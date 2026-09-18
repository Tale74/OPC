import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/json_transfer/iriu_json_compat.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('IRiU portable occurrence identity', () {
    test('same-category occurrences receive distinct stable identities', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final predmetId = await _insertPredmet(db, 'IDENTITY-DISTINCT/2026');
      final repository = IriuRepository(db);
      await repository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'CITULJA_POLITIKA',
        nazivPrikaz: 'Čitulja ista',
      );
      await repository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'CITULJA_POLITIKA',
        nazivPrikaz: 'Čitulja ista',
      );

      final rows = await _iriuForPredmet(db, predmetId);
      final identities = rows
          .map((row) => row.portableOccurrenceId)
          .whereType<String>()
          .toSet();
      expect(rows, hasLength(2));
      expect(identities, hasLength(2));
      expect(identities.every((id) => id.isNotEmpty), isTrue);
    });

    test('identity survives reload and is independent from display order', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final predmetId = await _insertPredmet(db, 'IDENTITY-ORDER/2026');
      final repository = IriuRepository(db);
      await repository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'CITULJA_POLITIKA',
        nazivPrikaz: 'Čitulja',
        redosled: 4,
      );
      final inserted = (await _iriuForPredmet(db, predmetId)).single;
      final identity = inserted.portableOccurrenceId;
      expect(identity, isNotNull);

      await repository.azurirajStavku(
        inserted.id,
        const IriuCompanion(redosled: drift.Value(1)),
      );
      final reloaded = (await _iriuForPredmet(db, predmetId)).single;
      expect(reloaded.portableOccurrenceId, identity);
      expect(reloaded.redosled, 1);
    });

    test('legacy/direct rows are backfilled without changing order or membership', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final predmetId = await _insertPredmet(db, 'IDENTITY-BACKFILL/2026');
      final rowId = await db.into(db.iriu).insert(
        IriuCompanion.insert(
          predmetId: predmetId,
          interniNaziv: 'CITULJA_POLITIKA',
          nazivPrikaz: const drift.Value('Legacy čitulja'),
          redosled: const drift.Value(7),
        ),
      );
      final before = await (db.select(db.iriu)..where((r) => r.id.equals(rowId)))
          .getSingle();
      expect(before.portableOccurrenceId, isNull);

      await db.backfillMissingIriuPortableOccurrenceIds(
        predmetId: predmetId,
      );
      final after = await (db.select(db.iriu)..where((r) => r.id.equals(rowId)))
          .getSingle();
      expect(after.portableOccurrenceId, isNotNull);
      expect(after.portableOccurrenceId, isNotEmpty);
      expect(after.interniNaziv, 'CITULJA_POLITIKA');
      expect(after.redosled, 7);
    });

    test('single-PREDMET JSON preserves identity for duplicate article occurrences', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);

      final sourcePredmetId = await _insertPredmet(source, 'IDENTITY-JSON/2026');
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-json-a',
        redosled: 0,
      );
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-json-b',
        redosled: 1,
      );

      final json = jsonDecode(
        await serializePredmetJsonForTest(
          db: source,
          predmetId: sourcePredmetId,
        ),
      ) as Map<String, dynamic>;
      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: await _insertActor(target),
      );

      final targetPredmet = (await target.select(target.predmeti).get()).single;
      final rows = await _iriuForPredmet(target, targetPredmet.id);
      expect(
        rows.map((row) => row.portableOccurrenceId).toSet(),
        {'iriu-occurrence-json-a', 'iriu-occurrence-json-b'},
      );
      expect(rows.map((row) => row.redosled).toSet(), {0, 1});
    });

    test('single-PREDMET JSON rejects duplicate portable occurrence identity', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);

      final sourcePredmetId = await _insertPredmet(source, 'IDENTITY-DUP/2026');
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-duplicate',
        redosled: 0,
      );
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-other',
        redosled: 1,
      );
      final json = jsonDecode(
        await serializePredmetJsonForTest(
          db: source,
          predmetId: sourcePredmetId,
        ),
      ) as Map<String, dynamic>;
      final iriu = json['iriu'] as List<dynamic>;
      (iriu[1] as Map<String, dynamic>)['portableOccurrenceId'] =
          'iriu-occurrence-duplicate';

      await expectLater(
        importPredmetJsonMapForTest(
          db: target,
          json: json,
          localActorKorisnikId: await _insertActor(target),
        ),
        throwsA(isA<Exception>()),
      );
      expect(await target.select(target.predmeti).get(), isEmpty);
    });

    test('OPC Backup JSON preserves identity for duplicate article occurrences', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);

      final sourcePredmetId = await _insertPredmet(source, 'IDENTITY-BACKUP/2026');
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-backup-a',
        redosled: 0,
      );
      await _insertIriu(
        source,
        predmetId: sourcePredmetId,
        portableId: 'iriu-occurrence-backup-b',
        redosled: 1,
      );

      final backup = jsonDecode(await serializeBackupJsonForTest(db: source))
          as Map<String, dynamic>;
      await importBackupJsonMapForTest(db: target, json: backup);

      final targetPredmet = (await target.select(target.predmeti).get()).single;
      final rows = await _iriuForPredmet(target, targetPredmet.id);
      expect(
        rows.map((row) => row.portableOccurrenceId).toSet(),
        {'iriu-occurrence-backup-a', 'iriu-occurrence-backup-b'},
      );
    });

    test('legacy JSON receives one persisted identity at import', () {
      final first = iriuDataFromCompatibleJson(<String, dynamic>{
        'id': 1,
        'predmetId': 10,
        'interniNaziv': 'CITULJA_POLITIKA',
        'nazivPrikaz': 'Legacy 1',
        'kom': '1',
        'iznos': 0.0,
        'cekiran': false,
        'redosled': 0,
      });
      final second = iriuDataFromCompatibleJson(<String, dynamic>{
        'id': 2,
        'predmetId': 10,
        'interniNaziv': 'CITULJA_POLITIKA',
        'nazivPrikaz': 'Legacy 2',
        'kom': '1',
        'iznos': 0.0,
        'cekiran': false,
        'redosled': 1,
      });

      expect(first.portableOccurrenceId, isNotNull);
      expect(second.portableOccurrenceId, isNotNull);
      expect(first.portableOccurrenceId, isNot(second.portableOccurrenceId));
    });
  });
}

