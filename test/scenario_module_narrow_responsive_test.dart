import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('SCENARIO cards and preview remain bounded on narrow width', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(
      wrapForTest(
        ScenarioModuleScreen(podesavanjaRepository: PodesavanjaRepository(db)),
      ),
    );
    while (find
        .byKey(const ValueKey('scenario-card-osnovni-paket'))
        .evaluate()
        .isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    for (final key in [
      'scenario-card-osnovni-paket',
      'scenario-card-scenariji',
      'scenario-card-new-scenario',
      'scenario-card-open-predmeti',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('scenario-open-scenariji')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('PREGLED').first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('PREGLED').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('PREGLED SCENARIJA'), findsOneWidget);
    expect(find.textContaining('SVE'), findsNothing);
    expect(find.textContaining('nije DA'), findsNothing);
    expect(find.textContaining('≠'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.widgetWithText(TextButton, 'ZATVORI').last);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byTooltip('ZATVORI').last);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
