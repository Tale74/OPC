import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('lista predmeta screen opens with stable actions', (
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
      await tester.idle();
      await tester.pump();
    });

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);
    final predmetiRepo = PredmetiRepository(db);
    final predmetiStream = Stream<List<PredmetiData>>.value(
      const <PredmetiData>[],
    );

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Savetnik',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        ListaPredmetaScreen(
          predmetiRepo: predmetiRepo,
          authRepo: authRepo,
          podesavanjaRepo: podesavanjaRepo,
          session: session,
          predmetiStreamOverride: predmetiStream,
          runStartupSideEffects: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OPC — LISTA PREDMETA'), findsOneWidget);
    expect(find.text('NOVI PREDMET'), findsOneWidget);
  });
}