Future<int> _insertPredmet(AppDatabase db, String brojPredmeta) {
  return db.into(db.predmeti).insert(
    PredmetiCompanion.insert(
      brojPredmeta: drift.Value(brojPredmeta),
      datumKreiranja: const drift.Value('2026-09-05T00:00:00.000'),
      ime: const drift.Value('R1'),
      prezime: const drift.Value('Test'),
    ),
  );
}

Future<int> _insertIriu(
  AppDatabase db, {
  required int predmetId,
  required String portableId,
  required int redosled,
}) {
  return db.into(db.iriu).insert(
    IriuCompanion.insert(
      predmetId: predmetId,
      portableOccurrenceId: drift.Value(portableId),
      interniNaziv: 'CITULJA_POLITIKA',
      nazivPrikaz: const drift.Value('Čitulja'),
      redosled: drift.Value(redosled),
    ),
  );
}

Future<List<IriuData>> _iriuForPredmet(AppDatabase db, int predmetId) {
  return (db.select(db.iriu)
        ..where((row) => row.predmetId.equals(predmetId))
        ..orderBy([(row) => drift.OrderingTerm.asc(row.redosled)]))
      .get();
}

Future<int> _insertActor(AppDatabase db) {
  return db.into(db.korisnici).insert(
    KorisniciCompanion.insert(
      imePrezime: 'R1 Actor',
      uloga: 'ADMINISTRATOR',
      pinHash: 'r1-test-hash',
      datumKreiranja: '2026-09-05T00:00:00.000',
    ),
  );
}
