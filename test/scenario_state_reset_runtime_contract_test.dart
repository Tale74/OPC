import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'fresh PREDMET applies BOLNICA scenario after base materialization',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final scenarioRepository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final definitions = await scenarioRepository.getActiveDefinitions();
      final predmetRepository = PredmetiRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await predmetRepository.inicijalizujIriu(predmetId);
      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(mestoSmrti: Value('BOLNICA')),
      );

      final result = await IriuRepository(db).syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: definitions,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );

      expect(result.matchedScenarioIds, contains('BOLNICA'));
      expect(result.addedCategories, contains(IriuK.prevozDoGroblja));
      final rows = await IriuRepository(db).getIriu(predmetId);
      final scenarioRows = rows.where((row) => row.scenarioUpravlja).toList();
      expect(
        scenarioRows.map((row) => row.interniNaziv),
        contains(IriuK.prevozDoGroblja),
      );
      expect(
        scenarioRows.map((row) => row.interniNaziv),
        isNot(contains(IriuK.iznosenje)),
      );
      expect(
        scenarioRows.map((row) => row.interniNaziv),
        isNot(contains(IriuK.transportnaVreca)),
      );
      final provenance = await (db.select(db.iriuProvenance).get());
      final prevoz = rows.firstWhere(
        (row) => row.interniNaziv == IriuK.prevozDoGroblja,
      );
      final prevozProvenance = provenance.firstWhere(
        (item) => item.iriuId == prevoz.id,
      );
      expect(prevozProvenance.origin, 'SCENARIO_PAKET');
      expect(prevozProvenance.scenarioId, 'BOLNICA');
    },
  );

  test(
    'DOM aliases, STAN and ULICA use independent scenario identities',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final scenarioRepository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final definitions = await scenarioRepository.getActiveDefinitions();
      final expectedHandling = <String>{
        IriuK.iznosenje,
        IriuK.transportnaVreca,
        IriuK.prevozDoHladnjace,
        IriuK.hladnjaca,
        IriuK.spremaanjePokojnika,
        IriuK.prevozDoGroblja,
      };

      for (final entry in <String, String>{
        'DOM ZA STARE': 'DOM_ZA_STARE',
        'PRIVATNA BOLNICA': 'DOM_ZA_STARE',
        'DRUGO': 'DOM_ZA_STARE',
        'STAN': 'STAN',
        'ULICA / JAVNO MESTO': 'ULICA_JAVNO_MESTO',
      }.entries) {
        final predmetRepository = PredmetiRepository(db);
        final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
        await predmetRepository.inicijalizujIriu(predmetId);
        await predmetRepository.azurirajPredmet(
          predmetId,
          PredmetiCompanion(mestoSmrti: Value(entry.key)),
        );
        final result = await IriuRepository(db).syncScenarioRows(
          predmetId: predmetId,
          predmet: await predmetRepository.getPredmet(predmetId),
          scenarios: definitions,
          osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        );
        expect(result.matchedScenarioIds, contains(entry.value));
        final rows = await IriuRepository(db).getIriu(predmetId);
        final added = rows
            .where((row) => row.scenarioUpravlja)
            .map((row) => row.interniNaziv)
            .toSet();
        expect(added, containsAll(expectedHandling));
        if (entry.key != 'DOM ZA STARE' &&
            entry.key != 'PRIVATNA BOLNICA' &&
            entry.key != 'DRUGO') {
          expect(result.matchedScenarioIds, isNot(contains('DOM_ZA_STARE')));
        }
      }
    },
  );
}
