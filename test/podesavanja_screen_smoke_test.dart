import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';

import 'opc_guide_test_bundle.dart';
import 'test_bootstrap.dart';

void main() {
  testWidgets('license entry is available on the first trial day', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final authRepo = AuthRepository(db);
    final session = SessionService();
    final settings = PodesavanjaRepository(db);
    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Synthetic Administrator',
      pin: '1234',
    );
    session.prijavi(admin);
    await settings.saveFirmaPodaci(
      const FirmaPodaciCompanion(
        pib: Value('111111111'),
        mb: Value('10000001'),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: settings,
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.podaciFirme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('LICENCA'));
    await tester.pumpAndSettle();
    expect(find.text('LICENCA / AKTIVACIJA'), findsOneWidget);
    expect(find.textContaining('Probni period traje do'), findsOneWidget);
    expect(find.textContaining('PIB: 111111111  MB: 10000001'), findsOneWidget);
    expect(find.text('Potpisana trajna licenca'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'AKTIVIRAJ'))
          .onPressed,
      isNotNull,
    );

    await tester.enterText(find.byType(TextField).last, 'invalid-token');
    await tester.tap(find.text('AKTIVIRAJ'));
    await tester.pumpAndSettle();
    expect(
      find.text('Licenca nije važeća za PIB i MB ove FIRME.'),
      findsOneWidget,
    );
  });

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

  testWidgets('O APLIKACIJI hides technical license diagnostics', (
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
    await tester.pumpAndSettle();

    expect(find.text('LICENCA / AKTIVACIJA'), findsNothing);
    expect(find.text('DIJAGNOSTIKA BAZE'), findsNothing);
    expect(find.textContaining('ID INSTALACIJE'), findsNothing);
    expect(find.textContaining('Lokalna licenca'), findsNothing);
  });

  testWidgets('O APLIKACIJI hides database lane diagnostics', (tester) async {
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
    await tester.pumpAndSettle();

    expect(find.text('DIJAGNOSTIKA BAZE'), findsNothing);
    expect(find.textContaining('Aktivna baza'), findsNothing);
    expect(find.textContaining('Build varijanta'), findsNothing);
    expect(find.text('LICENCA'), findsOneWidget);
    expect(find.text('NAPOMENA'), findsOneWidget);
  });

  testWidgets('O APLIKACIJI displays the short approved OPC description', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = createTestDatabase();
    addTearDown(db.close);
    final authRepo = AuthRepository(db);
    final session = SessionService();
    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    final guideBundle = await loadOpcGuideTestAssetBundle(tester);
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: guideBundle,
        child: wrapForTest(
          PodesavanjaScreen(
            repo: PodesavanjaRepository(db),
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.oAplikaciji,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    const description =
        'OPC pomaže u organizaciji i vođenju pogrebnih poslova. Na jednom '
        'mestu omogućava pregled predmeta, pripremu dokumentacije, praćenje '
        'obaveza i evidenciju robe i usluga.';
    expect(find.text(description), findsOneWidget);
    expect(find.text('PRIVATNOST I ČUVANJE PODATAKA'), findsOneWidget);
    expect(find.text('ZAŠTITA PODATAKA O LIČNOSTI'), findsOneWidget);
    expect(
      find.text(
        'OPC funkcioniše nezavisno od internet veze. Svi podaci koji se '
        'unose u aplikaciju čuvaju se lokalno, na uređaju korisnika.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Aplikacija nije dizajnirana da šalje korisničke podatke developeru '
        'niti da ih prenosi na udaljene servere. Developer nema ni posredan '
        'ni neposredan pristup podacima sačuvanim na uređaju korisnika.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Izvoz, prenos i čuvanje rezervnih kopija pokreće i kontroliše '
        'korisnik.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'OPC sadrži ugrađene mehanizme za zaštitu podataka o ličnosti, '
        'uključujući lokalnu kontrolu pristupa i mogućnost anonimizacije '
        'podataka u okviru PREDMETA.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Ovi mehanizmi namenjeni su zaštiti privatnosti i podršci '
        'odgovornom postupanju sa podacima o ličnosti. Korisnik zadržava '
        'odgovornost za način obrade, čuvanja i razmene podataka u skladu sa '
        'važećim propisima.',
      ),
      findsOneWidget,
    );
    expect(find.text('DEVELOPER'), findsOneWidget);
    expect(find.text('LICENCA'), findsOneWidget);
    expect(find.text('NAPOMENA'), findsOneWidget);

    await tester.tap(find.text('RAD U APLIKACIJI'));
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find
          .byKey(const Key('opc-guide-chapter-picker'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.text(description, skipOffstage: false), findsOneWidget);
    expect(find.text('RAD U APLIKACIJI'), findsWidgets);
    expect(find.byKey(const Key('opc-guide-chapter-picker')), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    for (final removedHeading in const [
      'LICENCA / AKTIVACIJA',
      'DIJAGNOSTIKA BAZE',
    ]) {
      expect(find.text(removedHeading), findsNothing);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    await tester.idle();
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
