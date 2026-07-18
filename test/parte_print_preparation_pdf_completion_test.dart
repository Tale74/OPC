import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/utils/export_utils.dart';
import 'package:opc_v4/features/predmeti/parte/application/parte_preparation_service.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';
import 'package:opc_v4/features/predmeti/parte/docx/parte_docx_exporter.dart';
import 'package:opc_v4/features/predmeti/parte/pdf/parte_pdf_renderer.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const potpun = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
  );

  test(
    'shared render plan produces standalone PDF with custom dimensions',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.dispose);
      await fixture.repository.updateAcknowledgements(
        preparationId: fixture.preparation.id,
        actor: fixture.actor,
        entitlement: potpun,
        noPhotoAccepted: true,
      );
      final preparation = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      final plan = await fixture.service.buildPlan(preparation: preparation);

      expect(plan.widthMm, 224);
      expect(plan.heightMm, 170);
      expect(plan.marginMm, 5);
      expect(plan.horizontalMarginMm, 5);
      expect(plan.verticalMarginMm, 5);
      expect(plan.canGeneratePdf, isTrue);
      final bytes = await PartePdfRenderer(
        mediaStore: fixture.mediaStore,
      ).build(plan: plan);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(1000));
    },
  );

  test(
    'filename uses existing helper, PREDMET number, PARTA and version',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.dispose);
      final filename = koricePdfDerivatFajlNaziv(
        fixture.predmet,
        'PARTA',
        includePredmetVersion: true,
      );
      expect(filename, contains('PARTE-PDF-001'));
      expect(filename, contains('PARTA'));
      expect(filename, endsWith('_v1.pdf'));
      expect(filename, isNot(contains('parteIme')));
    },
  );

  test(
    'DOCX is a valid local OOXML derivative and does not mark export',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.dispose);
      await fixture.service.replaceMedia(
        preparation: fixture.preparation,
        sourceBytes: Uint8List.fromList(
          img.encodePng(img.Image(width: 900, height: 1200)),
        ),
        kind: ParteMediaKind.photo,
        actor: fixture.actor,
        entitlement: potpun,
      );
      final before = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      final plan = await fixture.service.buildPlan(preparation: before);
      final bytes = await ParteDocxExporter(
        mediaStore: fixture.mediaStore,
      ).build(plan: plan);
      final smokeOutput = Platform.environment['OPC_PARTE_WORD_SMOKE_OUTPUT'];
      if (smokeOutput != null && smokeOutput.isNotEmpty) {
        await File(smokeOutput).writeAsBytes(bytes, flush: true);
      }
      final archive = ZipDecoder().decodeBytes(bytes);
      final names = archive.files.map((file) => file.name).toSet();

      expect(names, contains('[Content_Types].xml'));
      expect(names, contains('word/document.xml'));
      expect(names, contains('word/styles.xml'));
      expect(
        names.where((name) => name.startsWith('word/media/')),
        hasLength(2),
      );
      final document = utf8.decode(
        archive.findFile('word/document.xml')!.content as List<int>,
      );
      expect(document, contains('Sintetičko Lice'));
      expect(document, contains('w:orient="landscape"'));
      expect(document, contains('w:txbxContent'));
      expect(document, contains('wp:anchor'));
      expect(document, contains('behindDoc="1"'));
      expect(document, isNot(contains('behindDoc="0"')));
      expect(document, contains('<v:rect'));
      expect(document, isNot(contains('type="#_x0000_t202"')));
      expect(
        document.indexOf('<wp:wrapNone/>'),
        lessThan(document.indexOf('<wp:docPr')),
      );
      expect(document, contains('<wp:cNvGraphicFramePr/>'));
      expect(
        document,
        contains('<w:pgMar w:top="0" w:right="0" w:bottom="0" w:left="0"'),
      );
      expect(document, contains('parte_mournersHeading'));
      expect(document, contains('Sintetičko Lice'));
      expect(document, isNot(contains('—')));
      expect(document, contains('Ožalošćeni'));
      expect(
        RegExp('w:txbxContent').allMatches(document).length,
        greaterThanOrEqualTo(5),
      );
      final after = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      expect(after.exportedSuccessfully, isFalse);
    },
  );

  test('calibration PDF is a standalone exact-page diagnostic', () async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    await fixture.repository.updateAcknowledgements(
      preparationId: fixture.preparation.id,
      actor: fixture.actor,
      entitlement: potpun,
      noPhotoAccepted: true,
    );
    final preparation = (await fixture.repository.findForPredmet(
      fixture.predmet.id,
    ))!;
    final plan = await fixture.service.buildPlan(preparation: preparation);
    final bytes = await PartePdfRenderer(
      mediaStore: fixture.mediaStore,
    ).buildCalibration(plan: plan);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });

  test(
    'reset deletes only app-owned media and starts a fresh preparation',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.dispose);
      final imported = await fixture.service.replaceMedia(
        preparation: fixture.preparation,
        sourceBytes: Uint8List.fromList(
          img.encodePng(img.Image(width: 900, height: 1200)),
        ),
        kind: ParteMediaKind.photo,
        actor: fixture.actor,
        entitlement: potpun,
      );
      final current = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      final fresh = await fixture.service.resetAndStartAgain(
        preparation: current,
        actor: fixture.actor,
        entitlement: potpun,
      );

      expect(fresh.id, isNot(current.id));
      expect(fresh.photoMediaKey, isNull);
      expect(await fixture.mediaStore.exists(imported.mediaKey), isFalse);
      expect(fresh.predmetId, fixture.predmet.id);
    },
  );

  test(
    'explicit completion retains editable preparation and owned media',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.dispose);
      final external = File(
        '${fixture.root.path}${Platform.pathSeparator}external-original.png',
      );
      final originalBytes = Uint8List.fromList(
        img.encodePng(img.Image(width: 900, height: 1200)),
      );
      await external.writeAsBytes(originalBytes);
      final imported = await fixture.service.replaceMedia(
        preparation: fixture.preparation,
        sourceBytes: await external.readAsBytes(),
        kind: ParteMediaKind.photo,
        actor: fixture.actor,
        entitlement: potpun,
      );
      var preparation = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      final plan = await fixture.service.buildPlan(preparation: preparation);
      await fixture.repository.confirmPreview(
        preparationId: preparation.id,
        plan: plan,
        actor: fixture.actor,
        entitlement: potpun,
      );
      await fixture.repository.recordSuccessfulExport(
        preparationId: preparation.id,
        plan: plan,
        filename: 'SYNTHETIC_PARTA_v1.pdf',
        location: 'KORICE/SYNTHETIC_PARTA_v1.pdf',
        actor: fixture.actor,
        entitlement: potpun,
      );
      preparation = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;

      expect(preparation.status, PartePreparationStatus.inProgress.dbValue);
      expect(
        await fixture.repository.blocksPredmetCompletion(fixture.predmet.id),
        isTrue,
      );
      expect(await fixture.mediaStore.exists(imported.mediaKey), isTrue);

      await fixture.service.completeAndCleanup(
        preparation: preparation,
        plan: plan,
        actor: fixture.actor,
        entitlement: potpun,
      );
      final completed = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      expect(completed.status, PartePreparationStatus.completed.dbValue);
      expect(completed.exportedFilename, 'SYNTHETIC_PARTA_v1.pdf');
      expect(completed.draftJson, contains('textByBlock'));
      expect(await fixture.mediaStore.exists(imported.mediaKey), isTrue);
      expect(await external.exists(), isTrue);
      expect(await external.readAsBytes(), orderedEquals(originalBytes));
      expect(
        await fixture.repository.blocksPredmetCompletion(fixture.predmet.id),
        isFalse,
      );
      final retainedDraft = ParteDraft.decode(completed.draftJson);
      await fixture.repository.updateDraft(
        preparationId: completed.id,
        draft: retainedDraft.copyWith(
          textByBlock: <String, String>{
            ...retainedDraft.textByBlock,
            'mourners': 'Izmenjeni sintetički tekst',
          },
        ),
        actor: fixture.actor,
        entitlement: potpun,
      );
      final edited = (await fixture.repository.findForPredmet(
        fixture.predmet.id,
      ))!;
      expect(edited.status, PartePreparationStatus.completed.dbValue);
      expect(edited.previewConfirmedFingerprint, isNull);
      expect(edited.exportedSuccessfully, isFalse);

      await fixture.service.deleteRetainedCompleted(
        preparation: edited,
        actor: fixture.actor,
        entitlement: potpun,
      );
      expect(
        await fixture.repository.findForPredmet(fixture.predmet.id),
        isNull,
      );
      expect(await fixture.mediaStore.exists(imported.mediaKey), isFalse);
      expect(await external.exists(), isTrue);
    },
  );

  test('failed or stale preview/export state cannot complete', () async {
    final fixture = await _fixture();
    addTearDown(fixture.dispose);
    await fixture.repository.updateAcknowledgements(
      preparationId: fixture.preparation.id,
      actor: fixture.actor,
      entitlement: potpun,
      noPhotoAccepted: true,
    );
    final preparation = (await fixture.repository.findForPredmet(
      fixture.predmet.id,
    ))!;
    final plan = await fixture.service.buildPlan(preparation: preparation);

    expect(
      () => fixture.repository.beginCompletion(
        preparationId: preparation.id,
        plan: plan,
        actor: fixture.actor,
        entitlement: potpun,
      ),
      throwsStateError,
    );
    expect(
      () => fixture.repository.recordSuccessfulExport(
        preparationId: preparation.id,
        plan: plan,
        filename: 'never-written.pdf',
        location: 'KORICE/never-written.pdf',
        actor: fixture.actor,
        entitlement: potpun,
      ),
      throwsStateError,
    );
  });
}

