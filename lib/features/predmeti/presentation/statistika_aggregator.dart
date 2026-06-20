import '../../../core/database/database.dart';
import '../statistika_v1/statistika_models.dart';

const _topKategorijaOrder = <String, int>{
  'SANDUK': 0,
  'OBELEZJE': 1,
  'POKROV_GARNITURA': 2,
  'CVECE': 3,
  'CITULJE': 4,
};

const _topKategorijaLabelByKey = <String, String>{
  'SANDUK': 'SANDUK',
  'OBELEZJE': 'OBELE\u017dJE',
  'POKROV_GARNITURA': 'POKROV GARNITURA',
  'CVECE': 'CVE\u0106E',
  'CITULJE': '\u010cITULJE',
};

class StatistikaDateRange {
  const StatistikaDateRange({
    required this.dateFrom,
    required this.dateTo,
  });

  final DateTime dateFrom;
  final DateTime dateTo;

  bool contains(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return !normalized.isBefore(dateFrom) && !normalized.isAfter(dateTo);
  }
}

class StatistikaSnapshot {
  const StatistikaSnapshot({
    required this.summary,
    required this.poSavetniku,
    required this.poVrstiCeremonije,
    required this.poMestuSmrti,
    required this.poMestuCeremonije,
    required this.topArtikliPoKategorijama,
  });

  final StatistikaSummary summary;
  final List<StatistikaBreakdownRow> poSavetniku;
  final List<StatistikaBreakdownRow> poVrstiCeremonije;
  final List<StatistikaBreakdownRow> poMestuSmrti;
  final List<StatistikaBreakdownRow> poMestuCeremonije;
  final List<StatistikaTopKategorijaSection> topArtikliPoKategorijama;
}

class StatistikaTopKategorijaSection {
  const StatistikaTopKategorijaSection({
    required this.kategorijaLabel,
    required this.rows,
  });

  final String kategorijaLabel;
  final List<StatistikaTopArtikalRow> rows;
}

class StatistikaSummary {
  const StatistikaSummary({
    required this.brojPredmeta,
    required this.ukupnaIriuVrednost,
    required this.prosecnaIriuVrednostPoPredmetu,
  });

  final int brojPredmeta;
  final double ukupnaIriuVrednost;
  final double prosecnaIriuVrednostPoPredmetu;
}

class StatistikaBreakdownRow {
  const StatistikaBreakdownRow({
    required this.label,
    required this.brojPredmeta,
    required this.ukupnaIriuVrednost,
    required this.prosecnaIriuVrednostPoPredmetu,
  });

  final String label;
  final int brojPredmeta;
  final double ukupnaIriuVrednost;
  final double prosecnaIriuVrednostPoPredmetu;
}

class StatistikaTopArtikalRow {
  const StatistikaTopArtikalRow({
    required this.label,
    required this.brojPredmeta,
  });

  final String label;
  final int brojPredmeta;
}

class StatistikaAggregator {
  const StatistikaAggregator();

  StatistikaSnapshot build({
    required StatistikaPeriodSnapshot source,
  }) {
    final savetnikPoId = <int, String>{
      for (final korisnik in source.korisnici)
        korisnik.id: _normalizedLabel(
          korisnik.imePrezime,
          fallback: 'Savetnik #${korisnik.id}',
        ),
    };
    final ukupnoPoPredmetu = <int, double>{
      for (final snapshot in source.predmeti)
        snapshot.predmet.id: snapshot.ukupnaAktivnaIriuVrednost,
    };
    final filtriraniPredmeti = source.predmeti
        .map((snapshot) => snapshot.predmet)
        .toList(growable: false);

    final ukupnaIriuVrednost = ukupnoPoPredmetu.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final brojPredmeta = filtriraniPredmeti.length;
    final prosecnaIriuVrednostPoPredmetu = brojPredmeta == 0
        ? 0.0
        : ukupnaIriuVrednost / brojPredmeta;

    return StatistikaSnapshot(
      summary: StatistikaSummary(
        brojPredmeta: brojPredmeta,
        ukupnaIriuVrednost: ukupnaIriuVrednost,
        prosecnaIriuVrednostPoPredmetu: prosecnaIriuVrednostPoPredmetu,
      ),
      poSavetniku: _buildBreakdown(
        filtriraniPredmeti,
        ukupnoPoPredmetu,
        labelForPredmet: (predmet) {
          final savetnikId = predmet.savetnikId;
          if (savetnikId == null) return 'Bez savetnika';
          return savetnikPoId[savetnikId] ?? 'Savetnik #$savetnikId';
        },
      ),
      poVrstiCeremonije: _buildBreakdown(
        filtriraniPredmeti,
        ukupnoPoPredmetu,
        labelForPredmet: (predmet) => _normalizedLabel(
          predmet.vrstaCeremonije,
          fallback: 'Nedefinisana vrsta ceremonije',
        ),
      ),
      poMestuSmrti: _buildBreakdown(
        filtriraniPredmeti,
        ukupnoPoPredmetu,
        labelForPredmet: (predmet) => _normalizedLabel(
          predmet.mestoSmrti,
          fallback: 'Nedefinisano mesto smrti',
        ),
      ),
      poMestuCeremonije: _buildBreakdown(
        filtriraniPredmeti,
        ukupnoPoPredmetu,
        labelForPredmet: (predmet) => _normalizedLabel(
          predmet.groblje,
          fallback: 'Nedefinisano mesto ceremonije',
        ),
      ),
      topArtikliPoKategorijama: _buildTopArtikliPoKategorijama(
        source.predmeti,
      ),
    );
  }

