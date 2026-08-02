import 'scenario_contract.dart';
import 'scenario_persistence_contract.dart';
import '../../../../core/database/database.dart';

/// A read-only description of one materialized STAVKA and its ownership.
///
/// The planner treats a missing provenance row as protected legacy data. This
/// is deliberate: an unknown origin must never become an implicit delete
/// permission.
class ScenarioMaterializedStavka {
  const ScenarioMaterializedStavka({
    required this.iriuId,
    required this.kategorija,
    this.provenance,
  }) : assert(iriuId > 0);

  final int iriuId;
  final String kategorija;
  final ScenarioIriuProvenance? provenance;
}

enum ScenarioReconciliationOrigin { osnovniPaket, scenarioPaket }

class ScenarioReconciliationAdd {
  const ScenarioReconciliationAdd({
    required this.kategorija,
    required this.origin,
    this.ruleId,
  });

  final String kategorija;
  final ScenarioReconciliationOrigin origin;
  final String? ruleId;
}

class ScenarioReconciliationRemove {
  const ScenarioReconciliationRemove({
    required this.iriuId,
    required this.kategorija,
  });

  final int iriuId;
  final String kategorija;
}

class ScenarioReconciliationUpdate {
  const ScenarioReconciliationUpdate({
    required this.iriuId,
    required this.kategorija,
    required this.origin,
    this.ruleId,
  });

  final int iriuId;
  final String kategorija;
  final ScenarioReconciliationOrigin origin;
  final String? ruleId;
}

/// Pure result of comparing the selected SCENARIO package with materialized
/// STAVKE. Applying this result is intentionally a separate repository task.
class ScenarioReconciliationPlan {
  ScenarioReconciliationPlan({
    required this.moduleId,
    required this.scenarioId,
    required this.scenarioVersion,
    required this.matchesCondition,
    required Set<String> desiredCategories,
    required List<ScenarioReconciliationAdd> additions,
    required List<ScenarioReconciliationRemove> removals,
    required List<ScenarioReconciliationUpdate> updates,
  }) : desiredCategories = Set<String>.unmodifiable(desiredCategories),
       additions = List<ScenarioReconciliationAdd>.unmodifiable(additions),
       removals = List<ScenarioReconciliationRemove>.unmodifiable(removals),
       updates = List<ScenarioReconciliationUpdate>.unmodifiable(updates);

  final String moduleId;
  final String scenarioId;
  final int scenarioVersion;
  final bool matchesCondition;
  final Set<String> desiredCategories;
  final List<ScenarioReconciliationAdd> additions;
  final List<ScenarioReconciliationRemove> removals;
  final List<ScenarioReconciliationUpdate> updates;

  /// Any material consequence change requires a later user-facing notice.
  bool get requiresUserNotice =>
      additions.isNotEmpty || removals.isNotEmpty || updates.isNotEmpty;

  bool get isNoOp => !requiresUserNotice;
}

/// Determines the smallest safe set of changes for one PREDMET-owned
/// SCENARIO assignment. It never writes data and never removes RUČNA/LEGACY.
class ScenarioReconciliationPlanner {
  const ScenarioReconciliationPlanner({
    this.packageResolver = const ScenarioPackageResolver(),
  });

  final ScenarioPackageResolver packageResolver;

