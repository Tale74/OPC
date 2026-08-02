import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/predmet_scenario_application_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_reconciliation_contract.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('PREDMET SCENARIO application contract', () {
    test(
      'open PREDMET requires explicit confirmation for a new assignment',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _openPredmet(db);
        final assignment = _assignment();
        final reconciliation = _plan(predmet);

        final result = const PredmetScenarioApplicationContract().prepare(
          predmet: predmet,
          assignment: assignment,
          reconciliation: reconciliation,
        );

        expect(result.predmetId, predmet.id);
        expect(result.requiresUserConfirmation, isTrue);
        expect(result.isNoOp, isFalse);
      },
    );

    test(
      'closed and finished PREDMETI are rejected before any application',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _openPredmet(db);
        final assignment = _assignment();
        final reconciliation = _plan(predmet);

        for (final status in const ['ZATVOREN', 'ZAVRŠEN']) {
          await (db.update(db.predmeti)
                ..where((row) => row.id.equals(predmet.id)))
              .write(PredmetiCompanion(status: Value(status)));
          final changed = await PredmetiRepository(db).getPredmet(predmet.id);

          expect(
            () => const PredmetScenarioApplicationContract().prepare(
              predmet: changed,
              assignment: assignment,
              reconciliation: reconciliation,
            ),
            throwsA(
              isA<PredmetScenarioApplicationException>().having(
                (error) => error.reason,
                'reason',
                PredmetScenarioApplicationRejection.predmetNotOpen,
              ),
            ),
          );
        }
      },
    );

    test('assignment and reconciliation identity must match', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _openPredmet(db);
      final different = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'other-scenario',
        scenarioVersion: 1,
        scenario: const ScenarioDefinition(
          id: 'other-scenario',
          name: 'Other',
          condition: ScenarioCondition.any([]),
          consequences: [],
        ),
        osnovniPaket: const {'BASE_A'},
        assignedAt: '2026-08-02T00:00:00Z',
      );

      expect(
        () => const PredmetScenarioApplicationContract().prepare(
          predmet: predmet,
          assignment: different,
          reconciliation: _plan(predmet),
        ),
        throwsA(
          isA<PredmetScenarioApplicationException>().having(
            (error) => error.reason,
            'reason',
            PredmetScenarioApplicationRejection.planAssignmentMismatch,
          ),
        ),
      );
    });

    test('matching snapshot and no changes produce a no-op', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _openPredmet(db);
      final assignment = _assignment();
      const planner = ScenarioReconciliationPlanner();
      final reconciliation = planner.plan(
        moduleId: assignment.moduleId,
        scenario: assignment.scenario,
        scenarioVersion: assignment.scenarioVersion,
        osnovniPaket: assignment.osnovniPaket,
        predmet: predmet,
        materializedStavke: [
          ScenarioMaterializedStavka(
            iriuId: 1,
            kategorija: 'BASE_A',
            provenance: ScenarioIriuProvenance(
              iriuId: 1,
              origin: ScenarioIriuOriginKind.osnovniPaket,
              moduleId: 'scenario',
            ),
          ),
        ],
      );

      final result = const PredmetScenarioApplicationContract().prepare(
        predmet: predmet,
        assignment: assignment,
        reconciliation: reconciliation,
        currentSnapshotHash: assignment.snapshotHash,
      );

      expect(result.isNoOp, isTrue);
      expect(result.requiresUserConfirmation, isFalse);
    });
  });
}

Future<PredmetiData> _openPredmet(AppDatabase db) async {
  final id = await PredmetiRepository(db).kreirajPredmet(savetnikId: 1);
  return PredmetiRepository(db).getPredmet(id);
}

ScenarioAssignmentSnapshot _assignment() => ScenarioAssignmentSnapshot.create(
  moduleId: 'scenario',
  scenarioId: 'dom',
  scenarioVersion: 1,
  scenario: const ScenarioDefinition(
    id: 'dom',
    name: 'DOM',
    condition: ScenarioCondition.any([]),
    consequences: [
      ScenarioConsequence(
        katalogCategoryInternalName: 'SCENARIO_A',
        action: ScenarioConsequenceAction.required,
      ),
    ],
  ),
  osnovniPaket: const {'BASE_A'},
  assignedAt: '2026-08-02T00:00:00Z',
);

ScenarioReconciliationPlan _plan(PredmetiData predmet) =>
    const ScenarioReconciliationPlanner().plan(
      moduleId: 'scenario',
      scenario: _ScenarioFixture.scenario,
      scenarioVersion: 1,
      osnovniPaket: {'BASE_A'},
      predmet: predmet,
      materializedStavke: [],
    );

class _ScenarioFixture {
  static const scenario = ScenarioDefinition(
    id: 'dom',
    name: 'DOM',
    condition: ScenarioCondition.any([]),
    consequences: [
      ScenarioConsequence(
        katalogCategoryInternalName: 'SCENARIO_A',
        action: ScenarioConsequenceAction.required,
      ),
    ],
  );
}
