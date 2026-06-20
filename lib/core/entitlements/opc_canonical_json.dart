import 'dart:convert';

final class OpcCanonicalJsonV1 {
  const OpcCanonicalJsonV1._();

  static String encode(Object? value) {
    return _encodeValue(_normalize(value));
  }

  static Object? _normalize(Object? value) {
    if (value == null || value is String || value is bool || value is num) {
      return value;
    }
    if (value is List<Object?>) {
      return value.map(_normalize).toList(growable: false);
    }
    if (value is Map<String, Object?>) {
      final normalized = <String, Object?>{};
      for (final key in value.keys.toList()..sort()) {
        normalized[key] = _normalize(value[key]);
      }
      return normalized;
    }
    throw const FormatException('Unsupported canonical JSON value.');
  }

  static String _encodeValue(Object? value) {
    if (value is Map<String, Object?>) {
      final buffer = StringBuffer('{');
      var first = true;
      for (final entry in value.entries) {
        if (!first) buffer.write(',');
        first = false;
        buffer
          ..write(jsonEncode(entry.key))
          ..write(':')
          ..write(_encodeValue(entry.value));
      }
      return (buffer..write('}')).toString();
    }
    if (value is List<Object?>) {
      return '[${value.map(_encodeValue).join(',')}]';
    }
    return jsonEncode(value);
  }
}
