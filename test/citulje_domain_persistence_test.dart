import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/citulje/data/citulje_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/citulje/data/parte_confirmed_text_adapter.dart';
import 'package:opc_v4/features/predmeti/citulje/domain/citulje_models.dart';
import 'package:opc_v4/features/predmeti/parte/application/parte_preparation_service.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const entitlement = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
  );

  test(
    'current same-type occurrences get distinct persistent preparations',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db, 'CITULJE-DOMAIN-001');
      await _insertIriu(db, predmet.id, 'p-1', 'CITULJA_POLITIKA');
      await _insertIriu(db, predmet.id, 'p-2', 'CITULJA_POLITIKA');
      await _insertIriu(db, predmet.id, 'n-1', 'CITULJA_NOVOSTI');

      final rows = await CituljePreparationRepository(
        db,
      ).ensureCurrentForPredmet(predmet.id);

      expect(
        rows.map((row) => row.portableOccurrenceId),
        containsAll(<String>['p-1', 'p-2', 'n-1']),
      );
      expect(
        rows.map((row) => row.articleType),
        containsAll(<String>['CITULJA_POLITIKA', 'CITULJA_NOVOSTI']),
      );
      expect(rows, hasLength(3));
    },
  );

  test(
    'DA waits for confirmed PARTE and then stores an independent snapshot',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actor = await _insertAdmin(db);
      final predmet = await _insertPredmet(db, 'CITULJE-DOMAIN-002');
      await _insertIriu(db, predmet.id, 'p-1', 'CITULJA_POLITIKA');
      final citulje = CituljePreparationRepository(db);
      final preparation = (await citulje.ensureCurrentForPredmet(
        predmet.id,
      )).single;
      await citulje.configure(
        preparationId: preparation.id,
        mode: CituljeParteTextMode.da,
        publicationDate: '2026-09-05',
        note: 'Napomena',
      );

      final parteRepository = PartePreparationRepository(db);
      await parteRepository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: entitlement,
      );
      final parteService = PartePreparationService(
        repository: parteRepository,
        mediaStore: ParteMediaStore(),
      );
      final adapter = ParteConfirmedTextAdapter(
        repository: parteRepository,
        service: parteService,
      );
      final waiting = await citulje.captureParteSnapshot(
        preparationId: preparation.id,
        adapter: adapter,
      );
      expect(waiting.state, 'WAITING_FOR_PARTE_PREVIEW');
      expect(waiting.publicationText, isEmpty);

      final parte = await parteRepository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: entitlement,
      );
      await parteRepository.updateAcknowledgements(
        preparationId: parte.id,
        actor: actor,
        entitlement: entitlement,
        noPhotoAccepted: true,
        noCustomSymbolAccepted: true,
        grammarVerified: true,
      );
      final currentParte = await parteRepository.findForPredmet(predmet.id);
      final plan = await parteService.buildPlan(preparation: currentParte!);
      expect(plan.blockers, isEmpty, reason: plan.blockers.join(' | '));
      await parteRepository.confirmPreview(
        preparationId: parte.id,
        plan: plan,
        actor: actor,
        entitlement: entitlement,
      );
      final captured = await citulje.captureParteSnapshot(
        preparationId: preparation.id,
        adapter: adapter,
      );
      expect(captured.state, 'PARTE_SNAPSHOT_AVAILABLE');
      expect(captured.publicationText, isNotEmpty);
      expect(captured.parteSnapshotFingerprint, plan.fingerprint);

      final storedText = captured.publicationText;
      final parteBeforeCituljeEdit = (await parteRepository.findForPredmet(
        predmet.id,
      ))!.draftJson;
      final editedProposal = await citulje.savePublicationText(
        preparationId: preparation.id,
        publicationText: 'ČITULJE uređeni predlog',
      );
      expect(editedProposal.publicationText, 'ČITULJE uređeni predlog');
      expect(
        (await parteRepository.findForPredmet(predmet.id))!.draftJson,
        parteBeforeCituljeEdit,
      );
      final firstDraft = ParteDraft.decode(
        (await parteRepository.findForPredmet(predmet.id))!.draftJson,
      );
      final unconfirmedDraft = firstDraft.copyWith(
        textByBlock: {...firstDraft.textByBlock, 'name': 'Nacrt bez potvrde'},
      );
      await parteRepository.updateDraft(
        preparationId: parte.id,
        draft: unconfirmedDraft,
        actor: actor,
        entitlement: entitlement,
      );
      final unchanged = await citulje.captureParteSnapshot(
        preparationId: preparation.id,
        adapter: adapter,
      );
      expect(unchanged.publicationText, 'ČITULJE uređeni predlog');
      expect(unchanged.publicationText, isNot(storedText));
      expect(
        unchanged.parteSnapshotFingerprint,
        captured.parteSnapshotFingerprint,
      );

      final iterationParte = await parteRepository.findForPredmet(predmet.id);
      final iterationPlan = await parteService.buildPlan(
        preparation: iterationParte!,
      );
      expect(iterationPlan.blockers, isEmpty);
      await parteRepository.confirmPreview(
        preparationId: parte.id,
        plan: iterationPlan,
        actor: actor,
        entitlement: entitlement,
      );
      final refreshed = await citulje.captureParteSnapshot(
        preparationId: preparation.id,
        adapter: adapter,
      );
      expect(refreshed.publicationText, isNot(storedText));
      expect(refreshed.publicationText, isNot(unchanged.publicationText));
      expect(refreshed.parteSnapshotFingerprint, iterationPlan.fingerprint);

      final finalized = await citulje.finalizePreparation(
        preparationId: preparation.id,
      );
      expect(finalized.finalized, isTrue);
      expect(finalized.finalizedAt, isNot(equals(null)));
      final parteBeforeFinalizedRefresh = await parteRepository.findForPredmet(
        predmet.id,
      );
      final finalDraft = ParteDraft.decode(
        parteBeforeFinalizedRefresh!.draftJson,
      );
      await parteRepository.updateDraft(
        preparationId: parte.id,
        draft: finalDraft.copyWith(
          textByBlock: {
            ...finalDraft.textByBlock,
            'name': 'Posle finalizacije',
          },
        ),
        actor: actor,
        entitlement: entitlement,
      );
      final finalParte = await parteRepository.findForPredmet(predmet.id);
      final finalPlan = await parteService.buildPlan(preparation: finalParte!);
      await parteRepository.confirmPreview(
        preparationId: parte.id,
        plan: finalPlan,
        actor: actor,
        entitlement: entitlement,
      );
      final frozen = await citulje.captureParteSnapshot(
        preparationId: preparation.id,
        adapter: adapter,
      );
      expect(frozen.finalized, isTrue);
      expect(frozen.publicationText, refreshed.publicationText);
      expect(
        frozen.parteSnapshotFingerprint,
        refreshed.parteSnapshotFingerprint,
      );
      final frozenAfterManualEdit = await citulje.savePublicationText(
        preparationId: preparation.id,
        publicationText: 'Ne sme da promeni finalizovano',
      );
      expect(frozenAfterManualEdit, frozen);

      final reloaded = await citulje.findByOccurrence(
        predmetId: predmet.id,
        portableOccurrenceId: 'p-1',
      );
      expect(reloaded!.finalized, isTrue);
      expect(reloaded.publicationText, refreshed.publicationText);

      final target = createTestDatabase();
      addTearDown(target.close);
      final targetActor = await _insertAdmin(target);
      final transferred =
          jsonDecode(
                await serializePredmetJsonForTest(
                  db: db,
                  predmetId: predmet.id,
                ),
              )
              as Map<String, dynamic>;
      await importPredmetJsonMapForTest(
        db: target,
        json: transferred,
        localActorKorisnikId: targetActor.id,
      );
      final transferredCitulja = await target
          .select(target.cituljePripreme)
          .getSingle();
      expect(transferredCitulja.state, 'PARTE_SNAPSHOT_AVAILABLE');
      expect(transferredCitulja.publicationText, refreshed.publicationText);
      expect(
        transferredCitulja.parteSnapshotFingerprint,
        refreshed.parteSnapshotFingerprint,
      );

      final afterParteEdit = await citulje.findByOccurrence(
        predmetId: predmet.id,
        portableOccurrenceId: 'p-1',
      );
      expect(afterParteEdit!.publicationText, refreshed.publicationText);
      expect(afterParteEdit.state, 'PARTE_SNAPSHOT_AVAILABLE');
      expect(afterParteEdit.finalized, isTrue);

      final transferredFinalized = await target
          .select(target.cituljePripreme)
          .getSingle();
      expect(transferredFinalized.finalized, isTrue);
      expect(transferredFinalized.finalizedAt, isNot(equals(null)));
    },
  );

  test(
    'NE persists independent text and transfers through PREDMET JSON',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final sourcePredmet = await _insertPredmet(
        source,
        'CITULJE-TRANSFER-001',
      );
      await _insertIriu(source, sourcePredmet.id, 'same-1', 'CITULJA_POLITIKA');
      await _insertIriu(source, sourcePredmet.id, 'same-2', 'CITULJA_POLITIKA');
      final sourceRepo = CituljePreparationRepository(source);
      final sourceRows = await sourceRepo.ensureCurrentForPredmet(
        sourcePredmet.id,
      );
      for (final row in sourceRows) {
        await sourceRepo.configure(
          preparationId: row.id,
          mode: CituljeParteTextMode.ne,
          publicationDate: '2026-10-01',
          publicationText: 'Tekst ${row.portableOccurrenceId}',
          note: 'Beleška ${row.portableOccurrenceId}',
        );
      }
      final json =
          jsonDecode(
                await serializePredmetJsonForTest(
                  db: source,
                  predmetId: sourcePredmet.id,
                ),
              )
              as Map<String, dynamic>;
      expect(json['cituljePripreme'], hasLength(2));

      final targetActor = await _insertAdmin(target);
      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: targetActor.id,
      );
      final imported = await target.select(target.cituljePripreme).get();
      expect(
        imported.map((row) => row.portableOccurrenceId),
        containsAll(<String>['same-1', 'same-2']),
      );
      expect(imported.every((row) => row.state == 'INDEPENDENT_TEXT'), isTrue);
      expect(imported.every((row) => !row.finalized), isTrue);
      expect(
        imported.map((row) => row.publicationText),
        containsAll(<String>['Tekst same-1', 'Tekst same-2']),
      );
    },
  );

  test(
    'backup round trip preserves ČITULJE state and legacy backup stays valid',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      final legacyTarget = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      addTearDown(legacyTarget.close);
      final sourcePredmet = await _insertPredmet(source, 'CITULJE-BACKUP-001');
      await _insertIriu(
        source,
        sourcePredmet.id,
        'backup-1',
        'CITULJA_NOVOSTI',
      );
      final repo = CituljePreparationRepository(source);
      final row = (await repo.ensureCurrentForPredmet(sourcePredmet.id)).single;
      await repo.configure(
        preparationId: row.id,
        mode: CituljeParteTextMode.ne,
        publicationDate: '2026-11-02',
        publicationText: 'Backup tekst',
        note: 'Backup napomena',
      );
      await repo.finalizePreparation(preparationId: row.id);
      final backup =
          jsonDecode(await serializeBackupJsonForTest(db: source))
              as Map<String, dynamic>;
      expect(backup['cituljePripreme'], hasLength(1));
      await importBackupJsonMapForTest(db: target, json: backup);
      final restored = await target.select(target.cituljePripreme).getSingle();
      expect(restored.portableOccurrenceId, 'backup-1');
      expect(restored.publicationText, 'Backup tekst');
      expect(restored.note, 'Backup napomena');
      expect(restored.finalized, isTrue);
      expect(restored.finalizedAt, isNot(equals(null)));

      final legacy = Map<String, dynamic>.from(backup)
        ..remove('cituljePripreme');
      await importBackupJsonMapForTest(db: legacyTarget, json: legacy);
      expect(
        await legacyTarget.select(legacyTarget.cituljePripreme).get(),
        isEmpty,
      );
    },
  );

  test('finalization wins over an in-flight PARTE capture', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db, 'CITULJE-RACE-001');
    await _insertIriu(db, predmet.id, 'race-1', 'CITULJA_POLITIKA');
    final citulje = CituljePreparationRepository(db);
    final preparation = (await citulje.ensureCurrentForPredmet(
      predmet.id,
    )).single;
    await citulje.configure(
      preparationId: preparation.id,
      mode: CituljeParteTextMode.da,
    );
    await (db.update(
      db.cituljePripreme,
    )..where((row) => row.id.equals(preparation.id))).write(
      const CituljePripremeCompanion(
        publicationText: Value('Prethodni potvrđeni tekst'),
        state: Value('PARTE_SNAPSHOT_AVAILABLE'),
        parteSnapshotFingerprint: Value('prior-fingerprint'),
      ),
    );
    final actor = await _insertAdmin(db);
    final parteRepository = PartePreparationRepository(db);
    await parteRepository.initializeOrResume(
      predmetId: predmet.id,
      actor: actor,
      entitlement: entitlement,
    );
    final parteService = PartePreparationService(
      repository: parteRepository,
      mediaStore: ParteMediaStore(),
    );
    final gate = Completer<void>();
    final adapter = _BlockingParteAdapter(
      repository: parteRepository,
      service: parteService,
      gate: gate,
      result: const ParteConfirmedPlainText(
        text: 'Ne sme da prepiše finalizovanu pripremu',
        sourceFingerprint: 'race-fingerprint',
      ),
    );
    final capture = citulje.captureParteSnapshot(
      preparationId: preparation.id,
      adapter: adapter,
    );
    await Future<void>.delayed(Duration.zero);
    await citulje.finalizePreparation(preparationId: preparation.id);
    gate.complete();
    final result = await capture;
    expect(result.finalized, isTrue);
    expect(result.publicationText, 'Prethodni potvrđeni tekst');
    expect(result.parteSnapshotFingerprint, 'prior-fingerprint');
    expect(
      (await parteRepository.findForPredmet(predmet.id))!.draftJson,
      isNotEmpty,
    );
  });

  test('a concurrent DA to NE edit cannot accept a stale DA capture', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db, 'CITULJE-MODE-RACE');
    await _insertIriu(db, predmet.id, 'mode-race', 'CITULJA_POLITIKA');
    final citulje = CituljePreparationRepository(db);
    final preparation =
        (await citulje.ensureCurrentForPredmet(predmet.id)).single;
    await citulje.configure(
      preparationId: preparation.id,
      mode: CituljeParteTextMode.da,
    );
    final gate = Completer<void>();
    final parteRepository = PartePreparationRepository(db);
    final adapter = _BlockingParteAdapter(
      repository: parteRepository,
      service: PartePreparationService(
        repository: parteRepository,
        mediaStore: ParteMediaStore(),
      ),
      gate: gate,
      result: const ParteConfirmedPlainText(
        text: 'Stari DA snapshot ne sme da prođe',
        sourceFingerprint: 'stale-da',
      ),
    );
    final capture = citulje.captureParteSnapshot(
      preparationId: preparation.id,
      adapter: adapter,
    );
    await Future<void>.delayed(Duration.zero);
    final independent = await citulje.configure(
      preparationId: preparation.id,
      mode: CituljeParteTextMode.ne,
      publicationText: 'Trenutni nezavisni tekst',
    );
    gate.complete();
    final result = await capture;
    expect(result, independent);
    expect(result.parteTextMode, CituljeParteTextMode.ne.dbValue);
    expect(result.publicationText, 'Trenutni nezavisni tekst');
    expect(result.parteSnapshotFingerprint, isNull);
  });
}

