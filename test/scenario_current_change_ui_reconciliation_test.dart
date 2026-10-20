import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/owner_scenario_policy_kernel.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/ceremonija_segment.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_segment.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/predmet_decision_controls.dart';

import 'test_bootstrap.dart';

void main() {
  const scenarioCause = 'NEDEFINISANA';
  testWidgets(
    'Narrow NEDEFINISANA PREDMET OPELO change reaches IRiU reconciliation',
    (tester) async {
      tester.view.physicalSize = const Size(540, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = createTestDatabase();
      final session = SessionService();
      var resourcesClosed = false;
      addTearDown(() async {
        if (!resourcesClosed) {
          session.dispose();
          await db.close();
        }
      });

      await seedScenarioCatalogForTest(db);
      final admin = await AuthRepository(
        db,
      ).kreirajPrvogAdmina(imePrezime: 'Scenario UI test', pin: '1234');
      session.prijavi(admin);
      final predmeti = PredmetiRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: admin.id);
      await predmeti.inicijalizujIriu(predmetId);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          ime: Value('Scenario'),
          prezime: Value('UI test'),
          uzrokSmrti: Value(scenarioCause),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
          sahranaVanSrbije: Value(false),
          docekPosmrtnihOstataka: Value(false),
          promenaSanduka: Value(false),
          status: Value('OTVOREN'),
        ),
      );
      final initialPredmet = await predmeti.getPredmet(predmetId);
      await predmeti.sacuvajPredmet(
        predmetId,
        korisnikId: admin.id,
        fallbackSnapshot: predmeti.snapshotZaSaveCommit(initialPredmet),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: PredmetScreen(
            predmetId: predmetId,
            predmetiRepo: predmeti,
            session: session,
            openCeremony: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open IRiU through the real Narrow section navigation to establish the
      // fixture's applied SCENARIO baseline at OPELO=NE.
      await _backToHub(tester);
      await tester.tap(find.text('Roba i usluge'));
      await tester.pumpAndSettle();
      expect(find.byType(IriuSegment), findsOneWidget);
      expect(
        (await _rowNames(db, predmetId)).contains(IriuK.kompletZaOpelo),
        isFalse,
      );

      final baselineSnapshot = await _snapshot(db, predmetId);
      expect(baselineSnapshot, isNotNull, reason: 'Baseline open must apply.');
      final baselineAssignment = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(baselineSnapshot!.snapshotJson) as Map<String, dynamic>,
      );
      expect(baselineAssignment.appliedEvaluationBaseline, isNotNull);
      expect(baselineAssignment.appliedEvaluationBaseline!.opelo, 'NE');
      expect(
        await IriuRepository(db).hasCompleteAppliedScenarioEvidence(predmetId),
        isTrue,
      );

      await _backToHub(tester);
      await tester.tap(find.text('Ceremonija'));
      await tester.pumpAndSettle();
      expect(_opeloSwitch(tester).value, isFalse);

      final opeloSwitchFinder = find.descendant(
        of: _opeloTile(),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(opeloSwitchFinder);
      await tester.pumpAndSettle();
      await tester.tap(opeloSwitchFinder);
      await tester.pump(const Duration(milliseconds: 700));
      await _backToHub(tester);
      final afterNavigationAt700ms = (await predmeti.getPredmet(predmetId)).opelo;
      await tester.tap(find.text('Ceremonija'));
      await tester.pumpAndSettle();
      expect(
        _opeloSwitch(tester).value,
        afterNavigationAt700ms == 'DA',
        reason: 'Fresh Ceremony entry should reflect persisted PREDMET state.',
      );

      // If the first navigation happened before persistence, finish the
      // normal save/debounce path through the real Ceremony control.
      if (afterNavigationAt700ms != 'DA') {
        final savedOpeloSwitchFinder = find.descendant(
          of: _opeloTile(),
          matching: find.byType(Switch),
        );
        await tester.ensureVisible(savedOpeloSwitchFinder);
        await tester.pumpAndSettle();
        await tester.tap(savedOpeloSwitchFinder);
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();
      }
      final persistedAfterSave = await predmeti.getPredmet(predmetId);
      expect(persistedAfterSave.opelo, 'DA');

      await _backToHub(tester);
      await tester.tap(find.text('Ceremonija'));
      await tester.pumpAndSettle();
      final parentInput = tester
          .widget<CeremonijuSegment>(find.byType(CeremonijuSegment))
          .initialData;
      expect(parentInput.opelo, 'DA');
      expect(_opeloSwitch(tester).value, isTrue);

      final iriuRepository = IriuRepository(db);
      final currentSnapshot = await _snapshot(db, predmetId);
      expect(currentSnapshot, isNotNull);
      final currentAssignment = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(currentSnapshot!.snapshotJson) as Map<String, dynamic>,
      );
      final baselineInput = currentAssignment.appliedEvaluationBaseline;
      expect(baselineInput, isNotNull);
      final parentNormalizedInput = OwnerScenarioInput.fromPredmet(parentInput);
      expect(parentNormalizedInput.isComplete, isTrue);
      expect(parentNormalizedInput.uzrokSmrti, scenarioCause);
      expect(
        parentNormalizedInput.hasSameEvaluationInputsAs(baselineInput!),
        isFalse,
      );

      await _backToHub(tester);
      await tester.tap(find.text('Roba i usluge'));
      await tester.pumpAndSettle();
      final mountedSegment = tester.widget<IriuSegment>(find.byType(IriuSegment));
      final mountInput = OwnerScenarioInput.fromPredmet(
        mountedSegment.predmetData,
      );
      expect(mountInput.uzrokSmrti, scenarioCause);
      expect(mountInput.isComplete, isTrue);
      expect(mountedSegment.predmetData.opelo, 'DA');
      expect(parentInput.opelo, mountedSegment.predmetData.opelo);
      final dialogVisible = find
          .textContaining('PROMENA USLOVA SCENARIJA')
          .evaluate()
          .isNotEmpty;
      final intent = await iriuRepository.scenarioOpenReconciliationIntent(
        predmetId: predmetId,
        currentPredmet: parentInput,
      );
      final currentRows = await iriuRepository.getIriu(predmetId);
      const expectedBiohazard = scenarioCause != 'PRIRODNA';
      final policySnapshot = const BusinessPolicyEvaluator()
          .evaluateForIriuTruth(mountedSegment.predmetData);
      final truthSnapshot = const PredmetIriuTruthService().evaluate(
        predmet: mountedSegment.predmetData,
        storedRows: currentRows,
      );
      final iznosenjeTruth = truthSnapshot.rows.singleWhere(
        (row) => row.storedRow.interniNaziv == IriuK.iznosenje,
      );
      expect(policySnapshot.requiresBiohazardPrecautions, expectedBiohazard);
      expect(iznosenjeTruth.active, isTrue);
      expect(iznosenjeTruth.biohazard, expectedBiohazard);
      expect(iznosenjeTruth.warning.isNotEmpty, expectedBiohazard);
      expect(
        currentRows.where((row) => row.interniNaziv == IriuK.kompletZaOpelo),
        isEmpty,
      );

      expect(
        intent.shouldReconcile,
        isTrue,
        reason: 'Open-time eligibility must accept the saved NE→DA change.',
      );
      expect(dialogVisible, isTrue, reason: 'Expected reconciliation preview.');
      expect(
        find.textContaining('Komplet za opelo'),
        findsOneWidget,
        reason: 'Preview must show the actual +1 consequence.',
      );
      await tester.tap(find.text('POTVRDI PROMENU'));
      await tester.pumpAndSettle();
      final appliedRows = await iriuRepository.getIriu(predmetId);
      expect(
        appliedRows.where((row) => row.interniNaziv == IriuK.kompletZaOpelo),
        hasLength(1),
      );

      // Dispose StreamBuilders while the widget-test binding is active, then
      // let Drift's deferred Timer.run stream cleanup finish before DB.close.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pump(Duration.zero);
      session.dispose();
      await db.close();
      resourcesClosed = true;
    },
  );
}

Finder _opeloTile() => find.ancestor(
  of: find.text('Opelo'),
  matching: find.byType(PredmetBooleanDecisionTile),
);

Switch _opeloSwitch(WidgetTester tester) => tester.widget<Switch>(
  find.descendant(of: _opeloTile(), matching: find.byType(Switch)),
);

Future<void> _backToHub(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<PredmetScenarioSnapshot?> _snapshot(AppDatabase db, int predmetId) =>
    (db.select(db.predmetScenarioSnapshots)
          ..where((row) => row.predmetId.equals(predmetId)))
        .getSingleOrNull();

Future<Set<String>> _rowNames(AppDatabase db, int predmetId) async =>
    (await (db.select(db.iriu)..where((row) => row.predmetId.equals(predmetId))).get())
        .map((row) => row.interniNaziv)
        .toSet();
