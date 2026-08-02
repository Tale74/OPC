import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'scenario_persistence_contract.dart';
import 'scenario_transfer_envelope.dart';

/// Version of the Single-PREDMET scenario block, independent of the carrier's
/// root JSON schema version.
const int singlePredmetScenarioCarrierVersion = 1;
const String singlePredmetScenarioCarrierKind =
    'OPC_SINGLE_PREDMET_SCENARIO';
const String singlePredmetScenarioCarrierHashAlgorithm = 'SHA-256';
const String singlePredmetScenarioCarrierHashScope =
    'PAYLOAD_CANONICAL_JSON';

/// A carrier-safe reference to one IRIU row. The source/destination database
/// primary key is deliberately absent; the transfer index is scoped to the
/// exported IRIU list and is resolved only by an explicit preflight step.
class SinglePredmetScenarioProvenanceReference {
  SinglePredmetScenarioProvenanceReference({
    required this.iriuTransferIndex,
    required this.origin,
    String? moduleId,
    String? scenarioId,
    this.scenarioVersion,
    String? ruleId,
    String? operationId,
  }) : moduleId = _optionalText(moduleId, 'moduleId'),
       scenarioId = _optionalText(scenarioId, 'scenarioId'),
       ruleId = _optionalText(ruleId, 'ruleId'),
       operationId = _optionalText(operationId, 'operationId') {
    if (iriuTransferIndex < 0) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'iriuTransferIndex must not be negative.',
      );
    }
    if (scenarioVersion != null && scenarioVersion! <= 0) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'scenarioVersion must be positive.',
      );
    }
    _validateOriginIdentity(
      origin: origin,
      moduleId: this.moduleId,
      scenarioId: this.scenarioId,
      scenarioVersion: scenarioVersion,
      ruleId: this.ruleId,
      operationId: this.operationId,
    );
  }

  factory SinglePredmetScenarioProvenanceReference.fromJsonMap(
    Map<String, dynamic> json,
  ) {
    _assertSchema(json);
    _assertAllowedKeys(json, const {
      'schemaVersion',
      'iriuTransferIndex',
      'origin',
      'moduleId',
      'scenarioId',
      'scenarioVersion',
      'ruleId',
      'operationId',
    }, 'Single-PREDMET provenance reference');
    return SinglePredmetScenarioProvenanceReference(
      iriuTransferIndex: _requiredInt(json, 'iriuTransferIndex'),
      origin: ScenarioIriuOriginKindWire.fromWireName(
        _requiredText(json, 'origin'),
      ),
      moduleId: _optionalTextValue(json, 'moduleId'),
      scenarioId: _optionalTextValue(json, 'scenarioId'),
      scenarioVersion: _optionalIntValue(json, 'scenarioVersion'),
      ruleId: _optionalTextValue(json, 'ruleId'),
      operationId: _optionalTextValue(json, 'operationId'),
    );
  }

  final int iriuTransferIndex;
  final ScenarioIriuOriginKind origin;
  final String? moduleId;
  final String? scenarioId;
  final int? scenarioVersion;
  final String? ruleId;
  final String? operationId;

  Map<String, dynamic> toJsonMap() => {
    'schemaVersion': scenarioPersistenceSchemaVersion,
    'iriuTransferIndex': iriuTransferIndex,
    'origin': origin.wireName,
    if (moduleId != null) 'moduleId': moduleId,
    if (scenarioId != null) 'scenarioId': scenarioId,
    if (scenarioVersion != null) 'scenarioVersion': scenarioVersion,
    if (ruleId != null) 'ruleId': ruleId,
    if (operationId != null) 'operationId': operationId,
  };

  ScenarioIriuProvenance resolve(int destinationIriuId) {
    if (destinationIriuId <= 0) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'Resolved destination iriuId must be positive.',
      );
    }
    return ScenarioIriuProvenance(
      iriuId: destinationIriuId,
      origin: origin,
      moduleId: moduleId,
      scenarioId: scenarioId,
      scenarioVersion: scenarioVersion,
      ruleId: ruleId,
      operationId: operationId,
    );
  }
}

