import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'owner map definitions and base package are persisted independently',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final moduleRepository = ScenarioModuleRepository(db);

      final module = await moduleRepository.ensureModuleAndDefaults();
      final definitions = await moduleRepository.getDefinitions();

      expect(
        definitions.where((item) => item.id.startsWith('MAP_')),
        hasLength(1008),
      );
      expect(moduleRepository.readOsnovniPaket(module), hasLength(11));
    },
  );

  test(
    'PREDMET automatically materializes owner scenario and preserves snapshot on diff',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final first = await iriuRepository.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );

      expect(first.matchedScenarioIds.single, startsWith('MAP_'));
      expect((await iriuRepository.getIriu(predmetId)), hasLength(17));
      final firstSnapshot = await (db.select(
        db.predmetScenarioSnapshots,
      )..where((item) => item.predmetId.equals(predmetId))).getSingle();
      expect(firstSnapshot.scenarioId, first.matchedScenarioIds.single);

      final assignedDefinition = (await scenarioRepository.getDefinitions())
          .singleWhere((item) => item.id == first.matchedScenarioIds.single);
      final assigned = scenarioRepository.definitionFromRecord(
        assignedDefinition,
      );
      await scenarioRepository.saveDefinition(
        id: assignedDefinition.id,
        version: assignedDefinition.version,
        naziv: assignedDefinition.naziv,
        condition: assigned.condition,
        consequences: const <ScenarioConsequence>[],
        status: assignedDefinition.status,
        jePodrazumevani: assignedDefinition.jePodrazumevani,
      );
      final afterDefinitionEdit = await iriuRepository.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: await scenarioRepository.getActiveDefinitions(),
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      expect(afterDefinitionEdit.addedCategories, isEmpty);
      expect((await iriuRepository.getIriu(predmetId)), hasLength(17));
      final afterDefinitionSnapshot = await (db.select(
        db.predmetScenarioSnapshots,
      )..where((item) => item.predmetId.equals(predmetId))).getSingle();
      expect(afterDefinitionSnapshot.snapshotHash, firstSnapshot.snapshotHash);

      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(mestoSmrti: Value('BOLNICA')),
      );
      final second = await iriuRepository.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
      );

      expect(second.scenarioSnapshotChanged, isTrue);
      expect(second.pendingUserDecisionRows, isNotEmpty);
      expect((await iriuRepository.getIriu(predmetId)), hasLength(17));
      final unchangedSnapshot = await (db.select(
        db.predmetScenarioSnapshots,
      )..where((item) => item.predmetId.equals(predmetId))).getSingle();
      expect(unchangedSnapshot.scenarioId, firstSnapshot.scenarioId);

      final applied = await iriuRepository.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: await scenarioRepository.getActiveDefinitions(),
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: true,
      );
      expect(applied.scenarioSnapshotChanged, isTrue);
      expect(applied.pendingUserDecisionRows, isNotEmpty);
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).any((row) => row.interniNaziv == 'PREVOZ_DO_GROBLJA'),
        isTrue,
      );
    },
  );

  test(
    'NASILNA regression uses only the complete MAP definition and isolates PREDMET state',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmeti = PredmetiRepository(db);
      final scenarios = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetA = await predmeti.kreirajPredmet(savetnikId: 1);
      final predmetB = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetA,
        const PredmetiCompanion(
          uzrokSmrti: Value('NASILNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROBNICA'),
          opelo: Value('NE'),
        ),
      );
      await predmeti.azurirajPredmet(
        predmetB,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final module = await scenarios.ensureModuleAndDefaults();
      final active = await scenarios.getActiveDefinitions();
      expect(active, hasLength(1008));
      expect(active.every((item) => item.id.startsWith('MAP_')), isTrue);

      const legacy = ScenarioDefinition(
        id: 'STAN',
        name: 'STAN',
        condition: ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: ['STAN'],
          ),
        ),
        consequences: <ScenarioConsequence>[
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.kompletZaOpelo,
            action: ScenarioConsequenceAction.required,
          ),
        ],
      );
      final resultA = await iriu.syncScenarioRows(
        predmetId: predmetA,
        predmet: await predmeti.getPredmet(predmetA),
        scenarios: <ScenarioDefinition>[...active, legacy],
        osnovniPaket: scenarios.readOsnovniPaket(module),
      );
      final resultB = await iriu.syncScenarioRows(
        predmetId: predmetB,
        predmet: await predmeti.getPredmet(predmetB),
        scenarios: <ScenarioDefinition>[legacy, ...active],
        osnovniPaket: scenarios.readOsnovniPaket(module),
      );

      expect(resultA.matchedScenarioIds, <String>[
        'MAP_NASILNA_STAN_SAHRANA_GRADSKO_GROBNICA_NE_NE_NE',
      ]);
      final rowsA = await iriu.getIriu(predmetA);
      final additionsA = rowsA
          .where(
            (row) =>
                !scenarios.readOsnovniPaket(module).contains(row.interniNaziv),
          )
          .map((row) => row.interniNaziv)
          .toList(growable: false);
      expect(additionsA, <String>[
        IriuK.transportnaVreca,
        IriuK.iznosenje,
        IriuK.zastitnaIDodatnaOprema,
        IriuK.prevozDoHladnjace,
        IriuK.hladnjaca,
        IriuK.spremaanjePokojnika,
        IriuK.limeniUlozak,
        IriuK.lemovanje,
        IriuK.prevozDoGroblja,
      ]);
      expect(additionsA, isNot(contains(IriuK.kompletZaOpelo)));
      expect(resultB.matchedScenarioIds.single, contains('PRIRODNA_BOLNICA'));
      expect(
        (await iriu.getIriu(predmetB)).map((row) => row.interniNaziv),
        isNot(contains(IriuK.zastitnaIDodatnaOprema)),
      );

      final snapshots = await db.select(db.predmetScenarioSnapshots).get();
      expect(snapshots.map((item) => item.predmetId).toSet(), {
        predmetA,
        predmetB,
      });
      expect(snapshots.map((item) => item.scenarioId).toSet(), hasLength(2));
    },
  );
}
