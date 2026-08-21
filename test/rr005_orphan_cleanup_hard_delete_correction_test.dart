import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('RR-005 orphan cleanup and hard-delete correction', () {
    test('hard delete removes owned provenance and snapshot only', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final doomed = await _insertPredmet(db, 'RR005-DELETE-001/2026');
      final survivor = await _insertPredmet(db, 'RR005-KEEP-001/2026');
      final doomedIriu = await _insertIriu(db, doomed.id, 'RR005-DOOMED');
      final survivorIriu = await _insertIriu(db, survivor.id, 'RR005-SURVIVOR');
      await _insertProvenance(db, doomedIriu);
      await _insertProvenance(db, survivorIriu);
      await _insertSnapshot(db, doomed.id);
      await _insertSnapshot(db, survivor.id);

      await PredmetiRepository(db).obrisiPredmet(doomed.id);

      expect(await _exists(db, 'predmeti', doomed.id), isFalse);
      expect(await _exists(db, 'iriu', doomedIriu), isFalse);
      expect(await _exists(db, 'iriu_provenance', doomedIriu), isFalse);
      expect(
        await _exists(db, 'predmet_scenario_snapshots', doomed.id),
        isFalse,
      );
      expect(await _exists(db, 'predmeti', survivor.id), isTrue);
      expect(await _exists(db, 'iriu', survivorIriu), isTrue);
      expect(await _exists(db, 'iriu_provenance', survivorIriu), isTrue);
      expect(
        await _exists(db, 'predmet_scenario_snapshots', survivor.id),
        isTrue,
      );
      expect(await _targetedForeignKeyViolations(db), 0);
    });

    test('replacement removes provenance for replaced IRiU rows', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final local = await _insertPredmet(db, 'RR005-REPLACE-001/2026');
      final oldIriu = await _insertIriu(db, local.id, 'RR005-OLD');
      await _insertProvenance(db, oldIriu);

      await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
        lokalniPredmetId: local.id,
        predmet: local.copyWith(id: 900001, ime: 'Replacement'),
        iriu: const [],
        kontaktLica: const [],
        auditKorisnikId: 1,
      );

      expect(await _exists(db, 'iriu', oldIriu), isFalse);
      expect(await _exists(db, 'iriu_provenance', oldIriu), isFalse);
      expect(await _targetedForeignKeyViolations(db), 0);
    });

    test('startup repair removes only the two proven orphan classes', () async {
      final root = await Directory.systemTemp.createTemp('opc-rr005-');
      final path = p.join(root.path, 'rr005.sqlite');
      final first = AppDatabase.forTesting(NativeDatabase(File(path)));
      await first.customSelect('SELECT 1').getSingle();

      final validPredmet = await _insertPredmet(first, 'RR005-VALID-001/2026');
      final validIriu = await _insertIriu(
        first,
        validPredmet.id,
        'RR005-VALID',
      );
      await _insertProvenance(first, validIriu);
      await _insertSnapshot(first, validPredmet.id);
      await _insertProvenance(first, 910001);
      await _insertSnapshot(first, 910002);
      expect(await _targetedForeignKeyViolations(first), 2);
      await first.close();

      final reopened = AppDatabase.forTesting(NativeDatabase(File(path)));
      await reopened.customSelect('SELECT 1').getSingle();
      expect(await _targetedForeignKeyViolations(reopened), 0);
      expect(await _exists(reopened, 'iriu_provenance', validIriu), isTrue);
      expect(
        await _exists(reopened, 'predmet_scenario_snapshots', validPredmet.id),
        isTrue,
      );
      expect(await _exists(reopened, 'predmeti', validPredmet.id), isTrue);
      expect(await _exists(reopened, 'iriu', validIriu), isTrue);

      await reopened.repairKnownReferentialIntegrity();
      expect(await _targetedForeignKeyViolations(reopened), 0);
      await reopened.close();

      final reopenedAgain = AppDatabase.forTesting(NativeDatabase(File(path)));
      await reopenedAgain.customSelect('SELECT 1').getSingle();
      expect(await _targetedForeignKeyViolations(reopenedAgain), 0);
      expect(
        await _exists(reopenedAgain, 'iriu_provenance', validIriu),
        isTrue,
      );
      expect(
        await _exists(
          reopenedAgain,
          'predmet_scenario_snapshots',
          validPredmet.id,
        ),
        isTrue,
      );
      await reopenedAgain.close();
      await root.delete(recursive: true);
    });
  });
}

Future<PredmetiData> _insertPredmet(AppDatabase db, String broj) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-08-18T10:00:00.000'),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<int> _insertIriu(AppDatabase db, int predmetId, String name) {
  return db.customInsert(
    'INSERT INTO iriu '
    '(predmet_id, interni_naziv, naziv_prikaz, kom, iznos, redosled) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    variables: [
      Variable.withInt(predmetId),
      Variable.withString(name),
      Variable.withString(name),
      Variable.withString('1'),
      Variable.withReal(0),
      Variable.withInt(0),
    ],
  );
}

Future<void> _insertProvenance(AppDatabase db, int iriuId) {
  return db
      .into(db.iriuProvenance)
      .insert(
        IriuProvenanceCompanion.insert(
          iriuId: Value(iriuId),
          origin: 'RR005_TEST',
          createdAt: '2026-08-18T10:00:00.000',
        ),
      );
}

Future<void> _insertSnapshot(AppDatabase db, int predmetId) {
  return db
      .into(db.predmetScenarioSnapshots)
      .insert(
        PredmetScenarioSnapshotsCompanion.insert(
          predmetId: Value(predmetId),
          moduleId: 'rr005-test',
          scenarioId: 'RR005_TEST',
          scenarioVersion: 1,
          snapshotJson: '{}',
          snapshotHash: 'rr005-test-hash-$predmetId',
          assignedAt: '2026-08-18T10:00:00.000',
        ),
      );
}

Future<bool> _exists(AppDatabase db, String table, int id) async {
  final row = await db
      .customSelect(
        'SELECT 1 AS present FROM $table WHERE ${table == 'iriu_provenance'
            ? 'iriu_id'
            : table == 'predmet_scenario_snapshots'
            ? 'predmet_id'
            : 'id'} = ? LIMIT 1',
        variables: [Variable.withInt(id)],
      )
      .getSingleOrNull();
  return row != null;
}

Future<int> _targetedForeignKeyViolations(AppDatabase db) async {
  final rows = await db.customSelect('PRAGMA foreign_key_check').get();
  return rows
      .where(
        (row) =>
            row.read<String>('table') == 'iriu_provenance' ||
            row.read<String>('table') == 'predmet_scenario_snapshots',
      )
      .length;
}
