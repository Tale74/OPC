import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

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
      'hard delete currently leaves reminder and PARTE rows as FK orphans',
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
        expect(await _predmetOrphanCounts(db), {
          ..._zeroOrphanInventory,
          'ceremony_reminder_settings': 1,
          'parte_pripreme': 1,
        });
        expect(await _foreignKeyViolationTables(db), {
          'ceremony_reminder_settings',
          'parte_pripreme',
        });
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
      'replacement currently keeps stale reminder and PARTE state on local id',
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
        final incoming = local.copyWith(
          id: 9001,
          ime: 'Novi',
          sourceIdentity: 'ri1_import_characterization',
        );

        await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
          lokalniPredmetId: local.id,
          predmet: incoming,
          iriu: const [],
          kontaktLica: const [],
        );

        final replaced = await PredmetiRepository(db).getPredmet(local.id);
        expect(replaced.ime, 'Novi');
        expect(replaced.sourceIdentity, 'ri1_import_characterization');
        expect(
          await _singleText(
            db,
            'SELECT draft_json AS value FROM parte_pripreme '
            'WHERE predmet_id = ?',
            local.id,
          ),
          contains('old-local-predmet'),
        );
        expect(
          await _singleText(
            db,
            'SELECT scheduled_notification_ids AS value '
            'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            local.id,
          ),
          '[43001]',
        );
        expect(await _foreignKeyViolationTables(db), isEmpty);
      },
    );

    test(
      'full restore currently re-associates a stale reminder by reused local id',
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
          await _singleText(
            targetDb,
            'SELECT scheduled_notification_ids AS value '
            'FROM ceremony_reminder_settings WHERE predmet_id = ?',
            source.id,
          ),
          '[44001]',
        );
        expect(await _foreignKeyViolationTables(targetDb), isEmpty);
      },
    );
  });
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