/// Pure Single-PREDMET carrier block for the scenario envelope.
///
/// It carries transfer indexes instead of local database IDs. Existing JSON
/// export/import and root schema wiring are intentionally outside this class.
class SinglePredmetScenarioCarrierBlock {
  SinglePredmetScenarioCarrierBlock._({
    required this.assignment,
    required this.provenanceCoverage,
    required List<SinglePredmetScenarioProvenanceReference> provenance,
    required this.contentHash,
  }) : provenance = List<SinglePredmetScenarioProvenanceReference>.unmodifiable(
         provenance,
       );

  factory SinglePredmetScenarioCarrierBlock.fromEnvelope({
    required ScenarioTransferEnvelope envelope,
    required List<int> sourceIriuIds,
  }) {
    final sourceIndexById = <int, int>{};
    for (var index = 0; index < sourceIriuIds.length; index++) {
      final id = sourceIriuIds[index];
      if (id <= 0 || sourceIndexById.containsKey(id)) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'Source IRIU IDs must be unique positive values.',
        );
      }
      sourceIndexById[id] = index;
    }
    final references = envelope.provenance
        .map(
          (item) => SinglePredmetScenarioProvenanceReference(
            iriuTransferIndex: sourceIndexById[item.iriuId] ??
                (throw const SinglePredmetScenarioCarrierValidationException(
                  'Scenario provenance references an IRIU row outside the transfer list.',
                )),
            origin: item.origin,
            moduleId: item.moduleId,
            scenarioId: item.scenarioId,
            scenarioVersion: item.scenarioVersion,
            ruleId: item.ruleId,
            operationId: item.operationId,
          ),
        )
        .toList(growable: false);
    _validateAssignmentOwnership(envelope.assignment, references);
    _assertCompleteCoverage(
      envelope.provenanceCoverage,
      sourceIriuIds.length,
      references,
    );
    return _create(
      assignment: envelope.assignment,
      provenanceCoverage: envelope.provenanceCoverage,
      provenance: references,
    );
  }

  factory SinglePredmetScenarioCarrierBlock.fromJsonMap(
    Map<String, dynamic> json,
  ) {
    final input = _stringKeyMap(json, 'Single-PREDMET scenario carrier');
    _assertAllowedKeys(input, const {
      'kind',
      'carrierVersion',
      'hashAlgorithm',
      'hashScope',
      'payload',
      'contentHash',
    }, 'Single-PREDMET scenario carrier');
    if (input['kind'] != singlePredmetScenarioCarrierKind) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'Unsupported Single-PREDMET scenario carrier kind.',
      );
    }
    if (input['carrierVersion'] != singlePredmetScenarioCarrierVersion) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'Unsupported Single-PREDMET scenario carrier version.',
      );
    }
    if (input['hashAlgorithm'] != singlePredmetScenarioCarrierHashAlgorithm ||
        input['hashScope'] != singlePredmetScenarioCarrierHashScope) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'Unsupported Single-PREDMET scenario carrier hash metadata.',
      );
    }
    final payload = _requiredMap(input, 'payload');
    _assertAllowedKeys(payload, const {
      'assignment',
      'provenanceCoverage',
      'provenance',
    }, 'Single-PREDMET scenario carrier payload');
    final assignment = ScenarioAssignmentSnapshot.fromJsonMap(
      _requiredMap(payload, 'assignment'),
    );
    final coverage = ScenarioIriuProvenanceCoverageWire.fromWireName(
      _requiredText(payload, 'provenanceCoverage'),
    );
    final references = _requiredMapList(payload, 'provenance')
        .map(SinglePredmetScenarioProvenanceReference.fromJsonMap)
        .toList(growable: false);
    _validateAssignmentOwnership(assignment, references);
    final block = _create(
      assignment: assignment,
      provenanceCoverage: coverage,
      provenance: references,
    );
    if (block.contentHash != _requiredText(input, 'contentHash')) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'Single-PREDMET scenario carrier hash does not match its contents.',
      );
    }
    return block;
  }

  factory SinglePredmetScenarioCarrierBlock.decode(String encoded) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException catch (error) {
      throw SinglePredmetScenarioCarrierValidationException(
        'Single-PREDMET scenario carrier JSON is malformed: ${error.message}.',
      );
    }
    return SinglePredmetScenarioCarrierBlock.fromJsonMap(
      _stringKeyMap(decoded, 'Single-PREDMET scenario carrier'),
    );
  }

  final ScenarioAssignmentSnapshot assignment;
  final ScenarioIriuProvenanceCoverage provenanceCoverage;
  final List<SinglePredmetScenarioProvenanceReference> provenance;
  final String contentHash;

  Map<String, dynamic> toJsonMap() => {
    'kind': singlePredmetScenarioCarrierKind,
    'carrierVersion': singlePredmetScenarioCarrierVersion,
    'hashAlgorithm': singlePredmetScenarioCarrierHashAlgorithm,
    'hashScope': singlePredmetScenarioCarrierHashScope,
    'payload': _payloadMap(assignment, provenanceCoverage, provenance),
    'contentHash': contentHash,
  };

  String encode() => jsonEncode(toJsonMap());

  ScenarioTransferEnvelope resolveToEnvelope({
    required List<int> destinationIriuIds,
  }) {
    final ids = <int>{};
    for (final id in destinationIriuIds) {
      if (id <= 0 || !ids.add(id)) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'Destination IRIU IDs must be unique positive values.',
        );
      }
    }
    _assertCompleteCoverage(
      provenanceCoverage,
      destinationIriuIds.length,
      provenance,
    );
    final resolved = provenance
        .map((reference) {
          if (reference.iriuTransferIndex >= destinationIriuIds.length) {
            throw const SinglePredmetScenarioCarrierValidationException(
              'Scenario provenance transfer index is outside the destination list.',
            );
          }
          return reference.resolve(
            destinationIriuIds[reference.iriuTransferIndex],
          );
        })
        .toList(growable: false);
    return ScenarioTransferEnvelope.create(
      assignment: assignment,
      provenanceCoverage: provenanceCoverage,
      provenance: resolved,
    );
  }

  static SinglePredmetScenarioCarrierBlock _create({
    required ScenarioAssignmentSnapshot assignment,
    required ScenarioIriuProvenanceCoverage provenanceCoverage,
    required List<SinglePredmetScenarioProvenanceReference> provenance,
  }) {
    final sorted = List<SinglePredmetScenarioProvenanceReference>.of(provenance)
      ..sort((a, b) => a.iriuTransferIndex.compareTo(b.iriuTransferIndex));
    _validateAssignmentOwnership(assignment, sorted);
    final indexes = <int>{};
    for (final reference in sorted) {
      if (!indexes.add(reference.iriuTransferIndex)) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'Duplicate scenario provenance transfer index.',
        );
      }
    }
    if (provenanceCoverage == ScenarioIriuProvenanceCoverage.unavailable &&
        sorted.isNotEmpty) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'UNAVAILABLE provenance coverage must not contain provenance rows.',
      );
    }
    final payload = _payloadMap(assignment, provenanceCoverage, sorted);
    return SinglePredmetScenarioCarrierBlock._(
      assignment: assignment,
      provenanceCoverage: provenanceCoverage,
      provenance: sorted,
      contentHash: _hashPayload(payload),
    );
  }
}

