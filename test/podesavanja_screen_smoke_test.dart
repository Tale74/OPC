import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('podesavanja screen can open directly on korisnici section', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: podesavanjaRepo,
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.korisnici,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KORISNICI'), findsWidgets);
    expect(find.text('Oporavak pristupa aplikaciji'), findsOneWidget);
    expect(find.text('Sigurnosni kod nije podešen.'), findsOneWidget);
  });

  testWidgets('O APLIKACIJI shows development POTPUN as effective source', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: podesavanjaRepo,
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.oAplikaciji,
          entitlementPolicy: OpcEntitlementPolicy.fromPayload(
            OpcEntitlementPayload.presentationPotpun,
          ),
        ),
      ),
    );
    await _pumpUntilText(tester, 'Aktivni paket runtime-a: Potpun');

    expect(
      find.textContaining(
        'Lokalna licenca (neaktivna u razvojnom POTPUN režimu):',
      ),
      findsOneWidget,
    );
    expect(find.text('Aktivni paket runtime-a: Potpun'), findsOneWidget);
    expect(
      find.text('Aktivni entitlement runtime-a: razvojni POTPUN režim / test.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Razvojni/runtime-validation režim je aktivan'),
      findsOneWidget,
    );
  });

  testWidgets('O APLIKACIJI preserves final-package local diagnostics', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final authRepo = AuthRepository(db);
    final session = SessionService();
    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: PodesavanjaRepository(db),
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.oAplikaciji,
          entitlementPolicy: _osnovniLocalPolicy(),
        ),
      ),
    );
    await _pumpUntilText(
      tester,
      'Instalirana lokalna licenca - paket: Osnovni',
    );

    expect(
      find.text('Instalirana lokalna licenca - paket: Osnovni'),
      findsOneWidget,
    );
    expect(find.text('Aktivni paket runtime-a: Osnovni'), findsOneWidget);
    expect(find.textContaining('neaktivna u razvojnom'), findsNothing);
  });

  testWidgets('MODULI exposes PODSETNIK with package-safe visibility', (
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
    });
    final authRepo = AuthRepository(db);
    final session = SessionService();
    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: PodesavanjaRepository(db),
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.moduli,
          entitlementPolicy: _potpunDemoPolicy(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PODSETNIK'), findsOneWidget);
    expect(
      find.text('Modul je dostupan. Podešavanja se čuvaju po PREDMETU.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.idle();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpUntilText(
  WidgetTester tester,
  String text, {
  int maxPumps = 100,
}) async {
  for (var i = 0; i < maxPumps; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(text).evaluate().isNotEmpty) {
      return;
    }
  }
  final renderedText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((value) => value.trim().isNotEmpty)
      .join('\n');
  fail('Text "$text" was not rendered. Rendered text:\n$renderedText');
}

OpcEntitlementPolicy _potpunDemoPolicy() {
  return OpcEntitlementPolicy.fromPayload(
    const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: OpcEntitlementEnvironment.test,
      packageLevel: OpcPackageLevel.potpun,
    ),
  );
}

OpcEntitlementPolicy _osnovniLocalPolicy() {
  return OpcEntitlementPolicy.fromPayload(
    const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.localLicense,
      environment: OpcEntitlementEnvironment.production,
      packageLevel: OpcPackageLevel.osnovni,
      diagnosticsLabel: 'synthetic_local_osnovni',
    ),
  );
}
