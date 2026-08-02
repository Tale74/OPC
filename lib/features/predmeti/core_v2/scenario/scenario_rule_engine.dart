import 'scenario_contract.dart';
import '../../../../core/database/database.dart';

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
    for (final scenario in scenarios) {
      if (!scenario.condition.matches(predmet)) continue;
      matched.add(scenario);
      for (final consequence in scenario.consequences) {
        final previous = consequences[consequence.katalogCategoryInternalName];
        // Opoziv ima prednost nad ponudom iz drugog pravila.
        if (previous == null ||
            consequence.action == ScenarioConsequenceAction.suppressed) {
          consequences[consequence.katalogCategoryInternalName] = consequence;
        }
      }
    }
    final suppressed = consequences.values
        .where((item) => item.action == ScenarioConsequenceAction.suppressed)
        .map((item) => item.katalogCategoryInternalName)
        .toSet();
    final scenarioCategories =
        consequences.values
            .where(
              (item) => !suppressed.contains(item.katalogCategoryInternalName),
            )
            .toList(growable: false)
          ..sort((a, b) => a.order.compareTo(b.order));
    final effective = <String>{
      ...osnovniPaket,
      ...scenarioCategories.map((item) => item.katalogCategoryInternalName),
    }..removeAll(suppressed);
    return ScenarioRuleEvaluation(
      matchedScenarioIds: matched
          .map((item) => item.id)
          .toList(growable: false),
      baseCategories: Set.unmodifiable(osnovniPaket),
      scenarioCategories: List.unmodifiable(scenarioCategories),
      suppressedCategories: Set.unmodifiable(suppressed),
      effectiveCategories: Set.unmodifiable(effective),
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
  });

  final List<String> matchedScenarioIds;
  final Set<String> baseCategories;
  final List<ScenarioConsequence> scenarioCategories;
  final Set<String> suppressedCategories;
  final Set<String> effectiveCategories;
}
