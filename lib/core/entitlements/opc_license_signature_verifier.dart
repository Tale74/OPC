import 'dart:convert';

import 'package:cryptography/cryptography.dart';

final class OpcLicenseSignatureMetadata {
  const OpcLicenseSignatureMetadata({
    this.algorithmId = '',
    this.keyId = '',
  });

  final String algorithmId;
  final String keyId;
}

final class OpcLicenseSignatureInput {
  const OpcLicenseSignatureInput({
    required this.canonicalPayload,
    required this.signature,
    required this.metadata,
  });

  final String canonicalPayload;
  final String signature;
  final OpcLicenseSignatureMetadata metadata;
}

enum OpcLicenseSignatureFailureReason {
  unimplemented,
  missingSignature,
  unsupportedAlgorithm,
  unknownKeyId,
  malformedSignature,
  invalidSignature,
  verificationError,
}

final class OpcLicenseSignatureVerificationResult {
  const OpcLicenseSignatureVerificationResult._({
    required this.isValid,
    this.failureReason,
  });

  const OpcLicenseSignatureVerificationResult.valid()
      : this._(isValid: true);

  const OpcLicenseSignatureVerificationResult.invalid(
    OpcLicenseSignatureFailureReason reason,
  ) : this._(isValid: false, failureReason: reason);

  final bool isValid;
  final OpcLicenseSignatureFailureReason? failureReason;
}

abstract interface class OpcLicenseSignatureVerifier {
  Future<OpcLicenseSignatureVerificationResult> verify(
    OpcLicenseSignatureInput input,
  );
}

final class OpcFailClosedLicenseSignatureVerifier
    implements OpcLicenseSignatureVerifier {
  const OpcFailClosedLicenseSignatureVerifier();

  @override
  Future<OpcLicenseSignatureVerificationResult> verify(
    OpcLicenseSignatureInput input,
  ) async {
    if (input.signature.trim().isEmpty) {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.missingSignature,
      );
    }
    return const OpcLicenseSignatureVerificationResult.invalid(
      OpcLicenseSignatureFailureReason.unimplemented,
    );
  }
}

final class OpcEd25519LicenseSignatureVerifier
    implements OpcLicenseSignatureVerifier {
  const OpcEd25519LicenseSignatureVerifier({
    required Map<String, String> publicKeysById,
    Ed25519? algorithm,
  })  : _publicKeysById = publicKeysById,
        _algorithm = algorithm;

  static const algorithmId = 'ed25519-v1';

  final Map<String, String> _publicKeysById;
  final Ed25519? _algorithm;

  @override
  Future<OpcLicenseSignatureVerificationResult> verify(
    OpcLicenseSignatureInput input,
  ) async {
    if (input.signature.trim().isEmpty) {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.missingSignature,
      );
    }
    if (input.metadata.algorithmId != algorithmId) {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.unsupportedAlgorithm,
      );
    }

    final publicKeyText = _publicKeysById[input.metadata.keyId];
    if (publicKeyText == null || publicKeyText.trim().isEmpty) {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.unknownKeyId,
      );
    }

    try {
      final publicKeyBytes = base64Decode(publicKeyText);
      final signatureBytes = base64Decode(input.signature);
      final publicKey = SimplePublicKey(
        publicKeyBytes,
        type: KeyPairType.ed25519,
      );
      final signature = Signature(signatureBytes, publicKey: publicKey);
      final verified = await (_algorithm ?? Ed25519()).verify(
        utf8.encode(input.canonicalPayload),
        signature: signature,
      );
      if (verified) {
        return const OpcLicenseSignatureVerificationResult.valid();
      }
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.invalidSignature,
      );
    } on FormatException {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.malformedSignature,
      );
    } catch (_) {
      return const OpcLicenseSignatureVerificationResult.invalid(
        OpcLicenseSignatureFailureReason.verificationError,
      );
    }
  }
}
