import 'scenario_contract.dart';
import '../../../../core/database/database.dart';
import 'owner_scenario_policy_kernel.dart';

/// Jedini runtime evaluator SCENARIO modula.
///
/// Pravila dolaze iz [ScenarioDefinition] zapisa; ova klasa nema poslovne
/// kriterijume ugrađene u kodu.
class ScenarioRuleEngine {
  const ScenarioRuleEngine();

  ScenarioRuleEvaluation evaluate({
    required List<ScenarioDefinition> scenarios,
    required PredmetiData predmet,
    required Set<String> osnovniPaket,
  }) {
    final matched = <ScenarioDefinition>[];
    final consequences = <String, ScenarioConsequence>{};
    final sourceScenarioIds = <String, String>{};
    for (final scenario in scenarios) {
      if (!scenario.condition.matches(predmet)) continue;
      matched.add(scenario);
      for (final consequence in scenario.consequences) {
        final key = consequence.katalogCategoryInternalName;
        final previous = consequences[key];
        consequences[key] = previous == null
            ? consequence
            : _mergeConsequences(previous, consequence);
        sourceScenarioIds[key] = scenario.id;
      }
    }
    final suppressed = consequences.values
        .where((item) => item.action == ScenarioConsequenceAction.suppressed)
        .map((item) => item.katalogCategoryInternalName)
        .toSet();
    final scenarioCategories =
        consequences.values
            .where(
              (item) =>
                  !suppressed.contains(item.katalogCategoryInternalName) &&
                  item.provider != ScenarioItemProvider.samoNapomena &&
                  item.provider != ScenarioItemProvider.vanPaketaFirme,
            )
            .toList(growable: false)
          ..sort((a, b) => a.order.compareTo(b.order));
    final effective = <String>{
      ...osnovniPaket,
      ...scenarioCategories.map((item) => item.katalogCategoryInternalName),
    }..removeAll(suppressed);
    final decisions = <String, ScenarioConsequence>{};
    var baseOrder = 0;
    for (final category in osnovniPaket) {
      decisions[category] = ScenarioConsequence(
        katalogCategoryInternalName: category,
        action: ScenarioConsequenceAction.required,
        order: baseOrder++,
        section: 1,
        reason: 'Stavka pripada OSNOVNOM PAKETU.',
      );
    }
    decisions.addAll(consequences);
    return ScenarioRuleEvaluation(
      matchedScenarioIds: matched
          .map((item) => item.id)
          .toList(growable: false),
      baseCategories: Set.unmodifiable(osnovniPaket),
      scenarioCategories: List.unmodifiable(scenarioCategories),
      suppressedCategories: Set.unmodifiable(suppressed),
      effectiveCategories: Set.unmodifiable(effective),
      decisions: Map.unmodifiable(decisions),
      sourceScenarioIds: Map.unmodifiable(sourceScenarioIds),
    );
  }

  /// Converts the owner-kernel result into the materialization shape consumed
  /// by the IRiU repository. The kernel is the only business decision source.
  ScenarioRuleEvaluation fromOwnerKernel(OwnerScenarioResult result) {
    final decisions = <String, ScenarioConsequence>{};
    var baseOrder = 0;
    for (final category in result.baseCategories) {
      final action =
          result.baseActions[category] ?? ScenarioConsequenceAction.required;
      decisions[category] = ScenarioConsequence(
        katalogCategoryInternalName: category,
        action: action,
        order: baseOrder++,
        section: 1,
        reason: 'Stavka pripada OSNOVNOM PAKETU.',
      );
    }
    for (final consequence in result.consequences) {
      final previous = decisions[consequence.katalogCategoryInternalName];
      if (previous == null ||
          previous.action != ScenarioConsequenceAction.required) {
        decisions[consequence.katalogCategoryInternalName] = consequence;
      }
    }
    final sourceScenarioIds = <String, String>{
      for (final consequence in result.consequences)
        consequence.katalogCategoryInternalName: result.scenarioId ?? '',
    };
    return ScenarioRuleEvaluation(
      matchedScenarioIds: result.scenarioId == null
          ? const <String>[]
          : <String>[result.scenarioId!],
      baseCategories: result.baseCategories,
      scenarioCategories: result.consequences,
      suppressedCategories: const <String>{},
      effectiveCategories: result.effectiveCategories,
      decisions: Map.unmodifiable(decisions),
      sourceScenarioIds: Map.unmodifiable(sourceScenarioIds),
    );
  }

  ScenarioConsequence _mergeConsequences(
    ScenarioConsequence first,
    ScenarioConsequence second,
  ) {
    final action =
        first.action == ScenarioConsequenceAction.suppressed ||
            second.action == ScenarioConsequenceAction.suppressed
        ? ScenarioConsequenceAction.suppressed
        : first.action == ScenarioConsequenceAction.required ||
              second.action == ScenarioConsequenceAction.required
        ? ScenarioConsequenceAction.required
        : ScenarioConsequenceAction.recommended;
    return ScenarioConsequence(
      katalogCategoryInternalName: first.katalogCategoryInternalName,
      action: action,
      order: first.order < second.order ? first.order : second.order,
      section: first.section < second.section ? first.section : second.section,
      provider: second.provider,
      warning: [
        first.warning,
        second.warning,
      ].where((value) => value.trim().isNotEmpty).toSet().join(' '),
      reason: [
        first.reason,
        second.reason,
      ].where((value) => value.trim().isNotEmpty).toSet().join(' '),
      financiallyIncluded:
          first.financiallyIncluded && second.financiallyIncluded,
    );
  }
}

class ScenarioRuleEvaluation {
  const ScenarioRuleEvaluation({
    required this.matchedScenarioIds,
    required this.baseCategories,
    required this.scenarioCategories,
    required this.suppressedCategories,
    required this.effectiveCategories,
    required this.decisions,
    required this.sourceScenarioIds,
  });

  final List<String> matchedScenarioIds;
  final Set<String> baseCategories;
  final List<ScenarioConsequence> scenarioCategories;
  final Set<String> suppressedCategories;
  final Set<String> effectiveCategories;
  final Map<String, ScenarioConsequence> decisions;
  final Map<String, String> sourceScenarioIds;
}
