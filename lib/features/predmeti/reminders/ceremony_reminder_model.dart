class CeremonyReminderConfig {
  const CeremonyReminderConfig({this.enabled = true, this.frequencyHours = 24});

  static const allowedFrequencyHours = <int>[1, 2, 3, 4, 6, 8, 12, 24];

  final bool enabled;
  final int frequencyHours;

  CeremonyReminderConfig copyWith({bool? enabled, int? frequencyHours}) {
    return CeremonyReminderConfig(
      enabled: enabled ?? this.enabled,
      frequencyHours: frequencyHours ?? this.frequencyHours,
    );
  }

  int get normalizedFrequencyHours =>
      allowedFrequencyHours.contains(frequencyHours) ? frequencyHours : 24;
}

class CeremonyReminderOccurrence {
  const CeremonyReminderOccurrence({
    required this.scheduledAt,
    required this.notificationId,
  });

  final DateTime scheduledAt;
  final int notificationId;
}

List<CeremonyReminderOccurrence> buildCeremonyReminderOccurrences({
  required int predmetId,
  required DateTime ceremonyAt,
  required CeremonyReminderConfig config,
  required DateTime now,
}) {
  if (!config.enabled || !ceremonyAt.isAfter(now)) return const [];

  final frequency = Duration(hours: config.normalizedFrequencyHours);
  final start = ceremonyAt.subtract(const Duration(days: 2));
  final occurrences = <CeremonyReminderOccurrence>[];
  for (var at = start; !at.isAfter(ceremonyAt); at = at.add(frequency)) {
    if (!at.isAfter(now)) continue;
    occurrences.add(
      CeremonyReminderOccurrence(
        scheduledAt: at,
        notificationId: localCeremonyReminderNotificationId(predmetId, at),
      ),
    );
  }
  if (occurrences.isEmpty ||
      occurrences.last.scheduledAt != ceremonyAt && ceremonyAt.isAfter(now)) {
    occurrences.add(
      CeremonyReminderOccurrence(
        scheduledAt: ceremonyAt,
        notificationId: localCeremonyReminderNotificationId(
          predmetId,
          ceremonyAt,
        ),
      ),
    );
  }
  return occurrences;
}

int localCeremonyReminderNotificationId(int predmetId, DateTime scheduledAt) {
  var hash = 0x1fffffff & predmetId;
  hash = 0x1fffffff & (hash * 31 + scheduledAt.millisecondsSinceEpoch);
  return hash;
}

DateTime? activeCeremonyReminderSlot({
  required DateTime ceremonyAt,
  required CeremonyReminderConfig config,
  required DateTime now,
}) {
  if (!config.enabled || now.isAfter(ceremonyAt)) return null;
  final start = ceremonyAt.subtract(const Duration(days: 2));
  if (now.isBefore(start)) return null;
  final frequencyMinutes = config.normalizedFrequencyHours * 60;
  final elapsedMinutes = now.difference(start).inMinutes;
  return start.add(
    Duration(minutes: (elapsedMinutes ~/ frequencyMinutes) * frequencyMinutes),
  );
}
