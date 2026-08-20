import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_notification_gateway.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';

import 'test_bootstrap.dart';

void main() {
  group('RI-1 PREDMET lifecycle referential characterization', () {
    test(
      'current schema declares the complete PREDMET dependency inventory',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        expect(await _foreignKeysEnabled(db), 0);
        expect(await _predmetForeignKeys(db), {
          'ceremony_reminder_settings.predmet_id':
              'predmeti.id ON DELETE CASCADE',
          'iriu.predmet_id': 'predmeti.id ON DELETE CASCADE',
          'iriu_lifecycle_decisions.predmet_id':
              'predmeti.id ON DELETE CASCADE',
          'kontakt_lica.predmet_id': 'predmeti.id ON DELETE CASCADE',
          'log_izmena.predmet_id': 'predmeti.id ON DELETE CASCADE',
          'parte_pripreme.predmet_id': 'predmeti.id ON DELETE CASCADE',
          'stanje_robe_posledice.predmet_id': 'predmeti.id ON DELETE CASCADE',
        });
        expect(await _predmetOrphanCounts(db), _zeroOrphanInventory);
      },
    );

    test(
      'hard delete transaction explicitly removes reminder and PARTE rows',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-DELETE-001/2026',
        );
        await _insertReminder(db, predmet.id, '[41001]');
        await _insertParte(
          db,
          predmet.id,
          predmet.brojPredmeta,
          draftJson: '{"marker":"delete-characterization"}',
        );

        await PredmetiRepository(db).obrisiPredmet(predmet.id);

        expect(await db.select(db.predmeti).get(), isEmpty);
        expect(await _predmetOrphanCounts(db), _zeroOrphanInventory);
        expect(await _foreignKeyViolationTables(db), isEmpty);
      },
    );

    test(
      'anonymization currently redacts PREDMET but retains derivative PII',
      () async {
        const piiMarker = 'RI1-PII-1307990712345';
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-ANON-001/2026',
          jmbg: piiMarker,
        );
        await _insertReminder(db, predmet.id, '[42001,42002]');
        await _insertParte(
          db,
          predmet.id,
          predmet.brojPredmeta,
          draftJson: '{"jmbg":"$piiMarker"}',
        );
        await db.customStatement(
          'INSERT INTO log_izmena '
          '(predmet_id, korisnik_id, datum_vreme, polje, stara_vrednost, '
          'nova_vrednost) VALUES (?, ?, ?, ?, ?, ?)',
          [
            predmet.id,
            1,
            '2026-07-30T10:00:00.000',
            'jmbg',
            piiMarker,
            piiMarker,
          ],
        );

        await PredmetiRepository(db).anonimizujPredmet(predmet.id);

        final redacted = await PredmetiRepository(db).getPredmet(predmet.id);
        expect(redacted.status, 'ANONIMIZOVAN');
        expect(redacted.jmbg, PredmetiRepository.redactedValue);
        expect(
          await _singleText(
            db,
            'SELECT draft_json AS value FROM parte_pripreme '
            'WHERE predmet_id = ?',
            predmet.id,
          ),
          contains(piiMarker),
        );
        expect(
          await _singleText(
            db,
            'SELECT nova_vrednost AS value FROM log_izmena '
            'WHERE predmet_id = ?',
            predmet.id,
          ),
          piiMarker,
        );
        expect(
          await _singleText(
            db,
            'SELECT scheduled_notification_ids AS value '
            'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            predmet.id,
          ),
          '[42001,42002]',
        );
        expect(await _foreignKeyViolationTables(db), isEmpty);
      },
    );

    test(
      'same-identity replacement invalidates stale PARTE and reminder state',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final local = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-REPLACE-001/2026',
          ime: 'Stari',
        );
        await _insertReminder(db, local.id, '[43001]');
        await _insertParte(
          db,
          local.id,
          local.brojPredmeta,
          draftJson: '{"source":"old-local-predmet"}',
        );
        final transfer =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: db,
                    predmetId: local.id,
                  ),
                )
                as Map<String, dynamic>;
        final transferPredmet = (transfer['predmet'] as Map)
            .cast<String, dynamic>();
        transferPredmet['ime'] = 'Novi';
        transferPredmet['sourceIdentity'] = 'ri1_import_characterization';
        final gateway = _RecordingNotificationGateway();

        await importPredmetJsonMapForTest(
          db: db,
          json: transfer,
          replaceLocalPredmetId: local.id,
          notificationGateway: gateway,
        );

        final replaced = await PredmetiRepository(db).getPredmet(local.id);
        expect(replaced.ime, 'Novi');
        expect(replaced.sourceIdentity, 'ri1_import_characterization');
        expect(
          await db
              .customSelect(
                'SELECT 1 FROM parte_pripreme WHERE predmet_id = ?',
                variables: [Variable.withInt(local.id)],
              )
              .getSingleOrNull(),
          null,
        );
        expect(
          await _singleText(
            db,
            'SELECT scheduled_notification_ids AS value '
            'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            local.id,
          ),
          '[]',
        );
        expect(gateway.cancelledIds, contains(43001));
        expect(gateway.scheduledIds, isEmpty);
        expect(
          await _singleText(
            db,
            'SELECT delivery_times AS value FROM ceremony_reminder_settings '
            'WHERE predmet_id = ?',
            local.id,
          ),
          '["09:00"]',
        );
        expect(await _foreignKeyViolationTables(db), isEmpty);
      },
    );

    test(
      'full restore clears stale reminder before reusing a local predmet id',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);
        final source = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'RI1-RESTORED-001/2026',
          ime: 'Backup',
        );
        final target = await _insertPredmet(
          targetDb,
          brojPredmeta: 'RI1-STALE-TARGET-001/2026',
          ime: 'Stari',
        );
        expect(target.id, source.id);
        await _insertReminder(targetDb, target.id, '[44001]');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: sourceDb))
                as Map<String, dynamic>;

        await importBackupJsonMapForTest(db: targetDb, json: backup);

        final restored = await PredmetiRepository(
          targetDb,
        ).getPredmet(source.id);
        expect(restored.brojPredmeta, 'RI1-RESTORED-001/2026');
        expect(restored.ime, 'Backup');
        expect(
          await targetDb
              .customSelect(
                'SELECT 1 FROM ceremony_reminder_settings '
                'WHERE predmet_id = ?',
                variables: [Variable.withInt(source.id)],
              )
              .getSingleOrNull(),
          null,
        );
        expect(await _foreignKeyViolationTables(targetDb), isEmpty);
      },
    );

    test(
      'replacement stages and purges app-owned PARTE media after commit',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final mediaRoot = await Directory.systemTemp.createTemp('rr008-media-');
        addTearDown(() => mediaRoot.delete(recursive: true));
        final local = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-REPLACE-MEDIA-001/2026',
        );
        await _insertParte(
          db,
          local.id,
          local.brojPredmeta,
          draftJson: '{"source":"old"}',
        );
        final mediaFile = File(p.join(mediaRoot.path, 'old.png'));
        await mediaFile.writeAsBytes(const [1, 2, 3]);
        await db.customStatement(
          'UPDATE parte_pripreme SET photo_media_key = ? WHERE predmet_id = ?',
          ['old.png', local.id],
        );
        final transfer =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: db,
                    predmetId: local.id,
                  ),
                )
                as Map<String, dynamic>;

        await importPredmetJsonMapForTest(
          db: db,
          json: transfer,
          replaceLocalPredmetId: local.id,
          notificationGateway: _RecordingNotificationGateway(),
          mediaStore: ParteMediaStore(rootDirectory: () async => mediaRoot),
        );

        expect(await mediaFile.exists(), isFalse);
        expect(
          await db
              .customSelect(
                'SELECT 1 FROM parte_pripreme WHERE predmet_id = ?',
                variables: [Variable.withInt(local.id)],
              )
              .getSingleOrNull(),
          null,
        );
      },
    );

    test(
      'replacement without reminder configuration does not create default reminders',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final local = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-REPLACE-NO-REMINDER-001/2026',
        );
        final transfer =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: db,
                    predmetId: local.id,
                  ),
                )
                as Map<String, dynamic>;
        final gateway = _RecordingNotificationGateway();

        await importPredmetJsonMapForTest(
          db: db,
          json: transfer,
          replaceLocalPredmetId: local.id,
          notificationGateway: gateway,
        );

        expect(
          await db
              .customSelect(
                'SELECT 1 FROM ceremony_reminder_settings '
                'WHERE predmet_id = ?',
                variables: [Variable.withInt(local.id)],
              )
              .getSingleOrNull(),
          null,
        );
        expect(gateway.cancelledIds, isEmpty);
        expect(gateway.scheduledIds, isEmpty);
      },
    );

    test(
      'post-commit reminder initialization failure reports committed replacement without stranded media',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final mediaRoot = await Directory.systemTemp.createTemp(
          'rr008-post-commit-init-failure-',
        );
        addTearDown(() => mediaRoot.delete(recursive: true));
        final local = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-POST-COMMIT-INIT-FAIL-001/2026',
        );
        await _insertReminder(db, local.id, '[45001]');
        await _insertParte(
          db,
          local.id,
          local.brojPredmeta,
          draftJson: '{"source":"old"}',
        );
        final mediaFile = File(p.join(mediaRoot.path, 'old.png'));
        await mediaFile.writeAsBytes(const [1, 2, 3]);
        await db.customStatement(
          'UPDATE parte_pripreme SET photo_media_key = ? WHERE predmet_id = ?',
          ['old.png', local.id],
        );
        final transfer =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: db,
                    predmetId: local.id,
                  ),
                )
                as Map<String, dynamic>;
        final transferPredmet = (transfer['predmet'] as Map)
            .cast<String, dynamic>();
        transferPredmet['ime'] = 'PostCommitInit';
        transferPredmet['datumCeremonije'] = '30.07.2099';
        transferPredmet['vremeCeremonije'] = '12:00';
        final gateway = _RecordingNotificationGateway(failInitialize: true);

        final warning = await importPredmetJsonMapForTest(
          db: db,
          json: transfer,
          replaceLocalPredmetId: local.id,
          notificationGateway: gateway,
          mediaStore: ParteMediaStore(rootDirectory: () async => mediaRoot),
        );

        expect(warning, isNot(null));
        expect((await PredmetiRepository(db).getPredmet(local.id)).ime, 'PostCommitInit');
        expect(
          await _singleText(
            db,
            'SELECT scheduled_notification_ids AS value '
                'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            local.id,
          ),
          '[]',
        );
        expect(await mediaFile.exists(), isFalse);
        final trash = Directory(p.join(mediaRoot.path, '.delete_trash'));
        var trashEmpty = true;
        if (await trash.exists()) {
          trashEmpty = await trash.list(recursive: true).isEmpty;
        }
        expect(trashEmpty, isTrue);
      },
    );

    test(
      'post-commit scheduling failure cancels attempted notifications and keeps persisted ids empty',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final local = await _insertPredmet(
          db,
          brojPredmeta: 'RI1-POST-COMMIT-SCHEDULE-FAIL-001/2026',
        );
        await _insertReminder(db, local.id, '[46001]');
        final transfer =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: db,
                    predmetId: local.id,
                  ),
                )
                as Map<String, dynamic>;
        final transferPredmet = (transfer['predmet'] as Map)
            .cast<String, dynamic>();
        transferPredmet['ime'] = 'PostCommitSchedule';
        transferPredmet['datumCeremonije'] = '30.07.2099';
        transferPredmet['vremeCeremonije'] = '12:00';
        final gateway = _RecordingNotificationGateway(failScheduleAt: 2);

        final warning = await importPredmetJsonMapForTest(
          db: db,
          json: transfer,
          replaceLocalPredmetId: local.id,
          notificationGateway: gateway,
        );

        expect(warning, isNot(null));
        expect((await PredmetiRepository(db).getPredmet(local.id)).ime, 'PostCommitSchedule');
        expect(gateway.scheduledIds, isNotEmpty);
        expect(
          gateway.cancelledIds,
          containsAll(gateway.scheduledIds),
        );
        expect(
          await _singleText(
            db,
            'SELECT scheduled_notification_ids AS value '
                'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            local.id,
          ),
          '[]',
        );
      },
    );
  });
}

