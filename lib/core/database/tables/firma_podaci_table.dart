import 'package:drift/drift.dart';

/// Singleton tabela — uvek id = 1.
class FirmaPodaci extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get naziv => text().withDefault(const Constant(''))();
  TextColumn get adresa => text().withDefault(const Constant(''))();
  TextColumn get pib => text().withDefault(const Constant(''))();
  TextColumn get mb => text().withDefault(const Constant(''))();
  TextColumn get sifraDelatnosti => text().withDefault(const Constant(''))();
  TextColumn get telefon => text().withDefault(const Constant(''))();
  TextColumn get odgovornoLice => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get sajt => text().withDefault(const Constant(''))();
  BlobColumn get logo => blob().nullable()();
}
