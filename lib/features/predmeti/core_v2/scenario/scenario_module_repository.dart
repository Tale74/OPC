import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/database/database.dart';
import 'scenario_contract.dart';
import 'scenario_persistence_contract.dart';

/// Local persistence for the user-editable SCENARIO module.
///
/// This repository deliberately stops at module settings. It does not alter
/// PREDMET or IRIU rows; applying a scenario remains a separate, explicitly
/// authorized operation.
class ScenarioModuleRepository {
  ScenarioModuleRepository(
    this._db, {
    Future<String> Function(String)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const String moduleId = 'scenario';
  static const String moduleName = 'SCENARIO';

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
    if (existing.isNotEmpty) return module;
    try {
      final decoded = jsonDecode(
        await _loadAsset('assets/scenario_defaults.json'),
      );
      if (decoded is! List) return module;
      for (final raw in decoded.whereType<Map<String, dynamic>>()) {
        final map = Map<String, dynamic>.from(raw);
        await saveDefinition(
          id: map['id'] as String,
          version: (map['version'] as num?)?.toInt() ?? 1,
          naziv: map['naziv'] as String,
          condition: _conditionFromJson(
            Map<String, dynamic>.from(map['condition'] as Map),
          ),
          consequences: (map['consequences'] as List)
              .whereType<String>()
              .map(
                (name) => ScenarioConsequence(
                  katalogCategoryInternalName: name,
                  action: ScenarioConsequenceAction.recommended,
                ),
              )
              .toList(growable: false),
          jePodrazumevani: map['jePodrazumevani'] == true,
          status: 'PRIMENJEN',
        );
      }
    } on Object {
      // Nedostupan asset ne sme da blokira otvaranje PREDMETA; tada modul
      // ostaje prazan i korisnik može da ga popuni kroz UI.
    }
    return module;
  }

  Future<List<ScenarioDefinition>> getActiveDefinitions() async {
    final records = await getDefinitions();
    return records
        .where(
          (record) => record.jePodrazumevani && record.status != 'NEAKTIVAN',
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
    await (_db.update(
      _db.scenarioModules,
    )..where((row) => row.id.equals(moduleId))).write(
      ScenarioModulesCompanion(
        osnovniPaketJson: Value(jsonEncode(normalized.toList()..sort())),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  Set<String> readOsnovniPaket(ScenarioModule module) {
    final decoded = jsonDecode(module.osnovniPaketJson);
    if (decoded is! List) return <String>{};
    return decoded
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
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
    bool jePodrazumevani = false,
    String status = 'DRAFT',
  }) async {
    final normalizedId = id.trim();
    final normalizedName = naziv.trim();
    if (normalizedId.isEmpty || normalizedName.isEmpty || version <= 0) {
      throw ArgumentError('SCENARIO mora imati naziv, ID i pozitivnu verziju.');
    }
    await ensureModule();
    final definition = ScenarioDefinition(
      id: normalizedId,
      name: normalizedName,
      condition: condition,
      consequences: List<ScenarioConsequence>.unmodifiable(consequences),
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

  ScenarioCondition _conditionFromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String?;
    if (kind == 'criterion') {
      return ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.values.firstWhere(
            (value) => value.name == json['field'],
          ),
          operator: ScenarioCriterionOperator.values.firstWhere(
            (value) => value.name == json['operator'],
          ),
          values: (json['values'] as List? ?? const [])
              .whereType<String>()
              .toList(growable: false),
        ),
      );
    }
    final children = (json['children'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((child) => _conditionFromJson(Map<String, dynamic>.from(child)))
        .toList(growable: false);
    return kind == 'any'
        ? ScenarioCondition.any(children)
        : ScenarioCondition.all(children);
  }
}