class _RecordingNotificationGateway implements CeremonyNotificationGateway {
  _RecordingNotificationGateway({this.failInitialize = false, this.failScheduleAt});

  bool failInitialize;
  final int? failScheduleAt;
  int _scheduleCalls = 0;
  final cancelledIds = <int>[];
  final scheduledIds = <int>[];

  @override
  Future<void> initialize({required bool requestPermission}) async {
    if (failInitialize) {
      failInitialize = false;
      throw StateError('synthetic notification initialization failure');
    }
  }

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    _scheduleCalls++;
    scheduledIds.add(id);
    if (failScheduleAt == _scheduleCalls) {
      throw StateError('synthetic notification scheduling failure');
    }
  }
}

const _predmetDependentTables = [
  'ceremony_reminder_settings',
  'iriu',
  'iriu_lifecycle_decisions',
  'kontakt_lica',
  'log_izmena',
  'parte_pripreme',
  'stanje_robe_posledice',
];

const _zeroOrphanInventory = {
  'ceremony_reminder_settings': 0,
  'iriu': 0,
  'iriu_lifecycle_decisions': 0,
  'kontakt_lica': 0,
  'log_izmena': 0,
  'parte_pripreme': 0,
  'stanje_robe_posledice': 0,
};

Future<int> _foreignKeysEnabled(AppDatabase db) async {
  final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
  return row.read<int>('foreign_keys');
}

