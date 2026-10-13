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
