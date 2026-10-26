import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_canonical_json.dart';
import 'package:opc_v4/core/entitlements/opc_license_signature_verifier.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_model.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_parser.dart';
import 'package:opc_v4/core/entitlements/opc_predmet_creation_license.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';

import 'test_bootstrap.dart';

void main() {
  test('platform label distinguishes Web from every desktop/mobile target', () {
    expect(
      opcPlatformDisplayName(isWeb: true, platform: TargetPlatform.windows),
      'Web/PWA',
    );
    expect(
      opcPlatformDisplayName(isWeb: false, platform: TargetPlatform.windows),
      'Windows desktop',
    );
    expect(
      opcPlatformDisplayName(isWeb: false, platform: TargetPlatform.android),
      'Android',
    );
    expect(
      opcPlatformDisplayName(isWeb: false, platform: TargetPlatform.iOS),
      'iOS',
    );
    expect(
      opcPlatformDisplayName(isWeb: false, platform: TargetPlatform.macOS),
      'macOS',
    );
  });

  testWidgets(
    'trial invitation opens existing license and vanishes on activation',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await db.close();
      });
      final auth = AuthRepository(db);
      final session = SessionService();
      final settings = PodesavanjaRepository(db);
      final admin = await auth.kreirajPrvogAdmina(
        imePrezime: 'Synthetic Administrator',
        pin: '1234',
      );
      session.prijavi(admin);
      await settings.saveFirmaPodaci(
        const FirmaPodaciCompanion(
          naziv: Value('Synthetic FIRMA'),
          pib: Value('111111111'),
          mb: Value('10000001'),
        ),
      );
      final algorithm = Ed25519();
      final pair = await algorithm.newKeyPairFromSeed(List<int>.filled(32, 9));
      final publicKey = await pair.extractPublicKey();
      final service = OpcPredmetCreationLicense(
        db,
        clock: () => DateTime.utc(2026, 10, 25),
        parser: OpcLocalLicenseParser(
          verifier: OpcEd25519LicenseSignatureVerifier(
            publicKeysById: {'synthetic-ui': base64Encode(publicKey.bytes)},
          ),
        ),
        platform: OpcLocalLicensePlatform.web,
      );
      final token = await _issueSyntheticToken(algorithm, pair);

      Widget list() => wrapForTest(
        ListaPredmetaScreen(
          predmetiRepo: PredmetiRepository(db),
          authRepo: auth,
          podesavanjaRepo: settings,
          session: session,
          predmetiStreamOverride: Stream.value(const <PredmetiData>[]),
          runStartupSideEffects: false,
          predmetCreationLicense: service,
        ),
      );

      await tester.pumpWidget(list());
      await tester.pumpAndSettle();
      expect(find.textContaining('Probni period do'), findsOneWidget);
      await tester.tap(find.text('AKTIVIRAJ'));
      await tester.pumpAndSettle();
      expect(find.text('LICENCA / AKTIVACIJA'), findsOneWidget);
      expect(
        find.byTooltip('LICENCA – nije trajno aktivirana'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Icon>(find.byIcon(Icons.workspace_premium_outlined).last)
            .color,
        Colors.red,
      );

      await tester.enterText(find.byType(TextField).last, token);
      await tester.tap(find.widgetWithText(FilledButton, 'AKTIVIRAJ'));
      await tester.pumpAndSettle();
      expect(find.text('LICENCA / AKTIVACIJA'), findsNothing);
      expect(find.byTooltip('LICENCA – trajno aktivirana'), findsOneWidget);
      final medal = tester.widget<Icon>(
        find.byIcon(Icons.workspace_premium_outlined).last,
      );
      expect(medal.color, Colors.green);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.textContaining('Probni period do'), findsNothing);
      expect(find.text('AKTIVIRAJ'), findsNothing);
      expect(
        (await service.evaluate()).status,
        OpcPredmetLicenseStatus.activated,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(list());
      await tester.pumpAndSettle();
      expect(find.text('AKTIVIRAJ'), findsNothing);
    },
  );

  testWidgets(
    'expired trial keeps the invitation and existing records available',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = createTestDatabase();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await db.close();
      });
      final auth = AuthRepository(db);
      final session = SessionService();
      final admin = await auth.kreirajPrvogAdmina(
        imePrezime: 'Synthetic Administrator',
        pin: '1234',
      );
      session.prijavi(admin);
      var now = DateTime.utc(2026, 10, 25);
      final service = OpcPredmetCreationLicense(db, clock: () => now);
      expect((await service.evaluate()).status, OpcPredmetLicenseStatus.trial);
      now = DateTime.utc(2027, 1, 26);

      await tester.pumpWidget(
        wrapForTest(
          ListaPredmetaScreen(
            predmetiRepo: PredmetiRepository(db),
            authRepo: auth,
            podesavanjaRepo: PodesavanjaRepository(db),
            session: session,
            predmetiStreamOverride: Stream.value(const <PredmetiData>[]),
            runStartupSideEffects: false,
            predmetCreationLicense: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Probni period je istekao'), findsOneWidget);
      expect(find.text('AKTIVIRAJ'), findsOneWidget);
      expect(find.text('NOVI PREDMET'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<String> _issueSyntheticToken(
  Ed25519 algorithm,
  SimpleKeyPair pair,
) async {
  final payload = <String, Object?>{
    'licenseId': 'synthetic-ui-test',
    'customerId': '111111111:10000001',
    'customerLabel': 'Synthetic FIRMA',
    'firmaPib': '111111111',
    'firmaMb': '10000001',
    'packageLevel': 'potpun',
    'enabledAddOns': <String>[],
    'issuedAt': '2026-10-25T00:00:00.000Z',
    'diagnosticsLabel': 'synthetic_ui',
  };
  final signature = await algorithm.sign(
    utf8.encode(OpcCanonicalJsonV1.encode(payload)),
    keyPair: pair,
  );
  return jsonEncode(<String, Object?>{
    'schemaVersion': 2,
    'payload': payload,
    'signature': base64Encode(signature.bytes),
    'signatureMetadata': <String, Object?>{
      'algorithmId': 'ed25519-v1',
      'keyId': 'synthetic-ui',
    },
  });
}
