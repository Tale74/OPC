import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('SCENARIO module seeds defaults as editable data', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );

    await repository.ensureModuleAndDefaults();
    final definitions = await repository.getDefinitions();

    expect(definitions, isNotEmpty);
    final module = await repository.ensureModule();
    expect(repository.readOsnovniPaket(module), hasLength(9));
    expect(
      repository.readOsnovniPaket(module),
      containsAll([
        'SANDUK',
        'OBELEZJE',
        'POKROV_GARNITURA',
        'PESKIR_ZA_KRST',
        'POSMRTNE_PARTE',
        'CRNINA',
        'AGENCIJSKE_USLUGE',
        'CVECE',
        'CITULJA_POLITIKA',
      ]),
    );
    expect(
      definitions.where((item) => item.jePodrazumevani).map((item) => item.id),
      containsAll([
        'STAN',
        'DOM_ZA_STARE',
        'ULICA_JAVNO_MESTO',
        'BOLNICA',
        'LIMENI_ULOZAK',
        'LEMOVANJE',
        'LOKALNO_GROBLJE',
        'OPELO',
        'BIOHAZARD',
        'SAHRANA_VAN_SRBIJE',
        'DOCEK_POSMRTNIH_OSTATAKA',
      ]),
    );
  });

  test('SCENARIO module persists the base package and a user rule', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(db);

    final module = await repository.ensureModule();
    await repository.saveOsnovniPaket({'SANDUK', 'CITULJE'});
    await repository.saveDefinition(
      id: 'BOLNICA_GRADSKO',
      version: 1,
      naziv: 'Bolnica i gradsko groblje',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: ['BOLNICA'],
        ),
      ),
      consequences: const [
        ScenarioConsequence(
          katalogCategoryInternalName: 'SANDUK',
          action: ScenarioConsequenceAction.recommended,
        ),
      ],
      jePodrazumevani: true,
    );

    final savedModule =
        await (db.select(
              db.scenarioModules,
            )..where((row) => row.id.equals(ScenarioModuleRepository.moduleId)))
            .getSingle();
    expect(repository.readOsnovniPaket(savedModule), {'CITULJE', 'SANDUK'});

    final saved = await (db.select(
      db.scenarioDefinitions,
    )..where((row) => row.id.equals('BOLNICA_GRADSKO'))).getSingle();
    final definition = repository.definitionFromRecord(saved);
    expect(definition.name, 'Bolnica i gradsko groblje');
    expect(
      definition.consequences.single.katalogCategoryInternalName,
      'SANDUK',
    );
    expect(module.id, ScenarioModuleRepository.moduleId);
  });
}
