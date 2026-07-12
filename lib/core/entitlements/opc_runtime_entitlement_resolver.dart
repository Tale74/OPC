import 'opc_entitlement_policy.dart';
import 'opc_local_license_bootstrap_service.dart';

typedef OpcInstalledLicenseEvaluator =
    Future<OpcLocalLicenseBootstrapResult> Function();

final class OpcRuntimeEntitlementResolver {
  const OpcRuntimeEntitlementResolver({
    this.developmentPotpunActive =
        OpcNativeDevelopmentBuildMode.developmentPotpunActive,
    this.developmentConfigurationValid =
        OpcNativeDevelopmentBuildMode.configurationValid,
    OpcInstalledLicenseEvaluator? evaluateInstalledLicense,
  }) : _evaluateInstalledLicense = evaluateInstalledLicense;

  final bool developmentPotpunActive;
  final bool developmentConfigurationValid;
  final OpcInstalledLicenseEvaluator? _evaluateInstalledLicense;

  Future<OpcEntitlementPolicy> resolve() async {
    if (!developmentConfigurationValid) {
      throw StateError(
        'Nepoznata OPC_FINAL_PACKAGE_LICENSING build vrednost. '
        'Dozvoljeno je samo true ili false.',
      );
    }
    if (developmentPotpunActive) {
      return OpcEntitlementPolicy.fromPayload(
        OpcEntitlementPayload.presentationPotpun,
      );
    }

    final evaluator =
        _evaluateInstalledLicense ??
        OpcLocalLicenseBootstrapService().evaluateInstalledLicense;
    final result = await evaluator();
    return OpcEntitlementPolicy.fromPayload(result.payload);
  }
}
