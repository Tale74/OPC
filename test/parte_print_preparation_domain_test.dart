import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/parte/application/parte_authorization.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_template_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_composer.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_initial_composer.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const potpun = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
  );
  const osnovni = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.osnovni),
  );
  const srednji = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.srednji),
  );
  const srednjiParte = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(
      packageLevel: OpcPackageLevel.srednji,
      enabledAddOns: {OpcAddOn.advancedParte},
    ),
  );

  group('PARTE initial composition and render plan', () {
    test(
      'male/female grammar, OPELO/ISPRAĆAJ and časova are derived',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final male = await _insertPredmet(
          db,
          pol: 'M',
          opelo: 'DA',
          vremeOpela: '10:30',
        );
        final female = await _insertPredmet(
          db,
          broj: 'PARTE-002',
          pol: 'Z',
          opelo: 'NE',
          vremeIspracaja: '11:15',
        );

        final maleDraft = const ParteInitialComposer()
            .compose(predmet: male)
            .draft;
        final femaleDraft = const ParteInitialComposer()
            .compose(predmet: female)
            .draft;

        expect(maleDraft.textByBlock['intro'], contains('voljeni'));
        expect(maleDraft.textByBlock['death'], contains('preminuo'));
        expect(maleDraft.textByBlock['secondary'], contains('Opelo'));
        expect(maleDraft.textByBlock['secondary'], contains('časova'));
        expect(femaleDraft.textByBlock['intro'], contains('voljena'));
        expect(femaleDraft.textByBlock['death'], contains('preminula'));
        expect(femaleDraft.textByBlock['secondary'], contains('Ispraćaj'));
        expect(femaleDraft.textByBlock['ceremony'], contains('časova'));
      },
    );

    test('unknown gender never silently becomes male', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db, pol: '');
      final result = const ParteInitialComposer().compose(predmet: predmet);

      expect(result.grammarRequiresReview, isTrue);
      expect(result.draft.textByBlock['intro'], isEmpty);
      expect(result.draft.textByBlock['death'], isEmpty);
    });

    test(
      'mixed scripts remain present and all standard symbols resolve',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(
          db,
          ime: 'Милан John',
          prezime: 'Smith Петровић',
        );
        final draft = const ParteInitialComposer()
            .compose(predmet: predmet)
            .draft;
        expect(draft.textByBlock['name'], contains('John'));
        expect(draft.textByBlock['name'], contains('Петровић'));
        for (final symbol in ParteSymbolCatalog.standard) {
          expect(symbol.assetPath, isNotEmpty, reason: symbol.id);
        }
        expect(ParteSymbolCatalog.standard, hasLength(6));
      },
    );

    test(
      'no photo and free-choice warnings require explicit acknowledgement',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(db, simbol: 'SLOBODAN_IZBOR');
        final draft = const ParteInitialComposer()
            .compose(predmet: predmet)
            .draft;
        final blocked = const ParteComposer().compose(
          ParteCompositionInput(
            draft: draft,
            template: ParteTemplate.builtInStandard,
            photoMediaKey: null,
            customSymbolMediaKey: null,
            noPhotoAccepted: false,
            noCustomSymbolAccepted: false,
            lowResolutionPhoto: false,
            lowResolutionAccepted: false,
            grammarRequiresReview: false,
            grammarVerified: true,
          ),
        );
        expect(blocked.canGeneratePdf, isFalse);
        expect(blocked.blockers, hasLength(greaterThanOrEqualTo(2)));

        final accepted = const ParteComposer().compose(
          ParteCompositionInput(
            draft: draft,
            template: ParteTemplate.builtInStandard,
            photoMediaKey: null,
            customSymbolMediaKey: null,
            noPhotoAccepted: true,
            noCustomSymbolAccepted: true,
            lowResolutionPhoto: false,
            lowResolutionAccepted: false,
            grammarRequiresReview: false,
            grammarVerified: true,
          ),
        );
        expect(accepted.canGeneratePdf, isTrue);
        expect(
          accepted.blocks.any((block) => block.kind == ParteBlockKind.photo),
          isFalse,
        );
        expect(
          accepted.blocks.any((block) => block.kind == ParteBlockKind.symbol),
          isFalse,
        );
      },
    );

    test('long text is preserved and unresolved overflow blocks PDF', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db);
      final base = const ParteInitialComposer().compose(predmet: predmet).draft;
      final longText = List.filled(500, 'VEOMA DUGAČAK TEKST').join(' ');
      final draft = base.copyWith(
        textByBlock: {...base.textByBlock, 'mourners': longText},
      );
      final plan = const ParteComposer().compose(
        ParteCompositionInput(
          draft: draft,
          template: ParteTemplate.builtInStandard,
          photoMediaKey: null,
          customSymbolMediaKey: null,
          noPhotoAccepted: true,
          noCustomSymbolAccepted: true,
          lowResolutionPhoto: false,
          lowResolutionAccepted: false,
          grammarRequiresReview: false,
          grammarVerified: true,
        ),
      );
      expect(plan.canGeneratePdf, isFalse);
      expect(plan.blockers.join(' '), contains('mourners'));
      expect(draft.textByBlock['mourners'], longText);
    });
  });

  group('PARTE persistence, blocker, role and entitlement', () {
    test(
      'first legitimate open creates one restart-safe preparation',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final predmet = await _insertPredmet(db, partePotrebna: true);
        final repository = PartePreparationRepository(db);

        final first = await repository.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: potpun,
        );
        final second = await repository.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: potpun,
        );

        expect(second.id, first.id);
        expect(await db.select(db.partePripreme).get(), hasLength(1));
        expect(first.draftJson, contains('textByBlock'));
        expect(first.templateSnapshotJson, contains('widthMm'));
        expect(first.templateSnapshotJson, isNot(contains(predmet.ime)));
      },
    );

    test(
      'not-required and OSNOVNI paths cannot initialize preparation',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final notRequired = await _insertPredmet(db);
        final required = await _insertPredmet(
          db,
          broj: 'PARTE-LOCKED',
          partePotrebna: true,
        );
        final repository = PartePreparationRepository(db);

        expect(
          () => repository.initializeOrResume(
            predmetId: notRequired.id,
            actor: actor,
            entitlement: potpun,
          ),
          throwsStateError,
        );
        expect(
          () => repository.initializeOrResume(
            predmetId: required.id,
            actor: actor,
            entitlement: osnovni,
          ),
          throwsA(isA<ParteAuthorizationException>()),
        );
        expect(await db.select(db.partePripreme).get(), isEmpty);
      },
    );

    test(
      'SREDNJI requires the PARTE add-on and then resumes normally',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final predmet = await _insertPredmet(
          db,
          broj: 'PARTE-SREDNJI',
          partePotrebna: true,
        );
        final repository = PartePreparationRepository(db);

        expect(
          () => repository.initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: srednji,
          ),
          throwsA(isA<ParteAuthorizationException>()),
        );
        final created = await repository.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: srednjiParte,
        );
        expect(created.predmetId, predmet.id);
      },
    );

    test(
      'started preparation blocks close, automatic finish and anonymization',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final predmet = await _insertPredmet(
          db,
          partePotrebna: true,
          datumCeremonije: '01.01.2020',
        );
        await PartePreparationRepository(db).initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: potpun,
        );
        final predmetRepository = PredmetiRepository(db);

        expect(
          () => predmetRepository.zatvoriPredmet(
            predmet.id,
            korisnikId: actor.id,
          ),
          throwsA(isA<PartePreparationBlockException>()),
        );
        expect(
          await predmetRepository.osveziAutomatskiStatusPredmeta(predmet.id),
          isFalse,
        );
        expect(
          () => predmetRepository.anonimizujPredmet(predmet.id),
          throwsA(isA<PartePreparationBlockException>()),
        );
        expect(
          (await predmetRepository.getPredmet(predmet.id)).status,
          'OTVOREN',
        );
      },
    );

    test(
      'downgrade retains preparation and re-entitlement resumes it',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final predmet = await _insertPredmet(db, partePotrebna: true);
        final repository = PartePreparationRepository(db);
        final created = await repository.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: potpun,
        );
        expect(
          () => repository.initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: osnovni,
          ),
          throwsA(isA<ParteAuthorizationException>()),
        );
        expect((await repository.findForPredmet(predmet.id))?.id, created.id);
        expect(
          (await repository.initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: potpun,
          )).id,
          created.id,
        );
      },
    );

    test('SAVETNIK cannot manage FIRMA templates; ADMINISTRATOR can', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final adviser = await _insertUser(db, role: 'SAVETNIK');
      final admin = await _insertUser(db, role: 'ADMINISTRATOR');
      final repository = ParteTemplateRepository(db);

      expect(
        () => repository.createUserTemplate(
          actor: adviser,
          name: 'Zabranjen',
          technicalSource: ParteTemplate.builtInStandard,
        ),
        throwsA(isA<ParteAuthorizationException>()),
      );
      final created = await repository.createUserTemplate(
        actor: admin,
        name: 'Sintetički tehnički šablon',
        technicalSource: ParteTemplate.builtInStandard,
      );
      expect(created.builtIn, isFalse);
      expect(
        repository.exportTemplate(created),
        isNot(contains('textByBlock')),
      );
    });

    test(
      'FIRMA template lifecycle and import conflicts remain content-free',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final admin = await _insertUser(db, role: 'ADMINISTRATOR');
        final repository = ParteTemplateRepository(db);

        expect(
          () => repository.rename(
            actor: admin,
            id: parteBuiltinTemplateId,
            newName: 'Forbidden',
          ),
          throwsStateError,
        );
        expect(
          () => repository.delete(actor: admin, id: parteBuiltinTemplateId),
          throwsStateError,
        );

        final created = await repository.duplicate(
          actor: admin,
          source: ParteTemplate.builtInStandard,
          name: 'Synthetic layout',
        );
        await repository.rename(
          actor: admin,
          id: created.id,
          newName: 'Synthetic renamed layout',
        );
        await repository.setDefault(templateId: created.id, actor: admin);
        expect(
          (await repository.resolveActiveTemplate()).template.id,
          created.id,
        );

        final bytes = utf8.encode(
          repository.exportTemplate(
            (await repository.listTemplates()).singleWhere(
              (template) => template.id == created.id,
            ),
          ),
        );
        expect(
          await repository.importTemplate(
            actor: admin,
            bytes: bytes,
            conflict: ParteTemplateImportConflict.cancel,
          ),
          isNull,
        );
        final copy = await repository.importTemplate(
          actor: admin,
          bytes: bytes,
          conflict: ParteTemplateImportConflict.importAsCopy,
        );
        expect(copy, isNotNull);
        expect(copy!.id, isNot(created.id));
        expect(repository.exportTemplate(copy), isNot(contains('textByBlock')));

        await repository.delete(actor: admin, id: created.id);
        final fallback = await repository.resolveActiveTemplate();
        expect(fallback.template.id, parteBuiltinTemplateId);
        expect(fallback.fallbackUsed, isFalse);
      },
    );

    test(
      'started preparation keeps its template snapshot and detects source edits',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final admin = await _insertUser(db, role: 'ADMINISTRATOR');
        final actor = await _insertUser(db, role: 'SAVETNIK');
        final predmet = await _insertPredmet(
          db,
          broj: 'PARTE-SNAPSHOT',
          partePotrebna: true,
        );
        final templates = ParteTemplateRepository(db);
        final custom = await templates.createUserTemplate(
          actor: admin,
          name: 'Snapshot layout',
          technicalSource: ParteTemplate.builtInStandard,
        );
        await templates.setDefault(templateId: custom.id, actor: admin);
        final preparations = PartePreparationRepository(db);
        final started = await preparations.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: potpun,
        );
        final snapshot = started.templateSnapshotJson;

        await templates.setDefault(
          templateId: parteBuiltinTemplateId,
          actor: admin,
        );
        expect(
          (await preparations.initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: potpun,
          )).templateSnapshotJson,
          snapshot,
        );
        await (db.update(db.predmeti)
              ..where((row) => row.id.equals(predmet.id)))
            .write(const PredmetiCompanion(ime: Value('Changed source name')));
        expect(await preparations.sourceChanged(started.id), isTrue);
        final rebuilt = await preparations.rebuildFromPredmet(
          preparationId: started.id,
          actor: actor,
          entitlement: potpun,
        );
        expect(rebuilt.templateSnapshotJson, snapshot);
        expect(await preparations.sourceChanged(started.id), isFalse);
      },
    );
  });

  group('PARTE app-owned media', () {
    test(
      'normalizes synthetic copy and never mutates original bytes',
      () async {
        final root = await Directory.systemTemp.createTemp('opc_parte_media_');
        addTearDown(() => root.delete(recursive: true));
        final store = ParteMediaStore(rootDirectory: () async => root);
        final original = Uint8List.fromList(
          img.encodePng(img.Image(width: 800, height: 1000)),
        );
        final snapshot = Uint8List.fromList(original);

        final result = await store.importBytes(
          sourceBytes: original,
          predmetBroj: 'SYNTHETIC-001',
          kind: ParteMediaKind.photo,
        );

        expect(original, orderedEquals(snapshot));
        expect(await store.exists(result.mediaKey), isTrue);
        expect(
          img.decodePng(await store.read(result.mediaKey)),
          isNot(equals(null)),
        );
        expect(result.lowResolution, isFalse);
      },
    );

    test('corrupt replacement fails and prior app copy remains', () async {
      final root = await Directory.systemTemp.createTemp('opc_parte_media_');
      addTearDown(() => root.delete(recursive: true));
      final store = ParteMediaStore(rootDirectory: () async => root);
      final valid = Uint8List.fromList(
        img.encodePng(img.Image(width: 500, height: 700)),
      );
      final first = await store.importBytes(
        sourceBytes: valid,
        predmetBroj: 'SYNTHETIC-002',
        kind: ParteMediaKind.photo,
      );

      expect(
        () => store.importBytes(
          sourceBytes: Uint8List.fromList([1, 2, 3, 4]),
          predmetBroj: 'SYNTHETIC-002',
          kind: ParteMediaKind.photo,
        ),
        throwsA(isA<ParteMediaException>()),
      );
      expect(await store.exists(first.mediaKey), isTrue);
      expect(
        () => store.deleteOwned('../external-original.png'),
        throwsA(isA<ParteMediaException>()),
      );
    });
  });
}

