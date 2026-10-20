import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_print_profile_store.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_composer_screen.dart';
import 'package:opc_v4/features/predmeti/citulje/presentation/citulje_module_screen.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_segment_manual_fields.dart';

import 'test_bootstrap.dart';

void main() {
  group('PREDMET visual manual-field inventory', () {
    late AppDatabase db;
    late PredmetiData emptyPredmet;

    setUp(() async {
      db = createTestDatabase();
      final actor = await AuthRepository(
        db,
      ).kreirajPrvogAdmina(imePrezime: 'UX inventory test', pin: '1234');
      final id = await PredmetiRepository(
        db,
      ).kreirajPredmet(savetnikId: actor.id);
      emptyPredmet = await PredmetiRepository(db).getPredmet(id);
    });

    tearDown(() async => db.close());

    PredmetSegmentFieldCount count(
      int segment,
      PredmetiData predmet, {
      List<IriuData> rows = const <IriuData>[],
      FirmaPodaciData? firmaPodaci,
    }) => countPredmetSegmentManualFields(
      segmentNumber: segment,
      predmet: predmet,
      iRiuRows: rows,
      firmaPodaci: firmaPodaci,
    );

    test('empty, partial and filled states follow existing values', () {
      PredmetSegmentFieldCount count(PredmetiData predmet) =>
          countPredmetSegmentManualFields(segmentNumber: 2, predmet: predmet);

      final empty = count(emptyPredmet);
      final partial = count(emptyPredmet.copyWith(datumSmrti: '10.10.2026.'));
      final filled = count(
        emptyPredmet.copyWith(
          datumSmrti: '10.10.2026.',
          mestoSmrti: 'BOLNICA',
          uzrokSmrti: 'PRIRODNA',
        ),
      );

      expect(empty.state, PredmetSegmentFillState.empty);
      expect((empty.filled, empty.total), (0, 3));
      expect(partial.state, PredmetSegmentFillState.partial);
      expect((partial.filled, partial.total), (1, 3));
      expect(filled.state, PredmetSegmentFillState.filled);
      expect((filled.filled, filled.total), (3, 3));
      expect(filled.stateLabel, 'POPUNJENO');
      expect(
        count(emptyPredmet).state,
        PredmetSegmentFillState.empty,
        reason: 'Recounting after clearing reads current PREDMET values.',
      );
    });

    test('hidden conditional fields and non-entry segments are excluded', () {
      final storedCeremonyValues = emptyPredmet.copyWith(
        grobljePolaganjaUrne: 'Test urne',
        urnaSifra: 'U-1',
        tipPolaganja: 'GROB',
        urnaParcela: 'A',
        grobnoMesto: 'POSTOJECE',
        parcela: 'P-1',
      );
      final burial = countPredmetSegmentManualFields(
        segmentNumber: 5,
        predmet: storedCeremonyValues.copyWith(vrstaCeremonije: 'SAHRANA'),
      );
      final cremation = countPredmetSegmentManualFields(
        segmentNumber: 5,
        predmet: storedCeremonyValues.copyWith(vrstaCeremonije: 'KREMACIJA'),
      );

      expect(burial.filled, lessThan(cremation.filled));
      expect(
        countPredmetSegmentManualFields(
          segmentNumber: 9,
          predmet: emptyPredmet,
        ).state,
        PredmetSegmentFillState.noFields,
      );
      expect(
        countPredmetSegmentManualFields(
          segmentNumber: 10,
          predmet: emptyPredmet,
        ).state,
        PredmetSegmentFillState.noFields,
      );
    });

    test('segment 1 counts the selected default sex as a completed choice', () {
      final male = count(
        1,
        emptyPredmet.copyWith(
          ime: 'Test',
          prezime: 'Osoba',
          srednje: 'Srednje',
          pol: 'M',
          jmbg: 'TEST-ID',
          datumRodjenja: '01.01.1970.',
          mestoRodjenja: 'Test grad',
          adresa: 'Test adresa',
          imeOca: 'Test otac',
          imeMajke: 'Test majka',
        ),
      );
      expect((male.filled, male.total), (10, 10));
      expect(male.state, PredmetSegmentFillState.filled);

      final femaleWithoutVisibleMaidenName = count(
        1,
        emptyPredmet.copyWith(pol: 'Z'),
      );
      expect(femaleWithoutVisibleMaidenName.total, 11);
      expect(
        femaleWithoutVisibleMaidenName.state,
        PredmetSegmentFillState.partial,
      );
    });

    test('segment 3 decisions do not change the manual-input inventory', () {
      final switchesOff = emptyPredmet.copyWith(
        vojnePocasti: 'NE',
        posmrtnaPomoc: 'NE',
        bracniDrugOstvarujePravo: 'NE',
        bracniDrugJePenzioner: 'NE',
      );
      final switchesOn = switchesOff.copyWith(
        vojnePocasti: 'DA',
        posmrtnaPomoc: 'DA',
        bracniDrugOstvarujePravo: 'DA',
        bracniDrugJePenzioner: 'DA',
      );
      final empty = count(3, switchesOff);
      final toggled = count(3, switchesOn);
      expect((empty.filled, empty.total), (0, 2));
      expect((toggled.filled, toggled.total), (0, 2));

      final complete = count(
        3,
        switchesOn.copyWith(
          bracnoStanje: 'OŽENJEN',
          bracniDrugIme: 'Test',
          bracniDrugPrezime: 'Supružnik',
          bracniDrugPol: 'M',
          bracniDrugJmbg: 'TEST-JMBG',
          radniStatus: '["VOJNI_PENZIONER"]',
          cin: 'Test čin',
        ),
      );
      expect((complete.filled, complete.total), (6, 6));
      expect(complete.state, PredmetSegmentFillState.filled);
    });

    test('segment 4 excludes the same-payer switch and read-only branches', () {
      final requester = emptyPredmet.copyWith(
        naruTip: 'FIZICKO_LICE',
        naruIme: 'Test',
        naruPrezime: 'Osoba',
        naruJmbg: 'TEST-ID',
        naruAdresa: 'Test adresa',
        naruBrojLk: 'TEST-LK',
        naruTelefon1: '0000000',
        naruTelefon2: '0000001',
        naruEmail: 'test@example.invalid',
        naruIstiZaJkp: true,
      );
      final samePayer = count(4, requester);
      final separatePayer = count(4, requester.copyWith(naruIstiZaJkp: false));
      expect(samePayer.state, PredmetSegmentFillState.filled);
      expect(separatePayer.total, samePayer.total + 9);

      final spouse = count(
        4,
        requester.copyWith(
          bracnoStanje: 'OŽENJEN',
          bracniDrugIme: 'Test',
          bracniDrugPrezime: 'Supružnik',
          naruIme: 'Test',
          naruPrezime: 'Supružnik',
          naruJmbg: 'TEST-JMBG',
        ),
      );
      expect(spouse.total, samePayer.total - 3);

      const firm = FirmaPodaciData(
        id: 1,
        naziv: 'Test firma',
        adresa: 'Test adresa firme',
        pib: 'TEST-PIB',
        mb: 'TEST-MB',
        sifraDelatnosti: 'TEST-DELATNOST',
        telefon: '0000002',
        odgovornoLice: 'Test lice',
        email: 'firma@example.invalid',
        sajt: '',
        parteDefaultTemplateId: '',
        racunOmogucen: false,
      );
      final legalRepresentative = requester.copyWith(
        naruTip: 'PRAVNO_LICE',
        naruPlNaziv: 'Test naručilac',
        naruPlAdresa: 'Test adresa',
        naruPlPib: 'TEST-PIB-2',
        naruPlMb: 'TEST-MB-2',
        naruPlOdgovornoLice: 'Test odgovorno lice',
        naruPlTelefon1: '0000003',
        naruPlTelefon2: '0000004',
        naruPlEmail: 'naručilac@example.invalid',
        naruIstiZaJkp: false,
        jkpTip: 'PRAVNO_LICE',
        jkpPlNaziv: firm.naziv,
        jkpPlPib: firm.pib,
      );
      final fromFirm = count(4, legalRepresentative, firmaPodaci: firm);
      final editableLegal = count(4, legalRepresentative);
      expect(fromFirm.state, PredmetSegmentFillState.filled);
      expect(editableLegal.total, fromFirm.total + 7);
    });

    test(
      'segment 5 switches alter only the availability of dependent inputs',
      () {
        final base = emptyPredmet.copyWith(
          vrstaCeremonije: 'SAHRANA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'NOVO',
          tipGrobnogMesta: 'GROB',
          opelo: 'NE',
          sahranaVanSrbije: false,
          docekPosmrtnihOstataka: false,
        );
        final baseCount = count(5, base);
        final enabledBranches = count(
          5,
          base.copyWith(
            opelo: 'DA',
            obavestitiSvestenika: 'NE',
            opeloMesto: 'KAPELA NA GROBLJU',
            vremeOpela: '10:00',
            sahranaVanSrbije: true,
            svisZemlja: 'Test zemlja',
            svisGrad: 'Test grad',
            docekPosmrtnihOstataka: true,
            promenaSanduka: true,
            docekMesto: 'Test mesto',
            docekDatum: '02.02.2026.',
            docekVreme: '11:00',
          ),
        );
        expect(enabledBranches.total, baseCount.total + 6);
        expect(enabledBranches.filled, greaterThan(baseCount.filled));

        final partiallyFilled = count(
          5,
          base.copyWith(groblje: 'Test groblje'),
        );
        expect(partiallyFilled.state, PredmetSegmentFillState.partial);
        final filledBase = count(
          5,
          base.copyWith(
            groblje: 'Test groblje',
            datumCeremonije: '02.02.2026.',
            vremeCeremonije: '12:00',
            vremeIspracaja: '11:30',
          ),
        );
        expect(filledBase.state, PredmetSegmentFillState.filled);
      },
    );

    test('legacy work-status flags expose the same conditional inventory', () {
      final legacy = emptyPredmet.copyWith(
        radniStatus: '',
        vojniPenzioner: 'DA',
      );
      final count = countPredmetSegmentManualFields(
        segmentNumber: 3,
        predmet: legacy,
      );
      expect(count.total, greaterThan(1));
    });

    test('segment 6 excludes switches but counts visible manual fields', () {
      final notRequired = countPredmetSegmentManualFields(
        segmentNumber: 6,
        predmet: emptyPredmet.copyWith(titula: 'Stored', zanimanje: 'Stored'),
      );
      final required = countPredmetSegmentManualFields(
        segmentNumber: 6,
        predmet: emptyPredmet.copyWith(partePotrebna: true),
      );
      final switchesChanged = countPredmetSegmentManualFields(
        segmentNumber: 6,
        predmet: emptyPredmet.copyWith(
          partePotrebna: true,
          titulaIspred: true,
          zanimanjeNaParti: true,
          cinNaParti: true,
          srednjeNaParti: true,
        ),
      );
      final nicknamePositionAvailable = countPredmetSegmentManualFields(
        segmentNumber: 6,
        predmet: emptyPredmet.copyWith(
          partePotrebna: true,
          nadimakNaParti: true,
        ),
      );
      final complete = countPredmetSegmentManualFields(
        segmentNumber: 6,
        predmet: emptyPredmet.copyWith(
          partePotrebna: true,
          titula: 'Test titula',
          zanimanje: 'Test zanimanje',
          nadimak: 'Test nadimak',
          ozaloseni: 'Test ožalošćeni',
          titulaIspred: true,
          zanimanjeNaParti: true,
          nadimakNaParti: true,
        ),
      );
      expect(notRequired.state, PredmetSegmentFillState.noFields);
      expect((required.filled, required.total), (2, 6));
      expect((switchesChanged.filled, switchesChanged.total), (2, 6));
      expect(
        (nicknamePositionAvailable.filled, nicknamePositionAvailable.total),
        (3, 7),
      );
      expect((complete.filled, complete.total), (7, 7));
      expect(complete.state, PredmetSegmentFillState.filled);
    });

    test('segment 8 excludes DA/NE decisions from amount completion', () {
      final noAmounts = emptyPredmet.copyWith(
        troskoviJkp: 0,
        avans: 0,
        popust: 0,
        penzionerSrbije: 'DA',
        narucilacRefundira: 'NE',
        jkpPlacaSamostalno: false,
      );
      final decisionsChanged = count(
        8,
        noAmounts.copyWith(narucilacRefundira: 'DA', jkpPlacaSamostalno: true),
      );
      expect((count(8, noAmounts).filled, count(8, noAmounts).total), (0, 3));
      expect((decisionsChanged.filled, decisionsChanged.total), (0, 3));

      final amountsFilled = count(
        8,
        noAmounts.copyWith(troskoviJkp: 10, avans: 20, popust: 5),
      );
      expect((amountsFilled.filled, amountsFilled.total), (3, 3));
      expect(amountsFilled.state, PredmetSegmentFillState.filled);
    });

    test(
      'segment 7 keeps its manual note inventory and segments 9/10 stay neutral',
      () {
        expect(count(7, emptyPredmet).state, PredmetSegmentFillState.empty);
        expect(
          count(7, emptyPredmet.copyWith(napomena: 'Test napomena')).state,
          PredmetSegmentFillState.filled,
        );
        expect(count(9, emptyPredmet).state, PredmetSegmentFillState.noFields);
        expect(count(10, emptyPredmet).state, PredmetSegmentFillState.noFields);
      },
    );
  });

  testWidgets(
    'existing PREDMET opens the segment overview and exposes ordered shortcuts',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = await _fixture(tester);
      addTearDown(() => _dispose(tester, fixture));

      expect(
        find.byKey(const Key('predmet-segment-number-hub-1')),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsNothing);
      expect(find.textContaining('PREDMET ('), findsNothing);
      expect(find.byKey(const Key('predmet-shortcut-parte')), findsOneWidget);
      expect(find.byKey(const Key('predmet-shortcut-citulje')), findsOneWidget);

      final parte = tester.getCenter(
        find.byKey(const Key('predmet-shortcut-parte')),
      );
      final citulje = tester.getCenter(
        find.byKey(const Key('predmet-shortcut-citulje')),
      );
      final overflow = tester.getCenter(
        find.byKey(Key('predmet-overflow-trigger-detail-${fixture.id}')),
      );
      expect(parte.dx, lessThan(citulje.dx));
      expect(citulje.dx, lessThan(overflow.dx));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final scheme = Theme.of(tester.element(find.byType(AppBar))).colorScheme;
      final foreground = appBar.foregroundColor ?? scheme.onSurface;
      final background = appBar.backgroundColor ?? scheme.surface;
      expect(_contrastRatio(foreground, background), greaterThan(4.5));

      final closeButton = find.ancestor(
        of: find.text('ZATVORI'),
        matching: find.byType(OutlinedButton),
      );
      expect(closeButton, findsOneWidget);
    },
  );

  testWidgets('explicit document navigation is preserved', (tester) async {
    final fixture = await _fixture(tester, openDocuments: true);
    addTearDown(() => _dispose(tester, fixture));
    expect(find.text('DOKUMENTI'), findsWidgets);
  });

  testWidgets('segment number colors reflect current values without counters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final states = <(PredmetiCompanion, Color)>[
      (const PredmetiCompanion(), const Color(0xFFD96A65)),
      (
        const PredmetiCompanion(datumSmrti: Value('10.10.2026.')),
        const Color(0xFFE9A34D),
      ),
      (
        const PredmetiCompanion(
          datumSmrti: Value('10.10.2026.'),
          mestoSmrti: Value('BOLNICA'),
          uzrokSmrti: Value('PRIRODNA'),
        ),
        const Color(0xFF7FAE83),
      ),
    ];
    for (final state in states) {
      final fixture = await _fixture(tester, initialValues: state.$1);
      addTearDown(() => _dispose(tester, fixture));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      final segmentNumber = find.byKey(
        const ValueKey('predmet-segment-number-hub-2'),
      );
      expect(
        tester
            .widget<CircleAvatar>(
              find.descendant(
                of: segmentNumber,
                matching: find.byType(CircleAvatar),
              ),
            )
            .backgroundColor,
        state.$2,
      );
      _expectNoVisibleSegmentProgress(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('no-fields segments keep a neutral outlined circle', (
    tester,
  ) async {
    final presentations = <(Size, TargetPlatform, bool)>[
      (const Size(390, 844), TargetPlatform.android, true),
      (const Size(1280, 900), TargetPlatform.android, false),
    ];
    for (final presentation in presentations) {
      tester.view.physicalSize = presentation.$1;
      tester.view.devicePixelRatio = 1;
      final fixture = await _fixture(tester, platform: presentation.$2);
      addTearDown(() => _dispose(tester, fixture));

      if (presentation.$3) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      for (final index in [9, 10]) {
        final number = find.byKey(
          ValueKey(
            presentation.$3
                ? 'predmet-segment-number-hub-$index'
                : 'predmet-segment-number-sidebar-$index',
          ),
        );
        final avatar = tester.widget<CircleAvatar>(
          find.ancestor(
            of: find.text('$index'),
            matching: find.byType(CircleAvatar),
          ),
        );
        expect(
          avatar.backgroundColor,
          Theme.of(tester.element(number)).colorScheme.surfaceContainerHighest,
        );
        final avatarChild = avatar.child! as SizedBox;
        final ring = avatarChild.child! as DecoratedBox;
        final decoration = ring.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
        expect(decoration.border, isNotNull);
        expect(
          (decoration.border! as Border).top.color,
          Theme.of(tester.element(number)).colorScheme.outline,
        );
        expect(find.text('$index'), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'obsolete PARTE instruction is gone while close remains blocked',
    (tester) async {
      final fixture = await _fixture(
        tester,
        parteRequired: true,
        withIdentity: true,
      );
      addTearDown(() => _dispose(tester, fixture));
      await PartePreparationRepository(fixture.db).initializeOrResume(
        predmetId: fixture.id,
        actor: fixture.session.korisnik!,
        entitlement: _testEntitlement,
      );

      expect(
        await PredmetiRepository(
          fixture.db,
        ).imaAktivnuNezavrsenuPartePripremu(fixture.id),
        isTrue,
      );
      await tester.tap(find.text('ZATVORI').first);
      await _pumpUntilFound(
        tester,
        find.text('PARTE priprema je započeta i nije završena.'),
      );

      expect(find.textContaining('Potvrdite finalni preview'), findsNothing);
      expect(find.text('Predmet ne može biti zatvoren'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('segment navigation and open headers keep number colors', (
    tester,
  ) async {
    for (final presentation in const [
      (Size(390, 844), TargetPlatform.android),
      (Size(1280, 900), TargetPlatform.android),
      (Size(1280, 900), TargetPlatform.windows),
    ]) {
      tester.view.physicalSize = presentation.$1;
      tester.view.devicePixelRatio = 1;
      final fixture = await _fixture(tester, platform: presentation.$2);
      addTearDown(() => _dispose(tester, fixture));

      final openedNumber = find.byKey(
        const ValueKey('predmet-segment-number-open-1'),
      );
      final initialHubNumber = find.byKey(
        const ValueKey('predmet-segment-number-hub-1'),
      );
      expect(openedNumber, findsNothing);
      _expectNoVisibleSegmentProgress(tester);

      if (presentation.$1.width < 760) {
        expect(initialHubNumber, findsOneWidget);
        await tester.tap(initialHubNumber);
        await tester.pumpAndSettle();
        expect(openedNumber, findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(initialHubNumber, findsOneWidget);
        _expectNoVisibleSegmentProgress(tester);
      } else {
        expect(
          find.byKey(const ValueKey('predmet-segment-number-sidebar-1')),
          findsOneWidget,
        );
        expect(find.text('PREGLED PREDMETA'), findsOneWidget);
        await tester.tap(find.text('Preminulo lice'));
        await tester.pumpAndSettle();
        expect(openedNumber, findsOneWidget);
        await tester.tap(find.text('PREGLED PREDMETA'));
        await tester.pumpAndSettle();
        expect(find.text('PREGLED PREDMETA'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('PARTE shortcut opens with the current PREDMET id', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = await _fixture(
      tester,
      parteRequired: true,
      withIdentity: true,
    );
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.byKey(const Key('predmet-shortcut-parte')));
    await _pumpUntilFound(tester, find.byType(ParteComposerScreen));
    final parte = tester.widget<ParteComposerScreen>(
      find.byType(ParteComposerScreen),
    );
    expect(parte.predmetId, fixture.id);
  });

  testWidgets('Citulje shortcut opens with the current PREDMET id', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = await _fixture(
      tester,
      withIdentity: true,
      withCitulje: true,
    );
    addTearDown(() => _dispose(tester, fixture));

    await tester.tap(find.byKey(const Key('predmet-shortcut-citulje')));
    await _pumpUntilFound(tester, find.byType(CituljePreparationScreen));
    final citulje = tester.widget<CituljePreparationScreen>(
      find.byType(CituljePreparationScreen),
    );
    expect(citulje.predmet.id, fixture.id);
  });

  testWidgets('PARTE keeps the explicit refresh prompt after PREDMET changes', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await db.close();
      await tester.pump(const Duration(milliseconds: 1));
    });
    final actor = await AuthRepository(
      db,
    ).kreirajPrvogAdmina(imePrezime: 'PARTE source-change test', pin: '1234');
    final repository = PredmetiRepository(db);
    final id = await repository.kreirajPredmet(savetnikId: actor.id);
    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      const PredmetiCompanion(
        partePotrebna: Value(true),
        ime: Value('Ana'),
        prezime: Value('Test'),
      ),
    );
    await PartePreparationRepository(db).initializeOrResume(
      predmetId: id,
      actor: actor,
      entitlement: _testEntitlement,
    );
    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      const PredmetiCompanion(titula: Value('Izmenjena titula')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ParteComposerScreen(
          predmetId: id,
          predmetiRepository: repository,
          actor: actor,
          printProfileStore: _MemoryPrintProfileStore(),
          entitlement: _testEntitlement,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('PONOVO SASTAVI IZ PREDMETA'));
    expect(
      find.textContaining('Privremeni tekst nije automatski prepisan.'),
      findsOneWidget,
    );
  });
}

Future<_Fixture> _fixture(
  WidgetTester tester, {
  bool openDocuments = false,
  bool parteRequired = false,
  bool withIdentity = false,
  bool withCitulje = false,
  PredmetiCompanion? initialValues,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  final db = createTestDatabase();
  final repository = PredmetiRepository(db);
  final session = SessionService();
  final admin = await AuthRepository(
    db,
  ).kreirajPrvogAdmina(imePrezime: 'Night UX test', pin: '1234');
  session.prijavi(admin);
  final id = await repository.kreirajPredmet(savetnikId: admin.id);
  if (parteRequired || withIdentity) {
    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      PredmetiCompanion(
        partePotrebna: Value(parteRequired),
        ime: Value(withIdentity ? 'Ana' : ''),
        prezime: Value(withIdentity ? 'Test' : ''),
      ),
    );
  }
  if (initialValues != null) {
    await (db.update(
      db.predmeti,
    )..where((row) => row.id.equals(id))).write(initialValues);
  }
  if (withCitulje) {
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: id,
            interniNaziv: 'CITULJA_POLITIKA',
            portableOccurrenceId: const Value('night-ux-citulja-1'),
          ),
        );
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        platform: platform,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A5276)),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A5276),
          ).primary,
          foregroundColor: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A5276),
          ).onPrimary,
        ),
      ),
      home: PredmetScreen(
        predmetId: id,
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
  return _Fixture(db, session, id);
}

Future<void> _dispose(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  fixture.session.dispose();
  await fixture.db.close();
  await tester.pump(Duration.zero);
}

void _expectNoVisibleSegmentProgress(WidgetTester tester) {
  expect(
    find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          RegExp(r'^\d+\s*/\s*\d+$').hasMatch(widget.data ?? ''),
    ),
    findsNothing,
  );
  for (final label in const [
    'NEMA UNETIH',
    'DELIMIČNO',
    'POPUNJENO',
    'NEMA POLJA',
  ]) {
    expect(find.text(label), findsNothing);
  }
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsOneWidget);
}

const _testEntitlement = OpcEntitlementPolicy.fromSource(
  OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
);

class _MemoryPrintProfileStore extends PartePrintProfileStore {
  _MemoryPrintProfileStore()
    : super(rootDirectory: () async => Directory.current);

  final Map<String, PartePrintProfile> _profiles = {};

  @override
  Future<PartePrintProfile> loadForTemplate(String templateId) async =>
      _profiles[templateId] ?? const PartePrintProfile();

  @override
  Future<void> saveForTemplate(
    String templateId,
    PartePrintProfile profile,
  ) async {
    _profiles[templateId] = profile;
  }

  @override
  Future<void> resetForTemplate(String templateId) async {
    _profiles.remove(templateId);
  }
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final darker = foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}

class _Fixture {
  const _Fixture(this.db, this.session, this.id);
  final AppDatabase db;
  final SessionService session;
  final int id;
}
