import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/app.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('genuine zero-user database routes to first launch', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(OpcApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('Korak 1 od 2 — Administrator'), findsOneWidget);
    expect(find.text('Izaberite savetnika'), findsNothing);
  });

  testWidgets('existing users at startup route to login', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await AuthRepository(db).kreirajPrvogAdmina(
      imePrezime: 'STARTUP ADMIN',
      pin: '1234',
    );

    await tester.pumpWidget(OpcApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('Izaberite savetnika'), findsOneWidget);
    expect(find.text('STARTUP ADMIN'), findsOneWidget);
    expect(find.text('Korak 1 od 2 — Administrator'), findsNothing);
  });

  testWidgets(
    'users introduced after an empty start are visible after logout',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final authRepo = AuthRepository(db);

      await tester.pumpWidget(OpcApp(db: db));
      await tester.pumpAndSettle();
      expect(find.text('Korak 1 od 2 — Administrator'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'INITIAL ADMIN');
      await tester.tap(find.text('DALJE'));
      await tester.pumpAndSettle();
      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit).last);
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('POTVRDI'));
      await tester.pumpAndSettle();

      // Simulate the same user-state effect as a restore introducing an
      // additional legitimate user while the process remains alive.
      await authRepo.kreirajKorisnika(
        imePrezime: 'RESTORED SAVETNIK',
        uloga: 'SAVETNIK',
        pin: '5678',
      );

      await tester.tap(find.byTooltip('Odjava'));
      await tester.pumpAndSettle();

      expect(find.text('Izaberite savetnika'), findsOneWidget);
      expect(find.text('INITIAL ADMIN'), findsOneWidget);
      expect(find.text('RESTORED SAVETNIK'), findsOneWidget);
      expect(find.text('Korak 1 od 2 — Administrator'), findsNothing);
    },
  );
}
