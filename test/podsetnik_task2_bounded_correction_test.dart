import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/json_transfer/iriu_json_compat.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/presentation/podsetnik_module_screen.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/pdf/nalog_cvecari_pdf_export.dart';

import 'test_bootstrap.dart';

void main() {
  test('CVEĆE ribbon text is row-scoped, transferable and current-event based',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db.into(db.predmeti).insert(
      const PredmetiCompanion(brojPredmeta: Value('T2-RIBBON')),
    );
    final rowA = await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(predmetId),
        interniNaziv: const Value('CVECE'),
        nazivPrikaz: const Value('VENAC A'),
        tekstTrake: const Value('Za Anu'),
      ),
    );
    final rowB = await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(predmetId),
        interniNaziv: const Value('CVECE'),
        nazivPrikaz: const Value('BUKET B'),
        tekstTrake: const Value('Od porodice'),
      ),
    );
    final rows = await (db.select(db.iriu)
          ..where((row) => row.predmetId.equals(predmetId))
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();
    expect(rows.map((row) => row.id), [rowA, rowB]);
    expect(rows.map((row) => row.tekstTrake), ['Za Anu', 'Od porodice']);

    await (db.update(db.iriu)..where((row) => row.id.equals(rowA))).write(
      const IriuCompanion(tekstTrake: Value('Izmenjeno A')),
    );
    final changedB = await (db.select(db.iriu)
          ..where((row) => row.id.equals(rowB)))
        .getSingle();
    expect(changedB.tekstTrake, 'Od porodice');

    final transferred = iriuDataFromCompatibleJson(rows.first.toJson());
    expect(transferred.tekstTrake, 'Za Anu');

    await (db.delete(db.iriu)..where((row) => row.id.equals(rowA))).go();
    final readded = await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(predmetId),
        interniNaziv: const Value('CVECE'),
        nazivPrikaz: const Value('VENAC A'),
      ),
    );
    expect(readded, greaterThan(rowA));
    final currentReadded = await (db.select(db.iriu)
          ..where((row) => row.id.equals(readded)))
        .getSingle();
    expect(currentReadded.tekstTrake, equals(null));
  });

  test('NALOG CVEĆARI prepared data uses current IRiU order and row values',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db.into(db.predmeti).insert(
      const PredmetiCompanion(
        brojPredmeta: Value('T2-CVECARI'),
        ime: Value('Ana'),
        prezime: Value('Jovanović'),
        datumRodjenja: Value('01.01.1950.'),
        vrstaCeremonije: Value('SAHRANA'),
        datumCeremonije: Value('30.08.2026.'),
        vremeCeremonije: Value('12:00'),
        groblje: Value('Novo groblje'),
      ),
    );
    await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(predmetId),
        interniNaziv: const Value('CVECE'),
        nazivPrikaz: const Value('VENAC A'),
        tekstTrake: const Value('Za Anu'),
        redosled: const Value(1),
      ),
    );
    await db.into(db.iriu).insert(
      IriuCompanion(
        predmetId: Value(predmetId),
        interniNaziv: const Value('CVECE'),
        nazivPrikaz: const Value('BUKET B'),
        tekstTrake: const Value('Od porodice'),
        redosled: const Value(2),
      ),
    );
    final predmet = await (db.select(db.predmeti)
          ..where((row) => row.id.equals(predmetId)))
        .getSingle();
    final prepared = await pripremiNalogCvecariPdfPodatke(
      predmet: predmet,
      iriu: await IriuRepository(db).getIriu(predmetId),
      katalog: await db.select(db.katalogArtikli).get(),
    );
    expect(prepared.vrstaCeremonije, 'SAHRANA');
    expect(prepared.flowers.map((item) => item.articleName), [
      'VENAC A',
      'BUKET B',
    ]);
    expect(prepared.flowers.map((item) => item.ribbonText), [
      'Za Anu',
      'Od porodice',
    ]);
  });

  test('IRiU ribbon UI contract is row-scoped in the current source', () {
    final source = File(
      'lib/features/predmeti/presentation/segments/iriu_segment.dart',
    ).readAsStringSync();
    expect(source, contains("'iriu-cvece-ribbon-\${row.id}'"));
    expect(source, contains('row.nazivPrikaz'));
    expect(source, contains('row.tekstTrake ??'));
    expect(source, contains('IriuCompanion(tekstTrake: Value(value))'));
  });

  testWidgets('real assistance callbacks do not complete atomic obligations',
      (tester) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
      await db.close();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    });
    final predmetId = await db.into(db.predmeti).insert(
      const PredmetiCompanion(brojPredmeta: Value('T2-ACTIONS')),
    );
    for (final category in const ['SANDUK', 'CVECE']) {
      await db.into(db.iriu).insert(
        IriuCompanion(
          predmetId: Value(predmetId),
          interniNaziv: Value(category),
          nazivPrikaz: Value(category),
        ),
      );
    }
    final predmet = await (db.select(db.predmeti)
          ..where((row) => row.id.equals(predmetId)))
        .getSingle();
    var equipmentCalled = false;
    var flowersCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PodsetnikPredmetSettings(
              predmet: predmet,
              database: db,
              onNalogZaOpremanje: (_) async => equipmentCalled = true,
              onNalogCvecari: (_) async => flowersCalled = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('podsetnik-parent-label-goods.equipment')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spremiti opremu'), findsOneWidget);
    expect(find.byKey(const Key('podsetnik-nalog-opremanje')), findsOneWidget);
    await tester.tap(find.byKey(const Key('podsetnik-nalog-opremanje')));
    await tester.tap(
      find.byKey(const Key('podsetnik-parent-label-goods.flowers')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Poručiti cveće'), findsOneWidget);
    expect(find.byKey(const Key('podsetnik-nalog-cvecari')), findsOneWidget);
    await tester.tap(find.byKey(const Key('podsetnik-nalog-cvecari')));
    await tester.pump();
    expect(equipmentCalled, isTrue);
    expect(flowersCalled, isTrue);
    final obligations = await PodsetnikObligationRepository(db)
        .currentForPredmet(predmetId);
    expect(
      obligations
          .where((item) =>
              item.rule.stableRuleId == 'goods.equipment' ||
              item.rule.stableRuleId == 'goods.flowers')
          .every((item) => !item.completed),
      isTrue,
    );
  });
}
