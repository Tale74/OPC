import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

const String stanjeRobePosledicaTypeInsufficientStock = 'INSUFFICIENT_STOCK';

const String stanjeRobePosledicaStatusUnresolved = 'UNRESOLVED';
const String stanjeRobePosledicaStatusResolved = 'RESOLVED';
const String stanjeRobePosledicaStatusCleared = 'CLEARED';
const String stanjeRobePosledicaStatusSuperseded = 'SUPERSEDED';

const String stanjeRobePosledicaEventFirstSelection = 'FIRST_SELECTION';
const String stanjeRobePosledicaEventReplacementNewSelection =
    'REPLACEMENT_NEW_SELECTION';
const String stanjeRobePosledicaEventDeleteSelection = 'DELETE_SELECTION';
const String stanjeRobePosledicaEventSinglePredmetJsonImport =
    'SINGLE_PREDMET_JSON_IMPORT';

class StanjeRobePoslediceRepository {
  const StanjeRobePoslediceRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  AppDatabase get db => _db;

  Future<List<StanjeRobePoslediceData>> listActiveUnresolvedForPredmet(
    int predmetId,
  ) {
    return (_db.select(_db.stanjeRobePosledice)
          ..where(
            (t) =>
                t.predmetId.equals(predmetId) &
                t.status.equals(stanjeRobePosledicaStatusUnresolved),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.kategorija),
            (t) => OrderingTerm.asc(t.iriuId),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Stream<List<StanjeRobePoslediceData>> watchActiveUnresolvedForPredmet(
    int predmetId,
  ) {
    return (_db.select(_db.stanjeRobePosledice)
          ..where(
            (t) =>
                t.predmetId.equals(predmetId) &
                t.status.equals(stanjeRobePosledicaStatusUnresolved),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.kategorija),
            (t) => OrderingTerm.asc(t.iriuId),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch();
  }

  Stream<Set<int>> watchPredmetIdsWithActiveUnresolved() {
    return (_db.select(_db.stanjeRobePosledice)
          ..where((t) => t.status.equals(stanjeRobePosledicaStatusUnresolved)))
        .watch()
        .map((rows) => rows.map((row) => row.predmetId).toSet());
  }

  Stream<Map<String, int>> watchActiveUnresolvedCountsByStableArticleId() {
    return (_db.select(_db.stanjeRobePosledice)
          ..where((t) => t.status.equals(stanjeRobePosledicaStatusUnresolved)))
        .watch()
        .map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        counts.update(
          row.katalogStableArticleId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      return Map<String, int>.unmodifiable(counts);
        });
  }

  Stream<Map<String, List<StanjeRobePoslediceData>>>
      watchActiveUnresolvedByStableArticleId() {
    return (_db.select(_db.stanjeRobePosledice)
          ..where((t) => t.status.equals(stanjeRobePosledicaStatusUnresolved))
          ..orderBy([
            (t) => OrderingTerm.asc(t.katalogStableArticleId),
            (t) => OrderingTerm.asc(t.kategorija),
            (t) => OrderingTerm.asc(t.iriuId),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch()
        .map((rows) {
      final grouped = <String, List<StanjeRobePoslediceData>>{};
      for (final row in rows) {
        grouped.putIfAbsent(row.katalogStableArticleId, () => []).add(row);
      }
      return Map<String, List<StanjeRobePoslediceData>>.unmodifiable(
        grouped.map(
          (key, value) => MapEntry(
            key,
            List<StanjeRobePoslediceData>.unmodifiable(value),
          ),
        ),
      );
    });
  }

  Future<StanjeRobePoslediceData?> getActiveUnresolvedById(int id) {
    return (_db.select(_db.stanjeRobePosledice)
          ..where(
            (t) =>
                t.id.equals(id) &
                t.status.equals(stanjeRobePosledicaStatusUnresolved),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<StanjeRobePoslediceData?> getActiveUnresolvedForIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
  }) {
    final normalizedCategory = _normalizeKategorija(kategorija);
    return (_db.select(_db.stanjeRobePosledice)
          ..where(
            (t) =>
                t.predmetId.equals(predmetId) &
                t.iriuId.equals(iriuId) &
                t.kategorija.equals(normalizedCategory) &
                t.status.equals(stanjeRobePosledicaStatusUnresolved),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<StanjeRobePoslediceData> createOrUpdateUnresolved({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String katalogStableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
    required String sourceLifecycleEvent,
    required double effectQuantity,
    double? availableQuantityAtCreation,
    double? shortageQuantityAtCreation,
  }) async {
    final normalizedCategory = _normalizeKategorija(kategorija);
    final normalizedArticleId =
        _normalizeStableArticleId(katalogStableArticleId);
    final now = DateTime.now().toIso8601String();

    final active = await getActiveUnresolvedForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: normalizedCategory,
    );

    if (active != null && active.katalogStableArticleId != normalizedArticleId) {
      await _writeTerminalStatus(
        id: active.id,
        status: stanjeRobePosledicaStatusSuperseded,
        resolvedReason: 'REPLACED_WITH_UNRESOLVED',
        now: now,
      );
    } else if (active != null) {
      await (_db.update(_db.stanjeRobePosledice)
            ..where((t) => t.id.equals(active.id)))
          .write(
        StanjeRobePoslediceCompanion(
          selectedNazivSnapshot: Value(selectedNazivSnapshot),
          selectedIznosSnapshot: Value(selectedIznosSnapshot),
          sourceLifecycleEvent: Value(sourceLifecycleEvent),
          effectQuantity: Value(effectQuantity),
          availableQuantityAtCreation: Value(availableQuantityAtCreation),
          shortageQuantityAtCreation: Value(shortageQuantityAtCreation),
          updatedAt: Value(now),
        ),
      );
      final updated = await (_db.select(_db.stanjeRobePosledice)
            ..where((t) => t.id.equals(active.id)))
          .getSingle();
      return updated;
    }

    final id = await _db.into(_db.stanjeRobePosledice).insert(
          StanjeRobePoslediceCompanion.insert(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            katalogStableArticleId: normalizedArticleId,
            selectedNazivSnapshot: selectedNazivSnapshot,
            selectedIznosSnapshot: Value(selectedIznosSnapshot),
            consequenceType: stanjeRobePosledicaTypeInsufficientStock,
            status: stanjeRobePosledicaStatusUnresolved,
            createdAt: now,
            updatedAt: now,
            sourceLifecycleEvent: sourceLifecycleEvent,
            effectQuantity: Value(effectQuantity),
            availableQuantityAtCreation: Value(availableQuantityAtCreation),
            shortageQuantityAtCreation: Value(shortageQuantityAtCreation),
          ),
        );

    return (_db.select(_db.stanjeRobePosledice)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> resolveActiveForIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String resolvedReason,
  }) {
    return _terminalizeActiveForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
      status: stanjeRobePosledicaStatusResolved,
      resolvedReason: resolvedReason,
    );
  }

  Future<void> clearActiveForIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String resolvedReason,
  }) {
    return _terminalizeActiveForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
      status: stanjeRobePosledicaStatusCleared,
      resolvedReason: resolvedReason,
    );
  }

  Future<void> supersedeActiveForIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String resolvedReason,
  }) {
    return _terminalizeActiveForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
      status: stanjeRobePosledicaStatusSuperseded,
      resolvedReason: resolvedReason,
    );
  }

  Future<void> cleanupForDeletedIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
  }) {
    return clearActiveForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
      resolvedReason: 'DELETED_SELECTION',
    );
  }

  Future<int> deleteForPredmet(int predmetId) {
    return (_db.delete(_db.stanjeRobePosledice)
          ..where((t) => t.predmetId.equals(predmetId)))
        .go();
  }

  Future<StanjeRobePoslediceData> insertImportedUnresolved({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String katalogStableArticleId,
    required String selectedNazivSnapshot,
    required double selectedIznosSnapshot,
    required double effectQuantity,
    required String sourceLifecycleEvent,
    String? createdAt,
    String? updatedAt,
  }) async {
    final normalizedCategory = _normalizeKategorija(kategorija);
    final normalizedArticleId =
        _normalizeStableArticleId(katalogStableArticleId);
    final now = DateTime.now().toIso8601String();
    final id = await _db.into(_db.stanjeRobePosledice).insert(
          StanjeRobePoslediceCompanion.insert(
            predmetId: predmetId,
            iriuId: iriuId,
            kategorija: normalizedCategory,
            katalogStableArticleId: normalizedArticleId,
            selectedNazivSnapshot: selectedNazivSnapshot,
            selectedIznosSnapshot: Value(selectedIznosSnapshot),
            consequenceType: stanjeRobePosledicaTypeInsufficientStock,
            status: stanjeRobePosledicaStatusUnresolved,
            createdAt: createdAt?.trim().isNotEmpty == true
                ? createdAt!.trim()
                : now,
            updatedAt: updatedAt?.trim().isNotEmpty == true
                ? updatedAt!.trim()
                : now,
            sourceLifecycleEvent: sourceLifecycleEvent.trim().isNotEmpty
                ? sourceLifecycleEvent.trim()
                : stanjeRobePosledicaEventSinglePredmetJsonImport,
            effectQuantity: Value(effectQuantity),
          ),
        );

    return (_db.select(_db.stanjeRobePosledice)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> _terminalizeActiveForIriuRow({
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String status,
    required String resolvedReason,
  }) async {
    final active = await getActiveUnresolvedForIriuRow(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
    );
    if (active == null) return;
    await _writeTerminalStatus(
      id: active.id,
      status: status,
      resolvedReason: resolvedReason,
      now: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _writeTerminalStatus({
    required int id,
    required String status,
    required String resolvedReason,
    required String now,
  }) {
    return (_db.update(_db.stanjeRobePosledice)..where((t) => t.id.equals(id)))
        .write(
      StanjeRobePoslediceCompanion(
        status: Value(status),
        updatedAt: Value(now),
        resolvedAt: Value(now),
        resolvedReason: Value(resolvedReason),
      ),
    );
  }

  String _normalizeKategorija(String kategorija) {
    final normalized = kategorija.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        kategorija,
        'kategorija',
        'kategorija must not be empty.',
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
}
