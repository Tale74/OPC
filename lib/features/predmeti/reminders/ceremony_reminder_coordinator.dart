import '../../../core/format/app_date_format.dart';
import 'ceremony_notification_gateway.dart';
import 'ceremony_reminder_model.dart';
import 'ceremony_reminder_repository.dart';

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
    required String brojPredmeta,
    required DateTime? ceremonyAt,
    DateTime? now,
    bool requestPermission = false,
  }) async {
    final stored = await repository.getForPredmet(predmetId);
    await gateway.initialize(requestPermission: requestPermission);
    for (final id in stored.scheduledNotificationIds) {
      await gateway.cancel(id);
    }

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
        body: 'Predmet $brojPredmeta • termin ${_format(ceremonyAt!)}',
        payload: 'predmet:$predmetId',
      );
    }
    await repository.saveScheduledIds(
      predmetId,
      occurrences.map((item) => item.notificationId).toList(),
    );
    return occurrences;
  }

  String _format(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.${value.year}. $hour:$minute';
  }
}