class _BlockingParteAdapter extends ParteConfirmedTextAdapter {
  _BlockingParteAdapter({
    required super.repository,
    required super.service,
    required this.gate,
    required this.result,
  });

  final Completer<void> gate;
  final ParteConfirmedPlainText result;

  @override
  Future<ParteConfirmedPlainText?> readForPredmet(int predmetId) async {
    await gate.future;
    return result;
  }
}

Future<KorisniciData> _insertAdmin(AppDatabase db) async {
  final id = await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'R2 administrator',
          uloga: 'ADMINISTRATOR',
          pinHash: 'r2-hash',
          datumKreiranja: '2026-09-05T10:00:00.000',
        ),
      );
  return (db.select(
    db.korisnici,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<PredmetiData> _insertPredmet(AppDatabase db, String broj) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-09-05T10:00:00.000'),
          ime: const Value('R2'),
          prezime: const Value('Test'),
          pol: const Value('M'),
          partePotrebna: const Value(true),
          simbol: const Value('BEZ_SIMBOLA'),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<void> _insertIriu(
  AppDatabase db,
  int predmetId,
  String portableOccurrenceId,
  String articleType,
) async {
  await db
      .into(db.iriu)
      .insert(
        IriuCompanion.insert(
          predmetId: predmetId,
          portableOccurrenceId: Value(portableOccurrenceId),
          interniNaziv: articleType,
          nazivPrikaz: Value(articleType),
          redosled: Value(portableOccurrenceId.hashCode.abs()),
        ),
      );
}
