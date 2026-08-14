import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../../../core/format/app_money_format.dart';
import '../core_v2/rules/iriu_truth_rules.dart';
import '../core_v2/services/blok2_iriu_lifecycle_service.dart';
import '../core_v2/services/iriu_display_name_resolver.dart';
import '../core_v2/services/iriu_ordering_service.dart';
import '../core_v2/services/mesto_smrti_iriu_lifecycle_service.dart';
import '../core_v2/scenario/scenario_contract.dart';
import '../core_v2/scenario/scenario_persistence_contract.dart';
import '../core_v2/scenario/scenario_rule_engine.dart';
import '../core_v2/scenario/scenario_module_repository.dart';
import '../core_v2/scenario/owner_scenario_policy_kernel.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../domain/iriu_catalog_selection.dart';

class _LiveOrderingClassification {
  const _LiveOrderingClassification({
    required this.managed,
    required this.scenario,
    required this.section,
    required this.order,
    required this.context,
  });

  final bool managed;
  final bool scenario;
  final int section;
  final int order;
  final IriuOrderingContext context;
}

class IriuRepository {
  const IriuRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;
  static const _orderingService = IriuOrderingService();
  static const String _mestoSmrtiScopeKey = 'MESTO_SMRTI_BLOCK';
  static const String _blok2ScopeKey = 'BLOK2';
  static const String _manualDeletionDecisionKey = 'MANUAL_DELETE';
  static const String _scenarioScopeKey = 'SCENARIO';

  AppDatabase get db => _db;

  StanjeRobeLifecycleService _stanjeRobeLifecycleService() {
    final availability = StanjeRobeOperationalAvailability(
      podesavanjaRepository: PodesavanjaRepository(_db),
    );
    return StanjeRobeLifecycleService(
      db: _db,
      isOperationallyActive: availability.isActive,
    );
  }

  Stream<List<IriuData>> watchIriu(int predmetId) =>
      (_db.select(_db.iriu)
            ..where((i) => i.predmetId.equals(predmetId))
            // Raw storage order is explicit here; presentation order is
            // derived below and never delegated to redosled.
            ..orderBy([(i) => OrderingTerm.asc(i.id)]))
          .watch()
          .asyncMap((rows) => _orderedProjection(predmetId, rows));

