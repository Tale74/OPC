import 'dart:io';

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/owner_scenario_policy_kernel.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'incomplete first evaluation preserves OSNOVNI creation evidence until apply',
    () async {
      final counter = _ScenarioWriteCounter();
      final db = AppDatabase.forTesting(
        NativeDatabase.memory().interceptWith(counter),
      );
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.inicijalizujIriu(predmetId);
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final incomplete = await predmeti.getPredmet(predmetId);
      expect(OwnerScenarioInput.fromPredmet(incomplete).isComplete, isFalse);
      final initialRows = await iriu.getIriu(predmetId);
      final initialProvenance =
          await (db.select(db.iriuProvenance)..where(
                (row) =>
                    row.iriuId.isIn(initialRows.map((row) => row.id).toList()),
              ))
              .get();
      expect(initialRows, isNotEmpty);
      expect(initialRows.every((row) => !row.scenarioUpravlja), isTrue);
      expect(
        initialProvenance.every(
          (row) => row.moduleId == 'scenario' && row.origin == 'OSNOVNI_PAKET',
        ),
        isTrue,
      );
      counter.reset();

      final incompleteResult = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: incomplete,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        allowLegacyBaselineEstablishment: true,
      );

      expect(incompleteResult.changed, isFalse);
      expect(counter.writeCount, 0);
      expect(await iriu.getIriu(predmetId), _sameRowsAs(initialRows));
      expect(await (db.select(db.iriuProvenance)).get(), initialProvenance);
      expect(await _snapshotOrNull(db, predmetId) == null, isTrue);

      await _setBurialState(
        predmeti,
        predmetId,
        burialPlace: 'GROB',
        opelo: 'DA',
      );
      final complete = await predmeti.getPredmet(predmetId);
      expect(OwnerScenarioInput.fromPredmet(complete).isComplete, isTrue);
      final intent = await iriu.scenarioOpenReconciliationIntent(
        predmetId: predmetId,
        currentPredmet: complete,
      );
      expect(intent.shouldReconcile, isTrue);

      final preview = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: complete,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
        allowLegacyBaselineEstablishment:
            intent.allowLegacyBaselineEstablishment,
      );
      expect(preview.addedCategories, contains(IriuK.kompletZaOpelo));
      expect(await _snapshotOrNull(db, predmetId) == null, isTrue);
      expect(
        (await iriu.getIriu(predmetId)).every((row) => !row.scenarioUpravlja),
        isTrue,
      );

      final applied = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: complete,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        allowLegacyBaselineEstablishment:
            intent.allowLegacyBaselineEstablishment,
      );
      expect(applied.addedCategories, contains(IriuK.kompletZaOpelo));
      expect(
        (await iriu.getIriu(
          predmetId,
        )).where((row) => row.interniNaziv == IriuK.kompletZaOpelo),
        hasLength(1),
      );
      final assignment = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode((await _snapshot(db, predmetId)).snapshotJson)
            as Map<String, dynamic>,
      );
      expect(
        assignment.appliedEvaluationBaseline!.hasSameEvaluationInputsAs(
          OwnerScenarioInput.fromPredmet(complete),
        ),
        isTrue,
      );
      expect(await iriu.hasCompleteAppliedScenarioEvidence(predmetId), isTrue);
      expect(
        (await iriu.scenarioOpenReconciliationIntent(
          predmetId: predmetId,
          currentPredmet: complete,
        )).shouldReconcile,
        isFalse,
      );
    },
  );

  test(
    'poisoned OSNOVNI ownership recovers current state for OTVOREN and ZATVOREN',
    () async {
      for (final status in <String>['OTVOREN', 'ZATVOREN']) {
        final db = createTestDatabase();
        addTearDown(db.close);
        await seedScenarioCatalogForTest(db);
        final predmeti = PredmetiRepository(db);
        final scenarioRepository = ScenarioModuleRepository(db);
        final iriu = IriuRepository(db);
        final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
        await predmeti.inicijalizujIriu(predmetId);
        final baseRows = await iriu.getIriu(predmetId);
        for (final row in baseRows) {
          await iriu.azurirajStavku(
            row.id,
            const IriuCompanion(scenarioUpravlja: Value(true)),
          );
        }
        await _setBurialState(
          predmeti,
          predmetId,
          burialPlace: 'GROB',
          opelo: 'DA',
        );
        await (db.update(db.predmeti)..where((row) => row.id.equals(predmetId)))
            .write(PredmetiCompanion(status: Value(status)));
        final manualId = await iriu.dodajStavku(
          predmetId: predmetId,
          interniNaziv: 'MANUAL_RECOVERY_$status',
          nazivPrikaz: 'Ručni red $status',
        );
        final current = await predmeti.getPredmet(predmetId);
        final module = await scenarioRepository.ensureModuleAndDefaults();
        final scenarios = await scenarioRepository.getActiveDefinitions();

        expect(await _snapshotOrNull(db, predmetId) == null, isTrue);
        expect(
          (await iriu.getIriu(predmetId)).where((row) => row.scenarioUpravlja),
          hasLength(baseRows.length),
        );
        final intent = await iriu.scenarioOpenReconciliationIntent(
          predmetId: predmetId,
          currentPredmet: current,
        );
        expect(intent.shouldReconcile, isTrue, reason: 'status=$status');
        expect(
          intent.allowLegacyBaselineEstablishment,
          isTrue,
          reason: 'status=$status',
        );

        final preview = await iriu.syncScenarioRows(
          predmetId: predmetId,
          predmet: current,
          scenarios: scenarios,
          osnovniPaket: scenarioRepository.readOsnovniPaket(module),
          applyScenarioChange: false,
          allowLegacyBaselineEstablishment:
              intent.allowLegacyBaselineEstablishment,
        );
        expect(preview.addedCategories, contains(IriuK.kompletZaOpelo));
        expect(preview.addedCategories, contains(IriuK.prevozDoGroblja));
        expect(await _snapshotOrNull(db, predmetId) == null, isTrue);

        await iriu.syncScenarioRows(
          predmetId: predmetId,
          predmet: current,
          scenarios: scenarios,
          osnovniPaket: scenarioRepository.readOsnovniPaket(module),
          allowLegacyBaselineEstablishment:
              intent.allowLegacyBaselineEstablishment,
        );
        final rows = await iriu.getIriu(predmetId);
        expect(
          rows.where((row) => row.interniNaziv == IriuK.kompletZaOpelo),
          hasLength(1),
          reason: 'status=$status',
        );
        expect(
          rows.where((row) => row.interniNaziv == IriuK.prevozDoGroblja),
          hasLength(1),
          reason: 'status=$status',
        );
        expect(rows.any((row) => row.id == manualId), isTrue);
        expect(
          await iriu.hasCompleteAppliedScenarioEvidence(predmetId),
          isTrue,
        );
        final applied = ScenarioAssignmentSnapshot.fromJsonMap(
          jsonDecode((await _snapshot(db, predmetId)).snapshotJson)
              as Map<String, dynamic>,
        );
        expect(applied.appliedEvaluationBaseline != null, isTrue);
        expect(
          applied.appliedEvaluationBaseline!.hasSameEvaluationInputsAs(
            OwnerScenarioInput.fromPredmet(current),
          ),
          isTrue,
        );
      }
    },
  );

  test(
    'OPELO consequence is scenario-owned, removable, and stable across reopen',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'opc_scenario_opelo_ownership_',
      );
      final file = File('${root.path}${Platform.pathSeparator}opc.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        if (await root.exists()) await root.delete(recursive: true);
      });
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROB',
        opelo: 'NE',
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).where((row) => row.interniNaziv == IriuK.kompletZaOpelo),
        isEmpty,
      );

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROB',
        opelo: 'DA',
      );
      final beforePreview = await iriuRepository.getIriu(predmetId);
      final beforeSnapshot = await _snapshot(db, predmetId);
      final preview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(preview.addedCategories, [IriuK.kompletZaOpelo]);
      expect(preview.removedCategories, isEmpty);
      expect(
        await iriuRepository.getIriu(predmetId),
        _sameRowsAs(beforePreview),
      );
      expect(await _snapshot(db, predmetId), beforeSnapshot);

      final applied = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(applied.addedCategories, [IriuK.kompletZaOpelo]);
      final managed = await _rowByName(db, predmetId, IriuK.kompletZaOpelo);
      expect(managed.scenarioUpravlja, isTrue);
      final provenance = await (db.select(
        db.iriuProvenance,
      )..where((row) => row.iriuId.equals(managed.id))).getSingle();
      final appliedSnapshot = await _snapshot(db, predmetId);
      expect(provenance.moduleId, 'scenario');
      expect(provenance.origin, 'SCENARIO_PAKET');
      expect(provenance.scenarioId, appliedSnapshot.scenarioId);
      expect(provenance.ruleId, IriuK.kompletZaOpelo);

      final stable = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(stable.addedCategories, isEmpty);
      expect(stable.removedCategories, isEmpty);
      expect(stable.scenarioSnapshotChanged, isFalse);
      expect(await _snapshot(db, predmetId), appliedSnapshot);

      final manualId = await iriuRepository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: IriuK.kompletZaOpelo,
        nazivPrikaz: 'Komplet za opelo',
      );
      final manual = (await iriuRepository.getIriu(
        predmetId,
      )).singleWhere((row) => row.id == manualId);
      expect(manual.scenarioUpravlja, isFalse);
      expect(
        await (db.select(
          db.iriuProvenance,
        )..where((row) => row.iriuId.equals(manualId))).get(),
        isEmpty,
      );

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROB',
        opelo: 'NE',
      );
      final removalPreview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(removalPreview.addedCategories, isEmpty);
      expect(removalPreview.removedCategories, [IriuK.kompletZaOpelo]);
      expect(removalPreview.pendingUserDecisionRows.single.id, managed.id);
      final removed = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        conditionChangeDecisions: {managed.id: false},
      );
      expect(removed.removedCategories, [IriuK.kompletZaOpelo]);
      final remaining = (await iriuRepository.getIriu(
        predmetId,
      )).where((row) => row.interniNaziv == IriuK.kompletZaOpelo).toList();
      expect(remaining.map((row) => row.id), [manualId]);
      expect(remaining.single.scenarioUpravlja, isFalse);
      expect(
        await (db.select(
          db.iriuProvenance,
        )..where((row) => row.iriuId.equals(manualId))).get(),
        isEmpty,
      );

      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final reopenedRows = await IriuRepository(db).getIriu(predmetId);
      expect(
        reopenedRows
            .where((row) => row.interniNaziv == IriuK.kompletZaOpelo)
            .map((row) => row.id),
        [manualId],
      );
      final reopenedStable = await _sync(
        PredmetiRepository(db),
        IriuRepository(db),
        ScenarioModuleRepository(db),
        predmetId,
        await ScenarioModuleRepository(db).getActiveDefinitions(),
        await ScenarioModuleRepository(db).ensureModuleAndDefaults(),
        applyScenarioChange: false,
      );
      expect(reopenedStable.addedCategories, isEmpty);
      expect(reopenedStable.removedCategories, isEmpty);
      expect(
        (await IriuRepository(db).getIriu(predmetId))
            .where((row) => row.interniNaziv == IriuK.kompletZaOpelo)
            .map((row) => row.id),
        [manualId],
      );
    },
  );

  test(
    'creation-only OSNOVNI provenance permits first SCENARIO application after reopen',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.inicijalizujIriu(predmetId);
      final manualRowId = await iriu.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'MANUAL_BEFORE_FIRST_SCENARIO_OPEN',
        nazivPrikaz: 'Ručni red ostaje',
      );
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('DOM ZA STARE'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );

      final current = await predmeti.getPredmet(predmetId);
      final intent = await iriu.scenarioOpenReconciliationIntent(
        predmetId: predmetId,
        currentPredmet: current,
      );
      expect(intent.shouldReconcile, isTrue);
      expect(intent.allowLegacyBaselineEstablishment, isTrue);
      expect(await _snapshotOrNull(db, predmetId) == null, isTrue);

      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: current,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        allowLegacyBaselineEstablishment:
            intent.allowLegacyBaselineEstablishment,
      );
      final applied = await _snapshot(db, predmetId);
      expect(
        ScenarioAssignmentSnapshot.fromJsonMap(
          jsonDecode(applied.snapshotJson) as Map<String, dynamic>,
        ).appliedEvaluationBaseline!.hasSameEvaluationInputsAs(
          OwnerScenarioInput.fromPredmet(current),
        ),
        isTrue,
      );
      expect(
        (await iriu.getIriu(predmetId)).any((row) => row.id == manualRowId),
        isTrue,
      );
      final stableReopen = await iriu.scenarioOpenReconciliationIntent(
        predmetId: predmetId,
        currentPredmet: current,
      );
      expect(stableReopen.shouldReconcile, isFalse);
    },
  );

  test(
    'legacy assignment only reopens for a committed post-assignment kernel-input change',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'opc_scenario_legacy_save_reopen_',
      );
      final file = File('${tempDir.path}${Platform.pathSeparator}opc.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        await tempDir.delete(recursive: true);
      });
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
          docekPosmrtnihOstataka: Value(true),
          promenaSanduka: Value(false),
        ),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final original = await predmeti.getPredmet(predmetId);
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: original,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      final stored = await _snapshot(db, predmetId);
      final modern = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(stored.snapshotJson) as Map<String, dynamic>,
      );
      final legacy = ScenarioAssignmentSnapshot.create(
        moduleId: modern.moduleId,
        scenarioId: modern.scenarioId,
        scenarioVersion: modern.scenarioVersion,
        scenario: modern.scenario,
        osnovniPaket: modern.osnovniPaket,
        assignedAt: modern.assignedAt,
      );
      await (db.update(
        db.predmetScenarioSnapshots,
      )..where((row) => row.predmetId.equals(predmetId))).write(
        PredmetScenarioSnapshotsCompanion(
          snapshotJson: Value(jsonEncode(legacy.toJsonMap())),
          snapshotHash: Value(legacy.snapshotHash),
          assignedAt: Value(legacy.assignedAt),
        ),
      );

      final passiveBeforeEdit = await iriu.scenarioOpenReconciliationIntent(
        predmetId: predmetId,
        currentPredmet: original,
      );
      expect(passiveBeforeEdit.shouldReconcile, isFalse);

      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(promenaSanduka: Value(true)),
      );
      await predmeti.sacuvajPredmet(
        predmetId,
        korisnikId: 1,
        fallbackSnapshot: predmeti.snapshotZaSaveCommit(original),
      );

      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final reopenedPredmeti = PredmetiRepository(db);
      final reopenedCurrent = await reopenedPredmeti.getPredmet(predmetId);
      final reopenedIntent = await IriuRepository(db)
          .scenarioOpenReconciliationIntent(
            predmetId: predmetId,
            currentPredmet: reopenedCurrent,
          );
      expect(reopenedIntent.shouldReconcile, isTrue);
      expect(reopenedIntent.allowLegacyBaselineEstablishment, isTrue);
      expect(
        OwnerScenarioInput.fromPredmet(reopenedCurrent).promenaSanduka,
        isTrue,
      );
    },
  );

  test(
    'condition-vector transition reconciles only SCENARIO rows and preserves unrelated rows',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
        ),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final oldResult = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmeti.getPredmet(predmetId),
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      final oldSnapshot = await _snapshot(db, predmetId);
      final beforeTransition = await iriu.getIriu(predmetId);
      final oldPredmet = await predmeti.getPredmet(predmetId);
      final oldManaged = beforeTransition.where((row) => row.scenarioUpravlja);
      final oldByName = {for (final row in oldManaged) row.interniNaziv: row};
      final manualId = await iriu.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_REGRESSION_PRESERVE',
        nazivPrikaz: 'Ručni red ostaje',
      );
      final unrelatedId = await iriu.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'DRUGI_MODUL_REGRESSION_PRESERVE',
        nazivPrikaz: 'Red drugog modula ostaje',
      );
      await db
          .into(db.iriuProvenance)
          .insert(
            IriuProvenanceCompanion.insert(
              iriuId: Value(unrelatedId),
              origin: 'PARTE',
              moduleId: const Value('parte'),
              createdAt: '2026-10-05T00:00:00.000Z',
            ),
          );

      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          mestoSmrti: Value('DOM ZA STARE'),
          opelo: Value('NE'),
        ),
      );
      final currentPredmet = await predmeti.getPredmet(predmetId);
      const kernel = OwnerScenarioPolicyKernel();
      final oldKey = kernel.evaluate(oldPredmet).key;
      final newKey = kernel.evaluate(currentPredmet).key;
      expect(oldKey, isNot(newKey));

      final preview = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: currentPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
      );
      expect(preview.scenarioSnapshotChanged, isTrue);
      expect(preview.pendingUserDecisionRows, isNotEmpty);
      expect(await _snapshot(db, predmetId), oldSnapshot);
      expect(
        await iriu.getIriu(predmetId),
        hasLength(beforeTransition.length + 2),
      );

      final decisions = <int, bool>{
        for (final row in preview.pendingUserDecisionRows) row.id: false,
      };
      final applied = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: currentPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        conditionChangeDecisions: decisions,
      );
      expect(applied.scenarioSnapshotChanged, isTrue);
      expect(applied.pendingUserDecisionRows, isEmpty);
      expect(applied.removedCategories, isNotEmpty);
      expect(applied.addedCategories, isNotEmpty);
      expect(oldResult.matchedScenarioIds, isNotEmpty);
      expect(await _snapshot(db, predmetId), isNot(oldSnapshot));

      final after = await iriu.getIriu(predmetId);
      final afterByName = {for (final row in after) row.interniNaziv: row};
      for (final removed in applied.removedCategories) {
        expect(afterByName.containsKey(removed), isFalse, reason: removed);
        expect(oldByName.containsKey(removed), isTrue, reason: removed);
      }
      for (final added in applied.addedCategories) {
        expect(afterByName.containsKey(added), isTrue, reason: added);
        expect(oldByName.containsKey(added), isFalse, reason: added);
      }
      for (final commonName in oldByName.keys.toSet().intersection(
        afterByName.keys.toSet(),
      )) {
        expect(afterByName[commonName]!.id, oldByName[commonName]!.id);
      }
      expect(afterByName.containsKey('RUCNO_REGRESSION_PRESERVE'), isTrue);
      expect(
        afterByName.containsKey('DRUGI_MODUL_REGRESSION_PRESERVE'),
        isTrue,
      );
      expect(after.any((row) => row.id == manualId), isTrue);
      expect(after.any((row) => row.id == unrelatedId), isTrue);
      final unrelatedProvenance = await (db.select(
        db.iriuProvenance,
      )..where((row) => row.iriuId.equals(unrelatedId))).getSingle();
      expect(unrelatedProvenance.moduleId, 'parte');
      expect(unrelatedProvenance.origin, 'PARTE');

      final baseIndexes = <int>[
        for (var index = 0; index < after.length; index++)
          if (OwnerScenarioPolicyKernel.osnovniPaket.contains(
            after[index].interniNaziv,
          ))
            index,
      ];
      final scenarioIndexes = <int>[
        for (var index = 0; index < after.length; index++)
          if (after[index].scenarioUpravlja &&
              !OwnerScenarioPolicyKernel.osnovniPaket.contains(
                after[index].interniNaziv,
              ))
            index,
      ];
      final manualIndexes = <int>[
        for (var index = 0; index < after.length; index++)
          if (!after[index].scenarioUpravlja) index,
      ];
      expect(baseIndexes, isNotEmpty);
      expect(scenarioIndexes, isNotEmpty);
      expect(manualIndexes, isNotEmpty);
      expect(baseIndexes.last, lessThan(scenarioIndexes.first));
      expect(scenarioIndexes.last, lessThan(manualIndexes.first));
    },
  );

  test('unchanged applied kernel state performs no durable SQL writes', () async {
    final counter = _ScenarioWriteCounter();
    final db = AppDatabase.forTesting(
      NativeDatabase.memory().interceptWith(counter),
    );
    addTearDown(db.close);
    await seedScenarioCatalogForTest(db);
    final predmeti = PredmetiRepository(db);
    final scenarioRepository = ScenarioModuleRepository(db);
    final iriu = IriuRepository(db);
    final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
    await predmeti.azurirajPredmet(
      predmetId,
      const PredmetiCompanion(
        uzrokSmrti: Value('PRIRODNA'),
        mestoSmrti: Value('BOLNICA'),
        vrstaCeremonije: Value('SAHRANA'),
        tipGroblja: Value('GRADSKO'),
        tipGrobnogMesta: Value('GROB'),
        opelo: Value('NE'),
      ),
    );
    final module = await scenarioRepository.ensureModuleAndDefaults();
    final scenarios = await scenarioRepository.getActiveDefinitions();
    final predmet = await predmeti.getPredmet(predmetId);
    await predmeti.inicijalizujIriu(predmetId);
    await iriu.syncScenarioRows(
      predmetId: predmetId,
      predmet: predmet,
      scenarios: scenarios,
      osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    );
    // Initial base materialization converges once to the frozen applied
    // scenario projection; the following stable reopen must be a true no-op.
    await iriu.syncScenarioRows(
      predmetId: predmetId,
      predmet: predmet,
      scenarios: scenarios,
      osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    );
    counter.reset();
    final unchanged = await iriu.syncScenarioRows(
      predmetId: predmetId,
      predmet: predmet,
      scenarios: scenarios,
      osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    );

    expect(
      unchanged.changed,
      isFalse,
      reason:
          'added=${unchanged.addedCategories}, '
          'removed=${unchanged.removedCategories}, '
          'changed=${unchanged.changedCategories}, '
          'pending=${unchanged.pendingUserDecisionRows.map((row) => row.interniNaziv)}, '
          'snapshot=${unchanged.scenarioSnapshotChanged}',
    );
    expect(counter.writeCount, 0);
  });

  test(
    'same scenario key with changed sanduk input reconciles and baselines atomically',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
          docekPosmrtnihOstataka: Value(true),
          promenaSanduka: Value(false),
        ),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final initialPredmet = await predmeti.getPredmet(predmetId);
      final initialInput = OwnerScenarioInput.fromPredmet(initialPredmet);
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: initialPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      final initialSnapshot = await _snapshot(db, predmetId);
      final initialSanduk = await _rowByName(db, predmetId, IriuK.sanduk);
      final initialAssignment = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(initialSnapshot.snapshotJson) as Map<String, dynamic>,
      );
      expect(
        initialAssignment.appliedEvaluationBaseline!.hasSameEvaluationInputsAs(
          initialInput,
        ),
        isTrue,
      );

      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(promenaSanduka: Value(true)),
      );
      final changedPredmet = await predmeti.getPredmet(predmetId);
      final changedInput = OwnerScenarioInput.fromPredmet(changedPredmet);
      expect(changedInput.key, initialInput.key);
      expect(initialInput.hasSameEvaluationInputsAs(changedInput), isFalse);

      final preview = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: changedPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
      );
      expect(preview.scenarioSnapshotChanged, isTrue);
      expect(preview.changedCategories, contains(IriuK.sanduk));
      expect(await _snapshot(db, predmetId), initialSnapshot);

      final applied = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: changedPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      expect(applied.scenarioSnapshotChanged, isTrue);
      expect(applied.changedCategories, contains(IriuK.sanduk));
      final appliedSnapshot = await _snapshot(db, predmetId);
      final appliedAssignment = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(appliedSnapshot.snapshotJson) as Map<String, dynamic>,
      );
      expect(appliedAssignment.scenarioId, initialAssignment.scenarioId);
      expect(
        appliedAssignment.appliedEvaluationBaseline!.hasSameEvaluationInputsAs(
          changedInput,
        ),
        isTrue,
      );
      expect(appliedSnapshot.snapshotHash, isNot(initialSnapshot.snapshotHash));
      expect(
        await _rowByName(db, predmetId, IriuK.sanduk),
        isNot(initialSanduk),
      );
    },
  );

  test(
    'legacy same-key snapshot stays fail-closed until explicit current-change intent',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmeti = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriu = IriuRepository(db);
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('DA'),
          docekPosmrtnihOstataka: Value(true),
          promenaSanduka: Value(false),
        ),
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmeti.getPredmet(predmetId),
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
      );
      final stored = await _snapshot(db, predmetId);
      final previous = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(stored.snapshotJson) as Map<String, dynamic>,
      );
      final legacy = ScenarioAssignmentSnapshot.create(
        moduleId: previous.moduleId,
        scenarioId: previous.scenarioId,
        scenarioVersion: previous.scenarioVersion,
        scenario: previous.scenario,
        osnovniPaket: previous.osnovniPaket,
        assignedAt: previous.assignedAt,
      );
      await (db.update(
        db.predmetScenarioSnapshots,
      )..where((row) => row.predmetId.equals(predmetId))).write(
        PredmetScenarioSnapshotsCompanion(
          moduleId: Value(legacy.moduleId),
          scenarioId: Value(legacy.scenarioId),
          scenarioVersion: Value(legacy.scenarioVersion),
          snapshotJson: Value(jsonEncode(legacy.toJsonMap())),
          snapshotHash: Value(legacy.snapshotHash),
          assignedAt: Value(legacy.assignedAt),
        ),
      );
      await predmeti.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(promenaSanduka: Value(true)),
      );
      final changedPredmet = await predmeti.getPredmet(predmetId);
      final passiveOpen = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: changedPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
      );
      expect(passiveOpen.scenarioSnapshotChanged, isFalse);
      expect(passiveOpen.changedCategories, isEmpty);
      final stillLegacy = await _snapshot(db, predmetId);
      expect(stillLegacy.snapshotJson, jsonEncode(legacy.toJsonMap()));
      expect(
        ScenarioAssignmentSnapshot.fromJsonMap(
              jsonDecode(stillLegacy.snapshotJson) as Map<String, dynamic>,
            ).appliedEvaluationBaseline ==
            null,
        isTrue,
      );

      final explicitChange = await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: changedPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        applyScenarioChange: false,
        allowLegacyBaselineEstablishment: true,
      );
      expect(explicitChange.scenarioSnapshotChanged, isTrue);
      expect(explicitChange.changedCategories, contains(IriuK.sanduk));
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: changedPredmet,
        scenarios: scenarios,
        osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        allowLegacyBaselineEstablishment: true,
      );
      final established = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode((await _snapshot(db, predmetId)).snapshotJson)
            as Map<String, dynamic>,
      );
      expect(established.appliedEvaluationBaseline != null, isTrue);
    },
  );

  test(
    'A to B preview is no-mutation and confirmed additions snapshot FIKSNA price',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(predmetRepository, predmetId, burialPlace: 'GROB');
      await scenarioRepository.ensureModuleAndDefaults();
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final first = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(first.scenarioSnapshotChanged, isFalse);

      final persisted = await _rowByName(db, predmetId, IriuK.prevozDoGroblja);
      await iriuRepository.azurirajStavku(
        persisted.id,
        const IriuCompanion(kom: Value('3'), iznos: Value(777.0)),
      );
      final manualId = await iriuRepository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_LIFECYCLE',
        nazivPrikaz: 'Ručna lifecycle stavka',
        kom: '2',
        iznos: 333.0,
      );
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
          .write(const IriuKatalogConfigCompanion(cena: Value(12.5)));
      final beforeRows = await iriuRepository.getIriu(predmetId);
      final beforeSnapshot = await _snapshot(db, predmetId);

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      final preview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(preview.scenarioSnapshotChanged, isTrue);
      expect(
        preview.addedCategories,
        containsAll([IriuK.limeniUlozak, IriuK.lemovanje]),
      );
      expect(preview.removedCategories, isEmpty);
      expect(preview.changedCategories, contains(IriuK.prevozDoGroblja));
      expect(await iriuRepository.getIriu(predmetId), _sameRowsAs(beforeRows));
      expect(await _snapshot(db, predmetId), beforeSnapshot);

      final applied = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(applied.addedCategories, contains(IriuK.limeniUlozak));
      expect(applied.pendingUserDecisionRows, isEmpty);
      final added = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(added.cena, 12.5);
      expect(added.kom, '1');
      expect(added.iznos, 12.5);
      final preserved = await _rowByName(db, predmetId, IriuK.prevozDoGroblja);
      expect(preserved.id, persisted.id);
      expect(preserved.kom, '3');
      expect(preserved.iznos, 777.0);
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).any((row) => row.id == manualId),
        isTrue,
      );
      expect(
        (await _snapshot(db, predmetId)).scenarioId,
        applied.matchedScenarioIds.single,
      );
    },
  );

  test(
    'same identity status change is diffed and updates only scenario state',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
        cemeteryType: 'GRADSKO',
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final limeni = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      await iriuRepository.azurirajStavku(
        limeni.id,
        const IriuCompanion(kom: Value('4'), iznos: Value(901.0)),
      );
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
        cemeteryType: 'LOKALNO',
      );
      final preview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(preview.changedCategories, contains(IriuK.limeniUlozak));
      expect(preview.changedCategoryLabels, contains('Limeni uložak'));
      final before = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(before.iznos, 901.0);
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final after = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(after.id, before.id);
      expect(after.kom, '4');
      expect(after.iznos, 901.0);
      expect(after.poslovniStatus, 'PREPORUČENO');
      final provenance = await (db.select(
        db.iriuProvenance,
      )..where((row) => row.iriuId.equals(after.id))).getSingle();
      expect(provenance.scenarioId, contains('LOKALNO'));
    },
  );

  test(
    'multiple unconfirmed changes resolve from applied A and stay per PREDMET',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final predmetA = await predmetRepository.kreirajPredmet(savetnikId: 1);
      final predmetB = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(predmetRepository, predmetA, burialPlace: 'GROB');
      await _setBurialState(
        predmetRepository,
        predmetB,
        burialPlace: 'GROBNICA',
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetB,
        scenarios,
        module,
      );
      final snapshotB = await _snapshot(db, predmetB);

      await _setBurialState(
        predmetRepository,
        predmetA,
        burialPlace: 'GROBNICA',
      );
      final pendingB = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(pendingB.matchedScenarioIds.single, contains('GROBNICA'));
      await _setBurialState(
        predmetRepository,
        predmetA,
        burialPlace: 'GROBNICA',
        cemeteryType: 'LOKALNO',
      );
      final pendingC = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(pendingC.matchedScenarioIds.single, contains('LOKALNO'));
      expect(
        (await _snapshot(db, predmetA)).scenarioId,
        isNot(contains('LOKALNO')),
      );
      expect(await _snapshot(db, predmetB), snapshotB);
      expect(await iriuRepository.getIriu(predmetB), isNotEmpty);
    },
  );

  test(
    'removed scenario item is not retained and is re-added as a fresh snapshot',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
          .write(const IriuKatalogConfigCompanion(cena: Value(17.0)));
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final original = await _rowByName(db, predmetId, IriuK.limeniUlozak);

      await _setBurialState(predmetRepository, predmetId, burialPlace: 'GROB');
      final removalPreview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(removalPreview.removedCategories, contains(IriuK.limeniUlozak));
      final appliedRemoval = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      for (final row in appliedRemoval.pendingUserDecisionRows) {
        await iriuRepository.resolveScenarioConditionChange(
          predmetId: predmetId,
          row: row,
          keepRow: false,
        );
      }
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).any((row) => row.interniNaziv == IriuK.limeniUlozak),
        isFalse,
      );

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final readded = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(readded.id, isNot(original.id));
      expect(readded.cena, 17.0);
      expect(readded.iznos, 17.0);
    },
  );

  test('confirmed scenario snapshot survives close and reopen', () async {
    final root = await Directory.systemTemp.createTemp('opc_scenario_reopen_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final file = File('${root.path}${Platform.pathSeparator}opc.sqlite');
    final firstDb = AppDatabase.forTesting(NativeDatabase(file));
    await seedScenarioCatalogForTest(firstDb);
    final predmetRepository = PredmetiRepository(firstDb);
    final scenarioRepository = ScenarioModuleRepository(firstDb);
    final iriuRepository = IriuRepository(firstDb);
    final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
    await _setBurialState(
      predmetRepository,
      predmetId,
      burialPlace: 'GROBNICA',
    );
    final module = await scenarioRepository.ensureModuleAndDefaults();
    final scenarios = await scenarioRepository.getActiveDefinitions();
    await _sync(
      predmetRepository,
      iriuRepository,
      scenarioRepository,
      predmetId,
      scenarios,
      module,
    );
    final expected = await _snapshot(firstDb, predmetId);
    await firstDb.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopened.close);
    final snapshot = await _snapshot(reopened, predmetId);
    expect(snapshot, expected);
    expect(
      ScenarioAssignmentSnapshot.fromJsonMap(
            jsonDecode(snapshot.snapshotJson) as Map<String, dynamic>,
          ).appliedEvaluationBaseline !=
          null,
      isTrue,
    );
    expect((await IriuRepository(reopened).getIriu(predmetId)), isNotEmpty);
  });
}

