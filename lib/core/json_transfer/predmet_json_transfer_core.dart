import 'dart:convert';

const int predmetTransferSchemaVersion = 6;
const int maxSupportedPredmetTransferSchemaVersion = 7;
const int predmetTransferSchemaVersionWithConsequenceTransfer = 7;
const String predmetTransferFormat = 'OPC_PREDMET';
const String legacyBeleznicaTransferFormat = 'OPC_BELEZNICA';
const String stanjeRobeConsequenceTransferBlockKey =
    'stanjeRobeConsequenceTransfer';
const int stanjeRobeConsequenceTransferSchemaVersion = 1;
const String stanjeRobeConsequenceTransferPolicy =
    'single_predmet_unresolved_consequence_v1';
const String defaultPredmetBusinessScenarioId =
    'default_funeral_ceremony_policy';
const String defaultPredmetSourceIdentity = 'local_opc';
const String stanjeRobeInsufficientStockConsequenceType =
    'INSUFFICIENT_STOCK';
const String stanjeRobeUnresolvedConsequenceStatus = 'UNRESOLVED';

const Set<String> stanjeRobeConsequenceTransferCoveredCategories = {
  'SANDUK',
  'OBELEZJE',
  'POKROV_GARNITURA',
};

const Set<String> forbiddenStanjeRobeConsequenceTransferItemFields = {
  'id',
  'predmetId',
  'iriuId',
  'availableQuantityAtCreation',
  'shortageQuantityAtCreation',
  'resolvedAt',
  'resolvedReason',
  'warehouseQuantity',
  'warehouseQuantities',
  'trenutnaKolicina',
  'minimalnaKolicina',
  'stanjeRobeStavkaId',
  'appliedEffectId',
  'effectId',
  'effectStatus',
};

/// Pure candidate for the single-PREDMET JSON transfer boundary.
///
/// This file is intentionally not wired into runtime. It models the transfer
/// shape and validation seams so future work can compare it against the
/// current mixed UI/file/repository implementation without changing behavior.
abstract final class PredmetJsonTransferCore {
  static String encode(PredmetJsonTransferDocument document) {
    return const JsonEncoder.withIndent('  ').convert(document.toJsonMap());
  }

  static String encodeMap(Map<String, dynamic> jsonMap) {
    return encode(PredmetJsonTransferDocument.fromJsonMap(jsonMap));
  }

  static PredmetJsonTransferDocument decode(String jsonSource) {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! Map) {
      throw const PredmetJsonTransferValidationException(
        'PREDMET JSON transfer root must be an object.',
      );
    }

    return PredmetJsonTransferDocument.fromJsonMap(
      decoded.cast<String, dynamic>(),
    );
  }

  static void assertSupportedRootSchema(Map<String, dynamic> root) {
    final schemaVersion = root['schemaVersion'];
    if (schemaVersion is int &&
        schemaVersion > maxSupportedPredmetTransferSchemaVersion) {
      throw const PredmetJsonTransferValidationException(
        'PREDMET JSON transfer schema is newer than this candidate supports.',
      );
    }
  }

  static Map<String, dynamic> normalizePredmetImportMap({
    required Map<String, dynamic> predmet,
    required Map<String, dynamic> root,
  }) {
    final normalized = _copyJsonMap(predmet);
    final exportVerzija = root['exportVerzija'];
    if (exportVerzija is int) {
      normalized['exportVerzija'] = exportVerzija;
    } else {
      normalized.putIfAbsent('exportVerzija', () => 0);
    }
    normalized.putIfAbsent(
      'businessScenarioId',
      () => defaultPredmetBusinessScenarioId,
    );
    normalized.putIfAbsent('sourceIdentity', () => defaultPredmetSourceIdentity);
    normalized.putIfAbsent('createdByKorisnikId', () => null);
    normalized.putIfAbsent('lastBusinessModifiedByKorisnikId', () => null);
    normalized.putIfAbsent('lastBusinessModifiedAt', () => null);
    return normalized;
  }
}

class PredmetJsonTransferDocument {
  const PredmetJsonTransferDocument({
    required this.format,
    required this.schemaVersion,
    required this.entityType,
    required this.documentSourceIdentity,
    required this.encoding,
    required this.exportVerzija,
    required this.exportDatum,
    required this.sourceExpectations,
    required this.predmet,
    required this.iriu,
    required this.kontaktLica,
    this.consequenceTransfer,
  });

