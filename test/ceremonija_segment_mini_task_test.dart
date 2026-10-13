import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/ceremonija_segment.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('GRADSKO remains on one line across responsive layouts', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final presentation in const [
      (Size(412, 900), TargetPlatform.android),
      (Size(947, 900), TargetPlatform.android),
      (Size(947, 900), TargetPlatform.windows),
    ]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = presentation.$1;
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db);

      await tester.pumpWidget(
        _segmentApp(predmet, db, platform: presentation.$2, textScale: 1.25),
      );
      await tester.pump();

      final label = find.text('GRADSKO');
      expect(label, findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(label).size.height,
        lessThan(32),
        reason: 'The label must not wrap to a second line at 1.25 text scale.',
      );
      expect(find.text('LOKALNO'), findsOneWidget);
      expect(find.text('GROBLJE'), findsOneWidget);
      final layoutException = tester.takeException();
      final layoutDetails = layoutException is FlutterError
          ? layoutException.diagnostics
                .map((diagnostic) => diagnostic.toDescription())
                .join('\n')
          : '$layoutException';
      expect(
        layoutException,
        isNull,
        reason:
            'Presentation ${presentation.$1} / ${presentation.$2}: '
            '$layoutDetails\n${_renderFlexOverflowSummary(tester)}',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'Wide GROBLJE label and input align with TIP GROBLJA label and control',
    (tester) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final platform in const [
        TargetPlatform.android,
        TargetPlatform.windows,
      ]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(947, 900);
        final db = createTestDatabase();
        addTearDown(db.close);
        const longCemetery = 'NOVOBEŽANIJSKO';
        final predmet = await _insertPredmet(db, groblje: longCemetery);

        await tester.pumpWidget(
          _segmentApp(predmet, db, platform: platform, textScale: 1.25),
        );
        await tester.pump();

        final grobljeLabel = find.text('GROBLJE');
        final tipLabel = find.text('TIP GROBLJA');
        final field = find.byKey(const ValueKey('ceremonija-groblje-field'));
        final control = find.byKey(
          const ValueKey('ceremonija-tip-groblja-control'),
        );
        expect(grobljeLabel, findsOneWidget);
        expect(tipLabel, findsOneWidget);
        expect(field, findsOneWidget);
        expect(control, findsOneWidget);

        final grobljeLabelRect = tester.getRect(grobljeLabel);
        final tipLabelRect = tester.getRect(tipLabel);
        final fieldRect = tester.getRect(field);
        final controlRect = tester.getRect(control);
        expect(
          (grobljeLabelRect.top - tipLabelRect.top).abs(),
          lessThanOrEqualTo(1),
          reason: 'The two field labels must share a baseline row.',
        );
        expect(
          (fieldRect.top - controlRect.top).abs(),
          lessThanOrEqualTo(1),
          reason: 'The input and segmented control must start at the same y.',
        );
        final textField = tester.widget<TextFormField>(field);
        expect(textField.controller?.text, longCemetery);
        expect(find.text('GRADSKO'), findsOneWidget);
        expect(find.text('LOKALNO'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets('Narrow GROBLJE invites input only while empty', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CeremonijuSegment(
              initialData: predmet,
              predmetId: predmet.id,
              iriuRepo: IriuRepository(db),
              enabled: true,
              onSave: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final cemeteryField = find.widgetWithText(TextFormField, 'GROBLJE');
    expect(cemeteryField, findsOneWidget);
    expect(tester.getSize(cemeteryField).width, lessThanOrEqualTo(280));
    var field = tester.widget<TextField>(
      find.descendant(of: cemeteryField, matching: find.byType(TextField)),
    );
    expect(field.decoration?.filled, isTrue);
    expect(
      field.decoration?.fillColor,
      ThemeData(
        platform: TargetPlatform.android,
      ).colorScheme.secondaryContainer,
    );

    await tester.enterText(cemeteryField, 'Novo groblje');
    await tester.pump();
    field = tester.widget<TextField>(
      find.descendant(of: cemeteryField, matching: find.byType(TextField)),
    );
    expect(field.decoration?.filled, isFalse);
    expect(field.decoration?.fillColor, isNull);
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('OPELO save does not pre-materialize its SCENARIO IRiU row', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db);
    PredmetiCompanion? saved;

    await tester.pumpWidget(
      _segmentApp(predmet, db, onSave: (companion) => saved = companion),
    );
    await tester.pump();

    await tester.tap(find.text('Opelo'));
    await tester.pump(const Duration(milliseconds: 900));

    expect(saved, isNotNull);
    expect(saved!.opelo.value, 'DA');
    final opeloRows = await (db.select(
      db.iriu,
    )..where((row) => row.interniNaziv.equals('KOMPLET_ZA_OPELO'))).get();
    final predmetOpeloRows = opeloRows
        .where((row) => row.predmetId == predmet.id)
        .toList();
    expect(predmetOpeloRows, isEmpty);
  });

  testWidgets('VRSTA CEREMONIJE offers only the four main ceremony types', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(db);

    await tester.pumpWidget(_segmentApp(predmet, db));
    await tester.pump();

    final ceremonyDropdown = find.byType(DropdownButtonFormField<String>);
    expect(ceremonyDropdown, findsOneWidget);
    await tester.tap(ceremonyDropdown);
    await tester.pumpAndSettle();

    for (final label in const [
      'Sahrana',
      'Sahrana ekspres',
      'Kremacija',
      'Kremacija ekspres',
    ]) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }
    expect(find.text('Smeštaj urne'), findsNothing);
    expect(find.text('Rasipanje pepela'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'legacy ceremony values remain readable but are not offered again',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db, vrstaCeremonije: 'SMESTAJ_URNE');

      await tester.pumpWidget(_segmentApp(predmet, db));
      await tester.pump();

      expect(find.text('Smeštaj urne'), findsOneWidget);
      final ceremonyDropdown = find.byType(DropdownButtonFormField<String>);
      expect(ceremonyDropdown, findsOneWidget);
      await tester.tap(ceremonyDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Smeštaj urne'), findsOneWidget);
      expect(find.text('Rasipanje pepela'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cremation keeps urn placement options and separates ceremony and urn cemeteries',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        vrstaCeremonije: 'KREMACIJA',
        groblje: 'Gradsko krematorijumsko groblje',
        grobljePolaganjaUrne: 'Novo urno groblje',
        tipPolaganja: 'KOLUMBARIJUM',
      );

      await tester.pumpWidget(_segmentApp(predmet, db));
      await tester.pump();

      expect(find.text('TIP POLAGANJA URNE'), findsOneWidget);
      expect(find.text('GROBLJE'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Gradsko krematorijumsko groblje'),
        findsOneWidget,
      );
      expect(find.text('GROBLJE ZA POLAGANJE URNE'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Novo urno groblje'),
        findsOneWidget,
      );

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(2));
      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();
      for (final label in const [
        'Naknadno',
        'Grob',
        'Grobnica',
        'Kolumbarijum',
        'Rozarijum',
        'Rasipanje pepela',
      ]) {
        expect(find.text(label), findsAtLeastNWidgets(1));
      }
      expect(tester.takeException(), isNull);
    },
  );

  test('LISTA PDF includes GROBLJE and urn placement for cremation', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _insertPredmet(
      db,
      vrstaCeremonije: 'KREMACIJA',
      groblje: 'Gradsko krematorijumsko groblje',
      grobljePolaganjaUrne: 'Novo urno groblje',
      tipPolaganja: 'KOLUMBARIJUM',
      urnaParcela: '12',
      urnaBroj: '8',
    );
    final firma = await db.select(db.firmaPodaci).getSingle();
    final app = await db.select(db.appPodesavanja).getSingle();
    final prepared = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: const [],
      firma: firma,
      app: app,
      savetnik: null,
    );
    final rows = prepared.ceremonySection.columns.expand((column) => column);

    final groblje = rows.singleWhere((row) => row.label == 'Groblje');
    expect(groblje.value, 'Gradsko krematorijumsko groblje');
    expect(
      rows.singleWhere((row) => row.label == 'Groblje za polaganje urne').value,
      'Novo urno groblje',
    );
    expect(
      rows.singleWhere((row) => row.label == 'Tip polaganja urne').value,
      'Kolumbarijum',
    );
    expect(rows.singleWhere((row) => row.label == 'Parcela').value, '12');
    expect(rows.singleWhere((row) => row.label == 'Broj').value, '8');
  });

  testWidgets(
    'cremation express saves urn cemetery separately from ceremony cemetery',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        vrstaCeremonije: 'KREMACIJA_EKSPRES',
        groblje: 'Groblje ceremonije A',
        grobljePolaganjaUrne: 'Groblje urne B',
      );
      PredmetiCompanion? saved;

      await tester.pumpWidget(
        _segmentApp(predmet, db, onSave: (companion) => saved = companion),
      );
      await tester.pump();

      expect(find.text('GROBLJE ZA POLAGANJE URNE'), findsOneWidget);
      final urnCemetery = find.widgetWithText(TextFormField, 'Groblje urne B');
      expect(urnCemetery, findsOneWidget);
      await tester.enterText(urnCemetery, 'Groblje urne C');
      await tester.pump(const Duration(milliseconds: 900));

      expect(saved, isNotNull);
      expect(saved!.groblje.value, 'Groblje ceremonije A');
      expect(saved!.grobljePolaganjaUrne.value, 'Groblje urne C');
      await (db.update(
        db.predmeti,
      )..where((p) => p.id.equals(predmet.id))).write(saved!);
      final reloaded = await (db.select(
        db.predmeti,
      )..where((p) => p.id.equals(predmet.id))).getSingle();
      expect(reloaded.groblje, 'Groblje ceremonije A');
      expect(reloaded.grobljePolaganjaUrne, 'Groblje urne C');
    },
  );
}

