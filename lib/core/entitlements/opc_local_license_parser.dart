import 'dart:convert';

import 'opc_canonical_json.dart';
import 'opc_entitlement_policy.dart';
import 'opc_license_signature_verifier.dart';
import 'opc_local_license_model.dart';

final class OpcLocalLicenseParser {
  const OpcLocalLicenseParser({
    this.verifier = const OpcFailClosedLicenseSignatureVerifier(),
    this.clock,
  });

  static const int supportedSchemaVersion = 1;

  final OpcLicenseSignatureVerifier verifier;
  final DateTime Function()? clock;

  Future<OpcLocalLicenseEvaluation> evaluate(
    String licenseText, {
    OpcLocalLicensePlatform? currentPlatform,
    String? installationId,
  }) async {
    final envelope = _parseEnvelope(licenseText);
    if (envelope == null) {
      return const OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.malformedEnvelope,
      );
    }
    if (envelope.schemaVersion != supportedSchemaVersion) {
      return const OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.unsupportedSchema,
      );
    }
    if (envelope.signature.trim().isEmpty) {
      return const OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.missingSignature,
        signatureResult: OpcLicenseSignatureVerificationResult.invalid(
          OpcLicenseSignatureFailureReason.missingSignature,
        ),
      );
    }

    final parsed = _parsePayload(envelope.payload);
    if (parsed.failureReason != null) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: parsed.failureReason!,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
      );
    }

    final payload = parsed.payload!;
    if (currentPlatform != null &&
        !payload.allowedPlatforms.contains(currentPlatform)) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.wrongPlatform,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
      );
    }
    if (installationId != null &&
        !payload.allowedInstallationIds.contains(installationId)) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.wrongInstallation,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
      );
    }

    final now = (clock ?? DateTime.now)();
    if (payload.validFrom != null && now.isBefore(payload.validFrom!)) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.licenseNotYetValid,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
      );
    }
    if (payload.expiresAt != null && now.isAfter(payload.expiresAt!)) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.licenseExpired,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
      );
    }

    final signatureResult = await verifier.verify(
      OpcLicenseSignatureInput(
        canonicalPayload: OpcCanonicalJsonV1.encode(envelope.payload),
        signature: envelope.signature,
        metadata: envelope.signatureMetadata,
      ),
    );
    if (!signatureResult.isValid) {
      return OpcLocalLicenseEvaluation.failClosed(
        reason: OpcLocalLicenseFailureReason.signatureVerificationFailed,
        ignoredAddOnIds: parsed.ignoredAddOnIds,
        signatureResult: signatureResult,
      );
    }

    return OpcLocalLicenseEvaluation.valid(
      payload: payload,
      ignoredAddOnIds: parsed.ignoredAddOnIds,
      signatureResult: signatureResult,
    );
  }

  OpcLocalLicenseEnvelope? _parseEnvelope(String licenseText) {
    try {
      final decoded = jsonDecode(licenseText.trim());
      if (decoded is! Map<String, Object?>) return null;

      final schemaVersion = decoded['schemaVersion'];
      final payload = decoded['payload'];
      final signature = decoded['signature'];
      if (schemaVersion is! int ||
          payload is! Map<String, Object?> ||
          signature is! String) {
        return null;
      }

      final signatureMetadata = decoded['signatureMetadata'];
      return OpcLocalLicenseEnvelope(
        schemaVersion: schemaVersion,
        payload: payload,
        signature: signature,
        signatureMetadata: OpcLicenseSignatureMetadata(
          algorithmId: _stringFromMap(signatureMetadata, 'algorithmId') ?? '',
          keyId: _stringFromMap(signatureMetadata, 'keyId') ?? '',
        ),
      );
    } catch (_) {
      return null;
    }
  }

  _ParsedPayload _parsePayload(Map<String, Object?> payload) {
    final licenseId = _requiredString(payload['licenseId']);
    final customerId = _requiredString(payload['customerId']);
    final customerLabel = _requiredString(payload['customerLabel']);
    final packageLevelText = _requiredString(payload['packageLevel']);
    final diagnosticsLabel = _requiredString(payload['diagnosticsLabel']);
    final issuedAt = _parseRequiredDate(payload['issuedAt']);

    if (licenseId == null ||
        customerId == null ||
        customerLabel == null ||
        packageLevelText == null ||
        diagnosticsLabel == null ||
        issuedAt == null) {
      return const _ParsedPayload.fail(
        OpcLocalLicenseFailureReason.missingRequiredField,
      );
    }

    final packageLevel = _parsePackageLevel(packageLevelText);
    if (packageLevel == null) {
      return const _ParsedPayload.fail(
        OpcLocalLicenseFailureReason.unknownPackage,
      );
    }

    final parsedAddOns = _parseAddOns(payload['enabledAddOns']);
    final allowedPlatforms = _parsePlatforms(payload['allowedPlatforms']);
    if (allowedPlatforms.isEmpty) {
      return _ParsedPayload.fail(
        OpcLocalLicenseFailureReason.noSupportedPlatforms,
        ignoredAddOnIds: parsedAddOns.ignoredIds,
      );
    }

    final allowedInstallationIds = _parseStringSet(
      payload['allowedInstallationIds'],
    );
    if (allowedInstallationIds.isEmpty) {
      return _ParsedPayload.fail(
        OpcLocalLicenseFailureReason.noAllowedInstallations,
        ignoredAddOnIds: parsedAddOns.ignoredIds,
      );
    }

    return _ParsedPayload.valid(
      OpcLocalLicensePayload(
        licenseId: licenseId,
        customerId: customerId,
        customerLabel: customerLabel,
        packageLevel: packageLevel,
        enabledAddOns: parsedAddOns.addOns,
        allowedPlatforms: allowedPlatforms,
        allowedInstallationIds: allowedInstallationIds,
        issuedAt: issuedAt,
        validFrom: _parseOptionalDate(payload['validFrom']),
        expiresAt: _parseOptionalDate(payload['expiresAt']),
        diagnosticsLabel: diagnosticsLabel,
        saasTenantId: _optionalString(payload['saasTenantId']),
        saasAccountId: _optionalString(payload['saasAccountId']),
      ),
      ignoredAddOnIds: parsedAddOns.ignoredIds,
    );
  }

  static String? _stringFromMap(Object? map, String key) {
    if (map is! Map<String, Object?>) return null;
    return _optionalString(map[key]);
  }

  static String? _requiredString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _optionalString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _parseRequiredDate(Object? value) {
    final text = _requiredString(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  static DateTime? _parseOptionalDate(Object? value) {
    final text = _optionalString(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  static OpcPackageLevel? _parsePackageLevel(String value) {
    return switch (_normalized(value)) {
      'osnovni' => OpcPackageLevel.osnovni,
      'srednji' => OpcPackageLevel.srednji,
      'potpun' => OpcPackageLevel.potpun,
      _ => null,
    };
  }

  static _ParsedAddOns _parseAddOns(Object? value) {
    final addOns = <OpcAddOn>{};
    final ignored = <String>{};
    for (final id in _stringList(value)) {
      switch (_normalized(id)) {
        case 'stanjerobe':
          addOns.add(OpcAddOn.stanjeRobe);
        case 'advancedparte':
          addOns.add(OpcAddOn.advancedParte);
        case 'cituljesadeklaracijom':
          addOns.add(OpcAddOn.cituljeSaDeklaracijom);
        case 'lkocr':
          addOns.add(OpcAddOn.lkOcr);
        default:
          ignored.add(id);
      }
    }
    return _ParsedAddOns(addOns: addOns, ignoredIds: ignored);
  }

  static Set<OpcLocalLicensePlatform> _parsePlatforms(Object? value) {
    final platforms = <OpcLocalLicensePlatform>{};
    for (final id in _stringList(value)) {
      switch (_normalized(id)) {
        case 'windows':
          platforms.add(OpcLocalLicensePlatform.windows);
        case 'android':
          platforms.add(OpcLocalLicensePlatform.android);
      }
    }
    return platforms;
  }

  static Set<String> _parseStringSet(Object? value) {
    return _stringList(value)
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Iterable<String> _stringList(Object? value) {
    if (value is! List<Object?>) return const <String>[];
    return value.whereType<String>();
  }

  static String _normalized(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
  }
}

final class _ParsedAddOns {
  const _ParsedAddOns({
    required this.addOns,
    required this.ignoredIds,
  });

  final Set<OpcAddOn> addOns;
  final Set<String> ignoredIds;
}

final class _ParsedPayload {
  const _ParsedPayload._({
    required this.ignoredAddOnIds,
    this.payload,
    this.failureReason,
  });

  const _ParsedPayload.valid(
    OpcLocalLicensePayload payload, {
    required Set<String> ignoredAddOnIds,
  }) : this._(payload: payload, ignoredAddOnIds: ignoredAddOnIds);

  const _ParsedPayload.fail(
    OpcLocalLicenseFailureReason reason, {
    Set<String> ignoredAddOnIds = const <String>{},
  }) : this._(
          failureReason: reason,
          ignoredAddOnIds: ignoredAddOnIds,
        );

  final OpcLocalLicensePayload? payload;
  final OpcLocalLicenseFailureReason? failureReason;
  final Set<String> ignoredAddOnIds;
}
