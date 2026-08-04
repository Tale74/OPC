import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('SCENARIO module opens with base package and scenario sections', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      await db.close();
    });

    await tester.pumpWidget(
      wrapForTest(
        ScenarioModuleScreen(podesavanjaRepository: PodesavanjaRepository(db)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('SCENARIO'), findsWidgets);
    expect(find.text('OSNOVNI PAKET'), findsOneWidget);
    expect(find.text('SCENARIJI'), findsOneWidget);
    expect(find.text('SCENARIJI PO MESTU SMRTI'), findsOneWidget);
    expect(find.text('MESTO SMRTI'), findsOneWidget);
    expect(find.text('DOM ZA STARE'), findsWidgets);
    expect(find.text('PRIVATNA BOLNICA'), findsWidgets);
    expect(find.text('DRUGO'), findsWidgets);
    expect(find.text('DODATNI PAKETI'), findsOneWidget);
    expect(find.text('SAHRANA VAN SRBIJE'), findsWidgets);
    expect(
      find.byKey(const ValueKey<String>('scenario-branch-SAHRANA_VAN_SRBIJE')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('scenario-branch-PRIVATNA_BOLNICA')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('scenario-branch-DRUGO')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Modul SCENARIO uređuje listu osnovnih i dodatnih stavki robe i usluga za automatski pregled i obračun prema mestu smrti i drugim uslovima.',
      ),
      findsOneWidget,
    );
    expect(find.text('POSLOVNA HIJERARHIJA'), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.text('DODAJ NOVI SCENARIO'), findsOneWidget);
    for (final forbidden in [
      'PRIKAŽI SAŽETAK ODLUKE',
      'PROVERI NA PRIMERU',
      'NAPRAVI KOPIJU',
      'STAVI SCENARIO VAN UPOTREBE',
    ]) {
      expect(find.text(forbidden), findsNothing, reason: forbidden);
    }
  });

  testWidgets(
    'existing scenario editor uses one caption per condition field and shows hierarchy',
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
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        await db.close();
      });

      await tester.pumpWidget(
        wrapForTest(
          ScenarioModuleScreen(
            podesavanjaRepository: PodesavanjaRepository(db),
          ),
        ),
      );
      for (var index = 0; index < 30; index++) {
        if (find
            .byKey(const ValueKey<String>('scenario-edit-BOLNICA'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }

      await tester.tap(
        find.byKey(const ValueKey<String>('scenario-edit-BOLNICA')),
      );
      await tester.pumpAndSettle();

      expect(find.text('POSLOVNA HIJERARHIJA'), findsOneWidget);
      expect(find.text('NADUSLOV'), findsOneWidget);
      expect(find.text('DODAJ PODUSLOV'), findsOneWidget);
      expect(find.text('OPERATOR'), findsNothing);
      expect(find.text('STAVKE SCENARIJA'), findsOneWidget);
      expect(find.text('DOSTUPNE STAVKE'), findsOneWidget);
    },
  );
}
