import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'LISTA itemized rows include financially included citation rows exactly once',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('PDF-001'),
              datumKreiranja: const Value('2026-08-13T10:00:00.000'),
            ),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: IriuK.cituljaP,
              nazivPrikaz: const Value(
                'ČITULJA POLITIKA I/90 mm — Cela zemlja',
              ),
              kom: const Value('1'),
              iznos: const Value(3500),
              cena: const Value(3500),
              redosled: const Value(0),
            ),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: IriuK.crnina,
              nazivPrikaz: const Value('Ešarpa'),
              kom: const Value('1'),
              iznos: const Value(400),
              cena: const Value(400),
              redosled: const Value(1),
            ),
          );
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(predmetId))).getSingle();
      final prepared = const ListaPdfDataBuilder().build(
        predmet: predmet,
        iriuStavke: await (db.select(
          db.iriu,
        )..where((row) => row.predmetId.equals(predmetId))).get(),
        firma: await db.select(db.firmaPodaci).getSingle(),
        app: await db.select(db.appPodesavanja).getSingle(),
        savetnik: null,
      );

      expect(
        prepared.iriuItems.map((row) => row.naziv),
        containsAll(<String>[
          'ČITULJA POLITIKA I/90 mm — Cela zemlja',
          'Ešarpa',
        ]),
      );
      expect(
        prepared.iriuItems.where(
          (row) => row.naziv == 'ČITULJA POLITIKA I/90 mm — Cela zemlja',
        ),
        hasLength(1),
      );
      expect(
        prepared.iriuItems.fold<double>(0, (sum, row) => sum + row.iznos),
        3900,
      );
      expect(
        prepared.finansijskiRedovi
            .singleWhere((row) => row.label == 'ROBA I USLUGE')
            .value,
        contains('3.900'),
      );
    },
  );
}
