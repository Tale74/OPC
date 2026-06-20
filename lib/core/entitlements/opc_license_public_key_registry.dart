import 'opc_license_signature_verifier.dart';

/// Single in-app trust root for production local-license verification.
///
/// This file may contain only approved public verification keys.
/// Never add private keys, customer licenses, issuer logic, or test keys here.
/// The production registry stays empty until the user explicitly provides an
/// approved production public key id and public key value in a separate task.
final class OpcLicensePublicKeyRegistry {
  const OpcLicensePublicKeyRegistry._();

  /// Approved production public keys by key id.
  ///
  /// Future insertion must add only public key material. Private signing keys
  /// must remain outside the app, repository, customer device, and customer
  /// build artifacts.
  static const Map<String, String> productionPublicKeysById =
      <String, String>{};

  static bool get hasProductionPublicKeys =>
      productionPublicKeysById.isNotEmpty;

  static int get productionKeyCount => productionPublicKeysById.length;

  static String get productionRegistryStatusLabel {
    return hasProductionPublicKeys
        ? 'production_keys_configured'
        : 'production_keys_empty';
  }

  static OpcEd25519LicenseSignatureVerifier createProductionVerifier() {
    return const OpcEd25519LicenseSignatureVerifier(
      publicKeysById: productionPublicKeysById,
    );
  }
}
