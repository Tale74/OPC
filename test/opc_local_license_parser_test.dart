import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/entitlements/opc_canonical_json.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/entitlements/opc_license_public_key_registry.dart';
import 'package:opc_v4/core/entitlements/opc_license_signature_verifier.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_bootstrap_service.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_model.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_parser.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_repository.dart';

void main() {
  group('OpcLocalLicenseParser', () {
    test('malformed license fails closed', () async {
      final result = await const OpcLocalLicenseParser().evaluate('not-json');

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.malformedEnvelope,
      );
      expect(
        result.toEntitlementPayload().packageLevel,
        OpcPackageLevel.osnovni,
      );
    });

    test('unsupported schema fails closed', () async {
      final result = await const OpcLocalLicenseParser().evaluate(
        _licenseText(schemaVersion: 999),
      );

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.unsupportedSchema,
      );
    });

    test('missing signature fails closed', () async {
      final result = await const OpcLocalLicenseParser().evaluate(
        _licenseText(signature: ''),
      );

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.missingSignature,
      );
    });

    test('default verifier fails closed', () async {
      final result = await const OpcLocalLicenseParser().evaluate(
        _licenseText(),
      );

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.signatureVerificationFailed,
      );
      expect(
        result.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.unimplemented,
      );
    });

    test('unknown package fails closed', () async {
      final result = await const OpcLocalLicenseParser().evaluate(
        _licenseText(payloadOverrides: <String, Object?>{
          'packageLevel': 'enterprise',
        }),
      );

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.unknownPackage,
      );
    });

    test('unknown add-on is ignored', () async {
      final result = await const OpcLocalLicenseParser(
        verifier: _AlwaysValidSignatureVerifier(),
      ).evaluate(
        _licenseText(payloadOverrides: <String, Object?>{
          'enabledAddOns': <String>['stanjeRobe', 'unknownAddon'],
        }),
      );

      expect(result.isValid, isTrue);
      expect(result.ignoredAddOnIds, contains('unknownAddon'));
      expect(result.payload!.enabledAddOns, contains(OpcAddOn.stanjeRobe));
      expect(result.payload!.enabledAddOns.length, 1);
    });

    test('wrong platform fails closed', () async {
      final result = await const OpcLocalLicenseParser(
        verifier: _AlwaysValidSignatureVerifier(),
      ).evaluate(
        _licenseText(),
        currentPlatform: OpcLocalLicensePlatform.android,
      );

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.wrongPlatform,
      );
    });

    test('wrong installation id fails closed', () async {
      final result = await const OpcLocalLicenseParser(
        verifier: _AlwaysValidSignatureVerifier(),
      ).evaluate(_licenseText(), installationId: 'other_installation');

      expect(result.isValid, isFalse);
      expect(
        result.failureReason,
        OpcLocalLicenseFailureReason.wrongInstallation,
      );
    });

    test('valid shape with default verifier does not unlock paid package',
        () async {
      final result = await const OpcLocalLicenseParser().evaluate(
        _licenseText(payloadOverrides: <String, Object?>{
          'packageLevel': 'potpun',
          'enabledAddOns': <String>['stanjeRobe'],
        }),
      );

      expect(result.isValid, isFalse);
      final payload = result.toEntitlementPayload();
      expect(payload.packageLevel, OpcPackageLevel.osnovni);
      expect(payload.enabledAddOns, isEmpty);
    });

    test('package and add-on normalization unlocks only known values',
        () async {
      final result = await const OpcLocalLicenseParser(
        verifier: _AlwaysValidSignatureVerifier(),
      ).evaluate(
        _licenseText(payloadOverrides: <String, Object?>{
          'packageLevel': 'SREDNJI',
          'enabledAddOns': <String>['stanje_robe', 'LK-OCR', 'other'],
          'allowedPlatforms': <String>['WINDOWS'],
        }),
        currentPlatform: OpcLocalLicensePlatform.windows,
        installationId: 'opc_install_1_00000000000000000000000000000000',
      );

      expect(result.isValid, isTrue);
      final payload = result.toEntitlementPayload();
      expect(payload.packageLevel, OpcPackageLevel.srednji);
      expect(payload.enabledAddOns, contains(OpcAddOn.stanjeRobe));
      expect(payload.enabledAddOns, contains(OpcAddOn.lkOcr));
      expect(payload.enabledAddOns.length, 2);
      expect(result.ignoredAddOnIds, contains('other'));
    });

    test('canonical JSON sorts object keys recursively', () {
      final canonical = OpcCanonicalJsonV1.encode(<String, Object?>{
        'b': 2,
        'a': <String, Object?>{
          'd': true,
          'c': <String>['x', 'y'],
        },
      });

      expect(canonical, '{"a":{"c":["x","y"],"d":true},"b":2}');
    });

    test('Ed25519 verifier accepts valid signed license shape', () async {
      final fixture = await _signedLicenseFixture();

      final result = await OpcLocalLicenseParser(
        verifier: OpcEd25519LicenseSignatureVerifier(
          publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
        ),
      ).evaluate(
        fixture.licenseText,
        currentPlatform: OpcLocalLicensePlatform.windows,
        installationId: 'opc_install_1_00000000000000000000000000000000',
      );

      expect(result.isValid, isTrue);
      expect(result.signatureResult?.isValid, isTrue);
      expect(result.toEntitlementPayload().packageLevel, OpcPackageLevel.srednji);
      expect(
        result.toEntitlementPayload().enabledAddOns,
        contains(OpcAddOn.stanjeRobe),
      );
    });

    test('Ed25519 verifier rejects tampered payload', () async {
      final fixture = await _signedLicenseFixture();
      final decoded = jsonDecode(fixture.licenseText) as Map<String, Object?>;
      final payload = decoded['payload'] as Map<String, Object?>;
      payload['packageLevel'] = 'potpun';

      final result = await OpcLocalLicenseParser(
        verifier: OpcEd25519LicenseSignatureVerifier(
          publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
        ),
      ).evaluate(jsonEncode(decoded));

      expect(result.isValid, isFalse);
      expect(
        result.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.invalidSignature,
      );
    });

    test('Ed25519 verifier rejects unknown key id', () async {
      final fixture = await _signedLicenseFixture();

      final result = await const OpcLocalLicenseParser(
        verifier: OpcEd25519LicenseSignatureVerifier(
          publicKeysById: <String, String>{},
        ),
      ).evaluate(fixture.licenseText);

      expect(result.isValid, isFalse);
      expect(
        result.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.unknownKeyId,
      );
    });

    test('production registry is empty and rejects test key license', () async {
      expect(
        OpcLicensePublicKeyRegistry.productionPublicKeysById,
        isEmpty,
      );
      expect(OpcLicensePublicKeyRegistry.hasProductionPublicKeys, isFalse);
      expect(OpcLicensePublicKeyRegistry.productionKeyCount, 0);
      expect(
        OpcLicensePublicKeyRegistry.productionRegistryStatusLabel,
        'production_keys_empty',
      );

      final fixture = await _signedLicenseFixture();
      expect(
        OpcLicensePublicKeyRegistry.productionPublicKeysById
            .containsKey(fixture.keyId),
        isFalse,
      );

      final result = await OpcLocalLicenseParser(
        verifier: OpcLicensePublicKeyRegistry.createProductionVerifier(),
      ).evaluate(fixture.licenseText);

      expect(result.isValid, isFalse);
      expect(
        result.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.unknownKeyId,
      );
    });

    test('Ed25519 verifier rejects unsupported algorithm', () async {
      final fixture = await _signedLicenseFixture(
        algorithmId: 'rsa-v1',
      );

      final result = await OpcLocalLicenseParser(
        verifier: OpcEd25519LicenseSignatureVerifier(
          publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
        ),
      ).evaluate(fixture.licenseText);

      expect(result.isValid, isFalse);
      expect(
        result.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.unsupportedAlgorithm,
      );
    });
  });

  group('OpcLocalLicenseBootstrapService', () {
    test('missing installed license returns fail-closed Osnovni', () async {
      final service = await _bootstrapService();

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.missing);
      expect(result.safeReason, OpcLocalLicenseBootstrapSafeReason.noInstalledLicense);
      expect(result.effectivePackage, OpcPackageLevel.osnovni);
      expect(result.payload.packageLevel, OpcPackageLevel.osnovni);
    });

    test('malformed installed license returns fail-closed Osnovni', () async {
      final service = await _bootstrapService(installedLicenseText: 'not-json');

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.invalid);
      expect(
        result.safeReason,
        OpcLocalLicenseBootstrapSafeReason.parseOrVerificationFailed,
      );
      expect(result.effectivePackage, OpcPackageLevel.osnovni);
      expect(
        result.evaluation?.failureReason,
        OpcLocalLicenseFailureReason.malformedEnvelope,
      );
    });

    test('test-key license through production registry fails closed', () async {
      final fixture = await _signedLicenseFixture();
      final service = await _bootstrapService(
        installedLicenseText: fixture.licenseText,
      );

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.invalid);
      expect(result.effectivePackage, OpcPackageLevel.osnovni);
      expect(
        result.evaluation?.signatureResult?.failureReason,
        OpcLicenseSignatureFailureReason.unknownKeyId,
      );
    });

    test('valid test license through injected verifier returns payload',
        () async {
      final fixture = await _signedLicenseFixture();
      final service = await _bootstrapService(
        installedLicenseText: fixture.licenseText,
        parser: OpcLocalLicenseParser(
          verifier: OpcEd25519LicenseSignatureVerifier(
            publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
          ),
        ),
      );

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.valid);
      expect(result.safeReason, OpcLocalLicenseBootstrapSafeReason.none);
      expect(result.effectivePackage, OpcPackageLevel.srednji);
      expect(result.payload.enabledAddOns, contains(OpcAddOn.stanjeRobe));
    });

    test('platform mismatch fails closed', () async {
      final fixture = await _signedLicenseFixture();
      final service = await _bootstrapService(
        installedLicenseText: fixture.licenseText,
        platformProvider: () => OpcLocalLicensePlatform.android,
        parser: OpcLocalLicenseParser(
          verifier: OpcEd25519LicenseSignatureVerifier(
            publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
          ),
        ),
      );

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.invalid);
      expect(
        result.safeReason,
        OpcLocalLicenseBootstrapSafeReason.platformMismatch,
      );
      expect(result.effectivePackage, OpcPackageLevel.osnovni);
    });

    test('installation id mismatch fails closed', () async {
      final fixture = await _signedLicenseFixture();
      final service = await _bootstrapService(
        installedLicenseText: fixture.licenseText,
        installationIdProvider: () async => 'other_installation',
        parser: OpcLocalLicenseParser(
          verifier: OpcEd25519LicenseSignatureVerifier(
            publicKeysById: <String, String>{fixture.keyId: fixture.publicKey},
          ),
        ),
      );

      final result = await service.evaluateInstalledLicense();

      expect(result.status, OpcLocalLicenseBootstrapStatus.invalid);
      expect(
        result.safeReason,
        OpcLocalLicenseBootstrapSafeReason.installationMismatch,
      );
      expect(result.effectivePackage, OpcPackageLevel.osnovni);
    });

    test('repository installs, reads, and clears raw license text', () async {
      final directory = await _tempDirectory();
      final repository = OpcLocalLicenseRepository(
        directoryProvider: () async => directory,
      );

      expect(await repository.readInstalledLicenseText(), isNull);

      await repository.installLicenseText('  {"schemaVersion":1}  ');
      expect(await repository.readInstalledLicenseText(), '{"schemaVersion":1}');

      await repository.clearInstalledLicense();
      expect(await repository.readInstalledLicenseText(), isNull);
    });
  });
}

