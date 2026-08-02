import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart';

void main() {
  group('Single-PREDMET SCENARIO carrier contract', () {
    test('maps local source IDs to deterministic transfer indexes', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );

      expect(block.provenance.map((item) => item.iriuTransferIndex), [0, 1, 2]);
      expect(block.provenance.first.origin, ScenarioIriuOriginKind.osnovniPaket);
      expect(block.provenance[1].origin, ScenarioIriuOriginKind.legacy);
      expect(block.provenance.last.origin, ScenarioIriuOriginKind.rucnaStavka);
    });

    test('round-trips carrier block and preserves its hash', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      final decoded = SinglePredmetScenarioCarrierBlock.fromJsonMap(
        block.toJsonMap(),
      );

      expect(decoded.toJsonMap(), block.toJsonMap());
      expect(decoded.contentHash, block.contentHash);
      expect(decoded.encode(), isNotEmpty);
    });

    test('resolves transfer indexes only through explicit destination IDs', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      final resolved = block.resolveToEnvelope(
        destinationIriuIds: [201, 202, 203],
      );

      expect(resolved.provenance.map((item) => item.iriuId), [201, 202, 203]);
      expect(resolved.provenance.map((item) => item.origin), [
        ScenarioIriuOriginKind.osnovniPaket,
        ScenarioIriuOriginKind.legacy,
        ScenarioIriuOriginKind.rucnaStavka,
      ]);
      expect(resolved.assignment.snapshotHash, _assignment().snapshotHash);
    });

    test('source identity is never reused when a row is outside the list', () {
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromEnvelope(
          envelope: _envelope(extraProvenanceId: 999),
          sourceIriuIds: [101, 102, 103],
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('duplicate source and destination IDs are rejected', () {
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromEnvelope(
          envelope: _envelope(),
          sourceIriuIds: [101, 101, 103],
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      expect(
        () => block.resolveToEnvelope(destinationIriuIds: [201, 201, 203]),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('out-of-range transfer indexes fail before resolution', () {
      final sourceIds = List<int>.generate(10, (index) => 101 + index);
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: ScenarioTransferEnvelope.create(
          assignment: _assignment(),
          provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
          provenance: sourceIds
              .map(
                (id) => ScenarioIriuProvenance(
                  iriuId: id,
                  origin: ScenarioIriuOriginKind.legacy,
                ),
              )
              .toList(growable: false),
        ),
        sourceIriuIds: sourceIds,
      );

      expect(
        () => block.resolveToEnvelope(destinationIriuIds: [201, 202, 203]),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('UNAVAILABLE coverage cannot carry references', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.unavailable,
      );
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: envelope,
        sourceIriuIds: [101, 102],
      );
      expect(block.provenance, isEmpty);
      expect(block.provenanceCoverage,
          ScenarioIriuProvenanceCoverage.unavailable);
    });

    test('COMPLETE coverage must include every transferred row', () {
      final incomplete = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [_basic(101), _legacy(102)],
      );
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromEnvelope(
          envelope: incomplete,
          sourceIriuIds: [101, 102, 103],
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: incomplete,
        sourceIriuIds: [101, 102],
      );
      expect(
        () => block.resolveToEnvelope(destinationIriuIds: [201, 202, 203]),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('unknown fields, future version and hash tampering fail closed', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromJsonMap(
          Map<String, dynamic>.from(block.toJsonMap())..['future'] = true,
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromJsonMap(
          Map<String, dynamic>.from(block.toJsonMap())..['carrierVersion'] = 99,
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromJsonMap(
          Map<String, dynamic>.from(block.toJsonMap())
            ..['contentHash'] = '0' * 64,
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('contradictory scenario ownership fails before hash comparison', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      ).toJsonMap();
      final payload = Map<String, dynamic>.from(block['payload'] as Map);
      final provenance = List<dynamic>.from(payload['provenance'] as List);
      provenance[0] = Map<String, dynamic>.from(provenance[0] as Map)
        ..['moduleId'] = 'other-module';
      payload['provenance'] = provenance;

      expect(
        () => SinglePredmetScenarioCarrierBlock.fromJsonMap(
          Map<String, dynamic>.from(block)..['payload'] = payload,
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('nested unknown fields and malformed JSON fail before resolution', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      final payload = Map<String, dynamic>.from(block.toJsonMap()['payload'] as Map);
      final provenance = List<dynamic>.from(payload['provenance'] as List);
      provenance[0] = Map<String, dynamic>.from(provenance[0] as Map)
        ..['future'] = true;
      payload['provenance'] = provenance;
      expect(
        () => SinglePredmetScenarioCarrierBlock.fromJsonMap(
          Map<String, dynamic>.from(block.toJsonMap())..['payload'] = payload,
        ),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
      expect(
        () => SinglePredmetScenarioCarrierBlock.decode('{bad'),
        throwsA(isA<SinglePredmetScenarioCarrierValidationException>()),
      );
    });

    test('manual and legacy ownership survives the carrier boundary', () {
      final envelope = ScenarioTransferEnvelope.create(
        assignment: _assignment(),
        provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
        provenance: [
          ScenarioIriuProvenance(
            iriuId: 101,
            origin: ScenarioIriuOriginKind.legacy,
          ),
          _manual(103),
        ],
      );
      final resolved = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: envelope,
        sourceIriuIds: [101, 103],
      ).resolveToEnvelope(destinationIriuIds: [201, 203]);

      expect(resolved.provenance.map((item) => item.origin), [
        ScenarioIriuOriginKind.legacy,
        ScenarioIriuOriginKind.rucnaStavka,
      ]);
    });

    test('carrier hash is stable for the golden reference fixture', () {
      final block = SinglePredmetScenarioCarrierBlock.fromEnvelope(
        envelope: _envelope(),
        sourceIriuIds: [101, 102, 103],
      );
      expect(block.contentHash,
          '9fabb3ca4aef325405878cf50fa1f6e6b09e25f99f2e26eb782fbb7a19c89bfd');
    });
  });
}

ScenarioTransferEnvelope _envelope({int? extraProvenanceId}) {
  final provenance = <ScenarioIriuProvenance>[
    _basic(101),
    ScenarioIriuProvenance(
      iriuId: 102,
      origin: ScenarioIriuOriginKind.legacy,
    ),
    _manual(103),
    if (extraProvenanceId != null) _manual(extraProvenanceId),
  ];
  return ScenarioTransferEnvelope.create(
    assignment: _assignment(),
    provenanceCoverage: ScenarioIriuProvenanceCoverage.complete,
    provenance: provenance,
  );
}

ScenarioIriuProvenance _basic(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.osnovniPaket,
  moduleId: 'scenario',
);

ScenarioIriuProvenance _manual(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.rucnaStavka,
  operationId: 'manual-$id',
);

ScenarioIriuProvenance _legacy(int id) => ScenarioIriuProvenance(
  iriuId: id,
  origin: ScenarioIriuOriginKind.legacy,
);

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
