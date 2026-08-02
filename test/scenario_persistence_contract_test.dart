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

    test('schema v1 golden payload and hash remain stable', () {
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 3,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK', 'AGENCIJSKE_USLUGE'},
        assignedAt: '2026-08-01T10:00:00.000Z',
        assignedByKorisnikId: 7,
      );

      expect(snapshot.toJsonMap(), <String, dynamic>{
        'schemaVersion': 1,
        'moduleId': 'scenario',
        'scenarioId': 'hospital-gradsko',
        'scenarioVersion': 3,
        'scenario': {
          'id': 'hospital-gradsko',
          'name': 'Bolnica i gradsko groblje',
          'condition': {
            'kind': 'ALL',
            'children': [
              {
                'kind': 'CRITERION',
                'field': 'mestoSmrti',
                'operator': 'equals',
                'values': ['BOLNICA'],
              },
            ],
          },
          'consequences': [
            {
              'katalogCategoryInternalName': 'PREVOZ_DO_GROBLJA',
              'action': 'required',
              'order': 10,
            },
          ],
        },
        'osnovniPaket': ['AGENCIJSKE_USLUGE', 'SANDUK'],
        'assignedAt': '2026-08-01T10:00:00.000Z',
        'assignedByKorisnikId': 7,
        'snapshotHash':
            '33eaaf8fa7007b90d9c4f8ee6fd5021038b9d5b1136a402ab4b51861c29b2797',
      });
    });

    test('snapshot payload is deeply frozen after assignment', () {
      final values = <String>['BOLNICA'];
      final children = <ScenarioCondition>[
        ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: values,
          ),
        ),
      ];
      final consequences = <ScenarioConsequence>[
        const ScenarioConsequence(
          katalogCategoryInternalName: 'PREVOZ_DO_GROBLJA',
          action: ScenarioConsequenceAction.required,
          order: 10,
        ),
      ];
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: ScenarioDefinition(
          id: 'hospital-gradsko',
          name: 'Bolnica i gradsko groblje',
          condition: ScenarioCondition.all(children),
          consequences: consequences,
        ),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      );

      values[0] = 'DRUGO';
      children.clear();
      consequences.clear();

      expect(snapshot.scenario.condition.children.single.criterion!.values, [
        'BOLNICA',
      ]);
      expect(snapshot.scenario.condition.children, hasLength(1));
      expect(snapshot.scenario.consequences, hasLength(1));
      expect(
        () => snapshot.scenario.condition.children.single.criterion!.values[0] =
            'DRUGO',
        throwsUnsupportedError,
      );
      expect(
        () => snapshot.scenario.consequences.clear(),
        throwsUnsupportedError,
      );
    });

    test('create canonicalizes whitespace before hashing and round-trip', () {
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: ' scenario ',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: const ScenarioDefinition(
          id: 'hospital-gradsko',
          name: ' Bolnica i gradsko groblje ',
          condition: ScenarioCondition.all([
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.mestoSmrti,
                operator: ScenarioCriterionOperator.equals,
                values: [' BOLNICA '],
              ),
            ),
          ]),
          consequences: [
            ScenarioConsequence(
              katalogCategoryInternalName: ' PREVOZ_DO_GROBLJA ',
              action: ScenarioConsequenceAction.required,
              order: 10,
            ),
          ],
        ),
        osnovniPaket: {' SANDUK '},
        assignedAt: '2026-08-01T10:00:00.000Z',
      );

      final decoded = ScenarioAssignmentSnapshot.fromJsonMap(
        snapshot.toJsonMap(),
      );

      expect(snapshot.moduleId, 'scenario');
      expect(snapshot.scenario.name, 'Bolnica i gradsko groblje');
      expect(
        snapshot.scenario.condition.children.single.criterion!.values,
        ['BOLNICA'],
      );
      expect(
        snapshot.scenario.consequences.single.katalogCategoryInternalName,
        'PREVOZ_DO_GROBLJA',
      );
      expect(snapshot.osnovniPaket, {'SANDUK'});
      expect(decoded.snapshotHash, snapshot.snapshotHash);
      expect(decoded.toJsonMap(), snapshot.toJsonMap());
    });

    test('create rejects empty criterion and consequence values', () {
      expect(
        () => ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: const ScenarioDefinition(
            id: 'hospital-gradsko',
            name: 'Bolnica',
            condition: ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.mestoSmrti,
                operator: ScenarioCriterionOperator.equals,
                values: ['   '],
              ),
            ),
            consequences: [],
          ),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
      expect(
        () => ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: const ScenarioDefinition(
            id: 'hospital-gradsko',
            name: 'Bolnica',
            condition: ScenarioCondition.all([]),
            consequences: [
              ScenarioConsequence(
                katalogCategoryInternalName: '   ',
                action: ScenarioConsequenceAction.required,
              ),
            ],
          ),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
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

      final unknownAction = Map<String, dynamic>.from(snapshot.toJsonMap());
      final actionScenario = Map<String, dynamic>.from(
        unknownAction['scenario'] as Map,
      );
      final consequences = List<dynamic>.from(
        actionScenario['consequences'] as List,
      );
      consequences[0] = Map<String, dynamic>.from(consequences[0] as Map)
        ..['action'] = 'futureAction';
      actionScenario['consequences'] = consequences;
      unknownAction['scenario'] = actionScenario;
      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(unknownAction),
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

    test('unknown fields and enum values fail with contract exceptions', () {
      final payload = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      ).toJsonMap();
      final unknownRoot = Map<String, dynamic>.from(payload)
        ..['unrecognized'] = true;
      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(unknownRoot),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );

      final unknownNested = Map<String, dynamic>.from(payload);
      final scenario = Map<String, dynamic>.from(
        unknownNested['scenario'] as Map,
      )..['unrecognized'] = true;
      unknownNested['scenario'] = scenario;
      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(unknownNested),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );

      final unknownEnum = Map<String, dynamic>.from(payload);
      final scenarioWithCondition = Map<String, dynamic>.from(
        unknownEnum['scenario'] as Map,
      );
      final condition = Map<String, dynamic>.from(
        scenarioWithCondition['condition'] as Map,
      );
      final criterion = Map<String, dynamic>.from(
        (condition['children'] as List).single as Map,
      )..['field'] = 'NOT_A_FIELD';
      condition['children'] = [criterion];
      scenarioWithCondition['condition'] = condition;
      unknownEnum['scenario'] = scenarioWithCondition;
      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(unknownEnum),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('assigned user identity must be positive', () {
      expect(
        () => ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: _scenario(),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
          assignedByKorisnikId: 0,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('provenance origin matrix prevents parallel scenario ownership', () {
      final osnovni = ScenarioIriuProvenance(
        iriuId: 43,
        origin: ScenarioIriuOriginKind.osnovniPaket,
        moduleId: 'scenario',
      );
      expect(
        ScenarioIriuProvenance.fromJsonMap(osnovni.toJsonMap()).origin,
        ScenarioIriuOriginKind.osnovniPaket,
      );
      expect(
        () => ScenarioIriuProvenance(
          iriuId: 44,
          origin: ScenarioIriuOriginKind.osnovniPaket,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
      expect(
        () => ScenarioIriuProvenance(
          iriuId: 45,
          origin: ScenarioIriuOriginKind.rucnaStavka,
          scenarioId: 'hospital-gradsko',
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('future schema versions are rejected explicitly', () {
      final payload = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      ).toJsonMap()..['schemaVersion'] = 99;
      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(payload),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('snapshot freezes mutable scenario inputs before hashing', () {
      final children = <ScenarioCondition>[
        const ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: ['BOLNICA'],
          ),
        ),
      ];
      final consequences = <ScenarioConsequence>[
        const ScenarioConsequence(
          katalogCategoryInternalName: 'PREVOZ_DO_GROBLJA',
          action: ScenarioConsequenceAction.required,
          order: 10,
        ),
      ];
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: ScenarioDefinition(
          id: 'hospital-gradsko',
          name: 'Bolnica i gradsko groblje',
          condition: ScenarioCondition.all(children),
          consequences: consequences,
        ),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      );
      final hashBefore = snapshot.snapshotHash;
      children.clear();
      consequences.clear();

      expect(snapshot.snapshotHash, hashBefore);
      expect(snapshot.scenario.consequences, hasLength(1));
      expect(snapshot.scenario.condition.children, hasLength(1));
    });

    test(
      'unknown root and nested fields are rejected before hash validation',
      () {
        final snapshot = ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: _scenario(),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
        );
        final unknownRoot = Map<String, dynamic>.from(snapshot.toJsonMap())
          ..['futureField'] = true;
        final unknownNested = Map<String, dynamic>.from(snapshot.toJsonMap());
        final scenarioMap = Map<String, dynamic>.from(
          unknownNested['scenario'] as Map,
        )..['futureField'] = true;
        unknownNested['scenario'] = scenarioMap;

        expect(
          () => ScenarioAssignmentSnapshot.fromJsonMap(unknownRoot),
          throwsA(isA<ScenarioPersistenceValidationException>()),
        );
        expect(
          () => ScenarioAssignmentSnapshot.fromJsonMap(unknownNested),
          throwsA(isA<ScenarioPersistenceValidationException>()),
        );
      },
    );

    test('unknown enum wire values use the persistence validation error', () {
      final snapshot = ScenarioAssignmentSnapshot.create(
        moduleId: 'scenario',
        scenarioId: 'hospital-gradsko',
        scenarioVersion: 1,
        scenario: _scenario(),
        osnovniPaket: {'SANDUK'},
        assignedAt: '2026-08-01T10:00:00.000Z',
      );
      final tampered = Map<String, dynamic>.from(snapshot.toJsonMap());
      final scenarioMap = Map<String, dynamic>.from(
        tampered['scenario'] as Map,
      );
      final condition = Map<String, dynamic>.from(
        scenarioMap['condition'] as Map,
      );
      final children = (condition['children'] as List)
          .map((child) => Map<String, dynamic>.from(child as Map))
          .toList();
      children[0]['field'] = 'futureField';
      condition['children'] = children;
      scenarioMap['condition'] = condition;
      tampered['scenario'] = scenarioMap;

      expect(
        () => ScenarioAssignmentSnapshot.fromJsonMap(tampered),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test(
      'provenance origin matrix rejects contradictory scenario identity',
      () {
        expect(
          () => ScenarioIriuProvenance(
            iriuId: 51,
            origin: ScenarioIriuOriginKind.legacy,
            moduleId: 'scenario',
          ),
          throwsA(isA<ScenarioPersistenceValidationException>()),
        );
        expect(
          () => ScenarioIriuProvenance(
            iriuId: 52,
            origin: ScenarioIriuOriginKind.osnovniPaket,
            moduleId: 'scenario',
            scenarioId: 'hospital-gradsko',
          ),
          throwsA(isA<ScenarioPersistenceValidationException>()),
        );
        expect(
          () => ScenarioIriuProvenance(
            iriuId: 53,
            origin: ScenarioIriuOriginKind.rucnaStavka,
            operationId: '   ',
          ),
          throwsA(isA<ScenarioPersistenceValidationException>()),
        );
      },
    );

    test('provenance canonicalizes optional identity values', () {
      final provenance = ScenarioIriuProvenance(
        iriuId: 54,
        origin: ScenarioIriuOriginKind.osnovniPaket,
        moduleId: ' scenario ',
        operationId: ' operation-1 ',
      );

      expect(provenance.moduleId, 'scenario');
      expect(provenance.operationId, 'operation-1');
      expect(
        ScenarioIriuProvenance.fromJsonMap(provenance.toJsonMap()).toJsonMap(),
        provenance.toJsonMap(),
      );
    });

    test('assignedByKorisnikId must be positive when present', () {
      expect(
        () => ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: _scenario(),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
          assignedByKorisnikId: 0,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('assignment rejects a scenario definition with a different ID', () {
      expect(
        () => ScenarioAssignmentSnapshot.create(
          moduleId: 'scenario',
          scenarioId: 'hospital-gradsko',
          scenarioVersion: 1,
          scenario: const ScenarioDefinition(
            id: 'other-scenario',
            name: 'Drugi scenario',
            condition: ScenarioCondition.all([]),
            consequences: [],
          ),
          osnovniPaket: {'SANDUK'},
          assignedAt: '2026-08-01T10:00:00.000Z',
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
