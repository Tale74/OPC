import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'scenario_persistence_contract.dart';

/// Version of the transport framing, distinct from the embedded schema-1
/// [ScenarioAssignmentSnapshot].
const int scenarioTransferEnvelopeVersion = 1;

const String scenarioTransferEnvelopeKind = 'OPC_SCENARIO_TRANSFER';
const String scenarioTransferEnvelopeHashAlgorithm = 'SHA-256';
const String scenarioTransferEnvelopeHashScope = 'PAYLOAD_CANONICAL_JSON';

enum ScenarioIriuProvenanceCoverage { unavailable, complete }

extension ScenarioIriuProvenanceCoverageWire
    on ScenarioIriuProvenanceCoverage {
  String get wireName {
    switch (this) {
      case ScenarioIriuProvenanceCoverage.unavailable:
        return 'UNAVAILABLE';
      case ScenarioIriuProvenanceCoverage.complete:
        return 'COMPLETE';
    }
  }

  static ScenarioIriuProvenanceCoverage fromWireName(String value) {
    switch (value) {
      case 'UNAVAILABLE':
        return ScenarioIriuProvenanceCoverage.unavailable;
      case 'COMPLETE':
        return ScenarioIriuProvenanceCoverage.complete;
      default:
        throw ScenarioTransferEnvelopeValidationException(
          'Unknown provenance coverage: $value.',
        );
    }
  }
}

/// Pure, versioned transfer framing for an assigned scenario.
///
/// This contract deliberately does not select a JSON/full-backup carrier and
/// does not materialize or reconcile rows. The nested assignment snapshot is
/// emitted verbatim so its schema-1 hash remains unchanged.
class ScenarioTransferEnvelope {
  ScenarioTransferEnvelope._({
    required this.assignment,
    required this.provenanceCoverage,
    required List<ScenarioIriuProvenance> provenance,
    required this.contentHash,
  }) : provenance = List<ScenarioIriuProvenance>.unmodifiable(provenance);

  factory ScenarioTransferEnvelope.create({
    required ScenarioAssignmentSnapshot assignment,
    required ScenarioIriuProvenanceCoverage provenanceCoverage,
    List<ScenarioIriuProvenance> provenance = const [],
  }) {
    final sorted = List<ScenarioIriuProvenance>.of(provenance)
      ..sort((a, b) => a.iriuId.compareTo(b.iriuId));
    final ids = <int>{};
    for (final item in sorted) {
      if (!ids.add(item.iriuId)) {
        throw const ScenarioTransferEnvelopeValidationException(
          'Duplicate STAVKA provenance iriuId.',
        );
      }
      _validateOwnership(assignment, item);
    }
    if (provenanceCoverage == ScenarioIriuProvenanceCoverage.unavailable &&
        sorted.isNotEmpty) {
      throw const ScenarioTransferEnvelopeValidationException(
        'UNAVAILABLE provenance coverage must not contain provenance rows.',
      );
    }
    final payload = _payloadMap(
      assignment,
      provenanceCoverage,
      sorted,
    );
    return ScenarioTransferEnvelope._(
      assignment: assignment,
      provenanceCoverage: provenanceCoverage,
      provenance: sorted,
      contentHash: _hashPayload(payload),
    );
  }

  factory ScenarioTransferEnvelope.fromJsonMap(Map<String, dynamic> json) {
    final input = _stringKeyMap(json, 'scenario transfer envelope');
    _assertAllowedKeys(input, const {
      'kind',
      'envelopeVersion',
      'hashAlgorithm',
      'hashScope',
      'payload',
      'contentHash',
    }, 'scenario transfer envelope');
    if (input['kind'] != scenarioTransferEnvelopeKind) {
      throw const ScenarioTransferEnvelopeValidationException(
        'Unsupported scenario transfer envelope kind.',
      );
    }
    if (input['envelopeVersion'] != scenarioTransferEnvelopeVersion) {
      throw const ScenarioTransferEnvelopeValidationException(
        'Unsupported scenario transfer envelope version.',
      );
    }
    if (input['hashAlgorithm'] != scenarioTransferEnvelopeHashAlgorithm ||
        input['hashScope'] != scenarioTransferEnvelopeHashScope) {
      throw const ScenarioTransferEnvelopeValidationException(
        'Unsupported scenario transfer envelope hash metadata.',
      );
    }
    final payload = _requiredMap(input, 'payload');
    _assertAllowedKeys(payload, const {
      'assignment',
      'provenanceCoverage',
      'provenance',
    }, 'scenario transfer payload');
    final assignment = ScenarioAssignmentSnapshot.fromJsonMap(
      _requiredMap(payload, 'assignment'),
    );
    final coverage = ScenarioIriuProvenanceCoverageWire.fromWireName(
      _requiredText(payload, 'provenanceCoverage'),
    );
    final provenanceMaps = _requiredMapList(payload, 'provenance');
    final provenance = provenanceMaps
        .map(ScenarioIriuProvenance.fromJsonMap)
        .toList(growable: false);
    final expected = ScenarioTransferEnvelope.create(
      assignment: assignment,
      provenanceCoverage: coverage,
      provenance: provenance,
    );
    final suppliedHash = _requiredText(input, 'contentHash');
    if (suppliedHash != expected.contentHash) {
      throw const ScenarioTransferEnvelopeValidationException(
        'Scenario transfer envelope hash does not match its contents.',
      );
    }
    return expected;
  }

