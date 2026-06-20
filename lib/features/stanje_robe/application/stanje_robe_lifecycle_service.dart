import '../../../core/database/database.dart';
import '../data/stanje_robe_effects_repository.dart';
import '../data/stanje_robe_posledice_repository.dart';
import '../data/stanje_robe_repository.dart';

enum StanjeRobeLifecycleOutcome {
  applied,
  alreadyApplied,
  unresolvedRecorded,
  alreadyUnresolved,
  restored,
  unresolvedCleared,
  noActiveEffect,
  replacedWithApplied,
  replacedWithUnresolved,
  operationallyDisabled,
  resolvedAfterReplenishment,
  resolutionNoActiveConsequence,
  resolutionNoUnresolvedEffect,
  resolutionInsufficientStock,
}

class StanjeRobeLifecycleResult {
  const StanjeRobeLifecycleResult({
    required this.outcome,
    this.effect,
    this.stockState,
  });

  final StanjeRobeLifecycleOutcome outcome;
  final StanjeRobeAppliedEffect? effect;
  final StanjeRobeStavkeData? stockState;
}

class StanjeRobeLifecycleService {
  StanjeRobeLifecycleService({
    required AppDatabase db,
    StanjeRobeRepository? stanjeRobeRepository,
    StanjeRobeEffectsRepository? effectsRepository,
    StanjeRobePoslediceRepository? poslediceRepository,
    Future<bool> Function()? isOperationallyActive,
  }) : _db = db,
       _stanjeRobeRepository = stanjeRobeRepository ?? StanjeRobeRepository(db),
       _effectsRepository =
           effectsRepository ?? StanjeRobeEffectsRepository(db),
       _poslediceRepository =
           poslediceRepository ?? StanjeRobePoslediceRepository(db),
       _isOperationallyActive = isOperationallyActive;

  static const double coveredCategoryEffectQuantity = 1.0;

  static const String kategorijaSanduk = 'SANDUK';
  static const String kategorijaObelezje = 'OBELEZJE';
  static const String kategorijaPokrovGarnitura = 'POKROV_GARNITURA';

  static bool isCoveredCategory(String kategorija) {
    return _coveredCategories.contains(kategorija.trim());
  }

  static String displayLabelForCoveredCategory(String kategorija) {
    return switch (kategorija.trim()) {
      kategorijaSanduk => 'SANDUK',
      kategorijaObelezje => 'OBELEŽJE',
      kategorijaPokrovGarnitura => 'POKROV GARNITURA',
      _ => kategorija,
    };
  }

  final AppDatabase _db;
  final StanjeRobeRepository _stanjeRobeRepository;
  final StanjeRobeEffectsRepository _effectsRepository;
  final StanjeRobePoslediceRepository _poslediceRepository;
  final Future<bool> Function()? _isOperationallyActive;

  Future<StanjeRobeAppliedEffect?> getActiveEffectForSelection({
    required int predmetId,
    required int iriuId,
    required String kategorija,
  }) {
    return _effectsRepository.getCurrentEffectForSelection(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: _normalizeCoveredCategory(kategorija),
    );
  }

  Future<bool> hasSufficientStockForCoveredSelection({
    required String kategorija,
    required String stableArticleId,
  }) async {
    _normalizeCoveredCategory(kategorija);
    final normalizedArticleId = _normalizeStableArticleId(stableArticleId);
    if (!await _stanjeRobeOperationallyActive()) {
      return true;
    }
    final stanje = await _stanjeRobeRepository.getByStableArticleId(
      normalizedArticleId,
    );
    return _imaDovoljnoStanja(stanje);
  }

  Future<StanjeRobeLifecycleResult> applySelectionEffectForCoveredCategory({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String stableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
    String effectReason = 'SELECTION',
  }) async {
    final normalizedCategory = _normalizeCoveredCategory(kategorija);
    final normalizedArticleId = _normalizeStableArticleId(stableArticleId);
    if (!await _stanjeRobeOperationallyActive()) {
      return const StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.operationallyDisabled,
      );
    }

