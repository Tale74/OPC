import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'Android narrow keeps lifecycle actions in persistent action bar',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = await _fixture(tester, TargetPlatform.android);
      addTearDown(() => _dispose(tester, fixture));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.toolbarHeight, 84);
      expect(find.text('SAČUVAJ'), findsOneWidget);
      expect(find.text('ZATVORI'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('ZATVORI'), matching: find.byType(AppBar)),
        findsNothing,
      );
      expect(
        find.byKey(Key('predmet-overflow-trigger-detail-${fixture.id}')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Windows wide keeps primary lifecycle actions in chrome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    expect(
      find.ancestor(of: find.text('SAČUVAJ'), matching: find.byType(AppBar)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('ZATVORI'), matching: find.byType(AppBar)),
      findsOneWidget,
    );
  });

  testWidgets('Android wide keeps primary lifecycle actions in chrome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.android);
    addTearDown(() => _dispose(tester, fixture));

    expect(
      find.ancestor(of: find.text('SAČUVAJ'), matching: find.byType(AppBar)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('ZATVORI'), matching: find.byType(AppBar)),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('predmet-overflow-trigger-detail-${fixture.id}')),
      findsOneWidget,
    );
  });

  testWidgets('open-case exit dialog gives closing no primary emphasis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(
      tester,
      TargetPlatform.windows,
      withIdentity: true,
    );
    addTearDown(() => _dispose(tester, fixture));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('OSTANI')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('IZAĐI')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('ZATVORI PREDMET')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.byType(TextButton)),
      findsNWidgets(3),
    );

    await tester.tap(
      find.descendant(of: dialog, matching: find.text('OSTANI')),
    );
    await tester.pumpAndSettle();
    expect(
      (await PredmetiRepository(fixture.db).getPredmet(fixture.id)).status,
      'OTVOREN',
    );
  });

  testWidgets('explicit save keeps identity typed immediately before tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    final surname = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'PREZIME',
    );
    await tester.enterText(name, 'TEST');
    await tester.enterText(surname, 'POSTOJANOST');
    await tester.tap(find.text('SAČUVAJ'));
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.ime, 'TEST');
    expect(saved.prezime, 'POSTOJANOST');
  });

  testWidgets('immediate back flushes identity before exit decision', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    await tester.enterText(name, 'TEST');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Izlazak iz otvorenog predmeta'), findsOneWidget);
    expect(find.text('Predmet nije validan'), findsNothing);
    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.ime, 'TEST');
  });

  testWidgets('identity autosave completes after short typing pause', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    await tester.enterText(name, 'TEST');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.ime, 'TEST');
  });

  testWidgets('changing PREDMET segment saves pending identity without Save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    await tester.enterText(name, 'TEST');
    await tester.tap(find.text('Činjenice o smrti').first);
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.ime, 'TEST');
  });

  testWidgets('changing identity field commits without Save', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();
    final name = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    final surname = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'PREZIME',
    );
    await tester.enterText(name, 'TEST');
    await tester.tap(surname);
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.ime, 'TEST');
  });

  testWidgets('changing payer segment flushes pending edit without Save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Platilac').first);
    await tester.pumpAndSettle();
    final payerName = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'IME',
    );
    await tester.enterText(payerName.first, 'TEST PLATILAC');
    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.naruIme, 'TEST PLATILAC');
  });

  testWidgets('PARTE decision survives immediate segment change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _fixture(tester, TargetPlatform.windows);
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.text('Parte').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PARTE su potrebne'));
    await tester.tap(find.text('Preminulo lice').first);
    await tester.pumpAndSettle();

    final saved = await PredmetiRepository(fixture.db).getPredmet(fixture.id);
    expect(saved.partePotrebna, isTrue);
  });
}

Future<_Fixture> _fixture(
  WidgetTester tester,
  TargetPlatform platform, {
  bool withIdentity = false,
}) async {
  final db = createTestDatabase();
  final repository = PredmetiRepository(db);
  final session = SessionService();
  final admin = await AuthRepository(
    db,
  ).kreirajPrvogAdmina(imePrezime: 'Compact chrome test', pin: '1234');
  session.prijavi(admin);
  final id = await repository.kreirajPredmet(savetnikId: admin.id);
  if (withIdentity) {
    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      const PredmetiCompanion(ime: Value('Ana'), prezime: Value('Test')),
    );
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: PredmetScreen(
        predmetId: id,
        predmetiRepo: repository,
        session: session,
        entitlementPolicy: OpcEntitlementPolicy.fromPayload(
          const OpcEntitlementPayload(
            schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
            sourceKind: OpcEntitlementSourceKind.demoTest,
            environment: OpcEntitlementEnvironment.test,
            packageLevel: OpcPackageLevel.potpun,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Fixture(db, session, id);
}

Future<void> _dispose(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  fixture.session.dispose();
  await fixture.db.close();
}

class _Fixture {
  const _Fixture(this.db, this.session, this.id);
  final AppDatabase db;
  final SessionService session;
  final int id;
}