void _validateAssignmentOwnership(
  ScenarioAssignmentSnapshot assignment,
  Iterable<SinglePredmetScenarioProvenanceReference> provenance,
) {
  for (final item in provenance) {
    if (item.origin == ScenarioIriuOriginKind.osnovniPaket &&
        item.moduleId != assignment.moduleId) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'OSNOVNI_PAKET provenance module does not match the assignment.',
      );
    }
    if (item.origin == ScenarioIriuOriginKind.scenarioPaket &&
        (item.moduleId != assignment.moduleId ||
            item.scenarioId != assignment.scenarioId ||
            item.scenarioVersion != assignment.scenarioVersion)) {
      throw const SinglePredmetScenarioCarrierValidationException(
        'SCENARIO_PAKET provenance does not match the assignment.',
      );
    }
  }
}

void _assertCompleteCoverage(
  ScenarioIriuProvenanceCoverage coverage,
  int rowCount,
  Iterable<SinglePredmetScenarioProvenanceReference> provenance,
) {
  if (coverage != ScenarioIriuProvenanceCoverage.complete) return;
  final indexes = provenance.map((item) => item.iriuTransferIndex).toSet();
  if (indexes.length != rowCount ||
      indexes.any((index) => index < 0 || index >= rowCount)) {
    throw const SinglePredmetScenarioCarrierValidationException(
      'COMPLETE provenance coverage must identify every transferred IRIU row.',
    );
  }
}

