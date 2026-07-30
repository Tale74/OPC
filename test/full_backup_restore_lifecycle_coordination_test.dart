import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_notification_gateway.dart';

import 'test_bootstrap.dart';

void main() {
  group('RI-2 full backup restore lifecycle coordination', () {
    test(
      'transfers logical reminders, replaces local child state, and preserves '
      'installation security/audit',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        final root = await Directory.systemTemp.createTemp('opc-ri2-restore-');
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        addTearDown(() async {
          if (await root.exists()) await root.delete(recursive: true);
        });

        final sourceId = await _insertPredmet(
          sourceDb,
          broj: 'RI2-RESTORE-SOURCE-001/2026',
          ime: 'Backup',
        );
        await sourceDb.customStatement(
          'INSERT INTO ceremony_reminder_settings '
          '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
          'updated_at) VALUES (?, 1, ?, ?, ?)',
          [
            sourceId,
            '["08:30","11:15"]',
            '[81001,81002]',
            '2026-07-30T12:00:00.000',
          ],
        );
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                as Map<String, dynamic>;
        final exportedReminder =
            (backup['ceremonyReminderSettings'] as List).single as Map;
        expect(backup['schemaVersion'], 8);
        expect(exportedReminder['deliveryTimes'], ['08:30', '11:15']);
        expect(exportedReminder.containsKey('scheduledNotificationIds'), false);
        expect(backup.containsKey('securitySettings'), false);
        expect(backup.containsKey('authAuditLog'), false);

        final targetId = await _insertPredmet(
          targetDb,
          broj: 'RI2-RESTORE-STALE-001/2026',
          ime: 'Stari',
        );
        expect(targetId, sourceId);
        await targetDb.customStatement(
          'INSERT INTO ceremony_reminder_settings '
          '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
          'updated_at) VALUES (?, 1, ?, ?, ?)',
          [targetId, '["09:00"]', '[44001]', '2026-07-30T12:00:00.000'],
        );
        await targetDb.customStatement(
          'INSERT INTO kontakt_lica (predmet_id, blok, ime_prezime) '
          'VALUES (?, ?, ?)',
          [targetId, 'NARU_OPREMA', 'Stari kontakt'],
        );
        const mediaKey = 'stale/owned.png';
        await targetDb.customStatement(
          'INSERT INTO parte_pripreme '
          '(predmet_id, predmet_broj, status, created_at, updated_at, '
          'source_fingerprint, template_id, template_snapshot_json, draft_json, '
          'photo_media_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            targetId,
            'STALE',
            'COMPLETED',
            '2026-07-30T12:00:00.000',
            '2026-07-30T12:00:00.000',
            'stale',
            'stale-template',
            '{}',
            '{}',
            mediaKey,
          ],
        );
        final mediaFile = File(p.join(root.path, p.fromUri(mediaKey)));
        await mediaFile.parent.create(recursive: true);
        await mediaFile.writeAsBytes([1, 2, 3], flush: true);
        await targetDb.customStatement(
          'UPDATE security_settings SET recovery_code_hash = ?, '
          'recovery_code_salt = ?, recovery_code_version = ? WHERE id = 1',
          ['local-hash', 'local-salt', 'v-local'],
        );
        await targetDb.customStatement(
          'INSERT INTO auth_audit_log '
          '(timestamp, event_type, actor_type, result, details, '
          'install_context) VALUES (?, ?, ?, ?, ?, ?)',
          [
            '2026-07-30T12:00:00.000',
            'local_sentinel',
            'SYSTEM',
            'SUCCESS',
            'preserve',
            'local_installation',
          ],
        );

        final gateway = _FakeGateway();
        await importBackupJsonMapForTest(
          db: targetDb,
          json: backup,
          coordinateExternalState: true,
          notificationGateway: gateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => root),
        );

        final restored = await (targetDb.select(
          targetDb.predmeti,
        )..where((row) => row.id.equals(sourceId))).getSingle();
        expect(restored.brojPredmeta, 'RI2-RESTORE-SOURCE-001/2026');
        expect(await _count(targetDb, 'kontakt_lica'), 0);
        expect(await _count(targetDb, 'parte_pripreme'), 0);
        expect(await mediaFile.exists(), false);
        expect(gateway.cancelledIds, contains(44001));
        expect(gateway.scheduledIds, isNotEmpty);

        final reminder = await targetDb
            .customSelect(
              'SELECT enabled, delivery_times, scheduled_notification_ids '
              'FROM ceremony_reminder_settings WHERE predmet_id = ?',
              variables: [Variable.withInt(sourceId)],
            )
            .getSingle();
        expect(reminder.read<int>('enabled'), 1);
        expect(reminder.read<String>('delivery_times'), '["08:30","11:15"]');
        final newIds =
            jsonDecode(reminder.read<String>('scheduled_notification_ids'))
                as List;
        expect(newIds, isNotEmpty);
        expect(newIds, isNot(contains(81001)));
        expect(newIds, isNot(contains(81002)));

        final security = await targetDb
            .customSelect(
              'SELECT recovery_code_hash, recovery_code_salt, '
              'recovery_code_version FROM security_settings WHERE id = 1',
            )
            .getSingle();
        expect(security.read<String>('recovery_code_hash'), 'local-hash');
        expect(security.read<String>('recovery_code_salt'), 'local-salt');
        expect(security.read<String>('recovery_code_version'), 'v-local');
        final auditTypes = await targetDb
            .customSelect('SELECT event_type FROM auth_audit_log ORDER BY id')
            .get();
        expect(
          auditTypes.map((row) => row.read<String>('event_type')),
          containsAll(['local_sentinel', 'full_backup_restore']),
        );
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );

    test(
      'legacy schema 7 clears stale reminders without inventing settings',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        final sourceId = await _insertPredmet(
          sourceDb,
          broj: 'RI2-LEGACY-SOURCE-001/2026',
        );
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                  as Map<String, dynamic>
              ..['schemaVersion'] = 7
              ..remove('ceremonyReminderSettings');
        final targetId = await _insertPredmet(
          targetDb,
          broj: 'RI2-LEGACY-STALE-001/2026',
        );
        expect(targetId, sourceId);
        await targetDb.customStatement(
          'INSERT INTO ceremony_reminder_settings '
          '(predmet_id, scheduled_notification_ids, updated_at) '
          'VALUES (?, ?, ?)',
          [targetId, '[99001]', '2026-07-30T12:00:00.000'],
        );

        await importBackupJsonMapForTest(db: targetDb, json: backup);

        expect(await _count(targetDb, 'ceremony_reminder_settings'), 0);
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );

    test(
      'database failure restores staged media and old local reminders',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        final root = await Directory.systemTemp.createTemp(
          'opc-ri2-restore-rollback-',
        );
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        addTearDown(() async {
          if (await root.exists()) await root.delete(recursive: true);
        });

        await _insertPredmet(sourceDb, broj: 'RI2-ROLLBACK-SOURCE-001/2026');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                as Map<String, dynamic>;
        final targetId = await _insertPredmet(
          targetDb,
          broj: 'RI2-ROLLBACK-TARGET-001/2026',
        );
        await targetDb.customStatement(
          'INSERT INTO ceremony_reminder_settings '
          '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
          'updated_at) VALUES (?, 1, ?, ?, ?)',
          [targetId, '["09:00"]', '[77001]', '2026-07-30T12:00:00.000'],
        );
        const mediaKey = 'rollback/owned.png';
        await targetDb.customStatement(
          'INSERT INTO parte_pripreme '
          '(predmet_id, predmet_broj, status, created_at, updated_at, '
          'source_fingerprint, template_id, template_snapshot_json, draft_json, '
          'photo_media_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            targetId,
            'ROLLBACK',
            'COMPLETED',
            '2026-07-30T12:00:00.000',
            '2026-07-30T12:00:00.000',
            'rollback',
            'rollback-template',
            '{}',
            '{}',
            mediaKey,
          ],
        );
        final mediaFile = File(p.join(root.path, p.fromUri(mediaKey)));
        await mediaFile.parent.create(recursive: true);
        await mediaFile.writeAsBytes([7, 7, 7], flush: true);
        await targetDb.customStatement('''
        CREATE TRIGGER fail_full_restore
        BEFORE DELETE ON predmeti
        BEGIN
          SELECT RAISE(ABORT, 'synthetic restore failure');
        END
      ''');
        final gateway = _FakeGateway();

        await expectLater(
          importBackupJsonMapForTest(
            db: targetDb,
            json: backup,
            coordinateExternalState: true,
            notificationGateway: gateway,
            mediaStore: ParteMediaStore(rootDirectory: () async => root),
          ),
          throwsA(anything),
        );

        final retained = await (targetDb.select(
          targetDb.predmeti,
        )..where((row) => row.id.equals(targetId))).getSingle();
        expect(retained.brojPredmeta, 'RI2-ROLLBACK-TARGET-001/2026');
        expect(await mediaFile.exists(), true);
        expect(gateway.cancelledIds, contains(77001));
        expect(gateway.scheduledIds, isNotEmpty);
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );
  });
}

Future<int> _insertPredmet(
  AppDatabase db, {
  required String broj,
  String ime = 'Sinteticki',
}) {
  return db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-07-30T12:00:00.000'),
          ime: Value(ime),
          prezime: const Value('Predmet'),
          vrstaCeremonije: const Value('SAHRANA'),
          datumCeremonije: const Value('31.12.2099'),
          vremeCeremonije: const Value('12:00'),
        ),
      );
}

Future<int> _count(AppDatabase db, String table) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS row_count FROM $table')
      .getSingle();
  return row.read<int>('row_count');
}

class _FakeGateway implements CeremonyNotificationGateway {
  final List<int> cancelledIds = [];
  final List<int> scheduledIds = [];

  @override
  Future<void> initialize({required bool requestPermission}) async {}

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduledIds.add(id);
  }
}
