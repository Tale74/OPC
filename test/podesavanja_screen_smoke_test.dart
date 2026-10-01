import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'REFUNDACIJA PIO shows the approved instruction and input actions',
    (tester) async {
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
            initialSection: OpcSettingsSection.refundacijaPio,
          ),
        ),
      );
      await tester.pumpAndSettle();

      const instruction =
          'Unesite iznos naknade pogrebnih troškova preko Republičkog fonda '
          'za penzijsko i invalidsko osiguranje (PIO fond) za tekući period.';
      expect(find.text(instruction), findsOneWidget);
      expect(tester.widget<Text>(find.text(instruction)).textSpan, isNull);
      expect(
        find.text('Pravo na refundaciju ostvaruje se pod sledećim uslovima:'),
        findsNothing,
      );
      expect(find.text('Preminuli je penzioner'), findsNothing);
      expect(find.text('REFUNDACIJA U KORIST FIRME'), findsNothing);
      expect(find.textContaining('Iznos refundacije oduzima se'), findsNothing);
      expect(
        find.textContaining('Naručilac opreme i usluga je fizičko lice'),
        findsNothing,
      );
      expect(find.textContaining('PENZIONER = DA'), findsNothing);
      expect(find.textContaining('PLATILAC REFUNDIRA = NE'), findsNothing);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('IZNOS REFUNDACIJE PIO (RSD)'), findsOneWidget);
      expect(find.text('RSD'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'SAČUVAJ'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    },
  );

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
    await _pumpUntilText(
      tester,
      'Kompatibilni sačuvani paket (ne ograničava funkcije): Potpun',
    );

    expect(
      find.textContaining(
        'Lokalna licenca (neaktivna u razvojnom POTPUN režimu):',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Kompatibilni sačuvani paket (ne ograničava funkcije): Potpun'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Sve postojeće Windows/Android funkcije su dostupne po odluci vlasnika.',
      ),
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
    expect(
      find.text(
        'Kompatibilni sačuvani paket (ne ograničava funkcije): Osnovni',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('neaktivna u razvojnom'), findsNothing);
  });

  testWidgets('operational MODULI are absent from PODEŠAVANJA', (tester) async {
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
          initialSection: OpcSettingsSection.podaciFirme,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MODULI'), findsNothing);
    expect(find.text('PODSETNIK'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.idle();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('SAVETNIK gets backup actions without global admin settings', (
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
    final savetnik = await authRepo.kreirajKorisnika(
      imePrezime: 'Test Savetnik',
      uloga: 'SAVETNIK',
      pin: '5678',
    );
    session.prijavi(savetnik);

    expect(session.mozeBackup, isTrue);
    expect(session.jeAdmin, isFalse);
    expect(admin.uloga, 'ADMINISTRATOR');

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: PodesavanjaRepository(db),
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.korisnici,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Izvoz baze'), findsOneWidget);
    expect(find.byTooltip('Uvoz JSON'), findsOneWidget);
    expect(find.text('PODACI FIRME'), findsNothing);
    expect(find.text('KORISNICI'), findsNothing);
    expect(find.text('NOVI KORISNIK'), findsNothing);
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