  /// Sinhronizuje samo stavke koje je kreirao SCENARIO modul.
  /// Ručne, legacy i stavke drugih modula se nikada ne uklanjaju.
  Future<ScenarioSyncResult> syncScenarioRows({
    required int predmetId,
    required PredmetiData predmet,
    required List<ScenarioDefinition> scenarios,
    required Set<String> osnovniPaket,
    bool applyScenarioChange = true,
  }) async {
    final hasOwnerPolicyDefinitions = scenarios.any(
      (scenario) => scenario.id.startsWith('MAP_'),
    );
    final ownerResult = hasOwnerPolicyDefinitions
        ? const OwnerScenarioPolicyKernel().evaluate(predmet)
        : null;
    final previousSnapshot = await _readScenarioSnapshot(predmetId);
    final decodedPreviousSnapshot = previousSnapshot == null
        ? null
        : ScenarioAssignmentSnapshot.fromJsonMap(
            jsonDecode(previousSnapshot.snapshotJson) as Map<String, dynamic>,
          );
    final ownerDefinition = ownerResult?.scenarioId == null
        ? null
        : scenarios
              .where((item) => item.id == ownerResult!.scenarioId)
              .firstOrNull;
    if (ownerResult?.isComplete == true && ownerDefinition == null) {
      throw StateError(
        'SCENARIO owner-map definition is missing or inactive for '
        '${ownerResult!.scenarioId}.',
      );
    }
    final sameAssignedScenario =
        ownerResult?.isComplete == true &&
        decodedPreviousSnapshot?.scenarioId == ownerResult!.scenarioId;
    final effectiveOwnerDefinition = sameAssignedScenario
        ? decodedPreviousSnapshot!.scenario
        : ownerDefinition;
    final effectiveBasePackage = sameAssignedScenario
        ? decodedPreviousSnapshot!.osnovniPaket
        : osnovniPaket;
    final evaluation = ownerResult != null && ownerDefinition != null
        ? const ScenarioRuleEngine().evaluate(
            scenarios: [effectiveOwnerDefinition!],
            predmet: predmet,
            osnovniPaket: effectiveBasePackage,
          )
        : ownerResult != null
        ? const ScenarioRuleEngine().fromOwnerKernel(ownerResult)
        : const ScenarioRuleEngine().evaluate(
            scenarios: scenarios,
            predmet: predmet,
            osnovniPaket: osnovniPaket,
          );
    final candidateSnapshot = ownerResult?.isComplete == true
        ? _ownerScenarioSnapshot(
            result: ownerResult!,
            osnovniPaket: evaluation.baseCategories,
            definition: ownerDefinition,
          )
        : null;
    final scenarioSnapshotChanged =
        candidateSnapshot != null &&
        previousSnapshot != null &&
        !sameAssignedScenario &&
        previousSnapshot.snapshotHash != candidateSnapshot.snapshotHash;
    final rows = await getIriu(predmetId);
    final catalogRows = await (_db.select(_db.iriuKatalogConfig)).get();
    final catalogDisplayNames = <String, String>{
      for (final row in catalogRows)
        if (row.nazivPrikaz.trim().isNotEmpty)
          row.interniNaziv: row.nazivPrikaz.trim(),
    };
    final provenance = await (_db.select(_db.iriuProvenance)).get();
    final provenanceByIriuId = {
      for (final item in provenance) item.iriuId: item,
    };
    final scenarioRows = rows
        .where((row) {
          final item = provenanceByIriuId[row.id];
          return item?.moduleId == 'scenario' &&
              (item?.origin == 'OSNOVNI_PAKET' ||
                  item?.origin == 'SCENARIO_PAKET');
        })
        // This collection is extended below when the basic package was
        // materialized before provenance existed. Keep it mutable so the
        // actual PREDMET -> SCENARIO hand-off cannot fail before additions
        // are written.
        .toList();
    var orderingInvalidated = false;
    final existingNames = rows.map((row) => row.interniNaziv).toSet();
    final desired = evaluation.effectiveCategories;
    final dismissed = await _getDismissedCategories(
      predmetId: predmetId,
      scopeKey: _scenarioScopeKey,
    );
    final removals = scenarioRows
        .where((row) => !desired.contains(row.interniNaziv))
        .toList();
    final additions =
        desired.difference(existingNames).difference(dismissed).toList()
          ..sort();
    final changedRows = scenarioRows
        .where((row) => desired.contains(row.interniNaziv))
        .where((row) {
          final decision = evaluation.decisions[row.interniNaziv];
          return decision != null && _scenarioDecisionChanged(row, decision);
        })
        .toList(growable: false);
    final addedLabels = _resolveScenarioLabels(additions, catalogDisplayNames);
    final removedNames = removals
        .map((row) => row.interniNaziv)
        .toList(growable: false);
    final removedLabels = _resolveScenarioLabels(
      removedNames,
      catalogDisplayNames,
    );
    final changedNames = changedRows
        .map((row) => row.interniNaziv)
        .toList(growable: false);
    final changedLabels = _resolveScenarioLabels(
      changedNames,
      catalogDisplayNames,
    );

    // A changed complete combination is previewed before any row,
    // provenance or snapshot mutation. The UI can show the diff and call
    // this method again with applyScenarioChange=true only after confirmation.
    if (scenarioSnapshotChanged && !applyScenarioChange) {
      return ScenarioSyncResult(
        matchedScenarioIds: evaluation.matchedScenarioIds,
        addedCategories: additions,
        addedCategoryLabels: addedLabels,
        removedCategories: removedNames,
        removedCategoryLabels: removedLabels,
        changedCategories: changedNames,
        changedCategoryLabels: changedLabels,
        pendingUserDecisionRows: removals,
        scenarioSnapshotChanged: true,
      );
    }

    for (final category in dismissed.difference(desired)) {
      await _clearDismissal(
        predmetId: predmetId,
        interniNaziv: category,
        scopeKey: _scenarioScopeKey,
      );
    }
    for (final row in rows.where(
      (row) =>
          evaluation.baseCategories.contains(row.interniNaziv) &&
          provenanceByIriuId[row.id] == null,
    )) {
      scenarioRows.add(row);
      orderingInvalidated = true;
      await _db
          .into(_db.iriuProvenance)
          .insertOnConflictUpdate(
            IriuProvenanceCompanion.insert(
              iriuId: Value(row.id),
              origin: 'OSNOVNI_PAKET',
              moduleId: const Value('scenario'),
              createdAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
    }

    for (final row in removals) {
      await azurirajStavku(
        row.id,
        const IriuCompanion(cekaOdlukuKorisnika: Value(true)),
      );
    }
    for (final internalName in additions) {
      final decision = evaluation.decisions[internalName]!;
      final displayResolution = resolveIriuDisplayName(
        internalName: internalName,
        catalogDisplayNames: catalogDisplayNames,
      );
      if (!displayResolution.isResolved) {
        throw StateError(
          'SCENARIO consequence has no resolvable KATALOG category: '
          '$internalName',
        );
      }
      final id = await _insertStavka(
        predmetId: predmetId,
        interniNaziv: internalName,
        nazivPrikaz: displayResolution.displayName!,
        redosled: await sledeciredosled(predmetId),
        poslovniStatus: decision.businessStatus,
        obezbedjuje: decision.provider.name,
        poslovnoUpozorenje: decision.warning,
        poslovniRazlog: decision.reason,
        poslovnaCelina: decision.section,
        poslovniRedosled: decision.order,
        finansijskiUkljuceno: decision.financiallyIncluded,
        scenarioUpravlja: true,
      );
      final isBase = evaluation.baseCategories.contains(internalName);
      final consequence = evaluation.scenarioCategories.firstWhere(
        (item) => item.katalogCategoryInternalName == internalName,
        orElse: () => const ScenarioConsequence(
          katalogCategoryInternalName: '',
          action: ScenarioConsequenceAction.recommended,
        ),
      );
      await _db
          .into(_db.iriuProvenance)
          .insertOnConflictUpdate(
            IriuProvenanceCompanion.insert(
              iriuId: Value(id),
              origin: isBase ? 'OSNOVNI_PAKET' : 'SCENARIO_PAKET',
              moduleId: const Value('scenario'),
              scenarioId: Value(
                isBase || evaluation.matchedScenarioIds.isEmpty
                    ? null
                    : evaluation.sourceScenarioIds[internalName],
              ),
              scenarioVersion: Value(isBase ? null : 1),
              ruleId: Value(
                isBase ? null : consequence.katalogCategoryInternalName,
              ),
              createdAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
    }
    for (final row in scenarioRows.where(
      (row) => desired.contains(row.interniNaziv),
    )) {
      final decision = evaluation.decisions[row.interniNaziv]!;
      if (_scenarioDecisionChanged(row, decision) || !row.scenarioUpravlja) {
        orderingInvalidated = true;
      }
      await azurirajStavku(
        row.id,
        IriuCompanion(
          poslovniStatus: Value(decision.businessStatus),
          obezbedjuje: Value(decision.provider.name),
          poslovnoUpozorenje: Value(decision.warning),
          poslovniRazlog: Value(decision.reason),
          poslovnaCelina: Value(decision.section),
          poslovniRedosled: Value(decision.order),
          finansijskiUkljuceno: Value(decision.financiallyIncluded),
          scenarioUpravlja: const Value(true),
          cekaOdlukuKorisnika: const Value(false),
        ),
      );
      final isBase = evaluation.baseCategories.contains(row.interniNaziv);
      final consequence = evaluation.scenarioCategories.firstWhere(
        (item) => item.katalogCategoryInternalName == row.interniNaziv,
        orElse: () => const ScenarioConsequence(
          katalogCategoryInternalName: '',
          action: ScenarioConsequenceAction.recommended,
        ),
      );
      await (_db.update(
        _db.iriuProvenance,
      )..where((item) => item.iriuId.equals(row.id))).write(
        IriuProvenanceCompanion(
          origin: Value(isBase ? 'OSNOVNI_PAKET' : 'SCENARIO_PAKET'),
          scenarioId: Value(
            isBase || evaluation.matchedScenarioIds.isEmpty
                ? null
                : evaluation.sourceScenarioIds[row.interniNaziv],
          ),
          scenarioVersion: Value(isBase ? null : 1),
          ruleId: Value(
            isBase ? null : consequence.katalogCategoryInternalName,
          ),
        ),
      );
    }
    if (removals.isNotEmpty || additions.isNotEmpty || orderingInvalidated) {
      await _rebuildBusinessOrdering(predmetId);
    }
    if (ownerResult?.isComplete ?? false) {
      final snapshot = candidateSnapshot!;
      if (sameAssignedScenario) {
        // A later editor change is intentionally not retroactive for a
        // PREDMET that already carries this assignment snapshot.
      } else if (previousSnapshot == null ||
          previousSnapshot.snapshotHash == snapshot.snapshotHash) {
        if (previousSnapshot == null) {
          await _writeScenarioSnapshot(snapshot, predmetId: predmetId);
        }
      } else {
        // A condition change is not silently accepted while rows await a
        // user's keep/remove decision. Once no rows are pending, the current
        // owner-map assignment becomes the new restore snapshot.
        if (removals.isEmpty) {
          await _writeScenarioSnapshot(snapshot, predmetId: predmetId);
        }
      }
    }
    return ScenarioSyncResult(
      matchedScenarioIds: evaluation.matchedScenarioIds,
      addedCategories: additions,
      addedCategoryLabels: addedLabels,
      removedCategories: applyScenarioChange ? const <String>[] : removedNames,
      removedCategoryLabels: applyScenarioChange
          ? const <String>[]
          : removedLabels,
      changedCategories: changedNames,
      changedCategoryLabels: changedLabels,
      pendingUserDecisionRows: removals,
      scenarioSnapshotChanged: scenarioSnapshotChanged,
    );
  }

  /// Konačna odluka korisnika za red čiji uslov više nije ispunjen.
  Future<void> resolveScenarioConditionChange({
    required int predmetId,
    required IriuData row,
    required bool keepRow,
  }) async {
    if (keepRow) {
      await azurirajStavku(
        row.id,
        const IriuCompanion(
          scenarioUpravlja: Value(false),
          cekaOdlukuKorisnika: Value(false),
        ),
      );
      await (_db.delete(
        _db.iriuProvenance,
      )..where((item) => item.iriuId.equals(row.id))).go();
    } else {
      await obrisiStavkuSaLifecycleMemorijom(
        predmetId: predmetId,
        row: row,
        rememberManualDeletion: false,
      );
    }
    await _rebuildBusinessOrdering(predmetId);
    final predmet = await (_db.select(
      _db.predmeti,
    )..where((item) => item.id.equals(predmetId))).getSingleOrNull();
    if (predmet != null) {
      final pending =
          await (_db.select(_db.iriu)..where(
                (item) =>
                    item.predmetId.equals(predmetId) &
                    item.cekaOdlukuKorisnika.equals(true),
              ))
              .get();
      if (pending.isEmpty) {
        await _persistCurrentOwnerSnapshot(predmet);
      }
    }
  }

  Future<PredmetScenarioSnapshot?> _readScenarioSnapshot(int predmetId) {
    return (_db.select(
      _db.predmetScenarioSnapshots,
    )..where((item) => item.predmetId.equals(predmetId))).getSingleOrNull();
  }

  Future<void> _persistCurrentOwnerSnapshot(PredmetiData predmet) async {
    final result = const OwnerScenarioPolicyKernel().evaluate(predmet);
    if (!result.isComplete) return;
    final definitionRecord =
        await (_db.select(_db.scenarioDefinitions)
              ..where((item) => item.id.equals(result.scenarioId!))
              ..orderBy([(item) => OrderingTerm.desc(item.version)]))
            .getSingleOrNull();
    final definition = definitionRecord == null
        ? null
        : ScenarioModuleRepository(_db).definitionFromRecord(definitionRecord);
    await _writeScenarioSnapshot(
      _ownerScenarioSnapshot(
        result: result,
        osnovniPaket: result.baseCategories,
        definition: definition,
      ),
      predmetId: predmet.id,
    );
  }

  Future<void> _writeScenarioSnapshot(
    ScenarioAssignmentSnapshot snapshot, {
    required int predmetId,
  }) async {
    await _db
        .into(_db.predmetScenarioSnapshots)
        .insertOnConflictUpdate(
          PredmetScenarioSnapshotsCompanion.insert(
            predmetId: Value(predmetId),
            moduleId: snapshot.moduleId,
            scenarioId: snapshot.scenarioId,
            scenarioVersion: snapshot.scenarioVersion,
            snapshotJson: jsonEncode(snapshot.toJsonMap()),
            snapshotHash: snapshot.snapshotHash,
            assignedAt: snapshot.assignedAt,
          ),
        );
  }

  ScenarioAssignmentSnapshot _ownerScenarioSnapshot({
    required OwnerScenarioResult result,
    required Set<String> osnovniPaket,
    ScenarioDefinition? definition,
  }) {
    final key = result.key!;
    final criteria = <ScenarioCondition>[
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.uzrokSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: [key.cause],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.vrstaCeremonije,
          operator: ScenarioCriterionOperator.equals,
          values: [key.ceremony],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.opelo,
          operator: ScenarioCriterionOperator.equals,
          values: [key.opelo],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.sahranaVanSrbije,
          operator: key.international
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.docekPosmrtnihOstataka,
          operator: key.docek
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
    ];
    if (!key.docek) {
      criteria.add(
        ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: [key.place!],
          ),
        ),
      );
      if (!key.ceremony.startsWith('KREMACIJA')) {
        criteria
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGroblja,
                operator: ScenarioCriterionOperator.equals,
                values: [key.cemeteryType],
              ),
            ),
          )
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGrobnogMesta,
                operator: ScenarioCriterionOperator.equals,
                values: [key.burialPlace],
              ),
            ),
          );
      }
    }
    final generatedDefinition = ScenarioDefinition(
      id: result.scenarioId!,
      name: 'SCENARIO ${result.scenarioId}',
      condition: ScenarioCondition.all(criteria),
      consequences: result.consequences,
      description: 'Owner map snapshot for ${result.scenarioId}.',
    );
    return ScenarioAssignmentSnapshot.create(
      moduleId: 'scenario',
      scenarioId: result.scenarioId!,
      scenarioVersion: 1,
      scenario: definition ?? generatedDefinition,
      osnovniPaket: osnovniPaket,
      assignedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<List<IriuData>> getIriu(int predmetId) async {
    final rows = await _rawIriu(predmetId);
    return _orderedProjection(predmetId, rows);
  }

  Future<List<IriuData>> _rawIriu(int predmetId) =>
      (_db.select(_db.iriu)
            ..where((i) => i.predmetId.equals(predmetId))
            // Raw order is suitable for transfer/internal work only.
            ..orderBy([(i) => OrderingTerm.asc(i.id)]))
          .get();

  Future<List<IriuData>> _orderedProjection(
    int predmetId,
    List<IriuData> rows,
  ) async {
    if (rows.isEmpty) return const <IriuData>[];
    final context = await _orderingContext(predmetId);
    return _orderingService.orderedRows(rows, context: context);
  }

  Future<IriuOrderingContext> _orderingContext(int predmetId) async {
    final provenance = await (_db.select(_db.iriuProvenance)).get();
    final origins = <int, String>{
      for (final item in provenance) item.iriuId: item.origin,
    };
    final snapshotRow = await _readScenarioSnapshot(predmetId);
    if (snapshotRow == null || snapshotRow.snapshotJson.trim().isEmpty) {
      final module = await (_db.select(
        _db.scenarioModules,
      )..where((item) => item.id.equals(ScenarioModuleRepository.moduleId)))
          .getSingleOrNull();
      final osnovni = module == null
          ? ScenarioModuleRepository.defaultOsnovniPaket
          : ScenarioModuleRepository(_db).readOsnovniPaket(module);
      return IriuOrderingContext(
        osnovniCategories: osnovni,
        provenanceOrigins: origins,
        moduleId: ScenarioModuleRepository.moduleId,
      );
    }
    try {
      final snapshot = ScenarioAssignmentSnapshot.fromJsonMap(
        jsonDecode(snapshotRow.snapshotJson) as Map<String, dynamic>,
      );
      final activeConsequences = snapshot.scenario.consequences.where(
        (item) => item.action != ScenarioConsequenceAction.suppressed,
      );
      return IriuOrderingContext(
        osnovniCategories: snapshot.osnovniPaket,
        scenarioCategories: activeConsequences
            .map((item) => item.katalogCategoryInternalName)
            .toSet(),
        scenarioBusinessSections: {
          for (final item in activeConsequences)
            item.katalogCategoryInternalName: item.section,
        },
        scenarioBusinessOrders: {
          for (final item in activeConsequences)
            item.katalogCategoryInternalName: item.order,
        },
        provenanceOrigins: origins,
        moduleId: snapshot.moduleId,
        scenarioId: snapshot.scenarioId,
        scenarioVersion: snapshot.scenarioVersion,
        scenarioRuleIds: {
          for (final item in activeConsequences)
            item.katalogCategoryInternalName: item.katalogCategoryInternalName,
        },
      );
    } on Object {
      // A malformed/legacy snapshot must not block opening a PREDMET. The
      // persisted provenance and business metadata remain deterministic
      // fallbacks until the normal scenario lifecycle repairs the snapshot.
      return IriuOrderingContext(provenanceOrigins: origins);
    }
  }

  Future<int> dodajStavku({
    required int predmetId,
    required String interniNaziv,
    required String nazivPrikaz,
    String? katalogStableArticleId,
    String kom = '1',
    double iznos = 0.0,
    double? cena,
    int redosled = 0,
  }) async {
    await _clearManagedManualDeletionDecisionIfNeeded(
      predmetId: predmetId,
      interniNaziv: interniNaziv,
    );
    final id = await _insertStavka(
      predmetId: predmetId,
      interniNaziv: interniNaziv,
      nazivPrikaz: nazivPrikaz,
      katalogStableArticleId: katalogStableArticleId,
      kom: kom,
      iznos: iznos,
      cena: cena,
      redosled: redosled,
    );
    await _applyStockEffectForCatalogSelection(
      predmetId: predmetId,
      iriuId: id,
      interniNaziv: interniNaziv,
      katalogStableArticleId: katalogStableArticleId,
      selectedNazivSnapshot: nazivPrikaz,
      selectedIznosSnapshot: iznos,
    );
    await _rebuildBusinessOrdering(predmetId);
    return id;
  }

  /// Canonical concrete KATALOG → IRiU insertion contract used by live
  /// pickers. Category-only scenario/base rows use their own lifecycle path.
  Future<int> dodajKatalogSelection({
    required int predmetId,
    required IriuCatalogSelection selection,
    int redosled = 0,
  }) {
    return _applyLiveCatalogSelection(
      predmetId: predmetId,
      selection: selection,
      redosled: redosled,
    );
  }

  /// One semantic implementation for live concrete KATALOG add/reselection.
  /// Historical imports, category-only rows and scenario reconciliation stay
  /// on their explicit transfer/lifecycle paths below.
  Future<int> _applyLiveCatalogSelection({
    int? predmetId,
    IriuData? row,
    required IriuCatalogSelection selection,
    int redosled = 0,
  }) async {
    if (row != null) {
      await _updateLiveCatalogSelection(row: row, selection: selection);
      await _rebuildBusinessOrdering(row.predmetId);
      return row.id;
    }
    final targetPredmetId = predmetId!;
    final classification = await _classifyLiveCategory(
      predmetId: targetPredmetId,
      interniNaziv: selection.interniNaziv,
    );
    await _clearManagedManualDeletionDecisionIfNeeded(
      predmetId: targetPredmetId,
      interniNaziv: selection.interniNaziv,
    );
    final id = await _insertStavka(
      predmetId: targetPredmetId,
      interniNaziv: selection.interniNaziv,
      nazivPrikaz: selection.nazivPrikaz,
      katalogStableArticleId: selection.katalogStableArticleId,
      kom: selection.kom,
      iznos: selection.iznos,
      cena: selection.cena,
      redosled: redosled,
      poslovnaCelina: classification.section,
      poslovniRedosled: classification.order,
      scenarioUpravlja: classification.managed,
    );
    await _persistLiveProvenance(
      id: id,
      internalName: selection.interniNaziv,
      classification: classification,
    );
    await _applyStockEffectForCatalogSelection(
      predmetId: targetPredmetId,
      iriuId: id,
      interniNaziv: selection.interniNaziv,
      katalogStableArticleId: selection.katalogStableArticleId,
      selectedNazivSnapshot: selection.nazivPrikaz,
      selectedIznosSnapshot: selection.iznos,
    );
    await _rebuildBusinessOrdering(targetPredmetId);
    return id;
  }

  Future<String> _catalogDisplayName(String internalName) async {
    final row =
        await (_db.select(_db.iriuKatalogConfig)
              ..where((item) => item.interniNaziv.equals(internalName)))
            .getSingleOrNull();
    final resolution = resolveIriuDisplayName(
      internalName: internalName,
      catalogDisplayNames: {if (row != null) internalName: row.nazivPrikaz},
    );
    if (!resolution.isResolved) {
      throw StateError(
        'IRiU category has no resolvable KATALOG name: $internalName',
      );
    }
    return resolution.displayName!;
  }

  Future<int> _insertStavka({
    required int predmetId,
    required String interniNaziv,
    required String nazivPrikaz,
    String? katalogStableArticleId,
    String kom = '1',
    double iznos = 0.0,
    double? cena,
    int redosled = 0,
    String poslovniStatus = 'AKTIVNO',
    String obezbedjuje = 'FIRMA',
    String poslovnoUpozorenje = '',
    String poslovniRazlog = '',
    int poslovnaCelina = 6,
    int poslovniRedosled = 0,
    bool finansijskiUkljuceno = true,
    bool scenarioUpravlja = false,
  }) async {
    final appliedCena = await _resolveAppliedUnitPrice(
      interniNaziv: interniNaziv,
      katalogStableArticleId: katalogStableArticleId,
      explicitCena: cena,
    );
    final effectiveIznos = iznos == 0 && appliedCena > 0
        ? _amountForQuantity(kom, appliedCena)
        : iznos;
    return _db
        .into(_db.iriu)
        .insert(
          IriuCompanion(
            predmetId: Value(predmetId),
            katalogStableArticleId: Value(katalogStableArticleId),
            interniNaziv: Value(interniNaziv),
            nazivPrikaz: Value(nazivPrikaz),
            kom: Value(kom),
            cena: Value(appliedCena),
            iznos: Value(effectiveIznos),
            redosled: Value(redosled),
            poslovniStatus: Value(poslovniStatus),
            obezbedjuje: Value(obezbedjuje),
            poslovnoUpozorenje: Value(poslovnoUpozorenje),
            poslovniRazlog: Value(poslovniRazlog),
            poslovnaCelina: Value(poslovnaCelina),
            poslovniRedosled: Value(poslovniRedosled),
            finansijskiUkljuceno: Value(finansijskiUkljuceno),
            scenarioUpravlja: Value(scenarioUpravlja),
          ),
        );
  }

  Future<void> azurirajStavku(int id, IriuCompanion companion) =>
      (_db.update(_db.iriu)..where((i) => i.id.equals(id))).write(companion);

  Future<void> azurirajKatalogIzborStavke({
    required IriuData row,
    required String nazivPrikaz,
    required String kom,
    required double iznos,
    required String? katalogStableArticleId,
    double? cena,
    String? interniNaziv,
  }) async {
    await _updateLiveCatalogSelection(
      row: row,
      selection: IriuCatalogSelection(
        interniNaziv: interniNaziv?.trim().isEmpty == true
            ? row.interniNaziv
            : interniNaziv ?? row.interniNaziv,
        nazivPrikaz: nazivPrikaz,
        katalogStableArticleId: _normalizeNullableStableArticleId(
          katalogStableArticleId,
        ),
        cena: cena ?? row.cena,
        kom: kom,
        iznos: iznos,
      ),
    );
  }

  Future<void> _updateLiveCatalogSelection({
    required IriuData row,
    required IriuCatalogSelection selection,
  }) async {
    final nextStableArticleId = _normalizeNullableStableArticleId(
      selection.katalogStableArticleId,
    );
    final nextInterniNaziv = selection.interniNaziv.trim();
    final normalizedInterniNaziv = nextInterniNaziv.isEmpty
        ? row.interniNaziv
        : nextInterniNaziv;
    final classification = await _classifyLiveCategory(
      predmetId: row.predmetId,
      interniNaziv: normalizedInterniNaziv,
    );

    await _db.transaction(() async {
      if (nextStableArticleId != null &&
          _isCoveredStockCategory(row.interniNaziv)) {
        final current = await (_db.select(
          _db.iriu,
        )..where((i) => i.id.equals(row.id))).getSingleOrNull();

        if (current != null && _isCoveredStockCategory(current.interniNaziv)) {
          final previousStableArticleId = _normalizeNullableStableArticleId(
            current.katalogStableArticleId,
          );
          final lifecycleService = _stanjeRobeLifecycleService();

          if (previousStableArticleId == null) {
            await lifecycleService.applySelectionEffectForCoveredCategory(
              predmetId: current.predmetId,
              iriuId: current.id,
              kategorija: current.interniNaziv,
              stableArticleId: nextStableArticleId,
              selectedNazivSnapshot: selection.nazivPrikaz,
              selectedIznosSnapshot: selection.iznos,
            );
          } else {
            await lifecycleService.replaceSelectionEffectForCoveredCategory(
              predmetId: current.predmetId,
              iriuId: current.id,
              kategorija: current.interniNaziv,
              stableArticleId: nextStableArticleId,
              selectedNazivSnapshot: selection.nazivPrikaz,
              selectedIznosSnapshot: selection.iznos,
            );
          }
        }
      }

      await (_db.update(_db.iriu)..where((i) => i.id.equals(row.id))).write(
        IriuCompanion(
          interniNaziv: normalizedInterniNaziv == row.interniNaziv
              ? const Value.absent()
              : Value(normalizedInterniNaziv),
          katalogStableArticleId: Value(nextStableArticleId),
          nazivPrikaz: Value(selection.nazivPrikaz),
          kom: Value(selection.kom),
          cena: Value(selection.cena),
          iznos: Value(selection.iznos),
          poslovnaCelina: Value(classification.section),
          poslovniRedosled: Value(classification.order),
          scenarioUpravlja: Value(classification.managed),
        ),
      );
      await _persistLiveProvenance(
        id: row.id,
        internalName: normalizedInterniNaziv,
        classification: classification,
      );
    });
  }

  Future<_LiveOrderingClassification> _classifyLiveCategory({
    required int predmetId,
    required String interniNaziv,
  }) async {
    final context = await _orderingContext(predmetId);
    final rows = await _rawIriu(predmetId);
    final existing = rows
        .where((item) => item.interniNaziv == interniNaziv)
        .where((item) => item.scenarioUpravlja)
        .firstOrNull;
    final isScenario = context.scenarioCategories.contains(interniNaziv);
    final isOsnovni = context.osnovniCategories.contains(interniNaziv);
    final managed = isScenario || isOsnovni || existing != null;
    final scenario =
        isScenario ||
        (!isOsnovni && existing != null && existing.poslovnaCelina >= 2);
    return _LiveOrderingClassification(
      managed: managed,
      scenario: scenario,
      section:
          context.scenarioBusinessSections[interniNaziv] ??
          existing?.poslovnaCelina ??
          (scenario
              ? 2
              : managed
              ? 1
              : 6),
      order:
          context.scenarioBusinessOrders[interniNaziv] ??
          existing?.poslovniRedosled ??
          0,
      context: context,
    );
  }

  Future<void> _persistLiveProvenance({
    required int id,
    required String internalName,
    required _LiveOrderingClassification classification,
  }) async {
    if (!classification.managed) {
      await (_db.delete(
        _db.iriuProvenance,
      )..where((item) => item.iriuId.equals(id))).go();
      return;
    }
    final context = classification.context;
    if (classification.scenario &&
        (context.moduleId == null ||
            context.scenarioId == null ||
            context.scenarioVersion == null)) {
      return;
    }
    await _db
        .into(_db.iriuProvenance)
        .insertOnConflictUpdate(
          IriuProvenanceCompanion.insert(
            iriuId: Value(id),
            origin: classification.scenario
                ? 'SCENARIO_PAKET'
                : 'OSNOVNI_PAKET',
            moduleId: Value(context.moduleId ?? 'scenario'),
            scenarioId: Value(
              classification.scenario ? context.scenarioId : null,
            ),
            scenarioVersion: Value(
              classification.scenario ? context.scenarioVersion : null,
            ),
            ruleId: Value(
              classification.scenario
                  ? (context.scenarioRuleIds[internalName] ?? internalName)
                  : null,
            ),
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }

  /// Canonical concrete KATALOG → IRiU reselection contract. Add and edit
  /// paths therefore apply the same immutable selection shape.
  Future<void> azurirajKatalogSelection({
    required IriuData row,
    required IriuCatalogSelection selection,
  }) {
    return _applyLiveCatalogSelection(
      row: row,
      selection: selection,
    ).then((_) {});
  }

  Future<double> _resolveAppliedUnitPrice({
    required String interniNaziv,
    required String? katalogStableArticleId,
    double? explicitCena,
  }) async {
    if (explicitCena != null) return explicitCena;
    final stableId = _normalizeNullableStableArticleId(katalogStableArticleId);
    if (stableId != null) {
      final article =
          await (_db.select(_db.katalogArtikli)
                ..where((row) => row.stableArticleId.equals(stableId))
                ..limit(1))
              .getSingleOrNull();
      if (article != null) return article.cena;
    }
    final config =
        await (_db.select(_db.iriuKatalogConfig)
              ..where((row) => row.interniNaziv.equals(interniNaziv))
              ..limit(1))
            .getSingleOrNull();
    return config?.tip == 'FIKSNA' ? config!.cena : 0.0;
  }

  bool _scenarioDecisionChanged(IriuData row, ScenarioConsequence decision) {
    return row.poslovniStatus != decision.businessStatus ||
        row.obezbedjuje != decision.provider.name ||
        row.poslovnoUpozorenje != decision.warning ||
        row.poslovniRazlog != decision.reason ||
        row.poslovnaCelina != decision.section ||
        row.poslovniRedosled != decision.order ||
        row.finansijskiUkljuceno != decision.financiallyIncluded;
  }

  List<String> _resolveScenarioLabels(
    Iterable<String> internalNames,
    Map<String, String> catalogDisplayNames,
  ) {
    final labels = <String>[];
    for (final internalName in internalNames) {
      final resolution = resolveIriuDisplayName(
        internalName: internalName,
        catalogDisplayNames: catalogDisplayNames,
      );
      if (!resolution.isResolved) {
        throw StateError(
          'SCENARIO consequence has no resolvable KATALOG category: '
          '$internalName',
        );
      }
      labels.add(resolution.displayName!);
    }
    return labels;
  }

  double _amountForQuantity(String kom, double cena) {
    final quantity = tryParseSerbianManualAmount(kom.trim()) ?? 1.0;
    return quantity * cena;
  }

  Future<void> obrisiStavku(int id) async {
    final row = await (_db.select(
      _db.iriu,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.iriu)..where((i) => i.id.equals(id))).go();
    if (row != null) {
      await _rebuildBusinessOrdering(row.predmetId);
    }
  }

  Future<void> obrisiStavkuSaLifecycleMemorijom({
    required int predmetId,
    required IriuData row,
    bool rememberManualDeletion = true,
  }) async {
    final scenarioProvenance = await (_db.select(
      _db.iriuProvenance,
    )..where((item) => item.iriuId.equals(row.id))).getSingleOrNull();
    await _db.transaction(() async {
      await _restoreStockEffectForDeletedCatalogSelection(row);
      await (_db.delete(_db.iriu)..where((i) => i.id.equals(row.id))).go();
      if (rememberManualDeletion) {
        if (scenarioProvenance?.moduleId == ScenarioModuleRepository.moduleId) {
          await _rememberDismissal(
            predmetId: predmetId,
            interniNaziv: row.interniNaziv,
            scopeKey: _scenarioScopeKey,
          );
        }
        await _rememberManagedManualDeletionIfNeeded(
          predmetId: predmetId,
          interniNaziv: row.interniNaziv,
        );
      }
    });
    await _rebuildBusinessOrdering(predmetId);
  }

  Future<void> _applyStockEffectForCatalogSelection({
    required int predmetId,
    required int iriuId,
    required String interniNaziv,
    required String? katalogStableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
  }) async {
    final stableArticleId = _normalizeNullableStableArticleId(
      katalogStableArticleId,
    );
    if (stableArticleId == null || !_isCoveredStockCategory(interniNaziv)) {
      return;
    }

    await _stanjeRobeLifecycleService().applySelectionEffectForCoveredCategory(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: interniNaziv,
      stableArticleId: stableArticleId,
      selectedNazivSnapshot: selectedNazivSnapshot,
      selectedIznosSnapshot: selectedIznosSnapshot,
    );
  }

  Future<void> _restoreStockEffectForDeletedCatalogSelection(
    IriuData row,
  ) async {
    if (!_isCoveredStockCategory(row.interniNaziv) ||
        _normalizeNullableStableArticleId(row.katalogStableArticleId) == null) {
      return;
    }

    await _stanjeRobeLifecycleService()
        .restoreSelectionEffectForCoveredCategory(
          predmetId: row.predmetId,
          iriuId: row.id,
          kategorija: row.interniNaziv,
        );
  }

  bool _isCoveredStockCategory(String interniNaziv) {
    return interniNaziv == IriuK.sanduk ||
        interniNaziv == IriuK.obelezje ||
        interniNaziv == IriuK.pokrovGarnitura;
  }

  String? _normalizeNullableStableArticleId(String? stableArticleId) {
    final normalized = stableArticleId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  /// Proverava da li stavka sa datim internim nazivom već postoji na predmetu.
  Future<bool> stavkaPostoji(int predmetId, String interniNaziv) async {
    final res =
        await (_db.select(_db.iriu)..where(
              (i) =>
                  i.predmetId.equals(predmetId) &
                  i.interniNaziv.equals(interniNaziv),
            ))
            .get();
    return res.isNotEmpty;
  }

  /// Dodaje stavku samo ako već ne postoji.
  Future<void> predloziAkoNema({
    required int predmetId,
    required String interniNaziv,
    required String nazivPrikaz,
    int redosled = 0,
  }) async {
    if (!await stavkaPostoji(predmetId, interniNaziv)) {
      await _insertStavka(
        predmetId: predmetId,
        interniNaziv: interniNaziv,
        nazivPrikaz: nazivPrikaz,
        redosled: redosled,
      );
      await _rebuildBusinessOrdering(predmetId);
    }
  }

  /// Briše stavku po internom nazivu (za uklanjanje auto-predloženih).
  Future<void> obrisiPoNazivu(int predmetId, String interniNaziv) async {
    await (_db.delete(_db.iriu)..where(
          (i) =>
              i.predmetId.equals(predmetId) &
              i.interniNaziv.equals(interniNaziv),
        ))
        .go();
    await _rebuildBusinessOrdering(predmetId);
  }

  /// Sledeći redosled za dati predmet.
  Future<int> sledeciredosled(int predmetId) async {
    final items = await getIriu(predmetId);
    if (items.isEmpty) return 0;
    return items.map((i) => i.redosled).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Ubacuje novi red odmah ispod poslednjeg reda iste kategorije.
  /// Ako kategorija ne postoji — dodaje na kraj.
  Future<int> redosledPosleKategorije(
    int predmetId,
    String interniNaziv,
  ) async {
    final items = await getIriu(predmetId);
    if (items.isEmpty) return 0;

    final same = items.where((i) => i.interniNaziv == interniNaziv).toList();
    if (same.isEmpty) {
      return items.map((i) => i.redosled).reduce((a, b) => a > b ? a : b) + 1;
    }

    final katMax = same.map((i) => i.redosled).reduce((a, b) => a > b ? a : b);

    // Pomeri sve redove iza katMax za +1
    for (final row in items.where((i) => i.redosled > katMax)) {
      await azurirajStavku(
        row.id,
        IriuCompanion(redosled: Value(row.redosled + 1)),
      );
    }
    return katMax + 1;
  }

  /// Sve IRIU stavke — za izveštaje.
  Future<List<IriuData>> getSveIriu() => _db.select(_db.iriu).get();

  Future<Set<String>> getDismissedMestoSmrtiCategories(int predmetId) async {
    return _getDismissedCategories(
      predmetId: predmetId,
      scopeKey: _mestoSmrtiScopeKey,
    );
  }

  Future<Set<String>> getDismissedBlok2Categories(int predmetId) async {
    return _getDismissedCategories(
      predmetId: predmetId,
      scopeKey: _blok2ScopeKey,
    );
  }

  Future<Set<String>> _getDismissedCategories({
    required int predmetId,
    required String scopeKey,
  }) async {
    final result = await _db
        .customSelect(
          '''
        SELECT interni_naziv
        FROM iriu_lifecycle_decisions
        WHERE predmet_id = ? AND scope_key = ? AND decision_key = ?
      ''',
          variables: [
            Variable<int>(predmetId),
            Variable<String>(scopeKey),
            const Variable<String>(_manualDeletionDecisionKey),
          ],
          readsFrom: {},
        )
        .get();
    return result.map((row) => row.read<String>('interni_naziv')).toSet();
  }

  Future<void> syncMestoSmrtiManagedRows({
    required int predmetId,
    required PredmetiData predmet,
    required MestoSmrtiIriuLifecycleService lifecycleService,
  }) async {
    final storedRows = await getIriu(predmetId);
    final dismissedCategories = await getDismissedMestoSmrtiCategories(
      predmetId,
    );
    final plan = lifecycleService.planForCurrentState(
      predmet: predmet,
      storedRows: storedRows,
      dismissedCategories: dismissedCategories,
    );

    var insertedAny = false;
    for (final internalName in plan.categoriesToInsert) {
      final red = await sledeciredosled(predmetId);
      await _insertStavka(
        predmetId: predmetId,
        interniNaziv: internalName,
        nazivPrikaz: await _catalogDisplayName(internalName),
        redosled: red,
      );
      insertedAny = true;
    }
    if (insertedAny) {
      await _rebuildBusinessOrdering(predmetId);
    }
  }

  Future<void> syncBlok2ManagedRows({
    required int predmetId,
    required PredmetiData predmet,
    required Blok2IriuLifecycleService lifecycleService,
  }) async {
    final storedRows = await getIriu(predmetId);
    final dismissedCategories = await getDismissedBlok2Categories(predmetId);
    final plan = lifecycleService.planForCurrentState(
      predmet: predmet,
      storedRows: storedRows,
      dismissedCategories: dismissedCategories,
    );

    var insertedAny = false;
    for (final internalName in plan.categoriesToInsert) {
      final red = await sledeciredosled(predmetId);
      await _insertStavka(
        predmetId: predmetId,
        interniNaziv: internalName,
        nazivPrikaz: await _catalogDisplayName(internalName),
        redosled: red,
      );
      insertedAny = true;
    }
    if (insertedAny) {
      await _rebuildBusinessOrdering(predmetId);
    }
  }

  Future<void> _rebuildBusinessOrdering(int predmetId) async {
    final rows = await _rawIriu(predmetId);
    if (rows.isEmpty) return;
    final orderedRows = _orderingService.orderedRows(
      rows,
      context: await _orderingContext(predmetId),
    );
    await _db.transaction(() async {
      for (var index = 0; index < orderedRows.length; index++) {
        final row = orderedRows[index];
        if (row.redosled == index) continue;
        await (_db.update(_db.iriu)..where((i) => i.id.equals(row.id))).write(
          IriuCompanion(redosled: Value(index)),
        );
      }
    });
  }

  Future<void> _rememberManagedManualDeletionIfNeeded({
    required int predmetId,
    required String interniNaziv,
  }) async {
    final scopeKey = _scopeKeyForManagedCategory(interniNaziv);
    if (scopeKey == null) {
      return;
    }
    await _db.customStatement(
      '''
        INSERT OR IGNORE INTO iriu_lifecycle_decisions (
          predmet_id,
          interni_naziv,
          scope_key,
          decision_key,
          created_at
        ) VALUES (?, ?, ?, ?, ?)
      ''',
      [
        predmetId,
        interniNaziv,
        scopeKey,
        _manualDeletionDecisionKey,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<void> _rememberDismissal({
    required int predmetId,
    required String interniNaziv,
    required String scopeKey,
  }) => _db.customStatement(
    '''
        INSERT OR IGNORE INTO iriu_lifecycle_decisions (
          predmet_id, interni_naziv, scope_key, decision_key, created_at
        ) VALUES (?, ?, ?, ?, ?)
        ''',
    [
      predmetId,
      interniNaziv,
      scopeKey,
      _manualDeletionDecisionKey,
      DateTime.now().toIso8601String(),
    ],
  );

  Future<void> _clearDismissal({
    required int predmetId,
    required String interniNaziv,
    required String scopeKey,
  }) => _db.customStatement(
    '''
        DELETE FROM iriu_lifecycle_decisions
        WHERE predmet_id = ? AND interni_naziv = ? AND scope_key = ?
          AND decision_key = ?
        ''',
    [predmetId, interniNaziv, scopeKey, _manualDeletionDecisionKey],
  );

  Future<void> rememberBlok2ManagedDismissal({
    required int predmetId,
    required String interniNaziv,
  }) async {
    if (!IriuTruthRules.blok2ManagedCategories.contains(interniNaziv)) {
      return;
    }
    await _rememberManagedManualDeletionIfNeeded(
      predmetId: predmetId,
      interniNaziv: interniNaziv,
    );
  }

  Future<void> _clearManagedManualDeletionDecisionIfNeeded({
    required int predmetId,
    required String interniNaziv,
  }) async {
    final scopeKey = _scopeKeyForManagedCategory(interniNaziv);
    if (scopeKey == null) {
      await _clearDismissal(
        predmetId: predmetId,
        interniNaziv: interniNaziv,
        scopeKey: _scenarioScopeKey,
      );
      return;
    }
    await _db.customStatement(
      '''
        DELETE FROM iriu_lifecycle_decisions
        WHERE predmet_id = ? AND interni_naziv = ? AND scope_key = ? AND decision_key = ?
      ''',
      [predmetId, interniNaziv, scopeKey, _manualDeletionDecisionKey],
    );
    await _clearDismissal(
      predmetId: predmetId,
      interniNaziv: interniNaziv,
      scopeKey: _scenarioScopeKey,
    );
  }

  String? _scopeKeyForManagedCategory(String interniNaziv) {
    if (IriuTruthRules.mestoSmrtiManagedCategories.contains(interniNaziv)) {
      return _mestoSmrtiScopeKey;
    }
    if (IriuTruthRules.blok2ManagedCategories.contains(interniNaziv)) {
      return _blok2ScopeKey;
    }
    return null;
  }
}

class ScenarioSyncResult {
  const ScenarioSyncResult({
    required this.matchedScenarioIds,
    required this.addedCategories,
    this.addedCategoryLabels = const <String>[],
    required this.removedCategories,
    this.removedCategoryLabels = const <String>[],
    this.changedCategories = const <String>[],
    this.changedCategoryLabels = const <String>[],
    this.pendingUserDecisionRows = const <IriuData>[],
    this.scenarioSnapshotChanged = false,
  });

  final List<String> matchedScenarioIds;
  final List<String> addedCategories;
  final List<String> addedCategoryLabels;
  final List<String> removedCategories;
  final List<String> removedCategoryLabels;
  final List<String> changedCategories;
  final List<String> changedCategoryLabels;
  final List<IriuData> pendingUserDecisionRows;
  final bool scenarioSnapshotChanged;

  bool get changed =>
      addedCategories.isNotEmpty ||
      removedCategories.isNotEmpty ||
      changedCategories.isNotEmpty ||
      pendingUserDecisionRows.isNotEmpty ||
      scenarioSnapshotChanged;
}
