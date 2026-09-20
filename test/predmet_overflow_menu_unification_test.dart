import 'package:drift/drift.dart'
    show DatabaseConnection, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_overflow_menu.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';

void main() {
  testWidgets(
    'list-row and detail menus expose identical actions and eligibility by status',
    (tester) async {
      _setWideWindowsViewport(tester);
      final fixture = await _createFixture();
      addTearDown(() => _disposeFixture(tester, fixture));

      for (final status in const [
        'OTVOREN',
        'ZATVOREN',
        'ZAVRŠEN',
        'ANONIMIZOVAN',
      ]) {
        await _setStatus(fixture, status);
        final currentPredmet = await fixture.repository.getPredmet(
          fixture.selectedId,
        );

        await _mountList(tester, fixture, currentPredmet);
        final listActions = await _captureMenu(
          tester,
          'predmet-overflow-trigger-list-${fixture.selectedId}',
        );

        await _mountDetail(tester, fixture);
        final detailActions = await _captureMenu(
          tester,
          'predmet-overflow-trigger-detail-${fixture.selectedId}',
        );

        expect(
          listActions,
          equals(detailActions),
          reason: 'The two menus must match for status $status.',
        );
        expect(listActions.containsKey('delete'), isTrue);
        expect(listActions.containsKey('documents'), isTrue);
        expect(listActions.containsKey('reminder'), isTrue);
        expect(
          listActions['reminder']!.enabled,
          status == 'OTVOREN' || status == 'ZATVOREN',
        );
        expect(listActions['anonymize']!.enabled, status == 'ZAVRŠEN');
        expect(listActions.containsKey('exportJson'), status != 'ANONIMIZOVAN');
        expect(listActions.containsKey('finish'), status == 'ZATVOREN');
        expect(listActions.containsKey('edit'), status == 'ZATVOREN');
        expect(listActions.containsKey('close'), status == 'OTVOREN');
        expect(find.text('Uvoz JSON'), findsNothing);
      }
    },
  );

  testWidgets(
    'edit and close actions preserve behavior on both menu surfaces',
    (tester) async {
      _setWideWindowsViewport(tester);
      final fixture = await _createFixture();
      addTearDown(() => _disposeFixture(tester, fixture));

      for (final surface in const ['list', 'detail']) {
        await _setStatus(fixture, 'ZATVOREN');
        if (surface == 'list') {
          final predmet = await fixture.repository.getPredmet(
            fixture.selectedId,
          );
          await _mountList(tester, fixture, predmet);
          await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
        } else {
          await _mountDetail(tester, fixture);
          await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
        }
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('predmet-overflow-action-edit')));
        await tester.pumpAndSettle();
        expect(
          (await fixture.repository.getPredmet(fixture.selectedId)).status,
          'OTVOREN',
        );

        await _setStatus(fixture, 'OTVOREN');
        await (fixture.db.update(fixture.db.predmeti)
              ..where((row) => row.id.equals(fixture.selectedId)))
            .write(const PredmetiCompanion(ime: Value('Test')));
        if (surface == 'list') {
          final predmet = await fixture.repository.getPredmet(
            fixture.selectedId,
          );
          await _mountList(tester, fixture, predmet);
          await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
        } else {
          await _mountDetail(tester, fixture);
          await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
        }
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('predmet-overflow-action-close')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Zatvori predmet'), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog).last,
            matching: find.text('ZATVORI'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          (await fixture.repository.getPredmet(fixture.selectedId)).status,
          'ZATVOREN',
        );
      }
    },
  );

  testWidgets('shared lifecycle confirmation retains narrow Android sizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = await _createFixture();
    addTearDown(() => _disposeFixture(tester, fixture));

    for (final surface in const ['list', 'detail']) {
      await _setStatus(fixture, 'ZATVOREN');
      if (surface == 'list') {
        final predmet = await fixture.repository.getPredmet(fixture.selectedId);
        await _mountList(
          tester,
          fixture,
          predmet,
          platform: TargetPlatform.android,
        );
        await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      } else {
        await _mountDetail(tester, fixture, platform: TargetPlatform.android);
        await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('predmet-overflow-action-finish')));
      await tester.pumpAndSettle();

      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog).last);
      expect(dialog.scrollable, isTrue);
      expect(
        dialog.insetPadding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      );
      await tester.tap(find.text('ODUSTANI'));
      await tester.pumpAndSettle();
      expect(
        (await fixture.repository.getPredmet(fixture.selectedId)).status,
        'ZATVOREN',
      );
    }
  });

  testWidgets(
    'JSON export from the list menu uses the selected PREDMET and Documents stays separate',
    (tester) async {
      _setWideWindowsViewport(tester);
      final fixture = await _createFixture();
      addTearDown(() => _disposeFixture(tester, fixture));
      await _setStatus(fixture, 'ZAVRŠEN');
      final currentPredmet = await fixture.repository.getPredmet(
        fixture.selectedId,
      );
      await _mountList(tester, fixture, currentPredmet);

      await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      expect(find.text('Uvoz JSON'), findsNothing);
      await tester.tap(find.text('Izvezi JSON'));
      await tester.pumpAndSettle();

      expect(
        (await fixture.repository.getPredmet(fixture.selectedId)).exportVerzija,
        1,
      );
      expect(
        (await fixture.repository.getPredmet(fixture.otherId)).exportVerzija,
        0,
      );

      await _mountList(tester, fixture, currentPredmet);
      await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('predmet-overflow-action-documents')),
      );
      await tester.pumpAndSettle();
      expect(find.text('DOKUMENTI'), findsOneWidget);
      expect(find.text('Izvezi JSON'), findsNothing);
      expect(find.text('Uvoz JSON'), findsNothing);
    },
  );

  testWidgets('finish action invokes the same lifecycle path from both menus', (
    tester,
  ) async {
    _setWideWindowsViewport(tester);
    final fixture = await _createFixture();
    addTearDown(() => _disposeFixture(tester, fixture));

    for (final surface in const ['list', 'detail']) {
      await _setStatus(fixture, 'ZATVOREN');
      if (surface == 'list') {
        final predmet = await fixture.repository.getPredmet(fixture.selectedId);
        await _mountList(tester, fixture, predmet);
        await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      } else {
        await _mountDetail(tester, fixture);
        await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Označi kao ZAVRŠEN'));
      await tester.pumpAndSettle();
      expect(find.text('Označi predmet kao ZAVRŠEN'), findsOneWidget);
      await tester.tap(find.text('OZNAČI KAO ZAVRŠEN'));
      await tester.pumpAndSettle();
      expect(
        (await fixture.repository.getPredmet(fixture.selectedId)).status,
        'ZAVRŠEN',
      );
    }
  });

  testWidgets(
    'documents and PODSETNIK navigate from both list-row and detail menus',
    (tester) async {
      _setWideWindowsViewport(tester);
      final fixture = await _createFixture();
      addTearDown(() => _disposeFixture(tester, fixture));
      final predmet = await fixture.repository.getPredmet(fixture.selectedId);
      await _mountList(tester, fixture, predmet);

      await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('predmet-overflow-action-documents')),
      );
      await tester.pumpAndSettle();
      expect(find.text('DOKUMENTI'), findsOneWidget);
      await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('predmet-overflow-action-documents')),
      );
      await tester.pumpAndSettle();
      expect(find.text('DOKUMENTI'), findsOneWidget);
      await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('predmet-overflow-action-reminder')),
      );
      await tester.pumpAndSettle();
      expect(find.text('MODULI / PODSETNIK'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await _mountList(tester, fixture, predmet);
      await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('predmet-overflow-action-reminder')),
      );
      await tester.pumpAndSettle();
      expect(find.text('MODULI / PODSETNIK'), findsOneWidget);
    },
  );

  testWidgets(
    'GDPR and permanent-delete actions share confirmations and repository behavior on both surfaces',
    (tester) async {
      _setWideWindowsViewport(tester);
      final fixture = await _createFixture();
      addTearDown(() => _disposeFixture(tester, fixture));

      for (final surface in const ['list', 'detail']) {
        await _setStatus(fixture, 'ZAVRŠEN');
        if (surface == 'list') {
          final predmet = await fixture.repository.getPredmet(
            fixture.selectedId,
          );
          await _mountList(tester, fixture, predmet);
          await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
        } else {
          await _mountDetail(tester, fixture);
          await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
        }
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('predmet-overflow-action-anonymize')),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Anonimizovati predmet '), findsOneWidget);
        await tester.tap(find.text('ANONIMIZUJ'));
        await tester.pumpAndSettle();
        expect(
          (await fixture.repository.getPredmet(fixture.selectedId)).status,
          'ANONIMIZOVAN',
        );
      }

      for (final surface in const ['list', 'detail']) {
        await _setStatus(fixture, 'ZAVRŠEN');
        if (surface == 'list') {
          final predmet = await fixture.repository.getPredmet(
            fixture.selectedId,
          );
          await _mountList(tester, fixture, predmet);
          await tester.tap(find.byKey(_listTriggerKey(fixture.selectedId)));
        } else {
          await _mountDetail(tester, fixture);
          await tester.tap(find.byKey(_detailTriggerKey(fixture.selectedId)));
        }
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('predmet-overflow-action-delete')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Trajno brisanje predmeta'), findsOneWidget);
        await tester.tap(find.text('OBRIŠI TRAJNO'));
        await tester.pumpAndSettle();
        final remaining = await (fixture.db.select(
          fixture.db.predmeti,
        )..where((row) => row.id.equals(fixture.selectedId))).get();
        expect(remaining, isEmpty);

        // A new concrete PREDMET is required for the second-surface check.
        if (surface == 'list') {
          fixture.replaceSelectedId(
            await fixture.repository.kreirajPredmet(
              savetnikId: fixture.adminId,
            ),
          );
        }
      }
    },
  );
}