Future<KorisniciData> _insertUser(
  AppDatabase db, {
  required String role,
}) async {
  final id = await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'Sintetički korisnik $role',
          uloga: role,
          pinHash: 'synthetic-hash',
          datumKreiranja: '2026-07-11T10:00:00.000',
        ),
      );
  return (db.select(
    db.korisnici,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  String broj = 'PARTE-001',
  String ime = 'Milan',
  String prezime = 'Sintetić',
  String pol = 'M',
  String simbol = 'PRAVOSLAVNI_KRST_SVETOSAVSKI',
  String opelo = 'DA',
  String vremeOpela = '10:30',
  String vremeIspracaja = '',
  String datumCeremonije = '20.07.2026',
  bool partePotrebna = false,
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
          ime: Value(ime),
          prezime: Value(prezime),
          pol: Value(pol),
          datumRodjenja: const Value('01.01.1950'),
          datumSmrti: const Value('10.07.2026'),
          vrstaCeremonije: const Value('SAHRANA'),
          datumCeremonije: Value(datumCeremonije),
          vremeCeremonije: const Value('12:00'),
          groblje: const Value('GRADSKO GROBLJE'),
          opelo: Value(opelo),
          vremeOpela: Value(vremeOpela),
          vremeIspracaja: Value(vremeIspracaja),
          simbol: Value(simbol),
          pismo: const Value('LATINICA'),
          ozaloseni: const Value('Sintetička porodica'),
          partePotrebna: Value(partePotrebna),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}
