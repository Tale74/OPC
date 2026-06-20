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
