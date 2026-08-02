import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'SCENARIO engine applies rules and removes its stale rows only',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetRepository = PredmetiRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
      );
      final iRiu = IriuRepository(db);
      final manualId = await iRiu.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_TEST',
        nazivPrikaz: 'Ručna stavka',
      );
      const scenario = ScenarioDefinition(
        id: 'DOM',
        name: 'Dom za stare',
        condition: ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: ['DOM ZA STARE'],
          ),
        ),
        consequences: [
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.hladnjaca,
            action: ScenarioConsequenceAction.recommended,
          ),
        ],
      );
      var predmet = await predmetRepository.getPredmet(predmetId);
      final first = await iRiu.syncScenarioRows(
        predmetId: predmetId,
        predmet: predmet,
        scenarios: [scenario],
        osnovniPaket: const {IriuK.sanduk},
      );
      expect(
        first.addedCategories,
        containsAll([IriuK.sanduk, IriuK.hladnjaca]),
      );
      expect(
        (await iRiu.getIriu(predmetId)).map((row) => row.id),
        contains(manualId),
      );

      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(mestoSmrti: Value('BOLNICA')),
      );
      predmet = await predmetRepository.getPredmet(predmetId);
      final second = await iRiu.syncScenarioRows(
        predmetId: predmetId,
        predmet: predmet,
        scenarios: const [],
        osnovniPaket: const {IriuK.sanduk},
      );
      expect(second.removedCategories, contains(IriuK.hladnjaca));
      expect(
        (await iRiu.getIriu(predmetId)).map((row) => row.interniNaziv),
        containsAll(['RUCNO_TEST', IriuK.sanduk]),
      );
      expect(
        (await iRiu.getIriu(
          predmetId,
        )).any((row) => row.interniNaziv == IriuK.hladnjaca),
        isFalse,
      );
    },
  );
}
