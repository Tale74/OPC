import 'ceremony_reminder_model.dart';

const Set<String> urnaAshesCeremonyTypes = <String>{
  'KREMACIJA',
  'KREMACIJA_EKSPRES',
};

bool isUrnaAshesObligationRelevant({
  required String ceremonyType,
  required String placementType,
}) {
  final ceremony = ceremonyType.trim().toUpperCase();
  final placement = placementType.trim().toUpperCase();
  return urnaAshesCeremonyTypes.contains(ceremony) &&
      placement.isNotEmpty &&
      placement != 'NAKNADNO';
}

class UrnaAshesReminderOccurrence {
  const UrnaAshesReminderOccurrence({
    required this.scheduledAt,
    required this.notificationId,
  });

  final DateTime scheduledAt;
  final int notificationId;
}

String urnaAshesParentLabel(String placementType) =>
    placementType.trim().toUpperCase() == 'RASIPANJE_PEPELA'
        ? 'RASIPANJE PEPELA'
        : 'POLAGANJE URNE';

String urnaAshesNotificationTitle(String placementType) =>
    placementType.trim().toUpperCase() == 'RASIPANJE_PEPELA'
        ? 'PODSETNIK — RASIPANJE PEPELA'
        : 'PODSETNIK — POLAGANJE URNE';

/// The existing PODSETNIK delivery-time selection supplies the cadence. The
/// +3 date only gates the beginning of the repeating cycle.
List<UrnaAshesReminderOccurrence> buildUrnaAshesReminderOccurrences({
  required int predmetId,
  required DateTime ceremonyAt,
  required String ceremonyType,
  required String placementType,
  required CeremonyReminderConfig config,
  required DateTime now,
  required bool completed,
}) {
  if (completed ||
      !config.enabled ||
      !isUrnaAshesObligationRelevant(
        ceremonyType: ceremonyType,
        placementType: placementType,
      )) {
    return const <UrnaAshesReminderOccurrence>[];
  }

  final firstDay = DateTime(
    ceremonyAt.year,
    ceremonyAt.month,
    ceremonyAt.day,
  ).add(const Duration(days: 3));
  final startDay = now.isBefore(firstDay)
      ? firstDay
      : DateTime(now.year, now.month, now.day);
  final occurrences = <UrnaAshesReminderOccurrence>[];
  for (final time in config.normalizedDeliveryTimes) {
    final parts = time.split(':');
    var at = DateTime(
      startDay.year,
      startDay.month,
      startDay.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    occurrences.add(
      UrnaAshesReminderOccurrence(
        scheduledAt: at,
        notificationId: localUrnaAshesReminderNotificationId(predmetId, at),
      ),
    );
  }
  return occurrences;
}

DateTime? activeUrnaAshesReminderSlot({
  required DateTime ceremonyAt,
  required CeremonyReminderConfig config,
  required DateTime now,
  required String ceremonyType,
  required String placementType,
  required bool completed,
}) {
  if (completed ||
      !config.enabled ||
      !isUrnaAshesObligationRelevant(
        ceremonyType: ceremonyType,
        placementType: placementType,
      )) {
    return null;
  }
  final activation = DateTime(
    ceremonyAt.year,
    ceremonyAt.month,
    ceremonyAt.day,
  ).add(const Duration(days: 3));
  if (now.isBefore(activation)) return null;
  DateTime? latest;
  for (final time in config.normalizedDeliveryTimes) {
    final parts = time.split(':');
    final candidate = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (!candidate.isAfter(now) && (latest == null || candidate.isAfter(latest))) {
      latest = candidate;
    }
  }
  return latest;
}

int localUrnaAshesReminderNotificationId(int predmetId, DateTime scheduledAt) {
  var hash = 0x15f2a9 & predmetId;
  hash = 0x1fffffff & (hash * 31 + scheduledAt.millisecondsSinceEpoch);
  hash = 0x1fffffff & (hash * 31 + 0x55aa33);
  return hash;
}

String buildUrnaAshesReminderText({
  required String deceasedFirstName,
  required String deceasedLastName,
  required String placementType,
  required String urnaCemetery,
}) {
  final fullName = '$deceasedFirstName $deceasedLastName'.trim();
  final cemetery = urnaCemetery.trim();
  if (cemetery.isEmpty) return 'Groblje za polaganje urne nije uneto';
  final placement = placementType.trim().toUpperCase();
  if (placement == 'RASIPANJE_PEPELA') {
    return 'ZA $fullName ZAKAZATI RASIPANJE PEPELA NA $cemetery GROBLJU.';
  }
  return 'ZA $fullName ZAKAZATI POLAGANJE URNE U $placement NA $cemetery.';
}
