import 'dart:convert';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'individual transfer preserves intentional SCENARIO absence and presence',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      await seedScenarioCatalogForTest(source);
      await seedScenarioCatalogForTest(target);
      await _user(target, 1, 'IMPORTER', 'ADMINISTRATOR');

      final sourcePredmeti = PredmetiRepository(source);
      final sourceId = await sourcePredmeti.kreirajPredmet(savetnikId: 1);
      await sourcePredmeti.azurirajPredmet(
        sourceId,
        const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
      );
      const scenario = ScenarioDefinition(
        id: 'TRANSFER_FIDELITY',
        name: 'Transfer fidelity scenario',
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
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.prevozDoGroblja,
            action: ScenarioConsequenceAction.recommended,
          ),
        ],
      );

      final sourceIriu = IriuRepository(source);
      final sourcePredmet = await sourcePredmeti.getPredmet(sourceId);
      await sourceIriu.syncScenarioRows(
        predmetId: sourceId,
        predmet: sourcePredmet,
        scenarios: const [scenario],
        osnovniPaket: const {},
      );
      final sourceRows = await sourceIriu.getIriu(sourceId);
      final removed = sourceRows.singleWhere(
        (row) => row.interniNaziv == IriuK.hladnjaca,
      );
      await sourceIriu.obrisiStavkuSaLifecycleMemorijom(
        predmetId: sourceId,
        row: removed,
      );

      final json = jsonDecode(
        await serializePredmetJsonForTest(db: source, predmetId: sourceId),
      ) as Map<String, dynamic>;
      expect(json['schemaVersion'], 9);
      final lifecycle = json['iriuLifecycleDecisions'] as Map<String, dynamic>;
      expect(lifecycle['schemaVersion'], 1);
      expect(lifecycle['items'], hasLength(2));
      expect(
        (lifecycle['items'] as List).map((item) => item['interniNaziv']),
        everyElement(IriuK.hladnjaca),
      );

      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: 1,
      );
      final targetPredmeti = PredmetiRepository(target);
      final targetId = (await targetPredmeti.getSvePredmete()).single.id;
      final targetRows = await IriuRepository(target).getIriu(targetId);
      expect(
        targetRows.map((row) => row.interniNaziv),
        contains(IriuK.prevozDoGroblja),
      );
      expect(
        targetRows.map((row) => row.interniNaziv),
        isNot(contains(IriuK.hladnjaca)),
      );

      final decisions = await target
          .customSelect(
            'SELECT interni_naziv FROM iriu_lifecycle_decisions WHERE predmet_id = ?',
            variables: [Variable.withInt(targetId)],
          )
          .get();
      expect(
        decisions.map((row) => row.read<String>('interni_naziv')),
        everyElement(IriuK.hladnjaca),
      );

      final reopened = await targetPredmeti.getPredmet(targetId);
      final secondSync = await IriuRepository(target).syncScenarioRows(
        predmetId: targetId,
        predmet: reopened,
        scenarios: const [scenario],
        osnovniPaket: const {},
      );
      expect(secondSync.addedCategories, isEmpty);
      expect(
        (await IriuRepository(target).getIriu(targetId)).map(
          (row) => row.interniNaziv,
        ),
        isNot(contains(IriuK.hladnjaca)),
      );
    },
  );
}

Future<void> _user(AppDatabase db, int id, String name, String role) async {
  await db.into(db.korisnici).insert(
    KorisniciCompanion.insert(
      id: Value(id),
      imePrezime: name,
      uloga: role,
      pinHash: 'test-$id',
      datumKreiranja: '2026-08-22T00:00:00.000',
    ),
  );
}
