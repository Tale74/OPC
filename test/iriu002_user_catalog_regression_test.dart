import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/models/iriu_truth_models.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/financial_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/domain/iriu_catalog_selection.dart';

import 'test_bootstrap.dart';

Future<int> _actor(AppDatabase db) async {
  await prepareSameFirmaJsonTransferForTest(db);
  return db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'Synthetic IRiU actor',
          uloga: 'ADMINISTRATOR',
          pinHash: 'synthetic-only',
          datumKreiranja: '2026-11-02T00:00:00.000',
        ),
      );
}

Future<({int predmetId, int userRowId, int ordinaryRowId, int manualRowId})>
_createCase(AppDatabase db, {required bool withSnapshot}) async {
  final actorId = await _actor(db);
  final predmeti = PredmetiRepository(db);
  final predmetId = await predmeti.kreirajPredmet(savetnikId: actorId);
  if (withSnapshot) {
    final scenarios = ScenarioModuleRepository(db);
    await scenarios.ensureModuleAndDefaults();
    await predmeti.azurirajPredmet(
      predmetId,
      const PredmetiCompanion(
        uzrokSmrti: Value('PRIRODNA'),
        mestoSmrti: Value('BOLNICA'),
        vrstaCeremonije: Value('SAHRANA'),
        tipGroblja: Value('GRADSKO'),
        tipGrobnogMesta: Value('GROB'),
        opelo: Value('NE'),
      ),
    );
    await predmeti.inicijalizujIriu(predmetId);
    final module = await scenarios.ensureModule();
    await IriuRepository(db).syncScenarioRows(
      predmetId: predmetId,
      predmet: await predmeti.getPredmet(predmetId),
      scenarios: await scenarios.getActiveDefinitions(),
      osnovniPaket: scenarios.readOsnovniPaket(module),
    );
  }
  final repository = IriuRepository(db);
  await db
      .into(db.katalogArtikli)
      .insert(
        KatalogArtikliCompanion.insert(
          stableArticleId: const Value('SYNTHETIC-CONDITIONAL-700'),
          interniNazivKategorije: IriuK.spremaanjePokojnika,
          naziv: 'Synthetic conditional catalog article',
          cena: const Value(700),
        ),
      );
  final userRowId = await repository.dodajKatalogSelection(
    predmetId: predmetId,
    selection: const IriuCatalogSelection(
      interniNaziv: IriuK.spremaanjePokojnika,
      nazivPrikaz: 'Synthetic conditional catalog article',
      katalogStableArticleId: 'SYNTHETIC-CONDITIONAL-700',
      cena: 700,
      iznos: 700,
    ),
  );
  final ordinaryRowId = await repository.dodajKatalogSelection(
    predmetId: predmetId,
    selection: const IriuCatalogSelection(
      interniNaziv: 'SYNTHETIC_ORDINARY',
      nazivPrikaz: 'Synthetic ordinary catalog article',
      katalogStableArticleId: 'SYNTHETIC-ORDINARY-500',
      cena: 500,
      iznos: 500,
    ),
  );
  final manualRowId = await repository.dodajStavku(
    predmetId: predmetId,
    interniNaziv: 'RUCNO_SYNTHETIC',
    nazivPrikaz: 'Synthetic manual article',
    iznos: 300,
  );
  return (
    predmetId: predmetId,
    userRowId: userRowId,
    ordinaryRowId: ordinaryRowId,
    manualRowId: manualRowId,
  );
}

Future<void> _expectTruth(
  AppDatabase db,
  int predmetId, {
  required String userArticleId,
  required double userAmount,
}) async {
  final repository = IriuRepository(db);
  final rows = await repository.getIriu(predmetId);
  final origins = await repository.getProvenanceOrigins(
    rows.map((row) => row.id),
  );
  final user = rows.singleWhere(
    (row) => row.katalogStableArticleId == userArticleId,
  );
  final ordinary = rows.singleWhere(
    (row) => row.katalogStableArticleId == 'SYNTHETIC-ORDINARY-500',
  );
  final manual = rows.singleWhere(
    (row) => row.interniNaziv == 'RUCNO_SYNTHETIC',
  );
  expect(origins[user.id], 'RUCNA_STAVKA');
  expect(origins[ordinary.id], 'RUCNA_STAVKA');
  expect(user.iznos, userAmount);
  expect(user.katalogStableArticleId, userArticleId);
  final truth = const PredmetIriuTruthService().evaluate(
    predmet: await PredmetiRepository(db).getPredmet(predmetId),
    storedRows: rows,
    provenanceOrigins: origins,
  );
  final truthById = {for (final row in truth.rows) row.storedRow.id: row};
  expect(truthById[user.id]!.active, isTrue);
  expect(truthById[user.id]!.countsForFinancialTruth, isTrue);
  expect(truthById[ordinary.id]!.active, isTrue);
  expect(truthById[ordinary.id]!.countsForFinancialTruth, isTrue);
  expect(truthById[manual.id]!.active, isTrue);
  expect(truthById[manual.id]!.countsForFinancialTruth, isTrue);
  expect(
    const FinancialTruthService().buildRobaIUsluge(truth).robaIUsluge,
    userAmount + 800,
  );
}

