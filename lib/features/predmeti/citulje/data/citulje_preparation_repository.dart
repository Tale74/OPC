import 'package:drift/drift.dart';

import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../domain/citulje_concrete_format_projection.dart';
import '../domain/citulje_models.dart';
import 'parte_confirmed_text_adapter.dart';

class CituljePreparationRepository {
  const CituljePreparationRepository(this.db);

  final AppDatabase db;

  Future<List<CituljePripremeData>> ensureCurrentForPredmet(
    int predmetId,
  ) async {
    await db.backfillMissingIriuPortableOccurrenceIds(predmetId: predmetId);
    final rows =
        await (db.select(db.iriu)
              ..where(
                (row) =>
                    row.predmetId.equals(predmetId) &
                    (row.interniNaziv.equals(IriuK.cituljaP) |
                        row.interniNaziv.equals(IriuK.cituljaNo)),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.redosled)]))
            .get();
    final now = DateTime.now().toIso8601String();
    for (final row in rows) {
      final occurrence = row.portableOccurrenceId?.trim();
      if (occurrence == null || occurrence.isEmpty) {
        throw StateError('ČITULJE occurrence nema portable identitet.');
      }
      final existing = await findByOccurrence(
        predmetId: predmetId,
        portableOccurrenceId: occurrence,
      );
      if (existing != null) continue;
      await db
          .into(db.cituljePripreme)
          .insert(
            CituljePripremeCompanion.insert(
              predmetId: predmetId,
              portableOccurrenceId: occurrence,
              articleType: row.interniNaziv,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return listCurrentForPredmet(predmetId);
  }

  Future<List<CituljePripremeData>> listCurrentForPredmet(int predmetId) async {
    final current = await ensureCurrentForPredmetWithoutRecursion(predmetId);
    final result = <CituljePripremeData>[];
    for (final row in current) {
      final occurrence = row.portableOccurrenceId?.trim();
      if (occurrence == null || occurrence.isEmpty) continue;
      final preparation = await findByOccurrence(
        predmetId: predmetId,
        portableOccurrenceId: occurrence,
      );
      if (preparation != null && preparation.articleType == row.interniNaziv) {
        result.add(preparation);
      }
    }
    return result;
  }

  Future<IriuData?> findCurrentIriuForPreparation(
    CituljePripremeData preparation,
  ) async {
    final occurrence = preparation.portableOccurrenceId.trim();
    if (occurrence.isEmpty) return null;
    return (db.select(db.iriu)..where(
          (row) =>
              row.predmetId.equals(preparation.predmetId) &
              row.portableOccurrenceId.equals(occurrence) &
              row.interniNaziv.equals(preparation.articleType),
        ))
        .getSingleOrNull();
  }

  Future<String> currentCituljaDisplayValue(
    CituljePripremeData preparation,
  ) async {
    final currentIriu = await findCurrentIriuForPreparation(preparation);
    return resolveCituljeConcreteFormatDisplay(
      articleType: preparation.articleType,
      currentDisplayName: currentIriu?.nazivPrikaz,
    );
  }

  Future<List<IriuData>> ensureCurrentForPredmetWithoutRecursion(
    int predmetId,
  ) =>
      (db.select(db.iriu)
            ..where(
              (row) =>
                  row.predmetId.equals(predmetId) &
                  (row.interniNaziv.equals(IriuK.cituljaP) |
                      row.interniNaziv.equals(IriuK.cituljaNo)),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.redosled)]))
          .get();

  Future<List<CituljePripremeData>> listAllForPredmet(int predmetId) =>
      (db.select(db.cituljePripreme)
            ..where((row) => row.predmetId.equals(predmetId))
            ..orderBy([(row) => OrderingTerm.asc(row.id)]))
          .get();

  Future<CituljePripremeData?> findByOccurrence({
    required int predmetId,
    required String portableOccurrenceId,
  }) =>
      (db.select(db.cituljePripreme)..where(
            (row) =>
                row.predmetId.equals(predmetId) &
                row.portableOccurrenceId.equals(portableOccurrenceId),
          ))
          .getSingleOrNull();

  Future<CituljePripremeData> configure({
    required int preparationId,
    required CituljeParteTextMode mode,
    String? publicationDate,
    String? publicationText,
    String? note,
  }) async {
    final current = await _get(preparationId);
    final hasSnapshot =
        mode == CituljeParteTextMode.da &&
        current.state ==
            CituljePreparationState.parteSnapshotAvailable.dbValue &&
        current.publicationText.trim().isNotEmpty &&
        current.parteSnapshotFingerprint?.trim().isNotEmpty == true;
    final state = mode == CituljeParteTextMode.da
        ? (hasSnapshot
              ? CituljePreparationState.parteSnapshotAvailable
              : CituljePreparationState.waitingForPartePreview)
        : CituljePreparationState.independentText;
    await _update(
      preparationId,
      CituljePripremeCompanion(
        parteTextMode: Value(mode.dbValue),
        publicationDate: Value(publicationDate?.trim()),
        publicationText: hasSnapshot
            ? Value(current.publicationText)
            : Value(publicationText ?? ''),
        note: Value(note ?? current.note),
        state: Value(state.dbValue),
        parteSnapshotFingerprint: hasSnapshot
            ? Value(current.parteSnapshotFingerprint)
            : const Value(null),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return _get(preparationId);
  }

  Future<CituljePripremeData> saveIndependentText({
    required int preparationId,
    required String publicationText,
  }) async {
    final current = await _get(preparationId);
    if (CituljeParteTextMode.fromDb(current.parteTextMode) !=
        CituljeParteTextMode.ne) {
      throw StateError('Nezavisni tekst zahteva PARTE TEKST=NE.');
    }
    await _update(
      preparationId,
      CituljePripremeCompanion(
        publicationText: Value(publicationText),
        state: Value(CituljePreparationState.independentText.dbValue),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return _get(preparationId);
  }

  /// Saves the user-editable publication proposal without changing its
  /// upstream relationship. DA remains a PARTE-backed preparation; only a
  /// later confirmed PARTE capture may replace the proposal from upstream.
  Future<CituljePripremeData> savePublicationText({
    required int preparationId,
    required String publicationText,
  }) async {
    final current = await _get(preparationId);
    final mode = CituljeParteTextMode.fromDb(current.parteTextMode);
    if (mode == null) {
      throw StateError('ČITULJA priprema prvo zahteva PARTE TEKST režim.');
    }
    await _update(
      preparationId,
      CituljePripremeCompanion(
        publicationText: Value(publicationText),
        state: Value(
          mode == CituljeParteTextMode.ne
              ? CituljePreparationState.independentText.dbValue
              : current.state,
        ),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return _get(preparationId);
  }

  /// Applies explicit human corrections without reopening PARTE influence.
  /// Finalization, provenance, state, mode and portable identity are preserved.
  Future<CituljePripremeData> saveHumanCorrections({
    required int preparationId,
    String? publicationDate,
    String? publicationText,
    String? note,
  }) async {
    final updated = await (db.update(db.cituljePripreme)..where(
          (row) => row.id.equals(preparationId) & row.finalized.equals(true),
        ))
        .write(
          CituljePripremeCompanion(
            publicationDate: publicationDate == null
                ? const Value.absent()
                : Value(publicationDate.trim()),
            publicationText: publicationText == null
                ? const Value.absent()
                : Value(publicationText),
            note: note == null ? const Value.absent() : Value(note),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        );
    if (updated == 0) return _get(preparationId);
    return _get(preparationId);
  }

  /// Removes only a finalized preparation row, never its PREDMET/IRiU source.
  Future<bool> removeFinalizedPreparation({required int preparationId}) async {
    final removed = await (db.delete(db.cituljePripreme)..where(
          (row) => row.id.equals(preparationId) & row.finalized.equals(true),
        ))
        .go();
    return removed == 1;
  }

  Future<CituljePripremeData> captureParteSnapshot({
    required int preparationId,
    required ParteConfirmedTextAdapter adapter,
  }) async {
    final current = await _get(preparationId);
    if (CituljeParteTextMode.fromDb(current.parteTextMode) !=
        CituljeParteTextMode.da) {
      throw StateError('PARTE snapshot zahteva PARTE TEKST=DA.');
    }
    final confirmed = await adapter.readForPredmet(current.predmetId);
    if (confirmed == null) {
      return current;
    }
    final updated =
        await (db.update(db.cituljePripreme)..where(
              (row) =>
                  row.id.equals(preparationId) &
                  row.finalized.equals(false) &
                  row.parteTextMode.equals(CituljeParteTextMode.da.dbValue),
            ))
            .write(
              CituljePripremeCompanion(
                publicationText: Value(confirmed.text),
                state: Value(
                  CituljePreparationState.parteSnapshotAvailable.dbValue,
                ),
                parteSnapshotFingerprint: Value(confirmed.sourceFingerprint),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
            );
    if (updated == 0) return _get(preparationId);
    return _get(preparationId);
  }

  Future<CituljePripremeData> finalizePreparation({
    required int preparationId,
    CituljeParteTextMode? mode,
    String? publicationDate,
    String? publicationText,
    String? note,
  }) async {
    final current = await _get(preparationId);
    if (current.finalized) return current;
    final effectiveMode =
        mode ?? CituljeParteTextMode.fromDb(current.parteTextMode);
    final effectiveText = publicationText ?? current.publicationText;
    final effectiveState = switch (effectiveMode) {
      CituljeParteTextMode.da
          when current.state ==
                  CituljePreparationState.parteSnapshotAvailable.dbValue &&
              current.parteSnapshotFingerprint?.trim().isNotEmpty == true =>
        CituljePreparationState.parteSnapshotAvailable,
      CituljeParteTextMode.da => CituljePreparationState.waitingForPartePreview,
      CituljeParteTextMode.ne => CituljePreparationState.independentText,
      null => null,
    };
    final canFinalize =
        effectiveText.trim().isNotEmpty &&
        (effectiveState == CituljePreparationState.parteSnapshotAvailable ||
            effectiveState == CituljePreparationState.independentText);
    if (!canFinalize) {
      throw StateError(
        'ČITULJA priprema ne može da se finalizuje bez pripremljenog teksta.',
      );
    }
    final now = DateTime.now().toIso8601String();
    final updated =
        await (db.update(db.cituljePripreme)..where(
              (row) =>
                  row.id.equals(preparationId) & row.finalized.equals(false),
            ))
            .write(
              CituljePripremeCompanion(
                parteTextMode: mode == null
                    ? const Value.absent()
                    : Value(mode.dbValue),
                publicationDate: publicationDate == null
                    ? const Value.absent()
                    : Value(publicationDate.trim()),
                publicationText: publicationText == null
                    ? const Value.absent()
                    : Value(publicationText),
                note: note == null ? const Value.absent() : Value(note),
                state: mode == null || effectiveState == null
                    ? const Value.absent()
                    : Value(effectiveState.dbValue),
                parteSnapshotFingerprint: mode == CituljeParteTextMode.ne
                    ? const Value(null)
                    : const Value.absent(),
                finalized: const Value(true),
                finalizedAt: Value(now),
                updatedAt: Value(now),
              ),
            );
    if (updated == 0) return _get(preparationId);
    return _get(preparationId);
  }

  CituljePreparationTransfer toTransfer(CituljePripremeData row) =>
      CituljePreparationTransfer(
        portableOccurrenceId: row.portableOccurrenceId,
        articleType: row.articleType,
        parteTextMode: CituljeParteTextMode.fromDb(row.parteTextMode),
        publicationDate: row.publicationDate,
        publicationText: row.publicationText,
        note: row.note,
        state: CituljePreparationState.fromDb(row.state),
        finalized: row.finalized,
        finalizedAt: row.finalizedAt,
        parteSnapshotFingerprint: row.parteSnapshotFingerprint,
      );

  Future<CituljePripremeData> _get(int id) => (db.select(
    db.cituljePripreme,
  )..where((row) => row.id.equals(id))).getSingle();

  Future<void> _update(int id, CituljePripremeCompanion companion) =>
      // Check at the write boundary, not only before asynchronous reads: a
      // finalization that wins the race must also reject an in-flight edit.
      (db.update(db.cituljePripreme)
            ..where((row) => row.id.equals(id) & row.finalized.equals(false)))
          .write(companion);
}
