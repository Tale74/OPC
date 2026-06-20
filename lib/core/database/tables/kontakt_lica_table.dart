import 'package:drift/drift.dart';

import 'predmeti_table.dart';

class KontaktLica extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  // NARU_OPREMA / NARU_JKP
  TextColumn get blok => text()();
  TextColumn get imePrezime => text().withDefault(const Constant(''))();
  TextColumn get telefon => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get napomena => text().withDefault(const Constant(''))();
  IntColumn get redosled => integer().withDefault(const Constant(0))();
}
