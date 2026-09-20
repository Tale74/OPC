import '../models/iriu_truth_models.dart';

/// Kanonski entry point za "ROBA I USLUGE" u novom core lane-u.
///
/// Pravilo u ovoj fazi:
/// - dokument-scope izuzeci ne utiču na finansijsku istinu
/// - suppressed ili neaktivni redovi ne ulaze u "ROBA I USLUGE"
/// - red bez pozitivnog iznosa ne ulazi u "ROBA I USLUGE"
class FinancialTruthService {
  const FinancialTruthService();

  /// Calculates the displayed receivable amount from its current finance
  /// inputs. The same calculation is used by FINANSIJE and PODSETNIK so the
  /// F-09 threshold cannot drift from the finance segment's displayed total.
  double calculateZaNaplatu({
    required double robaIUsluge,
    required double refundacijaPio,
    required double avans,
    required double troskoviJkp,
    required bool jkpPlacaSamostalno,
    required double popust,
  }) {
    final posleRefundacije = robaIUsluge - refundacijaPio;
    final ostatak = avans > 0 ? posleRefundacije - avans : posleRefundacije;
    final jkpDodatak = jkpPlacaSamostalno ? 0.0 : troskoviJkp;
    return ostatak + jkpDodatak - popust;
  }

  FinancialTruthBasis buildRobaIUsluge(PredmetIriuTruthSnapshot snapshot) {
    final included = <FinancialTruthLine>[];
    final excluded = <FinancialTruthExclusion>[];

    for (final row in snapshot.rows) {
      if (row.countsForFinancialTruth) {
        included.add(FinancialTruthLine(row: row, amount: row.storedRow.iznos));
        continue;
      }

      excluded.add(
        FinancialTruthExclusion(
          row: row,
          state: row.financialState,
          reason: _reasonFor(row),
        ),
      );
    }

    final robaIUsluge = included.fold<double>(
      0.0,
      (sum, line) => sum + line.amount,
    );

    return FinancialTruthBasis(
      included: List<FinancialTruthLine>.unmodifiable(included),
      excluded: List<FinancialTruthExclusion>.unmodifiable(excluded),
      robaIUsluge: robaIUsluge,
    );
  }

  String _reasonFor(IriuTruthRow row) {
    switch (row.financialState) {
      case IriuFinancialState.counts:
        return 'counts for financial truth';
      case IriuFinancialState.excludedSuppressed:
        return 'excluded because row is not operationally active';
      case IriuFinancialState.excludedNonPositiveAmount:
        return 'excluded because stored amount is not positive';
    }
  }
}
