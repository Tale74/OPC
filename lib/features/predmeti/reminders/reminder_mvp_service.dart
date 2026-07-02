import '../../../core/database/database.dart';
import '../../../core/format/app_date_format.dart';

class ReminderMvpEntry {
  const ReminderMvpEntry({
    required this.predmetId,
    required this.brojPredmeta,
    required this.ime,
    required this.prezime,
    required this.vrstaCeremonije,
    required this.datumCeremonije,
    required this.vremeCeremonije,
    required this.daysUntilCeremony,
  });

  final int predmetId;
  final String brojPredmeta;
  final String ime;
  final String prezime;
  final String vrstaCeremonije;
  final String datumCeremonije;
  final String vremeCeremonije;
  final int daysUntilCeremony;

  String get sessionKey => '$predmetId:$daysUntilCeremony';

  String get windowsLeadLabel => switch (daysUntilCeremony) {
    2 => 'ZA 2 DANA',
    1 => 'SUTRA',
    _ => 'DANAS',
  };

  DateTime? get parsedDate => parseDateValue(datumCeremonije);
}

class ReminderMvpService {
  ReminderMvpService();

  bool _isEligibleStatus(String status) =>
      status == 'OTVOREN' || status == 'ZATVOREN';

  DateTime? _ceremonyDate(PredmetiData predmet) =>
      parseDateValue(predmet.datumCeremonije);

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  List<ReminderMvpEntry> collectDueEntries(
    Iterable<PredmetiData> predmeti, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final entries = <ReminderMvpEntry>[];

    for (final predmet in predmeti) {
      if (!_isEligibleStatus(predmet.status)) continue;
      final ceremonyDate = _ceremonyDate(predmet);
      if (ceremonyDate == null) continue;

      final delta = _dateOnly(ceremonyDate).difference(today).inDays;
      if (delta < 0 || delta > 2) continue;

      entries.add(
        ReminderMvpEntry(
          predmetId: predmet.id,
          brojPredmeta: predmet.brojPredmeta,
          ime: predmet.ime,
          prezime: predmet.prezime,
          vrstaCeremonije: predmet.vrstaCeremonije,
          datumCeremonije: predmet.datumCeremonije,
          vremeCeremonije: predmet.vremeCeremonije,
          daysUntilCeremony: delta,
        ),
      );
    }

    entries.sort((a, b) {
      final byDays = a.daysUntilCeremony.compareTo(b.daysUntilCeremony);
      if (byDays != 0) return byDays;
      final byDate = (a.parsedDate ?? DateTime(9999)).compareTo(
        b.parsedDate ?? DateTime(9999),
      );
      if (byDate != 0) return byDate;
      return a.brojPredmeta.compareTo(b.brojPredmeta);
    });

    return entries;
  }
}
