import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../application/parte_authorization.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_initial_composer.dart';
import '../domain/parte_models.dart';
import 'parte_template_repository.dart';

class PartePreparationRepository {
  const PartePreparationRepository(
    this._db, {
    this.authorization = const ParteAuthorization(),
    this.initialComposer = const ParteInitialComposer(),
  });

  final AppDatabase _db;
  final ParteAuthorization authorization;
  final ParteInitialComposer initialComposer;

  AppDatabase get db => _db;

  Future<PartePripremeData?> findForPredmet(int predmetId) => (_db.select(
    _db.partePripreme,
  )..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();

  Future<PartePripremeData> initializeOrResume({
    required int predmetId,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    final predmet = await (_db.select(
      _db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    if (!predmet.partePotrebna) {
      throw StateError('PARTE nisu označene kao potrebne u PREDMETU.');
    }
    final existing = await findForPredmet(predmetId);
    if (existing != null) return existing;

    final templateResolution = await ParteTemplateRepository(
      _db,
    ).resolveActiveTemplate();
    final template = templateResolution.template;
    final initial = initialComposer.compose(
      predmet: predmet,
      template: template,
    );
    final now = DateTime.now().toIso8601String();
    try {
      final id = await _db
          .into(_db.partePripreme)
          .insert(
            PartePripremeCompanion.insert(
              predmetId: predmet.id,
              predmetBroj: predmet.brojPredmeta,
              createdAt: now,
              updatedAt: now,
              sourceFingerprint: initial.sourceFingerprint,
              templateId: template.id,
              templateSnapshotJson: jsonEncode(template.toJson()),
              draftJson: initial.draft.encode(),
              grammarVerified: Value(!initial.grammarRequiresReview),
            ),
          );
      return (_db.select(
        _db.partePripreme,
      )..where((row) => row.id.equals(id))).getSingle();
    } catch (_) {
      final concurrent = await findForPredmet(predmetId);
      if (concurrent != null) return concurrent;
      rethrow;
    }
  }

  Future<void> updateDraft({
    required int preparationId,
    required ParteDraft draft,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    final current = await _requireEditable(preparationId);
    if (current.draftJson == draft.encode()) return;
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        draftJson: Value(draft.encode()),
        updatedAt: Value(DateTime.now().toIso8601String()),
        previewConfirmedFingerprint: const Value(null),
        exportedRenderFingerprint: const Value(null),
        exportedFilename: const Value(null),
        exportedLocation: const Value(null),
        exportedSuccessfully: const Value(false),
      ),
    );
  }

  Future<void> updateMediaReference({
    required int preparationId,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
    String? photoMediaKey,
    bool setPhoto = false,
    String? customSymbolMediaKey,
    bool setCustomSymbol = false,
    bool lowResolution = false,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    await _requireEditable(preparationId);
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        photoMediaKey: setPhoto ? Value(photoMediaKey) : const Value.absent(),
        customSymbolMediaKey: setCustomSymbol
            ? Value(customSymbolMediaKey)
            : const Value.absent(),
        noPhotoAccepted: setPhoto ? const Value(false) : const Value.absent(),
        noCustomSymbolAccepted: setCustomSymbol
            ? const Value(false)
            : const Value.absent(),
        lowResolutionAccepted: setPhoto
            ? Value(!lowResolution)
            : const Value.absent(),
        previewConfirmedFingerprint: const Value(null),
        exportedRenderFingerprint: const Value(null),
        exportedFilename: const Value(null),
        exportedLocation: const Value(null),
        exportedSuccessfully: const Value(false),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> updateAcknowledgements({
    required int preparationId,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
    bool? noPhotoAccepted,
    bool? noCustomSymbolAccepted,
    bool? lowResolutionAccepted,
    bool? grammarVerified,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    await _requireEditable(preparationId);
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        noPhotoAccepted: noPhotoAccepted == null
            ? const Value.absent()
            : Value(noPhotoAccepted),
        noCustomSymbolAccepted: noCustomSymbolAccepted == null
            ? const Value.absent()
            : Value(noCustomSymbolAccepted),
        lowResolutionAccepted: lowResolutionAccepted == null
            ? const Value.absent()
            : Value(lowResolutionAccepted),
        grammarVerified: grammarVerified == null
            ? const Value.absent()
            : Value(grammarVerified),
        previewConfirmedFingerprint: const Value(null),
        exportedRenderFingerprint: const Value(null),
        exportedSuccessfully: const Value(false),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> confirmPreview({
    required int preparationId,
    required ParteRenderPlan plan,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    await _requireEditable(preparationId);
    if (!plan.canConfirmPreview) {
      throw StateError('Finalni preview ima nerešene blokere.');
    }
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        previewConfirmedFingerprint: Value(plan.fingerprint),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> recordSuccessfulExport({
    required int preparationId,
    required ParteRenderPlan plan,
    required String filename,
    required String location,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    final current = await _requireEditable(preparationId);
    if (!plan.canGeneratePdf ||
        current.previewConfirmedFingerprint != plan.fingerprint) {
      throw StateError('PDF zahteva potvrđen aktuelni finalni preview.');
    }
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        exportedRenderFingerprint: Value(plan.fingerprint),
        exportedFilename: Value(filename),
        exportedLocation: Value(location),
        exportedSuccessfully: const Value(true),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<PartePripremeData> beginCompletion({
    required int preparationId,
    required ParteRenderPlan plan,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    final current = await _requireEditable(preparationId);
    if (!current.exportedSuccessfully ||
        current.exportedRenderFingerprint != plan.fingerprint ||
        current.previewConfirmedFingerprint != plan.fingerprint ||
        current.exportedFilename?.trim().isEmpty != false ||
        current.exportedLocation?.trim().isEmpty != false) {
      throw StateError(
        'PRIPREMA ZAVRŠENA zahteva uspešan aktuelni KORICE izvoz.',
      );
    }
    final now = DateTime.now().toIso8601String();
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        status: Value(PartePreparationStatus.cleanupPending.dbValue),
        cleanupPending: const Value(true),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return (_db.select(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).getSingle();
  }

  Future<void> finishCleanup(int preparationId) async {
    final current = await (_db.select(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).getSingle();
    if (PartePreparationStatus.fromDb(current.status) ==
        PartePreparationStatus.inProgress) {
      throw StateError('Aktivna priprema ne sme biti očišćena.');
    }
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        status: Value(PartePreparationStatus.completed.dbValue),
        cleanupPending: const Value(false),
        photoMediaKey: const Value(null),
        customSymbolMediaKey: const Value(null),
        draftJson: const Value('{}'),
        templateSnapshotJson: const Value('{}'),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<bool> blocksPredmetCompletion(int predmetId) async {
    final row = await findForPredmet(predmetId);
    return row != null &&
        PartePreparationStatus.fromDb(row.status) ==
            PartePreparationStatus.inProgress;
  }

  Future<bool> sourceChanged(int preparationId) async {
    final preparation = await (_db.select(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).getSingle();
    final predmet = await (_db.select(
      _db.predmeti,
    )..where((row) => row.id.equals(preparation.predmetId))).getSingle();
    final active = initialComposer.compose(
      predmet: predmet,
      template: _templateFromSnapshot(preparation.templateSnapshotJson),
    );
    return active.sourceFingerprint != preparation.sourceFingerprint;
  }

  Future<PartePripremeData> rebuildFromPredmet({
    required int preparationId,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    authorization.requirePreparationAccess(
      user: actor,
      entitlement: entitlement,
    );
    final current = await _requireEditable(preparationId);
    final predmet = await (_db.select(
      _db.predmeti,
    )..where((row) => row.id.equals(current.predmetId))).getSingle();
    final template = _templateFromSnapshot(current.templateSnapshotJson);
    final rebuilt = initialComposer.compose(
      predmet: predmet,
      template: template,
    );
    await (_db.update(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).write(
      PartePripremeCompanion(
        sourceFingerprint: Value(rebuilt.sourceFingerprint),
        draftJson: Value(rebuilt.draft.encode()),
        grammarVerified: Value(!rebuilt.grammarRequiresReview),
        previewConfirmedFingerprint: const Value(null),
        exportedRenderFingerprint: const Value(null),
        exportedFilename: const Value(null),
        exportedLocation: const Value(null),
        exportedSuccessfully: const Value(false),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return (_db.select(
      _db.partePripreme,
    )..where((row) => row.id.equals(preparationId))).getSingle();
  }

  ParteTemplate templateSnapshot(PartePripremeData preparation) =>
      _templateFromSnapshot(preparation.templateSnapshotJson);

  ParteTemplate _templateFromSnapshot(String source) => ParteTemplate.fromJson(
    (jsonDecode(source) as Map).cast<String, dynamic>(),
  );

  Future<PartePripremeData> _requireEditable(int id) async {
    final row = await (_db.select(
      _db.partePripreme,
    )..where((item) => item.id.equals(id))).getSingle();
    if (PartePreparationStatus.fromDb(row.status) !=
        PartePreparationStatus.inProgress) {
      throw StateError('Završena PARTE priprema nije editabilna.');
    }
    return row;
  }
}
