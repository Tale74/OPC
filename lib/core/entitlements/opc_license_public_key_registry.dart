import 'opc_license_signature_verifier.dart';

/// Single in-app trust root for production local-license verification.
///
/// This file may contain only approved public verification keys.
/// Never add private keys, customer licenses, issuer logic, or test keys here.
/// The OWNER-authorized offline issuer generated the public verification key
/// on 2026-10-22. Only the public half is embedded in this application.
final class OpcLicensePublicKeyRegistry {
  const OpcLicensePublicKeyRegistry._();

  /// Approved production public keys by key id.
  ///
  /// Future insertion must add only public key material. Private signing keys
  /// must remain outside the app, repository, customer device, and customer
  /// build artifacts.
  static const Map<String, String> productionPublicKeysById = <String, String>{
    'opc-owner-20261022': '+agv7s0bizhElI3LoyS0VTiTU4fhkxGOTgZctL0pdSY=',
  };

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
