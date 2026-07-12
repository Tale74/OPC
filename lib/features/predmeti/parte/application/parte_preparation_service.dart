import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../data/parte_media_store.dart';
import '../data/parte_preparation_repository.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_models.dart';

class PartePreparationService {
  const PartePreparationService({
    required this.repository,
    required this.mediaStore,
    this.composer = const ParteComposer(),
  });

  final PartePreparationRepository repository;
  final ParteMediaStore mediaStore;
  final ParteComposer composer;

  Future<ParteMediaImportResult> replaceMedia({
    required PartePripremeData preparation,
    required Uint8List sourceBytes,
    required ParteMediaKind kind,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    final previous = kind == ParteMediaKind.photo
        ? preparation.photoMediaKey
        : preparation.customSymbolMediaKey;
    final imported = await mediaStore.importBytes(
      sourceBytes: sourceBytes,
      predmetBroj: preparation.predmetBroj,
      kind: kind,
    );
    try {
      await repository.updateMediaReference(
        preparationId: preparation.id,
        actor: actor,
        entitlement: entitlement,
        setPhoto: kind == ParteMediaKind.photo,
        photoMediaKey: kind == ParteMediaKind.photo ? imported.mediaKey : null,
        setCustomSymbol: kind == ParteMediaKind.customSymbol,
        customSymbolMediaKey: kind == ParteMediaKind.customSymbol
            ? imported.mediaKey
            : null,
        lowResolution: imported.lowResolution,
      );
    } catch (_) {
      await mediaStore.deleteOwned(imported.mediaKey);
      rethrow;
    }
    try {
      await mediaStore.deleteOwned(previous);
    } on ParteMediaException {
      // The new valid reference is already durable. Old unreferenced app-owned
      // media may be retried by orphan cleanup; never roll back to it silently.
    }
    return imported;
  }

  Future<void> removeMedia({
    required PartePripremeData preparation,
    required ParteMediaKind kind,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    final previous = kind == ParteMediaKind.photo
        ? preparation.photoMediaKey
        : preparation.customSymbolMediaKey;
    await repository.updateMediaReference(
      preparationId: preparation.id,
      actor: actor,
      entitlement: entitlement,
      setPhoto: kind == ParteMediaKind.photo,
      photoMediaKey: null,
      setCustomSymbol: kind == ParteMediaKind.customSymbol,
      customSymbolMediaKey: null,
    );
    await mediaStore.deleteOwned(previous);
  }

  Future<ParteRenderPlan> buildPlan({
    required PartePripremeData preparation,
  }) async {
    final draft = ParteDraft.decode(preparation.draftJson);
    final template = repository.templateSnapshot(preparation);
    final photoExists = await mediaStore.exists(preparation.photoMediaKey);
    final customExists = await mediaStore.exists(
      preparation.customSymbolMediaKey,
    );
    var lowResolution = false;
    if (photoExists) {
      final bytes = await mediaStore.read(preparation.photoMediaKey!);
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        lowResolution = true;
      } else {
        final shortEdge = decoded.width < decoded.height
            ? decoded.width
            : decoded.height;
        final longEdge = decoded.width > decoded.height
            ? decoded.width
            : decoded.height;
        lowResolution =
            shortEdge < ParteMediaStore.lowResolutionShortEdge ||
            longEdge < ParteMediaStore.lowResolutionLongEdge;
      }
    }
    final predmet = await repositoryPredmet(preparation.predmetId);
    return composer.compose(
      ParteCompositionInput(
        draft: draft,
        template: template,
        photoMediaKey: photoExists ? preparation.photoMediaKey : null,
        customSymbolMediaKey: customExists
            ? preparation.customSymbolMediaKey
            : null,
        noPhotoAccepted: preparation.noPhotoAccepted,
        noCustomSymbolAccepted: preparation.noCustomSymbolAccepted,
        lowResolutionPhoto: lowResolution,
        lowResolutionAccepted: preparation.lowResolutionAccepted,
        grammarRequiresReview: !{
          'M',
          'Z',
        }.contains(predmet.pol.trim().toUpperCase()),
        grammarVerified: preparation.grammarVerified,
      ),
    );
  }

  Future<PredmetiData> repositoryPredmet(int predmetId) =>
      (repositoryDatabase.select(
        repositoryDatabase.predmeti,
      )..where((row) => row.id.equals(predmetId))).getSingle();

  AppDatabase get repositoryDatabase => repository.db;

  Future<void> completeAndCleanup({
    required PartePripremeData preparation,
    required ParteRenderPlan plan,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
  }) async {
    final pending = await repository.beginCompletion(
      preparationId: preparation.id,
      plan: plan,
      actor: actor,
      entitlement: entitlement,
    );
    await _cleanupPending(pending);
  }

  Future<void> retryCleanup(PartePripremeData preparation) async {
    if (!preparation.cleanupPending) return;
    await _cleanupPending(preparation);
  }

  Future<void> _cleanupPending(PartePripremeData preparation) async {
    await mediaStore.deleteOwned(preparation.photoMediaKey);
    await mediaStore.deleteOwned(preparation.customSymbolMediaKey);
    await repository.finishCleanup(preparation.id);
  }
}