    return _db.transaction(() async {
      final current = await _effectsRepository.getCurrentEffectForSelection(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
      );

      if (current != null) {
        if (current.stableArticleId != normalizedArticleId) {
          throw StateError(
            'Different current effect already exists for selection context. '
            'Use replaceSelectionEffectForCoveredCategory.',
          );
        }

        if (current.effectStatus == stanjeRobeEffectStatusApplied) {
          final stockState = await _stanjeRobeRepository.getByStableArticleId(
            normalizedArticleId,
          );
          await _poslediceRepository.resolveActiveForIriuRow(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            resolvedReason: 'STOCK_EFFECT_ALREADY_APPLIED',
          );
          return StanjeRobeLifecycleResult(
            outcome: StanjeRobeLifecycleOutcome.alreadyApplied,
            effect: current,
            stockState: stockState,
          );
        }

        final stanje = await _stanjeRobeRepository.getByStableArticleId(
          normalizedArticleId,
        );
        if (!_imaDovoljnoStanja(stanje)) {
          await _recordUnresolvedConsequence(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            stableArticleId: normalizedArticleId,
            selectedNazivSnapshot: selectedNazivSnapshot,
            selectedIznosSnapshot: selectedIznosSnapshot,
            sourceLifecycleEvent: _sourceEventForEffectReason(effectReason),
            stockState: stanje,
          );
          return StanjeRobeLifecycleResult(
            outcome: StanjeRobeLifecycleOutcome.alreadyUnresolved,
            effect: current,
            stockState: stanje,
          );
        }

        final azuriranoStanje = await _stanjeRobeRepository
            .promeniTrenutnuKolicinu(
              stableArticleId: normalizedArticleId,
              delta: -coveredCategoryEffectQuantity,
            );
        final updatedEffect = await _effectsRepository.updateEffectStatus(
          effectId: current.id,
          effectStatus: stanjeRobeEffectStatusApplied,
          effectReason: effectReason,
        );
        await _poslediceRepository.resolveActiveForIriuRow(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          resolvedReason: 'STOCK_EFFECT_APPLIED',
        );
        return StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.applied,
          effect: updatedEffect,
          stockState: azuriranoStanje,
        );
      }

      final stanje = await _stanjeRobeRepository.getByStableArticleId(
        normalizedArticleId,
      );
      if (!_imaDovoljnoStanja(stanje)) {
        final effectId = await _effectsRepository.insertEffect(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          stableArticleId: normalizedArticleId,
          effectQuantity: coveredCategoryEffectQuantity,
          effectStatus: stanjeRobeEffectStatusUnresolved,
          effectReason: effectReason,
        );
        await _recordUnresolvedConsequence(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          stableArticleId: normalizedArticleId,
          selectedNazivSnapshot: selectedNazivSnapshot,
          selectedIznosSnapshot: selectedIznosSnapshot,
          sourceLifecycleEvent: _sourceEventForEffectReason(effectReason),
          stockState: stanje,
        );
        return StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.unresolvedRecorded,
          effect: await _effectsRepository.getById(effectId),
          stockState: stanje,
        );
      }