class _Fixture {
  const _Fixture({
    required this.db,
    required this.root,
    required this.actor,
    required this.predmet,
    required this.repository,
    required this.mediaStore,
    required this.service,
    required this.preparation,
  });

  final AppDatabase db;
  final Directory root;
  final KorisniciData actor;
  final PredmetiData predmet;
  final PartePreparationRepository repository;
  final ParteMediaStore mediaStore;
  final PartePreparationService service;
  final PartePripremeData preparation;

  Future<void> dispose() async {
    await db.close();
    if (await root.exists()) await root.delete(recursive: true);
  }
}

Future<_Fixture> _fixture() async {
  final db = createTestDatabase();
  final root = await Directory.systemTemp.createTemp('opc_parte_pdf_');
  final actorId = await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'Sintetički savetnik',
          uloga: 'SAVETNIK',
          pinHash: 'synthetic-hash',
          datumKreiranja: '2026-07-11T10:00:00.000',
        ),
      );
  final actor = await (db.select(
    db.korisnici,
  )..where((row) => row.id.equals(actorId))).getSingle();
  final predmetId = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('PARTE-PDF-001'),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
          ime: const Value('Sintetičko'),
          prezime: const Value('Lice'),
          pol: const Value('M'),
          partePotrebna: const Value(true),
          simbol: const Value('PRAVOSLAVNI_KRST_SVETOSAVSKI'),
          datumSmrti: const Value('10.07.2026'),
          datumCeremonije: const Value('20.07.2026'),
          vremeCeremonije: const Value('12:00'),
          groblje: const Value('GRADSKO GROBLJE'),
        ),
      );
  final predmet = await (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(predmetId))).getSingle();
  final repository = PartePreparationRepository(db);
  final mediaStore = ParteMediaStore(rootDirectory: () async => root);
  final service = PartePreparationService(
    repository: repository,
    mediaStore: mediaStore,
  );
  final preparation = await repository.initializeOrResume(
    predmetId: predmet.id,
    actor: actor,
    entitlement: const OpcEntitlementPolicy.fromSource(
      OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
    ),
  );
  return _Fixture(
    db: db,
    root: root,
    actor: actor,
    predmet: predmet,
    repository: repository,
    mediaStore: mediaStore,
    service: service,
    preparation: preparation,
  );
}
