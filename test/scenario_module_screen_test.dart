import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:drift/drift.dart' show Value;

import 'test_bootstrap.dart';

void main() {
  testWidgets('SCENARIO module opens with base package and scenario sections', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedScenarioCatalogForTest(db);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await db.close();
      await Future<void>.delayed(const Duration(seconds: 5));
    });

    await tester.pumpWidget(
      wrapForTest(
        ScenarioModuleScreen(podesavanjaRepository: PodesavanjaRepository(db)),
      ),
    );
    while (find
        .byKey(const ValueKey('scenario-card-osnovni-paket'))
        .evaluate()
        .isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('SCENARIO'), findsWidgets);
    expect(
      find.byKey(const ValueKey('scenario-selected-predmet-view')),
      findsNothing,
    );
    expect(find.text('OSNOVNI PAKET'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('scenario-card-osnovni-paket')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('scenario-card-scenariji')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('scenario-card-new-scenario')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('scenario-card-open-predmeti')),
      findsOneWidget,
    );
    expect(find.text('Nema otvorenih PREDMETA'), findsOneWidget);
    expect(find.text('POSTOJEĆI SCENARIJI'), findsNothing);
    expect(find.text('MESTO SMRTI'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('scenario-open-scenariji')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byKey(const ValueKey('scenario-management-context')),
      findsOneWidget,
    );
    expect(find.text('POSTOJEĆI SCENARIJI'), findsOneWidget);
    expect(find.text('MESTO SMRTI'), findsOneWidget);
    expect(find.text('DODATNI SCENARIJI'), findsNothing);
    expect(find.text('STAN'), findsOneWidget);
    expect(find.text('POSLOVNA HIJERARHIJA'), findsNothing);
    expect(find.text('DODATNI USLOVI'), findsNothing);
    expect(find.text('DODATNI PAKETI'), findsNothing);
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

    await tester.tap(find.byTooltip('ZATVORI'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.ensureVisible(
      find.byKey(const ValueKey('scenario-card-osnovni-paket')),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'UREDI').first);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Izmene važe samo za nove PREDMETE.'), findsOneWidget);
    expect(find.text('Spremanje preminulog lica'), findsOneWidget);
    expect(find.text('Spremanje pokojnika'), findsNothing);
    await tester.tap(find.text('ODUSTANI'));
    await tester.pump(const Duration(milliseconds: 500));
    while (find.byTooltip('ZATVORI').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('ZATVORI').last);
      await tester.pump(const Duration(milliseconds: 500));
    }
  });

  testWidgets(
    'legacy partial block is hidden and applied scenario is PREDMET scoped',
    // Moved to an isolated file to avoid NativeDatabase memory lifecycle
    // interference between multiple widget databases in one test isolate.
    skip: true,
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

  testWidgets(
    'OPEN selector keeps one selection and clears stale closed PREDMET',
    skip: Platform.environment['OPC_RUN_UI_FORENSIC'] != '1',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
      final predmeti = PredmetiRepository(db);
      final idA = await predmeti.kreirajPredmet(savetnikId: 1);
      final idB = await predmeti.kreirajPredmet(savetnikId: 1);
      final idClosed = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        idA,
        const PredmetiCompanion(brojPredmeta: Value('TEST4-A')),
      );
      await predmeti.azurirajPredmet(
        idB,
        const PredmetiCompanion(brojPredmeta: Value('TEST4-B')),
      );
      await predmeti.azurirajPredmet(
        idClosed,
        const PredmetiCompanion(
          brojPredmeta: Value('TEST4-CLOSED'),
          status: Value('ZATVOREN'),
        ),
      );

      await tester.pumpWidget(
        wrapForTest(
          ScenarioModuleScreen(
            podesavanjaRepository: PodesavanjaRepository(db),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('TEST4-A'), findsOneWidget);
      expect(find.textContaining('TEST4-B'), findsOneWidget);
      expect(find.textContaining('TEST4-CLOSED'), findsNothing);

      await tester.tap(find.byKey(ValueKey('scenario-open-predmet-$idA')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('scenario-open-predmet-$idB')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('scenario-selected-predmet-view')),
        findsOneWidget,
      );
      expect(find.text('PREDMET TEST4-B · OTVOREN'), findsOneWidget);
      final aTile = tester.widget<CheckboxListTile>(
        find.byKey(ValueKey('scenario-open-predmet-$idA')),
      );
      final bTile = tester.widget<CheckboxListTile>(
        find.byKey(ValueKey('scenario-open-predmet-$idB')),
      );
      expect(aTile.value, isFalse);
      expect(bTile.value, isTrue);

      await predmeti.azurirajPredmet(
        idB,
        const PredmetiCompanion(status: Value('ZATVOREN')),
      );
      await tester.tap(
        find.byKey(const ValueKey('scenario-open-predmet-refresh')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('scenario-selected-predmet-view')),
        findsNothing,
      );
      expect(find.textContaining('TEST4-B'), findsNothing);
    },
  );

  testWidgets(
    'two applied scenario cards keep independent PREDMET state',
    skip: Platform.environment['OPC_RUN_UI_FORENSIC'] != '1',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
      final predmeti = PredmetiRepository(db);
      final idA = await predmeti.kreirajPredmet(savetnikId: 1);
      final idB = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        idA,
        const PredmetiCompanion(
          brojPredmeta: Value('A-001'),
          uzrokSmrti: Value('NASILNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROBNICA'),
          opelo: Value('NE'),
        ),
      );
      await predmeti.azurirajPredmet(
        idB,
        const PredmetiCompanion(
          brojPredmeta: Value('B-002'),
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
        ),
      );
      await ScenarioModuleRepository(db).ensureModuleAndDefaults();

      await tester.pumpWidget(
        wrapForTest(
          Column(
            children: [
              PredmetAppliedScenarioCard(
                predmet: await predmeti.getPredmet(idA),
              ),
              PredmetAppliedScenarioCard(
                predmet: await predmeti.getPredmet(idB),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Scenario za PREDMET A-001'), findsOneWidget);
      expect(find.text('Scenario za PREDMET B-002'), findsOneWidget);
      expect(find.textContaining('NASILNA · STAN'), findsOneWidget);
      expect(find.textContaining('PRIRODNA · BOLNICA'), findsOneWidget);
    },
  );
}
