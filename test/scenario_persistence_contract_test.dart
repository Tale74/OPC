import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';

void main() {
  group('SCENARIO persistence contract', () {
    test('snapshot round-trips with a stable content hash', () {
      final original = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 3,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK', 'AGENCIJSKE_USLUGE'},
        assignedAt: '2026-08-01T10:00:00.000Z',
        assignedByKorisnikId: 7,
      );

      final decoded = ScenarioAssignmentSnapshot.fromJsonMap(
        original.toJsonMap(),
      );

      expect(decoded.snapshotHash, original.snapshotHash);
      expect(decoded.moduleId, 'scenario');
      expect(decoded.scenarioId, 'hospital-gradsko');
      expect(decoded.scenarioVersion, 3);
      expect(decoded.osnovniPaket, {'AGENCIJSKE_USLUGE', 'SANDUK'});
      expect(decoded.scenario.consequences.single.order, 10);
    });

    test('tampering with selected package is rejected by the hash guard', () {
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      );
      final tampered = Map<String, dynamic>.from(snapshot.toJsonMap())
        ..['osnovniPaket'] = <String>['DRUGA_STAVKA'];

      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(tampered),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('manual STAVKA provenance remains outside scenario ownership', () {
      final provenance = ScenarioIriuProvenance(
        iriuId: 41,
        origin: ScenarioIriuOriginKind.rucnaStavka,
        operationId: 'manual-41',
      );

      final decoded = ScenarioIriuProvenance.fromJsonMap(
        provenance.toJsonMap(),
      );

      expect(decoded.origin, ScenarioIriuOriginKind.rucnaStavka);
      expect(decoded.scenarioId, isNull);
      expect(decoded.scenarioVersion, isNull);
    });

    test('scenario package provenance requires an immutable rule identity', () {
      expect(
        () => ScenarioIriuProvenance(
          iriuId: 42,
          origin: ScenarioIriuOriginKind.scenarioPaket,
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });
  });
}

ScenarioDefinition _scenario() => const ScenarioDefinition(
  id: 'hospital-gradsko',
  name: 'Bolnica i gradsko groblje',
  condition: ScenarioCondition.all([
    ScenarioCondition.criterion(
      ScenarioCriterion(
        field: ScenarioCriterionField.mestoSmrti,
        operator: ScenarioCriterionOperator.equals,
        values: ['BOLNICA'],
      ),
    ),
  ]),
  consequences: [
    ScenarioConsequence(
      katalogCategoryInternalName: 'PREVOZ_DO_GROBLJA',
      action: ScenarioConsequenceAction.required,
      order: 10,
    ),
  ],
);
