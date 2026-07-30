import '../../../core/database/database.dart';
import '../parte/data/parte_media_store.dart';
import '../reminders/ceremony_notification_gateway.dart';
import '../reminders/ceremony_reminder_coordinator.dart';
import '../reminders/ceremony_reminder_repository.dart';

class FullBackupRestoreOutcome<T> {
  const FullBackupRestoreOutcome({
    required this.result,
    required this.reminderSchedulingFailures,
  });

  final T result;
  final int reminderSchedulingFailures;
}

/// Coordinates full restore with local PARTE media and device reminders.
///
/// Recovery material and authentication audit are deliberately not owned here:
/// they remain installation-local and are preserved by the database restore.
class FullBackupRestoreCoordinator {
  FullBackupRestoreCoordinator({
    required AppDatabase db,
    required this.notificationGateway,
    ParteMediaStore? mediaStore,
    CeremonyReminderRepository? reminderRepository,
  }) : _db = db,
       mediaStore = mediaStore ?? ParteMediaStore(),
       reminderRepository =
           reminderRepository ?? CeremonyReminderRepository(db);

  final AppDatabase _db;
  final CeremonyNotificationGateway notificationGateway;
  final ParteMediaStore mediaStore;
  final CeremonyReminderRepository reminderRepository;

  Future<FullBackupRestoreOutcome<T>> restore<T>({
    required Future<T> Function() databaseRestore,
  }) async {
    final oldPredmeti = await _db.select(_db.predmeti).get();
    final oldReminderIds = <int>[];
    for (final predmet in oldPredmeti) {
      final stored = await reminderRepository.getForPredmet(predmet.id);
      oldReminderIds.addAll(stored.scheduledNotificationIds);
    }
    final preparations = await _db.select(_db.partePripreme).get();
    final mediaKeys = <String>{
      for (final preparation in preparations)
        for (final key in <String?>[
          preparation.photoMediaKey,
          preparation.customSymbolMediaKey,
        ])
          if (key != null && key.trim().isNotEmpty) key.trim(),
    };
    final stagedMedia = await mediaStore.stageOwnedDeletion(mediaKeys);

    late T result;
    try {
      await _cancelIds(oldReminderIds);
      result = await databaseRestore();
    } on Object catch (primaryFailure, primaryStackTrace) {
      final compensationFailures = <Object>[];
      try {
        await stagedMedia.restore();
      } on Object catch (failure) {
        compensationFailures.add(failure);
      }
      try {
        await _schedulePredmeti(oldPredmeti);
      } on Object catch (failure) {
        compensationFailures.add(failure);
      }
      if (compensationFailures.isNotEmpty) {
        throw StateError(
          'Full restore failed and ${compensationFailures.length} '
          'compensation action(s) also failed: $primaryFailure',
        );
      }
      Error.throwWithStackTrace(primaryFailure, primaryStackTrace);
    }

    try {
      await stagedMedia.purge();
    } on Object {
      // DB restore committed. Isolated trash is a later housekeeping item.
    }
    final reminderFailures = await _scheduleCurrentReminders();
    return FullBackupRestoreOutcome(
      result: result,
      reminderSchedulingFailures: reminderFailures,
    );
  }

  Future<void> _cancelIds(Iterable<int> ids) async {
    final scopedIds = ids.toSet();
    if (scopedIds.isEmpty) return;
    await notificationGateway.initialize(requestPermission: false);
    for (final id in scopedIds) {
      await notificationGateway.cancel(id);
    }
  }

  Future<int> _scheduleCurrentReminders() async {
    late List<PredmetiData> predmeti;
    try {
      predmeti = await _db.select(_db.predmeti).get();
    } on Object {
      return 1;
    }
    var failures = 0;
    for (final predmet in predmeti) {
      try {
        await _schedulePredmet(predmet);
      } on Object {
        failures++;
      }
    }
    return failures;
  }

  Future<void> _schedulePredmeti(Iterable<PredmetiData> predmeti) async {
    for (final predmet in predmeti) {
      await _schedulePredmet(predmet);
    }
  }

  Future<void> _schedulePredmet(PredmetiData predmet) async {
    final stored = await reminderRepository.getForPredmet(predmet.id);
    if (!stored.config.enabled && stored.scheduledNotificationIds.isEmpty) {
      return;
    }
    await CeremonyReminderCoordinator(
      repository: reminderRepository,
      gateway: notificationGateway,
    ).reschedule(
      predmetId: predmet.id,
      ceremonyType: predmet.vrstaCeremonije,
      deceasedFirstName: predmet.ime,
      deceasedLastName: predmet.prezime,
      ceremonyDate: predmet.datumCeremonije,
      ceremonyTime: predmet.vremeCeremonije,
      ceremonyAt: parseCeremonyReminderDateTime(
        predmet.datumCeremonije,
        predmet.vremeCeremonije,
      ),
    );
  }
}
