import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/podsetnik_obligation.dart';
import '../domain/podsetnik_obligation_transfer.dart';

class PodsetnikObligationRepository {
  const PodsetnikObligationRepository(this.db);

  final AppDatabase db;
  static const _deriver = PodsetnikObligationDeriver();

  Future<List<PodsetnikObligation>> currentForPredmet(int predmetId) async {
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final persisted = await (db.select(
      db.podsetnikObaveze,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final unresolvedStock = await _hasUnresolvedStock(predmetId);
    final currentRules = _deriver.deriveRules(
      predmet: predmet,
      iriu: iriu,
      unresolvedStock: unresolvedStock,
    );
    final completion = <String, bool>{};
    for (final row in persisted) {
      final rule = currentRules
          .where((candidate) => candidate.stableRuleId == row.stableRuleId)
          .firstOrNull;
      if (rule == null || row.kind != rule.kind.name) {
        // A rule that disappeared or changed shape must not resurrect an old
        // completion if the source condition later becomes true again.
        if (row.completed || row.completedAt != null) {
          await (db.update(
            db.podsetnikObaveze,
          )..where((candidate) => candidate.id.equals(row.id))).write(
            PodsetnikObavezeCompanion(
              completed: const Value(false),
              completedAt: const Value(null),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
        }
        continue;
      }
      final fingerprint = _deriver.sourceFingerprint(
        rule,
        predmet,
        iriu,
        unresolvedStock,
      );
      if (row.sourceFingerprint == fingerprint) {
        completion[row.stableRuleId] = row.completed;
      }
    }
    return _deriver.project(
      predmet: predmet,
      iriu: iriu,
      completedByRule: completion,
      unresolvedStock: unresolvedStock,
    );
  }

  Future<List<PodsetnikObligation>> reconcileForPredmet(int predmetId) async {
    final obligations = await currentForPredmet(predmetId);
    await db.transaction(() async {
      for (final item in obligations) {
        final existing =
            await (db.select(db.podsetnikObaveze)..where(
                  (row) =>
                      row.predmetId.equals(predmetId) &
                      row.stableRuleId.equals(item.rule.stableRuleId),
                ))
                .getSingleOrNull();
        final preservesCompletion =
            existing != null &&
            existing.kind == item.rule.kind.name &&
            existing.sourceFingerprint == item.sourceFingerprint;
        await db
            .into(db.podsetnikObaveze)
            .insert(
              PodsetnikObavezeCompanion(
                predmetId: Value(predmetId),
                stableRuleId: Value(item.rule.stableRuleId),
                phase: Value(item.rule.phase.name),
                kind: Value(item.rule.kind.name),
                parentRuleId: Value(item.rule.parentRuleId),
                sourceFingerprint: Value(item.sourceFingerprint),
                completed: Value(preservesCompletion && existing.completed),
                completedAt: Value(
                  preservesCompletion ? existing.completedAt : null,
                ),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        if (existing != null) {
          await (db.update(
            db.podsetnikObaveze,
          )..where((row) => row.id.equals(existing.id))).write(
            PodsetnikObavezeCompanion(
              phase: Value(item.rule.phase.name),
              kind: Value(item.rule.kind.name),
              parentRuleId: Value(item.rule.parentRuleId),
              sourceFingerprint: Value(item.sourceFingerprint),
              completed: Value(preservesCompletion && existing.completed),
              completedAt: Value(
                preservesCompletion ? existing.completedAt : null,
              ),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
        }
      }
    });
    return currentForPredmet(predmetId);
  }

  Future<void> setAtomicCompletion({
    required int predmetId,
    required String stableRuleId,
    required bool completed,
  }) async {
    final current = await currentForPredmet(predmetId);
    final item = current
        .where((value) => value.rule.stableRuleId == stableRuleId)
        .firstOrNull;
    if (item == null || !item.isAtomic) {
      throw StateError(
        'Only a current atomic PODSETNIK obligation can be completed.',
      );
    }
    final now = DateTime.now().toIso8601String();
    await db
        .into(db.podsetnikObaveze)
        .insert(
          PodsetnikObavezeCompanion(
            predmetId: Value(predmetId),
            stableRuleId: Value(stableRuleId),
            phase: Value(item.rule.phase.name),
            kind: Value(item.rule.kind.name),
            parentRuleId: Value(item.rule.parentRuleId),
            sourceFingerprint: Value(item.sourceFingerprint),
            completed: Value(completed),
            completedAt: Value(completed ? now : null),
            updatedAt: Value(now),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> setParentCompletion({
    required int predmetId,
    required String parentRuleId,
    required bool completed,
  }) async {
    final current = await currentForPredmet(predmetId);
    final children = current.where(
      (item) => item.rule.parentRuleId == parentRuleId && item.isAtomic,
    );
    if (children.isEmpty) return;
    await db.transaction(() async {
      for (final child in children) {
        await setAtomicCompletion(
          predmetId: predmetId,
          stableRuleId: child.rule.stableRuleId,
          completed: completed,
        );
      }
    });
  }

  Future<List<PodsetnikObligationTransferState>> exportPortableState(
    int predmetId,
  ) async {
    final rows =
        await (db.select(db.podsetnikObaveze)
              ..where((row) => row.predmetId.equals(predmetId))
              ..orderBy([(row) => OrderingTerm.asc(row.stableRuleId)]))
            .get();
    return rows
        .map(
          (row) => PodsetnikObligationTransferState(
            stableRuleId: row.stableRuleId,
            phase: row.phase,
            kind: row.kind,
            parentRuleId: row.parentRuleId,
            sourceFingerprint: row.sourceFingerprint,
            completed: row.completed,
            completedAt: row.completedAt,
          ),
        )
        .toList(growable: false);
  }

  Future<void> importPortableState({
    required int predmetId,
    required List<PodsetnikObligationTransferState> states,
  }) async {
    final current = await currentForPredmet(predmetId);
    final currentIds = current.map((item) => item.rule.stableRuleId).toSet();
    await db.transaction(() async {
      for (final state in states) {
        if (!currentIds.contains(state.stableRuleId)) continue;
        final rule = current
            .firstWhere((item) => item.rule.stableRuleId == state.stableRuleId)
            .rule;
        final fingerprint = _deriver.sourceFingerprint(
          rule,
          (await (db.select(
            db.predmeti,
          )..where((row) => row.id.equals(predmetId))).getSingle()),
          await (db.select(
            db.iriu,
          )..where((row) => row.predmetId.equals(predmetId))).get(),
          await _hasUnresolvedStock(predmetId),
        );
        final fingerprintMatches = state.sourceFingerprint == fingerprint;
        await db
            .into(db.podsetnikObaveze)
            .insert(
              PodsetnikObavezeCompanion(
                predmetId: Value(predmetId),
                stableRuleId: Value(state.stableRuleId),
                phase: Value(rule.phase.name),
                kind: Value(rule.kind.name),
                parentRuleId: Value(rule.parentRuleId),
                sourceFingerprint: Value(fingerprint),
                completed: Value(fingerprintMatches && state.completed),
                completedAt: Value(
                  fingerprintMatches && state.completed
                      ? state.completedAt
                      : null,
                ),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<bool> _hasUnresolvedStock(int predmetId) async {
    final row =
        await (db.select(db.stanjeRobePosledice)
              ..where(
                (item) =>
                    item.predmetId.equals(predmetId) &
                    item.status.equals('UNRESOLVED'),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