  List<StatistikaBreakdownRow> _buildBreakdown(
    List<PredmetiData> predmeti,
    Map<int, double> ukupnoPoPredmetu, {
    required String Function(PredmetiData predmet) labelForPredmet,
  }) {
    final grouped = <String, List<PredmetiData>>{};
    for (final predmet in predmeti) {
      final label = labelForPredmet(predmet);
      grouped.putIfAbsent(label, () => <PredmetiData>[]).add(predmet);
    }

    final rows = grouped.entries.map((entry) {
      final ukupno = entry.value.fold<double>(
        0,
        (sum, predmet) => sum + (ukupnoPoPredmetu[predmet.id] ?? 0),
      );
      final brojPredmeta = entry.value.length;
      return StatistikaBreakdownRow(
        label: entry.key,
        brojPredmeta: brojPredmeta,
        ukupnaIriuVrednost: ukupno,
        prosecnaIriuVrednostPoPredmetu:
            brojPredmeta == 0 ? 0.0 : ukupno / brojPredmeta,
      );
    }).toList(growable: false);

    rows.sort((a, b) {
      final totalCompare =
          b.ukupnaIriuVrednost.compareTo(a.ukupnaIriuVrednost);
      if (totalCompare != 0) return totalCompare;
      final countCompare = b.brojPredmeta.compareTo(a.brojPredmeta);
      if (countCompare != 0) return countCompare;
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return rows;
  }

  List<StatistikaTopKategorijaSection> _buildTopArtikliPoKategorijama(
    Iterable<StatistikaPredmetSnapshot> predmeti,
  ) {
    final grouped = <String, Map<String, _TopArtikalAccumulator>>{};

    for (final predmetSnapshot in predmeti) {
      final byOccurrenceInPredmet = <String, _ArtikalOccurrence>{};

      for (final truthRow in predmetSnapshot.truthSnapshot.activeRows) {
        final row = truthRow.storedRow;
        final kategorijaKey = _canonicalTopKategorijaKey(row.interniNaziv);
        if (kategorijaKey == null) continue;

        final normalizedLabel = _normalizeTopArtikalLabel(
          row.nazivPrikaz,
          fallback: row.interniNaziv,
          kategorijaKey: kategorijaKey,
        );
        final occurrenceKey =
            '$kategorijaKey|${normalizedLabel.identityKey}';
        byOccurrenceInPredmet.putIfAbsent(
          occurrenceKey,
          () => _ArtikalOccurrence(
            kategorijaKey: kategorijaKey,
            labelIdentityKey: normalizedLabel.identityKey,
            displayLabel: normalizedLabel.displayLabel,
            predmetId: predmetSnapshot.predmet.id,
          ),
        );
      }

      for (final occurrence in byOccurrenceInPredmet.values) {
        final kategorijaGroup = grouped.putIfAbsent(
          occurrence.kategorijaKey,
          () => <String, _TopArtikalAccumulator>{},
        );
        final current = kategorijaGroup[occurrence.labelIdentityKey];
        if (current == null) {
          kategorijaGroup[occurrence.labelIdentityKey] =
              _TopArtikalAccumulator(
            displayLabel: occurrence.displayLabel,
            predmetIds: <int>{occurrence.predmetId},
          );
        } else {
          current.predmetIds.add(occurrence.predmetId);
        }
      }
    }

    final sections = grouped.entries.map((entry) {
      final rows = entry.value.values
          .map(
            (artikal) => StatistikaTopArtikalRow(
              label: artikal.displayLabel,
              brojPredmeta: artikal.predmetIds.length,
            ),
          )
          .toList(growable: false);

      rows.sort((a, b) {
        final countCompare = b.brojPredmeta.compareTo(a.brojPredmeta);
        if (countCompare != 0) return countCompare;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });

      return StatistikaTopKategorijaSection(
        kategorijaLabel: _topKategorijaLabelByKey[entry.key] ?? entry.key,
        rows: rows.take(10).toList(growable: false),
      );
    }).toList(growable: false);

    sections.sort(
      (a, b) =>
          (_topKategorijaOrder[_canonicalTopKategorijaKey(a.kategorijaLabel)] ??
                  999)
              .compareTo(
        _topKategorijaOrder[_canonicalTopKategorijaKey(b.kategorijaLabel)] ??
            999,
      ),
    );
    return sections;
  }

  String? _canonicalTopKategorijaKey(String value) {
    switch (_normalizeIdentityToken(value)) {
      case 'SANDUK':
        return 'SANDUK';
      case 'OBELEZJE':
        return 'OBELEZJE';
      case 'POKROV_GARNITURA':
      case 'POKROV GARNITURA':
        return 'POKROV_GARNITURA';
      case 'CVECE':
        return 'CVECE';
      case 'CITULJA':
      case 'CITULJE':
      case 'CITULJA_POLITIKA':
      case 'CITULJA_NOVOSTI':
        return 'CITULJE';
    }
    return null;
  }

  _NormalizedTopArtikalLabel _normalizeTopArtikalLabel(
    String value, {
    required String fallback,
    required String kategorijaKey,
  }) {
    final candidate = _collapseWhitespace(value);
    final displayLabel =
        candidate.isEmpty ? _collapseWhitespace(fallback) : candidate;
    final identityKey = _normalizeIdentityToken(displayLabel);

    if (kategorijaKey == 'CITULJE' &&
        (identityKey == 'CITULJA' || identityKey == 'CITULJE')) {
      return const _NormalizedTopArtikalLabel(
        displayLabel: '\u010cITULJE',
        identityKey: 'CITULJE',
      );
    }

    if (identityKey == kategorijaKey) {
      return _NormalizedTopArtikalLabel(
        displayLabel: _topKategorijaLabelByKey[kategorijaKey] ?? displayLabel,
        identityKey: kategorijaKey,
      );
    }

    return _NormalizedTopArtikalLabel(
      displayLabel: displayLabel,
      identityKey: identityKey,
    );
  }

  String _normalizeIdentityToken(String value) {
    final normalizedWhitespace = _collapseWhitespace(value).toUpperCase();
    return normalizedWhitespace
        .replaceAll('\u0160', 'S')
        .replaceAll('\u0110', 'DJ')
        .replaceAll('\u017d', 'Z')
        .replaceAll('\u010c', 'C')
        .replaceAll('\u0106', 'C')
        .replaceAll('\u0161', 'S')
        .replaceAll('\u0111', 'DJ')
        .replaceAll('\u017e', 'Z')
        .replaceAll('\u010d', 'C')
        .replaceAll('\u0107', 'C');
  }

  String _collapseWhitespace(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizedLabel(
    String value, {
    required String fallback,
  }) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}

class _ArtikalOccurrence {
  const _ArtikalOccurrence({
    required this.kategorijaKey,
    required this.labelIdentityKey,
    required this.displayLabel,
    required this.predmetId,
  });

  final String kategorijaKey;
  final String labelIdentityKey;
  final String displayLabel;
  final int predmetId;
}

class _TopArtikalAccumulator {
  _TopArtikalAccumulator({
    required this.displayLabel,
    required this.predmetIds,
  });

  final String displayLabel;
  final Set<int> predmetIds;
}

class _NormalizedTopArtikalLabel {
  const _NormalizedTopArtikalLabel({
    required this.displayLabel,
    required this.identityKey,
  });

  final String displayLabel;
  final String identityKey;
}
