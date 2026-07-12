import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';

class ParteAuthorizationException implements Exception {
  const ParteAuthorizationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ParteAuthorization {
  const ParteAuthorization();

  void requirePreparationAccess({
    required KorisniciData user,
    required OpcEntitlementPolicy entitlement,
  }) {
    if (!user.aktivan ||
        (user.uloga != 'ADMINISTRATOR' && user.uloga != 'SAVETNIK')) {
      throw const ParteAuthorizationException(
        'Korisnik nema dozvolu za PARTE pripremu.',
      );
    }
    if (!entitlement.isModuleAvailable(OpcModule.advancedParte)) {
      throw const ParteAuthorizationException(
        'Napredna PARTE priprema nije dostupna u aktivnom paketu.',
      );
    }
  }

  void requireTemplateAdministration(KorisniciData user) {
    if (!user.aktivan || user.uloga != 'ADMINISTRATOR') {
      throw const ParteAuthorizationException(
        'Samo ADMINISTRATOR može da upravlja FIRMA PARTE šablonima.',
      );
    }
  }
}
