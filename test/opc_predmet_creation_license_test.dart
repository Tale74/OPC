import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
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
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';

import 'test_bootstrap.dart';

void main() {
  test('three calendar months clamp month-end dates', () {
    expect(
      OpcPredmetCreationLicense.addThreeCalendarMonths(
        DateTime.utc(2026, 1, 31, 10),
      ),
      DateTime.utc(2026, 4, 30, 10),
    );
    expect(
      OpcPredmetCreationLicense.addThreeCalendarMonths(
        DateTime.utc(2026, 11, 30, 10),
      ),
      DateTime.utc(2027, 2, 28, 10),
    );
  });

  test(
    'trial survives service recreation and closes at exact boundary',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      var now = DateTime.utc(2026, 10, 22, 9);
      OpcPredmetCreationLicense service() => OpcPredmetCreationLicense(
        db,
        clock: () => now,
        platform: OpcLocalLicensePlatform.windows,
        random: Random(1),
      );

      final first = await service().evaluate();
      expect(first.status, OpcPredmetLicenseStatus.trial);
      expect(first.canCreateNewPredmet, isTrue);
      expect(first.trialEndsUtc, DateTime.utc(2027, 1, 22, 9));
      now = DateTime.utc(2027, 1, 22, 8, 59, 59);
      final before = await service().evaluate();
      expect(before.status, OpcPredmetLicenseStatus.trial);
      expect(before.installationId, first.installationId);
      now = DateTime.utc(2027, 1, 22, 9);
      final atBoundary = await service().evaluate();
      expect(atBoundary.status, OpcPredmetLicenseStatus.expired);
      expect(atBoundary.canCreateNewPredmet, isFalse);
      now = DateTime.utc(2027, 1, 21, 9);
      expect(
        (await service().evaluate()).status,
        OpcPredmetLicenseStatus.clockRollback,
      );
    },
  );

  test(
    'only a valid permanent signature activates this installation',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      var now = DateTime.utc(2026, 10, 22, 9);
      final algorithm = Ed25519();
      final pair = await algorithm.newKeyPairFromSeed(List<int>.filled(32, 8));
      final publicKey = await pair.extractPublicKey();
      final parser = OpcLocalLicenseParser(
        verifier: OpcEd25519LicenseSignatureVerifier(
          publicKeysById: {'test-only': base64Encode(publicKey.bytes)},
        ),
        clock: () => now,
      );
      final service = OpcPredmetCreationLicense(
        db,
        clock: () => now,
        parser: parser,
        platform: OpcLocalLicensePlatform.windows,
        random: Random(2),
      );
      final initial = await service.evaluate();
      now = DateTime.utc(2027, 2, 1);
      expect((await service.evaluate()).canCreateNewPredmet, isFalse);

      final signed = await _sign(
        algorithm,
        pair,
        initial.installationId,
        platform: 'windows',
      );
      final tampered = signed.replaceFirst('potpun', 'osnovni');
      expect(await service.installPermanentActivation(tampered), isFalse);
      expect(await service.installPermanentActivation(signed), isTrue);
      expect(
        (await service.evaluate()).status,
        OpcPredmetLicenseStatus.activated,
      );
      expect((await service.evaluate()).canCreateNewPredmet, isTrue);

      expect(
        (await parser.evaluate(
          signed,
          currentPlatform: OpcLocalLicensePlatform.windows,
          installationId: 'opc_install_1_00000000000000000000000000000000',
        )).isValid,
        isFalse,
      );
      final wrongPlatform = OpcPredmetCreationLicense(
        db,
        clock: () => now,
        parser: parser,
        platform: OpcLocalLicensePlatform.web,
      );
      expect(await wrongPlatform.installPermanentActivation(signed), isFalse);
    },
  );

  testWidgets('expired trial blocks only manual new PREDMET in the list UI', (
    tester,
  ) async {
    final db = createTestDatabase();
    final auth = AuthRepository(db);
    final session = SessionService();
    var now = DateTime.utc(2026, 10, 22, 9);
    final license = OpcPredmetCreationLicense(
      db,
      clock: () => now,
      platform: OpcLocalLicensePlatform.windows,
      random: Random(4),
    );
    final predmeti = PredmetiRepository(db, creationLicense: license);
    final admin = await auth.kreirajPrvogAdmina(
      imePrezime: 'Synthetic administrator',
      pin: '1234',
    );
    session.prijavi(admin);
    final existingId = await predmeti.kreirajPredmet(savetnikId: admin.id);
    await (db.update(db.predmeti)..where((p) => p.id.equals(existingId))).write(
      const PredmetiCompanion(ime: Value('Existing'), prezime: Value('Record')),
    );
    final existing = await predmeti.getPredmet(existingId);
    await license.evaluate();
    now = DateTime.utc(2027, 1, 22, 9);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      session.dispose();
      await db.close();
      await tester.idle();
      await tester.pump();
    });
    await tester.pumpWidget(
      wrapForTest(
        ListaPredmetaScreen(
          predmetiRepo: predmeti,
          authRepo: auth,
          podesavanjaRepo: PodesavanjaRepository(db),
          session: session,
          predmetCreationLicense: license,
          predmetiStreamOverride: Stream.value([existing]),
          runStartupSideEffects: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Probni period je istekao'), findsOneWidget);
    await tester.tap(find.text('NOVI PREDMET'));
    await tester.pumpAndSettle();
    expect((await predmeti.getSvePredmete()).length, 1);
    expect(
      find.textContaining('Postojeći PREDMETI ostaju dostupni'),
      findsWidgets,
    );
    expect(find.text('Record Existing'), findsOneWidget);
    await tester.tap(find.text('Record Existing'));
    await tester.pumpAndSettle();
    expect(find.text('Record Existing'), findsWidgets);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
  });
}

Future<String> _sign(
  Ed25519 algorithm,
  SimpleKeyPair pair,
  String installationId, {
  required String platform,
}) async {
  final payload = <String, Object?>{
    'licenseId': 'synthetic-test-1',
    'customerId': 'synthetic-test',
    'customerLabel': 'Synthetic test',
    'packageLevel': 'potpun',
    'enabledAddOns': <String>[],
    'allowedPlatforms': <String>[platform],
    'allowedInstallationIds': <String>[installationId],
    'issuedAt': '2026-10-22T09:00:00.000Z',
    'diagnosticsLabel': 'synthetic_test',
  };
  final signature = await algorithm.sign(
    utf8.encode(OpcCanonicalJsonV1.encode(payload)),
    keyPair: pair,
  );
  return jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'payload': payload,
    'signature': base64Encode(signature.bytes),
    'signatureMetadata': <String, Object?>{
      'algorithmId': 'ed25519-v1',
      'keyId': 'test-only',
    },
  });
}
