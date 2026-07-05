import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('lista predmeta screen opens with stable actions', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      await db.close();
      await tester.idle();
      await tester.pump();
    });

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);
    final predmetiRepo = PredmetiRepository(db);
    final predmetiStream = Stream<List<PredmetiData>>.value(
      const <PredmetiData>[],
    );

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Savetnik',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        ListaPredmetaScreen(
          predmetiRepo: predmetiRepo,
          authRepo: authRepo,
          podesavanjaRepo: podesavanjaRepo,
          session: session,
          predmetiStreamOverride: predmetiStream,
          runStartupSideEffects: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OPC — LISTA PREDMETA'), findsOneWidget);
    expect(find.text('NOVI PREDMET'), findsOneWidget);
  });

  testWidgets(
    'POTPUN Podsetnik shortcut opens PODSETNIK module settings',
    (tester) async {
      final db = createTestDatabase();

      final authRepo = AuthRepository(db);
      final session = SessionService();
      final podesavanjaRepo = PodesavanjaRepository(db);
      final predmetiRepo = PredmetiRepository(db);
      final admin = await authRepo.kreirajPrvogAdmina(
        imePrezime: 'Test Administrator',
        pin: '1234',
      );
      session.prijavi(admin);
      final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: admin.id);
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(predmetId))).getSingle();
      final podsetnikPolicy = OpcEntitlementPolicy.fromPayload(
        const OpcEntitlementPayload(
          schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
          sourceKind: OpcEntitlementSourceKind.demoTest,
          environment: OpcEntitlementEnvironment.test,
          packageLevel: OpcPackageLevel.potpun,
        ),
      );

      await tester.pumpWidget(
        wrapForTest(
          ListaPredmetaScreen(
            predmetiRepo: predmetiRepo,
            authRepo: authRepo,
            podesavanjaRepo: podesavanjaRepo,
            session: session,
            predmetiStreamOverride: Stream.value([predmet]),
            runStartupSideEffects: false,
            entitlementPolicy: podsetnikPolicy,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      final shortcut = find.text('Podsetnik');
      expect(shortcut, findsOneWidget);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();

      expect(find.text('MODULI / PODSETNIK'), findsOneWidget);
      expect(find.byKey(const Key('podsetnik-module-settings')), findsOneWidget);
      expect(find.byKey(const Key('podsetnik-reminders-enabled')), findsOneWidget);
      expect(find.byKey(const Key('ceremony-reminders-enabled')), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
      await tester.pump();
      await tester.pumpAndSettle();
    },
  );

  test('Osnovni keeps Podsetnik shortcut disabled', () {
    expect(
      podsetnikShortcutEnabled(
        entitlementPolicy: OpcEntitlementPolicy.fromPayload(
          OpcEntitlementPayload.safeProductionFallback,
        ),
        predmetStatus: 'OTVOREN',
      ),
      isFalse,
    );
  });

  test('Srednji and Potpun keep Podsetnik module entitlement', () {
    for (final package in [OpcPackageLevel.srednji, OpcPackageLevel.potpun]) {
      final policy = OpcEntitlementPolicy.fromPayload(
        OpcEntitlementPayload(
          schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
          sourceKind: OpcEntitlementSourceKind.demoTest,
          environment: OpcEntitlementEnvironment.test,
          packageLevel: package,
        ),
      );
      expect(policy.isModuleAvailable(OpcModule.podsetnik), isTrue);
    }
  });

  test('anonymized PREDMET keeps Podsetnik shortcut disabled', () {
    expect(
      podsetnikShortcutEnabled(
        entitlementPolicy: _potpunPolicy(),
        predmetStatus: 'ANONIMIZOVAN',
      ),
      isFalse,
    );
  });

  testWidgets(
    'reminder dialog rows use spacing and alternating theme surfaces',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          const Scaffold(
            body: CeremonyReminderEventList(
              events: ['Prvi događaj', 'Drugi događaj'],
            ),
          ),
        ),
      );

      final first = tester.widget<Container>(
        find.byKey(const Key('ceremony-reminder-event-0')),
      );
      final second = tester.widget<Container>(
        find.byKey(const Key('ceremony-reminder-event-1')),
      );
      final firstDecoration = first.decoration! as BoxDecoration;
      final secondDecoration = second.decoration! as BoxDecoration;

      expect(firstDecoration.color, isNot(secondDecoration.color));
      expect(find.byType(SizedBox), findsWidgets);
    },
  );
}

OpcEntitlementPolicy _potpunPolicy() {
  return OpcEntitlementPolicy.fromPayload(
    const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: OpcEntitlementEnvironment.test,
      packageLevel: OpcPackageLevel.potpun,
    ),
  );
}
