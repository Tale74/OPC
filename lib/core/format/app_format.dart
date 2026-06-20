export 'app_date_format.dart';
export 'app_filename_format.dart';
export 'app_identifier_format.dart';
export 'app_money_format.dart';
export 'app_parse.dart';
export 'app_text_format.dart';
export 'app_time_format.dart';

import 'app_money_format.dart';
import 'app_parse.dart';

@Deprecated('Use formatMoneyRsd')
String formatRsd(double value) => formatMoneyRsd(value);

@Deprecated('Use formatMoneyNumber')
String formatBroj(double value) => formatMoneyNumber(value);

@Deprecated('Use normalizeDateInput')
String parsirajDatum(String input) => parseDateInput(input);

String kreirajBrojPredmeta(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = (value.year % 100).toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day$month${year}_$hour$minute';
}
