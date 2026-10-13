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

Future<PredmetScenarioSnapshot?> _snapshotOrNull(
  AppDatabase db,
  int predmetId,
) => (db.select(
  db.predmetScenarioSnapshots,
)..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();

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
      final provenance =
          await (db.select(db.iriuProvenance)..where(
                (item) => item.iriuId.isIn(rows.map((row) => row.id).toList()),
              ))
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
        await (db.select(
          db.predmetScenarioSnapshots,
        )..where((item) => item.predmetId.equals(predmetId))).getSingleOrNull(),
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
      await iriu.azurirajStavku(
        partialRowB,
        const IriuCompanion(scenarioUpravlja: Value(true)),
      );
      final assignment = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: definition.id,
        scenarioVersion: 1,
        scenario: definition,
        osnovniPaket: const {IriuK.sanduk},
        assignedAt: '2026-09-30T00:00:00.000Z',
      );
      await db
          .into(db.predmetScenarioSnapshots)
          .insert(
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
      await db
          .into(db.iriuProvenance)
          .insert(
            IriuProvenanceCompanion.insert(
              iriuId: Value(partialRowA),
              origin: 'OSNOVNI_PAKET',
              moduleId: const Value('scenario'),
              createdAt: '2026-09-30T00:00:00.000Z',
            ),
          );
      expect(await iriu.hasCompleteAppliedScenarioEvidence(partialId), isFalse);

      // A valid SCENARIO assignment remains complete in the presence of
      // legitimate manual and unrelated-module rows.
      final mixedId = await predmeti.kreirajPredmet(savetnikId: 1);
      final scenarioRow = await iriu.dodajStavku(
        predmetId: mixedId,
        interniNaziv: IriuK.sanduk,
        nazivPrikaz: 'SCENARIO managed',
      );
      await iriu.azurirajStavku(
        scenarioRow,
        const IriuCompanion(scenarioUpravlja: Value(true)),
      );
      final manualRow = await iriu.dodajStavku(
        predmetId: mixedId,
        interniNaziv: 'RUCNI_NEZAVISNI_RED',
        nazivPrikaz: 'Ručni red',
      );
      final unrelatedRow = await iriu.dodajStavku(
        predmetId: mixedId,
        interniNaziv: 'PARTE_NEZAVISNI_RED',
        nazivPrikaz: 'Drugi modul',
      );
      await iriu.azurirajStavku(
        unrelatedRow,
        const IriuCompanion(scenarioUpravlja: Value(true)),
      );
      await db
          .into(db.predmetScenarioSnapshots)
          .insert(
            PredmetScenarioSnapshotsCompanion.insert(
              predmetId: Value(mixedId),
              moduleId: assignment.moduleId,
              scenarioId: assignment.scenarioId,
              scenarioVersion: assignment.scenarioVersion,
              snapshotJson: jsonEncode(assignment.toJsonMap()),
              snapshotHash: assignment.snapshotHash,
              assignedAt: assignment.assignedAt,
            ),
          );
      await db
          .into(db.iriuProvenance)
          .insert(
            IriuProvenanceCompanion.insert(
              iriuId: Value(scenarioRow),
              origin: 'OSNOVNI_PAKET',
              moduleId: const Value('scenario'),
              createdAt: '2026-09-30T00:00:00.000Z',
            ),
          );
      await db
          .into(db.iriuProvenance)
          .insert(
            IriuProvenanceCompanion.insert(
              iriuId: Value(unrelatedRow),
              origin: 'PARTE',
              moduleId: const Value('parte'),
              createdAt: '2026-09-30T00:00:00.000Z',
            ),
          );
      expect(await iriu.hasCompleteAppliedScenarioEvidence(mixedId), isTrue);
      expect(manualRow, greaterThan(0));

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
      await iriu.azurirajStavku(
        unavailableRow,
        const IriuCompanion(scenarioUpravlja: Value(true)),
      );
      await db
          .into(db.predmetScenarioSnapshots)
          .insert(
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
      expect(
        await iriu.hasCompleteAppliedScenarioEvidence(unavailableId),
        isFalse,
      );
      expect(partialRowB, greaterThan(0));
      expect(unavailableRow, greaterThan(0));
    },
  );

  test(
    'terminal and ambiguous no-snapshot states remain fail-closed',
    () async {
      for (final status in <String>['ZAVRŠEN', 'ANONIMIZOVAN']) {
        final db = createTestDatabase();
        addTearDown(db.close);
        await seedScenarioCatalogForTest(db);
        final predmeti = PredmetiRepository(db);
        final iriu = IriuRepository(db);
        final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
        await predmeti.inicijalizujIriu(predmetId);
        final initialRows = await iriu.getIriu(predmetId);
        for (final row in initialRows) {
          await iriu.azurirajStavku(
            row.id,
            const IriuCompanion(scenarioUpravlja: Value(true)),
          );
        }
        await predmeti.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(
            uzrokSmrti: Value('PRIRODNA'),
            mestoSmrti: Value('STAN'),
            vrstaCeremonije: Value('SAHRANA'),
            tipGroblja: Value('GRADSKO'),
            tipGrobnogMesta: Value('GROB'),
            opelo: Value('DA'),
          ),
        );
        await (db.update(db.predmeti)..where((row) => row.id.equals(predmetId)))
            .write(PredmetiCompanion(status: Value(status)));
        final rowsBeforeOpen = await iriu.getIriu(predmetId);
        final provenanceBeforeOpen =
            await (db.select(db.iriuProvenance)..where(
                  (row) => row.iriuId.isIn(
                    rowsBeforeOpen.map((row) => row.id).toList(),
                  ),
                ))
                .get();

        final intent = await iriu.scenarioOpenReconciliationIntent(
          predmetId: predmetId,
          currentPredmet: await predmeti.getPredmet(predmetId),
        );

        expect(intent.shouldReconcile, isFalse, reason: 'status=$status');
        expect(await iriu.getIriu(predmetId), rowsBeforeOpen);
        expect(
          await (db.select(db.iriuProvenance)..where(
                (row) => row.iriuId.isIn(
                  rowsBeforeOpen.map((row) => row.id).toList(),
                ),
              ))
              .get(),
          provenanceBeforeOpen,
        );
        expect(await _snapshotOrNull(db, predmetId), isNull);
      }

      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final iriu = IriuRepository(db);
      final ambiguousId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        ambiguousId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
        ),
      );
      final unknownRowId = await iriu.dodajStavku(
        predmetId: ambiguousId,
        interniNaziv: IriuK.sanduk,
        nazivPrikaz: 'Nepoznato poreklo',
      );
      await iriu.azurirajStavku(
        unknownRowId,
        const IriuCompanion(scenarioUpravlja: Value(true)),
      );

      final ambiguousIntent = await iriu.scenarioOpenReconciliationIntent(
        predmetId: ambiguousId,
        currentPredmet: await predmeti.getPredmet(ambiguousId),
      );

      expect(ambiguousIntent.shouldReconcile, isFalse);
      expect(await _snapshotOrNull(db, ambiguousId), isNull);
      expect((await iriu.getIriu(ambiguousId)).single.id, unknownRowId);
      expect(await (db.select(db.iriuProvenance)).get(), isEmpty);
    },
  );
}
