import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/kontakt_lica_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_row_tile.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/narucilac_segment.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('contact edit flushes before Save/Back and survives reopen', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          const PredmetiCompanion(
            brojPredmeta: Value('NESTED-CONTACT-TEST'),
            naruTip: Value('PRAVNO_LICE'),
          ),
        );
    final repo = KontaktLicaRepository(db);
    final contactId = await repo.dodaj(
      predmetId: predmetId,
      blok: 'NARU_OPREMA',
      imePrezime: 'Staro Ime',
    );
    final predmet = await (db.select(
      db.predmeti,
    )..where((p) => p.id.equals(predmetId))).getSingle();
    final firma = await db.select(db.firmaPodaci).getSingle();
    final key = GlobalKey<NarucilacSegmentState>();
    Widget screen() => wrapForTest(
      Scaffold(
        body: SingleChildScrollView(
          child: NarucilacSegment(
            key: key,
            initialData: predmet,
            predmetId: predmetId,
            kontaktRepo: repo,
            firmaPodaci: firma,
            enabled: true,
            onSave: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final contactName = find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.controller?.text == 'Staro',
    );
    expect(contactName, findsOneWidget);
    await tester.enterText(contactName, 'Novo');
    await key.currentState!.flushPendingSave();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final saved = await (db.select(
      db.kontaktLica,
    )..where((k) => k.id.equals(contactId))).getSingle();
    expect(saved.imePrezime, 'Novo Ime');
    final editedName = find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.controller?.text == 'Novo',
    );
    await tester.enterText(editedName, 'Pred brisanje');
    final delete = find.byTooltip('Obriši kontakt');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    final deleted = await (db.select(
      db.kontaktLica,
    )..where((k) => k.id.equals(contactId))).getSingleOrNull();
    expect(
      deleted,
      isNull,
      reason: 'A pending write must not revive a deleted contact',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('IRiU row retains the last edit on immediate unmount', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          const PredmetiCompanion(brojPredmeta: Value('NESTED-AUTOSAVE-TEST')),
        );
    final rowId = await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'RUCNO_TEST',
            nazivPrikaz: const Value('Pre izmene'),
          ),
        );
    final row = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: IriuRowTile(
            stavka: row,
            iriuRepo: IriuRepository(db),
            podesavanjaRepo: PodesavanjaRepository(db),
            imaArtikalaStream: Stream<bool>.value(false),
            enabled: true,
            truthRow: null,
            stockConsequence: null,
            isNarrowAndroid: false,
            preporucenoLabel: 'PREPORUČENO',
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Posle izmene');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 900));
    final saved = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    expect(saved.nazivPrikaz, 'Posle izmene');
  });

  testWidgets('IRiU pending edit finishes before confirmed deletion', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          const PredmetiCompanion(brojPredmeta: Value('NESTED-DELETE-TEST')),
        );
    final rowId = await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'RUCNO_DELETE_TEST',
            nazivPrikaz: const Value('Pre brisanja'),
          ),
        );
    final row = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: IriuRowTile(
            stavka: row,
            iriuRepo: IriuRepository(db),
            podesavanjaRepo: PodesavanjaRepository(db),
            imaArtikalaStream: Stream<bool>.value(false),
            enabled: true,
            truthRow: null,
            stockConsequence: null,
            isNarrowAndroid: false,
            preporucenoLabel: 'PREPORUČENO',
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'Poslednja izmena',
    );
    await tester.tap(find.byTooltip('Obriši stavku'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OBRIŠI'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 900));
    expect(
      await (db.select(
        db.iriu,
      )..where((r) => r.id.equals(rowId))).getSingleOrNull(),
      isNull,
    );
  });
}
