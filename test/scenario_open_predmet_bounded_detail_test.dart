import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:drift/drift.dart' show Value;

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'bounded open-PREDMET detail keeps one selection and package semantics',
    (tester) async {
      final db = createTestDatabase();
      final scenarioRepository = ScenarioModuleRepository(db);
      await scenarioRepository.ensureModule();
      await scenarioRepository.saveDefinition(
        id: 'BOLNICA',
        version: 1,
        naziv: 'BOLNICA',
        condition: const ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: ['BOLNICA'],
          ),
        ),
        consequences: const [
          ScenarioConsequence(
            katalogCategoryInternalName: IriuK.prevozDoGroblja,
            action: ScenarioConsequenceAction.required,
          ),
        ],
        description: 'Bolnica dodaje prevoz do groblja.',
        jePodrazumevani: true,
        status: 'PRIMENJEN',
      );
      final predmeti = PredmetiRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          brojPredmeta: Value('080826-001'),
          uzrokSmrti: Value('NASILNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROBNICA'),
          opelo: Value('NE'),
        ),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });

      await tester.pumpWidget(
        wrapForTest(
          ScenarioModuleScreen(
            podesavanjaRepository: PodesavanjaRepository(db),
          ),
        ),
      );
      while (find
          .byKey(const ValueKey('scenario-card-osnovni-paket'))
          .evaluate()
          .isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      while (find.text('1 otvorenih PREDMETA').evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(
        find.byKey(const ValueKey('scenario-card-open-predmeti')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byKey(const ValueKey('scenario-open-predmet-context')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('scenario-open-predmet-list')),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(ValueKey('scenario-open-predmet-$predmetId')),
      );
      await tester.tap(
        find.byKey(ValueKey('scenario-open-predmet-$predmetId')),
      );
      while (find.text('PRIMENJENI SCENARIO PAKET').evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('DODATNI SCENARIJI'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('scenario-edit-BOLNICA')),
        findsNothing,
      );
      expect(find.text('Scenario za PREDMET 080826-001'), findsNothing);
      expect(find.text('PREDMET 080826-001 · OTVOREN'), findsOneWidget);
      expect(
        find.textContaining('NASILNA · STAN · SAHRANA · GRADSKO · GROBNICA'),
        findsAtLeastNWidgets(1),
      );
      if (Platform.environment['OPC_LEGACY_SNAPSHOT_TEST'] == '1') {
        expect(
          find.textContaining('PRIMENJENI SCENARIO SNAPSHOT'),
          findsOneWidget,
        );
      }
      expect(find.text('PRIMENJENO NA PREDMET'), findsAtLeastNWidgets(1));
      expect(find.text('PRIMENJENI SCENARIO PAKET'), findsOneWidget);
      expect(find.textContaining('SCENARIO_MAP_'), findsNothing);
      expect(find.textContaining('MAP_NASILNA_'), findsNothing);
      expect(find.text('Zaštitna i dodatna oprema'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('scenario-selected-edit')),
        findsNothing,
      );
      await tester.tap(find.byTooltip('ZATVORI').last);
      await tester.pump(const Duration(milliseconds: 500));
    },
  );
}
