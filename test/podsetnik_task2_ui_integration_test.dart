import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podsetnik/presentation/podsetnik_module_screen.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_text.dart';

import 'test_bootstrap.dart';

void main() {
  test('primary notification uses PREDMET GROBLJE and defensive fallback', () {
    expect(
      buildCeremonyReminderText(
        ceremonyType: 'SAHRANA',
        deceasedFirstName: 'Ana',
        deceasedLastName: 'Jovanović',
        ceremonyDate: '30.08.2026.',
        ceremonyTime: '12:00',
        ceremonyLocation: 'Novo groblje',
      ),
      'SAHRANA ZA Ana Jovanović JE 30.08.2026. U 12:00 '
      'NA GROBLJU Novo groblje. DOVRŠITE NEOPHODNE PRIPREME.',
    );
    expect(
      buildCeremonyReminderText(
        ceremonyType: 'KREMACIJA',
        deceasedFirstName: 'Ana',
        deceasedLastName: 'Jovanović',
        ceremonyDate: '30.08.2026.',
        ceremonyTime: '12:00',
        ceremonyLocation: '',
      ),
      contains('NA GROBLJU Groblje nije uneto.'),
    );
  });

  test('LISTA/PDF builder exposes the same conceptual obligation checklist', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final id = await db.into(db.predmeti).insert(
      const PredmetiCompanion(
        brojPredmeta: Value('TASK2-PDF'),
        opelo: Value('DA'),
        obavestitiSvestenika: Value('DA'),
        groblje: Value('Novo groblje'),
      ),
    );
    final predmet = await (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
    final firma = await (db.select(db.firmaPodaci)..where((p) => p.id.equals(1))).getSingle();
    final app = await (db.select(db.appPodesavanja)..where((p) => p.id.equals(1))).getSingle();
    final data = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: const [],
      firma: firma,
      app: app,
      savetnik: null,
    );
    expect(data.podsetnikChecklist.map((item) => item.label), contains('OPELO'));
    expect(data.podsetnikChecklist.map((item) => item.label), contains('Obavestiti sveštenika'));
  });

  testWidgets('PODSETNIK renders ceremony header and OBAVEZE I NAPOMENE', (tester) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
      await db.close();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    });
    final id = await db.into(db.predmeti).insert(
      const PredmetiCompanion(
        brojPredmeta: Value('TASK2-UI'),
        ime: Value('Ana'),
        prezime: Value('Jovanović'),
        vrstaCeremonije: Value('SAHRANA'),
        datumCeremonije: Value('30.08.2026.'),
        vremeCeremonije: Value('12:00'),
        groblje: Value('Novo groblje'),
        opelo: Value('DA'),
        obavestitiSvestenika: Value('DA'),
      ),
    );
    final predmet = await (db.select(db.predmeti)
          ..where((row) => row.id.equals(id)))
        .getSingle();
    await tester.pumpWidget(MaterialApp(
      home: PodsetnikPredmetSettings(predmet: predmet, database: db),
    ));
    await tester.pumpAndSettle();
    expect(find.text('ČINJENICE CEREMONIJE'), findsOneWidget);
    expect(find.text('OBAVEZE I NAPOMENE'), findsOneWidget);
    expect(find.byKey(const Key('podsetnik-ceremony-header')), findsOneWidget);
    expect(find.text('SAHRANA – 30.08.2026. – 12:00 – Novo groblje'), findsOneWidget);
    expect(find.text('SAHRANA · 30.08.2026. · 12:00 · Novo groblje'), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const Key('podsetnik-ceremony-header')),
        matching: find.byType(CheckboxListTile),
      ),
      findsNothing,
    );
    expect(find.text('OPELO'), findsOneWidget);
    expect(find.byKey(const Key('podsetnik-general-note')), findsOneWidget);
  });

  testWidgets('POD-02 uses responsive parent to child master-detail selection',
      (tester) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
      await tester.binding.setSurfaceSize(null);
    });
    final predmet = await _insertResponsivePodsetnikFixture(db);
    var opremanjeCalled = false;
    var cvecariCalled = false;

    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    await tester.pumpWidget(MaterialApp(
      home: PodsetnikPredmetSettings(
        predmet: predmet,
        database: db,
        onNalogZaOpremanje: (_) async => opremanjeCalled = true,
        onNalogCvecari: (_) async => cvecariCalled = true,
      ),
    ));
    await tester.pumpAndSettle();

    final parentPane = find.byKey(const Key('podsetnik-parent-obligations'));
    final childPane = find.byKey(
      const Key('podsetnik-selected-parent-children'),
    );
    final opeloLabel = find.byKey(
      const Key('podsetnik-parent-label-ceremony.opelo'),
    );
    final opeloCheckbox = find.byKey(
      const Key('podsetnik-parent-checkbox-ceremony.opelo'),
    );
    final parteLabel = find.byKey(
      const Key('podsetnik-parent-label-ceremony.parte'),
    );
    final militaryLabel = find.byKey(
      const Key('podsetnik-parent-label-military.honors'),
    );
    final equipmentLabel = find.byKey(
      const Key('podsetnik-parent-label-goods.equipment'),
    );
    final flowersLabel = find.byKey(
      const Key('podsetnik-parent-label-goods.flowers'),
    );
    final parteCheckbox = find.byKey(
      const Key('podsetnik-parent-checkbox-ceremony.parte'),
    );
    final equipmentCheckbox = find.byKey(
      const Key('podsetnik-parent-checkbox-goods.equipment'),
    );
    final equipmentParentSurface = find.byKey(
      const Key('podsetnik-parent-surface-goods.equipment'),
    );
    final flowersParentSurface = find.byKey(
      const Key('podsetnik-parent-surface-goods.flowers'),
    );
    expect(parentPane, findsOneWidget);
    expect(childPane, findsNothing);
    expect(find.text('Obavestiti sveštenika'), findsNothing);
    expect(find.text('Spremiti komplet za opelo'), findsNothing);
    expect(find.text('OPELO'), findsOneWidget);
    expect(find.text('VOJNE POČASTI'), findsOneWidget);
    expect(find.text('PARTE'), findsOneWidget);
    expect(find.text('OPREMA'), findsOneWidget);
    expect(find.text('CVEĆE'), findsOneWidget);
    expect(find.text('SLIKA'), findsOneWidget);
    expect(find.text('CRNINA'), findsOneWidget);
    expect(find.text('Spremiti parte'), findsNothing);
    expect(find.text('Spremiti opremu'), findsNothing);
    expect(find.text('Poručiti cveće'), findsNothing);
    expect(find.text('Spremiti sliku'), findsNothing);
    expect(find.text('Spremiti crninu'), findsNothing);
    expect(find.text('Obavestiti nadležnu službu'), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_right), findsWidgets);
    expect(
      find.descendant(
        of: parentPane,
        matching: find.byKey(const Key('podsetnik-nalog-opremanje')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: parentPane,
        matching: find.byKey(const Key('podsetnik-nalog-cvecari')),
      ),
      findsNothing,
    );
    expect(
      tester.getTopLeft(find.text('OPELO')).dy,
      lessThan(tester.getTopLeft(find.text('PARTE')).dy),
    );
    expect(tester.widget<Checkbox>(opeloCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(parteCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isFalse);
    final scheme = Theme.of(tester.element(opeloCheckbox)).colorScheme;
    expect(
      tester.widget<Checkbox>(opeloCheckbox).fillColor?.resolve({}),
      scheme.error,
    );

    await tester.tap(opeloLabel);
    await tester.pumpAndSettle();

    expect(childPane, findsOneWidget);
    expect(find.text('Obavestiti sveštenika'), findsOneWidget);
    expect(find.text('Spremiti komplet za opelo'), findsOneWidget);
    expect(find.text('Spremiti parte'), findsNothing);
    expect(tester.widget<Checkbox>(opeloCheckbox).value, isFalse);
    expect(
      tester.getTopLeft(childPane).dx,
      greaterThan(tester.getTopRight(parentPane).dx),
    );
    expect(
      tester.widget<Material>(
        find.byKey(const Key('podsetnik-parent-surface-ceremony.opelo')),
      ).color,
      scheme.secondaryContainer,
    );
    expect(tester.widget<Material>(childPane).color, scheme.secondaryContainer);
    expect(tester.takeException() == null, isTrue);

    final childTile = find.ancestor(
      of: find.text('Obavestiti sveštenika'),
      matching: find.byType(CheckboxListTile),
    );
    expect(find.text('Obavestiti sveštenika'), findsOneWidget);
    await tester.tap(childTile);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(childTile).value, isTrue);

    final kitTile = find.ancestor(
      of: find.text('Spremiti komplet za opelo'),
      matching: find.byType(CheckboxListTile),
    );
    expect(tester.widget<CheckboxListTile>(kitTile).value, isFalse);
    await tester.tap(kitTile);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(opeloCheckbox).value, isTrue);
    expect(childPane, findsOneWidget);

    await tester.tap(parteLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsOneWidget);
    expect(find.text('Spremiti parte'), findsOneWidget);
    expect(find.text('Obavestiti sveštenika'), findsNothing);

    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(find.text('Spremiti opremu'), findsOneWidget);
    expect(find.text('Spremiti parte'), findsNothing);
    expect(
      find.descendant(
        of: childPane,
        matching: find.byKey(const Key('podsetnik-nalog-opremanje')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('podsetnik-nalog-opremanje')));
    await tester.pumpAndSettle();
    expect(opremanjeCalled, isTrue);
    expect(
      tester.widget<Material>(equipmentParentSurface).color,
      scheme.secondaryContainer,
    );
    expect(tester.widget<Material>(childPane).color, scheme.secondaryContainer);
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isFalse);
    expect(
      find.descendant(
        of: equipmentParentSurface,
        matching: find.byIcon(Icons.keyboard_arrow_down),
      ),
      findsOneWidget,
    );
    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsNothing);
    expect(find.text('Spremiti opremu'), findsNothing);
    expect(find.byKey(const Key('podsetnik-nalog-opremanje')), findsNothing);
    expect(
      tester.widget<Material>(equipmentParentSurface).color,
      Colors.transparent,
    );
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isFalse);
    expect(
      find.descendant(
        of: equipmentParentSurface,
        matching: find.byIcon(Icons.keyboard_arrow_right),
      ),
      findsOneWidget,
    );
    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsOneWidget);
    expect(find.text('Spremiti opremu'), findsOneWidget);
    expect(find.byKey(const Key('podsetnik-nalog-opremanje')), findsOneWidget);
    expect(
      tester.widget<Material>(equipmentParentSurface).color,
      scheme.secondaryContainer,
    );
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isFalse);
    expect(
      find.descendant(
        of: equipmentParentSurface,
        matching: find.byIcon(Icons.keyboard_arrow_down),
      ),
      findsOneWidget,
    );
    final equipmentChild = find.byKey(
      const Key('podsetnik-child-goods.equipment'),
    );
    await tester.tap(equipmentChild);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(equipmentChild).value, isTrue);
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isTrue);
    expect(
      tester.widget<Checkbox>(equipmentCheckbox).fillColor?.resolve({}),
      Colors.green,
    );

    await tester.tap(flowersLabel);
    await tester.pumpAndSettle();
    expect(find.text('Poručiti cveće'), findsOneWidget);
    expect(find.text('Spremiti opremu'), findsNothing);
    expect(
      find.descendant(
        of: childPane,
        matching: find.byKey(const Key('podsetnik-nalog-cvecari')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('podsetnik-nalog-cvecari')));
    await tester.pumpAndSettle();
    expect(cvecariCalled, isTrue);
    expect(
      tester.widget<Material>(equipmentParentSurface).color,
      Colors.transparent,
    );
    expect(
      tester.widget<Material>(flowersParentSurface).color,
      scheme.secondaryContainer,
    );
    expect(tester.widget<Material>(childPane).color, scheme.secondaryContainer);

    await tester.tap(
      find.byKey(
        const Key('podsetnik-parent-label-military.honors'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Obavestiti nadležnu službu'), findsOneWidget);
    expect(find.text('Poručiti cveće'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(600, 1000));
    await tester.pumpAndSettle();
    expect(childPane, findsOneWidget);
    final militaryChild = find.text('Obavestiti nadležnu službu');
    expect(militaryChild, findsOneWidget);
    expect(tester.getTopLeft(parentPane).dx, lessThan(32));
    expect(tester.getTopLeft(childPane).dx, lessThan(32));
    expect(
      tester.getTopLeft(militaryLabel).dy,
      lessThan(tester.getTopLeft(militaryChild).dy),
    );
    expect(
      tester.getTopLeft(militaryChild).dy,
      lessThan(tester.getTopLeft(parteLabel).dy),
    );

    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: childPane,
        matching: find.byKey(const Key('podsetnik-nalog-opremanje')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: equipmentParentSurface,
        matching: find.byIcon(Icons.keyboard_arrow_down),
      ),
      findsOneWidget,
    );
    final equipmentChildText = find.text('Spremiti opremu');
    expect(
      tester.getTopLeft(equipmentLabel).dy,
      lessThan(tester.getTopLeft(equipmentChildText).dy),
    );
    expect(
      tester.getTopLeft(equipmentChildText).dy,
      lessThan(tester.getTopLeft(flowersLabel).dy),
    );
    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsNothing);
    expect(find.text('Spremiti opremu'), findsNothing);
    expect(find.text('Obavestiti nadležnu službu'), findsNothing);
    expect(find.byKey(const Key('podsetnik-nalog-opremanje')), findsNothing);
    expect(
      tester.widget<Material>(equipmentParentSurface).color,
      Colors.transparent,
    );
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isTrue);
    expect(
      find.descendant(
        of: equipmentParentSurface,
        matching: find.byIcon(Icons.keyboard_arrow_right),
      ),
      findsOneWidget,
    );
    await tester.tap(equipmentLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsOneWidget);
    expect(find.text('Spremiti opremu'), findsOneWidget);
    expect(
      tester.getTopLeft(equipmentLabel).dy,
      lessThan(tester.getTopLeft(equipmentChildText).dy),
    );
    expect(
      tester.getTopLeft(equipmentChildText).dy,
      lessThan(tester.getTopLeft(flowersLabel).dy),
    );
    expect(find.byKey(const Key('podsetnik-nalog-opremanje')), findsOneWidget);
    expect(tester.widget<Checkbox>(equipmentCheckbox).value, isTrue);
    expect(tester.takeException() == null, isTrue);

    await tester.tap(opeloLabel);
    await tester.pumpAndSettle();
    expect(childPane, findsOneWidget);
    expect(find.text('Obavestiti sveštenika'), findsOneWidget);
    expect(tester.getTopLeft(childPane).dx, lessThan(32));
    expect(tester.takeException() == null, isTrue);
  });

  testWidgets('POD-05 separates URNA/PEPEO parent and child presentation', (
    tester,
  ) async {
    const scenarios = [
      ('KREMACIJA', 'GROB', 'POLAGANJE URNE', 'Zakazati polaganje urne'),
      (
        'KREMACIJA_EKSPRES',
        'RASIPANJE_PEPELA',
        'RASIPANJE PEPELA',
        'Zakazati rasipanje pepela',
      ),
    ];

    for (final scenario in scenarios) {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: Value('POD05-${scenario.$2}'),
              ime: const Value('Ana'),
              prezime: const Value('Jovanović'),
              vrstaCeremonije: Value(scenario.$1),
              tipPolaganja: Value(scenario.$2),
              grobljePolaganjaUrne: const Value('Novo groblje'),
            ),
          );
      final predmet = await (db.select(
        db.predmeti,
      )..where((row) => row.id.equals(id))).getSingle();

      await tester.pumpWidget(
        MaterialApp(
          home: PodsetnikPredmetSettings(predmet: predmet, database: db),
        ),
      );
      await tester.pumpAndSettle();

      final parentLabel = find.byKey(
        const Key('podsetnik-parent-label-post.urn_ashes'),
      );
      final parentCheckbox = find.byKey(
        const Key('podsetnik-parent-checkbox-post.urn_ashes'),
      );
      final childTile = find.byKey(
        const Key('podsetnik-child-post.urn_ashes.arrange_placement'),
      );
      expect(find.text(scenario.$3), findsOneWidget);
      expect(parentLabel, findsOneWidget);
      expect(childTile, findsNothing);
      expect(find.text(scenario.$4), findsNothing);
      expect(tester.widget<Checkbox>(parentCheckbox).value, isFalse);

      await tester.tap(parentLabel);
      await tester.pumpAndSettle();

      expect(find.text(scenario.$3), findsOneWidget);
      expect(find.text(scenario.$4), findsOneWidget);
      expect(find.textContaining('ZA Ana Jovanović'), findsNothing);
      expect(tester.widget<Checkbox>(parentCheckbox).value, isFalse);
      expect(tester.widget<CheckboxListTile>(childTile).value, isFalse);

      await tester.tap(parentLabel);
      await tester.pumpAndSettle();
      expect(find.text(scenario.$4), findsNothing);

      await tester.tap(parentLabel);
      await tester.pumpAndSettle();
      expect(find.text(scenario.$4), findsOneWidget);
      expect(tester.widget<Checkbox>(parentCheckbox).value, isFalse);
      expect(tester.widget<CheckboxListTile>(childTile).value, isFalse);

      await tester.tap(childTile);
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(childTile).value, isTrue);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('POD-04 uses the bounded screen-local parte label', (tester) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
    final predmet = await _insertResponsivePodsetnikFixture(db);

    await tester.pumpWidget(MaterialApp(
      home: PodsetnikPredmetSettings(predmet: predmet, database: db),
    ));
    await tester.pumpAndSettle();

    expect(find.text('PARTE'), findsOneWidget);
    expect(find.text('Spremiti parte'), findsNothing);
    await tester.tap(
      find.byKey(
        const Key('podsetnik-parent-label-ceremony.parte'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PARTE'), findsOneWidget);
    expect(find.text('Spremiti parte'), findsOneWidget);
  });
}

Future<PredmetiData> _insertResponsivePodsetnikFixture(AppDatabase db) async {
  final id = await db.into(db.predmeti).insert(
    const PredmetiCompanion(
      brojPredmeta: Value('POD02-POD04-UI'),
      ime: Value('Ana'),
      prezime: Value('Jovanović'),
      vrstaCeremonije: Value('SAHRANA'),
      datumCeremonije: Value('30.08.2026.'),
      vremeCeremonije: Value('12:00'),
      groblje: Value('Novo groblje'),
      opelo: Value('DA'),
      obavestitiSvestenika: Value('DA'),
      vojniPenzioner: Value('DA'),
      vojnePocasti: Value('DA'),
      partePotrebna: Value(true),
    ),
  );
  for (final (index, category) in [
    (0, IriuK.kompletZaOpelo),
    (1, IriuK.sanduk),
    (2, IriuK.cvece),
    (3, IriuK.slika),
    (4, IriuK.crnina),
  ]) {
    await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(id),
        interniNaziv: Value(category),
        redosled: Value(index),
      ),
    );
  }
  return (db.select(db.predmeti)..where((row) => row.id.equals(id))).getSingle();
}
