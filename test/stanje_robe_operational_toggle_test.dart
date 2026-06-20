import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/catalog/stock_catalog_identity.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';
import 'package:opc_v4/features/stanje_robe/application/stanje_robe_lifecycle_service.dart';
import 'package:opc_v4/features/stanje_robe/application/stanje_robe_operational_availability.dart';
import 'package:opc_v4/features/stanje_robe/data/stanje_robe_effects_repository.dart';
import 'package:opc_v4/features/stanje_robe/data/stanje_robe_posledice_repository.dart';
import 'package:opc_v4/features/stanje_robe/data/stanje_robe_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('STANJE ROBE operational toggle', () {
    test(
      'defaults to disabled and preserves persisted operational setting',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final repo = PodesavanjaRepository(db);
        final availability = StanjeRobeOperationalAvailability(
          podesavanjaRepository: repo,
          entitlementPolicy: _potpunPolicy(),
        );

        expect(
          await availability.readStatus(),
          StanjeRobeOperationalStatus.disabled,
        );

        await repo.setStanjeRobeOperativnoOmoguceno(true);
        expect(
          await availability.readStatus(),
          StanjeRobeOperationalStatus.active,
        );

        final deniedAvailability = StanjeRobeOperationalAvailability(
          podesavanjaRepository: repo,
          entitlementPolicy: _osnovniPolicy(),
        );
        expect(
          await deniedAvailability.readStatus(),
          StanjeRobeOperationalStatus.notLicensed,
        );

        await repo.setStanjeRobeOperativnoOmoguceno(false);
        expect(
          await availability.readStatus(),
          StanjeRobeOperationalStatus.disabled,
        );
      },
    );

    test(
      'disabling preserves stock, applied effects, and consequences',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final repo = PodesavanjaRepository(db);
        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(db, predmetId: predmet.id);
        await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 3);
        await _insertAppliedEffect(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );
        await StanjeRobePoslediceRepository(db).createOrUpdateUnresolved(
          predmetId: predmet.id,
          iriuId: iriuId,
          kategorija: 'SANDUK',
          katalogStableArticleId: 'stock-stable-toggle',
          selectedNazivSnapshot: 'Test sanduk',
          selectedIznosSnapshot: 100,
          sourceLifecycleEvent: stanjeRobePosledicaEventFirstSelection,
          effectQuantity: 1,
          availableQuantityAtCreation: 0,
          shortageQuantityAtCreation: 1,
        );

        await repo.setStanjeRobeOperativnoOmoguceno(false);

        expect(await db.select(db.stanjeRobeStavke).get(), hasLength(1));
        expect(
          await db.select(db.stanjeRobeAppliedEffects).get(),
          hasLength(1),
        );
        expect(await db.select(db.stanjeRobePosledice).get(), hasLength(1));
        expect(await db.select(db.predmeti).get(), hasLength(1));
        expect(await db.select(db.iriu).get(), hasLength(1));
        expect(await db.select(db.katalogArtikli).get(), isNotEmpty);
      },
    );

    test(
      'stock data and POTPUN entitlement do not imply operational ON',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final repo = PodesavanjaRepository(db);
        await _insertCatalogArticle(
          db,
          stableId: 'stock-existing-entitlement',
          category: 'SANDUK',
          name: 'Entitlement sanduk',
        );
        await _insertStock(
          db,
          stableId: 'stock-existing-entitlement',
          quantity: 4,
        );

        final availability = StanjeRobeOperationalAvailability(
          podesavanjaRepository: repo,
          entitlementPolicy: _potpunPolicy(),
        );

        expect(
          await repo.isStanjeRobeOperativnoOmoguceno(),
          isFalse,
        );
        expect(
          await availability.readStatus(),
          StanjeRobeOperationalStatus.disabled,
        );
      },
    );

    test('disabled setting suppresses IRIU stock lifecycle effects', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final repo = PodesavanjaRepository(db);
      final predmet = await _insertPredmet(db);
      await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 3);
      await repo.setStanjeRobeOperativnoOmoguceno(false);

      await IriuRepository(db).dodajStavku(
        predmetId: predmet.id,
        interniNaziv: 'SANDUK',
        nazivPrikaz: 'Test sanduk',
        katalogStableArticleId: 'stock-stable-toggle',
        iznos: 100,
      );

      final stock =
          await (db.select(db.stanjeRobeStavke)
                ..where((s) => s.stableArticleId.equals('stock-stable-toggle')))
              .getSingle();
      expect(stock.trenutnaKolicina, 3);
      expect(await db.select(db.stanjeRobeAppliedEffects).get(), isEmpty);
      expect(await db.select(db.stanjeRobePosledice).get(), isEmpty);
      expect(await db.select(db.iriu).get(), hasLength(1));
    });

    test(
      'replenishment alone does not resolve an unresolved consequence',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(db, predmetId: predmet.id);
        await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 0);
        await _insertUnresolvedEffect(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );
        await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );

        await StanjeRobeRepository(db).sacuvajStanje(
          stableArticleId: 'stock-stable-toggle',
          trenutnaKolicina: 3,
          minimalnaKolicina: 0,
          aktivna: true,
        );

        final unresolved = await StanjeRobePoslediceRepository(
          db,
        ).listActiveUnresolvedForPredmet(predmet.id);
        final effect = await StanjeRobeEffectsRepository(db)
            .getCurrentEffectForSelection(
              predmetId: predmet.id,
              iriuId: iriuId,
              kategorija: 'SANDUK',
            );
        expect(unresolved, hasLength(1));
        expect(effect?.effectStatus, stanjeRobeEffectStatusUnresolved);
      },
    );

    test(
      'resolution fails without sufficient stock and mutates nothing',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(db, predmetId: predmet.id);
        await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 0);
        await _insertUnresolvedEffect(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );
        final consequence = await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );

        final result = await StanjeRobeLifecycleService(db: db)
            .resolveUnresolvedConsequenceAfterReplenishment(
              consequenceId: consequence.id,
            );

        final stock =
            await (db.select(db.stanjeRobeStavke)..where(
                  (s) => s.stableArticleId.equals('stock-stable-toggle'),
                ))
                .getSingle();
        final unresolved = await StanjeRobePoslediceRepository(
          db,
        ).listActiveUnresolvedForPredmet(predmet.id);
        final effect = await StanjeRobeEffectsRepository(db)
            .getCurrentEffectForSelection(
              predmetId: predmet.id,
              iriuId: iriuId,
              kategorija: 'SANDUK',
            );
        expect(
          result.outcome,
          StanjeRobeLifecycleOutcome.resolutionInsufficientStock,
        );
        expect(stock.trenutnaKolicina, 0);
        expect(unresolved, hasLength(1));
        expect(effect?.effectStatus, stanjeRobeEffectStatusUnresolved);
      },
    );

    test(
      'explicit resolution applies one decrement and is idempotent',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(db, predmetId: predmet.id);
        await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 3);
        await _insertUnresolvedEffect(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );
        final consequence = await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-toggle',
        );

        final service = StanjeRobeLifecycleService(db: db);
        final first = await service
            .resolveUnresolvedConsequenceAfterReplenishment(
              consequenceId: consequence.id,
            );
        final second = await service
            .resolveUnresolvedConsequenceAfterReplenishment(
              consequenceId: consequence.id,
            );

        final stock =
            await (db.select(db.stanjeRobeStavke)..where(
                  (s) => s.stableArticleId.equals('stock-stable-toggle'),
                ))
                .getSingle();
        final unresolved = await StanjeRobePoslediceRepository(
          db,
        ).listActiveUnresolvedForPredmet(predmet.id);
        final effects = await db.select(db.stanjeRobeAppliedEffects).get();
        final consequences = await db.select(db.stanjeRobePosledice).get();
        final iriuRows = await db.select(db.iriu).get();
        final predmeti = await db.select(db.predmeti).get();

        expect(
          first.outcome,
          StanjeRobeLifecycleOutcome.resolvedAfterReplenishment,
        );
        expect(
          second.outcome,
          StanjeRobeLifecycleOutcome.resolutionNoActiveConsequence,
        );
        expect(stock.trenutnaKolicina, 2);
        expect(unresolved, isEmpty);
        expect(effects.single.effectStatus, stanjeRobeEffectStatusApplied);
        expect(consequences.single.status, stanjeRobePosledicaStatusResolved);
        expect(iriuRows.single.nazivPrikaz, 'Test sanduk');
        expect(predmeti.single.ime, 'Test');
      },
    );

    test('disabled operational setting blocks explicit resolution', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final repo = PodesavanjaRepository(db);
      final predmet = await _insertPredmet(db);
      final iriuId = await _insertIriu(db, predmetId: predmet.id);
      await _insertStock(db, stableId: 'stock-stable-toggle', quantity: 3);
      await _insertUnresolvedEffect(
        db,
        predmetId: predmet.id,
        iriuId: iriuId,
        stableId: 'stock-stable-toggle',
      );
      final consequence = await _insertUnresolvedConsequence(
        db,
        predmetId: predmet.id,
        iriuId: iriuId,
        stableId: 'stock-stable-toggle',
      );
      await repo.setStanjeRobeOperativnoOmoguceno(false);

      final availability = StanjeRobeOperationalAvailability(
        podesavanjaRepository: repo,
        entitlementPolicy: _potpunPolicy(),
      );
      final result =
          await StanjeRobeLifecycleService(
            db: db,
            isOperationallyActive: availability.isActive,
          ).resolveUnresolvedConsequenceAfterReplenishment(
            consequenceId: consequence.id,
          );

      final stock =
          await (db.select(db.stanjeRobeStavke)
                ..where((s) => s.stableArticleId.equals('stock-stable-toggle')))
              .getSingle();
      final unresolved = await StanjeRobePoslediceRepository(
        db,
      ).listActiveUnresolvedForPredmet(predmet.id);
      expect(result.outcome, StanjeRobeLifecycleOutcome.operationallyDisabled);
      expect(stock.trenutnaKolicina, 3);
      expect(unresolved, hasLength(1));
    });

    testWidgets('ADMIN sees active operational status and toggle control', (
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
      await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(true);

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Status: licencirano i operativno aktivno.'),
        findsOneWidget,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Upravljaj stanjem robe'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('ADMIN manages quantities and resolves after replenishment', (
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
      await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(true);

      final predmet = await _insertPredmet(db);
      final iriuId = await _insertIriu(db, predmetId: predmet.id);
      await _insertCatalogArticle(
        db,
        stableId: 'stock-stable-managed',
        category: 'SANDUK',
        name: 'Managed sanduk',
      );
      await db
          .into(db.stanjeRobeStavke)
          .insert(
            StanjeRobeStavkeCompanion.insert(
              stableArticleId: 'stock-stable-managed',
              trenutnaKolicina: const Value(2),
              minimalnaKolicina: const Value(5),
              aktivna: const Value(true),
              datumKreiranja: const Value('2026-05-20T10:00:00.000'),
              datumAzuriranja: const Value('2026-05-20T10:00:00.000'),
            ),
          );
      await StanjeRobePoslediceRepository(db).createOrUpdateUnresolved(
        predmetId: predmet.id,
        iriuId: iriuId,
        kategorija: 'SANDUK',
        katalogStableArticleId: 'stock-stable-managed',
        selectedNazivSnapshot: 'Managed sanduk',
        selectedIznosSnapshot: 120,
        sourceLifecycleEvent: stanjeRobePosledicaEventFirstSelection,
        effectQuantity: 1,
        availableQuantityAtCreation: 0,
        shortageQuantityAtCreation: 1,
      );
      await _insertUnresolvedEffect(
        db,
        predmetId: predmet.id,
        iriuId: iriuId,
        stableId: 'stock-stable-managed',
      );

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upravljaj stanjem robe'));
      await tester.pumpAndSettle();

      expect(find.text('Managed sanduk'), findsOneWidget);
      expect(
        find.text('Kategorija: SANDUK - Stable ID: stock-stable-managed'),
        findsOneWidget,
      );
      expect(find.text('Trenutno: 2'), findsOneWidget);
      expect(find.text('Minimum: 5'), findsOneWidget);
      expect(find.text('Ispod minimuma'), findsOneWidget);
      expect(find.text('Nerazrešeno: 1'), findsOneWidget);

      await tester.tap(find.text('Izmeni').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '7');
      await tester.enterText(find.byType(TextField).at(1), '3');
      await tester.tap(find.text('SAČUVAJ'));
      await tester.pumpAndSettle();

      final stock =
          await (db.select(
                db.stanjeRobeStavke,
              )..where((s) => s.stableArticleId.equals('stock-stable-managed')))
              .getSingle();
      expect(stock.trenutnaKolicina, 7);
      expect(stock.minimalnaKolicina, 3);
      final unresolved = await StanjeRobePoslediceRepository(
        db,
      ).listActiveUnresolvedForPredmet(predmet.id);
      expect(
        unresolved.where(
          (row) =>
              row.katalogStableArticleId == 'stock-stable-managed' &&
              row.status == stanjeRobePosledicaStatusUnresolved,
        ),
        hasLength(1),
      );

      await tester.tap(find.text('Razreši').last);
      await tester.pumpAndSettle();
      expect(find.text('Razreši posledicu'), findsOneWidget);
      await tester.tap(find.text('RAZREŠI'));
      await tester.pumpAndSettle();

      final resolvedStock =
          await (db.select(
                db.stanjeRobeStavke,
              )..where((s) => s.stableArticleId.equals('stock-stable-managed')))
              .getSingle();
      final activeAfterResolve = await StanjeRobePoslediceRepository(
        db,
      ).listActiveUnresolvedForPredmet(predmet.id);
      final effectsAfterResolve = await db
          .select(db.stanjeRobeAppliedEffects)
          .get();
      expect(resolvedStock.trenutnaKolicina, 6);
      expect(activeAfterResolve, isEmpty);
      expect(
        effectsAfterResolve.single.effectStatus,
        stanjeRobeEffectStatusApplied,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('ADMIN initializes empty stock rows from covered catalog', (
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
      await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(true);
      await _insertCatalogArticle(
        db,
        stableId: 'stock-init-sanduk',
        category: 'SANDUK',
        name: 'Init sanduk',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-init-obelezje',
        category: 'OBELEZJE',
        name: 'Init obelezje',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-init-pokrov',
        category: 'POKROV_GARNITURA',
        name: 'Init pokrov',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-init-cvece',
        category: 'CVECE',
        name: 'Init cvece',
      );

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upravljaj stanjem robe'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nema evidentiranih STANJE ROBE stavki.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Modul je dostupan, ali jos nije inicijalizovan. '
          'Inicijalizujte praćenje robe iz kataloga za kategorije koje se '
          'prate kroz STANJE ROBE.',
        ),
        findsOneWidget,
      );
      expect(find.text('Inicijalizuj stanje robe iz kataloga'), findsOneWidget);

      await tester.tap(find.text('Inicijalizuj stanje robe iz kataloga'));
      await tester.pumpAndSettle();

      final rows = await db.select(db.stanjeRobeStavke).get();
      final stableIds = rows.map((row) => row.stableArticleId).toSet();
      expect(
        stableIds,
        containsAll([
          'stock-init-sanduk',
          'stock-init-obelezje',
          'stock-init-pokrov',
        ]),
      );
      expect(stableIds, isNot(contains('stock-init-cvece')));
      for (final row in rows) {
        expect(row.trenutnaKolicina, 0);
        expect(row.minimalnaKolicina, 0);
        expect(row.aktivna, isTrue);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('ADMIN initialization includes real SANDUK V-0 catalog article', (
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
      await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(true);
      await _insertCatalogArticle(
        db,
        stableId: StockCatalogIdentity.sandukV0StableId,
        category: 'SANDUK',
        name: 'SANDUK V-0',
      );
      await _insertCatalogArticle(
        db,
        stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
        category: 'SANDUK',
        name: 'SANDUK V-17 POLUKOVČEG',
      );

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upravljaj stanjem robe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inicijalizuj stanje robe iz kataloga'));
      await tester.pumpAndSettle();

      final rows = await db.select(db.stanjeRobeStavke).get();
      final stableIds = rows.map((row) => row.stableArticleId).toSet();
      expect(
        stableIds,
        contains(StockCatalogIdentity.sandukV0StableId),
      );
      expect(
        stableIds,
        contains(StockCatalogIdentity.sandukV17PolukovcegStableId),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    test('stock catalog read path returns covered catalog articles', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final repo = PodesavanjaRepository(db);
      await _insertCatalogArticle(
        db,
        stableId: 'stock-read-sanduk',
        category: 'SANDUK',
        name: 'Read sanduk',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-read-obelezje',
        category: 'OBELEZJE',
        name: 'Read obelezje',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-read-pokrov',
        category: 'POKROV_GARNITURA',
        name: 'Read pokrov',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'stock-read-cvece',
        category: 'CVECE',
        name: 'Read cvece',
      );

      final entries = await repo
          .getKatalogSaArtiklimaLightweightZaKategorije(const <String>{
            StanjeRobeLifecycleService.kategorijaSanduk,
            StanjeRobeLifecycleService.kategorijaObelezje,
            StanjeRobeLifecycleService.kategorijaPokrovGarnitura,
          });
      final stableIds = entries
          .expand((entry) => entry.artikli)
          .map((article) => article.stableArticleId)
          .toSet();

      expect(
        stableIds,
        containsAll(<String>{
          'stock-read-sanduk',
          'stock-read-obelezje',
          'stock-read-pokrov',
        }),
      );
      expect(stableIds, isNot(contains('stock-read-cvece')));
    });

    test('visible catalog read path includes stock-covered categories', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final repo = PodesavanjaRepository(db);
      await _insertCatalogArticle(
        db,
        stableId: 'visible-sanduk',
        category: 'SANDUK',
        name: 'Visible sanduk',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'visible-obelezje',
        category: 'OBELEZJE',
        name: 'Visible obelezje',
      );
      await _insertCatalogArticle(
        db,
        stableId: 'visible-pokrov',
        category: 'POKROV_GARNITURA',
        name: 'Visible pokrov',
      );

      final entries = await repo.getKatalogSaArtiklimaLightweight();
      final articleStableIds = entries
          .expand((entry) => entry.artikli)
          .map((article) => article.stableArticleId)
          .toSet();

      expect(
        articleStableIds,
        containsAll(<String>{
          'visible-sanduk',
          'visible-obelezje',
          'visible-pokrov',
        }),
      );
    });

    testWidgets(
      'ADMIN stock row falls back to stable id when catalog display is missing',
      (tester) async {
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
        await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(true);
        await _insertStock(
          db,
          stableId: 'stock-missing-catalog-display',
          quantity: 1,
        );

        await tester.pumpWidget(
          wrapForTest(
            PodesavanjaScreen(
              repo: podesavanjaRepo,
              authRepo: authRepo,
              session: session,
              initialSection: OpcSettingsSection.moduli,
              entitlementPolicy: _potpunPolicy(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Upravljaj stanjem robe'));
        await tester.pumpAndSettle();

        expect(find.text('stock-missing-catalog-display'), findsOneWidget);
        expect(
          find.text('Stable ID: stock-missing-catalog-display'),
          findsOneWidget,
        );
        expect(find.text('Trenutno: 1'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );

    test(
      'stock initialization is idempotent and preserves existing rows',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final repo = StanjeRobeRepository(db);
        await _insertStock(db, stableId: 'stock-existing', quantity: 4);
        await repo.sacuvajStanje(
          stableArticleId: 'stock-existing',
          trenutnaKolicina: 4,
          minimalnaKolicina: 2,
          aktivna: false,
        );

        final first = await repo.inicijalizujNedostajuceStavke([
          'stock-existing',
          'stock-new-a',
          'stock-new-b',
          'stock-new-a',
        ]);
        final second = await repo.inicijalizujNedostajuceStavke([
          'stock-existing',
          'stock-new-a',
          'stock-new-b',
        ]);

        final rows = await db.select(db.stanjeRobeStavke).get();
        final byStableId = {for (final row in rows) row.stableArticleId: row};
        expect(first, 2);
        expect(second, 0);
        expect(rows, hasLength(3));
        expect(byStableId['stock-existing']!.trenutnaKolicina, 4);
        expect(byStableId['stock-existing']!.minimalnaKolicina, 2);
        expect(byStableId['stock-existing']!.aktivna, isFalse);
        expect(byStableId['stock-new-a']!.trenutnaKolicina, 0);
        expect(byStableId['stock-new-a']!.minimalnaKolicina, 0);
        expect(byStableId['stock-new-a']!.aktivna, isTrue);
      },
    );

    test('stock initialization does not enable operational toggle', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final podesavanjaRepo = PodesavanjaRepository(db);
      final stanjeRobeRepo = StanjeRobeRepository(db);

      await stanjeRobeRepo.inicijalizujNedostajuceStavke([
        'stock-init-default-off',
      ]);

      expect(await db.select(db.stanjeRobeStavke).get(), hasLength(1));
      expect(
        await podesavanjaRepo.isStanjeRobeOperativnoOmoguceno(),
        isFalse,
      );
      expect(
        await StanjeRobeOperationalAvailability(
          podesavanjaRepository: podesavanjaRepo,
          entitlementPolicy: _potpunPolicy(),
        ).readStatus(),
        StanjeRobeOperationalStatus.disabled,
      );
    });

    test('dark warning card style uses restrained readable surface', () {
      final darkScheme = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );
      final style = resolvePredmetStockWarningCardStyle(
        darkScheme,
        Brightness.dark,
      );

      expect(style.backgroundColor, isNot(darkScheme.errorContainer));
      expect(style.primaryTextColor, darkScheme.onSurface);
      expect(style.secondaryTextColor, darkScheme.onSurfaceVariant);
      expect(style.borderColor, isNot(darkScheme.error));
    });

    test(
      'SANDUK V-0 selection follows normal stock consequence rules',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        await StanjeRobeRepository(db).sacuvajStanje(
          stableArticleId: StockCatalogIdentity.sandukV0StableId,
          trenutnaKolicina: 0,
          minimalnaKolicina: 0,
        );

        final result = await StanjeRobeLifecycleService(db: db)
            .applySelectionEffectForCoveredCategory(
              predmetId: 1,
              iriuId: 1,
              kategorija: 'SANDUK',
              stableArticleId: StockCatalogIdentity.sandukV0StableId,
              selectedNazivSnapshot: 'SANDUK V-0',
              selectedIznosSnapshot: 49960,
            );

        final effects = await db.select(db.stanjeRobeAppliedEffects).get();
        final consequences = await db.select(db.stanjeRobePosledice).get();
        expect(result.outcome, StanjeRobeLifecycleOutcome.unresolvedRecorded);
        expect(effects, hasLength(1));
        expect(effects.single.stableArticleId, StockCatalogIdentity.sandukV0StableId);
        expect(effects.single.effectStatus, stanjeRobeEffectStatusUnresolved);
        expect(consequences, hasLength(1));
        expect(
          consequences.single.katalogStableArticleId,
          StockCatalogIdentity.sandukV0StableId,
        );
        expect(consequences.single.status, stanjeRobePosledicaStatusUnresolved);
      },
    );

    test(
      'replacing tracked SANDUK V-17 with SANDUK V-0 restores old effect and tracks V0',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(
          db,
          predmetId: predmet.id,
          stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
          nazivPrikaz: 'SANDUK V-17 POLUKOVČEG',
        );
        await _insertStock(
          db,
          stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
          quantity: 1,
        );

        final service = StanjeRobeLifecycleService(db: db);
        final applied = await service.applySelectionEffectForCoveredCategory(
          predmetId: predmet.id,
          iriuId: iriuId,
          kategorija: 'SANDUK',
          stableArticleId: StockCatalogIdentity.sandukV17PolukovcegStableId,
          selectedNazivSnapshot: 'SANDUK V-17 POLUKOVČEG',
          selectedIznosSnapshot: 75790,
        );
        final replaced = await service.replaceSelectionEffectForCoveredCategory(
          predmetId: predmet.id,
          iriuId: iriuId,
          kategorija: 'SANDUK',
          stableArticleId: StockCatalogIdentity.sandukV0StableId,
          selectedNazivSnapshot: 'SANDUK V-0',
          selectedIznosSnapshot: 49960,
        );

        final stock = await (db.select(db.stanjeRobeStavke)
              ..where(
                (s) => s.stableArticleId.equals(
                  StockCatalogIdentity.sandukV17PolukovcegStableId,
                ),
              ))
            .getSingle();
        final effects = await db.select(db.stanjeRobeAppliedEffects).get();
        final current = await StanjeRobeEffectsRepository(db)
            .getCurrentEffectForSelection(
              predmetId: predmet.id,
              iriuId: iriuId,
              kategorija: 'SANDUK',
            );
        final unresolved = await StanjeRobePoslediceRepository(
          db,
        ).listActiveUnresolvedForPredmet(predmet.id);

        expect(applied.outcome, StanjeRobeLifecycleOutcome.applied);
        expect(replaced.outcome, StanjeRobeLifecycleOutcome.replacedWithUnresolved);
        expect(stock.trenutnaKolicina, 1);
        expect(effects, hasLength(2));
        expect(
          effects.where(
            (effect) =>
                effect.stableArticleId ==
                    StockCatalogIdentity.sandukV17PolukovcegStableId &&
                effect.effectStatus == stanjeRobeEffectStatusRestored,
          ),
          hasLength(1),
        );
        expect(current?.stableArticleId, StockCatalogIdentity.sandukV0StableId);
        expect(current?.effectStatus, stanjeRobeEffectStatusUnresolved);
        expect(unresolved, hasLength(1));
        expect(
          unresolved.single.katalogStableArticleId,
          StockCatalogIdentity.sandukV0StableId,
        );
      },
    );

    test(
      'replacing unresolved tracked SANDUK V-17 with SANDUK V-0 moves blocker to V0',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(db);
        final iriuId = await _insertIriu(
          db,
          predmetId: predmet.id,
          stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
          nazivPrikaz: 'SANDUK V-17 POLUKOVČEG',
        );
        await _insertUnresolvedEffect(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
        );
        await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: StockCatalogIdentity.sandukV17PolukovcegStableId,
        );

        final result = await StanjeRobeLifecycleService(
          db: db,
        ).replaceSelectionEffectForCoveredCategory(
          predmetId: predmet.id,
          iriuId: iriuId,
          kategorija: 'SANDUK',
          stableArticleId: StockCatalogIdentity.sandukV0StableId,
          selectedNazivSnapshot: 'SANDUK V-0',
          selectedIznosSnapshot: 49960,
        );

        final effects = await db.select(db.stanjeRobeAppliedEffects).get();
        final current = await StanjeRobeEffectsRepository(db)
            .getCurrentEffectForSelection(
              predmetId: predmet.id,
              iriuId: iriuId,
              kategorija: 'SANDUK',
            );
        final unresolved = await StanjeRobePoslediceRepository(
          db,
        ).listActiveUnresolvedForPredmet(predmet.id);
        final consequences = await db.select(db.stanjeRobePosledice).get();

        expect(result.outcome, StanjeRobeLifecycleOutcome.replacedWithUnresolved);
        expect(effects, hasLength(2));
        expect(
          effects.where(
            (effect) =>
                effect.stableArticleId ==
                    StockCatalogIdentity.sandukV17PolukovcegStableId &&
                effect.effectStatus == stanjeRobeEffectStatusCleared,
          ),
          hasLength(1),
        );
        expect(current?.stableArticleId, StockCatalogIdentity.sandukV0StableId);
        expect(current?.effectStatus, stanjeRobeEffectStatusUnresolved);
        expect(unresolved, hasLength(1));
        expect(
          unresolved.single.katalogStableArticleId,
          StockCatalogIdentity.sandukV0StableId,
        );
        expect(consequences, hasLength(2));
        expect(
          consequences.where(
            (consequence) =>
                consequence.katalogStableArticleId ==
                    StockCatalogIdentity.sandukV17PolukovcegStableId &&
                consequence.status == stanjeRobePosledicaStatusSuperseded,
          ),
          hasLength(1),
        );
      },
    );

    test(
      'seed compatibility preserves company-specific SANDUK V-17 stable identity',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        const legacyStableId = 'legacy-random-v17';
        final catalogId = await _insertCatalogArticle(
          db,
          stableId: legacyStableId,
          category: 'SANDUK',
          name: 'SANDUK V-17 POLUKOVČEG',
        );
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: 1,
                interniNaziv: 'SANDUK',
                nazivPrikaz: const Value('SANDUK V-17 POLUKOVČEG'),
                katalogStableArticleId: const Value(legacyStableId),
              ),
            );
        await StanjeRobeRepository(db).sacuvajStanje(
          stableArticleId: legacyStableId,
          trenutnaKolicina: 3,
          minimalnaKolicina: 0,
        );

        await db.canonicalizeSeedCatalogStableArticleIds();

        final article = await (db.select(
          db.katalogArtikli,
        )..where((a) => a.id.equals(catalogId))).getSingle();
        final iriu = await db.select(db.iriu).getSingle();
        final stock = await db.select(db.stanjeRobeStavke).getSingle();
        expect(article.stableArticleId, legacyStableId);
        expect(iriu.katalogStableArticleId, legacyStableId);
        expect(stock.stableArticleId, legacyStableId);
        expect(stock.trenutnaKolicina, 3);
      },
    );

    test(
      'known legacy SANDUK V-0 placeholder id canonicalizes without treating V0 as fake',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final catalogId = await _insertCatalogArticle(
          db,
          stableId: StockCatalogIdentity.legacySandukV0StableId,
          category: 'SANDUK',
          name: 'SANDUK V-0',
        );
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: 1,
                interniNaziv: 'SANDUK',
                nazivPrikaz: const Value('SANDUK V-0'),
                katalogStableArticleId:
                    const Value(StockCatalogIdentity.legacySandukV0StableId),
              ),
            );
        await StanjeRobeRepository(db).sacuvajStanje(
          stableArticleId: StockCatalogIdentity.legacySandukV0StableId,
          trenutnaKolicina: 3,
          minimalnaKolicina: 0,
        );

        await db.canonicalizeSeedCatalogStableArticleIds();

        final article = await (db.select(
          db.katalogArtikli,
        )..where((a) => a.id.equals(catalogId))).getSingle();
        final iriu = await db.select(db.iriu).getSingle();
        final stock = await db.select(db.stanjeRobeStavke).getSingle();
        expect(article.stableArticleId, StockCatalogIdentity.sandukV0StableId);
        expect(
          iriu.katalogStableArticleId,
          StockCatalogIdentity.sandukV0StableId,
        );
        expect(stock.stableArticleId, StockCatalogIdentity.sandukV0StableId);
        expect(stock.trenutnaKolicina, 3);
      },
    );

    testWidgets('ADMIN sees disabled operational status', (tester) async {
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
      await podesavanjaRepo.setStanjeRobeOperativnoOmoguceno(false);

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Status: licencirano, ali operativno isključeno u podešavanjima.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('SAVETNIK cannot control the operational toggle', (
      tester,
    ) async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final authRepo = AuthRepository(db);
      final session = SessionService();
      final podesavanjaRepo = PodesavanjaRepository(db);
      await authRepo.kreirajPrvogAdmina(
        imePrezime: 'Test Administrator',
        pin: '1234',
      );
      final savetnik = await authRepo.kreirajKorisnika(
        imePrezime: 'Test Savetnik',
        uloga: 'SAVETNIK',
        pin: '5678',
      );
      session.prijavi(savetnik);

      await tester.pumpWidget(
        wrapForTest(
          PodesavanjaScreen(
            repo: podesavanjaRepo,
            authRepo: authRepo,
            session: session,
            initialSection: OpcSettingsSection.moduli,
            entitlementPolicy: _potpunPolicy(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STANJE ROBE'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.text('Upravljaj stanjem robe'), findsNothing);
      expect(find.text('Inicijalizuj stanje robe iz kataloga'), findsNothing);
      expect(
        find.text(
          'Samo ADMINISTRATOR može da uključi ili isključi ovaj modul.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
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

OpcEntitlementPolicy _osnovniPolicy() {
  return OpcEntitlementPolicy.fromPayload(
    const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: OpcEntitlementEnvironment.test,
      packageLevel: OpcPackageLevel.osnovni,
    ),
  );
}

Future<PredmetiData> _insertPredmet(AppDatabase db) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('TOGGLE-001/2026'),
          datumKreiranja: const Value('2026-05-20T10:00:00.000'),
          ime: const Value('Test'),
          prezime: const Value('Predmet'),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}

Future<int> _insertIriu(
  AppDatabase db, {
  required int predmetId,
  String stableId = 'stock-stable-toggle',
  String nazivPrikaz = 'Test sanduk',
}) {
  return db
      .into(db.iriu)
      .insert(
        IriuCompanion.insert(
          predmetId: predmetId,
          katalogStableArticleId: Value(stableId),
          interniNaziv: 'SANDUK',
          nazivPrikaz: Value(nazivPrikaz),
          kom: const Value('1'),
          iznos: const Value(100),
          redosled: const Value(0),
        ),
      );
}

Future<void> _insertStock(
  AppDatabase db, {
  required String stableId,
  required double quantity,
}) {
  return db
      .into(db.stanjeRobeStavke)
      .insert(
        StanjeRobeStavkeCompanion.insert(
          stableArticleId: stableId,
          trenutnaKolicina: Value(quantity),
          minimalnaKolicina: const Value(0),
          aktivna: const Value(true),
          datumKreiranja: const Value('2026-05-20T10:00:00.000'),
          datumAzuriranja: const Value('2026-05-20T10:00:00.000'),
        ),
      );
}

Future<int> _insertCatalogArticle(
  AppDatabase db, {
  required String stableId,
  required String category,
  required String name,
}) {
  return db
      .into(db.katalogArtikli)
      .insert(
        KatalogArtikliCompanion.insert(
          stableArticleId: Value(stableId),
          interniNazivKategorije: category,
          naziv: name,
          cena: const Value(100),
        ),
      );
}

Future<void> _insertAppliedEffect(
  AppDatabase db, {
  required int predmetId,
  required int iriuId,
  required String stableId,
}) {
  return db
      .into(db.stanjeRobeAppliedEffects)
      .insert(
        StanjeRobeAppliedEffectsCompanion.insert(
          predmetId: predmetId,
          iriuId: Value(iriuId),
          kategorija: 'SANDUK',
          stableArticleId: stableId,
          effectQuantity: const Value(1),
          effectStatus: stanjeRobeEffectStatusApplied,
          effectReason: 'TEST',
          datumKreiranja: const Value('2026-05-20T10:00:00.000'),
          datumAzuriranja: const Value('2026-05-20T10:00:00.000'),
        ),
      );
}

Future<void> _insertUnresolvedEffect(
  AppDatabase db, {
  required int predmetId,
  required int iriuId,
  required String stableId,
}) {
  return db
      .into(db.stanjeRobeAppliedEffects)
      .insert(
        StanjeRobeAppliedEffectsCompanion.insert(
          predmetId: predmetId,
          iriuId: Value(iriuId),
          kategorija: 'SANDUK',
          stableArticleId: stableId,
          effectQuantity: const Value(1),
          effectStatus: stanjeRobeEffectStatusUnresolved,
          effectReason: 'TEST_UNRESOLVED',
          datumKreiranja: const Value('2026-05-20T10:00:00.000'),
          datumAzuriranja: const Value('2026-05-20T10:00:00.000'),
        ),
      );
}

Future<StanjeRobePoslediceData> _insertUnresolvedConsequence(
  AppDatabase db, {
  required int predmetId,
  required int iriuId,
  required String stableId,
}) {
  return StanjeRobePoslediceRepository(db).createOrUpdateUnresolved(
    predmetId: predmetId,
    iriuId: iriuId,
    kategorija: 'SANDUK',
    katalogStableArticleId: stableId,
    selectedNazivSnapshot: 'Test sanduk',
    selectedIznosSnapshot: 100,
    sourceLifecycleEvent: stanjeRobePosledicaEventFirstSelection,
    effectQuantity: 1,
    availableQuantityAtCreation: 0,
    shortageQuantityAtCreation: 1,
  );
}
