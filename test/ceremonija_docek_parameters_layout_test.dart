import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/ceremonija_segment.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'PREDMET ceremony uses country-neutral label for international burial',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(
        db,
        docek: false,
        sahranaVanSrbije: true,
      );

      await tester.pumpWidget(
        MaterialApp(
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

      final label = find.text('Sahrana u inostranstvu');
      await tester.ensureVisible(label);
      expect(label, findsOneWidget);
      expect(find.text('Sahrana van Srbije'), findsNothing);
    },
  );

  for (final scenario in const <(TargetPlatform, double, String)>[
    (TargetPlatform.windows, 1200, 'Windows'),
    (TargetPlatform.android, 412, 'narrow Android'),
  ]) {
    testWidgets('${scenario.$3} shows MESTO, DATUM and VREME DOCEKA', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(scenario.$2, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _insertPredmet(db);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: scenario.$1),
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

      expect(find.widgetWithText(TextFormField, 'Beograd'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '19.07.2026.'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '14:30'), findsOneWidget);
      expect(find.text('MESTO DOČEKA'), findsOneWidget);
      expect(find.text('DATUM DOČEKA'), findsOneWidget);
      expect(find.text('VREME DOČEKA'), findsOneWidget);
      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: exception is FlutterError ? exception.toStringDeep() : null,
      );
    });
  }
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  bool docek = true,
  bool sahranaVanSrbije = false,
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('DOCEK-UI-001/2026'),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
          docekPosmrtnihOstataka: Value(docek),
          docekMesto: const Value('Beograd'),
          docekDatum: const Value('19.07.2026.'),
          docekVreme: const Value('14:30'),
          sahranaVanSrbije: Value(sahranaVanSrbije),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}
