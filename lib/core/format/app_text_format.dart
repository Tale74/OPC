const Map<String, String> _serbianLatinAsciiMap = <String, String>{
  '\u017e': 'z',
  '\u017d': 'Z',
  '\u0161': 's',
  '\u0160': 'S',
  '\u010d': 'c',
  '\u010c': 'C',
  '\u0107': 'c',
  '\u0106': 'C',
  '\u0111': 'dj',
  '\u0110': 'Dj',
};

String normalizeText(String value) => value.trim();

String normalizeWhitespace(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ');

String normalizeMultiline(String value) {
  final normalizedLineBreaks = value.replaceAll(RegExp(r'\r\n?'), '\n');
  final trimmedLines = normalizedLineBreaks
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
      .toList();

  return trimmedLines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

String uppercaseSerbian(String value) => value.toUpperCase();

String latinToAscii(String value) {
  var normalized = value;
  _serbianLatinAsciiMap.forEach((source, target) {
    normalized = normalized.replaceAll(source, target);
  });
  return normalized;
}

String toTitleCaseWords(String value) {
  final normalized = normalizeWhitespace(value);
  if (normalized.isEmpty) return '';
  return normalized
      .split(' ')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}

String transliterateLatinToCyrillic(String value) {
  const digraphs = <String, String>{
    '\u0044\u017e': '\u040f',
    '\u0044\u017d': '\u040f',
    '\u0064\u017e': '\u045f',
    '\u004c\u006a': '\u0409',
    '\u004c\u004a': '\u0409',
    '\u006c\u006a': '\u0459',
    '\u004e\u006a': '\u040a',
    '\u004e\u004a': '\u040a',
    '\u006e\u006a': '\u045a',
  };
  const singleChars = <String, String>{
    '\u0041': '\u0410',
    '\u0042': '\u0411',
    '\u0056': '\u0412',
    '\u0047': '\u0413',
    '\u0044': '\u0414',
    '\u0110': '\u0402',
    '\u0045': '\u0415',
    '\u017d': '\u0416',
    '\u005a': '\u0417',
    '\u0049': '\u0418',
    '\u004a': '\u0408',
    '\u004b': '\u041a',
    '\u004c': '\u041b',
    '\u004d': '\u041c',
    '\u004e': '\u041d',
    '\u004f': '\u041e',
    '\u0050': '\u041f',
    '\u0052': '\u0420',
    '\u0053': '\u0421',
    '\u0054': '\u0422',
    '\u0106': '\u040b',
    '\u0055': '\u0423',
    '\u0046': '\u0424',
    '\u0048': '\u0425',
    '\u0043': '\u0426',
    '\u010c': '\u0427',
    '\u0160': '\u0428',
    '\u0061': '\u0430',
    '\u0062': '\u0431',
    '\u0076': '\u0432',
    '\u0067': '\u0433',
    '\u0064': '\u0434',
    '\u0111': '\u0452',
    '\u0065': '\u0435',
    '\u017e': '\u0436',
    '\u007a': '\u0437',
    '\u0069': '\u0438',
    '\u006a': '\u0458',
    '\u006b': '\u043a',
    '\u006c': '\u043b',
    '\u006d': '\u043c',
    '\u006e': '\u043d',
    '\u006f': '\u043e',
    '\u0070': '\u043f',
    '\u0072': '\u0440',
    '\u0073': '\u0441',
    '\u0074': '\u0442',
    '\u0107': '\u045b',
    '\u0075': '\u0443',
    '\u0066': '\u0444',
    '\u0068': '\u0445',
    '\u0063': '\u0446',
    '\u010d': '\u0447',
    '\u0161': '\u0448',
  };

  final buffer = StringBuffer();
  var index = 0;
  while (index < value.length) {
    final end = index + 2;
    if (end <= value.length) {
      final digraph = value.substring(index, end);
      final mappedDigraph = digraphs[digraph];
      if (mappedDigraph != null) {
        buffer.write(mappedDigraph);
        index += 2;
        continue;
      }
    }

    final char = value[index];
    buffer.write(singleChars[char] ?? char);
    index += 1;
  }
  return buffer.toString();
}
