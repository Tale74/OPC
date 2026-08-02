import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'scenario_contract.dart';

const int scenarioPersistenceSchemaVersion = 1;

enum ScenarioIriuOriginKind { legacy, osnovniPaket, scenarioPaket, rucnaStavka }

extension ScenarioIriuOriginKindWire on ScenarioIriuOriginKind {
  String get wireName {
    switch (this) {
      case ScenarioIriuOriginKind.legacy:
        return 'LEGACY';
      case ScenarioIriuOriginKind.osnovniPaket:
        return 'OSNOVNI_PAKET';
      case ScenarioIriuOriginKind.scenarioPaket:
        return 'SCENARIO_PAKET';
      case ScenarioIriuOriginKind.rucnaStavka:
        return 'RUCNA_STAVKA';
    }
  }

  static ScenarioIriuOriginKind fromWireName(String value) {
    return switch (value) {
      'LEGACY' => ScenarioIriuOriginKind.legacy,
      'OSNOVNI_PAKET' => ScenarioIriuOriginKind.osnovniPaket,
      'SCENARIO_PAKET' => ScenarioIriuOriginKind.scenarioPaket,
      'RUCNA_STAVKA' => ScenarioIriuOriginKind.rucnaStavka,
      _ => throw const ScenarioPersistenceValidationException(
        'Unknown STAVKA provenance origin.',
      ),
    };
  }
}

/// Immutable scenario state assigned to one PREDMET.
///
/// This is a pure persistence/transfer contract. It is intentionally not
/// connected to Drift or JSON import yet; the snapshot must be proven first.
/// Callers must use [create] or [fromJsonMap]; the validating constructor is
/// private so future repository code cannot bypass the invariant boundary.
class ScenarioAssignmentSnapshot {
  ScenarioAssignmentSnapshot._({
    required this.moduleId,
    required this.scenarioId,
    required this.scenarioVersion,
    required ScenarioDefinition scenario,
    required Set<String> osnovniPaket,
    required this.assignedAt,
    required this.snapshotHash,
    int? assignedByKorisnikId,
  }) : scenario = _freezeScenario(scenario),
       osnovniPaket = Set<String>.unmodifiable(osnovniPaket),
       assignedByKorisnikId = assignedByKorisnikId == null
           ? null
           : _requiredPositiveInt(assignedByKorisnikId, 'assignedByKorisnikId');

  factory ScenarioAssignmentSnapshot.create({
    required String moduleId,
    required String scenarioId,
    required int scenarioVersion,
    required ScenarioDefinition scenario,
    required Set<String> osnovniPaket,
    required String assignedAt,
    int? assignedByKorisnikId,
  }) {
    if (scenario.id != scenarioId) {
      throw const ScenarioPersistenceValidationException(
        'Scenario snapshot ID does not match its definition.',
      );
    }
    final draft = ScenarioAssignmentSnapshot._(
      moduleId: _requiredText(moduleId, 'moduleId'),
      scenarioId: _requiredText(scenarioId, 'scenarioId'),
      scenarioVersion: _requiredPositiveInt(scenarioVersion, 'scenarioVersion'),
      scenario: scenario,
      osnovniPaket: _validatedCategories(osnovniPaket, 'osnovniPaket'),
      assignedAt: _requiredText(assignedAt, 'assignedAt'),
      snapshotHash: '',
      assignedByKorisnikId: assignedByKorisnikId == null
          ? null
          : _requiredPositiveInt(assignedByKorisnikId, 'assignedByKorisnikId'),
    );
    return ScenarioAssignmentSnapshot._(
      moduleId: draft.moduleId,
      scenarioId: draft.scenarioId,
      scenarioVersion: draft.scenarioVersion,
      scenario: draft.scenario,
      osnovniPaket: draft.osnovniPaket,
      assignedAt: draft.assignedAt,
      snapshotHash: _hashPayload(draft._payloadMap),
      assignedByKorisnikId: draft.assignedByKorisnikId,
    );
  }