  factory PredmetJsonTransferDocument.fromJsonMap(Map<String, dynamic> root) {
    PredmetJsonTransferCore.assertSupportedRootSchema(root);

    final iriu = _optionalMapList(root, 'iriu');
    final rawConsequenceTransfer = root[stanjeRobeConsequenceTransferBlockKey];
    final consequenceTransfer = rawConsequenceTransfer == null
        ? null
        : StanjeRobeConsequenceTransferBlock.fromJsonMap(
            _castStringMap(
              rawConsequenceTransfer,
              stanjeRobeConsequenceTransferBlockKey,
            ),
            iriuRows: iriu
                .map(PredmetJsonIriuBoundary.fromJsonMap)
                .toList(growable: false),
          );

    return PredmetJsonTransferDocument(
      format: _optionalTrimmedNonEmptyString(root, 'format') ??
          legacyBeleznicaTransferFormat,
      schemaVersion: _optionalInt(root, 'schemaVersion'),
      entityType: _optionalTrimmedNonEmptyString(root, 'entityType') ??
          'PREDMET',
      documentSourceIdentity:
          _optionalTrimmedNonEmptyString(root, 'documentSourceIdentity') ??
              'PREDMET',
      encoding: _optionalTrimmedNonEmptyString(root, 'encoding') ?? 'utf-8',
      exportVerzija: _optionalInt(root, 'exportVerzija'),
      exportDatum: _optionalTrimmedNonEmptyString(root, 'exportDatum'),
      sourceExpectations: _optionalStringMap(root, 'sourceExpectations'),
      predmet: _castStringMap(root['predmet'], 'predmet'),
      iriu: iriu,
      kontaktLica: _optionalMapList(root, 'kontaktLica'),
      consequenceTransfer: consequenceTransfer,
    );
  }

  final String format;
  final int? schemaVersion;
  final String entityType;
  final String documentSourceIdentity;
  final String encoding;
  final int? exportVerzija;
  final String? exportDatum;
  final Map<String, dynamic> sourceExpectations;
  final Map<String, dynamic> predmet;
  final List<Map<String, dynamic>> iriu;
  final List<Map<String, dynamic>> kontaktLica;
  final StanjeRobeConsequenceTransferBlock? consequenceTransfer;

  bool get isCurrentPredmetFormat => format == predmetTransferFormat;

  bool get isLegacyPredmetFormat => format == legacyBeleznicaTransferFormat;

  String get brojPredmeta =>
      (predmet['brojPredmeta'] as String?)?.trim() ?? '';

  Map<String, dynamic> toJsonMap() {
    final map = <String, dynamic>{
      'format': format,
      if (schemaVersion != null) 'schemaVersion': schemaVersion,
      'entityType': entityType,
      'documentSourceIdentity': documentSourceIdentity,
      'encoding': encoding,
      if (exportVerzija != null) 'exportVerzija': exportVerzija,
      if (exportDatum != null) 'exportDatum': exportDatum,
      'sourceExpectations': _copyJsonMap(sourceExpectations),
      'predmet': _copyJsonMap(predmet),
      'iriu': iriu.map(_copyJsonMap).toList(growable: false),
      'kontaktLica': kontaktLica.map(_copyJsonMap).toList(growable: false),
    };

    final transfer = consequenceTransfer;
    if (transfer != null && transfer.items.isNotEmpty) {
      map[stanjeRobeConsequenceTransferBlockKey] = transfer.toJsonMap();
    }

    return map;
  }
}

class PredmetJsonIriuBoundary {
  const PredmetJsonIriuBoundary({
    required this.interniNaziv,
    required this.katalogStableArticleId,
    required this.nazivPrikaz,
    required this.iznos,
  });

  factory PredmetJsonIriuBoundary.fromJsonMap(Map<String, dynamic> json) {
    return PredmetJsonIriuBoundary(
      interniNaziv: _optionalTrimmedNonEmptyString(json, 'interniNaziv'),
      katalogStableArticleId:
          _normalizeNullableStableArticleId(json['katalogStableArticleId']),
      nazivPrikaz: _optionalTrimmedNonEmptyString(json, 'nazivPrikaz'),
      iznos: _optionalFiniteNumber(json, 'iznos'),
    );
  }