class SinglePredmetScenarioCarrierValidationException implements Exception {
  const SinglePredmetScenarioCarrierValidationException(this.message);

  final String message;

  @override
  String toString() =>
      'SinglePredmetScenarioCarrierValidationException: $message';
}

Map<String, dynamic> _payloadMap(
  ScenarioAssignmentSnapshot assignment,
  ScenarioIriuProvenanceCoverage coverage,
  List<SinglePredmetScenarioProvenanceReference> provenance,
) => {
  'assignment': assignment.toJsonMap(),
  'provenanceCoverage': coverage.wireName,
  'provenance': provenance.map((item) => item.toJsonMap()).toList(),
};

String _hashPayload(Map<String, dynamic> payload) => sha256
    .convert(utf8.encode(jsonEncode(_canonicalize(payload))))
    .toString();

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return <String, dynamic>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is Iterable) return value.map(_canonicalize).toList();
  return value;
}

void _validateOriginIdentity({
  required ScenarioIriuOriginKind origin,
  required String? moduleId,
  required String? scenarioId,
  required int? scenarioVersion,
  required String? ruleId,
  required String? operationId,
}) {
  final hasScenarioIdentity =
      moduleId != null ||
      scenarioId != null ||
      scenarioVersion != null ||
      ruleId != null;
  switch (origin) {
    case ScenarioIriuOriginKind.scenarioPaket:
      if (moduleId == null ||
          scenarioId == null ||
          scenarioVersion == null ||
          ruleId == null) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'SCENARIO_PAKET provenance requires scenario identity and ruleId.',
        );
      }
    case ScenarioIriuOriginKind.osnovniPaket:
      if (moduleId == null ||
          scenarioId != null ||
          scenarioVersion != null ||
          ruleId != null) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'OSNOVNI_PAKET provenance requires moduleId and no scenario rule identity.',
        );
      }
    case ScenarioIriuOriginKind.legacy:
    case ScenarioIriuOriginKind.rucnaStavka:
      if (hasScenarioIdentity) {
        throw const SinglePredmetScenarioCarrierValidationException(
          'This provenance origin must not carry scenario identity.',
        );
      }
  }
  if (operationId != null && operationId.trim().isEmpty) {
    throw const SinglePredmetScenarioCarrierValidationException(
      'operationId must not be empty.',
    );
  }
}

String? _optionalText(String? value, String key) {
  if (value == null) return null;
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw SinglePredmetScenarioCarrierValidationException('$key must not be empty.');
  }
  return normalized;
}

void _assertSchema(Map<String, dynamic> json) {
  if (json['schemaVersion'] != scenarioPersistenceSchemaVersion) {
    throw const SinglePredmetScenarioCarrierValidationException(
      'Unsupported provenance schema version.',
    );
  }
}

void _assertAllowedKeys(
  Map<String, dynamic> json,
  Set<String> allowed,
  String description,
) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList()
    ..sort();
  if (unknown.isNotEmpty) {
    throw SinglePredmetScenarioCarrierValidationException(
      'Unknown field(s) in $description: ${unknown.join(', ')}.',
    );
  }
}

Map<String, dynamic> _stringKeyMap(Object? value, String description) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw SinglePredmetScenarioCarrierValidationException(
      '$description must be an object with text keys.',
    );
  }
  return value.map<String, dynamic>(
    (key, item) => MapEntry(key as String, item),
  );
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw SinglePredmetScenarioCarrierValidationException('$key must be text.');
  }
  return value.trim();
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw SinglePredmetScenarioCarrierValidationException('$key must be an integer.');
  }
  return value;
}

int? _optionalIntValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! int) {
    throw SinglePredmetScenarioCarrierValidationException('$key must be an integer.');
  }
  return value;
}

String? _optionalTextValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw SinglePredmetScenarioCarrierValidationException('$key must be text.');
  }
  return _optionalText(value, key);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) =>
    _stringKeyMap(json[key], key);

List<Map<String, dynamic>> _requiredMapList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw SinglePredmetScenarioCarrierValidationException('$key must be a list.');
  }
  return value
      .map((item) => _stringKeyMap(item, '$key item'))
      .toList(growable: false);
}
