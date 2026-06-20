import 'app_text_format.dart';

const Map<String, String> _identifierAsciiReplacements = <String, String>{
  '\u0161': 's',
  '\u0160': 'S',
  '\u0111': 'dj',
  '\u0110': 'DJ',
  '\u010d': 'c',
  '\u010c': 'C',
  '\u0107': 'c',
  '\u0106': 'C',
  '\u017e': 'z',
  '\u017d': 'Z',
};

String _identifierToAscii(String value) {
  var normalized = value;
  _identifierAsciiReplacements.forEach((source, target) {
    normalized = normalized.replaceAll(source, target);
  });
  return normalized;
}

String normalizeInternalIdentifier(String value) {
  final collapsed = normalizeWhitespace(value);
  final ascii = _identifierToAscii(collapsed).toUpperCase();
  final normalized = ascii
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return normalized;
}

String resolveDisplayLabel({
  required String internalName,
  String? displayLabel,
  Map<String, String> fallbackDisplayLabels = const {},
}) {
  final normalizedDisplay = normalizeWhitespace(displayLabel ?? '');
  if (normalizedDisplay.isNotEmpty) return normalizedDisplay;
  final normalizedInternal = normalizeInternalIdentifier(internalName);
  return fallbackDisplayLabels[normalizedInternal] ?? normalizedInternal;
}