  final String? interniNaziv;
  final String? katalogStableArticleId;
  final String? nazivPrikaz;
  final double? iznos;
}

class StanjeRobeConsequenceTransferBlock {
  const StanjeRobeConsequenceTransferBlock({
    required this.schemaVersion,
    required this.policy,
    required this.items,
  });

  factory StanjeRobeConsequenceTransferBlock.fromJsonMap(
    Map<String, dynamic> json, {
    List<PredmetJsonIriuBoundary> iriuRows = const [],
  }) {
    final schemaVersion = _requiredInt(
      json,
      'schemaVersion',
      stanjeRobeConsequenceTransferBlockKey,
    );
    if (schemaVersion > stanjeRobeConsequenceTransferSchemaVersion) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer schema is newer than supported.',
      );
    }
    if (schemaVersion != stanjeRobeConsequenceTransferSchemaVersion) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer schema is not recognized.',
      );
    }

    final policy = _requiredNonEmptyString(
      json,
      'policy',
      stanjeRobeConsequenceTransferBlockKey,
    );
    if (policy != stanjeRobeConsequenceTransferPolicy) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer policy is not supported.',
      );
    }

    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer items must be a list.',
      );
    }

    final items = rawItems.map((rawItem) {
      final item = StanjeRobeConsequenceTransferItem.fromJsonMap(
        _castStringMap(rawItem, stanjeRobeConsequenceTransferBlockKey),
      );
      if (iriuRows.isNotEmpty) {
        item.validateAgainstIriuRows(iriuRows);
      }
      return item;
    }).toList(growable: false);

    return StanjeRobeConsequenceTransferBlock(
      schemaVersion: schemaVersion,
      policy: policy,
      items: items,
    );
  }

  final int schemaVersion;
  final String policy;
  final List<StanjeRobeConsequenceTransferItem> items;

  Map<String, dynamic> toJsonMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'policy': policy,
      'items': items.map((item) => item.toJsonMap()).toList(growable: false),
    };
  }
}

class StanjeRobeConsequenceTransferItem {
  const StanjeRobeConsequenceTransferItem({
    required this.iriuTransferIndex,
    required this.kategorija,
    required this.katalogStableArticleId,
    required this.selectedNazivSnapshot,
    required this.selectedIznosSnapshot,
    required this.consequenceType,
    required this.status,
    required this.effectQuantity,
    this.sourceLifecycleEvent,
    this.createdAt,
    this.updatedAt,
  });

  factory StanjeRobeConsequenceTransferItem.fromJsonMap(
    Map<String, dynamic> json,
  ) {
    _rejectForbiddenStanjeRobeConsequenceFields(json);

    final kategorija = _requiredNonEmptyString(
      json,
      'kategorija',
      stanjeRobeConsequenceTransferBlockKey,
    );
    if (!stanjeRobeConsequenceTransferCoveredCategories.contains(kategorija)) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer category is not supported.',
      );
    }

    final item = StanjeRobeConsequenceTransferItem(
      iriuTransferIndex: _requiredInt(
        json,
        'iriuTransferIndex',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      kategorija: kategorija,
      katalogStableArticleId: _requiredNonEmptyString(
        json,
        'katalogStableArticleId',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      selectedNazivSnapshot: _requiredNonEmptyString(
        json,
        'selectedNazivSnapshot',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      selectedIznosSnapshot:
          _optionalFiniteNumber(json, 'selectedIznosSnapshot') ?? 0.0,
      consequenceType: _requiredNonEmptyString(
        json,
        'consequenceType',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      status: _requiredNonEmptyString(
        json,
        'status',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      effectQuantity: _requiredFiniteNumber(
        json,
        'effectQuantity',
        stanjeRobeConsequenceTransferBlockKey,
      ),
      sourceLifecycleEvent: _optionalTrimmedNonEmptyString(
        json,
        'sourceLifecycleEvent',
      ),
      createdAt: _optionalTrimmedNonEmptyString(json, 'createdAt'),
      updatedAt: _optionalTrimmedNonEmptyString(json, 'updatedAt'),
    );

    if (item.consequenceType != stanjeRobeInsufficientStockConsequenceType ||
        item.status != stanjeRobeUnresolvedConsequenceStatus ||
        item.effectQuantity != 1.0) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer item is not an active unit insufficient-stock consequence.',
      );
    }

    return item;
  }

  final int iriuTransferIndex;
  final String kategorija;
  final String katalogStableArticleId;
  final String selectedNazivSnapshot;
  final double selectedIznosSnapshot;
  final String consequenceType;
  final String status;
  final double effectQuantity;
  final String? sourceLifecycleEvent;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJsonMap() {
    return <String, dynamic>{
      'iriuTransferIndex': iriuTransferIndex,
      'kategorija': kategorija,
      'katalogStableArticleId': katalogStableArticleId,
      'selectedNazivSnapshot': selectedNazivSnapshot,
      'selectedIznosSnapshot': selectedIznosSnapshot,
      'consequenceType': consequenceType,
      'status': status,
      'effectQuantity': effectQuantity,
      if (sourceLifecycleEvent != null)
        'sourceLifecycleEvent': sourceLifecycleEvent,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  void validateAgainstIriuRows(List<PredmetJsonIriuBoundary> iriuRows) {
    if (iriuTransferIndex < 0 || iriuTransferIndex >= iriuRows.length) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer points to a missing IRIU row.',
      );
    }

    final iriuRow = iriuRows[iriuTransferIndex];
    if (iriuRow.interniNaziv != kategorija) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer category does not match IRIU.',
      );
    }
    if (iriuRow.katalogStableArticleId != katalogStableArticleId.trim()) {
      throw const PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer stable article id does not match IRIU.',
      );
    }
  }
}

