import '../../../../core/database/database.dart';
import 'business_scenario_id.dart';

class BusinessPolicyDescriptor {
  const BusinessPolicyDescriptor({
    required this.id,
    required this.displayName,
    this.description,
  });

  final BusinessScenarioId id;
  final String displayName;
  final String? description;

  factory BusinessPolicyDescriptor.fromScenarioId(BusinessScenarioId id) {
    return BusinessPolicyDescriptor(
      id: id,
      displayName: id.displayName,
      description: id.description,
    );
  }
}

class PredmetBusinessPolicyInput {
  const PredmetBusinessPolicyInput({
    required this.predmetId,
    required this.brojPredmeta,
    required this.mestoSmrti,
    required this.uzrokSmrti,
    required this.vrstaCeremonije,
    required this.groblje,
    required this.tipGroblja,
    required this.tipGrobnogMesta,
    required this.sahranaVanSrbije,
    required this.docekPosmrtnihOstataka,
  });

  final int predmetId;
  final String brojPredmeta;
  final String mestoSmrti;
  final String uzrokSmrti;
  final String vrstaCeremonije;
  final String groblje;
  final String tipGroblja;
  final String tipGrobnogMesta;
  final bool sahranaVanSrbije;
  final bool docekPosmrtnihOstataka;

  factory PredmetBusinessPolicyInput.fromPredmet(PredmetiData predmet) {
    return PredmetBusinessPolicyInput(
      predmetId: predmet.id,
      brojPredmeta: predmet.brojPredmeta,
      mestoSmrti: predmet.mestoSmrti,
      uzrokSmrti: predmet.uzrokSmrti,
      vrstaCeremonije: predmet.vrstaCeremonije,
      groblje: predmet.groblje,
      tipGroblja: predmet.tipGroblja,
      tipGrobnogMesta: predmet.tipGrobnogMesta,
      sahranaVanSrbije: predmet.sahranaVanSrbije,
      docekPosmrtnihOstataka: predmet.docekPosmrtnihOstataka,
    );
  }
}

class PredmetBusinessPolicySnapshot {
  const PredmetBusinessPolicySnapshot({
    required this.policy,
    required this.input,
    required this.normalizedMestoSmrti,
    required this.isKremacija,
    required this.isHospitalDeath,
    required this.isLocalCemetery,
    required this.isGradskoCemetery,
    required this.isInternationalCase,
    required this.hasReceptionOfRemains,
    required this.hasUzrokSmrtiOverride,
    required this.requiresBiohazardPrecautions,
  });

  final BusinessPolicyDescriptor policy;
  final PredmetBusinessPolicyInput input;
  final String normalizedMestoSmrti;
  final bool isKremacija;
  final bool isHospitalDeath;
  final bool isLocalCemetery;
  final bool isGradskoCemetery;
  final bool isInternationalCase;
  final bool hasReceptionOfRemains;
  final bool hasUzrokSmrtiOverride;
  final bool requiresBiohazardPrecautions;
}