      final azuriranoStanje = await _stanjeRobeRepository
          .promeniTrenutnuKolicinu(
            stableArticleId: normalizedArticleId,
            delta: -coveredCategoryEffectQuantity,
          );
      final effectId = await _effectsRepository.insertEffect(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
        stableArticleId: normalizedArticleId,
        effectQuantity: coveredCategoryEffectQuantity,
        effectStatus: stanjeRobeEffectStatusApplied,
        effectReason: effectReason,
      );
      await _poslediceRepository.resolveActiveForIriuRow(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
        resolvedReason: 'STOCK_EFFECT_APPLIED',
      );
      return StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.applied,
        effect: await _effectsRepository.getById(effectId),
        stockState: azuriranoStanje,
      );
    });
  }

  Future<StanjeRobeLifecycleResult> restoreSelectionEffectForCoveredCategory({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    String appliedEffectReason = 'RESTORE',
    String unresolvedEffectReason = 'CLEAR_UNRESOLVED',
  }) async {
    final normalizedCategory = _normalizeCoveredCategory(kategorija);
    if (!await _stanjeRobeOperationallyActive()) {
      return const StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.operationallyDisabled,
      );
    }

    return _db.transaction(() async {
      final current = await _effectsRepository.getCurrentEffectForSelection(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
      );
      if (current == null) {
        return const StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.noActiveEffect,
        );
      }

      if (current.effectStatus == stanjeRobeEffectStatusApplied) {
        final azuriranoStanje = await _stanjeRobeRepository
            .promeniTrenutnuKolicinu(
              stableArticleId: current.stableArticleId,
              delta: current.effectQuantity,
            );
        final updatedEffect = await _effectsRepository.updateEffectStatus(
          effectId: current.id,
          effectStatus: stanjeRobeEffectStatusRestored,
          effectReason: appliedEffectReason,
        );
        await _poslediceRepository.cleanupForDeletedIriuRow(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
        );
        return StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.restored,
          effect: updatedEffect,
          stockState: azuriranoStanje,
        );
      }

      final updatedEffect = await _effectsRepository.updateEffectStatus(
        effectId: current.id,
        effectStatus: stanjeRobeEffectStatusCleared,
        effectReason: unresolvedEffectReason,
      );
      await _poslediceRepository.cleanupForDeletedIriuRow(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
      );
      return StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.unresolvedCleared,
        effect: updatedEffect,
      );
    });
  }

  Future<StanjeRobeLifecycleResult> replaceSelectionEffectForCoveredCategory({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String stableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
  }) async {
    final normalizedCategory = _normalizeCoveredCategory(kategorija);
    final normalizedArticleId = _normalizeStableArticleId(stableArticleId);
    if (!await _stanjeRobeOperationallyActive()) {
      return const StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.operationallyDisabled,
      );
    }

    return _db.transaction(() async {
      final current = await _effectsRepository.getCurrentEffectForSelection(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
      );

      if (current == null) {
        return applySelectionEffectForCoveredCategory(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          stableArticleId: normalizedArticleId,
          selectedNazivSnapshot: selectedNazivSnapshot,
          selectedIznosSnapshot: selectedIznosSnapshot,
          effectReason: 'REPLACEMENT_SELECTION',
        );
      }

      if (current.stableArticleId == normalizedArticleId) {
        if (current.effectStatus == stanjeRobeEffectStatusApplied) {
          final stanje = await _stanjeRobeRepository.getByStableArticleId(
            normalizedArticleId,
          );
          await _poslediceRepository.resolveActiveForIriuRow(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            resolvedReason: 'STOCK_EFFECT_ALREADY_APPLIED',
          );
          return StanjeRobeLifecycleResult(
            outcome: StanjeRobeLifecycleOutcome.alreadyApplied,
            effect: current,
            stockState: stanje,
          );
        }

        final stanje = await _stanjeRobeRepository.getByStableArticleId(
          normalizedArticleId,
        );
        if (!_imaDovoljnoStanja(stanje)) {
          await _recordUnresolvedConsequence(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            stableArticleId: normalizedArticleId,
            selectedNazivSnapshot: selectedNazivSnapshot,
            selectedIznosSnapshot: selectedIznosSnapshot,
            sourceLifecycleEvent:
                stanjeRobePosledicaEventReplacementNewSelection,
            stockState: stanje,
          );
          return StanjeRobeLifecycleResult(
            outcome: StanjeRobeLifecycleOutcome.alreadyUnresolved,
            effect: current,
            stockState: stanje,
          );
        }
      }

      if (current.effectStatus == stanjeRobeEffectStatusApplied) {
        await _stanjeRobeRepository.promeniTrenutnuKolicinu(
          stableArticleId: current.stableArticleId,
          delta: current.effectQuantity,
        );
        await _effectsRepository.updateEffectStatus(
          effectId: current.id,
          effectStatus: stanjeRobeEffectStatusRestored,
          effectReason: 'REPLACEMENT_OLD_RESTORED',
        );
        await _poslediceRepository.resolveActiveForIriuRow(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          resolvedReason: 'REPLACEMENT_OLD_RESTORED',
        );
      } else {
        await _effectsRepository.updateEffectStatus(
          effectId: current.id,
          effectStatus: stanjeRobeEffectStatusCleared,
          effectReason: 'REPLACEMENT_OLD_CLEARED',
        );
        await _poslediceRepository.supersedeActiveForIriuRow(
          predmetId: predmetId,
          iriuId: iriuId,
          kategorija: normalizedCategory,
          resolvedReason: 'REPLACEMENT_OLD_CLEARED',
        );
      }

      final replaced = await applySelectionEffectForCoveredCategory(
        predmetId: predmetId,
        iriuId: iriuId,
        kategorija: normalizedCategory,
        stableArticleId: normalizedArticleId,
        selectedNazivSnapshot: selectedNazivSnapshot,
        selectedIznosSnapshot: selectedIznosSnapshot,
        effectReason: 'REPLACEMENT_NEW_SELECTION',
      );

      if (replaced.outcome == StanjeRobeLifecycleOutcome.applied ||
          replaced.outcome == StanjeRobeLifecycleOutcome.alreadyApplied) {
        return StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.replacedWithApplied,
          effect: replaced.effect,
          stockState: replaced.stockState,
        );
      }

      return StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.replacedWithUnresolved,
        effect: replaced.effect,
        stockState: replaced.stockState,
      );
    });
  }

  Future<StanjeRobeLifecycleResult>
  resolveUnresolvedConsequenceAfterReplenishment({
    required int consequenceId,
  }) async {
    if (!await _stanjeRobeOperationallyActive()) {
      return const StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.operationallyDisabled,
      );
    }

    return _db.transaction(() async {
      final consequence = await _poslediceRepository.getActiveUnresolvedById(
        consequenceId,
      );
      if (consequence == null) {
        return const StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.resolutionNoActiveConsequence,
        );
      }

      final normalizedCategory = _normalizeCoveredCategory(
        consequence.kategorija,
      );
      final normalizedArticleId = _normalizeStableArticleId(
        consequence.katalogStableArticleId,
      );
      final current = await _effectsRepository.getCurrentEffectForSelection(
        predmetId: consequence.predmetId,
        iriuId: consequence.iriuId,
        kategorija: normalizedCategory,
      );

      if (current == null ||
          current.effectStatus != stanjeRobeEffectStatusUnresolved ||
          current.stableArticleId != normalizedArticleId ||
          current.effectQuantity <= 0) {
        return const StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.resolutionNoUnresolvedEffect,
        );
      }

      final stanje = await _stanjeRobeRepository.getByStableArticleId(
        normalizedArticleId,
      );
      if (stanje == null ||
          !stanje.aktivna ||
          stanje.trenutnaKolicina < current.effectQuantity) {
        return StanjeRobeLifecycleResult(
          outcome: StanjeRobeLifecycleOutcome.resolutionInsufficientStock,
          effect: current,
          stockState: stanje,
        );
      }

      final azuriranoStanje = await _stanjeRobeRepository
          .promeniTrenutnuKolicinu(
            stableArticleId: normalizedArticleId,
            delta: -current.effectQuantity,
          );
      final updatedEffect = await _effectsRepository.updateEffectStatus(
        effectId: current.id,
        effectStatus: stanjeRobeEffectStatusApplied,
        effectReason: 'ADMIN_REPLENISHMENT_RESOLUTION',
      );
      await _poslediceRepository.resolveActiveForIriuRow(
        predmetId: consequence.predmetId,
        iriuId: consequence.iriuId,
        kategorija: normalizedCategory,
        resolvedReason: 'ADMIN_REPLENISHMENT_RESOLUTION',
      );

      return StanjeRobeLifecycleResult(
        outcome: StanjeRobeLifecycleOutcome.resolvedAfterReplenishment,
        effect: updatedEffect,
        stockState: azuriranoStanje,
      );
    });
  }

  Future<List<StanjeRobeAppliedEffect>> listCurrentEffectsForPredmet(
    int predmetId,
  ) {
    return _effectsRepository.listCurrentEffectsForPredmet(predmetId);
  }

  Future<void> reconcileFullPredmetDelete(int predmetId) {
    return _reconcileCurrentPredmetEffects(
      predmetId: predmetId,
      appliedEffectReason: 'PREDMET_DELETE_RESTORED',
      unresolvedEffectReason: 'PREDMET_DELETE_CLEARED',
    );
  }

  Future<void> reconcilePredmetReplacement(int predmetId) {
    return _reconcileCurrentPredmetEffects(
      predmetId: predmetId,
      appliedEffectReason: 'PREDMET_REPLACEMENT_RESTORED',
      unresolvedEffectReason: 'PREDMET_REPLACEMENT_CLEARED',
    );
  }

  Future<void> _reconcileCurrentPredmetEffects({
    required int predmetId,
    required String appliedEffectReason,
    required String unresolvedEffectReason,
  }) {
    return _db.transaction(() async {
      final currentEffects = await _effectsRepository
          .listCurrentEffectsForPredmet(predmetId);

      for (final effect in currentEffects) {
        if (effect.effectStatus == stanjeRobeEffectStatusApplied) {
          await _stanjeRobeRepository.promeniTrenutnuKolicinu(
            stableArticleId: effect.stableArticleId,
            delta: effect.effectQuantity,
          );
          await _effectsRepository.updateEffectStatus(
            effectId: effect.id,
            effectStatus: stanjeRobeEffectStatusRestored,
            effectReason: appliedEffectReason,
          );
          continue;
        }

        await _effectsRepository.updateEffectStatus(
          effectId: effect.id,
          effectStatus: stanjeRobeEffectStatusCleared,
          effectReason: unresolvedEffectReason,
        );
      }

      await _poslediceRepository.deleteForPredmet(predmetId);
    });
  }

  bool _imaDovoljnoStanja(StanjeRobeStavkeData? stanje) {
    return stanje != null &&
        stanje.aktivna &&
        stanje.trenutnaKolicina >= coveredCategoryEffectQuantity;
  }

  Future<bool> _stanjeRobeOperationallyActive() async {
    final provider = _isOperationallyActive;
    if (provider == null) return true;
    return provider();
  }

  Future<void> _recordUnresolvedConsequence({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String stableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
    required String sourceLifecycleEvent,
    required StanjeRobeStavkeData? stockState,
  }) {
    return _poslediceRepository.createOrUpdateUnresolved(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
      katalogStableArticleId: stableArticleId,
      selectedNazivSnapshot: selectedNazivSnapshot,
      selectedIznosSnapshot: selectedIznosSnapshot,
      sourceLifecycleEvent: sourceLifecycleEvent,
      effectQuantity: coveredCategoryEffectQuantity,
      availableQuantityAtCreation: stockState?.trenutnaKolicina,
      shortageQuantityAtCreation: _shortageQuantity(stockState),
    );
  }

  double _shortageQuantity(StanjeRobeStavkeData? stanje) {
    if (_imaDovoljnoStanja(stanje)) return 0;
    final available = stanje == null || !stanje.aktivna
        ? 0.0
        : stanje.trenutnaKolicina;
    final shortage = coveredCategoryEffectQuantity - available;
    return shortage <= 0 ? 0 : shortage;
  }

  String _sourceEventForEffectReason(String effectReason) {
    return effectReason == 'REPLACEMENT_NEW_SELECTION' ||
            effectReason == 'REPLACEMENT_SELECTION'
        ? stanjeRobePosledicaEventReplacementNewSelection
        : stanjeRobePosledicaEventFirstSelection;
  }

  String _normalizeCoveredCategory(String kategorija) {
    final normalized = kategorija.trim();
    if (!_coveredCategories.contains(normalized)) {
      throw ArgumentError.value(
        kategorija,
        'kategorija',
        'Unsupported covered STANJE ROBE category.',
      );
    }
    return normalized;
  }

  String _normalizeStableArticleId(String stableArticleId) {
    final normalized = stableArticleId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        stableArticleId,
        'stableArticleId',
        'stableArticleId must not be empty.',
      );
    }
    return normalized;
  }

  static const Set<String> _coveredCategories = {
    kategorijaSanduk,
    kategorijaObelezje,
    kategorijaPokrovGarnitura,
  };
}
