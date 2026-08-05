import '../../../../core/constants/iriu_constants.dart';

/// User-facing integrity error. This is deliberately not an item name: an
/// unresolved KORISNIK_* identity is a broken KATALOG reference, not a valid
/// business category.
const String unresolvedIriuCatalogItemLabel =
    'GREŠKA KATALOGA: stavka nije razrešena';

final class IriuDisplayNameResolution {
  const IriuDisplayNameResolution._({
    required this.internalName,
    required this.displayName,
  });

  const IriuDisplayNameResolution.resolved({
    required String internalName,
    required String displayName,
  }) : this._(internalName: internalName, displayName: displayName);

  const IriuDisplayNameResolution.unresolved({required String internalName})
    : this._(internalName: internalName, displayName: null);

  final String internalName;
  final String? displayName;

  bool get isResolved => displayName != null;
  String get userFacingText => displayName ?? unresolvedIriuCatalogItemLabel;
}

final RegExp _userIriuInternalNamePattern = RegExp(r'^KORISNIK_\d+$');

bool isTechnicalIriuDisplayName({
  required String internalName,
  required String displayName,
}) {
  final normalizedDisplayName = displayName.trim();
  return normalizedDisplayName.isEmpty ||
      _userIriuInternalNamePattern.hasMatch(normalizedDisplayName) ||
      normalizedDisplayName == internalName.trim();
}

/// Resolves an IRIU row label from one authoritative source order:
///
/// 1. current KATALOG category name;
/// 2. built-in IRIU name;
/// 3. a non-technical name already stored on the row;
/// 4. an explicit KATALOG-integrity error state (not a fabricated item name).
IriuDisplayNameResolution resolveIriuDisplayName({
  required String internalName,
  Map<String, String> catalogDisplayNames = const <String, String>{},
  String? storedDisplayName,
}) {
  final catalogName = catalogDisplayNames[internalName]?.trim();
  if (catalogName != null && catalogName.isNotEmpty) {
    return IriuDisplayNameResolution.resolved(
      internalName: internalName,
      displayName: catalogName,
    );
  }

  final builtInName = IriuK.naziviPrikaz[internalName]?.trim();
  if (builtInName != null && builtInName.isNotEmpty) {
    return IriuDisplayNameResolution.resolved(
      internalName: internalName,
      displayName: builtInName,
    );
  }

  final storedName = storedDisplayName?.trim();
  if (storedName != null &&
      storedName.isNotEmpty &&
      !isTechnicalIriuDisplayName(
        internalName: internalName,
        displayName: storedName,
      )) {
    return IriuDisplayNameResolution.resolved(
      internalName: internalName,
      displayName: storedName,
    );
  }

  return IriuDisplayNameResolution.unresolved(internalName: internalName);
}
