import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

const String stanjeRobeEffectStatusApplied = 'APPLIED';
const String stanjeRobeEffectStatusRestored = 'RESTORED';
const String stanjeRobeEffectStatusUnresolved = 'UNRESOLVED';
const String stanjeRobeEffectStatusCleared = 'CLEARED';

const Set<String> stanjeRobeCurrentEffectStatuses = {
  stanjeRobeEffectStatusApplied,
  stanjeRobeEffectStatusUnresolved,
};

class StanjeRobeEffectsRepository {
  const StanjeRobeEffectsRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  AppDatabase get db => _db;

  Future<StanjeRobeAppliedEffect?> getById(int id) {
    return (_db.select(_db.stanjeRobeAppliedEffects)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<StanjeRobeAppliedEffect?> getCurrentEffectForSelection({
    required int predmetId,
    required int iriuId,
    required String kategorija,
  }) {
    final normalizedCategory = _normalizeKategorija(kategorija);
    return (_db.select(_db.stanjeRobeAppliedEffects)
          ..where(
            (t) =>
                t.predmetId.equals(predmetId) &
                t.iriuId.equals(iriuId) &
                t.kategorija.equals(normalizedCategory) &
                t.effectStatus.isIn(stanjeRobeCurrentEffectStatuses),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .getSingleOrNull();
  }

  Future<List<StanjeRobeAppliedEffect>> listCurrentEffectsForPredmet(
    int predmetId,
  ) {
    return (_db.select(_db.stanjeRobeAppliedEffects)
          ..where(
            (t) =>
                t.predmetId.equals(predmetId) &
                t.effectStatus.isIn(stanjeRobeCurrentEffectStatuses),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.kategorija),
            (t) => OrderingTerm.asc(t.iriuId),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<int> insertEffect({
    required int predmetId,
    required int? iriuId,
    required String kategorija,
    required String stableArticleId,
    required double effectQuantity,
    required String effectStatus,
    required String effectReason,
  }) {
    final now = DateTime.now().toIso8601String();
    return _db.into(_db.stanjeRobeAppliedEffects).insert(
          StanjeRobeAppliedEffectsCompanion.insert(
            predmetId: predmetId,
            iriuId: Value(iriuId),
            kategorija: _normalizeKategorija(kategorija),
            stableArticleId: _normalizeStableArticleId(stableArticleId),
            effectQuantity: Value(effectQuantity),
            effectStatus: effectStatus,
            effectReason: effectReason,
            datumKreiranja: Value(now),
            datumAzuriranja: Value(now),
          ),
        );
  }

  Future<StanjeRobeAppliedEffect> updateEffectStatus({
    required int effectId,
    required String effectStatus,
    required String effectReason,
  }) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.stanjeRobeAppliedEffects)
          ..where((t) => t.id.equals(effectId)))
        .write(
      StanjeRobeAppliedEffectsCompanion(
        effectStatus: Value(effectStatus),
        effectReason: Value(effectReason),
        datumAzuriranja: Value(now),
      ),
    );

    final updated = await getById(effectId);
    if (updated == null) {
      throw StateError('Applied stock effect not found after update: $effectId');
    }
    return updated;
  }

  Future<bool> hasCurrentEffectForSelection({
    required int predmetId,
    required int iriuId,
    required String kategorija,
  }) async {
    final effect = await getCurrentEffectForSelection(
      predmetId: predmetId,
      iriuId: iriuId,
      kategorija: kategorija,
    );
    return effect != null;
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
