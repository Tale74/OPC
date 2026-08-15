import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/database/database.dart';
import '../../../../core/constants/iriu_constants.dart';
import 'scenario_contract.dart';
import 'owner_scenario_policy_kernel.dart';
import 'scenario_persistence_contract.dart';

/// Local persistence for the user-editable SCENARIO module.
///
/// The repository owns policy-definition persistence. Runtime materializes
/// the owner-kernel result through the PREDMET/IRiU path.
class ScenarioModuleRepository {
  ScenarioModuleRepository(
    this._db, {
    Future<String> Function(String)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const String moduleId = 'scenario';
  static const String moduleName = 'SCENARIO';
  static const Set<String> _legacyBundledIds = <String>{
    'MESTO_SMRTI_BLOK',
    'MESTO_SMRTI_BOLNICA',
    'OPREMA_PREMA_USLOVU',
  };
  static const List<String> _defaultOsnovniPaketOrder = <String>[
    IriuK.sanduk,
    IriuK.obelezje,
    IriuK.pokrovGarnitura,
    IriuK.peskirZaKrst,
    IriuK.posmrtneParte,
    IriuK.crnina,
    IriuK.agencijskeUsluge,
    IriuK.cvece,
    IriuK.cituljaP,
    IriuK.cituljaNo,
    IriuK.slika,
  ];

  static final Set<String> _defaultOsnovniPaket = Set<String>.unmodifiable(
    _defaultOsnovniPaketOrder,
  );

  /// Read-only fallback used by derived ordering before a PREDMET has an
  /// applied snapshot. It never creates or updates module rows.
  static Set<String> get defaultOsnovniPaket => _defaultOsnovniPaket;
  static List<String> get defaultOsnovniPaketOrder =>
      List<String>.unmodifiable(_defaultOsnovniPaketOrder);

  // The first editable SCENARIO implementation seeded these nine owner
  // categories.  This exact set is a known legacy default, not a user
  // decision; it is therefore safe to extend it to the current eleven-item
  // owner package.  Any other non-empty package remains user-owned.
  static const Set<String> _legacyDefaultOsnovniPaket = <String>{
    IriuK.sanduk,
    IriuK.obelezje,
    IriuK.pokrovGarnitura,
    IriuK.peskirZaKrst,
    IriuK.posmrtneParte,
    IriuK.crnina,
    IriuK.agencijskeUsluge,
    IriuK.cvece,
    IriuK.cituljaP,
  };
  static const Set<String> _legacyPlaceDefinitionIds = <String>{
    'STAN',
    'DOM_ZA_STARE',
    'PRIVATNA_BOLNICA',
    'DRUGO',
    'ULICA_JAVNO_MESTO',
  };
  static const Set<String> _legacyPlaceConsequenceIds = <String>{
    IriuK.hladnjaca,
    IriuK.spremaanjePokojnika,
    IriuK.iznosenje,
    IriuK.prevozDoHladnjace,
    IriuK.transportnaVreca,
    IriuK.prevozDoGroblja,
  };
  static const Set<String> _legacyBiohazardConsequenceIds = <String>{
    IriuK.spremaanjePokojnika,
    IriuK.hladnjaca,
    IriuK.iznosenje,
    IriuK.prevozDoHladnjace,
    IriuK.prevozDoGroblja,
    IriuK.limeniUlozak,
    IriuK.lemovanje,
    IriuK.transportnaVreca,
    IriuK.kompletZaOpelo,
    IriuK.cituljaNo,
    IriuK.slika,
  };

  final AppDatabase _db;
  final Future<String> Function(String) _loadAsset;

  Future<ScenarioModule> ensureModule() async {
    final existing = await (_db.select(
      _db.scenarioModules,
    )..where((row) => row.id.equals(moduleId))).getSingleOrNull();
    if (existing != null) return existing;
    final now = DateTime.now().toUtc().toIso8601String();
    await _db
        .into(_db.scenarioModules)
        .insert(
          ScenarioModulesCompanion.insert(
            id: moduleId,
            naziv: const Value(moduleName),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await (_db.select(
      _db.scenarioModules,
    )..where((row) => row.id.equals(moduleId))).getSingle());
  }

  /// Kreira početne scenarije kao podatke modula, samo kada je modul prazan.
  /// Posle toga korisničke izmene imaju punu prednost i ne prepisuju se.
  Future<ScenarioModule> ensureModuleAndDefaults() async {
    final module = await ensureModule();
    final existing = await getDefinitions();
    final hasLegacyPackage = _isLegacyDefaultPackage(readOsnovniPaket(module));
    final hasLegacyDefaults = existing.any(
      (record) => _legacyBundledIds.contains(record.id),
    );
    final hasCollapsedPlaceDefinition = existing.any(
      (record) =>
          record.id == 'DOM_ZA_STARE' &&
          (_definitionHasMestoValue(
                definitionFromRecord(record),
                'PRIVATNA BOLNICA',
              ) ||
              _definitionHasMestoValue(definitionFromRecord(record), 'DRUGO')),
    );
    if (existing.isNotEmpty &&
        !hasLegacyPackage &&
        !hasLegacyDefaults &&
        !hasCollapsedPlaceDefinition) {
      return _ensureOwnerMapDefinitions(module);
    }
    try {
      final bundled = await _readBundledDefaults();
      if (bundled.isEmpty) {
        if (readOsnovniPaket(module).isEmpty) {
          await saveOsnovniPaket(_defaultOsnovniPaket);
        }
        return _ensureOwnerMapDefinitions(await ensureModule());
      }
      await _db.transaction(() async {
        if (existing.isEmpty) {
          final package = readOsnovniPaket(module);
          if (package.isEmpty || _isLegacyDefaultPackage(package)) {
            await saveOsnovniPaket(_defaultOsnovniPaket);
          }
          await _saveMissingBundledDefaults(bundled, const <String>{});
        } else {
          await _migrateLegacyBundledDefinitions(
            existing: existing,
            bundled: bundled,
          );
        }
      });
    } on Object {
      // Nedostupan asset ne sme da blokira otvaranje PREDMETA; tada modul
      // ostaje prazan i korisnik može da ga popuni kroz UI.
    }
    if (readOsnovniPaket(module).isEmpty) {
      try {
        await saveOsnovniPaket(_defaultOsnovniPaket);
      } on Object {
        // KATALOG validation remains authoritative.
      }
    }
    return _ensureOwnerMapDefinitions(await ensureModule());
  }

  bool _isLegacyDefaultPackage(Set<String> package) =>
      package.length == _legacyDefaultOsnovniPaket.length &&
      package.containsAll(_legacyDefaultOsnovniPaket);

  /// Materializes the finite owner map as independent editable definitions.
  /// Existing records, including deliberate user edits and later versions,
  /// are never overwritten; only missing map keys are seeded.
  Future<ScenarioModule> _ensureOwnerMapDefinitions(
    ScenarioModule module,
  ) async {
    await _repairKnownOwnerMapProtectiveEquipmentGap();
    final existingIds = (await getDefinitions()).map((item) => item.id).toSet();
    final missing = const OwnerScenarioPolicyKernel()
        .allKeys()
        .where((key) => !existingIds.contains(key.stableId))
        .toList(growable: false);
    if (missing.isEmpty) {
      return (await (_db.select(
        _db.scenarioModules,
      )..where((row) => row.id.equals(moduleId))).getSingle());
    }
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      const kernel = OwnerScenarioPolicyKernel();
      for (final key in missing) {
        final definition = kernel.definitionForKey(key);
        final wire = scenarioDefinitionToJsonMap(definition);
        await _db
            .into(_db.scenarioDefinitions)
            .insertOnConflictUpdate(
              ScenarioDefinitionsCompanion.insert(
                id: definition.id,
                moduleId: moduleId,
                version: 1,
                status: const Value('PRIMENJEN'),
                naziv: Value(definition.name),
                conditionJson: Value(jsonEncode(wire['condition'])),
                consequencesJson: Value(jsonEncode(wire['consequences'])),
                jePodrazumevani: const Value(true),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });
    return (await (_db.select(
      _db.scenarioModules,
    )..where((row) => row.id.equals(moduleId))).getSingle());
  }

  /// Repairs only the exact version-1 system shape produced before the
  /// NASILNA protective-equipment omission was found. User-edited records do
  /// not match this fingerprint and are deliberately left untouched.
  Future<void> _repairKnownOwnerMapProtectiveEquipmentGap() async {
    const kernel = OwnerScenarioPolicyKernel();
    final records = (await getDefinitions())
        .where(
          (record) =>
              record.id.startsWith('MAP_NASILNA_') &&
              record.version == 1 &&
              record.jePodrazumevani,
        )
        .toList(growable: false);
    if (records.isEmpty) return;

    final keysById = <String, OwnerScenarioKey>{
      for (final key in kernel.allKeys()) key.stableId: key,
    };
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      for (final record in records) {
        final key = keysById[record.id];
        if (key == null) continue;
        final expected = kernel.definitionForKey(key);
        final expectedWire = scenarioDefinitionToJsonMap(expected);
        final actualWire = jsonDecode(record.consequencesJson);
        if (_canonicalJsonEncode(actualWire) ==
            _canonicalJsonEncode(expectedWire['consequences'])) {
          // The stored definition already equals the owner payload. This is
          // a real startup no-op: preserve both payload and updated_at.
          continue;
        }
        final expectedWithoutProtective = (expectedWire['consequences'] as List)
            .where(
              (item) =>
                  item['katalogCategoryInternalName'] !=
                  IriuK.zastitnaIDodatnaOprema,
            )
            .map(
              (item) => <String, Object?>{
                'katalogCategoryInternalName':
                    item['katalogCategoryInternalName'],
                'action': item['action'],
              },
            )
            .toList(growable: false);
        final actualConsequences = (jsonDecode(record.consequencesJson) as List)
            .whereType<Map<Object?, Object?>>()
            .map(
              (item) => <String, Object?>{
                'katalogCategoryInternalName':
                    item['katalogCategoryInternalName'],
                'action': item['action'],
              },
            )
            .toList(growable: false);
        final sameLegacyBusinessShape =
            actualConsequences.length == expectedWithoutProtective.length &&
            Iterable<int>.generate(actualConsequences.length).every(
              (index) =>
                  actualConsequences[index]['katalogCategoryInternalName'] ==
                      expectedWithoutProtective[index]['katalogCategoryInternalName'] &&
                  actualConsequences[index]['action'] ==
                      expectedWithoutProtective[index]['action'],
            );
        final isKnownSystemShape =
            // Only version-1 owner defaults are eligible. A user-edited MAP
            // remains protected by jePodrazumevani == false, even when its
            // consequence list intentionally differs from the owner kernel.
            record.jePodrazumevani && sameLegacyBusinessShape;
        if (!isKnownSystemShape) continue;

        await (_db.update(_db.scenarioDefinitions)..where(
              (item) =>
                  item.id.equals(record.id) &
                  item.version.equals(record.version),
            ))
            .write(
              ScenarioDefinitionsCompanion(
                consequencesJson: Value(
                  jsonEncode(expectedWire['consequences']),
                ),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  Future<List<_BundledScenarioSeed>> _readBundledDefaults() async {
    final decoded = jsonDecode(
      await _loadAsset('assets/scenario_defaults.json'),
    );
    if (decoded is! List) return const <_BundledScenarioSeed>[];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          final definition = scenarioDefinitionFromJsonMap({
            'id': map['id'],
            'name': map['naziv'],
            'description': map['opis'] ?? '',
            'condition': map['condition'],
            'consequences': map['consequences'],
          });
          return _BundledScenarioSeed(
            definition: definition,
            version: (map['version'] as num?)?.toInt() ?? 1,
            jePodrazumevani: map['jePodrazumevani'] == true,
          );
        })
        .toList(growable: false);
  }

  Future<void> _saveMissingBundledDefaults(
    List<_BundledScenarioSeed> bundled,
    Set<String> existingIds,
  ) async {
    for (final seed in bundled) {
      if (existingIds.contains(seed.definition.id)) continue;
      await _saveBundledSeed(seed);
    }
  }

  Future<void> _saveBundledSeed(_BundledScenarioSeed seed) => saveDefinition(
    id: seed.definition.id,
    version: seed.version,
    naziv: seed.definition.name,
    description: seed.definition.description,
    condition: seed.definition.condition,
    consequences: seed.definition.consequences,
    jePodrazumevani: seed.jePodrazumevani,
    status: 'PRIMENJEN',
  );

  Future<void> _migrateLegacyBundledDefinitions({
    required List<ScenarioDefinitionRecord> existing,
    required List<_BundledScenarioSeed> bundled,
  }) async {
    final byId = <String, ScenarioDefinitionRecord>{
      for (final record in existing) record.id: record,
    };
    final existingIds = byId.keys.toSet();
    final bundledById = <String, _BundledScenarioSeed>{
      for (final seed in bundled) seed.definition.id: seed,
    };

    await _repairKnownLegacyDefaultDefinitions(
      existing: existing,
      bundledById: bundledById,
    );

    await _splitLegacyDefinition(
      legacy: byId['MESTO_SMRTI_BLOK'],
      targetIds: const <String>[
        'STAN',
        'DOM_ZA_STARE',
        'PRIVATNA_BOLNICA',
        'DRUGO',
        'ULICA_JAVNO_MESTO',
      ],
      existingIds: existingIds,
      bundledById: bundledById,
    );
    await _splitLegacyDefinition(
      legacy: byId['MESTO_SMRTI_BOLNICA'],
      targetIds: const <String>['BOLNICA'],
      existingIds: existingIds,
      bundledById: bundledById,
    );
    await _splitLegacyDefinition(
      legacy: byId['OPREMA_PREMA_USLOVU'],
      targetIds: const <String>['LIMENI_ULOZAK', 'LEMOVANJE'],
      existingIds: existingIds,
      bundledById: bundledById,
      splitConsequencesByTarget: true,
    );

    final collapsedDom = byId['DOM_ZA_STARE'];
    final domSeed = bundledById['DOM_ZA_STARE'];
    if (collapsedDom != null && domSeed != null) {
      final legacyRecord = collapsedDom;
      final seed = domSeed;
      final legacyDefinition = definitionFromRecord(legacyRecord);
      final isCollapsed =
          _definitionHasMestoValue(legacyDefinition, 'PRIVATNA BOLNICA') ||
          _definitionHasMestoValue(legacyDefinition, 'DRUGO');
      if (isCollapsed) {
        await _splitLegacyDefinition(
          legacy: legacyRecord,
          targetIds: const <String>['PRIVATNA_BOLNICA', 'DRUGO'],
          existingIds: existingIds,
          bundledById: bundledById,
        );
        await saveDefinition(
          id: legacyRecord.id,
          version: seed.version,
          naziv: seed.definition.name,
          description: seed.definition.description,
          condition: seed.definition.condition,
          consequences: legacyDefinition.consequences,
          jePodrazumevani: legacyRecord.jePodrazumevani,
          status: legacyRecord.status,
          allowBaseOverlap: true,
        );
        existingIds.add(legacyRecord.id);
      }
    }

    await _saveMissingBundledDefaults(bundled, existingIds);
    for (final legacyId in _legacyBundledIds) {
      final record = byId[legacyId];
      if (record != null) await deleteDefinition(record.id, record.version);
    }
    final package = readOsnovniPaket(await ensureModule());
    if (package.isEmpty || _isLegacyDefaultPackage(package)) {
      await saveOsnovniPaket(_defaultOsnovniPaket);
    }
  }

  Future<void> _repairKnownLegacyDefaultDefinitions({
    required List<ScenarioDefinitionRecord> existing,
    required Map<String, _BundledScenarioSeed> bundledById,
  }) async {
    for (final record in existing) {
      final seed = bundledById[record.id];
      if (seed == null ||
          !record.jePodrazumevani ||
          record.version != seed.version ||
          record.naziv != seed.definition.name) {
        continue;
      }
      final current = definitionFromRecord(record);
      final isKnownPlaceShape =
          _legacyPlaceDefinitionIds.contains(record.id) &&
          _sameCondition(current, seed.definition) &&
          _isLegacyPlaceDefinition(current);
      final isKnownBiohazardShape =
          record.id == 'BIOHAZARD' && _isLegacyBiohazardDefinition(current);
      if (!isKnownPlaceShape && !isKnownBiohazardShape) continue;

      // This is the exact shape emitted by the obsolete bundled migration:
      // it is not a user-authored edit. Restore only that known shape from
      // the current owner seed, while retaining status/default ownership.
      await saveDefinition(
        id: record.id,
        version: record.version,
        naziv: seed.definition.name,
        description: seed.definition.description,
        condition: seed.definition.condition,
        consequences: seed.definition.consequences,
        jePodrazumevani: record.jePodrazumevani,
        status: record.status,
      );
    }
  }

  bool _isLegacyPlaceDefinition(ScenarioDefinition definition) {
    if (definition.consequences.length != _legacyPlaceConsequenceIds.length) {
      return false;
    }
    return definition.consequences.every(
      (item) =>
          _legacyPlaceConsequenceIds.contains(
            item.katalogCategoryInternalName,
          ) &&
          item.action == ScenarioConsequenceAction.recommended &&
          item.order == 0 &&
          item.section == 2 &&
          item.provider == ScenarioItemProvider.firma &&
          item.warning.isEmpty &&
          item.reason.isEmpty &&
          item.financiallyIncluded &&
          item.conditionChangeBehavior ==
              ScenarioConditionChangeBehavior.obavestiIPrepustiOdluku,
    );
  }

  bool _isLegacyBiohazardDefinition(ScenarioDefinition definition) {
    final criterion = definition.condition.criterion;
    if (definition.condition.kind != ScenarioConditionKind.criterion ||
        criterion == null ||
        criterion.field != ScenarioCriterionField.uzrokSmrti ||
        criterion.operator != ScenarioCriterionOperator.equals ||
        criterion.values.length != 1 ||
        criterion.values.single != 'ZARAZNA' ||
        definition.consequences.length !=
            _legacyBiohazardConsequenceIds.length) {
      return false;
    }
    final expectedOrders = <String, int>{
      IriuK.spremaanjePokojnika: 50,
      IriuK.hladnjaca: 10,
      IriuK.iznosenje: 20,
      IriuK.prevozDoHladnjace: 30,
      IriuK.prevozDoGroblja: 40,
      IriuK.limeniUlozak: 50,
      IriuK.lemovanje: 60,
      IriuK.transportnaVreca: 70,
      IriuK.kompletZaOpelo: 80,
      IriuK.cituljaNo: 90,
      IriuK.slika: 100,
    };
    return definition.consequences.every(
      (item) =>
          _legacyBiohazardConsequenceIds.contains(
            item.katalogCategoryInternalName,
          ) &&
          item.action == ScenarioConsequenceAction.required &&
          item.order == expectedOrders[item.katalogCategoryInternalName] &&
          item.warning ==
              (item.katalogCategoryInternalName == IriuK.spremaanjePokojnika
                  ? 'Postupati prema merama zaštite za zaraznu bolest.'
                  : '') &&
          item.reason ==
              (item.katalogCategoryInternalName == IriuK.spremaanjePokojnika
                  ? 'Uzrok smrti je zarazan, a mesto smrti nije bolnica.'
                  : 'Ovaj scenario dodaje ${_displayNameForLegacyCategory(item.katalogCategoryInternalName)}.'),
    );
  }

  String _displayNameForLegacyCategory(String category) => switch (category) {
    IriuK.hladnjaca => 'Hladnjača',
    IriuK.iznosenje => 'Iznošenje',
    IriuK.prevozDoHladnjace => 'Prevoz do hladnjače',
    IriuK.prevozDoGroblja => 'Prevoz do groblja',
    IriuK.limeniUlozak => 'Limeni uložak',
    IriuK.lemovanje => 'Lemovanje',
    IriuK.transportnaVreca => 'Transportna vreća',
    IriuK.kompletZaOpelo => 'Komplet za opelo',
    IriuK.cituljaNo => 'Čitulja Novosti',
    IriuK.slika => 'Slika',
    _ => '',
  };

  bool _sameCondition(ScenarioDefinition left, ScenarioDefinition right) =>
      jsonEncode(scenarioDefinitionToJsonMap(left)['condition']) ==
      jsonEncode(scenarioDefinitionToJsonMap(right)['condition']);

  String _canonicalJsonEncode(Object? value) =>
      jsonEncode(_canonicalJson(value));

  Object? _canonicalJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: _canonicalJson(value[key]),
      };
    }
    if (value is Iterable) {
      return value.map(_canonicalJson).toList(growable: false);
    }
    return value;
  }

  Future<void> _splitLegacyDefinition({
    required ScenarioDefinitionRecord? legacy,
    required List<String> targetIds,
    required Set<String> existingIds,
    required Map<String, _BundledScenarioSeed> bundledById,
    bool splitConsequencesByTarget = false,
  }) async {
    if (legacy == null) return;
    final legacyDefinition = definitionFromRecord(legacy);
    for (final targetId in targetIds) {
      if (existingIds.contains(targetId)) continue;
      final seed = bundledById[targetId];
      if (seed == null) continue;
      final consequences = splitConsequencesByTarget
          ? legacyDefinition.consequences
                .where((item) => item.katalogCategoryInternalName == targetId)
                .toList(growable: false)
          : legacyDefinition.consequences;
      await saveDefinition(
        id: targetId,
        version: seed.version,
        naziv: seed.definition.name,
        description: seed.definition.description,
        condition: seed.definition.condition,
        consequences: consequences,
        jePodrazumevani: legacy.jePodrazumevani,
        status: legacy.status,
        allowBaseOverlap: true,
      );
      existingIds.add(targetId);
    }
  }

  Future<List<ScenarioDefinition>> getActiveDefinitions() async {
    final records = await getDefinitions();
    return records
        .where(
          (record) =>
              record.status == 'PRIMENJEN' && record.id.startsWith('MAP_'),
        )
        .map(definitionFromRecord)
        .toList(growable: false);
  }

  Stream<ScenarioModule?> watchModule() => (_db.select(
    _db.scenarioModules,
  )..where((row) => row.id.equals(moduleId))).watchSingleOrNull();

  Future<void> saveOsnovniPaket(Set<String> categoryIds) async {
    await ensureModule();
    final normalized = categoryIds.map((value) => value.trim()).toSet()
      ..removeWhere((value) => value.isEmpty);
    final catalogIds = (await (_db.select(
      _db.iriuKatalogConfig,
    )).get()).map((row) => row.interniNaziv).toSet();
    final missing = normalized.difference(catalogIds);
    if (missing.isNotEmpty) {
      throw ArgumentError(
        'Osnovni paket sadrži kategoriju koja ne postoji u KATALOGU: ${missing.first}.',
      );
    }
    final definitions = await getDefinitions();
    final usedByScenario = <String>{};
    for (final record in definitions) {
      usedByScenario.addAll(
        definitionFromRecord(
          record,
        ).consequences.map((item) => item.katalogCategoryInternalName),
      );
    }
    final conflict = normalized.intersection(usedByScenario);
    if (conflict.isNotEmpty) {
      throw ArgumentError(
        'Kategorija ${conflict.first} ne može istovremeno biti u OSNOVNOM PAKETU i dodatku scenarija. Uklonite je iz jednog paketa pa pokušajte ponovo.',
      );
    }
    // The caller supplies the configured package order. Preserve that order;
    // a universal concrete-category sequence is not business authority.
    final ordered = <String>[];
    final seen = <String>{};
    for (final value in categoryIds) {
      final normalizedValue = value.trim();
      if (normalizedValue.isEmpty || !normalized.contains(normalizedValue)) {
        continue;
      }
      if (seen.add(normalizedValue)) ordered.add(normalizedValue);
    }
    for (final value in normalized) {
      if (seen.add(value)) ordered.add(value);
    }
    await (_db.update(
      _db.scenarioModules,
    )..where((row) => row.id.equals(moduleId))).write(
      ScenarioModulesCompanion(
        osnovniPaketJson: Value(jsonEncode(ordered)),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  List<String> readOsnovniPaketOrder(ScenarioModule module) {
    final decoded = jsonDecode(module.osnovniPaketJson);
    if (decoded is! List) return const <String>[];
    final result = <String>[];
    final seen = <String>{};
    for (final value in decoded.whereType<String>()) {
      final normalized = value.trim();
      if (normalized.isNotEmpty && seen.add(normalized)) result.add(normalized);
    }
    return List<String>.unmodifiable(result);
  }

  Set<String> readOsnovniPaket(ScenarioModule module) {
    return readOsnovniPaketOrder(module).toSet();
  }

  Stream<List<ScenarioDefinitionRecord>> watchDefinitions() =>
      (_db.select(_db.scenarioDefinitions)
            ..where((row) => row.moduleId.equals(moduleId))
            ..orderBy([(row) => OrderingTerm.asc(row.naziv)]))
          .watch();

  Future<List<ScenarioDefinitionRecord>> getDefinitions() =>
      (_db.select(_db.scenarioDefinitions)
            ..where((row) => row.moduleId.equals(moduleId))
            ..orderBy([(row) => OrderingTerm.asc(row.naziv)]))
          .get();

  Future<void> saveDefinition({
    required String id,
    required int version,
    required String naziv,
    required ScenarioCondition condition,
    required List<ScenarioConsequence> consequences,
    String description = '',
    bool jePodrazumevani = false,
    String status = 'DRAFT',
    bool allowBaseOverlap = false,
  }) async {
    final normalizedId = id.trim();
    final normalizedName = naziv.trim();
    if (normalizedId.isEmpty || normalizedName.isEmpty || version <= 0) {
      throw ArgumentError('SCENARIO mora imati naziv, ID i pozitivnu verziju.');
    }
    _validateCondition(condition);
    final categories = <String, ScenarioConsequence>{};
    for (final consequence in consequences) {
      final category = consequence.katalogCategoryInternalName.trim();
      if (category.isEmpty) {
        throw ArgumentError('Svaka odluka mora koristiti stavku iz KATALOGA.');
      }
      final previous = categories[category];
      if (previous != null && previous.action != consequence.action) {
        throw ArgumentError(
          'Scenario daje suprotne odluke za istu stavku u istim okolnostima.',
        );
      }
      categories[category] = consequence;
    }
    await ensureModule();
    final existingCatalog = (await (_db.select(
      _db.iriuKatalogConfig,
    )).get()).map((item) => item.interniNaziv).toSet();
    final missing = categories.keys.where(
      (category) => !existingCatalog.contains(category),
    );
    if (missing.isNotEmpty) {
      throw ArgumentError('Stavka ${missing.first} ne postoji u KATALOGU.');
    }
    final module = await ensureModule();
    final osnovniPaket = readOsnovniPaket(module);
    final baseConflict = categories.keys.toSet().intersection(osnovniPaket);
    if (baseConflict.isNotEmpty && !allowBaseOverlap) {
      throw ArgumentError(
        'Kategorija ${baseConflict.first} je već u OSNOVNOM PAKETU i ne može biti dodatak scenarija. Uklonite je iz osnovnog paketa pa pokušajte ponovo.',
      );
    }
    final definition = ScenarioDefinition(
      id: normalizedId,
      name: normalizedName,
      condition: condition,
      consequences: List<ScenarioConsequence>.unmodifiable(consequences),
      description: description.trim(),
    );
    final wire = scenarioDefinitionToJsonMap(definition);
    final now = DateTime.now().toUtc().toIso8601String();
    await _db
        .into(_db.scenarioDefinitions)
        .insertOnConflictUpdate(
          ScenarioDefinitionsCompanion.insert(
            id: normalizedId,
            moduleId: moduleId,
            version: version,
            naziv: Value(normalizedName),
            conditionJson: Value(jsonEncode(wire['condition'])),
            consequencesJson: Value(jsonEncode(wire['consequences'])),
            jePodrazumevani: Value(jePodrazumevani),
            status: Value(status),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  ScenarioDefinition definitionFromRecord(ScenarioDefinitionRecord record) {
    final condition = jsonDecode(record.conditionJson);
    final consequences = jsonDecode(record.consequencesJson);
    return scenarioDefinitionFromJsonMap({
      'id': record.id,
      'name': record.naziv,
      'condition': condition,
      'consequences': consequences,
    });
  }

  Future<void> deleteDefinition(String id, int version) => (_db.delete(
    _db.scenarioDefinitions,
  )..where((row) => row.id.equals(id) & row.version.equals(version))).go();

  Future<void> setDefinitionInUse(
    ScenarioDefinitionRecord record,
    bool inUse,
  ) async {
    if (inUse) {
      final definition = definitionFromRecord(record);
      await saveDefinition(
        id: record.id,
        version: record.version,
        naziv: record.naziv,
        description: definition.description,
        condition: definition.condition,
        consequences: definition.consequences,
        jePodrazumevani: record.jePodrazumevani,
        status: 'PRIMENJEN',
      );
      return;
    }
    await (_db.update(_db.scenarioDefinitions)..where(
          (row) =>
              row.id.equals(record.id) & row.version.equals(record.version),
        ))
        .write(
          ScenarioDefinitionsCompanion(
            status: const Value('NEAKTIVAN'),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
  }

  void _validateCondition(ScenarioCondition condition) {
    if (condition.kind == ScenarioConditionKind.criterion) {
      final criterion = condition.criterion;
      if (criterion == null) {
        throw ArgumentError('Scenario mora imati kriterijum primene.');
      }
      final needsValues =
          criterion.operator != ScenarioCriterionOperator.isTrue &&
          criterion.operator != ScenarioCriterionOperator.isFalse;
      if (needsValues &&
          criterion.values.every((value) => value.trim().isEmpty)) {
        throw ArgumentError('Scenario mora imati kriterijum primene.');
      }
      return;
    }
    if (condition.children.isEmpty) {
      throw ArgumentError('Scenario mora imati kriterijum primene.');
    }
    for (final child in condition.children) {
      _validateCondition(child);
    }
  }

  bool _definitionHasMestoValue(ScenarioDefinition definition, String value) {
    bool visit(ScenarioCondition condition) {
      if (condition.kind == ScenarioConditionKind.criterion) {
        final criterion = condition.criterion;
        return criterion?.field == ScenarioCriterionField.mestoSmrti &&
            criterion!.values
                .map((item) => item.trim().toUpperCase())
                .contains(value.toUpperCase());
      }
      return condition.children.any(visit);
    }

    return visit(definition.condition);
  }
}

class _BundledScenarioSeed {
  const _BundledScenarioSeed({
    required this.definition,
    required this.version,
    required this.jePodrazumevani,
  });

  final ScenarioDefinition definition;
  final int version;
  final bool jePodrazumevani;
}
