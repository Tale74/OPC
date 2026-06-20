import 'package:drift/drift.dart';

import 'predmeti_table.dart';

class LogIzmena extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  IntColumn get korisnikId => integer()();
  TextColumn get datumVreme => text()();
  TextColumn get polje => text()();
  TextColumn get staraVrednost => text().withDefault(const Constant(''))();
  TextColumn get novaVrednost => text().withDefault(const Constant(''))();
}
