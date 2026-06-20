import 'app_text_format.dart';
import '../utils/document_text_codec.dart';

const Map<String, String> _filenameAsciiReplacements = <String, String>{
  '\u0161': 's',
  '\u0160': 'S',
  '\u0111': 'dj',
  '\u0110': 'Dj',
  '\u010d': 'c',
  '\u010c': 'C',
  '\u0107': 'c',
  '\u0106': 'C',
  '\u017e': 'z',
  '\u017d': 'Z',
};

String _filenameToAscii(String value) {
  var normalized = repairMojibake(value);
  _filenameAsciiReplacements.forEach((source, target) {
    normalized = normalized.replaceAll(source, target);
  });
  return normalized;
}

String sanitizeFilenameSegment(String value) {
  final collapsed = normalizeWhitespace(value);
  final ascii = _filenameToAscii(collapsed);
  final sanitized = ascii
      .replaceAll(RegExp(r'[\\/:*?"<>|]+'), ' ')
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return sanitized;
}

String sanitizeFilename(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  final lastDot = trimmed.lastIndexOf('.');
  final hasExtension = lastDot > 0 && lastDot < trimmed.length - 1;
  final basenameSource = hasExtension ? trimmed.substring(0, lastDot) : trimmed;
  final extensionSource =
      hasExtension ? trimmed.substring(lastDot + 1).trim() : '';

  final basename = sanitizeFilenameSegment(
    basenameSource.replaceAll(RegExp(r'[.\s]+$'), ''),
  );
  final extension = sanitizeFilenameSegment(
    extensionSource.replaceAll(RegExp(r'[.\s]+$'), ''),
  );

  if (basename.isEmpty) return extension.isEmpty ? '' : extension;
  if (extension.isEmpty) return basename;
  return '$basename.$extension';
}

String joinFilenameParts(Iterable<String> parts, String extension) {
  final safeParts = parts
      .map(sanitizeFilenameSegment)
      .where((part) => part.isNotEmpty)
      .toList();
  final safeExtension = sanitizeFilenameSegment(
    extension.replaceAll(RegExp(r'[.\s]+$'), ''),
  );
  if (safeParts.isEmpty) return safeExtension;
  if (safeExtension.isEmpty) return safeParts.join('_');
  return '${safeParts.join('_')}.$safeExtension';
}