void main() {
  test(
    'explicit catalog occurrence is active and counted; reselection keeps authority',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final ids = await _createCase(db, withSnapshot: true);
      await _expectTruth(
        db,
        ids.predmetId,
        userArticleId: 'SYNTHETIC-CONDITIONAL-700',
        userAmount: 700,
      );
      final repository = IriuRepository(db);
      final before = (await repository.getIriu(
        ids.predmetId,
      )).singleWhere((row) => row.id == ids.userRowId);
      await repository.azurirajKatalogSelection(
        row: before,
        selection: const IriuCatalogSelection(
          interniNaziv: IriuK.spremaanjePokojnika,
          nazivPrikaz: 'Reselected synthetic article',
          katalogStableArticleId: 'SYNTHETIC-CONDITIONAL-710',
          cena: 710,
          iznos: 710,
        ),
      );
      final after = (await repository.getIriu(
        ids.predmetId,
      )).singleWhere((row) => row.id == ids.userRowId);
      expect(after.portableOccurrenceId, before.portableOccurrenceId);
      expect(
        (await (db.select(db.katalogArtikli)..where(
                  (row) =>
                      row.stableArticleId.equals('SYNTHETIC-CONDITIONAL-700'),
                ))
                .getSingle())
            .cena,
        700,
      );
      await _expectTruth(
        db,
        ids.predmetId,
        userArticleId: 'SYNTHETIC-CONDITIONAL-710',
        userAmount: 710,
      );
    },
  );

  test('conditional automatic and unknown rows remain suppressed', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final ids = await _createCase(db, withSnapshot: true);
    final automaticId = await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: ids.predmetId,
            interniNaziv: IriuK.spremaanjePokojnika,
            nazivPrikaz: const Value('Synthetic automatic suppressed row'),
            iznos: const Value(900),
            poslovniStatus: const Value('NE PRIKAZUJE SE'),
            scenarioUpravlja: const Value(true),
          ),
        );
    final unknownId = await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: ids.predmetId,
            interniNaziv: IriuK.spremaanjePokojnika,
            nazivPrikaz: const Value('Synthetic unknown origin row'),
            iznos: const Value(600),
          ),
        );
    final repository = IriuRepository(db);
    final rows = await repository.getIriu(ids.predmetId);
    final truth = const PredmetIriuTruthService().evaluate(
      predmet: await PredmetiRepository(db).getPredmet(ids.predmetId),
      storedRows: rows,
      provenanceOrigins: await repository.getProvenanceOrigins(
        rows.map((row) => row.id),
      ),
    );
    final byId = {for (final row in truth.rows) row.storedRow.id: row};
    expect(byId[ids.userRowId]!.active, isTrue);
    for (final id in [automaticId, unknownId]) {
      expect(byId[id]!.active, isFalse);
      expect(byId[id]!.countsForFinancialTruth, isFalse);
    }
    expect(
      const FinancialTruthService().buildRobaIUsluge(truth).robaIUsluge,
      1500,
    );
  });

  test(
    'saved suppression excludes a user row from finance and documents',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final ids = await _createCase(db, withSnapshot: false);
      final repository = IriuRepository(db);
      await repository.azurirajStavku(
        ids.ordinaryRowId,
        const IriuCompanion(poslovniStatus: Value('NE PRIKAZUJE SE')),
      );
      final rows = await repository.getIriu(ids.predmetId);
      final truth = const PredmetIriuTruthService().evaluate(
        predmet: await PredmetiRepository(db).getPredmet(ids.predmetId),
        storedRows: rows,
        provenanceOrigins: await repository.getProvenanceOrigins(
          rows.map((row) => row.id),
        ),
      );
      final ordinary = truth.rows.singleWhere(
        (row) => row.storedRow.id == ids.ordinaryRowId,
      );
      expect(ordinary.active, isFalse);
      expect(ordinary.countsForFinancialTruth, isFalse);
      expect(
        ordinary.derivativeExclusions,
        contains(IriuDerivativeExclusion.notOperationallyActive),
      );
      expect(
        const FinancialTruthService().buildRobaIUsluge(truth).robaIUsluge,
        1000,
      );
    },
  );

  test('SCENARIO refresh preserves user row and package-first order', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final ids = await _createCase(db, withSnapshot: true);
    final repository = IriuRepository(db);
    final before = await repository.getIriu(ids.predmetId);
    final scenarios = ScenarioModuleRepository(db);
    final module = await scenarios.ensureModule();
    await repository.syncScenarioRows(
      predmetId: ids.predmetId,
      predmet: await PredmetiRepository(db).getPredmet(ids.predmetId),
      scenarios: await scenarios.getActiveDefinitions(),
      osnovniPaket: scenarios.readOsnovniPaket(module),
    );
    final after = await repository.getIriu(ids.predmetId);
    expect(after.length, before.length);
    expect(after.where((row) => row.id == ids.userRowId).length, 1);
    expect(after.where((row) => row.id == ids.ordinaryRowId).length, 1);
    expect(after.where((row) => row.id == ids.manualRowId).length, 1);
    final userIndex = after.indexWhere((row) => row.id == ids.userRowId);
    final origins = await repository.getProvenanceOrigins(
      after.map((row) => row.id),
    );
    for (final row in after) {
      if (origins[row.id] == 'OSNOVNI_PAKET' ||
          origins[row.id] == 'SCENARIO_PAKET') {
        expect(after.indexOf(row), lessThan(userIndex));
      }
    }
    await _expectTruth(
      db,
      ids.predmetId,
      userArticleId: 'SYNTHETIC-CONDITIONAL-700',
      userAmount: 700,
    );
  });

  for (final withSnapshot in [false, true]) {
    test(
      'PREDMET JSON preserves user authority, snapshot=$withSnapshot',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        final ids = await _createCase(source, withSnapshot: withSnapshot);
        final json =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: source,
                    predmetId: ids.predmetId,
                  ),
                )
                as Map<String, dynamic>;
        final carrier = (json['singlePredmetScenario'] as Map)
            .cast<String, dynamic>();
        expect(
          carrier['kind'],
          withSnapshot
              ? singlePredmetScenarioCarrierKind
              : singlePredmetIriuProvenanceCarrierKind,
        );
        if (!withSnapshot) {
          expect(
            (carrier['payload'] as Map).containsKey('assignment'),
            isFalse,
          );
        }
        final actorId = await _actor(target);
        await importPredmetJsonMapForTest(
          db: target,
          json: json,
          localActorKorisnikId: actorId,
        );
        final imported = (await target.select(target.predmeti).get()).single;
        await _expectTruth(
          target,
          imported.id,
          userArticleId: 'SYNTHETIC-CONDITIONAL-700',
          userAmount: 700,
        );
        if (!withSnapshot) {
          expect(
            await target.select(target.predmetScenarioSnapshots).get(),
            isEmpty,
          );
        }
        final damaged = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
        (damaged['singlePredmetScenario'] as Map)['contentHash'] = 'damaged';
        final beforeCount = (await target.select(target.predmeti).get()).length;
        await expectLater(
          importPredmetJsonMapForTest(
            db: target,
            json: damaged,
            localActorKorisnikId: actorId,
          ),
          throwsA(anything),
        );
        expect(
          (await target.select(target.predmeti).get()).length,
          beforeCount,
        );
        if (!withSnapshot) {
          final invalidReference =
              jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
          final payload =
              (invalidReference['singlePredmetScenario'] as Map)['payload']
                  as Map;
          final references = payload['provenance'] as List;
          (references.first as Map)['iriuTransferIndex'] =
              (json['iriu'] as List).length + 1;
          await expectLater(
            importPredmetJsonMapForTest(
              db: target,
              json: invalidReference,
              localActorKorisnikId: actorId,
            ),
            throwsA(anything),
          );
          expect(
            (await target.select(target.predmeti).get()).length,
            beforeCount,
          );
        }
      },
    );
  }

  test('reopen SQLite retains user origin and financial amount', () async {
    final directory = await Directory.systemTemp.createTemp('opc-iriu002-');
    final file = File('${directory.path}/synthetic.sqlite');
    var db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    final ids = await _createCase(db, withSnapshot: true);
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase(file));
    await _expectTruth(
      db,
      ids.predmetId,
      userArticleId: 'SYNTHETIC-CONDITIONAL-700',
      userAmount: 700,
    );
  });

  for (final withSnapshot in [false, true]) {
    test(
      'OPC Backup JSON preserves user authority, snapshot=$withSnapshot',
      () async {
        final source = createTestDatabase();
        final directory = await Directory.systemTemp.createTemp(
          'opc-iriu002-backup-',
        );
        final file = File('${directory.path}/synthetic.sqlite');
        var target = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(source.close);
        addTearDown(() async {
          await target.close();
          if (await directory.exists()) await directory.delete(recursive: true);
        });
        await _createCase(source, withSnapshot: withSnapshot);
        if (!withSnapshot) {
          expect(
            await source.select(source.predmetScenarioSnapshots).get(),
            isEmpty,
          );
        }
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;
        await importBackupJsonMapForTest(db: target, json: backup);
        final imported = (await target.select(target.predmeti).get()).single;
        await target.close();
        target = AppDatabase.forTesting(NativeDatabase(file));
        expect(
          (await PredmetiRepository(target).getPredmet(imported.id)).id,
          imported.id,
        );
        await _expectTruth(
          target,
          imported.id,
          userArticleId: 'SYNTHETIC-CONDITIONAL-700',
          userAmount: 700,
        );
        if (!withSnapshot) {
          expect(
            await target.select(target.predmetScenarioSnapshots).get(),
            isEmpty,
          );
        }
      },
    );
  }
}
