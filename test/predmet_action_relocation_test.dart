import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'Single-PREDMET export is in detail overflow and uses the open PREDMET',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = await _createFixture(
        tester,
        platform: TargetPlatform.windows,
        status: 'OTVOREN',
        openDocuments: true,
      );
      addTearDown(() => _disposeFixture(tester, fixture));

      expect(find.text('Izvezi JSON'), findsNothing);
      expect(find.text('Uvoz JSON'), findsNothing);

      await _openOverflow(tester);
      expect(find.text('Izvezi JSON'), findsOneWidget);
      expect(find.text('Uvoz JSON'), findsNothing);
      await tester.tap(find.text('Izvezi JSON'));
      await tester.pumpAndSettle();

      expect((await fixture.repository.getPredmet(fixture.selectedId)).exportVerzija, 1);
      expect((await fixture.repository.getPredmet(fixture.otherId)).exportVerzija, 0);
    },
  );

  testWidgets(
    'ZAVRŠEN remains in detail overflow and has no narrow/Segment 10 duplicate',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = await _createFixture(
        tester,
        platform: TargetPlatform.android,
        status: 'ZATVOREN',
      );
      addTearDown(() => _disposeFixture(tester, fixture));

      expect(find.text('ZAVRŠI'), findsNothing);
      final reviewSection = find.text('Pregled i potvrda');
      await tester.ensureVisible(reviewSection);
      await tester.tap(reviewSection);
      await tester.pumpAndSettle();
      expect(find.text('OZNAČI KAO ZAVRŠEN'), findsNothing);

      await _openOverflow(tester);
      expect(find.text('Označi kao ZAVRŠEN'), findsOneWidget);
      expect(find.text('Izvezi JSON'), findsOneWidget);
      await tester.tap(find.text('Označi kao ZAVRŠEN'));
      await tester.pumpAndSettle();

      expect(find.text('Označi predmet kao ZAVRŠEN'), findsOneWidget);
      await tester.tap(find.text('OZNAČI KAO ZAVRŠEN'));
      await tester.pumpAndSettle();
      expect(
        (await fixture.repository.getPredmet(fixture.selectedId)).status,
        'ZAVRŠEN',
      );
    },
  );

  testWidgets('ZAVRŠEN menu action remains unavailable before ZATVOREN', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await _createFixture(
      tester,
      platform: TargetPlatform.windows,
      status: 'OTVOREN',
    );
    addTearDown(() => _disposeFixture(tester, fixture));

    await _openOverflow(tester);
    expect(find.text('Označi kao ZAVRŠEN'), findsNothing);
    expect(find.text('Izvezi JSON'), findsOneWidget);
  });
}

Future<_ScreenFixture> _createFixture(
  WidgetTester tester, {
  required TargetPlatform platform,
  required String status,
  bool openDocuments = false,
}) async {
  final db = createTestDatabase();
  final repository = PredmetiRepository(db);
  final session = SessionService();
  final admin = await AuthRepository(db).kreirajPrvogAdmina(
    imePrezime: 'Relocation test administrator',
    pin: '1234',
  );
  session.prijavi(admin);
  final selectedId = await repository.kreirajPredmet(savetnikId: admin.id);
  final otherId = await repository.kreirajPredmet(savetnikId: admin.id);
  await (db.update(db.predmeti)..where((row) => row.id.equals(selectedId)))
      .write(PredmetiCompanion(status: Value(status)));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(platform: platform),
      home: PredmetScreen(
        predmetId: selectedId,
        predmetiRepo: repository,
        session: session,
        openDocuments: openDocuments,
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

  return _ScreenFixture(
    db: db,
    repository: repository,
    session: session,
    selectedId: selectedId,
    otherId: otherId,
  );
}

Future<void> _openOverflow(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
}

Future<void> _disposeFixture(
  WidgetTester tester,
  _ScreenFixture fixture,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  fixture.session.dispose();
  await fixture.db.close();
}

class _ScreenFixture {
  const _ScreenFixture({
    required this.db,
    required this.repository,
    required this.session,
    required this.selectedId,
    required this.otherId,
  });

  final AppDatabase db;
  final PredmetiRepository repository;
  final SessionService session;
  final int selectedId;
  final int otherId;
}