Future<Map<String, String>> _predmetForeignKeys(AppDatabase db) async {
  final result = <String, String>{};
  for (final table in _predmetDependentTables) {
    final rows = await db.customSelect('PRAGMA foreign_key_list($table)').get();
    for (final row in rows) {
      if (row.read<String>('table') != 'predmeti') continue;
      result['$table.${row.read<String>('from')}'] =
          '${row.read<String>('table')}.${row.read<String>('to')} '
          'ON DELETE ${row.read<String>('on_delete')}';
    }
  }
  return result;
}

Future<Map<String, int>> _predmetOrphanCounts(AppDatabase db) async {
  final result = <String, int>{};
  for (final table in _predmetDependentTables) {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS orphan_count FROM $table child '
          'LEFT JOIN predmeti parent ON parent.id = child.predmet_id '
          'WHERE parent.id IS NULL',
        )
        .getSingle();
    result[table] = row.read<int>('orphan_count');
  }
  return result;
}

Future<Set<String>> _foreignKeyViolationTables(AppDatabase db) async {
  final rows = await db.customSelect('PRAGMA foreign_key_check').get();
  return rows.map((row) => row.read<String>('table')).toSet();
}

Future<String> _singleText(AppDatabase db, String sql, int predmetId) async {
  final row = await db
      .customSelect(sql, variables: [Variable.withInt(predmetId)])
      .getSingle();
  return row.read<String>('value');
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  required String brojPredmeta,
  String ime = '',
  String jmbg = '',
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(brojPredmeta),
          datumKreiranja: const Value('2026-07-30T10:00:00.000'),
          ime: Value(ime),
          jmbg: Value(jmbg),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<void> _insertReminder(
  AppDatabase db,
  int predmetId,
  String scheduledIds,
) {
  return db.customStatement(
    'INSERT INTO ceremony_reminder_settings '
    '(predmet_id, enabled, frequency_hours, delivery_times, '
    'scheduled_notification_ids, updated_at) VALUES (?, 1, 24, ?, ?, ?)',
    [predmetId, '["09:00"]', scheduledIds, '2026-07-30T10:00:00.000'],
  );
}

Future<void> _insertParte(
  AppDatabase db,
  int predmetId,
  String predmetBroj, {
  required String draftJson,
}) {
  return db.customStatement(
    'INSERT INTO parte_pripreme '
    '(predmet_id, predmet_broj, status, created_at, updated_at, '
    'source_fingerprint, template_id, template_snapshot_json, draft_json) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      predmetId,
      predmetBroj,
      'COMPLETED',
      '2026-07-30T10:00:00.000',
      '2026-07-30T10:00:00.000',
      'ri1-source-fingerprint',
      'ri1-template',
      '{}',
      draftJson,
    ],
  );
}
