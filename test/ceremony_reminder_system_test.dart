import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_notification_gateway.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_coordinator.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_model.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_repository.dart';

void main() {
  group('ceremony reminder model', () {
    final ceremonyAt = DateTime(2026, 7, 10, 12);

    test('default 24-hour frequency represents 2 / 1 / 0 day windows', () {
      final occurrences = buildCeremonyReminderOccurrences(
        predmetId: 7,
        ceremonyAt: ceremonyAt,
        config: const CeremonyReminderConfig(),
        now: DateTime(2026, 7, 1),
      );
      expect(occurrences.map((item) => item.scheduledAt), [
        DateTime(2026, 7, 8, 12),
        DateTime(2026, 7, 9, 12),
        DateTime(2026, 7, 10, 12),
      ]);
    });

    test('supports multiple user-selected delivery hours', () {
      final occurrences = buildCeremonyReminderOccurrences(
        predmetId: 7,
        ceremonyAt: ceremonyAt,
        config: const CeremonyReminderConfig(frequencyHours: 6),
        now: DateTime(2026, 7, 1),
      );
      expect(occurrences, hasLength(9));
      expect(occurrences.first.scheduledAt, DateTime(2026, 7, 8, 12));
      expect(occurrences.last.scheduledAt, ceremonyAt);
    });

    test('skips past delivery times without immediate spam', () {
      final occurrences = buildCeremonyReminderOccurrences(
        predmetId: 7,
        ceremonyAt: ceremonyAt,
        config: const CeremonyReminderConfig(frequencyHours: 6),
        now: DateTime(2026, 7, 9, 16),
      );
      expect(
        occurrences.every(
          (item) => item.scheduledAt.isAfter(DateTime(2026, 7, 9, 16)),
        ),
        isTrue,
      );
      expect(occurrences.map((item) => item.scheduledAt), [
        DateTime(2026, 7, 9, 18),
        DateTime(2026, 7, 10),
        DateTime(2026, 7, 10, 6),
        DateTime(2026, 7, 10, 12),
      ]);
    });

    test('disabled reminders produce no occurrences', () {
      expect(
        buildCeremonyReminderOccurrences(
          predmetId: 7,
          ceremonyAt: ceremonyAt,
          config: const CeremonyReminderConfig(enabled: false),
          now: DateTime(2026, 7, 1),
        ),
        isEmpty,
      );
    });
  });

  test('reschedule cancels and replaces local notification ids', () async {
    final store = _FakeStore();
    final gateway = _FakeGateway();
    final coordinator = CeremonyReminderCoordinator(
      repository: store,
      gateway: gateway,
    );
    final ceremonyAt = DateTime(2026, 7, 10, 12);

    await coordinator.reschedule(
      predmetId: 7,
      brojPredmeta: 'P-7',
      ceremonyAt: ceremonyAt,
      now: DateTime(2026, 7, 1),
    );
    final firstIds = Set<int>.from(store.ids);
    await coordinator.reschedule(
      predmetId: 7,
      brojPredmeta: 'P-7',
      ceremonyAt: ceremonyAt.add(const Duration(hours: 1)),
      now: DateTime(2026, 7, 1),
    );

    expect(gateway.cancelled, containsAll(firstIds));
    expect(gateway.pending.keys.toSet(), store.ids.toSet());
    expect(gateway.lastBody, contains('Predmet P-7'));
    expect(gateway.lastBody, isNot(contains('ime')));
  });

  test(
    'persists local reminder configuration outside PREDMET fields',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('REMINDER-001/2026'),
              datumKreiranja: const Value('2026-07-01T09:00:00.000'),
            ),
          );
      final repository = CeremonyReminderRepository(db);

      await repository.saveConfig(
        predmetId,
        const CeremonyReminderConfig(enabled: true, frequencyHours: 3),
      );
      await repository.saveScheduledIds(predmetId, [11, 12]);
      final stored = await repository.getForPredmet(predmetId);

      expect(stored.config.enabled, isTrue);
      expect(stored.config.frequencyHours, 3);
      expect(stored.scheduledNotificationIds, [11, 12]);
    },
  );

  test('automatic GDPR startup dialog is retired', () {
    expect(automaticGdprStartupDialogEnabled, isFalse);
    expect(manualGdprActionAvailable('ZAVRŠEN'), isTrue);
    expect(manualGdprActionAvailable('OTVOREN'), isFalse);
  });
}

class _FakeStore implements CeremonyReminderStore {
  List<int> ids = [];

  @override
  Future<CeremonyReminderStoredConfig> getForPredmet(int predmetId) async {
    return CeremonyReminderStoredConfig(
      config: const CeremonyReminderConfig(),
      scheduledNotificationIds: List<int>.from(ids),
    );
  }

  @override
  Future<void> saveScheduledIds(int predmetId, List<int> ids) async {
    this.ids = List<int>.from(ids);
  }
}

class _FakeGateway implements CeremonyNotificationGateway {
  final Map<int, DateTime> pending = {};
  final List<int> cancelled = [];
  String lastBody = '';

  @override
  Future<void> initialize({required bool requestPermission}) async {}

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pending.remove(id);
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    pending[id] = scheduledAt;
    lastBody = body;
  }
}
