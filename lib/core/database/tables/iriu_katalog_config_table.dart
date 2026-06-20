import 'package:drift/drift.dart';

class IriuKatalogConfig extends Table {
  /// Interni naziv — PK (npr. SANDUK, LIMENI_ULOZAK, AGENCIJSKE_USLUGE).
  TextColumn get interniNaziv => text()();
  TextColumn get nazivPrikaz => text()();
  BoolColumn get vidljiv => boolean().withDefault(const Constant(true))();
  /// true = štampa se čak i ako je prazno; false = samo ako je popunjeno.
  BoolColumn get uvekPrikazati =>
      boolean().withDefault(const Constant(false))();
  // FIKSNA / KATALOSKA
  TextColumn get tip => text().withDefault(const Constant('FIKSNA'))();
  BoolColumn get jeKorisnicka =>
      boolean().withDefault(const Constant(false))();
  IntColumn get redosled => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {interniNaziv};
}
