import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_module_screen.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_composer_screen.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_print_profile_store.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('MODUL PARTE lists only open PREDMET with required PARTE', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Sintetički savetnik',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-07-12T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    final session = SessionService()..prijavi(actor);
    await _insert(db, 'ELIGIBLE-001', 'Otvoreno', parte: true);
    await _insert(db, 'NO-PARTE-002', 'BezParte', parte: false);
    await _insert(
      db,
      'CLOSED-003',
      'Zatvoreno',
      parte: true,
      status: 'ZATVOREN',
    );
    final eligible = await (db.select(
      db.predmeti,
    )..where((row) => row.brojPredmeta.equals('ELIGIBLE-001'))).getSingle();
    PredmetScreen? openedParteDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: ParteModuleScreen(
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          session: session,
          onOpenPredmetParte: (destination) async {
            openedParteDestination = destination;
          },
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.textContaining('ELIGIBLE-001').evaluate().isNotEmpty) break;
    }

    expect(find.text('MODUL PARTE'), findsOneWidget);
    expect(find.text('Otvoreno Lice'), findsOneWidget);
    expect(find.textContaining('ELIGIBLE-001'), findsOneWidget);
    expect(find.textContaining('NO-PARTE-002'), findsNothing);
    expect(find.textContaining('CLOSED-003'), findsNothing);

    await tester.tap(
      find.byKey(ValueKey('parte-open-predmet-parte-${eligible.id}')),
    );
    await tester.pump();
    expect(openedParteDestination, isNotNull);
    expect(openedParteDestination!.predmetId, eligible.id);
    expect(openedParteDestination!.openParte, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump();
  });

  testWidgets('narrow composer has collapsible setup and persistent designer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Sintetički savetnik',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-07-17T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    await _insert(db, 'COMPOSER-004', 'Sintetičko', parte: true);
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.brojPredmeta.equals('COMPOSER-004'))).getSingle();
    await tester.pumpWidget(
      MaterialApp(
        home: ParteComposerScreen(
          predmetId: predmet.id,
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          printProfileStore: _MemoryPrintProfileStore(),
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('TEKSTUALNI BLOKOVI').evaluate().isNotEmpty) break;
    }

    expect(find.text('TEKSTUALNI BLOKOVI'), findsOneWidget);
    expect(find.text('FORMAT I ZONA ŠTAMPE (mm)'), findsOneWidget);
    expect(find.textContaining('zona 175.0 × 115.0'), findsNothing);
    expect(find.textContaining('margina 5.0 × 5.0'), findsNothing);
    expect(find.text('Zona – X'), findsNothing);
    expect(find.text('Zona – Y'), findsNothing);
    expect(find.text('Zona štampe – širina'), findsOneWidget);
    expect(find.text('Zona štampe – visina'), findsOneWidget);
    expect(find.text('SAČUVAJ PROFIL ZA ŠABLON'), findsOneWidget);
    expect(find.text('Korekcija celog PDF otiska'), findsNothing);
    expect(find.textContaining('min '), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('TEKSTUALNI BLOKOVI'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('PRECIZNO POMERANJE I STIL'), findsOneWidget);
    expect(find.byKey(const Key('parte-compact-font-row')), findsOneWidget);
    expect(find.byKey(const Key('parte-font-size-state')), findsOneWidget);
    final textTitleBottom = tester
        .getRect(find.text('TEKSTUALNI BLOKOVI'))
        .bottom;
    final introLabelTop = tester.getRect(find.text('Uvodna fraza')).top;
    expect(introLabelTop, greaterThan(textTitleBottom));
    final formatTitleBottom = tester
        .getRect(find.text('FORMAT I ZONA ŠTAMPE (mm)'))
        .bottom;
    final pageWidthLabelTop = tester.getRect(find.text('Strana – širina')).top;
    expect(pageWidthLabelTop, greaterThan(formatTitleBottom));
    await tester.scrollUntilVisible(
      find.text('PREGLED PRIPREME'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('PREGLED PRIPREME'), findsOneWidget);
    expect(
      find.byKey(const Key('parte-preview-technical-guide')),
      findsOneWidget,
    );
    expect(find.textContaining('Actual size / 100%'), findsOneWidget);
    expect(find.textContaining('ne ulaze u PDF ni DOCX'), findsOneWidget);
    final preview = tester.widget<PartePlanPreview>(
      find.byType(PartePlanPreview),
    );
    final guideBottom = tester
        .getRect(find.byKey(const Key('parte-preview-technical-guide')))
        .bottom;
    final canvasTop = tester.getRect(find.byType(PartePlanPreview)).top;
    expect(guideBottom, lessThanOrEqualTo(canvasTop));
    expect(tester.takeException(), isNull);

    final movements = <(String, double, double)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParteEditorViewport(
            plan: preview.plan,
            mediaStore: preview.mediaStore,
            selectedBlockId: 'intro',
            onBlockMoved: (id, dxMm, dyMm) async {
              movements.add((id, dxMm, dyMm));
            },
          ),
        ),
      ),
    );
    await tester.pump();
    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byKey(const Key('parte-editor-interactive-viewer')),
    );
    expect(interactiveViewer.panEnabled, isFalse);
    expect(interactiveViewer.scaleEnabled, isFalse);
    final introFinder = find.byKey(const ValueKey('parte-preview-block-intro'));
    var blockDetector = tester.widget<GestureDetector>(introFinder);
    expect(blockDetector.onPanUpdate, isNotNull);
    expect(blockDetector.onPanEnd, isNotNull);
    blockDetector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(48, 0),
      ),
    );
    await tester.pump();
    blockDetector = tester.widget<GestureDetector>(introFinder);
    blockDetector.onPanEnd!(DragEndDetails());
    await tester.pump();
    expect(movements, hasLength(1));
    expect(movements.single.$1, 'intro');
    expect(movements.single.$2, isNot(0));

    await tester.tap(find.byKey(const Key('parte-viewport-pan-mode')));
    await tester.pump();
    final panViewer = tester.widget<InteractiveViewer>(
      find.byKey(const Key('parte-editor-interactive-viewer')),
    );
    expect(panViewer.panEnabled, isTrue);
    expect(panViewer.scaleEnabled, isTrue);
    blockDetector = tester.widget<GestureDetector>(introFinder);
    expect(blockDetector.onPanUpdate, isNull);
    expect(blockDetector.onPanEnd, isNull);
    expect(movements, hasLength(1));
    expect(find.byKey(const Key('parte-viewport-controls')), findsOneWidget);
  });

  testWidgets('composer font field follows fitted size after text save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Synthetic adviser',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-07-17T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('FONT-006'),
            datumKreiranja: const Value('2026-07-12T10:00:00.000'),
            ime: const Value('VeryLongNameThatMustBeFittedToThePartePrintArea'),
            prezime: const Value(
              'VeryLongSurnameThatMustBeFittedToThePartePrintArea',
            ),
            partePotrebna: const Value(true),
            status: const Value('OTVOREN'),
          ),
        );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.brojPredmeta.equals('FONT-006'))).getSingle();

    await tester.pumpWidget(
      MaterialApp(
        home: ParteComposerScreen(
          predmetId: predmet.id,
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          printProfileStore: _MemoryPrintProfileStore(),
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('TEKSTUALNI BLOKOVI').evaluate().isNotEmpty) break;
    }
    await tester.tap(find.text('TEKSTUALNI BLOKOVI'));
    await tester.pump();
    final nameField = find.byKey(const ValueKey('parte-text-name'));
    expect(nameField, findsOneWidget);
    await tester.enterText(
      nameField,
      'VeryLongNameThatMustBeFittedToThePartePrintArea VeryLongSurnameThatMustBeFittedToThePartePrintArea',
    );
      await tester.tap(find.byKey(const Key('parte-save-text')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('PREGLED PRIPREME'),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      final previewFinder = find.byType(PartePlanPreview);
      expect(previewFinder, findsOneWidget);
    final preview = tester.widget<PartePlanPreview>(previewFinder);
    final fittedNameSize = preview.plan.blocks
        .firstWhere((block) => block.id == 'name')
        .fontSize;
    final displayedSize = double.parse(
      tester
          .widget<TextField>(find.byKey(const Key('parte-font-size-state')))
          .controller!
          .text,
    );
    expect(fittedNameSize, lessThan(68));
    expect(displayedSize, fittedNameSize);
  });

  testWidgets(
    'completed preparation deletion is explicit and preserves PREDMET and IRiU',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actorId = await db
          .into(db.korisnici)
          .insert(
            KorisniciCompanion.insert(
              imePrezime: 'Sintetički savetnik',
              uloga: 'SAVETNIK',
              pinHash: 'synthetic-hash',
              datumKreiranja: '2026-07-22T10:00:00.000',
            ),
          );
      final actor = await (db.select(
        db.korisnici,
      )..where((row) => row.id.equals(actorId))).getSingle();
      final session = SessionService()..prijavi(actor);
      await _insert(db, 'DELETE-005', 'Sačuvana', parte: true);
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.brojPredmeta.equals('DELETE-005'))).getSingle();
      const entitlement = OpcEntitlementPolicy.fromSource(
        OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
      );
      final preparationRepository = PartePreparationRepository(db);
      final preparation = await preparationRepository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: entitlement,
      );
      await (db.update(
        db.partePripreme,
      )..where((row) => row.id.equals(preparation.id))).write(
        PartePripremeCompanion(
          status: Value(PartePreparationStatus.completed.dbValue),
        ),
      );
      final iriuRepository = IriuRepository(db);
      await iriuRepository.dodajStavku(
        predmetId: predmet.id,
        interniNaziv: IriuK.posmrtneParte,
        nazivPrikaz: 'Sintetičke posmrtne parte',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ParteModuleScreen(
            predmetiRepository: PredmetiRepository(db),
            actor: actor,
            entitlement: entitlement,
            session: session,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final menu = find.byKey(ValueKey('parte-preparation-menu-${predmet.id}'));
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OBRIŠI SAČUVANU PRIPREMU'));
      await tester.pumpAndSettle();
      expect(find.textContaining('PREDMET i IRiU podaci'), findsOneWidget);
      await tester.tap(find.text('ODUSTANI'));
      await tester.pumpAndSettle();
      expect(await preparationRepository.findForPredmet(predmet.id), isNotNull);

      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OBRIŠI SAČUVANU PRIPREMU'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OBRIŠI PRIPREMU'));
      await tester.pumpAndSettle();

      expect(await preparationRepository.findForPredmet(predmet.id), isNull);
      expect(
        (await PredmetiRepository(db).getPredmet(predmet.id)).id,
        predmet.id,
      );
      expect(
        (await iriuRepository.getIriu(
          predmet.id,
        )).any((row) => row.interniNaziv == IriuK.posmrtneParte),
        isTrue,
      );
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find
            .byKey(ValueKey('parte-preparation-menu-${predmet.id}'))
            .evaluate()
            .isEmpty) {
          break;
        }
      }
      expect(
        find.byKey(ValueKey('parte-preparation-${predmet.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('parte-preparation-menu-${predmet.id}')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump();
    },
  );
}

Future<void> _insert(
  AppDatabase db,
  String broj,
  String ime, {
  required bool parte,
  String status = 'OTVOREN',
}) => db
    .into(db.predmeti)
    .insert(
      PredmetiCompanion.insert(
        brojPredmeta: Value(broj),
        datumKreiranja: const Value('2026-07-12T10:00:00.000'),
        ime: Value(ime),
        prezime: const Value('Lice'),
        partePotrebna: Value(parte),
        status: Value(status),
      ),
    )
    .then((_) {});

class _MemoryPrintProfileStore extends PartePrintProfileStore {
  _MemoryPrintProfileStore()
    : super(rootDirectory: () async => Directory.current);

  final Map<String, PartePrintProfile> _profiles = {};

  @override
  Future<PartePrintProfile> loadForTemplate(String templateId) async =>
      _profiles[templateId] ?? const PartePrintProfile();

  @override
  Future<void> saveForTemplate(
    String templateId,
    PartePrintProfile profile,
  ) async {
    _profiles[templateId] = profile;
  }

  @override
  Future<void> resetForTemplate(String templateId) async {
    _profiles.remove(templateId);
  }
}
