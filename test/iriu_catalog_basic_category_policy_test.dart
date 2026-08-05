import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/financial_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('KATALOG osnovna category policy', () {
    test('fresh schema seeds fixed categories once with policy NE', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      expect(db.schemaVersion, 26);
      for (final internalName in IriuK.podesiveOsnovneSeedKategorije) {
        final rows = await (db.select(
          db.iriuKatalogConfig,
        )..where((row) => row.interniNaziv.equals(internalName))).get();
        expect(rows, hasLength(1));
        expect(rows.single.tip, 'FIKSNA');
        expect(rows.single.osnovnaUSvakomPredmetu, isFalse);
      }
    });

    test('new user category keeps the compatibility flag inert', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = PodesavanjaRepository(db);

      final disabled = await repo.dodajKorisnickaKategoriju(
        interniNaziv: 'KORISNIK_DISABLED',
        nazivPrikaz: 'Disabled',
        tip: 'FIKSNA',
      );
      final enabled = await repo.dodajKorisnickaKategoriju(
        interniNaziv: 'KORISNIK_ENABLED',
        nazivPrikaz: 'Enabled',
        tip: 'KATALOSKA',
        osnovnaUSvakomPredmetu: true,
      );

      expect(disabled.kategorija!.osnovnaUSvakomPredmetu, isFalse);
      expect(enabled.kategorija!.osnovnaUSvakomPredmetu, isFalse);
    });

    test(
      'policy changes affect only future PREDMETI and preserve order',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final katalogRepo = PodesavanjaRepository(db);
        final predmetiRepo = PredmetiRepository(db);

        await katalogRepo.dodajKorisnickaKategoriju(
          interniNaziv: 'KORISNIK_PRVI',
          nazivPrikaz: 'Prvi osnovni',
          tip: 'FIKSNA',
        );
        await katalogRepo.dodajKorisnickaKategoriju(
          interniNaziv: 'KORISNIK_DRUGI',
          nazivPrikaz: 'Drugi osnovni',
          tip: 'FIKSNA',
          osnovnaUSvakomPredmetu: true,
        );

        final beforeId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(beforeId);
        final beforeNames = await _internalNames(db, beforeId);
        expect(beforeNames.sublist(beforeNames.length - 2), <String>[
          IriuK.agencijskeUsluge,
          'KORISNIK_DRUGI',
        ]);

        await katalogRepo.azurirajKatalogStavku(
          'KORISNIK_PRVI',
          const IriuKatalogConfigCompanion(osnovnaUSvakomPredmetu: Value(true)),
        );
        expect(
          await _internalNames(db, beforeId),
          isNot(contains('KORISNIK_PRVI')),
        );

        final enabledId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(enabledId);
        expect(
          (await _internalNames(
            db,
            enabledId,
          )).sublist(IriuK.ugradjeneOsnovnePreAgencijskih.length),
          <String>[IriuK.agencijskeUsluge, 'KORISNIK_PRVI', 'KORISNIK_DRUGI'],
        );

        await katalogRepo.azurirajKatalogStavku(
          'KORISNIK_DRUGI',
          const IriuKatalogConfigCompanion(
            osnovnaUSvakomPredmetu: Value(false),
          ),
        );
        expect(await _internalNames(db, enabledId), contains('KORISNIK_DRUGI'));

        final disabledId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(disabledId);
        expect(await _internalNames(db, disabledId), contains('KORISNIK_PRVI'));
        expect(
          await _internalNames(db, disabledId),
          isNot(contains('KORISNIK_DRUGI')),
        );
      },
      skip:
          'Legacy KATALOG policy test; OSNOVNI PAKET now belongs to SCENARIO.',
    );

    test('manual row stays local and uses the existing cost model', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetiRepo = PredmetiRepository(db);
      final iriuRepo = IriuRepository(db);
      final firstId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
      await predmetiRepo.inicijalizujIriu(firstId);

      await iriuRepo.dodajStavku(
        predmetId: firstId,
        interniNaziv: 'RUCNO_FIKSNA_TEST',
        nazivPrikaz: 'Ručna stavka',
        kom: '2',
        iznos: 2500,
        redosled: await iriuRepo.sledeciredosled(firstId),
      );
      expect(
        await (db.select(
          db.iriuKatalogConfig,
        )..where((row) => row.interniNaziv.equals('RUCNO_FIKSNA_TEST'))).get(),
        isEmpty,
      );

      final predmet = await predmetiRepo.getPredmet(firstId);
      final snapshot = const PredmetIriuTruthService().evaluate(
        predmet: predmet,
        storedRows: await iriuRepo.getIriu(firstId),
      );
      expect(
        const FinancialTruthService().buildRobaIUsluge(snapshot).robaIUsluge,
        2500,
      );

      final secondId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
      await predmetiRepo.inicijalizujIriu(secondId);
      expect(
        await _internalNames(db, secondId),
        isNot(contains('RUCNO_FIKSNA_TEST')),
      );
    });

    test(
      'scenario rows precede built-in basics, agency and user basics',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final katalogRepo = PodesavanjaRepository(db);
        final predmetiRepo = PredmetiRepository(db);
        final iriuRepo = IriuRepository(db);
        await katalogRepo.dodajKorisnickaKategoriju(
          interniNaziv: 'KORISNIK_ORDER',
          nazivPrikaz: 'Order basic',
          tip: 'FIKSNA',
          osnovnaUSvakomPredmetu: true,
        );
        final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(predmetId);

        await iriuRepo.dodajStavku(
          predmetId: predmetId,
          interniNaziv: IriuK.iznosenje,
          nazivPrikaz: IriuK.naziviPrikaz[IriuK.iznosenje]!,
          redosled: await iriuRepo.sledeciredosled(predmetId),
        );

        final names = await _internalNames(db, predmetId);
        expect(names.first, IriuK.iznosenje);
        expect(
          names.indexOf(IriuK.agencijskeUsluge),
          greaterThan(names.indexOf(IriuK.cituljaP)),
        );
        expect(
          names.indexOf('KORISNIK_ORDER'),
          greaterThan(names.indexOf(IriuK.agencijskeUsluge)),
        );
        expect(names.toSet(), hasLength(names.length));
      },
      skip: 'Legacy ordering test; OSNOVNI PAKET now belongs to SCENARIO.',
    );
  });

  test('KATALOG owns the policy control and manual IRiU does not', () async {
    final katalogSource = await File(
      'lib/features/podesavanja/presentation/katalog_tab.dart',
    ).readAsString();
    final iriuSource = await File(
      'lib/features/predmeti/presentation/segments/iriu_segment.dart',
    ).readAsString();

    expect(katalogSource, isNot(contains('Osnovna u svakom PREDMETU')));
    expect(
      katalogSource,
      isNot(contains('bool _osnovnaUSvakomPredmetu = false')),
    );
    expect(iriuSource, isNot(contains('Osnovna u svakom PREDMETU')));
    expect(iriuSource, isNot(contains('dodajKorisnickaKategoriju(')));
  });
}

Future<List<String>> _internalNames(AppDatabase db, int predmetId) async {
  final rows =
      await (db.select(db.iriu)
            ..where((row) => row.predmetId.equals(predmetId))
            ..orderBy([(row) => OrderingTerm.asc(row.redosled)]))
          .get();
  return rows.map((row) => row.interniNaziv).toList(growable: false);
}