class _ScenarioWriteCounter extends QueryInterceptor {
  int writeCount = 0;

  void reset() => writeCount = 0;

  bool _isScenarioWrite(String statement) {
    final sql = statement.toLowerCase();
    return (sql.startsWith('insert') ||
            sql.startsWith('update') ||
            sql.startsWith('delete')) &&
        (sql.contains('"iriu"') ||
            sql.contains('"iriu_provenance"') ||
            sql.contains('"predmet_scenario_snapshots"'));
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (_isScenarioWrite(statement)) writeCount++;
    return executor.runInsert(statement, args);
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (_isScenarioWrite(statement)) writeCount++;
    return executor.runUpdate(statement, args);
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (_isScenarioWrite(statement)) writeCount++;
    return executor.runDelete(statement, args);
  }
}

Future<ScenarioSyncResult> _sync(
  PredmetiRepository predmetRepository,
  IriuRepository iriuRepository,
  ScenarioModuleRepository scenarioRepository,
  int predmetId,
  List<ScenarioDefinition> scenarios,
  ScenarioModule module, {
  bool applyScenarioChange = true,
  Map<int, bool> conditionChangeDecisions = const <int, bool>{},
}) async {
  return iriuRepository.syncScenarioRows(
    predmetId: predmetId,
    predmet: await predmetRepository.getPredmet(predmetId),
    scenarios: scenarios,
    osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    applyScenarioChange: applyScenarioChange,
    conditionChangeDecisions: conditionChangeDecisions,
  );
}

