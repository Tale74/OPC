import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart';
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

  test(
    'BIOHAZARD policy snapshot and IRiU truth agree for all valid causes',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final basePredmet = await _insertPredmet(db);
      final rowId = await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: basePredmet.id,
              interniNaziv: IriuK.iznosenje,
              nazivPrikaz: const Value('Iznošenje'),
              kom: const Value('1'),
              redosled: const Value(1),
              scenarioUpravlja: const Value(true),
            ),
          );
      final row = (await (db.select(
        db.iriu,
      )..where((item) => item.id.equals(rowId))).getSingle());
      const service = PredmetIriuTruthService();
      const expectedWarning =
          'Postupati prema merama zaštite za zaraznu bolest.';

      for (final (cause, expectedBiohazard) in const <(String, bool)>[
        ('PRIRODNA', false),
        ('ZARAZNA', true),
        ('NEDEFINISANA', true),
      ]) {
        final predmet = basePredmet.copyWith(
          uzrokSmrti: cause,
          mestoSmrti: 'STAN',
          vrstaCeremonije: 'SAHRANA',
          tipGroblja: 'GRADSKO',
          tipGrobnogMesta: 'GROB',
          opelo: 'NE',
          sahranaVanSrbije: false,
          docekPosmrtnihOstataka: false,
        );
        final policy = const BusinessPolicyEvaluator().evaluateForIriuTruth(
          predmet,
        );
        final scenarioRow = row.copyWith(
          poslovnoUpozorenje: expectedBiohazard ? expectedWarning : '',
        );
        final truth = service.evaluate(
          predmet: predmet,
          storedRows: [scenarioRow],
        );
        final iznosenje = _row(truth, IriuK.iznosenje);

        expect(
          policy.requiresBiohazardPrecautions,
          expectedBiohazard,
          reason: 'cause=$cause',
        );
        expect(iznosenje.active, isTrue, reason: 'cause=$cause');
        expect(iznosenje.biohazard, expectedBiohazard, reason: 'cause=$cause');
        expect(
          iznosenje.warning,
          expectedBiohazard ? expectedWarning : '',
          reason: 'cause=$cause',
        );
      }

      final receptionPredmet = basePredmet.copyWith(
        uzrokSmrti: 'NEDEFINISANA',
        mestoSmrti: 'BOLNICA',
        vrstaCeremonije: 'SAHRANA',
        tipGroblja: 'GRADSKO',
        tipGrobnogMesta: 'GROB',
        opelo: 'NE',
        sahranaVanSrbije: false,
        docekPosmrtnihOstataka: true,
      );
      final receptionPolicy = const BusinessPolicyEvaluator()
          .evaluateForIriuTruth(receptionPredmet);
      final receptionTruth = service.evaluate(
        predmet: receptionPredmet,
        storedRows: [row.copyWith(poslovnoUpozorenje: expectedWarning)],
      );
      expect(receptionPolicy.requiresBiohazardPrecautions, isTrue);
      expect(_row(receptionTruth, IriuK.iznosenje).biohazard, isTrue);
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
