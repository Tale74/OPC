import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('podesavanja screen can open directly on korisnici section', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: podesavanjaRepo,
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.korisnici,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KORISNICI'), findsWidgets);
    expect(find.text('Oporavak pristupa aplikaciji'), findsOneWidget);
    expect(
      find.text('Sigurnosni kod nije podešen.'),
      findsOneWidget,
    );
  });

  testWidgets('O APLIKACIJI separates local license from active entitlement', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final authRepo = AuthRepository(db);
    final session = SessionService();
    final podesavanjaRepo = PodesavanjaRepository(db);

    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: podesavanjaRepo,
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.oAplikaciji,
          entitlementPolicy: _potpunDemoPolicy(),
        ),
      ),
    );
    await _pumpUntilText(
      tester,
      'Instalirana lokalna licenca - paket: Osnovni',
    );

    expect(
      find.text('Instalirana lokalna licenca - paket: Osnovni'),
      findsOneWidget,
    );
    expect(find.text('Aktivni paket runtime-a: Potpun'), findsOneWidget);
    expect(
      find.text('Aktivni entitlement runtime-a: demo/test / test.'),
      findsOneWidget,
    );
    expect(find.text('Aktivni moduli/dodaci: STANJE ROBE.'), findsOneWidget);
  });
}

Future<void> _pumpUntilText(
  WidgetTester tester,
  String text, {
  int maxPumps = 100,
}) async {
  for (var i = 0; i < maxPumps; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(text).evaluate().isNotEmpty) {
      return;
    }
  }
  final renderedText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((value) => value.trim().isNotEmpty)
      .join('\n');
  fail('Text "$text" was not rendered. Rendered text:\n$renderedText');
}

OpcEntitlementPolicy _potpunDemoPolicy() {
  return OpcEntitlementPolicy.fromPayload(
    const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: OpcEntitlementEnvironment.test,
      packageLevel: OpcPackageLevel.potpun,
    ),
  );
}
