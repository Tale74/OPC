import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('SCENARIO module opens with base package and scenario sections', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      await db.close();
    });

    await tester.pumpWidget(
      wrapForTest(
        ScenarioModuleScreen(podesavanjaRepository: PodesavanjaRepository(db)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('SCENARIO'), findsWidgets);
    expect(find.text('OSNOVNI PAKET'), findsOneWidget);
    expect(find.text('SCENARIJI'), findsOneWidget);
    expect(
      find.text(
        'Modul SCENARIO uređuje listu osnovnih i dodatnih stavki robe i usluga za automatski pregled i obračun prema mestu smrti i drugim uslovima.',
      ),
      findsOneWidget,
    );
    expect(find.text('POSLOVNA HIJERARHIJA'), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.text('DODAJ NOVI SCENARIO'), findsOneWidget);
    for (final forbidden in [
      'PRIKAŽI SAŽETAK ODLUKE',
      'PROVERI NA PRIMERU',
      'NAPRAVI KOPIJU',
      'STAVI SCENARIO VAN UPOTREBE',
    ]) {
      expect(find.text(forbidden), findsNothing, reason: forbidden);
    }
  });
}
