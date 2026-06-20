import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../business_policy/business_policy_evaluator.dart';
import '../business_policy/business_policy_models.dart';
import '../models/iriu_truth_models.dart';
import '../rules/iriu_truth_rules.dart';

class PredmetIriuTruthService {
  const PredmetIriuTruthService({
    BusinessPolicyEvaluator businessPolicyEvaluator =
        const BusinessPolicyEvaluator(),
  }) : _businessPolicyEvaluator = businessPolicyEvaluator;

  final BusinessPolicyEvaluator _businessPolicyEvaluator;

  PredmetIriuTruthSnapshot evaluate({
    required PredmetiData predmet,
    required List<IriuData> storedRows,
  }) {
    final context = _PredmetIriuTruthEvaluationContext(
      predmet: predmet,
      policySnapshot: _businessPolicyEvaluator.evaluateForIriuTruth(predmet),
    );
    final normalizedMestoSmrti = _normalizedMestoSmrtiForIriuTruth(context);
    final requiresBiohazardPrecautions =
        _requiresBiohazardPrecautionsForIriuTruth(context);
    final hasReceptionOfRemains =
        _hasReceptionOfRemainsForIriuTruth(context);
    final isInternationalCase =
        _isInternationalCaseForIriuTruth(context);
    final isLocalCemetery =
        _isLocalCemeteryForIriuTruth(context);
    final isKremacija = _isKremacijaForIriuTruth(context);
    final isHospitalDeath = _isHospitalDeathForIriuTruth(context);
    final rows = storedRows
        .map(
          (row) => _evaluateRow(
            context: context,
            row: row,
            normalizedMestoSmrti: normalizedMestoSmrti,
            requiresBiohazardPrecautions: requiresBiohazardPrecautions,
            hasReceptionOfRemains: hasReceptionOfRemains,
            isInternationalCase: isInternationalCase,
            isLocalCemetery: isLocalCemetery,
            isKremacija: isKremacija,
            isHospitalDeath: isHospitalDeath,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.truthOrder.compareTo(b.truthOrder));

    return PredmetIriuTruthSnapshot(
      predmet: context.predmet,
      rows: rows,
    );
  }

  IriuTruthRow _evaluateRow({
    required _PredmetIriuTruthEvaluationContext context,
    required IriuData row,
    required String normalizedMestoSmrti,
    required bool requiresBiohazardPrecautions,
    required bool hasReceptionOfRemains,
    required bool isInternationalCase,
    required bool isLocalCemetery,
    required bool isKremacija,
    required bool isHospitalDeath,
  }) {
    assert(
      normalizedMestoSmrti == context.policySnapshot.normalizedMestoSmrti,
      'PredmetIriuTruthService must pass through the snapshot-normalized '
      'mestoSmrti unchanged during the no-output-change migration phase.',
    );
    assert(
      requiresBiohazardPrecautions ==
          context.policySnapshot.requiresBiohazardPrecautions,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'BIOHAZARD precondition unchanged during the no-output-change migration '
      'phase.',
    );
    assert(
      hasReceptionOfRemains == context.policySnapshot.hasReceptionOfRemains,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'reception-of-remains precondition unchanged during the '
      'no-output-change migration phase.',
    );
    assert(
      isInternationalCase == context.policySnapshot.isInternationalCase,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'international-case precondition unchanged during the no-output-change '
      'migration phase.',
    );
    assert(
      isLocalCemetery == context.policySnapshot.isLocalCemetery,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'local-cemetery precondition unchanged during the no-output-change '
      'migration phase.',
    );
    assert(
      isKremacija == context.policySnapshot.isKremacija,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'cremation precondition unchanged during the no-output-change '
      'migration phase.',
    );
    assert(
      isHospitalDeath == context.policySnapshot.isHospitalDeath,
      'PredmetIriuTruthService must pass through the snapshot-derived '
      'hospital-death precondition unchanged during the no-output-change '
      'migration phase.',
    );
    final predmet = context.predmet;
    final policy = IriuTruthRules.policyFor(row.interniNaziv);
    final active = IriuTruthRules.isOperationallyActive(
      predmet: predmet,
      row: row,
    );
    assert(
      row.interniNaziv != IriuK.cargoTroskovi || active == hasReceptionOfRemains,
      'cargoTroskovi operational activation must remain compatible with the '
      'snapshot reception-of-remains precondition during the no-output-change '
      'migration phase.',
    );
    assert(
      row.interniNaziv != IriuK.medjunarodniPrevoz ||
          active == isInternationalCase,
      'medjunarodniPrevoz operational activation must remain compatible with '
      'the snapshot international-case precondition during the '
      'no-output-change migration phase.',
    );
    assert(
      row.interniNaziv != IriuK.medjunarodnaDocumentacija ||
          active == isInternationalCase,
      'medjunarodnaDocumentacija operational activation must remain '
      'compatible with the snapshot international-case precondition during '
      'the no-output-change migration phase.',
    );
    assert(
      row.interniNaziv != IriuK.balsamovanje ||
          active == isInternationalCase,
      'balsamovanje operational activation must remain compatible with the '
      'snapshot international-case precondition during the no-output-change '
      'migration phase.',
    );
    assert(
      row.interniNaziv != IriuK.prevozSprovoda || active == isLocalCemetery,
      'prevozSprovoda operational activation must remain compatible with the '
      'snapshot local-cemetery precondition during the no-output-change '
      'migration phase.',
    );
    final recommended = IriuTruthRules.isRecommended(
      predmet: predmet,
      row: row,
    );
    assert(
      row.interniNaziv != IriuK.limeniUlozak || !isKremacija || !recommended,
      'limeniUlozak recommendation must remain excluded for cremation cases '
      'and compatible with the snapshot cremation precondition during the '
      'no-output-change migration phase.',
    );
    assert(
      row.interniNaziv != IriuK.lemovanje ||
          recommended ==
              _expectedLemovanjeRecommendationForIriuTruth(context),
      'lemovanje recommendation must remain compatible with locked Blok 2 '
      'rules during the no-output-change migration phase.',
    );
    final biohazard = IriuTruthRules.isBiohazard(
      predmet: predmet,
      row: row,
    );
    assert(
      !biohazard || requiresBiohazardPrecautions,
      'BIOHAZARD row activation must remain compatible with the snapshot '
      'precondition during the no-output-change migration phase.',
    );
    final financialCounts = IriuTruthRules.countsForFinancialTruth(
      predmet: predmet,
      row: row,
    );
    final derivativeExclusions = IriuTruthRules.derivativeExclusions(
      predmet: predmet,
      row: row,
    );

    final reasons = <String>[
      'stored row from persistent IRIU table',
      if (policy.protectedFirstInOrdering)
        'protected anchor category in truth ordering',
      if (policy.kind == IriuManagedKind.recommendedAutoManaged)
        'auto-managed recommendation, never mandatory',
      if (policy.kind == IriuManagedKind.conditionManagedOperational)
        'condition-managed operational category',
      if (!active)
        'stored row remains visible in core truth but is operationally suppressed',
      if (recommended)
        'current predmet conditions mark this row as recommended',
      if (biohazard)
        'current predmet conditions activate BIOHAZARD precautions for this row',
      if (!financialCounts && row.iznos <= 0)
        'excluded from financial truth because amount is non-positive',
      if (!financialCounts && !active)
        'excluded from financial truth because row is not operationally active',
    ];

    return IriuTruthRow(
      storedRow: row,
      truthOrder: IriuTruthRules.truthOrder(row),
      managedKind: policy.kind,
      stored: true,
      operationalState:
          active ? IriuOperationalState.active : IriuOperationalState.suppressed,
      recommendationState: recommended
          ? IriuRecommendationState.recommended
          : IriuRecommendationState.none,
      biohazard: biohazard,
      financialState: financialCounts
          ? IriuFinancialState.counts
          : row.iznos <= 0
              ? IriuFinancialState.excludedNonPositiveAmount
              : IriuFinancialState.excludedSuppressed,
      derivativeExclusions: derivativeExclusions,
      manualDeletionAllowed: policy.manualDeletionAllowed,
      requiresUserResolution:
          policy.requiresUserResolutionOnConditionChange && !active,
      reasons: List<String>.unmodifiable(reasons),
    );
  }

  String _normalizedMestoSmrtiForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final normalizedMestoSmrti = context.policySnapshot.normalizedMestoSmrti;
    assert(
      normalizedMestoSmrti ==
          IriuTruthRules.normalizeMestoSmrti(context.predmet.mestoSmrti),
      'BusinessPolicySnapshot normalizedMestoSmrti must stay aligned with '
      'IriuTruthRules.normalizeMestoSmrti(...) during the no-output-change '
      'migration phase.',
    );
    return normalizedMestoSmrti;
  }

  bool _requiresBiohazardPrecautionsForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final requiresBiohazardPrecautions =
        context.policySnapshot.requiresBiohazardPrecautions;
    final normalizedMestoSmrti =
        IriuTruthRules.normalizeMestoSmrti(context.predmet.mestoSmrti);
    assert(
      requiresBiohazardPrecautions ==
          (context.predmet.uzrokSmrti == 'ZARAZNA' &&
              normalizedMestoSmrti.isNotEmpty &&
              normalizedMestoSmrti != 'BOLNICA'),
      'BusinessPolicySnapshot requiresBiohazardPrecautions must stay aligned '
      'with the non-row BIOHAZARD precondition during the no-output-change '
      'migration phase.',
    );
    return requiresBiohazardPrecautions;
  }

  bool _hasReceptionOfRemainsForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final hasReceptionOfRemains =
        context.policySnapshot.hasReceptionOfRemains;
    assert(
      hasReceptionOfRemains == context.predmet.docekPosmrtnihOstataka,
      'BusinessPolicySnapshot hasReceptionOfRemains must stay aligned with '
      'the legacy reception-of-remains source condition during the '
      'no-output-change migration phase.',
    );
    return hasReceptionOfRemains;
  }

  bool _isInternationalCaseForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final isInternationalCase = context.policySnapshot.isInternationalCase;
    assert(
      isInternationalCase == context.predmet.sahranaVanSrbije,
      'BusinessPolicySnapshot isInternationalCase must stay aligned with the '
      'legacy international-case source condition during the no-output-change '
      'migration phase.',
    );
    return isInternationalCase;
  }

  bool _isLocalCemeteryForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final isLocalCemetery = context.policySnapshot.isLocalCemetery;
    assert(
      isLocalCemetery == (context.predmet.tipGroblja == 'LOKALNO'),
      'BusinessPolicySnapshot isLocalCemetery must stay aligned with the '
      'legacy local-cemetery source condition during the no-output-change '
      'migration phase.',
    );
    return isLocalCemetery;
  }

  bool _isKremacijaForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final isKremacija = context.policySnapshot.isKremacija;
    assert(
      isKremacija ==
          (context.predmet.vrstaCeremonije == 'KREMACIJA' ||
              context.predmet.vrstaCeremonije == 'KREMACIJA_EKSPRES'),
      'BusinessPolicySnapshot isKremacija must stay aligned with the legacy '
      'cremation source condition during the no-output-change migration '
      'phase.',
    );
    return isKremacija;
  }

  bool _isHospitalDeathForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    final isHospitalDeath = context.policySnapshot.isHospitalDeath;
    assert(
      isHospitalDeath ==
          (IriuTruthRules.normalizeMestoSmrti(context.predmet.mestoSmrti) ==
              'BOLNICA'),
      'BusinessPolicySnapshot isHospitalDeath must stay aligned with the '
      'legacy hospital-death source condition during the no-output-change '
      'migration phase.',
    );
    return isHospitalDeath;
  }

  bool _expectedLemovanjeRecommendationForIriuTruth(
    _PredmetIriuTruthEvaluationContext context,
  ) {
    if (context.policySnapshot.isKremacija) {
      return false;
    }
    if (context.policySnapshot.hasUzrokSmrtiOverride) {
      return true;
    }
    return context.policySnapshot.input.tipGrobnogMesta == 'GROBNICA';
  }
}

class _PredmetIriuTruthEvaluationContext {
  const _PredmetIriuTruthEvaluationContext({
    required this.predmet,
    required this.policySnapshot,
  });

  final PredmetiData predmet;
  final PredmetBusinessPolicySnapshot policySnapshot;
}
