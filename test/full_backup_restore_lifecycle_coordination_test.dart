import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_notification_gateway.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_coordinator.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_model.dart';

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
        await sourceDb
            .into(sourceDb.korisnici)
            .insert(
              KorisniciCompanion.insert(
                imePrezime: 'Sinteticki korisnik',
                uloga: 'SAVETNIK',
                pinHash: 'portable-synthetic-pin-hash',
                datumKreiranja: '2026-07-30T12:00:00.000',
              ),
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
        expect(backup['schemaVersion'], 9);
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

        final restoredUser = await targetDb
            .customSelect('SELECT pin_hash FROM korisnici')
            .getSingle();
        expect(
          restoredUser.read<String>('pin_hash'),
          'portable-synthetic-pin-hash',
        );

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
          auditTypes
              .where(
                (row) =>
                    row.read<String>('event_type') == 'full_backup_restore',
              )
              .length,
          1,
        );
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
      // This scenario opens two Drift databases and stages media. In the
      // complete suite it can legitimately wait behind migration tests; the
      // default 30-second timeout caused teardown to delete the temp root
      // while the test was still creating its stale media fixture.
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'dirty FK-off source exports only PREDMET-owned reminders and round-trips',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        final root = await Directory.systemTemp.createTemp(
          'opc-inc003-dirty-roundtrip-',
        );
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        addTearDown(() async {
          if (await root.exists()) await root.delete(recursive: true);
        });

        final sourceId = await _insertPredmet(
          sourceDb,
          broj: 'INC003-DIRTY-SOURCE-001/2026',
        );
        await _insertReminder(
          sourceDb,
          predmetId: sourceId,
          deliveryTimes: '["08:30"]',
          scheduledIds: '[81001]',
        );
        await _insertReminder(
          sourceDb,
          predmetId: 900001,
          deliveryTimes: '["10:15"]',
          scheduledIds: '[91001]',
        );
        await _insertReminder(
          sourceDb,
          predmetId: 900002,
          deliveryTimes: 'malformed-local-derivative',
          scheduledIds: '[91002]',
        );
        await _insertLog(sourceDb, predmetId: sourceId, polje: 'valid-log');
        await _insertLog(sourceDb, predmetId: 900001, polje: 'orphan-log');

        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                as Map<String, dynamic>;
        final reminders = backup['ceremonyReminderSettings'] as List;
        expect(reminders, hasLength(1));
        expect((reminders.single as Map)['predmetId'], sourceId);
        expect(
          (reminders.single as Map).containsKey('scheduledNotificationIds'),
          false,
        );
        final logs = backup['logIzmena'] as List;
        expect(logs, hasLength(1));
        expect((logs.single as Map)['predmetId'], sourceId);
        expect((logs.single as Map)['polje'], 'valid-log');

        final gateway = _FakeGateway();
        await importBackupJsonMapForTest(
          db: targetDb,
          json: backup,
          coordinateExternalState: true,
          notificationGateway: gateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => root),
        );

        expect(await _count(targetDb, 'predmeti'), 1);
        expect(await _count(targetDb, 'ceremony_reminder_settings'), 1);
        expect(gateway.scheduledIds, isNotEmpty);
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );

    test('existing schema-8 orphan reminder is skipped without destination '
        'reassociation and all old OS ids are cancelled', () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      final root = await Directory.systemTemp.createTemp('opc-inc003-compat-');
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });

      final sourceId = await _insertPredmet(
        sourceDb,
        broj: 'INC003-COMPAT-SOURCE-001/2026',
      );
      await _insertReminder(
        sourceDb,
        predmetId: sourceId,
        deliveryTimes: '["08:30"]',
        scheduledIds: '[82001]',
      );
      await _insertLog(sourceDb, predmetId: sourceId, polje: 'valid-log');
      final backup =
          jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
              as Map<String, dynamic>;

      final targetFirst = await _insertPredmet(
        targetDb,
        broj: 'INC003-DESTINATION-001/2026',
      );
      final targetOrphanCollision = await _insertPredmet(
        targetDb,
        broj: 'INC003-DESTINATION-002/2026',
      );
      expect(targetFirst, sourceId);
      await _insertReminder(
        targetDb,
        predmetId: targetFirst,
        deliveryTimes: '["09:00"]',
        scheduledIds: '[66001]',
      );
      await _insertReminder(
        targetDb,
        predmetId: targetOrphanCollision,
        deliveryTimes: '["09:30"]',
        scheduledIds: '[66002]',
      );
      await _insertReminder(
        targetDb,
        predmetId: 900003,
        deliveryTimes: '["10:30"]',
        scheduledIds: '[66003]',
      );
      (backup['ceremonyReminderSettings'] as List).add(<String, dynamic>{
        'predmetId': targetOrphanCollision,
        'enabled': true,
        'deliveryTimes': <String>['10:00'],
      });
      final orphanLog =
          Map<String, dynamic>.from((backup['logIzmena'] as List).single as Map)
            ..['id'] = 900004
            ..['predmetId'] = targetOrphanCollision
            ..['polje'] = 'orphan-log';
      (backup['logIzmena'] as List).add(orphanLog);
      await targetDb.customStatement(
        'UPDATE security_settings SET recovery_code_hash = ? WHERE id = 1',
        ['inc003-local-security'],
      );
      await targetDb.customStatement(
        'INSERT INTO auth_audit_log '
        '(timestamp, event_type, actor_type, result, details, '
        'install_context) VALUES (?, ?, ?, ?, ?, ?)',
        [
          '2026-07-30T12:00:00.000',
          'inc003-local-audit',
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

      expect(gateway.cancelledIds, containsAll([66001, 66002, 66003]));
      expect(
        await (targetDb.select(targetDb.predmeti)
              ..where((row) => row.id.equals(targetOrphanCollision)))
            .getSingleOrNull(),
        null,
      );
      expect(
        await targetDb
            .customSelect(
              'SELECT 1 FROM ceremony_reminder_settings '
              'WHERE predmet_id = ?',
              variables: [Variable.withInt(targetOrphanCollision)],
            )
            .getSingleOrNull(),
        null,
      );
      expect(await _count(targetDb, 'ceremony_reminder_settings'), 1);
      final importedLogs = await targetDb
          .customSelect('SELECT predmet_id, polje FROM log_izmena ORDER BY id')
          .get();
      expect(importedLogs, hasLength(1));
      expect(importedLogs.single.read<int>('predmet_id'), sourceId);
      expect(importedLogs.single.read<String>('polje'), 'valid-log');
      final security = await targetDb
          .customSelect(
            'SELECT recovery_code_hash FROM security_settings WHERE id = 1',
          )
          .getSingle();
      expect(
        security.read<String>('recovery_code_hash'),
        'inc003-local-security',
      );
      final audit = await targetDb
          .customSelect('SELECT event_type FROM auth_audit_log ORDER BY id')
          .get();
      expect(
        audit.map((row) => row.read<String>('event_type')),
        containsAll(['inc003-local-audit', 'full_backup_restore']),
      );
    });

    test('schema-8 compatibility still blocks device ids, duplicates, and bad '
        'types before destination mutation', () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      final root = await Directory.systemTemp.createTemp(
        'opc-inc003-strict-coordinated-',
      );
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final sourceId = await _insertPredmet(
        sourceDb,
        broj: 'INC003-STRICT-SOURCE-001/2026',
      );
      await _insertReminder(
        sourceDb,
        predmetId: sourceId,
        deliveryTimes: '["08:30"]',
        scheduledIds: '[83001]',
      );
      await _insertLog(sourceDb, predmetId: sourceId, polje: 'valid-log');
      final clean =
          jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
              as Map<String, dynamic>;
      final targetId = await _insertPredmet(
        targetDb,
        broj: 'INC003-STRICT-TARGET-001/2026',
      );
      await _insertReminder(
        targetDb,
        predmetId: targetId,
        deliveryTimes: '["09:00"]',
        scheduledIds: '[84001]',
      );
      const mediaKey = 'strict-invalid/owned.png';
      await targetDb.customStatement(
        'INSERT INTO parte_pripreme '
        '(predmet_id, predmet_broj, status, created_at, updated_at, '
        'source_fingerprint, template_id, template_snapshot_json, draft_json, '
        'photo_media_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          targetId,
          'STRICT-INVALID',
          'COMPLETED',
          '2026-07-30T12:00:00.000',
          '2026-07-30T12:00:00.000',
          'strict-invalid',
          'strict-invalid-template',
          '{}',
          '{}',
          mediaKey,
        ],
      );
      final mediaFile = File(p.join(root.path, p.fromUri(mediaKey)));
      await mediaFile.parent.create(recursive: true);
      await mediaFile.writeAsBytes([4, 4, 4], flush: true);

      final withDeviceIds = _deepJsonCopy(clean);
      ((withDeviceIds['ceremonyReminderSettings'] as List).single
          as Map)['scheduledNotificationIds'] = <int>[
        12345,
      ];
      await expectLater(
        importBackupJsonMapForTest(db: targetDb, json: withDeviceIds),
        throwsA(anything),
      );

      final withoutRequiredReminderSection = _deepJsonCopy(clean)
        ..remove('ceremonyReminderSettings');
      final coordinatedGateway = _FakeGateway();
      await expectLater(
        importBackupJsonMapForTest(
          db: targetDb,
          json: withoutRequiredReminderSection,
          coordinateExternalState: true,
          notificationGateway: coordinatedGateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => root),
        ),
        throwsA(anything),
      );
      expect(await _count(targetDb, 'predmeti'), 1);
      expect(await _count(targetDb, 'ceremony_reminder_settings'), 1);
      expect(await _count(targetDb, 'parte_pripreme'), 1);
      expect(await mediaFile.exists(), true);
      expect(coordinatedGateway.cancelledIds, contains(84001));
      expect(coordinatedGateway.scheduledIds, isNotEmpty);

      final withDuplicate = _deepJsonCopy(clean);
      final duplicateRows =
          withDuplicate['ceremonyReminderSettings'] as List<dynamic>;
      duplicateRows.add(Map<String, dynamic>.from(duplicateRows.single as Map));
      await expectLater(
        importBackupJsonMapForTest(db: targetDb, json: withDuplicate),
        throwsA(anything),
      );

      final withBadType = _deepJsonCopy(clean);
      ((withBadType['ceremonyReminderSettings'] as List).single
              as Map)['enabled'] =
          'true';
      await expectLater(
        importBackupJsonMapForTest(db: targetDb, json: withBadType),
        throwsA(anything),
      );

      final withMalformedOrphanReminder = _deepJsonCopy(clean);
      (withMalformedOrphanReminder['ceremonyReminderSettings'] as List).add(
        <String, dynamic>{
          'predmetId': 900005,
          'enabled': 'true',
          'deliveryTimes': <String>['10:00'],
        },
      );
      await expectLater(
        importBackupJsonMapForTest(
          db: targetDb,
          json: withMalformedOrphanReminder,
        ),
        throwsA(anything),
      );

      final withMalformedOrphanLog = _deepJsonCopy(clean);
      final malformedOrphanLog =
          Map<String, dynamic>.from(
              (withMalformedOrphanLog['logIzmena'] as List).single as Map,
            )
            ..['id'] = 900005
            ..['predmetId'] = 900006
            ..['datumVreme'] = 123;
      (withMalformedOrphanLog['logIzmena'] as List).add(malformedOrphanLog);
      await expectLater(
        importBackupJsonMapForTest(db: targetDb, json: withMalformedOrphanLog),
        throwsA(anything),
      );
      expect(await _count(targetDb, 'predmeti'), 1);
    });

    test('orphan notification cancel failure preserves DB/media and compensates '
        'only valid old reminders', () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      final root = await Directory.systemTemp.createTemp(
        'opc-inc003-cancel-failure-',
      );
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });

      await _insertPredmet(sourceDb, broj: 'INC003-CANCEL-SOURCE-001/2026');
      final backup =
          jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
              as Map<String, dynamic>;
      final targetId = await _insertPredmet(
        targetDb,
        broj: 'INC003-CANCEL-TARGET-001/2026',
      );
      await _insertReminder(
        targetDb,
        predmetId: targetId,
        deliveryTimes: '["09:00"]',
        scheduledIds: '[88001]',
      );
      await _insertReminder(
        targetDb,
        predmetId: 900005,
        deliveryTimes: '["10:00"]',
        scheduledIds: '[88002]',
      );
      const mediaKey = 'cancel-failure/owned.png';
      await targetDb.customStatement(
        'INSERT INTO parte_pripreme '
        '(predmet_id, predmet_broj, status, created_at, updated_at, '
        'source_fingerprint, template_id, template_snapshot_json, draft_json, '
        'photo_media_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          targetId,
          'CANCEL-FAILURE',
          'COMPLETED',
          '2026-07-30T12:00:00.000',
          '2026-07-30T12:00:00.000',
          'cancel-failure',
          'cancel-failure-template',
          '{}',
          '{}',
          mediaKey,
        ],
      );
      final mediaFile = File(p.join(root.path, p.fromUri(mediaKey)));
      await mediaFile.parent.create(recursive: true);
      await mediaFile.writeAsBytes([8, 8, 8], flush: true);
      final gateway = _FakeGateway(failOnCancelId: 88002);

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

      expect(await _count(targetDb, 'predmeti'), 1);
      expect(await _count(targetDb, 'ceremony_reminder_settings'), 2);
      expect(await _count(targetDb, 'parte_pripreme'), 1);
      expect(await mediaFile.exists(), true);
      expect(gateway.cancelledIds, containsAll([88001, 88002]));
      expect(gateway.scheduledIds, isNotEmpty);
      expect(gateway.scheduledIds, isNot(contains(88002)));
    });

    test(
      'legacy schema 7 clears stale reminders without inventing settings',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        final root = await Directory.systemTemp.createTemp(
          'opc-ri2-legacy-schema7-',
        );
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        addTearDown(() async {
          if (await root.exists()) await root.delete(recursive: true);
        });
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

        final gateway = _FakeGateway();
        await importBackupJsonMapForTest(
          db: targetDb,
          json: backup,
          coordinateExternalState: true,
          notificationGateway: gateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => root),
        );

        expect(await _count(targetDb, 'ceremony_reminder_settings'), 0);
        expect(gateway.cancelledIds, contains(99001));
        expect(gateway.scheduledIds, isEmpty);
        expect(
          await targetDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );

    test(
      'post-commit scheduling failure keeps restored DB and reports warning',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        final root = await Directory.systemTemp.createTemp(
          'opc-inc003-schedule-failure-',
        );
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        addTearDown(() async {
          if (await root.exists()) await root.delete(recursive: true);
        });

        final sourceId = await _insertPredmet(
          sourceDb,
          broj: 'INC003-SCHEDULE-SOURCE-001/2026',
        );
        await _insertReminder(
          sourceDb,
          predmetId: sourceId,
          deliveryTimes: '["09:00"]',
          scheduledIds: '[]',
        );
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                as Map<String, dynamic>;
        final gateway = _FakeGateway(failScheduling: true);

        final message = await importBackupJsonMapForTest(
          db: targetDb,
          json: backup,
          coordinateExternalState: true,
          notificationGateway: gateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => root),
        );

        final restored = await (targetDb.select(
          targetDb.predmeti,
        )..where((row) => row.id.equals(sourceId))).getSingle();
        expect(restored.brojPredmeta, 'INC003-SCHEDULE-SOURCE-001/2026');
        expect(gateway.scheduledIds, isNotEmpty);
        expect(message, contains('broj: 1'));
        final restoreAudit = await targetDb
            .customSelect(
              'SELECT COUNT(*) AS row_count FROM auth_audit_log '
              'WHERE event_type = \'full_backup_restore\'',
            )
            .getSingle();
        expect(restoreAudit.read<int>('row_count'), 1);
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
        await _insertReminder(
          targetDb,
          predmetId: 900004,
          deliveryTimes: '["10:00"]',
          scheduledIds: '[77002]',
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
        expect(gateway.cancelledIds, containsAll([77001, 77002]));
        expect(gateway.scheduledIds, isNotEmpty);
        expect(gateway.scheduledIds, isNot(contains(77002)));
        final rollbackViolations = await targetDb
            .customSelect('PRAGMA foreign_key_check')
            .get();
        expect(rollbackViolations, hasLength(1));
        expect(
          rollbackViolations.single.read<String>('table'),
          'ceremony_reminder_settings',
        );
      },
    );
  });

  final suppliedBackupPath = Platform.environment['OPC_INC003_BACKUP_PATH'];
  if (suppliedBackupPath != null && suppliedBackupPath.trim().isNotEmpty) {
    test('INC-003 supplied schema-8 backup isolated preflight', () async {
      final file = File(suppliedBackupPath);
      final digest = await sha256.bind(file.openRead()).first;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final predmeti = json['predmeti'] as List<dynamic>;
      final reminders = json['ceremonyReminderSettings'] as List<dynamic>;
      final logs = json['logIzmena'] as List<dynamic>;
      final predmetIds = predmeti
          .map((row) => (row as Map)['id'])
          .whereType<int>()
          .toSet();
      final parentOwnedReminderCount = reminders
          .where(
            (row) =>
                row is Map &&
                row['predmetId'] is int &&
                predmetIds.contains(row['predmetId']),
          )
          .length;
      final orphanReminderCount = reminders.length - parentOwnedReminderCount;
      final preflightMoment = DateTime(2026, 7, 31, 17, 54);
      final predmetiById = <int, Map<String, dynamic>>{
        for (final row in predmeti.whereType<Map<String, dynamic>>())
          if (row['id'] is int) row['id'] as int: row,
      };
      var activeTriggerCount = 0;
      for (final row in reminders.whereType<Map<String, dynamic>>()) {
        final predmetId = row['predmetId'];
        final predmet = predmetId is int ? predmetiById[predmetId] : null;
        if (predmet == null) continue;
        final ceremonyAt = parseCeremonyReminderDateTime(
          predmet['datumCeremonije']?.toString() ?? '',
          predmet['vremeCeremonije']?.toString() ?? '',
        );
        if (ceremonyAt == null) continue;
        final slot = activeCeremonyReminderSlot(
          ceremonyAt: ceremonyAt,
          config: CeremonyReminderConfig(
            enabled: row['enabled'] as bool,
            deliveryTimes: (row['deliveryTimes'] as List).cast<String>(),
          ),
          now: preflightMoment,
        );
        if (slot != null) activeTriggerCount++;
      }
      final validLogCount = logs
          .where(
            (row) =>
                row is Map &&
                row['predmetId'] is int &&
                predmetIds.contains(row['predmetId']),
          )
          .length;
      final orphanLogCount = logs.length - validLogCount;
      expect(json['format'], 'OPC_BACKUP');
    expect(json['schemaVersion'], 9);
      expect(predmeti.length, 46);
      expect(reminders.length, 9);
      expect(parentOwnedReminderCount, 7);
      expect(orphanReminderCount, 2);
      expect(activeTriggerCount, 0);
      expect(orphanLogCount, 6);
      expect(
        reminders.every(
          (row) => row is Map && !row.containsKey('scheduledNotificationIds'),
        ),
        true,
      );

      final targetDb = createTestDatabase();
      final root = await Directory.systemTemp.createTemp(
        'opc-inc003-supplied-preflight-',
      );
      addTearDown(targetDb.close);
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      await targetDb.customStatement(
        'UPDATE security_settings SET recovery_code_hash = ? WHERE id = 1',
        ['supplied-preflight-local-security'],
      );
      await targetDb.customStatement(
        'INSERT INTO auth_audit_log '
        '(timestamp, event_type, actor_type, result, details, install_context) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          '2026-07-30T12:00:00.000',
          'supplied-preflight-local-audit',
          'SYSTEM',
          'SUCCESS',
          'preserve',
          'local_installation',
        ],
      );
      final suppliedGateway = _FakeGateway();
      await importBackupJsonMapForTest(
        db: targetDb,
        json: json,
        coordinateExternalState: true,
        notificationGateway: suppliedGateway,
        mediaStore: ParteMediaStore(rootDirectory: () async => root),
      );

      expect(await _count(targetDb, 'predmeti'), predmeti.length);
      expect(
        await _count(targetDb, 'ceremony_reminder_settings'),
        parentOwnedReminderCount,
      );
      expect(suppliedGateway.scheduledIds, hasLength(3));
      expect(await _count(targetDb, 'log_izmena'), validLogCount);
      final importedReminderRows = await targetDb
          .customSelect(
            'SELECT predmet_id, scheduled_notification_ids '
            'FROM ceremony_reminder_settings '
            'ORDER BY predmet_id',
          )
          .get();
      expect(
        importedReminderRows.every(
          (row) => predmetIds.contains(row.read<int>('predmet_id')),
        ),
        true,
      );
      final persistedScheduledIds = importedReminderRows
          .expand(
            (row) =>
                (jsonDecode(row.read<String>('scheduled_notification_ids'))
                        as List)
                    .whereType<int>(),
          )
          .toSet();
      expect(persistedScheduledIds, suppliedGateway.scheduledIds.toSet());
      final security = await targetDb
          .customSelect(
            'SELECT recovery_code_hash FROM security_settings WHERE id = 1',
          )
          .getSingle();
      expect(
        security.read<String>('recovery_code_hash'),
        'supplied-preflight-local-security',
      );
      final audit = await targetDb
          .customSelect('SELECT event_type FROM auth_audit_log ORDER BY id')
          .get();
      expect(
        audit.map((row) => row.read<String>('event_type')),
        containsAll(['supplied-preflight-local-audit', 'full_backup_restore']),
      );
      expect(
        audit
            .where(
              (row) => row.read<String>('event_type') == 'full_backup_restore',
            )
            .length,
        1,
      );
      final violations = await targetDb
          .customSelect('PRAGMA foreign_key_check')
          .get();
      final violationCounts = <String, int>{};
      for (final row in violations) {
        final table = row.read<String>('table');
        violationCounts.update(table, (value) => value + 1, ifAbsent: () => 1);
      }
      if (violationCounts.isNotEmpty) {
        // Privacy-safe evidence: table names and aggregate counts only.
        // ignore: avoid_print
        print('INC003_PREFLIGHT fkViolations=$violationCounts');
      }
      expect(violationCounts, isEmpty);
      // Privacy-safe evidence only: digest, byte size and aggregate counts.
      // ignore: avoid_print
      print(
        'INC003_PREFLIGHT sha256=$digest bytes=${await file.length()} '
        'predmeti=${predmeti.length} reminders=${reminders.length} '
        'parentOwnedReminders=$parentOwnedReminderCount '
        'skippedOrphanReminders=$orphanReminderCount '
        'activeTriggersAtPreflight=$activeTriggerCount '
        'futurePlatformSchedulesRebuilt=${suppliedGateway.scheduledIds.length} '
        'logs=${logs.length} validLogs=$validLogCount '
        'skippedLogs=$orphanLogCount',
      );
    });
  }
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