  factory ScenarioAssignmentSnapshot.fromJsonMap(Map<String, dynamic> json) {
    _assertSchema(json);
    _assertAllowedKeys(json, const {
      'schemaVersion',
      'moduleId',
      'scenarioId',
      'scenarioVersion',
      'scenario',
      'osnovniPaket',
      'assignedAt',
      'assignedByKorisnikId',
      'snapshotHash',
    }, 'scenario snapshot');
    final snapshot = ScenarioAssignmentSnapshot._(
      moduleId: _requiredTextValue(json, 'moduleId'),
      scenarioId: _requiredTextValue(json, 'scenarioId'),
      scenarioVersion: _requiredPositiveIntValue(json, 'scenarioVersion'),
      scenario: _scenarioFromJson(_requiredMap(json, 'scenario')),
      osnovniPaket: _requiredStringSet(json, 'osnovniPaket'),
      assignedAt: _requiredTextValue(json, 'assignedAt'),
      snapshotHash: _requiredTextValue(json, 'snapshotHash'),
      assignedByKorisnikId: _optionalPositiveIntValue(
        json,
        'assignedByKorisnikId',
      ),
    );
    if (snapshot.scenario.id != snapshot.scenarioId) {
      throw const ScenarioPersistenceValidationException(
        'Scenario snapshot ID does not match its definition.',
      );
    }
    if (_hashPayload(snapshot._payloadMap) != snapshot.snapshotHash) {
      throw const ScenarioPersistenceValidationException(
        'Scenario snapshot hash does not match its contents.',
      );
    }
    return snapshot;
  }

  final String moduleId;
  final String scenarioId;
  final int scenarioVersion;
  final ScenarioDefinition scenario;
  final Set<String> osnovniPaket;
  final String assignedAt;
  final int? assignedByKorisnikId;
  final String snapshotHash;

  Map<String, dynamic> toJsonMap() => {
    'schemaVersion': scenarioPersistenceSchemaVersion,
    ..._payloadMap,
    'snapshotHash': snapshotHash,
  };

  Map<String, dynamic> get _payloadMap => {
    'moduleId': moduleId,
    'scenarioId': scenarioId,
    'scenarioVersion': scenarioVersion,
    'scenario': _scenarioToJson(scenario),
    'osnovniPaket': osnovniPaket.toList()..sort(),
    'assignedAt': assignedAt,
    if (assignedByKorisnikId != null)
      'assignedByKorisnikId': assignedByKorisnikId,
  };
}

/// Provenance for one materialized STAVKA. Legacy rows may remain unclassified
/// until an explicit migration; reconciliation may remove only scenario-owned
/// rows, never RUČNA STAVKA rows.
class ScenarioIriuProvenance {
  ScenarioIriuProvenance({
    required this.iriuId,
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
    if (iriuId <= 0) {
      throw const ScenarioPersistenceValidationException(
        'iriuId must be positive.',
      );
    }
    _validateProvenanceIdentity();
    if (scenarioVersion != null && scenarioVersion! <= 0) {
      throw const ScenarioPersistenceValidationException(
        'scenarioVersion must be positive.',
      );
    }
  }

  void _validateProvenanceIdentity() {
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
          throw const ScenarioPersistenceValidationException(
            'SCENARIO_PAKET provenance requires scenario identity and ruleId.',
          );
        }
      case ScenarioIriuOriginKind.osnovniPaket:
        if (moduleId == null ||
            scenarioId != null ||
            scenarioVersion != null ||
            ruleId != null) {
          throw const ScenarioPersistenceValidationException(
            'OSNOVNI_PAKET provenance requires moduleId and no scenario rule identity.',
          );
        }
      case ScenarioIriuOriginKind.legacy:
      case ScenarioIriuOriginKind.rucnaStavka:
        if (hasScenarioIdentity) {
          throw const ScenarioPersistenceValidationException(
            'This STAVKA provenance origin must not carry scenario identity.',
          );
        }
    }
    for (final entry in <String, String?>{
      'moduleId': moduleId,
      'scenarioId': scenarioId,
      'ruleId': ruleId,
      'operationId': operationId,
    }.entries) {
      if (entry.value != null && entry.value!.trim().isEmpty) {
        throw ScenarioPersistenceValidationException(
          '${entry.key} must not be empty.',
        );
      }
    }
  }

  factory ScenarioIriuProvenance.fromJsonMap(Map<String, dynamic> json) {
    _assertSchema(json);
    _assertAllowedKeys(json, const {
      'schemaVersion',
      'iriuId',
      'origin',
      'moduleId',
      'scenarioId',
      'scenarioVersion',
      'ruleId',
      'operationId',
    }, 'STAVKA provenance');
    return ScenarioIriuProvenance(
      iriuId: _requiredPositiveIntValue(json, 'iriuId'),
      origin: ScenarioIriuOriginKindWire.fromWireName(
        _requiredTextValue(json, 'origin'),
      ),
      moduleId: _optionalTextValue(json, 'moduleId'),
      scenarioId: _optionalTextValue(json, 'scenarioId'),
      scenarioVersion: _optionalIntValue(json, 'scenarioVersion'),
      ruleId: _optionalTextValue(json, 'ruleId'),
      operationId: _optionalTextValue(json, 'operationId'),
    );
  }

  final int iriuId;
  final ScenarioIriuOriginKind origin;
  final String? moduleId;
  final String? scenarioId;
  final int? scenarioVersion;
  final String? ruleId;
  final String? operationId;

  Map<String, dynamic> toJsonMap() => {
    'schemaVersion': scenarioPersistenceSchemaVersion,
    'iriuId': iriuId,
    'origin': origin.wireName,
    if (moduleId != null) 'moduleId': moduleId,
    if (scenarioId != null) 'scenarioId': scenarioId,
    if (scenarioVersion != null) 'scenarioVersion': scenarioVersion,
    if (ruleId != null) 'ruleId': ruleId,
    if (operationId != null) 'operationId': operationId,
  };
}

