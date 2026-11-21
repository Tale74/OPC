import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/predmet_iriu_order.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_segment.dart';

import 'test_bootstrap.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('segment 7 saves SCENARIO order at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 870));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final db = createTestDatabase();
      final repo = IriuRepository(db);
      addTearDown(db.close);
      late PredmetiData caseData;

      Future<void> addRow(
        String identity,
        String category,
        String origin,
      ) async {
        final rowId = await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: caseData.id,
                interniNaziv: category,
                portableOccurrenceId: Value(identity),
                iznos: const Value(125),
              ),
            );
        await db
            .into(db.iriuProvenance)
            .insert(
              IriuProvenanceCompanion.insert(
                iriuId: Value(rowId),
                origin: origin,
                createdAt: '2026-11-20T10:00:00Z',
              ),
            );
      }

      {
        await seedScenarioCatalogForTest(db);
        final id = await db
            .into(db.predmeti)
            .insert(PredmetiCompanion.insert());
        caseData = await (db.select(
          db.predmeti,
        )..where((row) => row.id.equals(id))).getSingle();
        await savePredmetIriuOrder(
          db,
          id,
          const PredmetIriuOrder(basic: ['SANDUK']),
        );
        await addRow('base', 'SANDUK', 'OSNOVNI_PAKET');
        await addRow('manual', 'PROBA_RUCNO', 'RUCNA_STAVKA');
      }

      final control = find.byKey(const Key('iriu-scenario-order'));
      Future<void> mount() async {
        await tester.pumpWidget(
          wrapForTest(
            Scaffold(
              body: SingleChildScrollView(
                child: IriuSegment(
                  predmetId: caseData.id,
                  predmetData: caseData,
                  iriuRepo: repo,
                  podesavanjaRepo: PodesavanjaRepository(db),
                  enabled: true,
                  onNapomenaSave: (_) {},
                ),
              ),
            ),
          ),
        );
      }

      Future<void> pumpUntil(bool Function() ready) async {
        for (var i = 0; i < 100; i++) {
          await tester.pump(const Duration(milliseconds: 30));
          if (ready()) return;
        }
        fail('Segment 7 did not reach the expected state.');
      }

      await mount();
      await pumpUntil(() => control.evaluate().isNotEmpty);
      expect(tester.widget<OutlinedButton>(control).onPressed, isNull);
      expect(find.textContaining('najmanje dve SCENARIO'), findsOneWidget);

      {
        await addRow('one', 'PROBA_A', 'SCENARIO_PAKET');
        await addRow('two', 'PROBA_B', 'SCENARIO_PAKET');
      }
      await pumpUntil(
        () => tester.widget<OutlinedButton>(control).onPressed != null,
      );
      await tester.tap(control);
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.byKey(const ValueKey('base')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.byKey(const ValueKey('manual')),
        ),
        findsNothing,
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('two')),
          matching: find.byTooltip('Gore'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: dialog, matching: find.byType(FilledButton)),
      );
      await tester.pumpAndSettle();
      {
        expect((await readPredmetIriuOrder(db, caseData.id))?.scenario, [
          'two',
          'one',
        ]);
        final rows = await repo.getIriu(caseData.id);
        expect(rows.map((r) => r.portableOccurrenceId), [
          'base',
          'two',
          'one',
          'manual',
        ]);
        expect(rows.map((r) => r.iznos), everyElement(125));
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await mount();
      await pumpUntil(
        () =>
            control.evaluate().isNotEmpty &&
            tester.widget<OutlinedButton>(control).onPressed != null,
      );
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('two'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('one'))).dy),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 30));
    });
  }
}
