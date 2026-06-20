import '../../../core/database/database.dart';
import '../core_v2/models/iriu_truth_models.dart';

class StatistikaPredmetSnapshot {
  const StatistikaPredmetSnapshot({
    required this.predmet,
    required this.truthSnapshot,
    required this.ukupnaAktivnaIriuVrednost,
    required this.rawIriuRows,
  });

  final PredmetiData predmet;
  final PredmetIriuTruthSnapshot truthSnapshot;
  final double ukupnaAktivnaIriuVrednost;
  final List<IriuData> rawIriuRows;
}

class StatistikaPeriodSnapshot {
  const StatistikaPeriodSnapshot({
    required this.predmeti,
    required this.korisnici,
    required this.kataloskeKategorije,
  });

  final List<StatistikaPredmetSnapshot> predmeti;
  final List<KorisniciData> korisnici;
  final Map<String, String> kataloskeKategorije;

  Iterable<IriuData> get rawIriuRows =>
      predmeti.expand((snapshot) => snapshot.rawIriuRows);
}
