import '../../../../core/database/database.dart';

/// Eksplicitni poslovni koncepti koje novi core lane razlikuje za svaki IRIU red.
enum IriuTruthConcept {
  stored,
  active,
  recommended,
  suppressed,
}

/// Operativni status reda u core istini.
enum IriuOperationalState {
  active,
  suppressed,
}

/// Preporuka je namerno odvojena od stored/active stanja.
enum IriuRecommendationState {
  none,
  recommended,
}

/// Finansijska istina ne sme da zavisi od vizuelnog check-a ili derivata.
enum IriuFinancialState {
  counts,
  excludedSuppressed,
  excludedNonPositiveAmount,
}

/// Razlozi zbog kojih red može biti izostavljen iz nekog derivata,
/// bez menjanja core poslovne istine reda.
enum IriuDerivativeExclusion {
  notOperationallyActive,
  documentScopedOut,
}

/// Tip auto-upravljanja nad kategorijom.
enum IriuManagedKind {
  none,
  protectedAnchor,
  recommendedAutoManaged,
  conditionManagedOperational,
}

class IriuTruthRow {
  const IriuTruthRow({
    required this.storedRow,
    required this.truthOrder,
    required this.managedKind,
    required this.stored,
    required this.operationalState,
    required this.recommendationState,
    required this.biohazard,
    required this.financialState,
    required this.derivativeExclusions,
    required this.manualDeletionAllowed,
    required this.requiresUserResolution,
    required this.reasons,
  });

  final IriuData storedRow;
  final int truthOrder;
  final IriuManagedKind managedKind;
  final bool stored;
  final IriuOperationalState operationalState;
  final IriuRecommendationState recommendationState;
  final bool biohazard;
  final IriuFinancialState financialState;
  final Set<IriuDerivativeExclusion> derivativeExclusions;
  final bool manualDeletionAllowed;
  final bool requiresUserResolution;
  final List<String> reasons;

  bool get active => operationalState == IriuOperationalState.active;
  bool get recommended =>
      recommendationState == IriuRecommendationState.recommended;
  bool get suppressed => operationalState == IriuOperationalState.suppressed;
  bool get countsForFinancialTruth => financialState == IriuFinancialState.counts;
}

class PredmetIriuTruthSnapshot {
  const PredmetIriuTruthSnapshot({
    required this.predmet,
    required this.rows,
  });

  final PredmetiData predmet;
  final List<IriuTruthRow> rows;

  List<IriuTruthRow> get storedRows =>
      rows.where((row) => row.stored).toList(growable: false);

  List<IriuTruthRow> get activeRows =>
      rows.where((row) => row.active).toList(growable: false);

  List<IriuTruthRow> get recommendedRows =>
      rows.where((row) => row.recommended).toList(growable: false);

  List<IriuTruthRow> get financialRows => rows
      .where((row) => row.countsForFinancialTruth)
      .toList(growable: false);

  List<IriuTruthRow> get financialExcludedRows => rows
      .where((row) => !row.countsForFinancialTruth)
      .toList(growable: false);

  List<IriuTruthRow> rowsVisibleToDerivative({
    Set<IriuDerivativeExclusion> excludedReasons = const <IriuDerivativeExclusion>{},
  }) {
    return rows
        .where(
          (row) => row.derivativeExclusions.intersection(excludedReasons).isEmpty,
        )
        .toList(growable: false);
  }
}

class FinancialTruthLine {
  const FinancialTruthLine({
    required this.row,
    required this.amount,
  });

  final IriuTruthRow row;
  final double amount;
}

class FinancialTruthExclusion {
  const FinancialTruthExclusion({
    required this.row,
    required this.state,
    required this.reason,
  });

  final IriuTruthRow row;
  final IriuFinancialState state;
  final String reason;
}

class FinancialTruthBasis {
  const FinancialTruthBasis({
    required this.included,
    required this.excluded,
    required this.robaIUsluge,
  });

  final List<FinancialTruthLine> included;
  final List<FinancialTruthExclusion> excluded;
  final double robaIUsluge;
}
