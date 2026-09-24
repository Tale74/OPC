import 'package:drift/drift.dart';

import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/stable_id_generator.dart';
import '../domain/podsetnik_obligation.dart';
import '../domain/podsetnik_obligation_transfer.dart';

class PodsetnikObligationRepository {
  const PodsetnikObligationRepository(this.db);

  final AppDatabase db;
  static const _deriver = PodsetnikObligationDeriver();
  static const _cituljeChildPrefix = 'citulje.occurrence.';

  Future<List<PodsetnikObligation>> currentForPredmet(int predmetId) async {
    await db.backfillMissingIriuPortableOccurrenceIds(predmetId: predmetId);
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final persisted = await (db.select(
      db.podsetnikObaveze,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final manualRows = await _manualRows(predmetId);
    final unresolvedStock = await _hasUnresolvedStock(predmetId);
    final manualRules = _manualRules(manualRows);
    final statusEligible =
        predmet.status.trim().toUpperCase() == 'OTVOREN' ||
        predmet.status.trim().toUpperCase() == 'ZATVOREN';
    final currentRules = _deriver.deriveRules(
      predmet: predmet,
      iriu: iriu,
      unresolvedStock: unresolvedStock,
      additionalRules: statusEligible ? manualRules : const [],
    );
    final completion = <String, bool>{};
    for (final row in persisted) {
      if (row.stableRuleId == cituljeParentRuleId) {
        // ČITULJA parent completion is derived from current children and is
        // not a durable business fact of its own.
        await _deletePersistedRow(row.id);
        continue;
      }
      final rule = currentRules
          .where((candidate) => candidate.stableRuleId == row.stableRuleId)
          .firstOrNull;
      final isCituljeChild = row.stableRuleId.startsWith(_cituljeChildPrefix);
      if (isCituljeChild) {
        final validated = _validatedCituljaRule(
          stableRuleId: row.stableRuleId,
          phase: row.phase,
          kind: row.kind,
          parentRuleId: row.parentRuleId,
          completed: row.completed,
          requireCompleted: false,
          iriu: iriu,
        );
        final expectedFingerprint = validated == null
            ? null
            : _deriver.sourceFingerprint(
                validated,
                predmet,
                iriu,
                unresolvedStock,
              );
        final validFingerprint =
            expectedFingerprint != null &&
            row.sourceFingerprint == expectedFingerprint;
        if (!validFingerprint || (rule == null && !row.completed)) {
          await _deletePersistedRow(row.id);
          continue;
        }
        if (rule != null && row.kind == rule.kind.name) {
          completion[row.stableRuleId] = row.completed;
        }
        // A valid completed child may be temporarily non-current and remains
        // durable, but it is deliberately absent from this current projection.
        continue;
      }
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
      additionalRules: statusEligible ? manualRules : const [],
    );
  }

  /// Reads current manual PODSETNIK rows for a document projection without
  /// reconciling completion state, backfilling identities or writing storage.
  Future<List<PodsetnikObligationRule>> manualRulesForPredmetProjection(
    int predmetId,
  ) async {
    final status =
        await (db.select(db.predmeti)..where((row) => row.id.equals(predmetId)))
            .map((row) => row.status)
            .getSingleOrNull();
    if (status == null ||
        (status.trim().toUpperCase() != 'OTVOREN' &&
            status.trim().toUpperCase() != 'ZATVOREN')) {
      return const <PodsetnikObligationRule>[];
    }
    return List<PodsetnikObligationRule>.unmodifiable(
      _manualRules(await _manualRows(predmetId)),
    );
  }

  /// Reprojects the current PODSETNIK state whenever this PREDMET's owned
  /// completion rows change. The stream is the authoritative completion
  /// boundary; it is not a second REVIEW BAR state or a timer-based poll.
  Stream<List<PodsetnikObligation>> watchCurrentForPredmet(
    int predmetId,
  ) async* {
    final query = db.customSelect(
      'SELECT id FROM predmeti WHERE id = ?',
      variables: [Variable.withInt(predmetId)],
      readsFrom: {
        db.predmeti,
        db.iriu,
        db.stanjeRobePosledice,
        db.podsetnikObaveze,
      },
    );
    await for (final _ in query.watch()) {
      yield await currentForPredmet(predmetId);
    }
  }

  Future<List<PodsetnikObligation>> reconcileForPredmet(int predmetId) async {
    final obligations = await currentForPredmet(predmetId);
    await db.transaction(() async {
      for (final item in obligations) {
        if (item.rule.stableRuleId == cituljeParentRuleId) {
          // The ČITULJA parent is a projection over children, not persisted
          // completion state.
          continue;
        }
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
    await cleanupCituljaStateForPredmet(predmetId);
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final unresolvedStock = await _hasUnresolvedStock(predmetId);
    final rows =
        await (db.select(db.podsetnikObaveze)
              ..where((row) => row.predmetId.equals(predmetId))
              ..orderBy([(row) => OrderingTerm.asc(row.stableRuleId)]))
            .get();
    final manualTextById = {
      for (final row in await _manualRows(predmetId))
        row.stableRuleId: row.text,
    };
    final currentIds = _deriver
        .deriveRules(
          predmet: predmet,
          iriu: iriu,
          unresolvedStock: unresolvedStock,
        )
        .followedBy(_manualRules(await _manualRows(predmetId)))
        .map((rule) => rule.stableRuleId)
        .toSet();
    return rows
        .where((row) {
          if (row.stableRuleId == cituljeParentRuleId) return false;
          if (!row.stableRuleId.startsWith(_cituljeChildPrefix)) return true;
          if (currentIds.contains(row.stableRuleId)) return true;
          final validated = _validatedCituljaRule(
            stableRuleId: row.stableRuleId,
            phase: row.phase,
            kind: row.kind,
            parentRuleId: row.parentRuleId,
            completed: row.completed,
            requireCompleted: true,
            iriu: iriu,
          );
          return validated != null &&
              row.sourceFingerprint ==
                  _deriver.sourceFingerprint(
                    validated,
                    predmet,
                    iriu,
                    unresolvedStock,
                  );
        })
        .map(
          (row) => PodsetnikObligationTransferState(
            stableRuleId: row.stableRuleId,
            phase: row.phase,
            kind: row.kind,
            parentRuleId: row.parentRuleId,
            sourceFingerprint: row.sourceFingerprint,
            completed: row.completed,
            completedAt: row.completedAt,
            obligationText: manualTextById[row.stableRuleId],
          ),
        )
        .toList(growable: false);
  }

  /// Removes only ČITULJA-specific stale state. Generic obligation history is
  /// intentionally outside this cleanup boundary.
  Future<void> cleanupCituljaStateForPredmet(int predmetId) async {
    await db.backfillMissingIriuPortableOccurrenceIds(predmetId: predmetId);
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
    final currentIds = _deriver
        .deriveRules(
          predmet: predmet,
          iriu: iriu,
          unresolvedStock: unresolvedStock,
        )
        .map((rule) => rule.stableRuleId)
        .toSet();
    for (final row in persisted) {
      if (row.stableRuleId == cituljeParentRuleId) {
        await _deletePersistedRow(row.id);
        continue;
      }
      if (!row.stableRuleId.startsWith(_cituljeChildPrefix)) continue;
      final validated = _validatedCituljaRule(
        stableRuleId: row.stableRuleId,
        phase: row.phase,
        kind: row.kind,
        parentRuleId: row.parentRuleId,
        completed: row.completed,
        requireCompleted: false,
        iriu: iriu,
      );
      final expectedFingerprint = validated == null
          ? null
          : _deriver.sourceFingerprint(
              validated,
              predmet,
              iriu,
              unresolvedStock,
            );
      if (expectedFingerprint == null ||
          row.sourceFingerprint != expectedFingerprint ||
          (!currentIds.contains(row.stableRuleId) && !row.completed)) {
        await _deletePersistedRow(row.id);
      }
    }
  }

  Future<void> importPortableState({
    required int predmetId,
    required List<PodsetnikObligationTransferState> states,
  }) async {
    final current = await currentForPredmet(predmetId);
    final currentIds = current.map((item) => item.rule.stableRuleId).toSet();
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    final unresolvedStock = await _hasUnresolvedStock(predmetId);
    await db.transaction(() async {
      for (final state in states) {
        if (state.stableRuleId == cituljeParentRuleId) continue;
        final isCituljeChild = state.stableRuleId.startsWith(
          _cituljeChildPrefix,
        );
        final isManual = isManualObligationRuleId(state.stableRuleId);
        final rule = current
            .where((item) => item.rule.stableRuleId == state.stableRuleId)
            .firstOrNull
            ?.rule;
        if (isCituljeChild &&
            rule != null &&
            _validatedCituljaRule(
                  stableRuleId: state.stableRuleId,
                  phase: state.phase,
                  kind: state.kind,
                  parentRuleId: state.parentRuleId,
                  completed: state.completed,
                  requireCompleted: false,
                  iriu: iriu,
                ) ==
                null) {
          continue;
        }
        final nonCurrentCituljaRule = rule == null
            ? _validatedNonCurrentCituljaRule(state, iriu)
            : null;
        final manualRule = rule == null && isManual
            ? _validatedManualRule(state)
            : null;
        final importRule = rule ?? nonCurrentCituljaRule ?? manualRule;
        // A non-current occurrence is not a current obligation, but a
        // completed concrete ČITULJA child is still PREDMET-owned durable
        // state. Import only the canonical completed child whose occurrence
        // is still attributable to this PREDMET/IRiU data.
        if (importRule == null ||
            (rule == null && !state.completed && !isManual)) {
          continue;
        }
        if (rule != null && !currentIds.contains(state.stableRuleId)) {
          continue;
        }
        final fingerprint = _deriver.sourceFingerprint(
          importRule,
          predmet,
          iriu,
          unresolvedStock,
        );
        final fingerprintMatches = state.sourceFingerprint == fingerprint;
        if (isCituljeChild && !fingerprintMatches) continue;
        if (isManual && (state.obligationText == null || !fingerprintMatches)) {
          continue;
        }
        await db
            .into(db.podsetnikObaveze)
            .insert(
              PodsetnikObavezeCompanion(
                predmetId: Value(predmetId),
                stableRuleId: Value(state.stableRuleId),
                phase: Value(importRule.phase.name),
                kind: Value(importRule.kind.name),
                parentRuleId: Value(importRule.parentRuleId),
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
        if (isManual) {
          await db.customStatement(
            'INSERT OR REPLACE INTO podsetnik_manual_obaveze '
            '(predmet_id, stable_rule_id, obligation_text) VALUES (?, ?, ?)',
            [predmetId, state.stableRuleId, state.obligationText!.trim()],
          );
        }
      }
    });
  }

  PodsetnikObligationRule? _validatedNonCurrentCituljaRule(
    PodsetnikObligationTransferState state,
    List<IriuData> iriu,
  ) {
    return _validatedCituljaRule(
      stableRuleId: state.stableRuleId,
      phase: state.phase,
      kind: state.kind,
      parentRuleId: state.parentRuleId,
      completed: state.completed,
      requireCompleted: true,
      iriu: iriu,
    );
  }

  List<PodsetnikObligationRule> _manualRules(
    List<_ManualObligationRecord> rows,
  ) {
    final valid = rows
        .where((row) => row.text.trim().isNotEmpty)
        .map(
          (row) => PodsetnikObligationRule(
            stableRuleId: row.stableRuleId,
            phase: PodsetnikObligationPhase.preCeremony,
            kind: PodsetnikObligationKind.atomic,
            parentRuleId: posebneObavezeParentRuleId,
            displayLabel: row.text.trim(),
          ),
        )
        .toList(growable: false);
    if (valid.isEmpty) return const [];
    return [
      const PodsetnikObligationRule(
        stableRuleId: posebneObavezeParentRuleId,
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.group,
      ),
      ...valid,
    ];
  }

  PodsetnikObligationRule? _validatedManualRule(
    PodsetnikObligationTransferState state,
  ) {
    final text = state.obligationText?.trim();
    if (!isManualObligationRuleId(state.stableRuleId) ||
        state.phase != PodsetnikObligationPhase.preCeremony.name ||
        state.kind != PodsetnikObligationKind.atomic.name ||
        state.parentRuleId != posebneObavezeParentRuleId ||
        text == null ||
        text.isEmpty) {
      return null;
    }
    return PodsetnikObligationRule(
      stableRuleId: state.stableRuleId,
      phase: PodsetnikObligationPhase.preCeremony,
      kind: PodsetnikObligationKind.atomic,
      parentRuleId: posebneObavezeParentRuleId,
      displayLabel: text,
    );
  }

  Future<String> addManualObligation({
    required int predmetId,
    required String text,
    required String actorRole,
  }) async {
    final normalized = text.trim();
    final role = actorRole.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const FormatException('POSEBNA OBAVEZA mora imati tekst.');
    }
    if (role != 'SAVETNIK' && role != 'ADMINISTRATOR') {
      throw StateError('Korisnik nema pravo da doda POSEBNU OBAVEZU.');
    }
    final id = manualObligationRuleId(generatePodsetnikManualObligationId());
    final now = DateTime.now().toIso8601String();
    final rule = PodsetnikObligationRule(
      stableRuleId: id,
      phase: PodsetnikObligationPhase.preCeremony,
      kind: PodsetnikObligationKind.atomic,
      parentRuleId: posebneObavezeParentRuleId,
      displayLabel: normalized,
    );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await (db.select(
      db.iriu,
    )..where((row) => row.predmetId.equals(predmetId))).get();
    await db
        .into(db.podsetnikObaveze)
        .insert(
          PodsetnikObavezeCompanion(
            predmetId: Value(predmetId),
            stableRuleId: Value(id),
            phase: const Value('preCeremony'),
            kind: const Value('atomic'),
            parentRuleId: const Value(posebneObavezeParentRuleId),
            sourceFingerprint: Value(
              _deriver.sourceFingerprint(rule, predmet, iriu),
            ),
            completed: const Value(false),
            updatedAt: Value(now),
          ),
        );
    await db.customStatement(
      'INSERT INTO podsetnik_manual_obaveze '
      '(predmet_id, stable_rule_id, obligation_text) VALUES (?, ?, ?)',
      [predmetId, id, normalized],
    );
    return id;
  }

  Future<List<_ManualObligationRecord>> _manualRows(int predmetId) async {
    final rows = await db
        .customSelect(
          'SELECT stable_rule_id, obligation_text '
          'FROM podsetnik_manual_obaveze WHERE predmet_id = ? '
          'ORDER BY stable_rule_id',
          variables: [Variable.withInt(predmetId)],
        )
        .get();
    return rows
        .map(
          (row) => _ManualObligationRecord(
            stableRuleId: row.read<String>('stable_rule_id'),
            text: row.read<String>('obligation_text'),
          ),
        )
        .toList(growable: false);
  }

  PodsetnikObligationRule? _validatedCituljaRule({
    required String stableRuleId,
    required String phase,
    required String kind,
    required String? parentRuleId,
    required bool completed,
    required bool requireCompleted,
    required List<IriuData> iriu,
  }) {
    if (!stableRuleId.startsWith(_cituljeChildPrefix) ||
        kind != PodsetnikObligationKind.atomic.name ||
        phase != PodsetnikObligationPhase.preCeremony.name ||
        parentRuleId != cituljeParentRuleId ||
        (requireCompleted && !completed)) {
      return null;
    }
    final portableOccurrenceId = stableRuleId.substring(
      _cituljeChildPrefix.length,
    );
    if (portableOccurrenceId.trim().isEmpty ||
        stableRuleId != cituljeChildRuleId(portableOccurrenceId)) {
      return null;
    }
    final matchingOccurrences = iriu
        .where(
          (row) =>
              (row.interniNaziv == IriuK.cituljaP ||
                  row.interniNaziv == IriuK.cituljaNo) &&
              row.portableOccurrenceId?.trim() == portableOccurrenceId,
        )
        .toList(growable: false);
    if (matchingOccurrences.length != 1) return null;
    return PodsetnikObligationRule(
      stableRuleId: stableRuleId,
      phase: PodsetnikObligationPhase.preCeremony,
      kind: PodsetnikObligationKind.atomic,
      parentRuleId: cituljeParentRuleId,
      portableOccurrenceId: portableOccurrenceId,
    );
  }

  Future<void> _deletePersistedRow(int id) async {
    await (db.delete(
      db.podsetnikObaveze,
    )..where((row) => row.id.equals(id))).go();
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

class _ManualObligationRecord {
  const _ManualObligationRecord({
    required this.stableRuleId,
    required this.text,
  });

  final String stableRuleId;
  final String text;
}