  ScenarioReconciliationPlan plan({
    required String moduleId,
    required ScenarioDefinition scenario,
    required int scenarioVersion,
    required Set<String> osnovniPaket,
    required PredmetiData predmet,
    required List<ScenarioMaterializedStavka> materializedStavke,
  }) {
    final normalizedModuleId = _requiredText(moduleId, 'moduleId');
    if (scenarioVersion <= 0) {
      throw ArgumentError.value(
        scenarioVersion,
        'scenarioVersion',
        'must be positive',
      );
    }

    final resolution = packageResolver.resolve(
      scenario: scenario,
      predmet: predmet,
      osnovniPaket: _normalizedSet(osnovniPaket),
    );
    final desired = <String, _DesiredCategory>{};
    final suppressed = resolution.suppressedCategories;

    final sortedBaseCategories = resolution.baseCategories.toList()..sort();
    for (final category in sortedBaseCategories) {
      final normalized = _requiredText(category, 'osnovniPaket category');
      if (!suppressed.contains(normalized)) {
        desired[normalized] = const _DesiredCategory(
          origin: ScenarioReconciliationOrigin.osnovniPaket,
        );
      }
    }

    var scenarioOrder = 0;
    for (final consequence in resolution.scenarioCategories) {
      final category = _requiredText(
        consequence.katalogCategoryInternalName,
        'scenario consequence category',
      );
      final ruleId = _ruleId(scenario.id, scenarioOrder, category);
      scenarioOrder++;
      if (consequence.action == ScenarioConsequenceAction.suppressed ||
          suppressed.contains(category) ||
          desired.containsKey(category)) {
        continue;
      }
      desired[category] = _DesiredCategory(
        origin: ScenarioReconciliationOrigin.scenarioPaket,
        ruleId: ruleId,
      );
    }

    final managedRows = materializedStavke
        .where((row) => _isManagedByModule(row.provenance, normalizedModuleId))
        .toList(growable: false);
    final existingByCategory = <String, List<ScenarioMaterializedStavka>>{};
    for (final row in managedRows) {
      final category = _requiredText(row.kategorija, 'materialized category');
      (existingByCategory[category] ??= <ScenarioMaterializedStavka>[]).add(
        row,
      );
    }

    final removals = <ScenarioReconciliationRemove>[];
    for (final row in managedRows) {
      final category = _requiredText(row.kategorija, 'materialized category');
      if (!desired.containsKey(category)) {
        removals.add(
          ScenarioReconciliationRemove(
            iriuId: row.iriuId,
            kategorija: category,
          ),
        );
      }
    }

    final additions = <ScenarioReconciliationAdd>[];
    final updates = <ScenarioReconciliationUpdate>[];
    for (final entry in desired.entries) {
      final rows = existingByCategory[entry.key] ?? const [];
      final expected = entry.value;
      if (rows.isEmpty) {
        additions.add(
          ScenarioReconciliationAdd(
            kategorija: entry.key,
            origin: expected.origin,
            ruleId: expected.ruleId,
          ),
        );
        continue;
      }
      for (final row in rows) {
        if (!_hasExpectedProvenance(
          row.provenance,
          normalizedModuleId,
          scenario.id,
          scenarioVersion,
          expected,
        )) {
          updates.add(
            ScenarioReconciliationUpdate(
              iriuId: row.iriuId,
              kategorija: entry.key,
              origin: expected.origin,
              ruleId: expected.ruleId,
            ),
          );
        }
      }
    }

    return ScenarioReconciliationPlan(
      moduleId: normalizedModuleId,
      scenarioId: scenario.id,
      scenarioVersion: scenarioVersion,
      matchesCondition: scenario.condition.matches(predmet),
      desiredCategories: desired.keys.toSet(),
      additions: additions,
      removals: removals,
      updates: updates,
    );
  }
}

class _DesiredCategory {
  const _DesiredCategory({required this.origin, this.ruleId});

  final ScenarioReconciliationOrigin origin;
  final String? ruleId;
}

String _requiredText(String value, String field) {
  final normalized = value.trim();
  if (normalized.isEmpty) throw ArgumentError('$field must not be empty.');
  return normalized;
}

Set<String> _normalizedSet(Set<String> values) => values
    .map((value) => value.trim())
    .where((value) => value.isNotEmpty)
    .toSet();

String _ruleId(String scenarioId, int index, String category) =>
    '$scenarioId#$index:$category';

bool _isManagedByModule(ScenarioIriuProvenance? provenance, String moduleId) {
  if (provenance == null || provenance.moduleId != moduleId) return false;
  return provenance.origin == ScenarioIriuOriginKind.osnovniPaket ||
      provenance.origin == ScenarioIriuOriginKind.scenarioPaket;
}

bool _hasExpectedProvenance(
  ScenarioIriuProvenance? provenance,
  String moduleId,
  String scenarioId,
  int scenarioVersion,
  _DesiredCategory expected,
) {
  if (provenance == null || provenance.moduleId != moduleId) return false;
  switch (expected.origin) {
    case ScenarioReconciliationOrigin.osnovniPaket:
      return provenance.origin == ScenarioIriuOriginKind.osnovniPaket &&
          provenance.scenarioId == null &&
          provenance.scenarioVersion == null &&
          provenance.ruleId == null;
    case ScenarioReconciliationOrigin.scenarioPaket:
      return provenance.origin == ScenarioIriuOriginKind.scenarioPaket &&
          provenance.scenarioId == scenarioId &&
          provenance.scenarioVersion == scenarioVersion &&
          provenance.ruleId == expected.ruleId;
  }
}
