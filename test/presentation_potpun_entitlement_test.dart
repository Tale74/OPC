import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_bootstrap_service.dart';
import 'package:opc_v4/core/entitlements/opc_runtime_entitlement_resolver.dart';

void main() {
  group('presentation POTPUN entitlement mode', () {
    test('selected entitlement follows build-time presentation flag', () {
      const policy = OpcEntitlementPolicy.current();

      expect(policy.isModuleAvailable(OpcModule.predmetCore), isTrue);

      if (OpcPresentationBuildMode.presentationPotpunRequested) {
        expect(policy.packageLevel, OpcPackageLevel.potpun);
        expect(policy.sourceKind, OpcEntitlementSourceKind.presentationOwner);
        expect(policy.isModuleAvailable(OpcModule.podsetnik), isTrue);
        expect(policy.isModuleAvailable(OpcModule.stanjeRobe), isTrue);
      } else {
        expect(policy.packageLevel, OpcPackageLevel.osnovni);
        expect(policy.sourceKind, OpcEntitlementSourceKind.localLicense);
        expect(policy.isModuleAvailable(OpcModule.podsetnik), isFalse);
        expect(policy.isModuleAvailable(OpcModule.stanjeRobe), isFalse);
      }
    });

    test('presentation source resolves as explicit non-production Potpun', () {
      final policy = OpcEntitlementPolicy.fromPayload(
        OpcEntitlementPayload.presentationPotpun,
      );

      expect(policy.packageLevel, OpcPackageLevel.potpun);
      expect(policy.sourceKind, OpcEntitlementSourceKind.presentationOwner);
      expect(policy.environment, OpcEntitlementEnvironment.test);
      expect(policy.diagnostics.safeLabel, 'presentation_potpun_owner_build');
      expect(policy.diagnostics.isFailClosed, isFalse);
      expect(policy.isModuleAvailable(OpcModule.podsetnik), isTrue);
      expect(policy.isModuleAvailable(OpcModule.stanjeRobe), isTrue);
    });

    test(
      'presentation resolver does not require installed license bootstrap',
      () async {
        final resolver = OpcRuntimeEntitlementResolver(
          presentationPotpunRequested: true,
          evaluateInstalledLicense: () {
            throw StateError('license bootstrap must not run');
          },
        );

        final policy = await resolver.resolve();

        expect(policy.packageLevel, OpcPackageLevel.potpun);
        expect(policy.sourceKind, OpcEntitlementSourceKind.presentationOwner);
        expect(policy.isModuleAvailable(OpcModule.stanjeRobe), isTrue);
        expect(policy.isModuleAvailable(OpcModule.podsetnik), isTrue);
      },
    );

    test('normal resolver still uses local-license bootstrap result', () async {
      var bootstrapCalled = false;
      final resolver = OpcRuntimeEntitlementResolver(
        presentationPotpunRequested: false,
        evaluateInstalledLicense: () async {
          bootstrapCalled = true;
          return const OpcLocalLicenseBootstrapResult.missing();
        },
      );

      final policy = await resolver.resolve();

      expect(bootstrapCalled, isTrue);
      expect(policy.packageLevel, OpcPackageLevel.osnovni);
      expect(policy.sourceKind, OpcEntitlementSourceKind.localLicense);
    });

    test('package policy still distinguishes Osnovni, Srednji and Potpun', () {
      final osnovni = _policy(OpcPackageLevel.osnovni);
      final srednji = _policy(OpcPackageLevel.srednji);
      final potpun = _policy(OpcPackageLevel.potpun);

      expect(osnovni.isModuleAvailable(OpcModule.podsetnik), isFalse);
      expect(osnovni.isModuleAvailable(OpcModule.stanjeRobe), isFalse);

      expect(srednji.isModuleAvailable(OpcModule.podsetnik), isTrue);
      expect(srednji.isModuleAvailable(OpcModule.stanjeRobe), isFalse);

      expect(potpun.isModuleAvailable(OpcModule.podsetnik), isTrue);
      expect(potpun.isModuleAvailable(OpcModule.stanjeRobe), isTrue);
    });
  });
}

OpcEntitlementPolicy _policy(OpcPackageLevel packageLevel) {
  return OpcEntitlementPolicy.fromPayload(
    OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.localLicense,
      environment: OpcEntitlementEnvironment.production,
      packageLevel: packageLevel,
    ),
  );
}
