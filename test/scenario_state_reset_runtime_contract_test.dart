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
        const PredmetiCompanion(
          mestoSmrti: Value('BOLNICA'),
          uzrokSmrti: Value('PRIRODNA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );

      final result = await IriuRepository(db).syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: definitions,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );

      expect(result.matchedScenarioIds.single, startsWith('MAP_'));
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
      expect(prevozProvenance.scenarioId, result.matchedScenarioIds.single);
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
      final matchedIds = <String>{};

      for (final entry in <String, String>{
        'DOM ZA STARE': 'DOM_ZA_STARE',
        'PRIVATNA BOLNICA': 'PRIVATNA_BOLNICA',
        'DRUGO': 'DRUGO',
        'STAN': 'STAN',
        'ULICA / JAVNO MESTO': 'ULICA_JAVNO_MESTO',
      }.entries) {
        final predmetRepository = PredmetiRepository(db);
        final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
        await predmetRepository.inicijalizujIriu(predmetId);
        await predmetRepository.azurirajPredmet(
          predmetId,
          PredmetiCompanion(
            mestoSmrti: Value(entry.key),
            uzrokSmrti: const Value('PRIRODNA'),
            vrstaCeremonije: const Value('SAHRANA'),
            tipGroblja: const Value('GRADSKO'),
            tipGrobnogMesta: const Value('GROB'),
            opelo: const Value('NE'),
          ),
        );
        final result = await IriuRepository(db).syncScenarioRows(
          predmetId: predmetId,
          predmet: await predmetRepository.getPredmet(predmetId),
          scenarios: definitions,
          osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        );
        expect(result.matchedScenarioIds.single, startsWith('MAP_'));
        matchedIds.add(result.matchedScenarioIds.single);
        final rows = await IriuRepository(db).getIriu(predmetId);
        final added = rows
            .where((row) => row.scenarioUpravlja)
            .map((row) => row.interniNaziv)
            .toSet();
        expect(added, containsAll(expectedHandling));
      }
      expect(matchedIds, hasLength(5));
    },
  );

  test('BOLNICA with zarazna smrt follows the hospital exception', () async {
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
      const PredmetiCompanion(
        mestoSmrti: Value('BOLNICA'),
        uzrokSmrti: Value('ZARAZNA'),
        vrstaCeremonije: Value('SAHRANA'),
        tipGroblja: Value('GRADSKO'),
        tipGrobnogMesta: Value('GROB'),
        opelo: Value('NE'),
      ),
    );
    final result = await IriuRepository(db).syncScenarioRows(
      predmetId: predmetId,
      predmet: await predmetRepository.getPredmet(predmetId),
      scenarios: definitions,
      osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    );
    expect(result.matchedScenarioIds.single, startsWith('MAP_'));
    final rows = await IriuRepository(db).getIriu(predmetId);
    expect(
      rows.map((row) => row.interniNaziv),
      isNot(contains(IriuK.limeniUlozak)),
    );
    expect(
      rows.map((row) => row.interniNaziv),
      isNot(contains(IriuK.lemovanje)),
    );
  });
}
