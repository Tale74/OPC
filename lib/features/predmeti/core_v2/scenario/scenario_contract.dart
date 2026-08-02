import '../../../../core/database/database.dart';
import '../rules/iriu_truth_rules.dart';

enum ScenarioCriterionField {
  mestoSmrti,
  uzrokSmrti,
  vrstaCeremonije,
  tipGroblja,
  grobnoMesto,
  tipGrobnogMesta,
  sahranaVanSrbije,
  docekPosmrtnihOstataka,
  opelo,
}

enum ScenarioCriterionOperator {
  equals,
  notEquals,
  inSet,
  notInSet,
  isTrue,
  isFalse,
}

class ScenarioCriterion {
  const ScenarioCriterion({
    required this.field,
    required this.operator,
    this.values = const <String>[],
  });

  final ScenarioCriterionField field;
  final ScenarioCriterionOperator operator;
  final List<String> values;

  bool matches(PredmetiData predmet) {
    final actual = _valueFor(predmet);
    switch (operator) {
      case ScenarioCriterionOperator.equals:
        return values.length == 1 && actual == values.single;
      case ScenarioCriterionOperator.notEquals:
        return values.length == 1 && actual != values.single;
      case ScenarioCriterionOperator.inSet:
        return values.contains(actual);
      case ScenarioCriterionOperator.notInSet:
        return !values.contains(actual);
      case ScenarioCriterionOperator.isTrue:
        return actual == 'DA';
      case ScenarioCriterionOperator.isFalse:
        return actual == 'NE';
    }
  }

  String _valueFor(PredmetiData predmet) {
    switch (field) {
      case ScenarioCriterionField.mestoSmrti:
        return IriuTruthRules.normalizeMestoSmrti(predmet.mestoSmrti);
      case ScenarioCriterionField.uzrokSmrti:
        return predmet.uzrokSmrti.trim().toUpperCase();
      case ScenarioCriterionField.vrstaCeremonije:
        return predmet.vrstaCeremonije.trim().toUpperCase();
      case ScenarioCriterionField.tipGroblja:
        return predmet.tipGroblja.trim().toUpperCase();
      case ScenarioCriterionField.grobnoMesto:
        return predmet.grobnoMesto.trim().toUpperCase();
      case ScenarioCriterionField.tipGrobnogMesta:
        return predmet.tipGrobnogMesta.trim().toUpperCase();
      case ScenarioCriterionField.sahranaVanSrbije:
        return predmet.sahranaVanSrbije ? 'DA' : 'NE';
      case ScenarioCriterionField.docekPosmrtnihOstataka:
        return predmet.docekPosmrtnihOstataka ? 'DA' : 'NE';
      case ScenarioCriterionField.opelo:
        return predmet.opelo.trim().toUpperCase();
    }
  }
}

enum ScenarioConditionKind { all, any, criterion }

class ScenarioCondition {
  const ScenarioCondition.all(this.children)
    : kind = ScenarioConditionKind.all,
      criterion = null;

  const ScenarioCondition.any(this.children)
    : kind = ScenarioConditionKind.any,
      criterion = null;

  const ScenarioCondition.criterion(this.criterion)
    : kind = ScenarioConditionKind.criterion,
      children = const <ScenarioCondition>[];

  final ScenarioConditionKind kind;
  final List<ScenarioCondition> children;
  final ScenarioCriterion? criterion;

  bool matches(PredmetiData predmet) {
    switch (kind) {
      case ScenarioConditionKind.all:
        return children.every((condition) => condition.matches(predmet));
      case ScenarioConditionKind.any:
        return children.any((condition) => condition.matches(predmet));
      case ScenarioConditionKind.criterion:
        return criterion!.matches(predmet);
    }
  }
}

enum ScenarioConsequenceAction { required, recommended, suppressed }

enum ScenarioItemProvider { firma, drugaSluzba, samoNapomena, vanPaketaFirme }

enum ScenarioConditionChangeBehavior { obavestiIPrepustiOdluku }

class ScenarioConsequence {
  const ScenarioConsequence({
    required this.katalogCategoryInternalName,
    required this.action,
    this.order = 0,
    this.section = 2,
    this.provider = ScenarioItemProvider.firma,
    this.warning = '',
    this.reason = '',
    this.financiallyIncluded = true,
    this.conditionChangeBehavior =
        ScenarioConditionChangeBehavior.obavestiIPrepustiOdluku,
  });

  final String katalogCategoryInternalName;
  final ScenarioConsequenceAction action;
  final int order;
  final int section;
  final ScenarioItemProvider provider;
  final String warning;
  final String reason;
  final bool financiallyIncluded;
  final ScenarioConditionChangeBehavior conditionChangeBehavior;

  String get businessStatus => switch (action) {
    ScenarioConsequenceAction.required => 'AKTIVNO',
    ScenarioConsequenceAction.recommended => 'PREPORUČENO',
    ScenarioConsequenceAction.suppressed => 'NE PRIKAZUJE SE',
  };
}

class ScenarioDefinition {
  const ScenarioDefinition({
    required this.id,
    required this.name,
    required this.condition,
    required this.consequences,
    this.description = '',
  });

  final String id;
  final String name;
  final ScenarioCondition condition;
  final List<ScenarioConsequence> consequences;
  final String description;
}

class ScenarioPackageResolution {
  const ScenarioPackageResolution({
    required this.baseCategories,
    required this.scenarioCategories,
    required this.suppressedCategories,
  });

  final Set<String> baseCategories;
  final List<ScenarioConsequence> scenarioCategories;
  final Set<String> suppressedCategories;

  Set<String> get effectiveCategories => {
    ...baseCategories,
    for (final consequence in scenarioCategories)
      if (consequence.action != ScenarioConsequenceAction.suppressed)
        consequence.katalogCategoryInternalName,
  }..removeAll(suppressedCategories);
}

class ScenarioPackageResolver {
  const ScenarioPackageResolver();

  ScenarioPackageResolution resolve({
    required ScenarioDefinition scenario,
    required PredmetiData predmet,
    required Set<String> osnovniPaket,
  }) {
    if (!scenario.condition.matches(predmet)) {
      return ScenarioPackageResolution(
        baseCategories: Set<String>.unmodifiable(osnovniPaket),
        scenarioCategories: const <ScenarioConsequence>[],
        suppressedCategories: const <String>{},
      );
    }

    final sorted = scenario.consequences.toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
    return ScenarioPackageResolution(
      baseCategories: Set<String>.unmodifiable(osnovniPaket),
      scenarioCategories: List<ScenarioConsequence>.unmodifiable(sorted),
      suppressedCategories: Set<String>.unmodifiable(
        sorted
            .where(
              (consequence) =>
                  consequence.action == ScenarioConsequenceAction.suppressed,
            )
            .map((consequence) => consequence.katalogCategoryInternalName),
      ),
    );
  }
}
