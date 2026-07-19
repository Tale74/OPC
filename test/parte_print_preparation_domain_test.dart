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
import 'package:opc_v4/features/predmeti/parte/data/parte_print_profile_store.dart';
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
        expect(maleDraft.textByBlock['years'], '1950 – 2026.');
        expect(maleDraft.textByBlock['years'], isNot(contains('—')));
        expect(femaleDraft.textByBlock['intro'], contains('voljena'));
        expect(femaleDraft.textByBlock['death'], contains('preminula'));
        expect(femaleDraft.textByBlock['secondary'], contains('Ispraćaj'));
        expect(femaleDraft.textByBlock['ceremony'], contains('časova'));
      },
    );

    test('formal font catalog persists supported render families', () {
      expect(
        ParteFontCatalog.supported,
        containsAll(<String>[
          ParteFontCatalog.notoSans,
          ParteFontCatalog.notoSerif,
        ]),
      );
      final serif = ParteTemplate.builtInStandard.blocks
          .firstWhere((block) => block.kind == ParteBlockKind.text)
          .copyWith(fontFamily: ParteFontCatalog.notoSerif);
      final decoded = ParteBlockSpec.fromJson(serif.toJson());
      expect(decoded.fontFamily, ParteFontCatalog.notoSerif);
      expect(ParteFontCatalog.displayName(decoded.fontFamily), 'Noto Serif');
      expect(
        ParteTemplate.builtInStandard.blocks
            .firstWhere((block) => block.kind == ParteBlockKind.text)
            .fontFamily,
        ParteFontCatalog.notoSerif,
      );
      final explicitSans = serif.copyWith(
        fontFamily: ParteFontCatalog.notoSans,
      );
      expect(
        ParteBlockSpec.fromJson(explicitSans.toJson()).fontFamily,
        ParteFontCatalog.notoSans,
      );
    });

    test('locked media reflow and legacy normalization preserve one ratio', () {
      const photo = ParteBlockSpec(
        id: 'photo',
        kind: ParteBlockKind.photo,
        rect: ParteRectMm(x: 170, y: 10, width: 40, height: 40),
        sourceAspectRatio: 0.75,
      );
      const draft = ParteDraft(
        textByBlock: {},
        blocks: [photo],
        widthMm: 224,
        heightMm: 170,
        symbolId: 'BEZ_SIMBOLA',
      );
      final transformed = draft.reflowTo(
        widthMm: 224,
        heightMm: 170,
        horizontalMarginMm: 5,
        verticalMarginMm: 5,
        printableZoneXmm: 24.5,
        printableZoneYmm: 27.5,
        printableZoneWidthMm: 175,
        printableZoneHeightMm: 115,
      );
      final rect = transformed.blocks.single.rect;
      expect(rect.width / rect.height, closeTo(0.75, 0.0001));
    });

    test(
      'printer corrections are machine-local and isolated by template',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'parte_print_profile_',
        );
        addTearDown(() => root.delete(recursive: true));
        final store = PartePrintProfileStore(rootDirectory: () async => root);
        await store.saveForTemplate(
          'template-a',
          const PartePrintProfile(
            horizontalCorrectionMm: -2.5,
            verticalCorrectionMm: 1.25,
          ),
        );
        final loaded = await store.loadForTemplate('template-a');
        expect(loaded.horizontalCorrectionMm, -2.5);
        expect(loaded.verticalCorrectionMm, 1.25);
        expect((await store.loadForTemplate('template-b')).isCentered, isTrue);
        await store.resetForTemplate('template-a');
        expect((await store.loadForTemplate('template-a')).isCentered, isTrue);
      },
    );

    test(
      'legacy single printer profile binds to the active template',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'parte_print_profile_legacy_',
        );
        addTearDown(() => root.delete(recursive: true));
        await File('${root.path}/parte_print_profile.json').writeAsString(
          jsonEncode(
            const PartePrintProfile(
              horizontalCorrectionMm: 25,
              verticalCorrectionMm: 4,
            ).toJson(),
          ),
        );
        final store = PartePrintProfileStore(rootDirectory: () async => root);

        final migrated = await store.loadForTemplate('test4-template');

        expect(migrated.horizontalCorrectionMm, 25);
        expect(migrated.verticalCorrectionMm, 4);
        expect(
          (await store.loadForTemplate('another-template')).isCentered,
          isTrue,
        );
        final persisted =
            jsonDecode(
                  await File(
                    '${root.path}/parte_print_profile.json',
                  ).readAsString(),
                )
                as Map<String, dynamic>;
        expect(persisted['schemaVersion'], 2);
        expect(
          (persisted['profilesByTemplateId'] as Map).keys,
          contains('test4-template'),
        );
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

    test('selected LATINICA script normalizes all initial content', () async {
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
      expect(draft.textByBlock['name'], contains('Petrović'));
      expect(draft.textByBlock['name'], isNot(contains('Петровић')));
      for (final symbol in ParteSymbolCatalog.standard) {
        expect(symbol.assetPath, isNotEmpty, reason: symbol.id);
      }
      expect(ParteSymbolCatalog.standard, hasLength(6));
    });

    test(
      'canonical plan keeps a 74 pt name on one line and normalizes years',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmet = await _insertPredmet(
          db,
          ime: 'Aleksandar-Mihailo',
          prezime: 'Petrović Jovanović',
        );
        final base = const ParteInitialComposer()
            .compose(predmet: predmet)
            .draft;
        final draft = base.copyWith(
          textByBlock: {...base.textByBlock, 'years': '1950 — 2026.'},
          blocks: base.blocks
              .map(
                (block) => block.id == 'name'
                    ? block.copyWith(
                        rect: ParteRectMm(
                          x: 14,
                          y: block.rect.y,
                          width: 196,
                          height: block.rect.height,
                        ),
                        initialFontSize: 74,
                        maximumFontSize: 74,
                      )
                    : block,
              )
              .toList(growable: false),
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

        final name = plan.blocks.singleWhere((block) => block.id == 'name');
        final years = plan.blocks.singleWhere((block) => block.id == 'years');
        expect(name.lines, hasLength(1));
        expect(name.resolvedText, contains('Aleksandar-Mihailo'));
        expect(name.fontSize, lessThanOrEqualTo(74));
        expect(name.maximumFontSize, 74);
        expect(name.horizontalScale, inInclusiveRange(0.5, 1));
        expect(name.fitStatus, ParteFitStatus.fitted);
        expect(years.resolvedText, '1950 – 2026.');
        expect(plan.canGeneratePdf, isTrue, reason: plan.blockers.join(' | '));
        expect(plan.validateForExport, returnsNormally);
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
        expect(
          accepted.canGeneratePdf,
          isTrue,
          reason: accepted.blockers.join(' | '),
        );
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

    test(
      'physical reflow transforms every block and keeps separate margins',
      () {
        final source = ParteDraft(
          textByBlock: const <String, String>{'name': 'Sintetičko Lice'},
          blocks: ParteTemplate.builtInStandard.blocks,
          widthMm: 224,
          heightMm: 170,
          horizontalMarginMm: 5,
          verticalMarginMm: 5,
          symbolId: 'BEZ_SIMBOLA',
        );
        final transformed = source.reflowTo(
          widthMm: 180,
          heightMm: 120,
          horizontalMarginMm: 8,
          verticalMarginMm: 10,
        );

        expect(transformed.blocks, hasLength(source.blocks.length));
        expect(transformed.horizontalMarginMm, 8);
        expect(transformed.verticalMarginMm, 10);
        for (var i = 0; i < source.blocks.length; i++) {
          expect(
            transformed.blocks[i].rect,
            isNot(same(source.blocks[i].rect)),
          );
          expect(transformed.blocks[i].rect.x, greaterThanOrEqualTo(8));
          expect(transformed.blocks[i].rect.y, greaterThanOrEqualTo(10));
        }
        final decoded = ParteDraft.decode(transformed.encode());
        expect(decoded.horizontalMarginMm, 8);
        expect(decoded.verticalMarginMm, 10);
      },
    );

    test('legacy one-margin JSON migrates to both axes', () {
      final legacy = <String, Object?>{
        'schemaVersion': 2,
        'textByBlock': <String, String>{'mourners': 'Ožalošćeni:\nPorodica'},
        'blocks': ParteTemplate.builtInStandard.blocks
            .where((block) => block.id != 'mournersHeading')
            .map((block) => block.toJson())
            .toList(),
        'widthMm': 224,
        'heightMm': 170,
        'marginMm': 7,
        'symbolId': 'BEZ_SIMBOLA',
      };
      final decoded = ParteDraft.fromJson(legacy);
      expect(decoded.horizontalMarginMm, 7);
      expect(decoded.verticalMarginMm, 7);
      expect(decoded.printableZoneXmm, 0);
      expect(decoded.printableZoneYmm, 0);
      expect(decoded.printableZoneWidthMm, 224);
      expect(decoded.printableZoneHeightMm, 170);
      expect(decoded.textByBlock['mournersHeading'], 'Ožalošćeni:');
      expect(decoded.textByBlock['mourners'], 'Porodica');
      expect(
        decoded.blocks.any((block) => block.id == 'mournersHeading'),
        isTrue,
      );
    });

    test('schema 4 reflow maps blocks into the explicit printable zone', () {
      final source = ParteDraft(
        textByBlock: const <String, String>{'name': 'Sintetičko Lice'},
        blocks: ParteTemplate.builtInStandard.blocks,
        widthMm: 224,
        heightMm: 170,
        symbolId: 'BEZ_SIMBOLA',
      );
      final transformed = source.reflowTo(
        widthMm: 224,
        heightMm: 170,
        horizontalMarginMm: 5,
        verticalMarginMm: 5,
        printableZoneXmm: 24.5,
        printableZoneYmm: 27.5,
        printableZoneWidthMm: 175,
        printableZoneHeightMm: 115,
      );

      expect(transformed.schemaVersion, parteDraftSchemaVersion);
      expect(transformed.printableZoneXmm, 24.5);
      expect(transformed.printableZoneWidthMm, 175);
      for (final block in transformed.blocks) {
        expect(block.rect.x, greaterThanOrEqualTo(29.5));
        expect(block.rect.y, greaterThanOrEqualTo(32.5));
        expect(block.rect.right, lessThanOrEqualTo(194.5));
        expect(block.rect.bottom, lessThanOrEqualTo(137.5));
      }
      final decoded = ParteDraft.decode(transformed.encode());
      expect(decoded.printableZoneYmm, 27.5);
      expect(decoded.printableZoneHeightMm, 115);
    });

    test(
      'name casing and all weekday forms are display-only correct',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        const weekdays = <String>[
          'ponedeljak',
          'utorak',
          'sredu',
          'četvrtak',
          'petak',
          'subotu',
          'nedelju',
        ];
        for (var index = 0; index < weekdays.length; index++) {
          final predmet = await _insertPredmet(
            db,
            broj: 'WEEKDAY-$index',
            ime: index == 0 ? 'mILAN-pETAR' : 'Milan',
            prezime: index == 0 ? 'pETROVIĆ' : 'Sintetić',
            datumCeremonije: '${20 + index}.07.2026',
          );
          final draft = const ParteInitialComposer()
              .compose(predmet: predmet)
              .draft;
          expect(draft.textByBlock['ceremony'], contains(weekdays[index]));
          if (index == 0) {
            expect(draft.textByBlock['name'], contains('Milan-Petar Petrović'));
            expect(predmet.ime, 'mILAN-pETAR');
          }
        }
      },
    );
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
      'business prerequisite remains while OSNOVNI no longer locks PARTE',
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
        final created = await repository.initializeOrResume(
          predmetId: required.id,
          actor: actor,
          entitlement: osnovni,
        );
        expect(created.predmetId, required.id);
        expect(await db.select(db.partePripreme).get(), hasLength(1));
      },
    );

    test('SREDNJI no longer requires the PARTE add-on', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actor = await _insertUser(db, role: 'SAVETNIK');
      final predmet = await _insertPredmet(
        db,
        broj: 'PARTE-SREDNJI',
        partePotrebna: true,
      );
      final repository = PartePreparationRepository(db);

      final createdWithoutAddOn = await repository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: srednji,
      );
      final created = await repository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: srednjiParte,
      );
      expect(created.id, createdWithoutAddOn.id);
      expect(created.predmetId, predmet.id);
    });

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

    test('package change retains and resumes the same preparation', () async {
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
        (await repository.initializeOrResume(
          predmetId: predmet.id,
          actor: actor,
          entitlement: osnovni,
        )).id,
        created.id,
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
    });

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

    test(
      'selected apply, active template and persisted default stay independent',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final admin = await _insertUser(db, role: 'ADMINISTRATOR');
        final predmet = await _insertPredmet(
          db,
          broj: 'PARTE-TEMPLATE-STATE',
          partePotrebna: true,
        );
        final templates = ParteTemplateRepository(db);
        final defaultTemplate = await templates.createUserTemplate(
          actor: admin,
          name: 'Default layout',
          technicalSource: ParteTemplate.builtInStandard,
        );
        final appliedTemplate = await templates.createUserTemplate(
          actor: admin,
          name: 'Applied layout',
          technicalSource: ParteTemplate.builtInStandard,
        );
        await templates.setDefault(
          templateId: defaultTemplate.id,
          actor: admin,
        );
        final preparations = PartePreparationRepository(db);
        var preparation = await preparations.initializeOrResume(
          predmetId: predmet.id,
          actor: admin,
          entitlement: potpun,
        );
        final draft = ParteDraft.decode(preparation.draftJson);

        await preparations.applyTemplate(
          preparationId: preparation.id,
          currentDraft: draft,
          template: appliedTemplate,
          actor: admin,
          entitlement: potpun,
        );
        preparation = (await preparations.findForPredmet(predmet.id))!;

        expect(preparation.templateId, appliedTemplate.id);
        expect(
          preparations.templateSnapshot(preparation).id,
          appliedTemplate.id,
        );
        expect(
          (await templates.resolveActiveTemplate()).template.id,
          defaultTemplate.id,
        );
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