class PredmetJsonTransferValidationException implements Exception {
  const PredmetJsonTransferValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _optionalStringMap(
  Map<String, dynamic> json,
  String key,
) {
  final raw = json[key];
  if (raw == null) return const <String, dynamic>{};
  return _castStringMap(raw, key);
}

List<Map<String, dynamic>> _optionalMapList(
  Map<String, dynamic> json,
  String key,
) {
  final raw = json[key];
  if (raw == null) return const <Map<String, dynamic>>[];
  if (raw is! List) {
    throw PredmetJsonTransferValidationException('$key must be a list.');
  }
  return raw
      .map((item) => _castStringMap(item, key))
      .toList(growable: false);
}

Map<String, dynamic> _castStringMap(Object? raw, String section) {
  if (raw is! Map) {
    throw PredmetJsonTransferValidationException('$section must be an object.');
  }
  return raw.cast<String, dynamic>();
}

int _requiredInt(
  Map<String, dynamic> json,
  String key,
  String section,
) {
  final value = json[key];
  if (value is int) return value;
  throw PredmetJsonTransferValidationException('$section.$key must be an int.');
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is int ? value : null;
}

String _requiredNonEmptyString(
  Map<String, dynamic> json,
  String key,
  String section,
) {
  final value = _optionalTrimmedNonEmptyString(json, key);
  if (value != null) return value;
  throw PredmetJsonTransferValidationException(
    '$section.$key must be a non-empty string.',
  );
}

String? _optionalTrimmedNonEmptyString(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _requiredFiniteNumber(
  Map<String, dynamic> json,
  String key,
  String section,
) {
  final value = _optionalFiniteNumber(json, key);
  if (value != null) return value;
  throw PredmetJsonTransferValidationException(
    '$section.$key must be a finite number.',
  );
}

double? _optionalFiniteNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite) return null;
  return value.toDouble();
}

String? _normalizeNullableStableArticleId(Object? stableArticleId) {
  if (stableArticleId is! String) return null;
  final normalized = stableArticleId.trim();
  return normalized.isEmpty ? null : normalized;
}

void _rejectForbiddenStanjeRobeConsequenceFields(
  Map<String, dynamic> itemMap,
) {
  for (final field in forbiddenStanjeRobeConsequenceTransferItemFields) {
    if (itemMap.containsKey(field)) {
      throw PredmetJsonTransferValidationException(
        'STANJE ROBE consequence transfer contains forbidden field: $field.',
      );
    }
  }
}

Map<String, dynamic> _copyJsonMap(Map<String, dynamic> value) {
  return value.map(
    (key, mapValue) => MapEntry(key, _copyJsonValue(mapValue)),
  );
}

Object? _copyJsonValue(Object? value) {
  if (value is Map) {
    return value.map(
      (key, mapValue) => MapEntry(key.toString(), _copyJsonValue(mapValue)),
    );
  }
  if (value is List) {
    return value.map(_copyJsonValue).toList(growable: false);
  }
  return value;
}
