import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'current lifecycle characterization auto-closes a past ceremony without active PARTE',
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
        isTrue,
      );
      expect((await repository.getPredmet(predmet.id)).status, 'ZAVRŠEN');
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

  test('bulk lifecycle refresh only changes open past-date PREDMETI', () async {
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

    expect(await repository.osveziAutomatskeStatuse(), 1);
    expect((await repository.getPredmet(pastOpen.id)).status, 'ZAVRŠEN');
    expect((await repository.getPredmet(pastFinished.id)).status, 'ZAVRŠEN');
    expect(
      (await repository.getPredmet(pastAnonymized.id)).status,
      'ANONIMIZOVAN',
    );
    expect((await repository.getPredmet(futureOpen.id)).status, 'OTVOREN');
  });
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
