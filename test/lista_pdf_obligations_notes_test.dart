import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_export.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'LISTA projects grouped finance obligations and canonical notes only',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('LISTA-OBL-01'),
              status: const Value('OTVOREN'),
              troskoviJkp: const Value(1200),
              jkpPlacaSamostalno: const Value(false),
              napomena: const Value('Kanonska napomena'),
              napomenaPlacanja: const Value('Stara finansijska napomena'),
              penzionerNapomena: const Value('Stara statusna napomena'),
            ),
          );
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();
      final prepared = const ListaPdfDataBuilder().build(
        predmet: predmet,
        iriuStavke: const [],
        firma: await db.select(db.firmaPodaci).getSingle(),
        app: await db.select(db.appPodesavanja).getSingle(),
        savetnik: null,
      );

      final finance = prepared.podsetnikChecklist;
      expect(
        finance.map((item) => item.label),
        containsAll(['FINANSIJE', 'PLATITI RAČUN', 'NAPLATITI OBAVEZE']),
      );
      expect(
        finance.firstWhere((item) => item.label == 'PLATITI RAČUN').parentLabel,
        'FINANSIJE',
      );
      expect(
        finance
            .firstWhere((item) => item.label == 'NAPLATITI OBAVEZE')
            .parentLabel,
        'FINANSIJE',
      );
      expect(
        finance.firstWhere((item) => item.label == 'PLATITI RAČUN').context,
        isNotEmpty,
      );
      expect(
        finance.firstWhere((item) => item.label == 'NAPLATITI OBAVEZE').context,
        isNotEmpty,
      );
      expect(finance.any((item) => item.label.contains('finance.')), isFalse);
      expect(prepared.napomene, hasLength(1));
      expect(prepared.napomene.single.value, 'Kanonska napomena');
      expect(
        prepared.napomene.any((note) => note.value.contains('Stara')),
        isFalse,
      );
    },
  );

  test(
    'LISTA carries every non-empty ribbon text with its flower row',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(brojPredmeta: const Value('LISTA-CV-01')),
          );
      for (final row in [
        ('Cveće 1', 'Počivaj u miru'),
        ('Cveće 2', 'Sa ljubavlju'),
        ('Cveće 3', ''),
      ]) {
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: id,
                interniNaziv: IriuK.cvece,
                nazivPrikaz: Value(row.$1),
                tekstTrake: Value(row.$2),
              ),
            );
      }
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();
      final prepared = const ListaPdfDataBuilder().build(
        predmet: predmet,
        iriuStavke: await (db.select(
          db.iriu,
        )..where((row) => row.predmetId.equals(id))).get(),
        firma: await db.select(db.firmaPodaci).getSingle(),
        app: await db.select(db.appPodesavanja).getSingle(),
        savetnik: null,
      );
      final items = prepared.iriuItems;

      expect(items.map((item) => item.tekstTrake), [
        'Počivaj u miru',
        'Sa ljubavlju',
        '',
      ]);
      final checklistParent = prepared.podsetnikChecklist.singleWhere(
        (item) => item.label == 'CVEĆE',
      );
      expect(checklistParent.group, isTrue);
      final flowerChild = prepared.podsetnikChecklist.singleWhere(
        (item) => item.label == 'Poručiti cveće',
      );
      expect(flowerChild.parentLabel, 'CVEĆE');
      expect(flowerChild.context, [
        'Cveće 1\nTraka: Počivaj u miru',
        'Cveće 2\nTraka: Sa ljubavlju',
        'Cveće 3',
      ]);
    },
  );

  test('LISTA uses concise urn and ashes parent/child wording', () async {
    for (final placement in ['POLAGANJE_URNE', 'RASIPANJE_PEPELA']) {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: Value('LISTA-URN-$placement'),
              status: const Value('OTVOREN'),
              ime: const Value('Ana'),
              prezime: const Value('Jovanović'),
              vrstaCeremonije: const Value('KREMACIJA'),
              tipPolaganja: Value(placement),
              grobljePolaganjaUrne: const Value('Novo groblje'),
            ),
          );
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();
      final checklist = const ListaPdfDataBuilder()
          .build(
            predmet: predmet,
            iriuStavke: const [],
            firma: await db.select(db.firmaPodaci).getSingle(),
            app: await db.select(db.appPodesavanja).getSingle(),
            savetnik: null,
          )
          .podsetnikChecklist;
      final expectedParent = placement == 'RASIPANJE_PEPELA'
          ? 'RASIPANJE PEPELA'
          : 'POLAGANJE URNE';
      final expectedChild = placement == 'RASIPANJE_PEPELA'
          ? 'Zakazati rasipanje pepela'
          : 'Zakazati polaganje urne';
      final parent = checklist.singleWhere(
        (item) => item.label == expectedParent,
      );
      final child = checklist.singleWhere(
        (item) => item.label == expectedChild,
      );
      expect(parent.group, isTrue);
      expect(child.parentLabel, expectedParent);
      expect(child.context, ['Groblje polaganja urne: Novo groblje']);
      expect(
        checklist.any((item) => item.label.startsWith('ZA Ana Jovanović')),
        isFalse,
      );
    }
  });

  test(
    'LISTA preserves every grouped and synthetic PODSETNIK family',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('LISTA-FAMILY-01'),
              status: const Value('OTVOREN'),
              ime: const Value('Ana'),
              prezime: const Value('Jovanović'),
              vrstaCeremonije: const Value('KREMACIJA'),
              tipPolaganja: const Value('POLAGANJE_URNE'),
              grobljePolaganjaUrne: const Value('Novo groblje'),
              opelo: const Value('DA'),
              obavestitiSvestenika: const Value('DA'),
              opeloMesto: const Value('CRKVA NA GROBLJU'),
              vremeOpela: const Value('10:30'),
              vojniPenzioner: const Value('DA'),
              vojnePocasti: const Value('DA'),
              posmrtnaPomoc: const Value('DA'),
              penzionerSrbije: const Value('DA'),
              narucilacRefundira: const Value('NE'),
              bracnoStanje: const Value('OZENJEN'),
              bracniDrugOstvarujePravo: const Value('DA'),
              troskoviJkp: const Value(1200),
              jkpPlacaSamostalno: const Value(false),
              partePotrebna: const Value(true),
            ),
          );
      final categories = <String>[
        IriuK.kompletZaOpelo,
        IriuK.sanduk,
        IriuK.slika,
        IriuK.crnina,
        IriuK.cvece,
        IriuK.cituljaP,
        IriuK.cituljaNo,
      ];
      for (var i = 0; i < categories.length; i++) {
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: id,
                interniNaziv: categories[i],
                nazivPrikaz: Value('Izabrani artikal ${i + 1}'),
                portableOccurrenceId:
                    categories[i] == IriuK.cituljaP ||
                        categories[i] == IriuK.cituljaNo
                    ? Value('lista-citulja-$i')
                    : const Value.absent(),
              ),
            );
      }
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();
      final iriu = await (db.select(
        db.iriu,
      )..where((row) => row.predmetId.equals(id))).get();
      final checklist = const ListaPdfDataBuilder()
          .build(
            predmet: predmet,
            iriuStavke: iriu,
            firma: await db.select(db.firmaPodaci).getSingle(),
            app: await db.select(db.appPodesavanja).getSingle(),
            savetnik: null,
          )
          .podsetnikChecklist;

      const expectedPairs = <String, String>{
        'FINANSIJE': 'PLATITI RAČUN',
        'OPELO': 'Obavestiti sveštenika',
        'VOJNE POČASTI': 'Obavestiti nadležnu službu',
        'REFUNDACIJA PIO': 'Podneti zahtev PIO',
        'PORODIČNA PENZIJA': 'Podneti zahtev za porodičnu penziju',
        'POSMRTNA POMOĆ': 'Podneti zahtev za posmrtnu pomoć',
        'PARTE': 'Spremiti parte',
        'OPREMA': 'Spremiti opremu',
        'SLIKA': 'Spremiti sliku',
        'CRNINA': 'Spremiti crninu',
        'CVEĆE': 'Poručiti cveće',
        'ČITULJA': 'ČITULJA POLITIKA',
        'POLAGANJE URNE': 'Zakazati polaganje urne',
      };
      for (final pair in expectedPairs.entries) {
        final parent = checklist.singleWhere((item) => item.label == pair.key);
        final child = checklist.singleWhere((item) => item.label == pair.value);
        expect(parent.group, isTrue, reason: pair.key);
        expect(child.parentLabel, pair.key, reason: pair.value);
      }
      expect(
        checklist
            .where((item) => item.label == 'NAPLATITI OBAVEZE')
            .single
            .parentLabel,
        'FINANSIJE',
      );
      expect(
        checklist
            .where((item) => item.label == 'Spremiti komplet za opelo')
            .single
            .parentLabel,
        'OPELO',
      );
      expect(
        checklist
            .where((item) => item.label == 'Obavestiti sveštenika')
            .single
            .context,
        ['Mesto opela: Crkva na groblju', 'Vreme opela: 10:30'],
      );
      expect(
        checklist
            .where((item) => item.label == 'ČITULJA NOVOSTI')
            .single
            .parentLabel,
        'ČITULJA',
      );
      expect(
        checklist
            .where((item) => item.label == 'ČITULJA POLITIKA')
            .single
            .context,
        ['Izabrani artikal 6'],
      );
      expect(
        checklist.any(
          (item) =>
              RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$').hasMatch(item.label),
        ),
        isFalse,
      );
      expect(
        checklist
            .expand((item) => item.context)
            .any(
              (line) => line.contains('ceremony.') || line.contains('goods.'),
            ),
        isFalse,
      );
    },
  );

  test(
    'LISTA preserves manual obligation text without persistence writes',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('LISTA-MANUAL-01'),
              status: const Value('OTVOREN'),
            ),
          );
      final repository = PodsetnikObligationRepository(db);
      await repository.addManualObligation(
        predmetId: id,
        text: 'Poneti porodični dokument u grobljansku kancelariju',
        actorRole: 'SAVETNIK',
      );
      final rules = await repository.manualRulesForPredmetProjection(id);
      expect(
        rules.map((rule) => rule.stableRuleId),
        contains('special.manual'),
      );
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();
      final checklist = const ListaPdfDataBuilder()
          .build(
            predmet: predmet,
            iriuStavke: const [],
            firma: await db.select(db.firmaPodaci).getSingle(),
            app: await db.select(db.appPodesavanja).getSingle(),
            savetnik: null,
            additionalObligations: rules,
          )
          .podsetnikChecklist;
      expect(checklist.any((item) => item.label == 'POSEBNE OBAVEZE'), isTrue);
      expect(
        checklist.any(
          (item) =>
              item.label ==
              'Poneti porodični dokument u grobljansku kancelariju',
        ),
        isTrue,
      );
      expect(
        checklist.any((item) => item.label.contains('special.manual.')),
        isFalse,
      );
    },
  );

  test('dense LISTA export renders the planned two-page document', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('LISTA-DENSE-01'),
            status: const Value('OTVOREN'),
            vrstaCeremonije: const Value('SAHRANA'),
            opelo: const Value('DA'),
            obavestitiSvestenika: const Value('DA'),
            penzionerSrbije: const Value('DA'),
            vojniPenzioner: const Value('DA'),
            vojnePocasti: const Value('DA'),
            posmrtnaPomoc: const Value('DA'),
            narucilacRefundira: const Value('NE'),
            bracnoStanje: const Value('OZENJEN'),
            bracniDrugOstvarujePravo: const Value('DA'),
            troskoviJkp: const Value(1250),
            partePotrebna: const Value(true),
            sahranaVanSrbije: const Value(true),
            docekPosmrtnihOstataka: const Value(true),
            napomena: const Value('Kanonska napomena za gusti LISTA dokument.'),
          ),
        );
    final categories = <String>[
      IriuK.kompletZaOpelo,
      IriuK.sanduk,
      IriuK.slika,
      IriuK.crnina,
      IriuK.cvece,
      IriuK.cituljaP,
    ];
    for (var index = 0; index < categories.length; index++) {
      final category = categories[index];
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: id,
              interniNaziv: category,
              nazivPrikaz: Value(
                category == IriuK.cvece ? 'Cveće ${index + 1}' : category,
              ),
              portableOccurrenceId: category == IriuK.cituljaP
                  ? const Value('dense-citulja-1')
                  : const Value.absent(),
              tekstTrake: category == IriuK.cvece
                  ? const Value('Sa ljubavlju, porodica i prijatelji')
                  : const Value.absent(),
            ),
          );
    }
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(id))).getSingle();
    final prepared = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: await (db.select(
        db.iriu,
      )..where((row) => row.predmetId.equals(id))).get(),
      firma: await db.select(db.firmaPodaci).getSingle(),
      app: await db.select(db.appPodesavanja).getSingle(),
      savetnik: null,
    );

    expect(prepared.podsetnikChecklist.length, greaterThan(7));
    final pdf = await buildListaPdfBytesForTesting(preparedData: prepared);
    final source = latin1.decode(pdf, allowInvalid: true);
    expect(source, startsWith('%PDF-'));
    expect(RegExp(r'/Type\s*/Page\b').allMatches(source), hasLength(2));
  });
}
