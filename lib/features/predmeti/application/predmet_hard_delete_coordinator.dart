import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../data/predmeti_repository.dart';
import '../parte/data/parte_media_store.dart';
import '../reminders/ceremony_notification_gateway.dart';
import '../reminders/ceremony_reminder_coordinator.dart';
import '../reminders/ceremony_reminder_repository.dart';

class PredmetHardDeleteCompensationException implements Exception {
  const PredmetHardDeleteCompensationException({
    required this.primaryFailure,
    required this.compensationFailures,
  });

  final Object primaryFailure;
  final List<Object> compensationFailures;

  @override
  String toString() =>
      'Hard delete failed and compensation was incomplete '
      '(${compensationFailures.length} failure(s)): $primaryFailure';
}

/// Coordinates PREDMET hard delete with app-owned filesystem and OS state.
///
/// SQLite foreign-key enforcement intentionally remains unchanged in RI-2.
/// The database repository therefore removes every declared PREDMET child
/// explicitly, while this coordinator owns external staging and compensation.
class PredmetHardDeleteCoordinator {
  PredmetHardDeleteCoordinator({
    required AppDatabase db,
    required this.notificationGateway,
    ParteMediaStore? mediaStore,
    PredmetiRepository? predmetiRepository,
    CeremonyReminderRepository? reminderRepository,
  }) : _db = db,
       mediaStore = mediaStore ?? ParteMediaStore(),
       predmetiRepository = predmetiRepository ?? PredmetiRepository(db),
       reminderRepository =
           reminderRepository ?? CeremonyReminderRepository(db);

  final AppDatabase _db;
  final CeremonyNotificationGateway notificationGateway;
  final ParteMediaStore mediaStore;
  final PredmetiRepository predmetiRepository;
  final CeremonyReminderRepository reminderRepository;

  Future<void> deletePredmet(int predmetId) async {
    final predmet = await predmetiRepository.getPredmet(predmetId);
    final preparation = await (_db.select(
      _db.partePripreme,
    )..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();
    final reminder = await reminderRepository.getForPredmet(predmetId);
    final mediaKeys = await _exclusiveMediaKeys(preparation);
    final stagedMedia = await mediaStore.stageOwnedDeletion(mediaKeys);

    try {
      await _cancelStoredReminderIds(reminder.scheduledNotificationIds);
      await predmetiRepository.obrisiPredmet(predmetId);
    } on Object catch (primaryFailure, primaryStackTrace) {
      final compensationFailures = <Object>[];
      try {
        await stagedMedia.restore();
      } on Object catch (failure) {
        compensationFailures.add(failure);
      }
      if (reminder.scheduledNotificationIds.isNotEmpty) {
        try {
          await CeremonyReminderCoordinator(
            repository: reminderRepository,
            gateway: notificationGateway,
          ).reschedule(
            predmetId: predmet.id,
            predmetStatus: predmet.status,
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
        } on Object catch (failure) {
          compensationFailures.add(failure);
        }
      }
      if (compensationFailures.isNotEmpty) {
        throw PredmetHardDeleteCompensationException(
          primaryFailure: primaryFailure,
          compensationFailures: List.unmodifiable(compensationFailures),
        );
      }
      Error.throwWithStackTrace(primaryFailure, primaryStackTrace);
    }

    try {
      await stagedMedia.purge();
    } on FileSystemException {
      // The authoritative transaction has committed. Isolated app-owned trash
      // remains recoverable by later housekeeping and must not revive PREDMET.
    }
  }

  Future<List<String>> _exclusiveMediaKeys(
    PartePripremeData? preparation,
  ) async {
    if (preparation == null) return const [];
    final exclusive = <String>[];
    for (final key in <String?>[
      preparation.photoMediaKey,
      preparation.customSymbolMediaKey,
    ]) {
      final normalized = key?.trim() ?? '';
      if (normalized.isEmpty) continue;
      final shared =
          await (_db.select(_db.partePripreme)
                ..where(
                  (row) =>
                      row.id.isNotValue(preparation.id) &
                      (row.photoMediaKey.equals(normalized) |
                          row.customSymbolMediaKey.equals(normalized)),
                )
                ..limit(1))
              .getSingleOrNull();
      if (shared == null) exclusive.add(normalized);
    }
    return exclusive;
  }

  Future<void> _cancelStoredReminderIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await notificationGateway.initialize(requestPermission: false);
    for (final id in ids) {
      await notificationGateway.cancel(id);
    }
  }
}
