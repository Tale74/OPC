import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/ceremonija_segment.dart';

import 'test_bootstrap.dart';

void main() {
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

Widget _segmentApp(
  PredmetiData predmet,
  AppDatabase db, {
  void Function(PredmetiCompanion)? onSave,
}) {
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.windows),
    home: Scaffold(
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
