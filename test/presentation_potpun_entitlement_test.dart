import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_bootstrap_service.dart';
import 'package:opc_v4/core/entitlements/opc_runtime_entitlement_resolver.dart';

void main() {
  group('native development POTPUN entitlement mode', () {
    test('selected entitlement follows validated native build mode', () {
      const policy = OpcEntitlementPolicy.current();

      if (!OpcNativeDevelopmentBuildMode.configurationValid) {
        expect(
          () => policy.isModuleAvailable(OpcModule.predmetCore),
          throwsStateError,
        );
        return;
      }

      expect(policy.isModuleAvailable(OpcModule.predmetCore), isTrue);

      if (OpcNativeDevelopmentBuildMode.developmentPotpunActive) {
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
      'development resolver does not require installed license bootstrap',
      () async {
        final resolver = OpcRuntimeEntitlementResolver(
          developmentPotpunActive: true,
          developmentConfigurationValid: true,
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

    test(
      'final-package resolver still uses local-license bootstrap result',
      () async {
        var bootstrapCalled = false;
        final resolver = OpcRuntimeEntitlementResolver(
          developmentPotpunActive: false,
          developmentConfigurationValid: true,
          evaluateInstalledLicense: () async {
            bootstrapCalled = true;
            return const OpcLocalLicenseBootstrapResult.missing();
          },
        );

        final policy = await resolver.resolve();

        expect(bootstrapCalled, isTrue);
        expect(policy.packageLevel, OpcPackageLevel.osnovni);
        expect(policy.sourceKind, OpcEntitlementSourceKind.localLicense);
      },
    );

    test(
      'native development POTPUN enables advancedParte without license',
      () async {
        final policy = await OpcRuntimeEntitlementResolver(
          developmentPotpunActive: true,
          developmentConfigurationValid: true,
          evaluateInstalledLicense: () {
            throw StateError('development mode must not read a local license');
          },
        ).resolve();

        expect(policy.packageLevel, OpcPackageLevel.potpun);
        expect(policy.isModuleAvailable(OpcModule.advancedParte), isTrue);
        expect(policy.diagnostics.safeLabel, 'presentation_potpun_owner_build');

        final ordinaryPotpun = _policy(OpcPackageLevel.potpun);
        for (final module in OpcModule.values) {
          expect(
            policy.isModuleAvailable(module),
            ordinaryPotpun.isModuleAvailable(module),
            reason: module.name,
          );
        }
      },
    );

    test(
      'unknown native build configuration fails without choosing a package',
      () {
        final resolver = OpcRuntimeEntitlementResolver(
          developmentPotpunActive: false,
          developmentConfigurationValid: false,
          evaluateInstalledLicense: () async =>
              const OpcLocalLicenseBootstrapResult.missing(),
        );

        expect(resolver.resolve, throwsStateError);
      },
    );

    test('development package resolution is platform-neutral', () async {
      Future<OpcEntitlementPolicy> resolveForSyntheticPlatform(String _) {
        return OpcRuntimeEntitlementResolver(
          developmentPotpunActive: true,
          developmentConfigurationValid: true,
          evaluateInstalledLicense: () {
            throw StateError('development mode must not read a local license');
          },
        ).resolve();
      }

      final windows = await resolveForSyntheticPlatform('windows');
      final android = await resolveForSyntheticPlatform('android');
      expect(windows.diagnostics.toSafeMap(), android.diagnostics.toSafeMap());
      expect(windows.packageLevel, OpcPackageLevel.potpun);
    });

    test('package policy still distinguishes Osnovni, Srednji and Potpun', () {
      final osnovni = _policy(OpcPackageLevel.osnovni);
      final srednji = _policy(OpcPackageLevel.srednji);
      final potpun = _policy(OpcPackageLevel.potpun);

      expect(osnovni.isModuleAvailable(OpcModule.podsetnik), isFalse);
      expect(osnovni.isModuleAvailable(OpcModule.stanjeRobe), isFalse);
      expect(osnovni.isModuleAvailable(OpcModule.advancedParte), isFalse);

      expect(srednji.isModuleAvailable(OpcModule.podsetnik), isTrue);
      expect(srednji.isModuleAvailable(OpcModule.stanjeRobe), isFalse);
      expect(srednji.isModuleAvailable(OpcModule.advancedParte), isFalse);

      expect(potpun.isModuleAvailable(OpcModule.podsetnik), isTrue);
      expect(potpun.isModuleAvailable(OpcModule.stanjeRobe), isTrue);
      expect(potpun.isModuleAvailable(OpcModule.advancedParte), isTrue);
    });

    test('production SREDNJI keeps optional advancedParte policy', () {
      final locked = _policy(OpcPackageLevel.srednji);
      final entitled = OpcEntitlementPolicy.fromPayload(
        const OpcEntitlementPayload(
          schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
          sourceKind: OpcEntitlementSourceKind.localLicense,
          environment: OpcEntitlementEnvironment.production,
          packageLevel: OpcPackageLevel.srednji,
          enabledAddOns: {OpcAddOn.advancedParte},
        ),
      );

      expect(locked.isModuleAvailable(OpcModule.advancedParte), isFalse);
      expect(entitled.isModuleAvailable(OpcModule.advancedParte), isTrue);
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