  factory ScenarioTransferEnvelope.decode(String encoded) {
    // jsonDecode returns a Map and cannot detect duplicate JSON object keys;
    // a future raw-parser gate must be used when duplicate-key rejection is
    // required. This contract does reject all unknown keys after decoding.
    late final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException catch (error) {
      throw ScenarioTransferEnvelopeValidationException(
        'Scenario transfer envelope JSON is malformed: ${error.message}.',
      );
    }
    if (decoded is! Map) {
      throw const ScenarioTransferEnvelopeValidationException(
        'Scenario transfer envelope JSON must be an object.',
      );
    }
    return ScenarioTransferEnvelope.fromJsonMap(
      _stringKeyMap(decoded, 'scenario transfer envelope'),
    );
  }

  /// Explicit adapter for a legacy schema-1 assignment map. It is never
  /// invoked implicitly by [fromJsonMap] or [decode].
  factory ScenarioTransferEnvelope.fromLegacyAssignmentMap({
    required Map<String, dynamic> assignment,
    required ScenarioIriuProvenanceCoverage provenanceCoverage,
    List<ScenarioIriuProvenance> provenance = const [],
  }) => ScenarioTransferEnvelope.create(
    assignment: ScenarioAssignmentSnapshot.fromJsonMap(assignment),
    provenanceCoverage: provenanceCoverage,
    provenance: provenance,
  );

  final ScenarioAssignmentSnapshot assignment;
  final ScenarioIriuProvenanceCoverage provenanceCoverage;
  final List<ScenarioIriuProvenance> provenance;
  final String contentHash;

  Map<String, dynamic> toJsonMap() => {
    'kind': scenarioTransferEnvelopeKind,
    'envelopeVersion': scenarioTransferEnvelopeVersion,
    'hashAlgorithm': scenarioTransferEnvelopeHashAlgorithm,
    'hashScope': scenarioTransferEnvelopeHashScope,
    'payload': _payloadMap(assignment, provenanceCoverage, provenance),
    'contentHash': contentHash,
  };

  String encode() => jsonEncode(toJsonMap());

  static Map<String, dynamic> _payloadMap(
    ScenarioAssignmentSnapshot assignment,
    ScenarioIriuProvenanceCoverage coverage,
    List<ScenarioIriuProvenance> provenance,
  ) => {
    'assignment': assignment.toJsonMap(),
    'provenanceCoverage': coverage.wireName,
    'provenance': provenance.map((item) => item.toJsonMap()).toList(),
  };

  static void _validateOwnership(
    ScenarioAssignmentSnapshot assignment,
    ScenarioIriuProvenance item,
  ) {
    if (item.origin == ScenarioIriuOriginKind.osnovniPaket &&
        item.moduleId != assignment.moduleId) {
      throw const ScenarioTransferEnvelopeValidationException(
        'OSNOVNI_PAKET provenance module does not match the assignment.',
      );
    }
    if (item.origin == ScenarioIriuOriginKind.scenarioPaket &&
        (item.moduleId != assignment.moduleId ||
            item.scenarioId != assignment.scenarioId ||
            item.scenarioVersion != assignment.scenarioVersion)) {
      throw const ScenarioTransferEnvelopeValidationException(
        'SCENARIO_PAKET provenance does not match the assignment.',
      );
    }
  }
}

class ScenarioTransferEnvelopeValidationException implements Exception {
  const ScenarioTransferEnvelopeValidationException(this.message);

  final String message;

  @override
  String toString() => 'ScenarioTransferEnvelopeValidationException: $message';
}

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

Map<String, dynamic> _stringKeyMap(Object? value, String description) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw ScenarioTransferEnvelopeValidationException(
      '$description must be an object with text keys.',
    );
  }
  return value.map<String, dynamic>(
    (key, item) => MapEntry(key as String, item),
  );
}

void _assertAllowedKeys(
  Map<String, dynamic> json,
  Set<String> allowed,
  String description,
) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList()
    ..sort();
  if (unknown.isNotEmpty) {
    throw ScenarioTransferEnvelopeValidationException(
      'Unknown field(s) in $description: ${unknown.join(', ')}.',
    );
  }
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw ScenarioTransferEnvelopeValidationException('$key must be text.');
  }
  return value.trim();
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) =>
    _stringKeyMap(json[key], key);

List<Map<String, dynamic>> _requiredMapList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw ScenarioTransferEnvelopeValidationException('$key must be a list.');
  }
  return value
      .map((item) => _stringKeyMap(item, '$key item'))
      .toList(growable: false);
}
