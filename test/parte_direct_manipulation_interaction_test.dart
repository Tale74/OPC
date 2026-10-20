import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_print_profile_store.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_composer.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_composer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('resize hit targets stay 48 logical px at minimum zoom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final committed = <ParteRectMm>[];
    await _pumpViewport(
      tester,
      rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
      onCommit: (id, rect, {required moved}) async => committed.add(rect),
    );
    await tester.tap(find.byKey(const Key('parte-viewport-zoom-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parte-viewport-zoom-out')));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const Key('parte-viewport-zoom-value')))
          .data,
      '50%',
    );

    final nw = find.byKey(const ValueKey('parte-resize-hit-name-nw'));
    final ne = find.byKey(const ValueKey('parte-resize-hit-name-ne'));
    expect(tester.getRect(nw).width, closeTo(48, 0.01));
    expect(tester.getRect(nw).height, closeTo(48, 0.01));
    expect(tester.getRect(ne).width, closeTo(48, 0.01));

    final blockFinder = find.byKey(const ValueKey('parte-preview-block-name'));
    const localStart = Offset(48, 48);
    final detector = tester.widget<GestureDetector>(blockFinder);
    detector.onPanStart!(
      DragStartDetails(
        globalPosition: tester.getCenter(nw),
        localPosition: localStart,
      ),
    );
    detector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: tester.getCenter(nw) + const Offset(24, 12),
        localPosition: localStart + const Offset(48, 24),
        delta: const Offset(48, 24),
      ),
    );
    await tester.pump();
    expect(committed, isEmpty, reason: 'pointer updates are transient');
    tester.widget<GestureDetector>(blockFinder).onPanEnd!(DragEndDetails());
    await tester.pumpAndSettle();

    expect(committed, hasLength(1));
    expect(committed.single.right, closeTo(80, 0.01));
    expect(committed.single.bottom, closeTo(75, 0.01));
    expect(committed.single.width, lessThan(50));
    expect(committed.single.height, lessThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlapping minimum-size handles choose NW deterministically', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final committed = <ParteRectMm>[];
    await _pumpViewport(
      tester,
      rect: const ParteRectMm(x: 30, y: 35, width: 5, height: 5),
      onCommit: (id, rect, {required moved}) async => committed.add(rect),
    );

    final northwest = find.byKey(const ValueKey('parte-resize-hit-name-nw'));
    final northeast = find.byKey(const ValueKey('parte-resize-hit-name-ne'));
    final blockFinder = find.byKey(const ValueKey('parte-preview-block-name'));
    final detector = tester.widget<GestureDetector>(blockFinder);
    final nwCenter = tester.getCenter(northwest);
    final neCenter = tester.getCenter(northeast);
    final globalStart = Offset((nwCenter.dx + neCenter.dx) / 2, nwCenter.dy);
    final localStart = _localFromScreenPoint(
      tester,
      blockFinder,
      globalStart,
      1,
    );
    detector.onPanStart!(
      DragStartDetails(globalPosition: globalStart, localPosition: localStart),
    );
    detector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: globalStart - const Offset(30, 0),
        localPosition: localStart - const Offset(30, 0),
        delta: const Offset(-30, 0),
      ),
    );
    await tester.pump();
    tester.widget<GestureDetector>(blockFinder).onPanEnd!(DragEndDetails());
    await tester.pumpAndSettle();

    expect(committed, hasLength(1));
    expect(committed.single.right, closeTo(35, 0.01));
    expect(committed.single.bottom, closeTo(40, 0.01));
    expect(committed.single.width, greaterThan(5));
    expect(committed.single.height, 5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('corner anchors remain fixed across viewport zoom factors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final (zoom, zoomSteps) in <(double, int)>[
      (0.75, -1),
      (1, 0),
      (1.5, 2),
    ]) {
      final committed = <ParteRectMm>[];
      await _pumpViewport(
        tester,
        rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
        onCommit: (id, rect, {required moved}) async => committed.add(rect),
      );
      final zoomButton = find.byKey(
        Key(
          zoomSteps < 0 ? 'parte-viewport-zoom-out' : 'parte-viewport-zoom-in',
        ),
      );
      for (var step = 0; step < zoomSteps.abs(); step++) {
        await tester.tap(zoomButton);
        await tester.pumpAndSettle();
      }
      expect(
        tester
            .widget<Text>(find.byKey(const Key('parte-viewport-zoom-value')))
            .data,
        '${(zoom * 100).round()}%',
      );

      final preview = find.byType(PartePlanPreview);
      final viewportRect = tester.getRect(preview);
      const screenDx = 12.0;
      const screenDy = 9.0;
      for (final (handle, dx, dy) in <(String, double, double)>[
        ('nw', screenDx, screenDy),
      ]) {
        final hit = find.byKey(ValueKey('parte-resize-hit-name-$handle'));
        expect(tester.getRect(hit).width, closeTo(48, 0.02));
        expect(tester.getRect(hit).height, closeTo(48, 0.02));
        final block = find.byKey(const ValueKey('parte-preview-block-name'));
        final detector = tester.widget<GestureDetector>(block);
        final globalStart = tester.getCenter(hit);
        final localStart = _localFromScreenPoint(
          tester,
          block,
          globalStart,
          zoom,
        );
        detector.onPanStart!(
          DragStartDetails(
            globalPosition: globalStart,
            localPosition: localStart,
          ),
        );
        detector.onPanUpdate!(
          DragUpdateDetails(
            globalPosition: globalStart + Offset(dx, dy),
            localPosition: localStart + Offset(dx / zoom, dy / zoom),
            delta: Offset(dx / zoom, dy / zoom),
          ),
        );
        detector.onPanEnd!(DragEndDetails());
        await tester.pumpAndSettle();

        expect(committed, hasLength(1), reason: '$handle at $zoom×');
        final actual = committed.single;
        final expectedDx = dx * 210 / viewportRect.width;
        final expectedDy = dy * 297 / viewportRect.height;
        expect(actual.right, closeTo(80, 0.02));
        expect(actual.bottom, closeTo(75, 0.02));
        expect(actual.x, closeTo(30 + expectedDx, 0.02));
        expect(actual.y, closeTo(35 + expectedDy, 0.02));
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }

    for (final (handle, dx, dy) in <(String, double, double)>[
      ('nw', 12.0, 9.0),
      ('ne', -12.0, 9.0),
      ('sw', 12.0, -9.0),
      ('se', -12.0, -9.0),
    ]) {
      final committed = <ParteRectMm>[];
      await _pumpViewport(
        tester,
        rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
        onCommit: (id, rect, {required moved}) async => committed.add(rect),
      );
      final previewRect = tester.getRect(find.byType(PartePlanPreview));
      final hit = find.byKey(ValueKey('parte-resize-hit-name-$handle'));
      final block = find.byKey(const ValueKey('parte-preview-block-name'));
      final detector = tester.widget<GestureDetector>(block);
      final globalStart = tester.getCenter(hit);
      final localStart = _localFromScreenPoint(tester, block, globalStart, 1);
      detector.onPanStart!(
        DragStartDetails(
          globalPosition: globalStart,
          localPosition: localStart,
        ),
      );
      detector.onPanUpdate!(
        DragUpdateDetails(
          globalPosition: globalStart + Offset(dx, dy),
          localPosition: localStart + Offset(dx, dy),
          delta: Offset(dx, dy),
        ),
      );
      detector.onPanEnd!(DragEndDetails());
      await tester.pumpAndSettle();

      expect(committed, hasLength(1), reason: '$handle fixed opposite corner');
      final actual = committed.single;
      final expectedDx = dx * 210 / previewRect.width;
      final expectedDy = dy * 297 / previewRect.height;
      if (handle.contains('w')) {
        expect(actual.right, closeTo(80, 0.02));
        expect(actual.x, closeTo(30 + expectedDx, 0.02));
      } else {
        expect(actual.x, closeTo(30, 0.02));
        expect(actual.right, closeTo(80 + expectedDx, 0.02));
      }
      if (handle.contains('n')) {
        expect(actual.bottom, closeTo(75, 0.02));
        expect(actual.y, closeTo(35 + expectedDy, 0.02));
      } else {
        expect(actual.y, closeTo(35, 0.02));
        expect(actual.bottom, closeTo(75 + expectedDy, 0.02));
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('cancel and no-op clear preview without durable commit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final committed = <ParteRectMm>[];
    final previews = <ParteRectMm?>[];
    await _pumpViewport(
      tester,
      rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
      onPreview: (id, rect) => previews.add(rect),
      onCommit: (id, rect, {required moved}) async => committed.add(rect),
    );
    final nw = find.byKey(const ValueKey('parte-resize-hit-name-nw'));
    final block = find.byKey(const ValueKey('parte-preview-block-name'));
    final detector = tester.widget<GestureDetector>(block);
    final globalStart = tester.getCenter(nw);
    final localStart = _localFromScreenPoint(tester, block, globalStart, 1);
    detector.onPanStart!(
      DragStartDetails(globalPosition: globalStart, localPosition: localStart),
    );
    detector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: globalStart + const Offset(10, 8),
        localPosition: localStart + const Offset(10, 8),
        delta: const Offset(10, 8),
      ),
    );
    expect(previews.whereType<ParteRectMm>(), isNotEmpty);
    tester.widget<GestureDetector>(block).onPanCancel!();
    await tester.pump();
    expect(committed, isEmpty);
    expect(previews.last, isNull);

    final unchangedStart = tester.getCenter(nw);
    final unchangedLocal = _localFromScreenPoint(
      tester,
      block,
      unchangedStart,
      1,
    );
    final unchangedDetector = tester.widget<GestureDetector>(block);
    unchangedDetector.onPanStart!(
      DragStartDetails(
        globalPosition: unchangedStart,
        localPosition: unchangedLocal,
      ),
    );
    unchangedDetector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: unchangedStart,
        localPosition: unchangedLocal,
        delta: Offset.zero,
      ),
    );
    unchangedDetector.onPanEnd!(DragEndDetails());
    await tester.pumpAndSettle();
    expect(committed, isEmpty);
    expect(previews.last, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'locked ratio resize preserves source ratio and opposite anchor',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final committed = <ParteRectMm>[];
      await _pumpViewport(
        tester,
        rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
        lockAspectRatio: true,
        sourceAspectRatio: 1.25,
        onCommit: (id, rect, {required moved}) async => committed.add(rect),
      );

      final hit = find.byKey(const ValueKey('parte-resize-hit-name-nw'));
      final block = find.byKey(const ValueKey('parte-preview-block-name'));
      final detector = tester.widget<GestureDetector>(block);
      final globalStart = tester.getCenter(hit);
      final localStart = _localFromScreenPoint(tester, block, globalStart, 1);
      detector.onPanStart!(
        DragStartDetails(
          globalPosition: globalStart,
          localPosition: localStart,
        ),
      );
      detector.onPanUpdate!(
        DragUpdateDetails(
          globalPosition: globalStart + const Offset(1000, 0),
          localPosition: localStart + const Offset(1000, 0),
          delta: const Offset(1000, 0),
        ),
      );
      detector.onPanEnd!(DragEndDetails());
      await tester.pumpAndSettle();

      expect(committed, hasLength(1));
      expect(committed.single.width, closeTo(6.25, 0.01));
      expect(committed.single.height, closeTo(5, 0.01));
      expect(
        committed.single.width / committed.single.height,
        closeTo(1.25, 0.001),
      );
      expect(committed.single.right, closeTo(80, 0.01));
      expect(committed.single.bottom, closeTo(75, 0.01));
      expect(committed.single.x, greaterThan(30));
      expect(committed.single.y, greaterThan(35));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('body drag translates without resizing and clamps to safe area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final committed = <(ParteRectMm, bool)>[];
    await _pumpViewport(
      tester,
      rect: const ParteRectMm(x: 30, y: 35, width: 50, height: 40),
      onCommit: (id, rect, {required moved}) async =>
          committed.add((rect, moved)),
    );
    final block = find.byKey(const ValueKey('parte-preview-block-name'));
    final detector = tester.widget<GestureDetector>(block);
    final globalStart = tester.getRect(block).center;
    final localStart = _localFromScreenPoint(tester, block, globalStart, 1);
    detector.onPanStart!(
      DragStartDetails(globalPosition: globalStart, localPosition: localStart),
    );
    detector.onPanUpdate!(
      DragUpdateDetails(
        globalPosition: globalStart + const Offset(-10000, -10000),
        localPosition: localStart + const Offset(-10000, -10000),
        delta: const Offset(-10000, -10000),
      ),
    );
    detector.onPanEnd!(DragEndDetails());
    await tester.pumpAndSettle();

    expect(committed, hasLength(1));
    final (rect, moved) = committed.single;
    expect(moved, isTrue);
    expect(rect.width, 50);
    expect(rect.height, 40);
    expect(rect.x, greaterThanOrEqualTo(5));
    expect(rect.y, greaterThanOrEqualTo(5));
    expect(rect.right, lessThanOrEqualTo(205));
    expect(rect.bottom, lessThanOrEqualTo(292));
    expect(rect.x, isNot(30));
    expect(rect.y, isNot(35));
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo slider persists once at end and zero times on cancel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final updates = _PartePreparationUpdateCounter();
    final db = AppDatabase.forTesting(
      NativeDatabase.memory().interceptWith(updates),
    );
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Synthetic adviser',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-10-04T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('SLIDER-TEST-001'),
            datumKreiranja: const Value('2026-10-04T10:00:00.000'),
            ime: const Value('Synthetic'),
            prezime: const Value('Test'),
            partePotrebna: const Value(true),
            status: const Value('OTVOREN'),
          ),
        );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.brojPredmeta.equals('SLIDER-TEST-001'))).getSingle();
    await tester.pumpWidget(
      MaterialApp(
        home: ParteComposerScreen(
          predmetId: predmet.id,
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
          printProfileStore: _MemoryPrintProfileStore(),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('TEKSTUALNI BLOKOVI').evaluate().isNotEmpty) break;
    }
    final disclosure = find.byKey(const Key('parte-precision-disclosure'));
    expect(
      disclosure,
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .join(' | '),
    );
    await tester.ensureVisible(disclosure);
    await tester.tap(find.text('PRECIZNO POMERANJE I STIL'));
    await tester.pumpAndSettle();
    final blockSelector = find
        .descendant(
          of: disclosure,
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .first;
    await tester.ensureVisible(blockSelector);
    await tester.tap(blockSelector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fotografija').last);
    await tester.pumpAndSettle();
    final slider = find.byKey(const ValueKey('parte-effect-slider-brightness'));
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();

    updates.count = 0;
    var sliderRect = tester.getRect(slider);
    var gesture = await tester.startGesture(
      Offset(sliderRect.left + 24, sliderRect.center.dy),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    expect(updates.count, 0, reason: 'slider samples are transient');
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(updates.count, 0, reason: 'cancelled slider gesture is not durable');
    expect(tester.widget<Slider>(slider).value, closeTo(1, 0.001));

    sliderRect = tester.getRect(slider);
    gesture = await tester.startGesture(sliderRect.center);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(updates.count, 0, reason: 'no-op slider interaction must not write');

    final repository = PartePreparationRepository(db);
    final before = await repository.findForPredmet(predmet.id);
    final beforeBrightness = ParteDraft.decode(
      before!.draftJson,
    ).blocks.firstWhere((block) => block.id == 'photo').brightness;

    sliderRect = tester.getRect(slider);
    gesture = await tester.startGesture(
      Offset(sliderRect.left + 24, sliderRect.center.dy),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(90, 0));
    await tester.pump();
    expect(updates.count, 0, reason: 'drag samples do not update the database');
    await gesture.up();
    await tester.pumpAndSettle();

    expect(updates.count, 1, reason: 'one completed drag performs one UPDATE');
    final after = await repository.findForPredmet(predmet.id);
    final afterBrightness = ParteDraft.decode(
      after!.draftJson,
    ).blocks.firstWhere((block) => block.id == 'photo').brightness;
    expect(afterBrightness, isNot(beforeBrightness));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected block diagonal drag beats page scroll and writes once per commit',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final updates = _PartePreparationUpdateCounter();
      final db = AppDatabase.forTesting(
        NativeDatabase.memory().interceptWith(updates),
      );
      addTearDown(db.close);
      final actorId = await db
          .into(db.korisnici)
          .insert(
            KorisniciCompanion.insert(
              imePrezime: 'Synthetic adviser',
              uloga: 'SAVETNIK',
              pinHash: 'synthetic-hash',
              datumKreiranja: '2026-10-05T10:00:00.000',
            ),
          );
      final actor = await (db.select(
        db.korisnici,
      )..where((row) => row.id.equals(actorId))).getSingle();
      await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('DMI-DB-TEST-001'),
              datumKreiranja: const Value('2026-10-05T10:00:00.000'),
              ime: const Value('Synthetic'),
              prezime: const Value('Test'),
              partePotrebna: const Value(true),
              status: const Value('OTVOREN'),
            ),
          );
      final predmet =
          await (db.select(db.predmeti)
                ..where((row) => row.brojPredmeta.equals('DMI-DB-TEST-001')))
              .getSingle();
      const entitlement = OpcEntitlementPolicy.fromSource(
        OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
      );
      final repository = PartePreparationRepository(db);
      final preparation = await repository.initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: entitlement,
      );
      final draft = ParteDraft.decode(preparation.draftJson);
      final selected = draft.blocks.firstWhere((block) => block.id == 'name');
      final initialRect = selected.rect;
      final plan = ParteRenderPlan(
        widthMm: draft.widthMm,
        heightMm: draft.heightMm,
        horizontalMarginMm: draft.horizontalMarginMm,
        verticalMarginMm: draft.verticalMarginMm,
        blocks: [
          ParteRenderBlock(
            id: selected.id,
            kind: selected.kind,
            rect: selected.rect,
            layer: selected.layer,
            lines: [draft.textByBlock[selected.id] ?? 'Synthetic text'],
            fontSize: selected.initialFontSize,
            bold: selected.bold,
            alignment: selected.alignment,
            fontFamily: selected.fontFamily,
            horizontalScale: selected.horizontalScale,
            brightness: selected.brightness,
            contrast: selected.contrast,
            sharpness: selected.sharpness,
            grayscale: selected.grayscale,
            border: selected.border,
            borderWidth: selected.borderWidth,
            imageShape: selected.imageShape,
            minimumFontSize: selected.minimumFontSize,
            maximumFontSize: selected.maximumFontSize,
            sourceAspectRatio: selected.sourceAspectRatio,
          ),
        ],
        warnings: const [],
        blockers: const [],
        fingerprint: 'db-write-test',
      );
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      var selectedBlockId = 'intro';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  StatefulBuilder(
                    builder: (context, setState) => SizedBox(
                      height: 620,
                      child: ParteEditorViewport(
                        plan: plan,
                        mediaStore: ParteMediaStore(),
                        selectedBlockId: selectedBlockId,
                        onBlockSelected: (id) => setState(() {
                          selectedBlockId = id;
                        }),
                        onBlockRectPreview: (_, _) {},
                        onBlockRectCommitted:
                            (id, rect, {required moved}) async {
                              final nextDraft = draft.copyWith(
                                blocks: draft.blocks
                                    .map(
                                      (block) => block.id == id
                                          ? block.copyWith(rect: rect)
                                          : block,
                                    )
                                    .toList(growable: false),
                              );
                              await repository.updateDraft(
                                preparationId: preparation.id,
                                draft: nextDraft,
                                actor: actor,
                                entitlement: entitlement,
                              );
                            },
                      ),
                    ),
                  ),
                  const SizedBox(height: 700),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      updates.count = 0;
      final block = find.byKey(const ValueKey('parte-preview-block-name'));
      await tester.ensureVisible(block);
      final initialScrollOffset = scrollController.offset;
      final start = tester.getCenter(block);
      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveBy(const Offset(44, 28));
      await tester.pump();
      expect(updates.count, 0, reason: 'move samples stay transient');
      expect(scrollController.offset, closeTo(initialScrollOffset, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(updates.count, 1, reason: 'completed move writes one UPDATE');
      final afterMove = ParteDraft.decode(
        (await repository.findForPredmet(predmet.id))!.draftJson,
      ).blocks.firstWhere((block) => block.id == 'name').rect;
      expect(afterMove.x, isNot(initialRect.x));
      expect(afterMove.y, isNot(initialRect.y));
      expect(selectedBlockId, 'name');

      for (final delta in const [Offset(38, 0), Offset(0, 34)]) {
        await tester.ensureVisible(block);
        final beforeAxisScroll = scrollController.offset;
        updates.count = 0;
        final axisDrag = await tester.startGesture(tester.getCenter(block));
        await tester.pump();
        await axisDrag.moveBy(delta);
        await tester.pump();
        expect(updates.count, 0, reason: 'body drag samples stay transient');
        expect(scrollController.offset, closeTo(beforeAxisScroll, 0.01));
        await axisDrag.up();
        await tester.pumpAndSettle();
        expect(updates.count, 1, reason: 'axis move commits one UPDATE');
        final nextRect = ParteDraft.decode(
          (await repository.findForPredmet(predmet.id))!.draftJson,
        ).blocks.firstWhere((block) => block.id == 'name').rect;
        if (delta.dx != 0) {
          expect(nextRect.x, isNot(initialRect.x));
          expect(nextRect.y, initialRect.y);
        } else {
          expect(nextRect.x, initialRect.x);
          expect(nextRect.y, isNot(initialRect.y));
        }
        expect(nextRect.width, initialRect.width);
        expect(nextRect.height, initialRect.height);
      }

      updates.count = 0;
      final pageScrollBefore = scrollController.offset;
      final blankPageDrag = await tester.startGesture(const Offset(210, 840));
      await tester.pump();
      await blankPageDrag.moveBy(const Offset(0, -120));
      await tester.pump();
      expect(scrollController.offset, greaterThan(pageScrollBefore));
      expect(updates.count, 0, reason: 'blank-page scrolling writes nothing');
      await blankPageDrag.up();
      await tester.pumpAndSettle();

      updates.count = 0;
      final northwest = find.byKey(const ValueKey('parte-resize-hit-name-nw'));
      await tester.ensureVisible(northwest);
      final beforeResizeScroll = scrollController.offset;
      final resize = await tester.startGesture(tester.getCenter(northwest));
      await tester.pump();
      await resize.moveBy(const Offset(22, 16));
      await tester.pump();
      expect(updates.count, 0, reason: 'resize samples stay transient');
      expect(scrollController.offset, closeTo(beforeResizeScroll, 0.01));
      await resize.up();
      await tester.pumpAndSettle();
      expect(updates.count, 1, reason: 'completed resize writes one UPDATE');
      final afterResize = ParteDraft.decode(
        (await repository.findForPredmet(predmet.id))!.draftJson,
      ).blocks.firstWhere((block) => block.id == 'name').rect;
      expect(afterResize.width, lessThan(afterMove.width));
      expect(afterResize.height, lessThan(afterMove.height));
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpViewport(
  WidgetTester tester, {
  required ParteRectMm rect,
  bool lockAspectRatio = false,
  double? sourceAspectRatio,
  required Future<void> Function(
    String id,
    ParteRectMm rect, {
    required bool moved,
  })
  onCommit,
  void Function(String id, ParteRectMm? rect)? onPreview,
}) async {
  const plan = ParteRenderPlan(
    widthMm: 210,
    heightMm: 297,
    horizontalMarginMm: 5,
    verticalMarginMm: 5,
    blocks: [
      ParteRenderBlock(
        id: 'name',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 30, y: 35, width: 50, height: 40),
        layer: 0,
        lines: ['Test identitet'],
      ),
    ],
    warnings: [],
    blockers: [],
    fingerprint: 'test',
  );
  final testPlan = ParteRenderPlan(
    widthMm: plan.widthMm,
    heightMm: plan.heightMm,
    horizontalMarginMm: plan.horizontalMarginMm,
    verticalMarginMm: plan.verticalMarginMm,
    blocks: [
      ParteRenderBlock(
        id: 'name',
        kind: ParteBlockKind.text,
        rect: rect,
        layer: 0,
        lines: ['Test identitet'],
        sourceAspectRatio: sourceAspectRatio,
      ),
    ],
    warnings: plan.warnings,
    blockers: plan.blockers,
    fingerprint: plan.fingerprint,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ParteEditorViewport(
          plan: testPlan,
          mediaStore: ParteMediaStore(),
          selectedBlockId: 'name',
          lockAspectRatios: {'name': lockAspectRatio},
          onBlockRectPreview: onPreview ?? (_, _) {},
          onBlockRectCommitted: onCommit,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Offset _localFromScreenPoint(
  WidgetTester tester,
  Finder block,
  Offset screenPoint,
  double zoom,
) {
  final topLeft = tester.getTopLeft(block);
  return (screenPoint - topLeft) / zoom;
}

class _PartePreparationUpdateCounter extends QueryInterceptor {
  int count = 0;

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (statement.toLowerCase().contains('update "parte_pripreme"')) count++;
    return executor.runUpdate(statement, args);
  }
}

class _MemoryPrintProfileStore extends PartePrintProfileStore {
  _MemoryPrintProfileStore()
    : super(rootDirectory: () async => Directory.current);

  @override
  Future<PartePrintProfile> loadForTemplate(String templateId) async =>
      const PartePrintProfile();

  @override
  Future<void> saveForTemplate(
    String templateId,
    PartePrintProfile profile,
  ) async {}
}
