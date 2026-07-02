import 'package:intl/intl.dart';

final DateFormat _documentDateFormat = DateFormat('dd.MM.yyyy');
final RegExp _isoDatePattern = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
final RegExp _localizedDatePattern = RegExp(
  r'^(\d{1,2})[./](\d{1,2})[./](\d{4})([./])?$',
);
const List<String> _srWeekdays = <String>[
  'ponedeljak',
  'utorak',
  'sreda',
  'cetvrtak',
  'petak',
  'subota',
  'nedelja',
];
const List<String> _srMonthsGenitive = <String>[
  'januara',
  'februara',
  'marta',
  'aprila',
  'maja',
  'juna',
  'jula',
  'avgusta',
  'septembra',
  'oktobra',
  'novembra',
  'decembra',
];

String formatDateForDocument(DateTime value) =>
    _documentDateFormat.format(value);

DateTime? parseDateValue(String? input) {
  if (input == null) return null;

  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final isoMatch = _isoDatePattern.firstMatch(trimmed);
  final localizedMatch = _localizedDatePattern.firstMatch(trimmed);

  int? year;
  int? month;
  int? day;

  if (isoMatch != null) {
    year = int.tryParse(isoMatch.group(1)!);
    month = int.tryParse(isoMatch.group(2)!);
    day = int.tryParse(isoMatch.group(3)!);
  } else if (localizedMatch != null) {
    day = int.tryParse(localizedMatch.group(1)!);
    month = int.tryParse(localizedMatch.group(2)!);
    year = int.tryParse(localizedMatch.group(3)!);
  }

  if (day == null || month == null || year == null) return null;
  if (year < 1900 || year > 2100) return null;

  final value = DateTime(year, month, day);
  if (value.year != year || value.month != month || value.day != day) {
    return null;
  }

  return value;
}

String formatDateUi(DateTime? value) {
  if (value == null) return '';
  return _documentDateFormat.format(value);
}

String formatDateUiSr(DateTime? value, {bool trailingDot = false}) {
  final formatted = formatDateUi(value);
  if (formatted.isEmpty || !trailingDot) return formatted;
  return '$formatted.';
}

String formatCalendarPickerSelection(
  DateTime value, {
  bool trailingDot = false,
}) => formatDateUiSr(value, trailingDot: trailingDot);

String formatDateText(DateTime? value) {
  if (value == null) return '';
  final weekday = _srWeekdays[value.weekday - 1];
  final month = _srMonthsGenitive[value.month - 1];
  final day = value.day.toString().padLeft(2, '0');
  return '$weekday, $day. $month ${value.year}. godine';
}

String normalizeDateInput(String input) {
  final trimmed = input.trim();
  final parsed = parseDateValue(trimmed);
  if (parsed == null) return trimmed;
  return formatDateUi(parsed);
}

String normalizeCeremonyDateInput(String input) {
  final trimmed = input.trim();
  final parsed = parseDateValue(trimmed);
  if (parsed == null) return trimmed;
  return formatDateUiSr(parsed, trailingDot: true);
}
