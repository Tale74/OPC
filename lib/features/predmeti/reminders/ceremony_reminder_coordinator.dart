import '../../../core/format/app_date_format.dart';
import 'ceremony_notification_gateway.dart';
import 'ceremony_reminder_model.dart';
import 'ceremony_reminder_repository.dart';
import 'ceremony_reminder_text.dart';
import 'podsetnik_eligibility.dart';

DateTime? parseCeremonyReminderDateTime(String date, String time) {
  final parsedDate = parseDateValue(date);
  final parts = time.trim().split(':');
  if (parsedDate == null || parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) return null;
  return DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    hour,
    minute,
  );
}

class CeremonyReminderCoordinator {
  const CeremonyReminderCoordinator({
    required this.repository,
    required this.gateway,
  });

  final CeremonyReminderStore repository;
  final CeremonyNotificationGateway gateway;

  Future<List<CeremonyReminderOccurrence>> reschedule({
    required int predmetId,
    required String predmetStatus,
    required String ceremonyType,
    required String deceasedFirstName,
    required String deceasedLastName,
    required String ceremonyDate,
    required String ceremonyTime,
    required DateTime? ceremonyAt,
    DateTime? now,
    bool requestPermission = false,
  }) async {
    final stored = await repository.getForPredmet(predmetId);

    // Historical reminder rows may be retained, but current PREDMET status is
    // the only authority for active scheduling. Fail closed for every status
    // outside the owner-controlled OTVOREN/ZATVOREN allow-list.
    if (!isPodsetnikEligibleStatus(predmetStatus)) {
      if (stored.scheduledNotificationIds.isNotEmpty) {
        await gateway.initialize(requestPermission: false);
      }
      await _cancelStoredIds(stored.scheduledNotificationIds);
      if (stored.scheduledNotificationIds.isNotEmpty) {
        await repository.saveScheduledIds(predmetId, const []);
      }
      return const <CeremonyReminderOccurrence>[];
    }

    await gateway.initialize(requestPermission: requestPermission);
    await _cancelStoredIds(stored.scheduledNotificationIds);

    final occurrences = ceremonyAt == null
        ? const <CeremonyReminderOccurrence>[]
        : buildCeremonyReminderOccurrences(
            predmetId: predmetId,
            ceremonyAt: ceremonyAt,
            config: stored.config,
            now: now ?? DateTime.now(),
          );
    for (final occurrence in occurrences) {
      await gateway.schedule(
        id: occurrence.notificationId,
        scheduledAt: occurrence.scheduledAt,
        title: 'Podsetnik za ceremoniju',
        body: buildCeremonyReminderText(
          ceremonyType: ceremonyType,
          deceasedFirstName: deceasedFirstName,
          deceasedLastName: deceasedLastName,
          ceremonyDate: ceremonyDate,
          ceremonyTime: ceremonyTime,
        ),
        payload: 'predmet:$predmetId',
      );
    }
    await repository.saveScheduledIds(
      predmetId,
      occurrences.map((item) => item.notificationId).toList(),
    );
    return occurrences;
  }

  Future<void> _cancelStoredIds(Iterable<int> ids) async {
    for (final id in ids) {
      await gateway.cancel(id);
    }
  }
}
