import 'opc_entitlement_policy.dart';
import 'opc_local_license_bootstrap_service.dart';

typedef OpcInstalledLicenseEvaluator =
    Future<OpcLocalLicenseBootstrapResult> Function();

final class OpcRuntimeEntitlementResolver {
  const OpcRuntimeEntitlementResolver({
    this.presentationPotpunRequested =
        OpcPresentationBuildMode.presentationPotpunRequested,
    OpcInstalledLicenseEvaluator? evaluateInstalledLicense,
  }) : _evaluateInstalledLicense = evaluateInstalledLicense;

  final bool presentationPotpunRequested;
  final OpcInstalledLicenseEvaluator? _evaluateInstalledLicense;

  Future<OpcEntitlementPolicy> resolve() async {
    if (presentationPotpunRequested) {
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
