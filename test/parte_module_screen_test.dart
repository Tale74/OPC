import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/help/opc_help.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
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
    await _insert(
      db,
      'OLDER-004',
      'Starije',
      parte: true,
      datumKreiranja: '2026-07-11T10:00:00.000',
    );
    await _insert(
      db,
      'TIE-LOW-005',
      'Isti datum niži ID',
      parte: true,
      datumKreiranja: '2026-07-13T10:00:00.000',
    );
    await _insert(
      db,
      'TIE-HIGH-006',
      'Isti datum viši ID',
      parte: true,
      datumKreiranja: '2026-07-13T10:00:00.000',
    );
    await _insert(
      db,
      'NEWEST-007',
      'Najnovije',
      parte: true,
      datumKreiranja: '2026-07-14T10:00:00.000',
    );
    await _insert(db, 'NO-PARTE-002', 'BezParte', parte: false);
    await _insert(
      db,
      'CLOSED-003',
      'Zatvoreno',
      parte: true,
      status: 'ZAVRŠEN',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ParteModuleScreen(
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          session: session,
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
    expect(find.byKey(const Key('parte-predmet-selector')), findsOneWidget);
    await tester.tap(find.byKey(const Key('parte-predmet-selector')));
    await tester.pumpAndSettle();
    final orderedOptions = [
      'Najnovije Lice · NEWEST-007',
      'Isti datum viši ID Lice · TIE-HIGH-006',
      'Isti datum niži ID Lice · TIE-LOW-005',
      'Otvoreno Lice · ELIGIBLE-001',
      'Starije Lice · OLDER-004',
    ].map(find.text).toList();
    final optionTops = orderedOptions
        .map((option) => tester.getTopLeft(option.last).dy)
        .toList();
    expect(optionTops, orderedEquals([...optionTops]..sort()));
    expect(find.text('Otvoreno Lice · ELIGIBLE-001'), findsOneWidget);
    expect(find.textContaining('NO-PARTE-002'), findsNothing);
    expect(find.textContaining('CLOSED-003'), findsNothing);
    await tester.tap(find.text('Otvoreno Lice · ELIGIBLE-001').last);
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.byType(ParteComposerScreen).evaluate().isNotEmpty) break;
    }
    expect(find.byType(ParteComposerScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('narrow composer has collapsible setup and persistent designer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
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

    final composerAppBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(composerAppBar.title, isA<OpcHelpTitle>());
    final title = (composerAppBar.title as OpcHelpTitle).title;
    expect(title, isA<Text>());
    expect((title as Text).data, 'PARTE – Sintetičko Lice');
    expect(
      find.byKey(const Key('opc-help-button-parte.preparation')),
      findsOneWidget,
    );
    expect(composerAppBar.bottom, isNull);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('PREDMET COMPOSER-004'),
      ),
      findsNothing,
    );

    expect(find.text('TEKSTUALNI BLOKOVI'), findsOneWidget);
    expect(find.text('FORMAT I ZONA ŠTAMPE'), findsOneWidget);
    expect(find.text('FORMAT I ZONA ŠTAMPE (mm)'), findsNothing);
    final textBlocksTile = find.ancestor(
      of: find.text('TEKSTUALNI BLOKOVI'),
      matching: find.byType(ExpansionTile),
    );
    expect(
      tester.widget<ExpansionTile>(textBlocksTile).initiallyExpanded,
      isFalse,
    );
    expect(find.text('Uvodna fraza'), findsNothing);
    await _tapAfterVisible(tester, find.text('TEKSTUALNI BLOKOVI'));
    expect(find.text('Uvodna fraza'), findsOneWidget);
    final mediaCard = find.byKey(const Key('parte-media-disclosure'));
    final mediaTile = find.descendant(
      of: mediaCard,
      matching: find.byType(ExpansionTile),
    );
    expect(tester.widget<ExpansionTile>(mediaTile).initiallyExpanded, isFalse);
    expect(
      find.ancestor(of: find.text('MEDIJI'), matching: find.byType(Card)),
      findsOneWidget,
    );
    expect(find.text('UNESI FOTOGRAFIJU'), findsNothing);
    await _tapAfterVisible(tester, find.text('MEDIJI'));
    expect(find.text('UNESI FOTOGRAFIJU'), findsOneWidget);
    await _tapAfterVisible(tester, find.text('MEDIJI'));
    expect(find.text('UNESI FOTOGRAFIJU'), findsNothing);

    final precisionCard = find.byKey(const Key('parte-precision-disclosure'));
    final precisionTile = find.descendant(
      of: precisionCard,
      matching: find.byType(ExpansionTile),
    );
    expect(
      tester.widget<ExpansionTile>(precisionTile).initiallyExpanded,
      isFalse,
    );
    expect(find.byKey(const Key('parte-font-size-state')), findsNothing);
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));
    expect(find.byKey(const Key('parte-font-size-state')), findsOneWidget);
    expect(find.text('SUZI'), findsNothing);
    expect(
      find.byKey(const Key('parte-dimension-width-decrease')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('parte-dimension-width-increase')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('parte-dimension-height-decrease')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('parte-dimension-height-increase')),
      findsOneWidget,
    );
    final blockPicker = tester.widget<DropdownButtonFormField<String>>(
      find
          .descendant(
            of: precisionCard,
            matching: find.byType(DropdownButtonFormField<String>),
          )
          .first,
    );
    blockPicker.onChanged!('intro');
    await tester.pump();
    final preparationRepository = PartePreparationRepository(db);
    final beforeMove = await preparationRepository.findForPredmet(predmet.id);
    final beforeIntro = ParteDraft.decode(
      beforeMove!.draftJson,
    ).blocks.firstWhere((block) => block.id == 'intro');
    Future<ParteBlockSpec> readIntro() async {
      final current = await preparationRepository.findForPredmet(predmet.id);
      return ParteDraft.decode(
        current!.draftJson,
      ).blocks.firstWhere((block) => block.id == 'intro');
    }

    Future<void> tapPosition(String direction) async {
      final button = find.byKey(Key('parte-position-$direction'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    final rightButton = find.byKey(const Key('parte-position-right'));
    expect(tester.widget<IconButton>(rightButton).tooltip, 'Desno 1 mm');
    await tapPosition('right');
    expect((await readIntro()).rect.x, beforeIntro.rect.x + 1);
    await tapPosition('right');
    expect((await readIntro()).rect.x, beforeIntro.rect.x + 2);
    await tapPosition('right');
    expect((await readIntro()).rect.x, beforeIntro.rect.x + 3);
    await tapPosition('left');
    expect((await readIntro()).rect.x, beforeIntro.rect.x + 2);
    await tapPosition('left');
    await tapPosition('left');
    final afterHorizontal = await readIntro();
    expect(afterHorizontal.rect.x, beforeIntro.rect.x);
    await tapPosition('up');
    expect((await readIntro()).rect.y, beforeIntro.rect.y - 1);
    await tapPosition('down');
    expect((await readIntro()).rect.y, beforeIntro.rect.y);
    for (final expectation in [
      (
        key: const Key('parte-dimension-width-decrease'),
        turns: 1,
        icon: Icons.unfold_less,
        tooltip: 'Suzi blok za 1 mm',
      ),
      (
        key: const Key('parte-dimension-width-increase'),
        turns: 1,
        icon: Icons.unfold_more,
        tooltip: 'Proširi blok za 1 mm',
      ),
      (
        key: const Key('parte-dimension-height-decrease'),
        turns: 0,
        icon: Icons.unfold_less,
        tooltip: 'Snizi blok za 1 mm',
      ),
      (
        key: const Key('parte-dimension-height-increase'),
        turns: 0,
        icon: Icons.unfold_more,
        tooltip: 'Povisi blok za 1 mm',
      ),
    ]) {
      final button = tester.widget<IconButton>(find.byKey(expectation.key));
      final rotated = button.icon as RotatedBox;
      expect(rotated.quarterTurns, expectation.turns);
      expect((rotated.child as Icon).icon, expectation.icon);
      expect(button.tooltip, expectation.tooltip);
    }
    blockPicker.onChanged!('name');
    await tester.pump();
    const dimensionActionKeys = [
      Key('parte-dimension-width-decrease'),
      Key('parte-dimension-width-increase'),
      Key('parte-dimension-height-decrease'),
      Key('parte-dimension-height-increase'),
    ];
    final dimensionActionTops = dimensionActionKeys
        .map((key) => tester.getTopLeft(find.byKey(key)).dy)
        .toList();
    expect(dimensionActionTops.toSet(), hasLength(1));
    final fontSizeField = tester.widget<TextField>(
      find.byKey(const Key('parte-font-size-state')),
    );
    expect(fontSizeField.decoration?.suffixText, 'pt');
    final fontSizeBefore = double.parse(fontSizeField.controller!.text);
    final increaseFont = find.byKey(
      const Key('parte-font-size-increment'),
      skipOffstage: false,
    );
    expect(
      tester.widget<IconButton>(increaseFont).tooltip,
      'Uvećaj font za 0,5 pt',
    );
    await tester.ensureVisible(increaseFont);
    await tester.tap(increaseFont);
    await tester.pumpAndSettle();
    final fontSizeAfter = double.parse(
      tester
          .widget<TextField>(find.byKey(const Key('parte-font-size-state')))
          .controller!
          .text,
    );
    expect(fontSizeAfter, closeTo(fontSizeBefore + 0.5, 0.01));
    final decrementFont = find.byKey(
      const Key('parte-font-size-decrement'),
      skipOffstage: false,
    );
    final currentPreparation = await PartePreparationRepository(
      db,
    ).findForPredmet(predmet.id);
    final nameSpec = ParteDraft.decode(
      currentPreparation!.draftJson,
    ).blocks.firstWhere((block) => block.id == 'name');
    fontSizeField.controller!.text = nameSpec.minimumFontSize.toString();
    tester
        .widget<TextField>(find.byKey(const Key('parte-font-size-state')))
        .onSubmitted!(nameSpec.minimumFontSize.toString());
    await tester.pumpAndSettle();
    final minimumValue = double.parse(
      tester
          .widget<TextField>(find.byKey(const Key('parte-font-size-state')))
          .controller!
          .text,
    );
    expect(minimumValue, nameSpec.minimumFontSize);
    expect(tester.widget<IconButton>(decrementFont).onPressed, isNull);
    final stateField = tester.widget<TextField>(
      find.byKey(const Key('parte-font-size-state')),
    );
    stateField.controller!.text = nameSpec.maximumFontSize.toString();
    stateField.onSubmitted!(nameSpec.maximumFontSize.toString());
    await tester.pumpAndSettle();
    final maximumValue = double.parse(
      tester
          .widget<TextField>(find.byKey(const Key('parte-font-size-state')))
          .controller!
          .text,
    );
    expect(maximumValue, greaterThan(minimumValue));
    final maximumPreparation = await PartePreparationRepository(
      db,
    ).findForPredmet(predmet.id);
    expect(
      ParteDraft.decode(
        maximumPreparation!.draftJson,
      ).blocks.firstWhere((block) => block.id == 'name').initialFontSize,
      nameSpec.maximumFontSize,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('parte-font-size-increment')),
          )
          .onPressed,
      isNull,
    );
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));
    expect(find.byKey(const Key('parte-font-size-state')), findsNothing);

    expect(find.textContaining('zona 175.0 × 115.0'), findsNothing);
    expect(find.textContaining('margina 5.0 × 5.0'), findsNothing);
    expect(find.text('Zona štampe – širina'), findsNothing);
    await _tapAfterVisible(tester, find.text('FORMAT I ZONA ŠTAMPE'));
    expect(find.text('Zona – X'), findsNothing);
    expect(find.text('Zona – Y'), findsNothing);
    expect(find.text('Zona štampe – širina'), findsOneWidget);
    expect(find.text('Zona štampe – visina'), findsOneWidget);
    final formatCard = find.byKey(const Key('parte-format-disclosure'));
    final formatCardRect = tester.getRect(formatCard);
    final pageWidthLabel = find.text('Strana – širina');
    expect(tester.getRect(pageWidthLabel).top, greaterThan(formatCardRect.top));
    final pageWidthField = tester.widget<TextField>(
      find.ancestor(of: pageWidthLabel, matching: find.byType(TextField)),
    );
    expect(pageWidthField.decoration?.suffixText, 'mm');
    expect(find.text('FORMAT I ZONA ŠTAMPE (mm)'), findsNothing);
    expect(find.text('SAČUVAJ PROFIL ZA ŠABLON'), findsOneWidget);
    expect(find.text('Korekcija celog PDF otiska'), findsNothing);
    expect(find.textContaining('min '), findsNothing);
    expect(tester.takeException(), isNull);
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));
    expect(find.text('PRECIZNO POMERANJE I STIL'), findsOneWidget);
    expect(find.byKey(const Key('parte-compact-font-row')), findsOneWidget);
    expect(find.byKey(const Key('parte-font-size-state')), findsOneWidget);
    final textTitleBottom = tester
        .getRect(find.text('TEKSTUALNI BLOKOVI'))
        .bottom;
    final introLabelTop = tester.getRect(find.text('Uvodna fraza')).top;
    expect(introLabelTop, greaterThan(textTitleBottom));
    final formatTitleBottom = tester
        .getRect(find.text('FORMAT I ZONA ŠTAMPE'))
        .bottom;
    final pageWidthLabelTop = tester.getRect(find.text('Strana – širina')).top;
    expect(pageWidthLabelTop, greaterThanOrEqualTo(formatTitleBottom + 8));
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
    expect(find.textContaining('stvarnoj veličini'), findsOneWidget);
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
    await _tapAfterVisible(tester, find.text('TEKSTUALNI BLOKOVI'));
    final nameField = find.byKey(
      const ValueKey('parte-text-name'),
      skipOffstage: false,
    );
    expect(nameField, findsOneWidget);
    const editedText =
        'VeryLongNameThatMustBeFittedToThePartePrintArea '
        'VeryLongSurnameThatMustBeFittedToThePartePrintArea';
    await tester.enterText(nameField, editedText);

    await _tapAfterVisible(tester, find.text('MEDIJI'));
    await _tapAfterVisible(tester, find.text('MEDIJI'));
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));
    expect(tester.widget<TextField>(nameField).controller!.text, editedText);
    await _tapAfterVisible(tester, find.text('PRECIZNO POMERANJE I STIL'));

    final cancelResetButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('OBRIŠI PRIPREMU I POČNI NOVU'),
        matching: find.byType(OutlinedButton),
      ),
    );
    cancelResetButton.onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Obriši pripremu i počni ponovo'), findsOneWidget);
    await tester.tap(find.text('ODUSTANI'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(nameField).controller!.text, editedText);

    final controllerBeforeMutation = tester
        .widget<TextField>(nameField)
        .controller;
    tester
        .widget<IconButton>(
          find.byKey(const Key('parte-dimension-width-increase')),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(nameField).controller,
      same(controllerBeforeMutation),
    );
    expect(tester.widget<TextField>(nameField).controller!.text, editedText);
    var preparation = await PartePreparationRepository(
      db,
    ).findForPredmet(predmet.id);
    expect(
      ParteDraft.decode(preparation!.draftJson).textByBlock['name'],
      isNot(editedText),
    );

    tester
        .widget<FilledButton>(find.byKey(const Key('parte-save-text')))
        .onPressed!();
    await tester.pumpAndSettle();
    preparation = await PartePreparationRepository(
      db,
    ).findForPredmet(predmet.id);
    expect(
      ParteDraft.decode(preparation!.draftJson).textByBlock['name'],
      editedText,
    );

    tester
        .widget<IconButton>(
          find.byKey(const Key('parte-dimension-width-increase')),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(nameField).controller!.text, editedText);
    preparation = await PartePreparationRepository(
      db,
    ).findForPredmet(predmet.id);
    expect(
      ParteDraft.decode(preparation!.draftJson).textByBlock['name'],
      editedText,
    );

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
    tester
        .widget<ParteEditorViewport>(find.byType(ParteEditorViewport))
        .onBlockSelected!('intro');
    await tester.pump();
    final fittedIntroSize = preview.plan.blocks
        .firstWhere((block) => block.id == 'intro')
        .fontSize;
    expect(
      double.parse(
        tester
            .widget<TextField>(
              find.byKey(
                const Key('parte-font-size-state'),
                skipOffstage: false,
              ),
            )
            .controller!
            .text,
      ),
      fittedIntroSize,
    );

    await (db.delete(
      db.partePripreme,
    )..where((row) => row.id.equals(preparation!.id))).go();
    tester
        .widget<IconButton>(
          find.byKey(
            const Key('parte-dimension-width-increase'),
            skipOffstage: false,
          ),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(nameField).controller!.text, editedText);
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

      await tester.tap(find.byKey(const Key('parte-predmet-selector')));
      await tester.pump();
      await tester.tap(find.text('Sačuvana Lice · DELETE-005').last);
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(ParteComposerScreen).evaluate().isNotEmpty) break;
      }
      await tester.pageBack();
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(ParteComposerScreen).evaluate().isEmpty) {
          break;
        }
      }
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find
            .byKey(ValueKey('parte-preparation-menu-${predmet.id}'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }

      final menu = find.byKey(ValueKey('parte-preparation-menu-${predmet.id}'));
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OBRIŠI SAČUVANU PRIPREMU'));
      await tester.pumpAndSettle();
      expect(find.textContaining('PREDMET i IRiU podaci'), findsOneWidget);
      await tester.tap(find.text('ODUSTANI'));
      await tester.pumpAndSettle();
      expect(await preparationRepository.findForPredmet(predmet.id), isNotNull);

      await tester.ensureVisible(menu);
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
      expect(find.byKey(const Key('parte-predmet-selector')), findsOneWidget);
      expect(
        find.byKey(ValueKey('parte-open-predmet-parte-${predmet.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('parte-preparation-menu-${predmet.id}')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Future<void> _tapAfterVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _insert(
  AppDatabase db,
  String broj,
  String ime, {
  required bool parte,
  String status = 'OTVOREN',
  String datumKreiranja = '2026-07-12T10:00:00.000',
}) => db
    .into(db.predmeti)
    .insert(
      PredmetiCompanion.insert(
        brojPredmeta: Value(broj),
        datumKreiranja: Value(datumKreiranja),
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
