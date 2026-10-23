import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_canonical_json.dart';
import 'package:opc_v4/core/entitlements/opc_license_signature_verifier.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_model.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_parser.dart';
import 'package:opc_v4/core/entitlements/opc_predmet_creation_license.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  late Ed25519 algorithm;
  late SimpleKeyPair pair;
  late OpcLocalLicenseParser parser;

  setUp(() async {
    algorithm = Ed25519();
    pair = await algorithm.newKeyPairFromSeed(List<int>.filled(32, 9));
    final publicKey = await pair.extractPublicKey();
    parser = OpcLocalLicenseParser(
      verifier: OpcEd25519LicenseSignatureVerifier(
        publicKeysById: {'synthetic-firma': base64Encode(publicKey.bytes)},
      ),
    );
  });

  test(
    'one signed PIB+MB key works on every platform and installation',
    () async {
      final token = await _issue(algorithm, pair, '111111111', '10000001');
      for (final platform in OpcLocalLicensePlatform.values) {
        final result = await parser.evaluate(
          token,
          currentPlatform: platform,
          installationId: 'different-device-${platform.name}',
          firmaPib: ' 111111111 ',
          firmaMb: ' 10000001 ',
        );
        expect(result.isValid, isTrue, reason: platform.name);
      }
      expect(
        (await parser.evaluate(
          token,
          firmaPib: '',
          firmaMb: '10000001',
        )).failureReason,
        OpcLocalLicenseFailureReason.missingFirmaIdentity,
      );
      expect(
        (await parser.evaluate(
          token,
          firmaPib: '999999999',
          firmaMb: '10000001',
        )).failureReason,
        OpcLocalLicenseFailureReason.wrongFirma,
      );
      expect(
        (await parser.evaluate(
          token,
          firmaPib: '111111111',
          firmaMb: '99999999',
        )).failureReason,
        OpcLocalLicenseFailureReason.wrongFirma,
      );
      final altered = token.replaceFirst('10000001', '10000002');
      expect(
        (await parser.evaluate(
          altered,
          firmaPib: '111111111',
          firmaMb: '10000002',
        )).isValid,
        isFalse,
      );
    },
  );

  test(
    'first-day activation survives expiry, identity change revokes local use',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await prepareSameFirmaJsonTransferForTest(db);
      var now = DateTime.utc(2026, 10, 23);
      OpcPredmetCreationLicense service() => OpcPredmetCreationLicense(
        db,
        clock: () => now,
        parser: parser,
        platform: OpcLocalLicensePlatform.windows,
      );
      final first = await service().evaluate();
      expect(first.status, OpcPredmetLicenseStatus.trial);
      final token = await _issue(algorithm, pair, '111111111', '10000001');
      expect(await service().installPermanentActivation(token), isTrue);
      now = DateTime.utc(2027, 1, 23);
      expect(
        (await service().evaluate()).status,
        OpcPredmetLicenseStatus.activated,
      );
      await (db.update(db.firmaPodaci)..where((f) => f.id.equals(1))).write(
        const FirmaPodaciCompanion(mb: Value('10000002')),
      );
      expect(
        (await service().evaluate()).status,
        OpcPredmetLicenseStatus.expired,
      );
      final repo = PredmetiRepository(db, creationLicense: service());
      await expectLater(repo.kreirajPredmet(savetnikId: 1), throwsStateError);
      expect(await repo.getSvePredmete(), isEmpty);
      await (db.update(db.firmaPodaci)..where((f) => f.id.equals(1))).write(
        const FirmaPodaciCompanion(mb: Value('10000001')),
      );
      expect(
        (await service().evaluate()).status,
        OpcPredmetLicenseStatus.activated,
      );
    },
  );
}

Future<String> _issue(
  Ed25519 algorithm,
  SimpleKeyPair pair,
  String pib,
  String mb,
) async {
  final payload = <String, Object?>{
    'licenseId': 'synthetic-firma-one-key',
    'customerId': '$pib:$mb',
    'customerLabel': 'Synthetic FIRMA',
    'firmaPib': pib,
    'firmaMb': mb,
    'packageLevel': 'potpun',
    'enabledAddOns': <String>[],
    'issuedAt': '2026-10-23T00:00:00.000Z',
    'diagnosticsLabel': 'synthetic_firma',
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
      'keyId': 'synthetic-firma',
    },
  });
}
