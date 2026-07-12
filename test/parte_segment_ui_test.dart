import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/parte_segment.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'narrow PARTE not-required flow is scroll-safe and has no entry',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmet = await _predmet(db, partePotrebna: false);

      await tester.pumpWidget(
        _wrap(
          ParteSegment(
            initialData: predmet,
            enabled: true,
            onSave: (_) {},
            advancedParteAvailable: true,
            onOpenPreparation: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PARTE su potrebne'), findsOneWidget);
      expect(find.textContaining('Porodica ne želi PARTE'), findsOneWidget);
      expect(find.text('OTVORI PRIPREMU ZA ŠTAMPU'), findsNothing);
      expect(tester.takeException(), equals(null));
    },
  );

  testWidgets('OSNOVNI lock is visible and does not delete PREDMET fields', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _predmet(db, partePotrebna: true);

    await tester.pumpWidget(
      _wrap(
        ParteSegment(
          initialData: predmet,
          enabled: true,
          onSave: (_) {},
          advancedParteAvailable: false,
          onOpenPreparation: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('nije dostupna u aktivnom paketu'),
      findsOneWidget,
    );
    expect(find.text('OTVORI PRIPREMU ZA ŠTAMPU'), findsNothing);
    expect(find.text('Sintetički ožalošćeni'), findsOneWidget);
  });

  testWidgets('entitled PARTE shows one controlled composer entry', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmet = await _predmet(db, partePotrebna: true);
    var opened = false;

    await tester.pumpWidget(
      _wrap(
        ParteSegment(
          initialData: predmet,
          enabled: true,
          onSave: (_) {},
          advancedParteAvailable: true,
          onOpenPreparation: () => opened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OTVORI PRIPREMU ZA ŠTAMPU'));

    expect(opened, isTrue);
    expect(find.text('PREVIEW PARTE'), findsNothing);
    expect(find.textContaining('WYSIWYG preview'), findsOneWidget);
  });
}

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(padding: const EdgeInsets.all(8), child: child),
  ),
);

Future<PredmetiData> _predmet(
  AppDatabase db, {
  required bool partePotrebna,
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('PARTE-UI-001'),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
          ime: const Value('Sintetičko'),
          prezime: const Value('Lice'),
          partePotrebna: Value(partePotrebna),
          ozaloseni: const Value('Sintetički ožalošćeni'),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}
