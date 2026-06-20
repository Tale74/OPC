import 'app_date_format.dart';
import 'app_money_format.dart';

double parseMoneyNumber(String input) => parseMoneyInput(input);

String parseDateInput(String input) => normalizeDateInput(input);

@Deprecated('Use parseMoneyNumber')
double parsirajBroj(String input) => parseMoneyNumber(input);

@Deprecated('Use parseDateInput')
String parsirajDatum(String input) => parseDateInput(input);
