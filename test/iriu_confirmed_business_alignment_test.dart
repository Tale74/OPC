import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/models/iriu_truth_models.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';

import 'test_bootstrap.dart';

void main() {
  test('SAHRANA VAN SRBIJE owns BALSAMOVANJE while DOCEK owns CARGO', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db);
    final rows = await _insertConfirmedRows(db, predmet.id);
    const service = PredmetIriuTruthService();

    final international = service.evaluate(
      predmet: predmet.copyWith(
        sahranaVanSrbije: true,
        docekPosmrtnihOstataka: false,
        opelo: 'DA',
      ),
      storedRows: rows,
    );
    expect(_row(international, IriuK.balsamovanje).active, isTrue);
    expect(_row(international, IriuK.cargoTroskovi).suppressed, isTrue);

    final reception = service.evaluate(
      predmet: predmet.copyWith(
        sahranaVanSrbije: false,
        docekPosmrtnihOstataka: true,
        opelo: 'NE',
      ),
      storedRows: rows,
    );
    expect(_row(reception, IriuK.balsamovanje).suppressed, isTrue);
    expect(_row(reception, IriuK.cargoTroskovi).active, isTrue);
  });

  test(
    'OPELO NE suppresses stored KOMPLET without deleting manual edits',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db);
      final rows = await _insertConfirmedRows(db, predmet.id);
      const service = PredmetIriuTruthService();

      final active = service.evaluate(
        predmet: predmet.copyWith(opelo: 'DA'),
        storedRows: rows,
      );
      expect(_row(active, IriuK.kompletZaOpelo).active, isTrue);

      final suppressed = service.evaluate(
        predmet: predmet.copyWith(opelo: 'NE'),
        storedRows: rows,
      );
      final komplet = _row(suppressed, IriuK.kompletZaOpelo);
      expect(komplet.suppressed, isTrue);
      expect(komplet.stored, isTrue);
      expect(komplet.storedRow.nazivPrikaz, 'Ručno izmenjen komplet');
      expect(komplet.storedRow.iznos, 4321);
      expect(komplet.countsForFinancialTruth, isFalse);
    },
  );
}

Future<PredmetiData> _insertPredmet(AppDatabase db) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('IR-IU-ALIGN-001/2026'),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}

Future<List<IriuData>> _insertConfirmedRows(
  AppDatabase db,
  int predmetId,
) async {
  for (final entry in const <(String, String, double)>[
    (IriuK.balsamovanje, 'Balsamovanje', 1000),
    (IriuK.cargoTroskovi, 'Cargo troškovi', 2000),
    (IriuK.kompletZaOpelo, 'Ručno izmenjen komplet', 4321),
  ]) {
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: entry.$1,
            nazivPrikaz: Value(entry.$2),
            kom: const Value('1'),
            iznos: Value(entry.$3),
            redosled: const Value(0),
          ),
        );
  }
  return (db.select(
    db.iriu,
  )..where((r) => r.predmetId.equals(predmetId))).get();
}

IriuTruthRow _row(PredmetIriuTruthSnapshot snapshot, String internalName) =>
    snapshot.rows.singleWhere(
      (row) => row.storedRow.interniNaziv == internalName,
    );
