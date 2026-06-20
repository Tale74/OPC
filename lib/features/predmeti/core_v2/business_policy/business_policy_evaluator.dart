import '../../../../core/database/database.dart';
import '../rules/iriu_truth_rules.dart';
import 'business_policy_models.dart';
import 'business_scenario_id.dart';

class BusinessPolicyEvaluator {
  const BusinessPolicyEvaluator({
    this.defaultScenario = BusinessScenarioId.defaultFuneralCeremonyPolicy,
  });

  final BusinessScenarioId defaultScenario;

  BusinessPolicyDescriptor get defaultPolicy =>
      BusinessPolicyDescriptor.fromScenarioId(defaultScenario);

  PredmetBusinessPolicySnapshot evaluateForIriuTruth(PredmetiData predmet) {
    return evaluateForPredmet(predmet);
  }

  PredmetBusinessPolicySnapshot evaluateForPredmet(PredmetiData predmet) {
    final scenario = _resolveScenarioForPredmet(predmet);
    return evaluate(
      policy: BusinessPolicyDescriptor.fromScenarioId(scenario),
      input: PredmetBusinessPolicyInput.fromPredmet(predmet),
    );
  }

  PredmetBusinessPolicySnapshot evaluate({
    required BusinessPolicyDescriptor policy,
    required PredmetBusinessPolicyInput input,
  }) {
    final normalizedMestoSmrti =
        IriuTruthRules.normalizeMestoSmrti(input.mestoSmrti);
    final isKremacija = input.vrstaCeremonije == 'KREMACIJA' ||
        input.vrstaCeremonije == 'KREMACIJA_EKSPRES';
    final isHospitalDeath = normalizedMestoSmrti == 'BOLNICA';
    final hasUzrokSmrtiOverride = const <String>{
      'NASILNA',
      'ZARAZNA',
      'NEDEFINISANA',
    }.contains(input.uzrokSmrti);

    return PredmetBusinessPolicySnapshot(
      policy: policy,
      input: input,
      normalizedMestoSmrti: normalizedMestoSmrti,
      isKremacija: isKremacija,
      isHospitalDeath: isHospitalDeath,
      isLocalCemetery: input.tipGroblja == 'LOKALNO',
      isGradskoCemetery: input.tipGroblja == 'GRADSKO',
      isInternationalCase: input.sahranaVanSrbije,
      hasReceptionOfRemains: input.docekPosmrtnihOstataka,
      hasUzrokSmrtiOverride: hasUzrokSmrtiOverride,
      requiresBiohazardPrecautions:
          input.uzrokSmrti == 'ZARAZNA' &&
              normalizedMestoSmrti.isNotEmpty &&
              normalizedMestoSmrti != 'BOLNICA',
    );
  }

  BusinessScenarioId _resolveScenarioForPredmet(PredmetiData predmet) {
    final value = predmet.businessScenarioId.trim();
    if (value.isEmpty) {
      return defaultScenario;
    }
    return BusinessScenarioId.fromValue(value);
  }
}
