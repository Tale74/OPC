import 'package:drift/drift.dart';

class Korisnici extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imePrezime => text()();
  TextColumn get uloga => text()(); // ADMINISTRATOR / SAVETNIK
  TextColumn get pinHash => text()();
  BoolColumn get aktivan => boolean().withDefault(const Constant(true))();
  TextColumn get datumKreiranja => text()();
}