String _licenseText({
  int schemaVersion = 1,
  String signature = 'placeholder-signature',
  Map<String, Object?> payloadOverrides = const <String, Object?>{},
}) {
  return jsonEncode(<String, Object?>{
    'schemaVersion': schemaVersion,
    'payload': <String, Object?>{
      'licenseId': 'license-1',
      'customerId': 'customer-1',
      'customerLabel': 'Customer',
      'packageLevel': 'srednji',
      'enabledAddOns': <String>['stanjeRobe'],
      'allowedPlatforms': <String>['windows'],
      'allowedInstallationIds': <String>[
        'opc_install_1_00000000000000000000000000000000',
      ],
      'issuedAt': '2026-05-19T00:00:00.000Z',
      'diagnosticsLabel': 'customer_safe_label',
      ...payloadOverrides,
    },
    'signature': signature,
    'signatureMetadata': <String, Object?>{
      'algorithmId': 'UNIMPLEMENTED',
      'keyId': 'NO_KEY',
    },
  });
}

final class _AlwaysValidSignatureVerifier
    implements OpcLicenseSignatureVerifier {
  const _AlwaysValidSignatureVerifier();

  @override
  Future<OpcLicenseSignatureVerificationResult> verify(
    OpcLicenseSignatureInput input,
  ) async {
    return const OpcLicenseSignatureVerificationResult.valid();
  }
}