String _renderFlexOverflowSummary(WidgetTester tester) {
  final rows = tester
      .renderObjectList<RenderFlex>(find.byType(Row))
      .toList(growable: false);
  final overflowingChildren = <String>[];
  for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) {
    final row = rows[rowIndex];
    var child = row.firstChild;
    while (child != null) {
      final data = child.parentData! as FlexParentData;
      final right = data.offset.dx + child.size.width;
      if (right > row.size.width + 0.5) {
        overflowingChildren.add(
          'Row#$rowIndex width=${row.size.width}, childWidth=${child.size.width}, '
          'childX=${data.offset.dx}, right=$right\n${row.toStringDeep()}',
        );
      }
      child = row.childAfter(child);
    }
  }
  return 'Overflowing row children: ${overflowingChildren.join('; ')}';
}

Widget _segmentApp(
  PredmetiData predmet,
  AppDatabase db, {
  void Function(PredmetiCompanion)? onSave,
  TargetPlatform platform = TargetPlatform.windows,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: CeremonijuSegment(
              initialData: predmet,
              predmetId: predmet.id,
              iriuRepo: IriuRepository(db),
              enabled: true,
              onSave: onSave ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  String vrstaCeremonije = 'SAHRANA',
  String groblje = '',
  String grobljePolaganjaUrne = '',
  String tipPolaganja = 'NAKNADNO',
  String urnaParcela = '',
  String urnaBroj = '',
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('CEREM-002/2026'),
          datumKreiranja: const Value('2026-08-05T10:00:00.000'),
          vrstaCeremonije: Value(vrstaCeremonije),
          groblje: Value(groblje),
          grobljePolaganjaUrne: Value(grobljePolaganjaUrne),
          tipPolaganja: Value(tipPolaganja),
          urnaParcela: Value(urnaParcela),
          urnaBroj: Value(urnaBroj),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}
