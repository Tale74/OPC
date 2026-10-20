import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets(
    'OPEN selector keeps one selection and clears stale closed PREDMET',
    (tester) async {
      final db = createTestDatabase();
      await seedScenarioCatalogForTest(db);
      await ScenarioModuleRepository(db).ensureModuleAndDefaults();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
      final predmeti = PredmetiRepository(db);
      final idA = await predmeti.kreirajPredmet(savetnikId: 1);
      final idB = await predmeti.kreirajPredmet(savetnikId: 1);
      final idClosed = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
        idA,
        const PredmetiCompanion(brojPredmeta: Value('TEST4-A')),
      );
      await predmeti.azurirajPredmet(
        idB,
        const PredmetiCompanion(brojPredmeta: Value('TEST4-B')),
      );
      await predmeti.azurirajPredmet(
        idClosed,
        const PredmetiCompanion(
          brojPredmeta: Value('TEST4-CLOSED'),
          status: Value('ZATVOREN'),
        ),
      );

      await tester.pumpWidget(
        wrapForTest(
          ScenarioModuleScreen(
            podesavanjaRepository: PodesavanjaRepository(db),
          ),
        ),
      );
      await _pumpUntil(
        tester,
        find.byKey(const ValueKey('scenario-card-open-predmeti')),
      );
      await _pumpUntil(tester, find.text('Broj otvorenih predmeta: 2'));
      await tester.tap(
        find.byKey(const ValueKey('scenario-card-open-predmeti')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await _pumpUntil(
        tester,
        find.byKey(const ValueKey('scenario-open-predmet-selector')),
      );
      expect(
        find.byKey(const ValueKey('scenario-open-predmet-selector')),
        findsOneWidget,
      );
      expect(find.textContaining('TEST4-CLOSED'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('scenario-open-predmet-selector')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('PREDMET TEST4-A').last, findsOneWidget);
      expect(find.text('PREDMET TEST4-B').last, findsOneWidget);
      await tester.tap(find.text('PREDMET TEST4-A').last);
      await _pumpUntil(tester, find.text('PREDMET TEST4-A · OTVOREN'));
      expect(
        find.byKey(const ValueKey('scenario-selected-predmet-view')),
        findsOneWidget,
      );
      expect(find.text('PREDMET TEST4-A · OTVOREN'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('scenario-open-predmet-selector')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('PREDMET TEST4-B').last);
      await _pumpUntil(tester, find.text('PREDMET TEST4-B · OTVOREN'));
      expect(find.text('PREDMET TEST4-B · OTVOREN'), findsOneWidget);
      expect(find.text('PREDMET TEST4-A · OTVOREN'), findsNothing);

      await predmeti.azurirajPredmet(
        idB,
        const PredmetiCompanion(status: Value('ZATVOREN')),
      );
      await tester.tap(
        find.byKey(const ValueKey('scenario-open-predmet-refresh')),
      );
      await _pumpUntil(
        tester,
        find.byKey(const ValueKey('scenario-selected-predmet-view')),
        absent: true,
      );
      expect(
        find.byKey(const ValueKey('scenario-selected-predmet-view')),
        findsNothing,
      );
      expect(find.textContaining('TEST4-B'), findsNothing);
    },
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  bool absent = false,
  int maxFrames = 100,
}) async {
  for (var frame = 0; frame < maxFrames; frame++) {
    final found = finder.evaluate().isNotEmpty;
    if (absent ? !found : found) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail(
    absent
        ? 'Widgets matching $finder remained mounted after $maxFrames pumps.'
        : 'Widgets matching $finder did not appear after $maxFrames pumps.',
  );
}
