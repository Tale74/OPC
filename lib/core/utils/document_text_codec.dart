import 'dart:convert';

const Map<String, int> _cp1252ExtensionBytes = <String, int>{
  '\u20AC': 0x80,
  '\u201A': 0x82,
  '\u0192': 0x83,
  '\u201E': 0x84,
  '\u2026': 0x85,
  '\u2020': 0x86,
  '\u2021': 0x87,
  '\u02C6': 0x88,
  '\u2030': 0x89,
  '\u0160': 0x8A,
  '\u2039': 0x8B,
  '\u0152': 0x8C,
  '\u017D': 0x8E,
  '\u2018': 0x91,
  '\u2019': 0x92,
  '\u201C': 0x93,
  '\u201D': 0x94,
  '\u2022': 0x95,
  '\u2013': 0x96,
  '\u2014': 0x97,
  '\u02DC': 0x98,
  '\u2122': 0x99,
  '\u0161': 0x9A,
  '\u203A': 0x9B,
  '\u0153': 0x9C,
  '\u017E': 0x9E,
  '\u0178': 0x9F,
};

final RegExp _mojibakeMarkerPattern = RegExp(r'[ÃÂâÅÄÆÐÈÉÊËÑØ]');

class DocumentTextCodec {
  const DocumentTextCodec();

  String normalize(String value) {
    return repairMojibake(value);
  }

  Map<String, dynamic> normalizeMap(Map<String, dynamic> value) {
    return value.map(
      (key, entry) => MapEntry(key, normalizeValue(entry)),
    );
  }

  dynamic normalizeValue(dynamic value) {
    if (value is String) {
      return normalize(value);
    }
    if (value is Map<String, dynamic>) {
      return normalizeMap(value);
    }
    if (value is List) {
      return value.map(normalizeValue).toList(growable: false);
    }
    return value;
  }
}

const documentTextCodec = DocumentTextCodec();

String repairMojibake(String value) {
  if (value.isEmpty || !_mojibakeMarkerPattern.hasMatch(value)) {
    return value;
  }

  var current = value;
  for (var i = 0; i < 2; i++) {
    final repaired = _decodeCp1252Mojibake(current);
    if (repaired == null || repaired == current) {
      break;
    }
    if (_mojibakeScore(repaired) >= _mojibakeScore(current)) {
      break;
    }
    current = repaired;
  }
  return current;
}

String? _decodeCp1252Mojibake(String value) {
  final bytes = <int>[];
  for (final rune in value.runes) {
    if (rune <= 0xFF) {
      bytes.add(rune);
      continue;
    }

    final char = String.fromCharCode(rune);
    final cp1252 = _cp1252ExtensionBytes[char];
    if (cp1252 == null) {
      return null;
    }
    bytes.add(cp1252);
  }

  try {
    return utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    return null;
  }
}

int _mojibakeScore(String value) {
  return _mojibakeMarkerPattern.allMatches(value).length;
}
