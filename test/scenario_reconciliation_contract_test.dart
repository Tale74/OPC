import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_reconciliation_contract.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('SCENARIO reconciliation contract', () {
    test(
      'removes stale owned rows, updates provenance and protects manual rows',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetRepo = PredmetiRepository(db);
        final predmetId = await predmetRepo.kreirajPredmet(savetnikId: 1);
        await predmetRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final predmet = await predmetRepo.getPredmet(predmetId);
        final scenario = _scenario();
        const planner = ScenarioReconciliationPlanner();

        final plan = planner.plan(
          moduleId: 'scenario',
          scenario: scenario,
          scenarioVersion: 2,
          osnovniPaket: const {'BASE_A'},
          predmet: predmet,
          materializedStavke: [
            _provenanceRow(
              1,
              ScenarioIriuOriginKind.osnovniPaket,
              moduleId: 'scenario',
            ).asRow('BASE_A'),
            _provenanceRow(
              2,
              ScenarioIriuOriginKind.scenarioPaket,
              moduleId: 'scenario',
              scenarioId: 'dom-old',
              scenarioVersion: 1,
              ruleId: 'dom-old#0:SCENARIO_A',
            ).asRow('SCENARIO_A'),
            _provenanceRow(
              3,
              ScenarioIriuOriginKind.scenarioPaket,
              moduleId: 'scenario',
              scenarioId: 'dom-old',
              scenarioVersion: 1,
              ruleId: 'dom-old#1:STALE',
            ).asRow('STALE'),
            _provenanceRow(
              4,
              ScenarioIriuOriginKind.rucnaStavka,
            ).asRow('RUČNA'),
            _provenanceRow(5, ScenarioIriuOriginKind.legacy).asRow('LEGACY'),
            _provenanceRow(
              6,
              ScenarioIriuOriginKind.scenarioPaket,
              moduleId: 'other-module',
              scenarioId: 'other',
              scenarioVersion: 1,
              ruleId: 'other#0:OTHER_MODULE',
            ).asRow('OTHER_MODULE'),
            const ScenarioMaterializedStavka(iriuId: 7, kategorija: 'UNKNOWN'),
          ],
        );

        expect(plan.desiredCategories, {'BASE_A', 'SCENARIO_A'});
        expect(plan.removals.map((item) => item.iriuId), [3]);
        expect(plan.additions, isEmpty);
        expect(plan.updates.map((item) => item.iriuId), [2]);
        expect(plan.updates.single.ruleId, 'dom#0:SCENARIO_A');
        expect(plan.requiresUserNotice, isTrue);
      },
    );

    test(
      'does not retain scenario rows when the criterion no longer matches',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetRepo = PredmetiRepository(db);
        final predmetId = await predmetRepo.kreirajPredmet(savetnikId: 1);
        final predmet = await predmetRepo.getPredmet(predmetId);
        final plan = const ScenarioReconciliationPlanner().plan(
          moduleId: 'scenario',
          scenario: _ScenarioFixtures.outsideDom,
          scenarioVersion: 1,
          osnovniPaket: const {'BASE_A'},
          predmet: predmet,
          materializedStavke: [
            _ScenarioFixtures.baseRow,
            _ScenarioFixtures.scenarioRow,
          ],
        );

        expect(plan.matchesCondition, isFalse);
        expect(plan.desiredCategories, {'BASE_A'});
        expect(plan.removals.map((item) => item.iriuId), [2]);
        expect(plan.additions, isEmpty);
      },
    );

    test(
      'produces deterministic additions for a matching empty package',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetRepo = PredmetiRepository(db);
        final predmetId = await predmetRepo.kreirajPredmet(savetnikId: 1);
        await predmetRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final predmet = await predmetRepo.getPredmet(predmetId);
        final plan = const ScenarioReconciliationPlanner().plan(
          moduleId: 'scenario',
          scenario: _ScenarioFixtures.dom,
          scenarioVersion: 3,
          osnovniPaket: const {'BASE_A'},
          predmet: predmet,
          materializedStavke: const [],
        );

        expect(plan.additions.map((item) => item.kategorija), [
          'BASE_A',
          'SCENARIO_A',
        ]);
        expect(
          plan.additions.first.origin,
          ScenarioReconciliationOrigin.osnovniPaket,
        );
        expect(
          plan.additions.last.origin,
          ScenarioReconciliationOrigin.scenarioPaket,
        );
        expect(plan.additions.last.ruleId, 'dom#0:SCENARIO_A');
      },
    );

    test(
      'suppressed consequence removes a base category owned by the module',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetRepo = PredmetiRepository(db);
        final predmetId = await predmetRepo.kreirajPredmet(savetnikId: 1);
        await predmetRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final predmet = await predmetRepo.getPredmet(predmetId);
        final plan = const ScenarioReconciliationPlanner().plan(
          moduleId: 'scenario',
          scenario: _ScenarioFixtures.suppressesBase,
          scenarioVersion: 1,
          osnovniPaket: const {'BASE_A'},
          predmet: predmet,
          materializedStavke: [_ScenarioFixtures.baseRow],
        );

        expect(plan.desiredCategories, isEmpty);
        expect(plan.removals.map((item) => item.iriuId), [1]);
      },
    );
  });
}

ScenarioDefinition _scenario() => _ScenarioFixtures.dom;

ScenarioIriuProvenance _provenanceRow(
  int id,
  ScenarioIriuOriginKind origin, {
  String? moduleId,
  String? scenarioId,
  int? scenarioVersion,
  String? ruleId,
}) => ScenarioIriuProvenance(
  iriuId: id,
  origin: origin,
  moduleId: moduleId,
  scenarioId: scenarioId,
  scenarioVersion: scenarioVersion,
  ruleId: ruleId,
);

extension on ScenarioIriuProvenance {
  ScenarioMaterializedStavka asRow(String category) =>
      ScenarioMaterializedStavka(
        iriuId: iriuId,
        kategorija: category,
        provenance: this,
      );
}

class _ScenarioFixtures {
  static const dom = ScenarioDefinition(
    id: 'dom',
    name: 'DOM',
    condition: ScenarioCondition.criterion(
      ScenarioCriterion(
        field: ScenarioCriterionField.mestoSmrti,
        operator: ScenarioCriterionOperator.equals,
        values: ['DOM ZA STARE'],
      ),
    ),
    consequences: [
      ScenarioConsequence(
        katalogCategoryInternalName: 'SCENARIO_A',
        action: ScenarioConsequenceAction.required,
        order: 1,
      ),
    ],
  );

  static const outsideDom = dom;

  static const suppressesBase = ScenarioDefinition(
    id: 'suppress-base',
    name: 'Suppress base',
    condition: ScenarioCondition.criterion(
      ScenarioCriterion(
        field: ScenarioCriterionField.mestoSmrti,
        operator: ScenarioCriterionOperator.equals,
        values: ['DOM ZA STARE'],
      ),
    ),
    consequences: [
      ScenarioConsequence(
        katalogCategoryInternalName: 'BASE_A',
        action: ScenarioConsequenceAction.suppressed,
      ),
    ],
  );

  static final baseRow = _provenanceRow(
    1,
    ScenarioIriuOriginKind.osnovniPaket,
    moduleId: 'scenario',
  ).asRow('BASE_A');

  static final scenarioRow = _provenanceRow(
    2,
    ScenarioIriuOriginKind.scenarioPaket,
    moduleId: 'scenario',
    scenarioId: 'dom',
    scenarioVersion: 1,
    ruleId: 'dom#0:SCENARIO_A',
  ).asRow('SCENARIO_A');
}