Future<void> _insertReminder(
  AppDatabase db, {
  required int predmetId,
  required String deliveryTimes,
  required String scheduledIds,
}) {
  return db.customStatement(
    'INSERT INTO ceremony_reminder_settings '
    '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
    'updated_at) VALUES (?, 1, ?, ?, ?)',
    [predmetId, deliveryTimes, scheduledIds, '2026-07-30T12:00:00.000'],
  );
}

Future<void> _insertLog(
  AppDatabase db, {
  required int predmetId,
  required String polje,
}) {
  return db.customStatement(
    'INSERT INTO log_izmena '
    '(predmet_id, korisnik_id, datum_vreme, polje, stara_vrednost, '
    'nova_vrednost) VALUES (?, ?, ?, ?, ?, ?)',
    [predmetId, 1, '2026-07-30T12:00:00.000', polje, 'pre', 'posle'],
  );
}

Map<String, dynamic> _deepJsonCopy(Map<String, dynamic> source) {
  return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
}

class _FakeGateway implements CeremonyNotificationGateway {
  _FakeGateway({this.failOnCancelId, this.failScheduling = false});

  final int? failOnCancelId;
  final bool failScheduling;
  bool _cancelFailureThrown = false;
  final List<int> cancelledIds = [];
  final List<int> scheduledIds = [];

  @override
  Future<void> initialize({required bool requestPermission}) async {}

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    if (!_cancelFailureThrown && id == failOnCancelId) {
      _cancelFailureThrown = true;
      throw StateError('synthetic notification cancellation failure');
    }
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
    if (failScheduling) {
      throw StateError('synthetic notification scheduling failure');
    }
  }
}
