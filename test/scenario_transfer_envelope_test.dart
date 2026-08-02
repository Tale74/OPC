import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart';

void main() {
  group('SCENARIO transfer envelope contract', () {
    test('round-trips with a deterministic envelope hash', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [_scenarioRow(20), _basicRow(10), _manualRow(30)],
      );

      final decoded = ScenarioTransferEnvelope.fromJsonMap(
        envelope.toJsonMap(),
      );

      expect(decoded.contentHash, envelope.contentHash);
      expect(
        envelope.contentHash,
        '72e3c461089939a48261a3de51b1c19af0818669aa0d75418e75621b4e049df0',
      );
      expect(decoded.toJsonMap(), envelope.toJsonMap());
      expect(decoded.provenance.map((item) => item.iriuId), [10, 20, 30]);
      expect(
        ScenarioTransferEnvelope.decode(envelope.encode()).toJsonMap(),
        envelope.toJsonMap(),
      );
    });

    test('preserves the schema-1 assignment snapshot and its golden hash', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.unavailable,
      );
      final assignment = envelope.toJsonMap()['payload'] as Map;

      expect(assignment['assignment'], _assignment().toJsonMap());
      expect(
        (assignment['assignment'] as Map)['snapshotHash'],
        '33eaaf8fa7007b90d9c4f8ee6fd5021038b9d5b1136a402ab4b51861c29b2797',
      );
      expect(assignment['provenanceCoverage'], 'UNAVAILABLE');
      expect(assignment['provenance'], isEmpty);
    });

    test('reversed provenance input has the same representation and hash', () {
      final first = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [_scenarioRow(20), _basicRow(10)],
      );
      final second = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [_basicRow(10), _scenarioRow(20)],
      );

      expect(second.contentHash, first.contentHash);
      expect(second.toJsonMap(), first.toJsonMap());
    });

    test('coverage is explicit: unavailable cannot carry rows', () {
      expect(
        () => ScenarioTransferEnvelope.create(
          assignment: _assignment(),
          provenanceCoverage: ScenarioIriuProvenanceCoverage.unavailable,
          provenance: [_manualRow(30)],
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );

      final completeEmpty = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
      );
      expect(completeEmpty.provenance, isEmpty);
    });

    test('duplicate IDs and contradictory ownership are rejected', () {
      expect(
        () => ScenarioTransferEnvelope.create(
          assignment: _assignment(),
          provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
          provenance: [_manualRow(30), _manualRow(30)],
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
      expect(
        () => ScenarioTransferEnvelope.create(
          assignment: _assignment(),
          provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
          provenance: [
            ScenarioIriuProvenance(
              iriuId: 31,
              origin: ScenarioIriuOriginKind.scenarioPaket,
              moduleId: 'other-module',
              scenarioId: 'hospital-gradsko',
              scenarioVersion: 3,
              ruleId: 'rule-1',
            ),
          ],
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
    });

    test('unknown fields, future versions and wrong kind fail closed', () {
      final base = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
      ).toJsonMap();
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(base)..['future'] = true,
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(base)..['envelopeVersion'] = 99,
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(base)..['kind'] = 'OTHER',
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
    });

    test('payload and nested assignment tampering are rejected', () {
      final base = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
      ).toJsonMap();
      final payload = Map<String, dynamic>.from(base['payload'] as Map)
        ..['unknown'] = true;
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(base)..['payload'] = payload,
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );

      final tamperedAssignment = Map<String, dynamic>.from(
        (base['payload'] as Map)['assignment'] as Map,
      )..['osnovniPaket'] = ['OTHER'];
      final tamperedPayload = Map<String, dynamic>.from(base['payload'] as Map)
        ..['assignment'] = tamperedAssignment;
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(base)..['payload'] = tamperedPayload,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('nested provenance fields, types and coverage are strict', () {
      final withRow = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [_manualRow(30)],
      ).toJsonMap();
      final payload = Map<String, dynamic>.from(withRow['payload'] as Map);
      final provenance = List<dynamic>.from(payload['provenance'] as List);
      provenance[0] = Map<String, dynamic>.from(provenance[0] as Map)
        ..['futureField'] = true;
      payload['provenance'] = provenance;
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(withRow)..['payload'] = payload,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );

      final unavailable = Map<String, dynamic>.from(withRow['payload'] as Map)
        ..['provenanceCoverage'] = 'UNAVAILABLE';
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(withRow)..['payload'] = unavailable,
        ),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );

      final malformed = Map<String, dynamic>.from(withRow['payload'] as Map);
      malformed['provenance'] = [
        <String, dynamic>{
          'schemaVersion': 1,
          'iriuId': 'not-an-int',
          'origin': 'RUCNA_STAVKA',
        },
      ];
      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(
          Map<String, dynamic>.from(withRow)..['payload'] = malformed,
        ),
        throwsA(isA<ScenarioPersistenceValidationException>()),
      );
    });

    test('envelope content hash tampering is rejected', () {
      final base = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
      ).toJsonMap();
      base['contentHash'] = '0' * 64;

      expect(
        () => ScenarioTransferEnvelope.fromJsonMap(base),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
    });

    test('JSON encoding is an object and rejects non-object JSON', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
      );
      expect(jsonDecode(envelope.encode()), isA<Map<String, dynamic>>());
      expect(
        () => ScenarioTransferEnvelope.decode('[]'),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
      expect(
        () => ScenarioTransferEnvelope.decode('{malformed'),
        throwsA(isA<ScenarioTransferEnvelopeValidationException>()),
      );
    });

    test('legacy schema-1 adaptation is explicit', () {
      final envelope = ScenarioTransferEnvelope.fromLegacyAssignmentMap(
        assignment: _assignment().toJsonMap(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.unavailable,
      );

      expect(envelope.assignment.snapshotHash, _assignment().snapshotHash);
      expect(envelope.provenanceCoverage,
          ScenarioIriuProvenanceCoverage.unavailable);
    });

    test('legacy and manual provenance ownership is retained', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [
          _manualRow(30),
          ScenarioIriuProvenance(
            iriuId: 40,
            origin: ScenarioIriuOriginKind.legacy,
          ),
        ],
      );

      expect(
        envelope.provenance.map((item) => item.origin),
        [ScenarioIriuOriginKind.rucnaStavka, ScenarioIriuOriginKind.legacy],
      );
    });
  });
}

ScenarioAssignmentSnapshot _assignment() => ScenarioAssignmentSnapshot.create(
  moduleId: 'scenario',
  scenarioId: 'hospital-gradsko',
  scenarioVersion: 3,
  scenario: const ScenarioDefinition(
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
  ),
  osnovniPaket: {'SANDUK', 'AGENCIJSKE_USLUGE'},
  assignedAt: '2026-08-01T10:00:00.000Z',
  assignedByKorisnikId: 7,
);

ScenarioIriuProvenance _basicRow(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.osnovniPaket,
  moduleId: 'scenario',
);

ScenarioIriuProvenance _scenarioRow(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.scenarioPaket,
  moduleId: 'scenario',
  scenarioId: 'hospital-gradsko',
  scenarioVersion: 3,
  ruleId: 'rule-1',
);

ScenarioIriuProvenance _manualRow(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.rucnaStavka,
  operationId: 'manual-$id',
);