class ScenarioPersistenceValidationException implements Exception {
  const ScenarioPersistenceValidationException(this.message);

  final String message;

  @override
  String toString() => 'ScenarioPersistenceValidationException: $message';
}

Map<String, dynamic> _scenarioToJson(ScenarioDefinition scenario) => {
  'id': scenario.id,
  'name': scenario.name,
  'condition': _conditionToJson(scenario.condition),
  'consequences': scenario.consequences.map(_consequenceToJson).toList(),
};

ScenarioDefinition _scenarioFromJson(Map<String, dynamic> json) {
  _assertAllowedKeys(json, const {
    'id',
    'name',
    'condition',
    'consequences',
  }, 'scenario definition');
  return ScenarioDefinition(
    id: _requiredTextValue(json, 'id'),
    name: _requiredTextValue(json, 'name'),
    condition: _conditionFromJson(_requiredMap(json, 'condition')),
    consequences: _requiredMapList(
      json,
      'consequences',
    ).map(_consequenceFromJson).toList(growable: false),
  );
}

Map<String, dynamic> _conditionToJson(ScenarioCondition condition) {
  switch (condition.kind) {
    case ScenarioConditionKind.all:
      return {
        'kind': 'ALL',
        'children': condition.children.map(_conditionToJson).toList(),
      };
    case ScenarioConditionKind.any:
      return {
        'kind': 'ANY',
        'children': condition.children.map(_conditionToJson).toList(),
      };
    case ScenarioConditionKind.criterion:
      final criterion = condition.criterion!;
      return {
        'kind': 'CRITERION',
        'field': _criterionFieldWireName(criterion.field),
        'operator': _criterionOperatorWireName(criterion.operator),
        'values': criterion.values,
      };
  }
}

ScenarioCondition _conditionFromJson(Map<String, dynamic> json) {
  final kind = _requiredTextValue(json, 'kind');
  switch (kind) {
    case 'ALL':
      _assertAllowedKeys(json, const {'kind', 'children'}, 'ALL condition');
      return ScenarioCondition.all(
        _requiredMapList(
          json,
          'children',
        ).map(_conditionFromJson).toList(growable: false),
      );
    case 'ANY':
      _assertAllowedKeys(json, const {'kind', 'children'}, 'ANY condition');
      return ScenarioCondition.any(
        _requiredMapList(
          json,
          'children',
        ).map(_conditionFromJson).toList(growable: false),
      );
    case 'CRITERION':
      _assertAllowedKeys(json, const {
        'kind',
        'field',
        'operator',
        'values',
      }, 'criterion condition');
      final fieldName = _requiredTextValue(json, 'field');
      final operatorName = _requiredTextValue(json, 'operator');
      final field = _criterionFieldFromWire(fieldName);
      final operator = _criterionOperatorFromWire(operatorName);
      return ScenarioCondition.criterion(
        ScenarioCriterion(
          field: field,
          operator: operator,
          values: _requiredStringList(json, 'values'),
        ),
      );
    default:
      throw const ScenarioPersistenceValidationException(
        'Unknown scenario condition kind.',
      );
  }
}

Map<String, dynamic> _consequenceToJson(ScenarioConsequence consequence) => {
  'katalogCategoryInternalName': consequence.katalogCategoryInternalName,
  'action': _consequenceActionWireName(consequence.action),
  'order': consequence.order,
};

ScenarioConsequence _consequenceFromJson(Map<String, dynamic> json) {
  _assertAllowedKeys(json, const {
    'katalogCategoryInternalName',
    'action',
    'order',
  }, 'scenario consequence');
  return ScenarioConsequence(
    katalogCategoryInternalName: _requiredTextValue(
      json,
      'katalogCategoryInternalName',
    ),
    action: _consequenceActionFromWire(_requiredTextValue(json, 'action')),
    order: _requiredIntValue(json, 'order'),
  );
}

