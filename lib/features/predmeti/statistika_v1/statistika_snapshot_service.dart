import '../../../core/database/database.dart';
import '../core_v2/services/financial_truth_service.dart';
import '../core_v2/services/predmet_iriu_truth_service.dart';
import 'statistika_models.dart';

class StatistikaSnapshotService {
  const StatistikaSnapshotService({
    PredmetIriuTruthService predmetIriuTruthService =
        const PredmetIriuTruthService(),
    FinancialTruthService financialTruthService =
        const FinancialTruthService(),
  })  : _predmetIriuTruthService = predmetIriuTruthService,
        _financialTruthService = financialTruthService;

  final PredmetIriuTruthService _predmetIriuTruthService;
  final FinancialTruthService _financialTruthService;

  StatistikaPeriodSnapshot buildPeriodSnapshot({
    required List<PredmetiData> predmeti,
    required List<IriuData> iriu,
    required List<KorisniciData> korisnici,
    required Map<String, String> kataloskeKategorije,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    final normalizedDateFrom =
        DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    final normalizedDateTo = DateTime(dateTo.year, dateTo.month, dateTo.day);
    final iriuByPredmetId = <int, List<IriuData>>{};
    for (final row in iriu) {
      iriuByPredmetId.putIfAbsent(row.predmetId, () => <IriuData>[]).add(row);
    }

    final predmetSnapshots = predmeti
        .where((predmet) {
          final parsed = DateTime.tryParse(predmet.datumKreiranja);
          if (parsed == null) return false;
          final normalized = DateTime(parsed.year, parsed.month, parsed.day);
          return !normalized.isBefore(normalizedDateFrom) &&
              !normalized.isAfter(normalizedDateTo);
        })
        .map((predmet) {
          final storedRows = List<IriuData>.unmodifiable(
            iriuByPredmetId[predmet.id] ?? const <IriuData>[],
          );
          final truthSnapshot = _predmetIriuTruthService.evaluate(
            predmet: predmet,
            storedRows: storedRows,
          );
          final financialTruth =
              _financialTruthService.buildRobaIUsluge(truthSnapshot);
          return StatistikaPredmetSnapshot(
            predmet: predmet,
            truthSnapshot: truthSnapshot,
            ukupnaAktivnaIriuVrednost: financialTruth.robaIUsluge,
            rawIriuRows: storedRows,
          );
        })
        .toList(growable: false);

    return StatistikaPeriodSnapshot(
      predmeti: predmetSnapshots,
      korisnici: List<KorisniciData>.unmodifiable(korisnici),
      kataloskeKategorije: Map<String, String>.unmodifiable(
        kataloskeKategorije,
      ),
    );
  }
}
