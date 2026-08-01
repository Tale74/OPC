import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';

import 'test_bootstrap.dart';

void main() {
  group('SCENARIO package contract', () {
    test('criteria select a scenario package from the PREDMET facts', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        mestoSmrti: 'BOLNICA',
        uzrokSmrti: 'PRIRODNA',
        tipGroblja: 'GRADSKO',
      );
      const scenario = ScenarioDefinition(
        id: 'hospital-gradsko',
        name: 'Bolnica i gradsko groblje',
        condition: ScenarioCondition.all([
          ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.mestoSmrti,
              operator: ScenarioCriterionOperator.equals,
              values: ['BOLNICA'],
            ),
          ),
          ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.uzrokSmrti,
              operator: ScenarioCriterionOperator.notEquals,
              values: ['ZARAZNA'],
            ),
          ),
          ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.tipGroblja,
              operator: ScenarioCriterionOperator.equals,
              values: ['GRADSKO'],
            ),
          ),
        ]),
        consequences: [
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.prevozDoGroblja,
            action: ScenarioConsequenceAction.required,
            order: 10,
          ),
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.limeniUlozak,
            action: ScenarioConsequenceAction.recommended,
            order: 20,
          ),
        ],
      );

      final resolution = const ScenarioPackageResolver().resolve(
        scenario: scenario,
        predmet: predmet,
        osnovniPaket: <String>{IriuK.sanduk},
      );

      expect(
        resolution.effectiveCategories,
        containsAll(<String>{
          IriuK.sanduk,
          IriuK.prevozDoGroblja,
          IriuK.limeniUlozak,
        }),
      );
      expect(
        resolution.scenarioCategories.map(
          (consequence) => consequence.katalogCategoryInternalName,
        ),
        <String>[IriuK.prevozDoGroblja, IriuK.limeniUlozak],
      );
    });

    test('non-matching criteria leave the base package unchanged', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        mestoSmrti: 'BOLNICA',
        uzrokSmrti: 'ZARAZNA',
        tipGroblja: 'GRADSKO',
      );
      const scenario = ScenarioDefinition(
        id: 'hospital-non-infectious',
        name: 'Bolnica bez zarazne smrti',
        condition: ScenarioCondition.all([
          ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.mestoSmrti,
              operator: ScenarioCriterionOperator.equals,
              values: ['BOLNICA'],
            ),
          ),
          ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.uzrokSmrti,
              operator: ScenarioCriterionOperator.notEquals,
              values: ['ZARAZNA'],
            ),
          ),
        ]),
        consequences: [
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.prevozDoGroblja,
            action: ScenarioConsequenceAction.required,
          ),
        ],
      );

      final resolution = const ScenarioPackageResolver().resolve(
        scenario: scenario,
        predmet: predmet,
        osnovniPaket: <String>{IriuK.sanduk},
      );

      expect(resolution.effectiveCategories, <String>{IriuK.sanduk});
      expect(resolution.scenarioCategories, isEmpty);
    });

    test(
      'scenario can suppress a base catalog category without manual rows',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(db);
        const scenario = ScenarioDefinition(
          id: 'without-sanduk',
          name: 'Scenario bez sanduka',
          condition: ScenarioCondition.all([]),
          consequences: [
            ScenarioConsequence(
              katalogCategoryInternalName: IriuK.sanduk,
              action: ScenarioConsequenceAction.suppressed,
            ),
          ],
        );

        final resolution = const ScenarioPackageResolver().resolve(
          scenario: scenario,
          predmet: predmet,
          osnovniPaket: <String>{IriuK.sanduk, IriuK.agencijskeUsluge},
        );

        expect(resolution.effectiveCategories, <String>{
          IriuK.agencijskeUsluge,
        });
        expect(resolution.suppressedCategories, contains(IriuK.sanduk));
      },
    );
  });
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  String mestoSmrti = 'STAN',
  String uzrokSmrti = 'PRIRODNA',
  String tipGroblja = 'GRADSKO',
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('SCENARIO-CONTRACT-001/2026'),
          datumKreiranja: const Value('2026-08-01T09:00:00.000'),
          mestoSmrti: Value(mestoSmrti),
          uzrokSmrti: Value(uzrokSmrti),
          tipGroblja: Value(tipGroblja),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}