void _assertSchema(Map<String, dynamic> json) {
  final value = json['schemaVersion'];
  if (value != scenarioPersistenceSchemaVersion) {
    throw const ScenarioPersistenceValidationException(
      'Unsupported scenario persistence schema version.',
    );
  }
}

String _hashPayload(Map<String, dynamic> payload) =>
    sha256.convert(utf8.encode(jsonEncode(_canonicalize(payload)))).toString();

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, dynamic>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is Iterable) return value.map(_canonicalize).toList();
  return value;
}

String _criterionFieldWireName(ScenarioCriterionField field) {
  switch (field) {
    case ScenarioCriterionField.mestoSmrti:
      return 'mestoSmrti';
    case ScenarioCriterionField.uzrokSmrti:
      return 'uzrokSmrti';
    case ScenarioCriterionField.vrstaCeremonije:
      return 'vrstaCeremonije';
    case ScenarioCriterionField.tipGroblja:
      return 'tipGroblja';
    case ScenarioCriterionField.grobnoMesto:
      return 'grobnoMesto';
    case ScenarioCriterionField.tipGrobnogMesta:
      return 'tipGrobnogMesta';
    case ScenarioCriterionField.sahranaVanSrbije:
      return 'sahranaVanSrbije';
    case ScenarioCriterionField.docekPosmrtnihOstataka:
      return 'docekPosmrtnihOstataka';
    case ScenarioCriterionField.opelo:
      return 'opelo';
  }
}

ScenarioCriterionField _criterionFieldFromWire(String value) {
  switch (value) {
    case 'mestoSmrti':
      return ScenarioCriterionField.mestoSmrti;
    case 'uzrokSmrti':
      return ScenarioCriterionField.uzrokSmrti;
    case 'vrstaCeremonije':
      return ScenarioCriterionField.vrstaCeremonije;
    case 'tipGroblja':
      return ScenarioCriterionField.tipGroblja;
    case 'grobnoMesto':
      return ScenarioCriterionField.grobnoMesto;
    case 'tipGrobnogMesta':
      return ScenarioCriterionField.tipGrobnogMesta;
    case 'sahranaVanSrbije':
      return ScenarioCriterionField.sahranaVanSrbije;
    case 'docekPosmrtnihOstataka':
      return ScenarioCriterionField.docekPosmrtnihOstataka;
    case 'opelo':
      return ScenarioCriterionField.opelo;
    default:
      throw const ScenarioPersistenceValidationException(
        'Unknown scenario condition field.',
      );
  }
}

String _criterionOperatorWireName(ScenarioCriterionOperator operator) {
  switch (operator) {
    case ScenarioCriterionOperator.equals:
      return 'equals';
    case ScenarioCriterionOperator.notEquals:
      return 'notEquals';
    case ScenarioCriterionOperator.inSet:
      return 'inSet';
    case ScenarioCriterionOperator.notInSet:
      return 'notInSet';
    case ScenarioCriterionOperator.isTrue:
      return 'isTrue';
    case ScenarioCriterionOperator.isFalse:
      return 'isFalse';
  }
}

ScenarioCriterionOperator _criterionOperatorFromWire(String value) {
  switch (value) {
    case 'equals':
      return ScenarioCriterionOperator.equals;
    case 'notEquals':
      return ScenarioCriterionOperator.notEquals;
    case 'inSet':
      return ScenarioCriterionOperator.inSet;
    case 'notInSet':
      return ScenarioCriterionOperator.notInSet;
    case 'isTrue':
      return ScenarioCriterionOperator.isTrue;
    case 'isFalse':
      return ScenarioCriterionOperator.isFalse;
    default:
      throw const ScenarioPersistenceValidationException(
        'Unknown scenario condition operator.',
      );
  }
}

ScenarioConsequenceAction _consequenceActionFromWire(String value) {
  switch (value) {
    case 'required':
      return ScenarioConsequenceAction.required;
    case 'recommended':
      return ScenarioConsequenceAction.recommended;
    case 'suppressed':
      return ScenarioConsequenceAction.suppressed;
    default:
      throw const ScenarioPersistenceValidationException(
        'Unknown scenario consequence action.',
      );
  }
}

String _consequenceActionWireName(ScenarioConsequenceAction action) {
  switch (action) {
    case ScenarioConsequenceAction.required:
      return 'required';
    case ScenarioConsequenceAction.recommended:
      return 'recommended';
    case ScenarioConsequenceAction.suppressed:
      return 'suppressed';
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
    throw ScenarioPersistenceValidationException(
      'Unknown field(s) in $description: ${unknown.join(', ')}.',
    );
  }
}

