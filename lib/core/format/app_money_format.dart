import 'package:intl/intl.dart';

final NumberFormat _srMoneyFormat = NumberFormat('#,##0.00', 'sr_Latn_RS');
final RegExp _plainMoneyPattern = RegExp(r'^\d+(?:\.\d{1,2})?$');
final RegExp _serbianMoneyPattern = RegExp(
  r'^\d{1,3}(?:[.\s]\d{3})+(?:,\d{2})?$',
);

double parseMoneyInput(String? input) {
  if (input == null) return 0.0;

  final trimmed = input.trim();
  if (trimmed.isEmpty) return 0.0;

  final withoutSuffix = trimmed.replaceFirst(
    RegExp(r'\s*rsd\s*$', caseSensitive: false),
    '',
  );
  final compact = withoutSuffix.replaceAll(RegExp(r'\s+'), '');
  if (compact.contains('-')) return 0.0;

  if (_plainMoneyPattern.hasMatch(compact)) {
    return double.tryParse(compact) ?? 0.0;
  }

  if (_serbianMoneyPattern.hasMatch(withoutSuffix)) {
    final normalized = compact.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  return 0.0;
}

String formatMoneyRsd(double? value) =>
    '${_srMoneyFormat.format(value ?? 0.0)} RSD';

String formatMoneyNumber(double? value) => _srMoneyFormat.format(value ?? 0.0);

/// Parses a manually entered IRiU amount without changing its business value.
///
/// Both Serbian and keyboard-friendly decimal separators are accepted. When
/// more than one separator is present, the last one is the decimal separator
/// and the preceding separators are treated as grouping separators.
double? tryParseSerbianManualAmount(String? input) {
  if (input == null) return 0.0;

  final compact = input
      .trim()
      .replaceFirst(RegExp(r'\s*rsd\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), '');
  if (compact.isEmpty) return 0.0;
  if (!RegExp(r'^\d+(?:[.,]\d+)*$').hasMatch(compact)) return null;

  final separators = RegExp(r'[.,]').allMatches(compact).toList();
  if (separators.isEmpty) return double.tryParse(compact);

  final lastSeparator = separators.last.start;
  final decimalDigits = compact.length - lastSeparator - 1;
  if (decimalDigits < 1 || decimalDigits > 2) {
    if (separators.length == 1 && decimalDigits == 3) {
      return double.tryParse(compact.replaceAll(RegExp(r'[.,]'), ''));
    }
    return null;
  }

  final integerPart = compact
      .substring(0, lastSeparator)
      .replaceAll(RegExp(r'[.,]'), '');
  final fractionPart = compact.substring(lastSeparator + 1);
  return double.tryParse('$integerPart.$fractionPart');
}

String? normalizeSerbianManualAmount(String? input) {
  final parsed = tryParseSerbianManualAmount(input);
  if (parsed == null) return null;
  return parsed > 0 ? formatMoneyNumber(parsed) : '';
}
