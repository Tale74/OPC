final _controlCharacters = RegExp(r'[\x00-\x1f\x7f-\x9f\u2028\u2029]');

/// Company identifiers use exact textual comparison after removing outer
/// spaces. Never coerce a JSON number or strip characters within an identifier.
String? normalizedFirmIdentifier(Object? value) {
  if (value is! String || _controlCharacters.hasMatch(value)) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? optionalFirmIdentifierError(String? value) {
  if (value == null || value.isEmpty || !_controlCharacters.hasMatch(value)) {
    return null;
  }
  return 'Identifikator FIRME mora biti tekst u jednom redu.';
}