final class _SignedLicenseFixture {
  const _SignedLicenseFixture({
    required this.licenseText,
    required this.publicKey,
    required this.keyId,
  });

  final String licenseText;
  final String publicKey;
  final String keyId;
}

Future<_SignedLicenseFixture> _signedLicenseFixture({
  String algorithmId = OpcEd25519LicenseSignatureVerifier.algorithmId,
}) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(List<int>.filled(32, 7));
  final publicKey = await keyPair.extractPublicKey();
  const keyId = 'test-key-1';
  final payload = <String, Object?>{
    'licenseId': 'license-1',
    'customerId': 'customer-1',
    'customerLabel': 'Customer',
    'packageLevel': 'srednji',
    'enabledAddOns': <String>['stanjeRobe'],
    'allowedPlatforms': <String>['windows'],
    'allowedInstallationIds': <String>[
      'opc_install_1_00000000000000000000000000000000',
    ],
    'issuedAt': '2026-05-19T00:00:00.000Z',
    'diagnosticsLabel': 'customer_safe_label',
  };
  final canonicalPayload = OpcCanonicalJsonV1.encode(payload);
  final signature = await algorithm.sign(
    utf8.encode(canonicalPayload),
    keyPair: keyPair,
  );

  return _SignedLicenseFixture(
    keyId: keyId,
    publicKey: base64Encode(publicKey.bytes),
    licenseText: jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'payload': payload,
      'signature': base64Encode(signature.bytes),
      'signatureMetadata': <String, Object?>{
        'algorithmId': algorithmId,
        'keyId': keyId,
      },
    }),
  );
}

Future<OpcLocalLicenseBootstrapService> _bootstrapService({
  String? installedLicenseText,
  OpcLocalLicenseParser? parser,
  OpcLocalLicensePlatformProvider? platformProvider,
  OpcLocalLicenseInstallationIdProvider? installationIdProvider,
}) async {
  final directory = await _tempDirectory();
  final repository = OpcLocalLicenseRepository(
    directoryProvider: () async => directory,
  );
  if (installedLicenseText != null) {
    await repository.installLicenseText(installedLicenseText);
  }
  return OpcLocalLicenseBootstrapService(
    repository: repository,
    installationIdProvider: installationIdProvider ??
        () async => 'opc_install_1_00000000000000000000000000000000',
    parser: parser,
    platformProvider: platformProvider ?? () => OpcLocalLicensePlatform.windows,
  );
}

Future<Directory> _tempDirectory() async {
  final directory = await Directory.systemTemp.createTemp('opc_license_test_');
  addTearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  return directory;
}
