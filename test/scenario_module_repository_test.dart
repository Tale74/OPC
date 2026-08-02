import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
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
