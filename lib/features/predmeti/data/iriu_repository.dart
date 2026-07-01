import 'package:drift/drift.dart';

import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../core_v2/rules/iriu_truth_rules.dart';
import '../core_v2/services/blok2_iriu_lifecycle_service.dart';
import '../core_v2/services/iriu_ordering_service.dart';
import '../core_v2/services/mesto_smrti_iriu_lifecycle_service.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';

class IriuRepository {
  const IriuRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;
  static const _orderingService = IriuOrderingService();
  static const String _mestoSmrtiScopeKey = 'MESTO_SMRTI_BLOCK';
  static const String _blok2ScopeKey = 'BLOK2';
  static const String _manualDeletionDecisionKey = 'MANUAL_DELETE';

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
            ..orderBy([(i) => OrderingTerm.asc(i.redosled)]))
          .watch();

  Future<List<IriuData>> getIriu(int predmetId) =>
      (_db.select(_db.iriu)
            ..where((i) => i.predmetId.equals(predmetId))
            ..orderBy([(i) => OrderingTerm.asc(i.redosled)]))
          .get();

  Future<int> dodajStavku({
    required int predmetId,
    required String interniNaziv,
    required String nazivPrikaz,
    String? katalogStableArticleId,
    String kom = '1',
    double iznos = 0.0,
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

  Future<int> _insertStavka({
    required int predmetId,
    required String interniNaziv,
    required String nazivPrikaz,
    String? katalogStableArticleId,
    String kom = '1',
    double iznos = 0.0,
    int redosled = 0,
  }) =>
      _db.into(_db.iriu).insert(
        IriuCompanion(
          predmetId: Value(predmetId),
          katalogStableArticleId: Value(katalogStableArticleId),
          interniNaziv: Value(interniNaziv),
          nazivPrikaz: Value(nazivPrikaz),
          kom: Value(kom),
          iznos: Value(iznos),
          redosled: Value(redosled),
        ),
      );

  Future<void> azurirajStavku(int id, IriuCompanion companion) =>
      (_db.update(_db.iriu)..where((i) => i.id.equals(id))).write(companion);

  Future<void> azurirajKatalogIzborStavke({
    required IriuData row,
    required String nazivPrikaz,
    required String kom,
    required double iznos,
    required String? katalogStableArticleId,
    String? interniNaziv,
  }) async {
    final nextStableArticleId =
        _normalizeNullableStableArticleId(katalogStableArticleId);
    final nextInterniNaziv = interniNaziv?.trim();
    final normalizedInterniNaziv =
        nextInterniNaziv == null || nextInterniNaziv.isEmpty
        ? row.interniNaziv
        : nextInterniNaziv;

    await _db.transaction(() async {
      if (nextStableArticleId != null &&
          _isCoveredStockCategory(row.interniNaziv)) {
        final current = await (_db.select(_db.iriu)
              ..where((i) => i.id.equals(row.id)))
            .getSingleOrNull();

        if (current != null && _isCoveredStockCategory(current.interniNaziv)) {
          final previousStableArticleId =
              _normalizeNullableStableArticleId(current.katalogStableArticleId);
          final lifecycleService = _stanjeRobeLifecycleService();

          if (previousStableArticleId == null) {
            await lifecycleService.applySelectionEffectForCoveredCategory(
              predmetId: current.predmetId,
              iriuId: current.id,
              kategorija: current.interniNaziv,
              stableArticleId: nextStableArticleId,
              selectedNazivSnapshot: nazivPrikaz,
              selectedIznosSnapshot: iznos,
            );
          } else {
            await lifecycleService.replaceSelectionEffectForCoveredCategory(
              predmetId: current.predmetId,
              iriuId: current.id,
              kategorija: current.interniNaziv,
              stableArticleId: nextStableArticleId,
              selectedNazivSnapshot: nazivPrikaz,
              selectedIznosSnapshot: iznos,
            );
          }
        }
      }

      await (_db.update(_db.iriu)..where((i) => i.id.equals(row.id))).write(
        IriuCompanion(
          interniNaziv: normalizedInterniNaziv == row.interniNaziv
              ? const Value.absent()
              : Value(normalizedInterniNaziv),
          katalogStableArticleId: Value(katalogStableArticleId),
          nazivPrikaz: Value(nazivPrikaz),
          kom: Value(kom),
          iznos: Value(iznos),
        ),
      );
    });
  }

  Future<void> obrisiStavku(int id) async {
    final row = await (_db.select(_db.iriu)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
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
    await _db.transaction(() async {
      await _restoreStockEffectForDeletedCatalogSelection(row);
      await (_db.delete(_db.iriu)..where((i) => i.id.equals(row.id))).go();
      if (rememberManualDeletion) {
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
    final stableArticleId =
        _normalizeNullableStableArticleId(katalogStableArticleId);
    if (stableArticleId == null || !_isCoveredStockCategory(interniNaziv)) {
      return;
    }

    await _stanjeRobeLifecycleService()
        .applySelectionEffectForCoveredCategory(
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
    final res = await (_db.select(_db.iriu)
          ..where(
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
    await (_db.delete(_db.iriu)
          ..where(
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
      int predmetId, String interniNaziv) async {
    final items = await getIriu(predmetId);
    if (items.isEmpty) return 0;

    final same = items.where((i) => i.interniNaziv == interniNaziv).toList();
    if (same.isEmpty) {
      return items.map((i) => i.redosled).reduce((a, b) => a > b ? a : b) + 1;
    }

    final katMax =
        same.map((i) => i.redosled).reduce((a, b) => a > b ? a : b);

    // Pomeri sve redove iza katMax za +1
    for (final row in items.where((i) => i.redosled > katMax)) {
      await azurirajStavku(
          row.id, IriuCompanion(redosled: Value(row.redosled + 1)));
    }
    return katMax + 1;
  }

  /// Sve IRIU stavke — za izveštaje.
  Future<List<IriuData>> getSveIriu() =>
      _db.select(_db.iriu).get();

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
    final result = await _db.customSelect(
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
    ).get();
    return result
        .map((row) => row.read<String>('interni_naziv'))
        .toSet();
  }

  Future<void> syncMestoSmrtiManagedRows({
    required int predmetId,
    required PredmetiData predmet,
    required MestoSmrtiIriuLifecycleService lifecycleService,
  }) async {
    final storedRows = await getIriu(predmetId);
    final dismissedCategories =
        await getDismissedMestoSmrtiCategories(predmetId);
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
        nazivPrikaz: IriuK.naziviPrikaz[internalName] ?? internalName,
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
        nazivPrikaz: IriuK.naziviPrikaz[internalName] ?? internalName,
        redosled: red,
      );
      insertedAny = true;
    }
    if (insertedAny) {
      await _rebuildBusinessOrdering(predmetId);
    }
  }

  Future<void> _rebuildBusinessOrdering(int predmetId) async {
    final rows = await getIriu(predmetId);
    if (rows.isEmpty) return;
    final orderedRows = _orderingService.orderedRows(rows);
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
      return;
    }
    await _db.customStatement(
      '''
        DELETE FROM iriu_lifecycle_decisions
        WHERE predmet_id = ? AND interni_naziv = ? AND scope_key = ? AND decision_key = ?
      ''',
      [
        predmetId,
        interniNaziv,
        scopeKey,
        _manualDeletionDecisionKey,
      ],
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
