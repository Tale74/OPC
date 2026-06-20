import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/auth/presentation/login_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('login screen shows stable initial elements', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final authRepo = AuthRepository(db);
    final session = SessionService();

    await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Savetnik',
      pin: '1234',
    );

    await tester.pumpWidget(
      wrapForTest(
        LoginScreen(
          authRepo: authRepo,
          session: session,
          onSuccess: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OPC'), findsOneWidget);
    expect(find.text('Izaberite savetnika'), findsOneWidget);
    expect(find.text('Test Savetnik'), findsOneWidget);
  });
}
