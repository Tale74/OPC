import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'new-PREDMET initialization records source-proven base provenance',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);

      await predmeti.inicijalizujIriu(predmetId);

      final rows = await IriuRepository(db).getIriu(predmetId);
      final provenance = await (db.select(db.iriuProvenance)
            ..where((item) => item.iriuId.isIn(rows.map((row) => row.id).toList())))
          .get();
      expect(rows, isNotEmpty);
      expect(provenance, hasLength(rows.length));
      expect(
        provenance.map((item) => item.iriuId).toSet(),
        rows.map((item) => item.id).toSet(),
      );
      expect(
        provenance.every(
          (item) =>
              item.moduleId == 'scenario' && item.origin == 'OSNOVNI_PAKET',
        ),
        isTrue,
      );
      expect(
        await (db.select(db.predmetScenarioSnapshots)
              ..where((item) => item.predmetId.equals(predmetId)))
            .getSingleOrNull(),
        isNull,
      );
    },
  );

  test(
    'carrierless category match is not provenance and incomplete evidence blocks open reconciliation',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final iriu = IriuRepository(db);
      final scenarios = ScenarioModuleRepository(db);
      await scenarios.ensureModule();
      const definition = ScenarioDefinition(
        id: 'CARRIERLESS_TEST',
        name: 'Carrierless test',
        condition: ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: ['STAN'],
          ),
        ),
        consequences: [
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.hladnjaca,
            action: ScenarioConsequenceAction.required,
          ),
        ],
      );

      final legacyId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        legacyId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final existingId = await iriu.dodajStavku(
        predmetId: legacyId,
        interniNaziv: IriuK.sanduk,
        nazivPrikaz: 'Postojeći red bez poznatog porekla',
      );
      final beforeRows = await iriu.getIriu(legacyId);
      final preview = await iriu.syncScenarioRows(
        predmetId: legacyId,
        predmet: await predmeti.getPredmet(legacyId),
        scenarios: const [definition],
        osnovniPaket: const {IriuK.sanduk},
        applyScenarioChange: false,
      );

      expect(preview.changed, isTrue);
      expect(await iriu.getIriu(legacyId), beforeRows);
      expect(await db.select(db.iriuProvenance).get(), isEmpty);
      expect(await db.select(db.predmetScenarioSnapshots).get(), isEmpty);
      expect(await iriu.hasCompleteAppliedScenarioEvidence(legacyId), isFalse);
      expect((await iriu.getIriu(legacyId)).single.id, existingId);

      // A transferred assignment snapshot with incomplete row provenance is
      // also insufficient for automatic open-time reconciliation.
      final partialId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        partialId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final partialRowA = await iriu.dodajStavku(
        predmetId: partialId,
        interniNaziv: IriuK.sanduk,
        nazivPrikaz: 'Poznati osnovni red',
      );
      final partialRowB = await iriu.dodajStavku(
        predmetId: partialId,
        interniNaziv: IriuK.hladnjaca,
        nazivPrikaz: 'Nepoznato poreklo',
      );
      final assignment = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: definition.id,
        scenarioVersion: 1,
        scenario: definition,
        osnovniPaket: const {IriuK.sanduk},
        assignedAt: '2026-09-30T00:00:00.000Z',
      );
      await db.into(db.predmetScenarioSnapshots).insert(
        PredmetScenarioSnapshotsCompanion.insert(
          predmetId: Value(partialId),
          moduleId: assignment.moduleId,
          scenarioId: assignment.scenarioId,
          scenarioVersion: assignment.scenarioVersion,
          snapshotJson: jsonEncode(assignment.toJsonMap()),
          snapshotHash: assignment.snapshotHash,
          assignedAt: assignment.assignedAt,
        ),
      );
      await db.into(db.iriuProvenance).insert(
        IriuProvenanceCompanion.insert(
          iriuId: Value(partialRowA),
          origin: 'OSNOVNI_PAKET',
          moduleId: const Value('scenario'),
          createdAt: '2026-09-30T00:00:00.000Z',
        ),
      );
      expect(await iriu.hasCompleteAppliedScenarioEvidence(partialId), isFalse);

      final unavailableId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        unavailableId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final unavailableRow = await iriu.dodajStavku(
        predmetId: unavailableId,
        interniNaziv: IriuK.sanduk,
        nazivPrikaz: 'Poreklo nedostupno',
      );
      await db.into(db.predmetScenarioSnapshots).insert(
        PredmetScenarioSnapshotsCompanion.insert(
          predmetId: Value(unavailableId),
          moduleId: assignment.moduleId,
          scenarioId: assignment.scenarioId,
          scenarioVersion: assignment.scenarioVersion,
          snapshotJson: jsonEncode(assignment.toJsonMap()),
          snapshotHash: assignment.snapshotHash,
          assignedAt: assignment.assignedAt,
        ),
      );
      expect(await iriu.hasCompleteAppliedScenarioEvidence(unavailableId), isFalse);
      expect(partialRowB, greaterThan(0));
      expect(unavailableRow, greaterThan(0));
    },
  );
}
