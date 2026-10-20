import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/catalog/katalog_category_baseline.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('clean start seeds the exact category baseline without articles', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final rows = await db.select(db.iriuKatalogConfig).get();
    expect(rows, hasLength(KatalogCategoryBaseline.entries.length));
    expect(
      rows.map((row) => row.interniNaziv).toSet(),
      KatalogCategoryBaseline.internalNames,
    );
    expect(await db.select(db.katalogArtikli).get(), isEmpty);
  });

  test('clean-start bootstrap is idempotent and preserves a renamed label', () async {
    final directory = await Directory.systemTemp.createTemp(
      'opc-category-baseline-',
    );
    final file = File('${directory.path}${Platform.pathSeparator}baseline.sqlite');
    try {
      final first = AppDatabase.forTesting(NativeDatabase(file));
      final repo = PodesavanjaRepository(first);
      await repo.azurirajKatalogStavku(
        IriuK.sanduk,
        const IriuKatalogConfigCompanion(nazivPrikaz: Value('Kovčeg')),
      );
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      final row = await (second.select(second.iriuKatalogConfig)
            ..where((item) => item.interniNaziv.equals(IriuK.sanduk)))
          .getSingle();
      expect(row.nazivPrikaz, 'Kovčeg');
      expect(
        (await second.select(second.iriuKatalogConfig).get()).length,
        KatalogCategoryBaseline.entries.length,
      );
      expect(await second.select(second.katalogArtikli).get(), isEmpty);
      await second.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('built-in scenario reference blocks physical category deletion', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scenarioRepo = ScenarioModuleRepository(db);
    await scenarioRepo.saveDefinition(
      id: 'MAP_TEST_BUILTIN',
      version: 1,
      naziv: 'Test built-in scenario',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: ['STAN'],
        ),
      ),
      consequences: const [
        ScenarioConsequence(
          katalogCategoryInternalName: IriuK.sanduk,
          action: ScenarioConsequenceAction.required,
        ),
      ],
      jePodrazumevani: true,
      status: 'PRIMENJEN',
    );

    final repo = PodesavanjaRepository(db);
    final status = await repo.proveriKategorijuZaLifecycleAkciju(
      IriuK.sanduk,
    );
    expect(status!.uScenariju, isTrue);
    expect(status.mozeFizickoBrisanje, isFalse);
    final outcome = await repo.ukloniIliDeaktivirajKorisnickuKategoriju(
      IriuK.sanduk,
    );
    expect(outcome.obrisana, isFalse);
    expect(outcome.deaktivirana, isTrue);
    expect(
      await (db.select(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.sanduk)))
          .getSingle(),
      isA<IriuKatalogConfigData>(),
    );
  });

  test('custom scenario retains category key after rename and blocks deletion', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = PodesavanjaRepository(db);
    const customKey = 'KORISNIK_CUSTOM_SCENARIO';
    final inserted = await repo.dodajKorisnickaKategoriju(
      interniNaziv: customKey,
      nazivPrikaz: 'Posebna usluga',
      tip: 'FIKSNA',
    );
    expect(inserted.uspeh, isTrue);

    final scenarioRepo = ScenarioModuleRepository(db);
    await scenarioRepo.saveDefinition(
      id: 'CUSTOM_SCENARIO_1',
      version: 1,
      naziv: 'Korisnički scenario',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: ['STAN'],
        ),
      ),
      consequences: const [
        ScenarioConsequence(
          katalogCategoryInternalName: customKey,
          action: ScenarioConsequenceAction.required,
        ),
      ],
      status: 'PRIMENJEN',
    );
    await repo.azurirajKatalogStavku(
      customKey,
      const IriuKatalogConfigCompanion(nazivPrikaz: Value('Izmenjena usluga')),
    );

    final definition = (await scenarioRepo.getDefinitions()).singleWhere(
      (item) => item.id == 'CUSTOM_SCENARIO_1',
    );
    final consequences = jsonDecode(definition.consequencesJson) as List;
    expect(
      (consequences.single as Map)['katalogCategoryInternalName'],
      customKey,
    );
    expect(
      (await repo.proveriKategorijuZaLifecycleAkciju(customKey))!.uScenariju,
      isTrue,
    );
    final outcome = await repo.ukloniIliDeaktivirajKorisnickuKategoriju(
      customKey,
    );
    expect(outcome.obrisana, isFalse);
    expect(outcome.deaktivirana, isTrue);
  });

  test('removing the last scenario reference restores existing delete rules',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = PodesavanjaRepository(db);
    const customKey = 'KORISNIK_DELETE_AFTER_SCENARIO';
    await repo.dodajKorisnickaKategoriju(
      interniNaziv: customKey,
      nazivPrikaz: 'Privremena usluga',
      tip: 'FIKSNA',
    );
    final scenarioRepo = ScenarioModuleRepository(db);
    await scenarioRepo.saveDefinition(
      id: 'CUSTOM_SCENARIO_DELETE',
      version: 1,
      naziv: 'Scenario za brisanje',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: ['STAN'],
        ),
      ),
      consequences: const [
        ScenarioConsequence(
          katalogCategoryInternalName: customKey,
          action: ScenarioConsequenceAction.required,
        ),
      ],
      status: 'PRIMENJEN',
    );
    await scenarioRepo.deleteDefinition('CUSTOM_SCENARIO_DELETE', 1);
    final status = await repo.proveriKategorijuZaLifecycleAkciju(customKey);
    expect(status!.uScenariju, isFalse);
    final outcome = await repo.ukloniIliDeaktivirajKorisnickuKategoriju(
      customKey,
    );
    expect(outcome.obrisana, isTrue);
    expect(outcome.deaktivirana, isFalse);
  });
}