Future<void> _setBurialState(
  PredmetiRepository repository,
  int predmetId, {
  required String burialPlace,
  String cemeteryType = 'GRADSKO',
  String opelo = 'NE',
}) => repository.azurirajPredmet(
  predmetId,
  PredmetiCompanion(
    uzrokSmrti: const Value('PRIRODNA'),
    mestoSmrti: const Value('STAN'),
    vrstaCeremonije: const Value('SAHRANA'),
    tipGroblja: Value(cemeteryType),
    tipGrobnogMesta: Value(burialPlace),
    opelo: Value(opelo),
  ),
);

Future<IriuData> _rowByName(AppDatabase db, int predmetId, String name) =>
    (db.select(db.iriu)..where(
          (row) =>
              row.predmetId.equals(predmetId) & row.interniNaziv.equals(name),
        ))
        .getSingle();

Future<PredmetScenarioSnapshot> _snapshot(AppDatabase db, int predmetId) =>
    (db.select(
      db.predmetScenarioSnapshots,
    )..where((row) => row.predmetId.equals(predmetId))).getSingle();

Future<PredmetScenarioSnapshot?> _snapshotOrNull(
  AppDatabase db,
  int predmetId,
) => (db.select(
  db.predmetScenarioSnapshots,
)..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();

Matcher _sameRowsAs(List<IriuData> expected) =>
    predicate<List<IriuData>>((actual) {
      if (actual.length != expected.length) return false;
      for (var index = 0; index < actual.length; index++) {
        if (actual[index] != expected[index]) return false;
      }
      return true;
    }, 'rows equal expected values');
