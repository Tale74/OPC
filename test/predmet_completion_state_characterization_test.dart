import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'past ceremony remains open because completion is never automatic',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-PAST-001',
        datumCeremonije: '01.01.2020',
      );
      final repository = PredmetiRepository(db);

      expect(
        await repository.osveziAutomatskiStatusPredmeta(predmet.id),
        isFalse,
      );
      expect((await repository.getPredmet(predmet.id)).status, 'OTVOREN');
    },
  );

  test(
    'current lifecycle characterization does not auto-close missing or future ceremony dates',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final missing = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-MISSING-002',
        datumCeremonije: '',
      );
      final future = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-FUTURE-003',
        datumCeremonije: '31.12.2999',
      );
      final repository = PredmetiRepository(db);

      expect(
        await repository.osveziAutomatskiStatusPredmeta(missing.id),
        isFalse,
      );
      expect(
        await repository.osveziAutomatskiStatusPredmeta(future.id),
        isFalse,
      );
      expect((await repository.getPredmet(missing.id)).status, 'OTVOREN');
      expect((await repository.getPredmet(future.id)).status, 'OTVOREN');
    },
  );

  test('bulk lifecycle refresh never changes a PREDMET status', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final pastOpen = await _insertPredmet(
      db,
      broj: 'LIFECYCLE-BULK-004',
      datumCeremonije: '01.01.2020',
    );
    final pastFinished = await _insertPredmet(
      db,
      broj: 'LIFECYCLE-BULK-005',
      datumCeremonije: '01.01.2020',
      status: 'ZAVRŠEN',
    );
    final pastAnonymized = await _insertPredmet(
      db,
      broj: 'LIFECYCLE-BULK-006',
      datumCeremonije: '01.01.2020',
      status: 'ANONIMIZOVAN',
    );
    final futureOpen = await _insertPredmet(
      db,
      broj: 'LIFECYCLE-BULK-007',
      datumCeremonije: '31.12.2999',
    );
    final repository = PredmetiRepository(db);

    expect(await repository.osveziAutomatskeStatuse(), 0);
    expect((await repository.getPredmet(pastOpen.id)).status, 'OTVOREN');
    expect((await repository.getPredmet(pastFinished.id)).status, 'ZAVRŠEN');
    expect(
      (await repository.getPredmet(pastAnonymized.id)).status,
      'ANONIMIZOVAN',
    );
    expect((await repository.getPredmet(futureOpen.id)).status, 'OTVOREN');
  });

  test(
    'only explicit completion moves ZATVOREN to immutable ZAVRŠEN',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actor = await _insertUser(db);
      final open = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-EXPLICIT-008',
        datumCeremonije: '31.12.2999',
      );
      final closed = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-EXPLICIT-009',
        datumCeremonije: '31.12.2999',
        status: 'ZATVOREN',
      );
      final anonymized = await _insertPredmet(
        db,
        broj: 'LIFECYCLE-EXPLICIT-011',
        datumCeremonije: '31.12.2999',
        status: 'ANONIMIZOVAN',
      );
      final repository = PredmetiRepository(db);

      expect(
        () => repository.zavrsiPredmet(open.id, korisnikId: actor.id),
        throwsA(isA<PredmetCompletionStateException>()),
      );
      expect(
        () => repository.zavrsiPredmet(anonymized.id, korisnikId: actor.id),
        throwsA(isA<PredmetImmutableLifecycleException>()),
      );

      await repository.zavrsiPredmet(closed.id, korisnikId: actor.id);
      expect((await repository.getPredmet(closed.id)).status, 'ZAVRŠEN');
      await repository.zavrsiPredmet(closed.id, korisnikId: actor.id);

      expect(
        () => repository.otvoriPredmet(closed.id, korisnikId: actor.id),
        throwsA(isA<PredmetImmutableLifecycleException>()),
      );
      expect(
        () => repository.zatvoriPredmet(closed.id, korisnikId: actor.id),
        throwsA(isA<PredmetImmutableLifecycleException>()),
      );
      expect(
        () => repository.azurirajPredmet(
          closed.id,
          const PredmetiCompanion(ime: Value('Nedozvoljena izmena')),
        ),
        throwsA(isA<PredmetImmutableLifecycleException>()),
      );
      expect(
        () => repository.sacuvajPredmet(closed.id, korisnikId: actor.id),
        throwsA(isA<PredmetImmutableLifecycleException>()),
      );
      expect((await repository.getPredmet(closed.id)).status, 'ZAVRŠEN');
    },
  );

  test('unfinished PARTE blocks explicit completion atomically', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final actor = await _insertUser(db);
    final predmet = await _insertPredmet(
      db,
      broj: 'LIFECYCLE-BLOCKED-010',
      datumCeremonije: '31.12.2999',
      status: 'ZATVOREN',
    );
    await db.customStatement(
      'INSERT INTO parte_pripreme '
      '(predmet_id, predmet_broj, status, created_at, updated_at, '
      'source_fingerprint, template_id, template_snapshot_json, draft_json) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        predmet.id,
        predmet.brojPredmeta,
        'IN_PROGRESS',
        '2026-08-01T10:00:00.000',
        '2026-08-01T10:00:00.000',
        'completion-test-source',
        'completion-test-template',
        '{}',
        '{}',
      ],
    );
    final repository = PredmetiRepository(db);

    expect(
      () => repository.zavrsiPredmet(predmet.id, korisnikId: actor.id),
      throwsA(isA<PartePreparationBlockException>()),
    );
    expect((await repository.getPredmet(predmet.id)).status, 'ZATVOREN');
  });
}

Future<KorisniciData> _insertUser(AppDatabase db) async {
  final id = await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'Lifecycle test korisnik',
          uloga: 'SAVETNIK',
          pinHash: 'synthetic-hash',
          datumKreiranja: '2026-08-01T10:00:00.000',
        ),
      );
  return (db.select(
    db.korisnici,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  required String broj,
  required String datumCeremonije,
  String status = 'OTVOREN',
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-08-01T10:00:00.000'),
          ime: const Value('Karakterizacija'),
          prezime: const Value('Lifecycle'),
          datumCeremonije: Value(datumCeremonije),
          partePotrebna: const Value(false),
          status: Value(status),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}
