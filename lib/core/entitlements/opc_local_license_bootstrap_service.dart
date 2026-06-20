import 'dart:io';

import '../installation/opc_installation_id_repository.dart';
import 'opc_entitlement_policy.dart';
import 'opc_license_public_key_registry.dart';
import 'opc_local_license_model.dart';
import 'opc_local_license_parser.dart';
import 'opc_local_license_repository.dart';

typedef OpcLocalLicensePlatformProvider = OpcLocalLicensePlatform? Function();
typedef OpcLocalLicenseInstallationIdProvider = Future<String> Function();

enum OpcLocalLicenseBootstrapStatus {
  missing,
  valid,
  invalid,
}

enum OpcLocalLicenseBootstrapSafeReason {
  none,
  noInstalledLicense,
  readFailed,
  parseOrVerificationFailed,
  platformMismatch,
  installationMismatch,
}

final class OpcLocalLicenseBootstrapResult {
  const OpcLocalLicenseBootstrapResult._({
    required this.status,
    required this.effectivePackage,
    required this.payload,
    required this.safeReason,
    this.evaluation,
  });

  const OpcLocalLicenseBootstrapResult.missing()
      : this._(
          status: OpcLocalLicenseBootstrapStatus.missing,
          effectivePackage: OpcPackageLevel.osnovni,
          payload: OpcEntitlementPayload.safeProductionFallback,
          safeReason: OpcLocalLicenseBootstrapSafeReason.noInstalledLicense,
        );

  const OpcLocalLicenseBootstrapResult.invalid({
    required OpcLocalLicenseBootstrapSafeReason safeReason,
    OpcLocalLicenseEvaluation? evaluation,
  }) : this._(
          status: OpcLocalLicenseBootstrapStatus.invalid,
          effectivePackage: OpcPackageLevel.osnovni,
          payload: OpcEntitlementPayload.safeProductionFallback,
          safeReason: safeReason,
          evaluation: evaluation,
        );

  OpcLocalLicenseBootstrapResult.valid({
    required OpcLocalLicenseEvaluation evaluation,
  }) : this._(
          status: OpcLocalLicenseBootstrapStatus.valid,
          effectivePackage: evaluation.toEntitlementPayload().packageLevel,
          payload: evaluation.toEntitlementPayload(),
          safeReason: OpcLocalLicenseBootstrapSafeReason.none,
          evaluation: evaluation,
        );

  final OpcLocalLicenseBootstrapStatus status;
  final OpcPackageLevel effectivePackage;
  final OpcEntitlementPayload payload;
  final OpcLocalLicenseBootstrapSafeReason safeReason;
  final OpcLocalLicenseEvaluation? evaluation;
}

final class OpcLocalLicenseBootstrapService {
  OpcLocalLicenseBootstrapService({
    OpcLocalLicenseRepository? repository,
    OpcInstallationIdRepository? installationIdRepository,
    OpcLocalLicenseInstallationIdProvider? installationIdProvider,
    OpcLocalLicenseParser? parser,
    OpcLocalLicensePlatformProvider? platformProvider,
  })  : _repository = repository ?? OpcLocalLicenseRepository(),
        _installationIdProvider = installationIdProvider ??
            (installationIdRepository ?? OpcInstallationIdRepository())
                .getOrCreateInstallationId,
        _parser = parser ??
            OpcLocalLicenseParser(
              verifier: OpcLicensePublicKeyRegistry.createProductionVerifier(),
            ),
        _platformProvider = platformProvider ?? _currentPlatform;

  final OpcLocalLicenseRepository _repository;
  final OpcLocalLicenseInstallationIdProvider _installationIdProvider;
  final OpcLocalLicenseParser _parser;
  final OpcLocalLicensePlatformProvider _platformProvider;

  Future<OpcLocalLicenseBootstrapResult> evaluateInstalledLicense() async {
    final String? licenseText;
    try {
      licenseText = await _repository.readInstalledLicenseText();
    } catch (_) {
      return const OpcLocalLicenseBootstrapResult.invalid(
        safeReason: OpcLocalLicenseBootstrapSafeReason.readFailed,
      );
    }

    if (licenseText == null) {
      return const OpcLocalLicenseBootstrapResult.missing();
    }

    final String installationId;
    try {
      installationId = await _installationIdProvider();
    } catch (_) {
      return const OpcLocalLicenseBootstrapResult.invalid(
        safeReason: OpcLocalLicenseBootstrapSafeReason.readFailed,
      );
    }

    final evaluation = await _parser.evaluate(
      licenseText,
      currentPlatform: _platformProvider(),
      installationId: installationId,
    );
    if (evaluation.isValid) {
      return OpcLocalLicenseBootstrapResult.valid(evaluation: evaluation);
    }

    return OpcLocalLicenseBootstrapResult.invalid(
      safeReason: _safeReasonFor(evaluation.failureReason),
      evaluation: evaluation,
    );
  }

  static OpcLocalLicenseBootstrapSafeReason _safeReasonFor(
    OpcLocalLicenseFailureReason? reason,
  ) {
    return switch (reason) {
      OpcLocalLicenseFailureReason.wrongPlatform =>
        OpcLocalLicenseBootstrapSafeReason.platformMismatch,
      OpcLocalLicenseFailureReason.wrongInstallation =>
        OpcLocalLicenseBootstrapSafeReason.installationMismatch,
      _ => OpcLocalLicenseBootstrapSafeReason.parseOrVerificationFailed,
    };
  }

  static OpcLocalLicensePlatform? _currentPlatform() {
    if (Platform.isWindows) return OpcLocalLicensePlatform.windows;
    if (Platform.isAndroid) return OpcLocalLicensePlatform.android;
    return null;
  }
}
