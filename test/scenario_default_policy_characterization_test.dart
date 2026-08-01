import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/rules/iriu_truth_rules.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

/// Characterization of the currently shipped default policy.
///
/// This is deliberately a characterization test, not a new scenario engine.
/// The current output is produced by several hard-coded rule families and
/// must remain stable until an owner-approved published scenario definition
/// can represent the same composition and lifecycle semantics.
void main() {
  group('Current default SCENARIO policy characterization', () {
    test('MESTO SMRTI output matrix remains exact', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = PredmetiRepository(db);

      final expectedBlock = <String>[
        IriuK.hladnjaca,
        IriuK.spremaanjePokojnika,
        IriuK.iznosenje,
        IriuK.prevozDoHladnjace,
        IriuK.transportnaVreca,
        IriuK.prevozDoGroblja,
      ];
      final cases = <String, List<String>>{
        'STAN': expectedBlock,
        'DOM ZA STARE': expectedBlock,
        IriuTruthRules.mestoSmrtiPrivatnaBolnica: expectedBlock,
        'DRUGO': expectedBlock,
        'ULICA': expectedBlock,
        'JAVNO MESTO': expectedBlock,
        'BOLNICA': <String>[IriuK.prevozDoGroblja],
        '': const <String>[],
      };

      for (final entry in cases.entries) {
        final predmet = await _predmet(repository, mestoSmrti: entry.key);
        expect(
          IriuTruthRules.autoManagedMestoSmrtiCategories(predmet: predmet),
          entry.value,
          reason: 'MESTO SMRTI=${entry.key}',
        );
      }
    });

    test('BLOK 2 output matrix remains exact', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = PredmetiRepository(db);

      final grobnica = await _predmet(
        repository,
        mestoSmrti: 'STAN',
        uzrokSmrti: 'PRIRODNA',
        tipGroblja: 'GRADSKO',
        tipGrobnogMesta: 'GROBNICA',
      );
      expect(
        IriuTruthRules.autoManagedBlok2Categories(predmet: grobnica),
        <String>[IriuK.limeniUlozak, IriuK.lemovanje],
      );

      final causeOverride = await _predmet(
        repository,
        mestoSmrti: 'STAN',
        uzrokSmrti: 'ZARAZNA',
        tipGroblja: 'GRADSKO',
        tipGrobnogMesta: 'GROB',
      );
      expect(
        IriuTruthRules.autoManagedBlok2Categories(predmet: causeOverride),
        <String>[IriuK.limeniUlozak, IriuK.lemovanje],
      );

      final cremation = await _predmet(
        repository,
        mestoSmrti: 'STAN',
        uzrokSmrti: 'PRIRODNA',
        tipGroblja: 'GRADSKO',
        tipGrobnogMesta: 'GROBNICA',
        vrstaCeremonije: 'KREMACIJA',
      );
      expect(
        IriuTruthRules.autoManagedBlok2Categories(predmet: cremation),
        isEmpty,
      );

      final localCemetery = await _predmet(
        repository,
        mestoSmrti: 'STAN',
        uzrokSmrti: 'PRIRODNA',
        tipGroblja: 'LOKALNO',
        tipGrobnogMesta: 'GROB',
      );
      expect(
        IriuTruthRules.autoManagedBlok2Categories(predmet: localCemetery),
        <String>[IriuK.prevozSprovoda],
      );
    });

    test(
      'stored-row truth flags preserve international, doček, opelo, biohazard and ordering rules',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final repository = PredmetiRepository(db);
        final predmet = await _predmet(
          repository,
          mestoSmrti: 'STAN',
          uzrokSmrti: 'ZARAZNA',
        );
        final rows = <IriuData>[
          _row(1, predmet.id, IriuK.sanduk, redosled: 900),
          _row(2, predmet.id, IriuK.medjunarodniPrevoz, redosled: 10),
          _row(3, predmet.id, IriuK.medjunarodnaDocumentacija, redosled: 11),
          _row(4, predmet.id, IriuK.balsamovanje, redosled: 12),
          _row(5, predmet.id, IriuK.cargoTroskovi, redosled: 13),
          _row(6, predmet.id, IriuK.kompletZaOpelo, redosled: 14),
          _row(7, predmet.id, IriuK.spremaanjePokojnika, redosled: 15),
        ];

        final snapshot = const PredmetIriuTruthService().evaluate(
          predmet: predmet.copyWith(
            sahranaVanSrbije: true,
            docekPosmrtnihOstataka: true,
            opelo: 'DA',
          ),
          storedRows: rows,
        );
        final byCategory = <String, dynamic>{
          for (final row in snapshot.rows) row.storedRow.interniNaziv: row,
        };

        expect(byCategory[IriuK.medjunarodniPrevoz].active, isTrue);
        expect(byCategory[IriuK.medjunarodnaDocumentacija].active, isTrue);
        expect(byCategory[IriuK.balsamovanje].active, isTrue);
        expect(byCategory[IriuK.cargoTroskovi].active, isTrue);
        expect(byCategory[IriuK.kompletZaOpelo].active, isTrue);
        expect(byCategory[IriuK.spremaanjePokojnika].biohazard, isTrue);
        expect(byCategory[IriuK.sanduk].truthOrder, -100000);
      },
    );

    test('BLOK 2 cause overrides include NASILNA and NEDEFINISANA', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = PredmetiRepository(db);
      for (final cause in const <String>['NASILNA', 'NEDEFINISANA']) {
        final predmet = await _predmet(
          repository,
          mestoSmrti: 'STAN',
          uzrokSmrti: cause,
          tipGrobnogMesta: 'GROB',
        );
        expect(
          IriuTruthRules.autoManagedBlok2Categories(predmet: predmet),
          <String>[IriuK.limeniUlozak, IriuK.lemovanje],
          reason: 'UZROK SMRTI=$cause',
        );
      }
    });
  });
}

Future<PredmetiData> _predmet(
  PredmetiRepository repository, {
  required String mestoSmrti,
  String uzrokSmrti = 'PRIRODNA',
  String tipGroblja = 'GRADSKO',
  String tipGrobnogMesta = 'GROB',
  String vrstaCeremonije = 'SAHRANA',
}) async {
  final id = await repository.kreirajPredmet(savetnikId: 1);
  await repository.azurirajPredmet(
    id,
    PredmetiCompanion(
      mestoSmrti: Value(mestoSmrti),
      uzrokSmrti: Value(uzrokSmrti),
      tipGroblja: Value(tipGroblja),
      tipGrobnogMesta: Value(tipGrobnogMesta),
      vrstaCeremonije: Value(vrstaCeremonije),
    ),
  );
  return repository.getPredmet(id);
}

IriuData _row(
  int id,
  int predmetId,
  String interniNaziv, {
  required int redosled,
}) {
  return IriuData(
    id: id,
    predmetId: predmetId,
    interniNaziv: interniNaziv,
    nazivPrikaz: interniNaziv,
    kom: '1',
    iznos: 1,
    cekiran: false,
    redosled: redosled,
  );
}