void _setWideWindowsViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<_OverflowFixture> _createFixture() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
  final authRepo = AuthRepository(db);
  final session = SessionService();
  final settingsRepo = PodesavanjaRepository(db);
  final repository = PredmetiRepository(db);
  final admin = await authRepo.kreirajPrvogAdmina(
    imePrezime: 'Overflow test administrator',
    pin: '1234',
  );
  session.prijavi(admin);
  final selectedId = await repository.kreirajPredmet(savetnikId: admin.id);
  final otherId = await repository.kreirajPredmet(savetnikId: admin.id);
  return _OverflowFixture(
    db: db,
    authRepo: authRepo,
    settingsRepo: settingsRepo,
    repository: repository,
    session: session,
    adminId: admin.id,
    selectedId: selectedId,
    otherId: otherId,
  );
}

Future<void> _setStatus(_OverflowFixture fixture, String status) async {
  await (fixture.db.update(fixture.db.predmeti)
        ..where((row) => row.id.equals(fixture.selectedId)))
      .write(PredmetiCompanion(status: Value(status)));
}

Future<void> _mountList(
  WidgetTester tester,
  _OverflowFixture fixture,
  PredmetiData predmet, {
  TargetPlatform platform = TargetPlatform.windows,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: ThemeData(platform: platform),
      home: ListaPredmetaScreen(
        predmetiRepo: fixture.repository,
        authRepo: fixture.authRepo,
        podesavanjaRepo: fixture.settingsRepo,
        session: fixture.session,
        predmetiStreamOverride: Stream.value([predmet]),
        runStartupSideEffects: false,
        entitlementPolicy: _fullEntitlementPolicy,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _mountDetail(
  WidgetTester tester,
  _OverflowFixture fixture, {
  TargetPlatform platform = TargetPlatform.windows,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: ThemeData(platform: platform),
      home: PredmetScreen(
        predmetId: fixture.selectedId,
        predmetiRepo: fixture.repository,
        session: fixture.session,
        entitlementPolicy: _fullEntitlementPolicy,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Map<String, ({String label, bool enabled})>> _captureMenu(
  WidgetTester tester,
  String triggerKey,
) async {
  await tester.tap(find.byKey(Key(triggerKey)));
  await tester.pumpAndSettle();
  final actions = <String, ({String label, bool enabled})>{};
  for (final action in PredmetOverflowAction.values) {
    final itemFinder = find.byKey(
      Key('predmet-overflow-action-${action.name}'),
    );
    if (itemFinder.evaluate().isEmpty) continue;
    final item = tester.widget<PopupMenuItem<PredmetOverflowAction>>(
      itemFinder,
    );
    final label = tester
        .widget<Text>(
          find.descendant(of: itemFinder, matching: find.byType(Text)),
        )
        .data!;
    actions[action.name] = (label: label, enabled: item.enabled);
  }
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
  return actions;
}

Key _listTriggerKey(int id) => Key('predmet-overflow-trigger-list-$id');
Key _detailTriggerKey(int id) => Key('predmet-overflow-trigger-detail-$id');

Future<void> _disposeFixture(
  WidgetTester tester,
  _OverflowFixture fixture,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.idle();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
  fixture.session.dispose();
  await fixture.db.close();
  await tester.idle();
  await tester.pump();
}

final _fullEntitlementPolicy = OpcEntitlementPolicy.fromPayload(
  const OpcEntitlementPayload(
    schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
    sourceKind: OpcEntitlementSourceKind.demoTest,
    environment: OpcEntitlementEnvironment.test,
    packageLevel: OpcPackageLevel.potpun,
  ),
);

class _OverflowFixture {
  _OverflowFixture({
    required this.db,
    required this.authRepo,
    required this.settingsRepo,
    required this.repository,
    required this.session,
    required this.adminId,
    required this.selectedId,
    required this.otherId,
  });

  final AppDatabase db;
  final AuthRepository authRepo;
  final PodesavanjaRepository settingsRepo;
  final PredmetiRepository repository;
  final SessionService session;
  final int adminId;
  int selectedId;
  final int otherId;

  void replaceSelectedId(int id) => selectedId = id;
}