ScenarioDefinition _freezeScenario(ScenarioDefinition scenario) =>
    ScenarioDefinition(
      id: _requiredText(scenario.id, 'scenario.id'),
      name: _requiredText(scenario.name, 'scenario.name'),
      condition: _freezeCondition(scenario.condition),
      consequences: List<ScenarioConsequence>.unmodifiable(
        scenario.consequences
            .map(
              (consequence) => ScenarioConsequence(
                katalogCategoryInternalName: _requiredText(
                  consequence.katalogCategoryInternalName,
                  'scenario.consequences.katalogCategoryInternalName',
                ),
                action: consequence.action,
                order: consequence.order,
              ),
            )
            .toList(growable: false),
      ),
    );

ScenarioCondition _freezeCondition(ScenarioCondition condition) {
  switch (condition.kind) {
    case ScenarioConditionKind.all:
      return ScenarioCondition.all(
        List<ScenarioCondition>.unmodifiable(
          condition.children.map(_freezeCondition).toList(growable: false),
        ),
      );
    case ScenarioConditionKind.any:
      return ScenarioCondition.any(
        List<ScenarioCondition>.unmodifiable(
          condition.children.map(_freezeCondition).toList(growable: false),
        ),
      );
    case ScenarioConditionKind.criterion:
      final criterion = condition.criterion;
      if (criterion == null) {
        throw const ScenarioPersistenceValidationException(
          'Criterion condition must contain a criterion.',
        );
      }
      return ScenarioCondition.criterion(
        ScenarioCriterion(
          field: criterion.field,
          operator: criterion.operator,
          values: List<String>.unmodifiable(
            criterion.values
                .map(
                  (value) => _requiredText(
                    value,
                    'scenario.condition.criterion.values',
                  ),
                )
                .toList(growable: false),
          ),
        ),
      );
  }
}

String _requiredText(String value, String key) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ScenarioPersistenceValidationException('$key must not be empty.');
  }
  return normalized;
}

String? _optionalText(String? value, String key) {
  return value == null ? null : _requiredText(value, key);
}

int _requiredPositiveInt(int value, String key) {
  if (value <= 0) {
    throw ScenarioPersistenceValidationException('$key must be positive.');
  }
  return value;
}

Set<String> _validatedCategories(Set<String> values, String key) {
  final normalized = values.map((value) => value.trim()).toSet();
  if (normalized.any((value) => value.isEmpty)) {
    throw ScenarioPersistenceValidationException(
      '$key must contain only non-empty category IDs.',
    );
  }
  return normalized;
}

String _requiredTextValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw ScenarioPersistenceValidationException('$key must be text.');
  }
  return _requiredText(value, key);
}

int _requiredIntValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw ScenarioPersistenceValidationException('$key must be an integer.');
  }
  return value;
}

int _requiredPositiveIntValue(Map<String, dynamic> json, String key) =>
    _requiredPositiveInt(_requiredIntValue(json, key), key);

int? _optionalIntValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! int) {
    throw ScenarioPersistenceValidationException('$key must be an integer.');
  }
  return value;
}

int? _optionalPositiveIntValue(Map<String, dynamic> json, String key) {
  final value = _optionalIntValue(json, key);
  return value == null ? null : _requiredPositiveInt(value, key);
}

String? _optionalTextValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw ScenarioPersistenceValidationException('$key must be text.');
  }
  return _requiredText(value, key);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map<Object?, Object?>) {
    throw ScenarioPersistenceValidationException('$key must be an object.');
  }
  return value.map<String, dynamic>(
    (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
  );
}

List<Map<String, dynamic>> _requiredMapList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List || value.any((item) => item is! Map<Object?, Object?>)) {
    throw ScenarioPersistenceValidationException(
      '$key must be an object list.',
    );
  }
  return value
      .map((item) {
        final map = item as Map<Object?, Object?>;
        return map.map<String, dynamic>(
          (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
        );
      })
      .toList(growable: false);
}

List<String> _requiredStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List || value.any((item) => item is! String)) {
    throw ScenarioPersistenceValidationException('$key must be a text list.');
  }
  return value
      .cast<String>()
      .map((item) => _requiredText(item, key))
      .toList(growable: false);
}

Set<String> _requiredStringSet(Map<String, dynamic> json, String key) =>
    _validatedCategories(_requiredStringList(json, key).toSet(), key);
