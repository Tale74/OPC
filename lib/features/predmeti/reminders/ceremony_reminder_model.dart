import '../../../core/format/app_time_format.dart';

class CeremonyReminderConfig {
  const CeremonyReminderConfig({
    this.enabled = true,
    this.deliveryTimes = const <String>['09:00'],
  });

  final bool enabled;
  final List<String> deliveryTimes;

  CeremonyReminderConfig copyWith({
    bool? enabled,
    List<String>? deliveryTimes,
  }) {
    return CeremonyReminderConfig(
      enabled: enabled ?? this.enabled,
      deliveryTimes: deliveryTimes ?? this.deliveryTimes,
    );
  }

  List<String> get normalizedDeliveryTimes {
    final normalized =
        deliveryTimes
            .map(normalizeTimeInput)
            .where((value) => RegExp(r'^\d{2}:\d{2}$').hasMatch(value))
            .toSet()
            .toList()
          ..sort();
    return normalized.isEmpty ? const <String>['09:00'] : normalized;
  }
}

class CeremonyReminderOccurrence {
  const CeremonyReminderOccurrence({
    required this.scheduledAt,
    required this.notificationId,
  });

  final DateTime scheduledAt;
  final int notificationId;
}

/// Builds future platform delivery slots for the ceremony's -2/-1/0 days.
///
/// A non-empty result means that device notifications can be prepared ahead
/// of time. It does not mean that the reminder date-trigger is active now;
/// [activeCeremonyReminderSlot] answers that separate question.
List<CeremonyReminderOccurrence> buildCeremonyReminderOccurrences({
  required int predmetId,
  required DateTime ceremonyAt,
  required CeremonyReminderConfig config,
  required DateTime now,
}) {
  if (!config.enabled || !ceremonyAt.isAfter(now)) return const [];

  final occurrences = <CeremonyReminderOccurrence>[];
  for (final daysBefore in const <int>[2, 1, 0]) {
    final day = DateTime(
      ceremonyAt.year,
      ceremonyAt.month,
      ceremonyAt.day,
    ).subtract(Duration(days: daysBefore));
    for (final time in config.normalizedDeliveryTimes) {
      final parts = time.split(':');
      final at = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (!at.isAfter(now) || at.isAfter(ceremonyAt)) continue;
      occurrences.add(
        CeremonyReminderOccurrence(
          scheduledAt: at,
          notificationId: localCeremonyReminderNotificationId(predmetId, at),
        ),
      );
    }
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
  final currentDay = DateTime(now.year, now.month, now.day);
  final validDays = <DateTime>{
    for (final daysBefore in const <int>[2, 1, 0])
      DateTime(
        ceremonyAt.year,
        ceremonyAt.month,
        ceremonyAt.day,
      ).subtract(Duration(days: daysBefore)),
  };
  if (!validDays.contains(currentDay)) return null;
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
    if (!candidate.isAfter(now) &&
        !candidate.isAfter(ceremonyAt) &&
        (latest == null || candidate.isAfter(latest))) {
      latest = candidate;
    }
  }
  return latest;
}
