import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import 'ceremony_reminder_model.dart';

class CeremonyReminderStoredConfig {
  const CeremonyReminderStoredConfig({
    required this.config,
    required this.scheduledNotificationIds,
    this.scheduledUrnaNotificationIds = const <int>[],
  });

  final CeremonyReminderConfig config;
  final List<int> scheduledNotificationIds;
  final List<int> scheduledUrnaNotificationIds;
}

abstract interface class CeremonyReminderStore {
  Future<CeremonyReminderStoredConfig> getForPredmet(int predmetId);
  Future<void> saveScheduledIds(int predmetId, List<int> ids);
  Future<void> saveUrnaScheduledIds(int predmetId, List<int> ids);
  Future<bool> isUrnaObligationCompleted(int predmetId);
}

class CeremonyReminderRepository implements CeremonyReminderStore {
  const CeremonyReminderRepository(this.db);

  final AppDatabase db;

  @override
  Future<CeremonyReminderStoredConfig> getForPredmet(int predmetId) async {
    final row = await db
        .customSelect(
          'SELECT enabled, delivery_times, scheduled_notification_ids, '
          'urna_scheduled_notification_ids '
          'FROM ceremony_reminder_settings WHERE predmet_id = ?',
          variables: [Variable.withInt(predmetId)],
        )
        .getSingleOrNull();
    if (row == null) {
      return const CeremonyReminderStoredConfig(
        config: CeremonyReminderConfig(),
        scheduledNotificationIds: [],
        scheduledUrnaNotificationIds: [],
      );
    }
    final rawIds = jsonDecode(row.read<String>('scheduled_notification_ids'));
    final rawTimes = jsonDecode(row.read<String>('delivery_times'));
    return CeremonyReminderStoredConfig(
      config: CeremonyReminderConfig(
        enabled: row.read<int>('enabled') == 1,
        deliveryTimes: rawTimes is List
            ? rawTimes.whereType<String>().toList(growable: false)
            : const <String>['09:00'],
      ),
      scheduledNotificationIds: rawIds is List
          ? rawIds.whereType<num>().map((value) => value.toInt()).toList()
          : const [],
      scheduledUrnaNotificationIds: _decodeIds(
        row.read<String>('urna_scheduled_notification_ids'),
      ),
    );
  }

  Future<void> saveConfig(int predmetId, CeremonyReminderConfig config) {
    return db.customStatement(
      'INSERT INTO ceremony_reminder_settings '
      '(predmet_id, enabled, delivery_times, updated_at) VALUES (?, ?, ?, ?) '
      'ON CONFLICT(predmet_id) DO UPDATE SET enabled = excluded.enabled, '
      'delivery_times = excluded.delivery_times, updated_at = excluded.updated_at',
      [
        predmetId,
        config.enabled ? 1 : 0,
        jsonEncode(config.normalizedDeliveryTimes),
        DateTime.now().toIso8601String(),
      ],
    );
  }

  @override
  Future<void> saveScheduledIds(int predmetId, List<int> ids) {
    return db.customStatement(
      'INSERT INTO ceremony_reminder_settings '
      '(predmet_id, scheduled_notification_ids, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(predmet_id) DO UPDATE SET '
      'scheduled_notification_ids = excluded.scheduled_notification_ids, '
      'updated_at = excluded.updated_at '
      'WHERE scheduled_notification_ids <> excluded.scheduled_notification_ids',
      [predmetId, jsonEncode(ids), DateTime.now().toIso8601String()],
    );
  }

  @override
  Future<void> saveUrnaScheduledIds(int predmetId, List<int> ids) {
    return db.customStatement(
      'INSERT INTO ceremony_reminder_settings '
      '(predmet_id, urna_scheduled_notification_ids, updated_at) '
      'VALUES (?, ?, ?) ON CONFLICT(predmet_id) DO UPDATE SET '
      'urna_scheduled_notification_ids = excluded.urna_scheduled_notification_ids, '
      'updated_at = excluded.updated_at',
      [predmetId, jsonEncode(ids), DateTime.now().toIso8601String()],
    );
  }

  @override
  Future<bool> isUrnaObligationCompleted(int predmetId) async {
    final row = await db
        .customSelect(
          'SELECT completed FROM podsetnik_obaveze '
          'WHERE predmet_id = ? AND stable_rule_id = ? LIMIT 1',
          variables: [
            Variable.withInt(predmetId),
            Variable.withString('post.urn_ashes.arrange_placement'),
          ],
        )
        .getSingleOrNull();
    return row?.read<int>('completed') == 1;
  }
}

List<int> _decodeIds(String value) {
  try {
    final raw = jsonDecode(value);
    return raw is List
        ? raw.whereType<num>().map((item) => item.toInt()).toList()
        : const <int>[];
  } on FormatException {
    return const <int>[];
  }
}
