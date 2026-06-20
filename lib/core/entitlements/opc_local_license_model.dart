import 'opc_entitlement_policy.dart';
import 'opc_license_signature_verifier.dart';

enum OpcLocalLicensePlatform {
  windows,
  android,
}

enum OpcLocalLicenseFailureReason {
  malformedEnvelope,
  unsupportedSchema,
  missingRequiredField,
  unknownPackage,
  noSupportedPlatforms,
  noAllowedInstallations,
  wrongPlatform,
  wrongInstallation,
  licenseNotYetValid,
  licenseExpired,
  missingSignature,
  signatureVerificationFailed,
}

final class OpcLocalLicenseEnvelope {
  const OpcLocalLicenseEnvelope({
    required this.schemaVersion,
    required this.payload,
    required this.signature,
    this.signatureMetadata = const OpcLicenseSignatureMetadata(),
  });

  final int schemaVersion;
  final Map<String, Object?> payload;
  final String signature;
  final OpcLicenseSignatureMetadata signatureMetadata;
}

final class OpcLocalLicensePayload {
  const OpcLocalLicensePayload({
    required this.licenseId,
    required this.customerId,
    required this.customerLabel,
    required this.packageLevel,
    required this.enabledAddOns,
    required this.allowedPlatforms,
    required this.allowedInstallationIds,
    required this.issuedAt,
    required this.diagnosticsLabel,
    this.validFrom,
    this.expiresAt,
    this.saasTenantId,
    this.saasAccountId,
  });

  final String licenseId;
  final String customerId;
  final String customerLabel;
  final OpcPackageLevel packageLevel;
  final Set<OpcAddOn> enabledAddOns;
  final Set<OpcLocalLicensePlatform> allowedPlatforms;
  final Set<String> allowedInstallationIds;
  final DateTime issuedAt;
  final DateTime? validFrom;
  final DateTime? expiresAt;
  final String diagnosticsLabel;
  final String? saasTenantId;
  final String? saasAccountId;
}

final class OpcLocalLicenseEvaluation {
  const OpcLocalLicenseEvaluation._({
    required this.isValid,
    required this.ignoredAddOnIds,
    this.payload,
    this.failureReason,
    this.signatureResult,
  });

  const OpcLocalLicenseEvaluation.valid({
    required OpcLocalLicensePayload payload,
    required Set<String> ignoredAddOnIds,
    required OpcLicenseSignatureVerificationResult signatureResult,
  }) : this._(
          isValid: true,
          payload: payload,
          ignoredAddOnIds: ignoredAddOnIds,
          signatureResult: signatureResult,
        );

  const OpcLocalLicenseEvaluation.failClosed({
    required OpcLocalLicenseFailureReason reason,
    Set<String> ignoredAddOnIds = const <String>{},
    OpcLicenseSignatureVerificationResult? signatureResult,
  }) : this._(
          isValid: false,
          failureReason: reason,
          ignoredAddOnIds: ignoredAddOnIds,
          signatureResult: signatureResult,
        );

  final bool isValid;
  final OpcLocalLicensePayload? payload;
  final OpcLocalLicenseFailureReason? failureReason;
  final Set<String> ignoredAddOnIds;
  final OpcLicenseSignatureVerificationResult? signatureResult;

  OpcEntitlementPayload toEntitlementPayload() {
    final payload = this.payload;
    if (!isValid || payload == null) {
      return OpcEntitlementPayload.safeProductionFallback;
    }

    return OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.localLicense,
      environment: OpcEntitlementEnvironment.production,
      packageLevel: payload.packageLevel,
      enabledAddOns: payload.enabledAddOns,
      diagnosticsLabel: payload.diagnosticsLabel,
    );
  }
}
