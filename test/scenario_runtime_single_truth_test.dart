import 'dart:io';

// The production condition factory is intentionally exercised as written.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('SCENARIO is the only source of the basic package', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scenarios = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );
    final module = await scenarios.ensureModuleAndDefaults();
    final base = scenarios.readOsnovniPaket(module);
    expect(base, hasLength(9));

    final catalogFlag = await (db.select(db.iriuKatalogConfig)
          ..where((row) => row.interniNaziv.equals('CVECE')))
        .getSingle();
    // Historical value may remain in the compatibility column; it is not
    // consulted by runtime initialization.
    expect(catalogFlag.osnovnaUSvakomPredmetu, isTrue);

    final predmeti = PredmetiRepository(db);
    final predmet = await predmeti.kreirajPredmet(savetnikId: 1);
    await predmeti.inicijalizujIriu(predmet);
    final rows = await (db.select(db.iriu)
          ..where((row) => row.predmetId.equals(predmet)))
        .get();
    expect(rows.map((row) => row.interniNaziv), contains('CVECE'));
  });

  test('basic and scenario packages cannot contain the same category', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
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
  });
}
