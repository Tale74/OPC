import 'dart:io';

// The production condition factory is intentionally exercised as written.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'OSNOVNI PAKET materialization snapshots fixed KATALOG price and amount',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.peskirZaKrst)))
          .write(const IriuKatalogConfigCompanion(cena: Value(42.5)));

      final predmeti = PredmetiRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.inicijalizujIriu(predmetId);

      final row =
          await (db.select(db.iriu)..where(
                (item) =>
                    item.predmetId.equals(predmetId) &
                    item.interniNaziv.equals(IriuK.peskirZaKrst),
              ))
              .getSingle();
      expect(row.cena, 42.5);
      expect(row.iznos, 42.5);
    },
  );

  test('SCENARIO is the only source of the basic package', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await seedScenarioCatalogForTest(db);
    final scenarios = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );
    final module = await scenarios.ensureModuleAndDefaults();
    final base = scenarios.readOsnovniPaket(module);
    expect(base, hasLength(11));

    final catalogFlag = await (db.select(
      db.iriuKatalogConfig,
    )..where((row) => row.interniNaziv.equals('CVECE'))).getSingle();
    // The legacy column is retained for compatibility only; SCENARIO owns
    // the active basic package and runtime never reads this value.
    expect(catalogFlag.osnovnaUSvakomPredmetu, isTrue);

    final predmeti = PredmetiRepository(db);
    final predmet = await predmeti.kreirajPredmet(savetnikId: 1);
    await predmeti.inicijalizujIriu(predmet);
    final rows = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmet))).get();
    expect(rows.map((row) => row.interniNaziv), contains('CVECE'));
  });

  test(
    'basic and scenario packages cannot contain the same category',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final scenarios = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      final module = await scenarios.ensureModuleAndDefaults();
      final base = scenarios.readOsnovniPaket(module);

      await expectLater(
        scenarios.saveDefinition(
          id: 'DUPLICATE_BASE',
          version: 1,
          naziv: 'Duplirana odluka',
          condition: ScenarioCondition.criterion(
            const ScenarioCriterion(
              field: ScenarioCriterionField.mestoSmrti,
              operator: ScenarioCriterionOperator.equals,
              values: ['STAN'],
            ),
          ),
          consequences: [
            ScenarioConsequence(
              katalogCategoryInternalName: base.first,
              action: ScenarioConsequenceAction.required,
              order: 10,
            ),
          ],
        ),
        throwsArgumentError,
      );
    },
  );
}
