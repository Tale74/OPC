import 'package:drift/drift.dart';

import 'predmeti_table.dart';

class Iriu extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  TextColumn get katalogStableArticleId =>
      text().named('katalog_stable_article_id').nullable()();
  /// Interni naziv kategorije — nepromenjiv string (npr. SANDUK, LIMENI_ULOZAK).
  /// Koristi se za automatsku logiku i Nalog za opremanje.
  TextColumn get interniNaziv => text()();
  /// Naziv za prikaz — vidljiv korisniku, editabilan.
  TextColumn get nazivPrikaz => text().withDefault(const Constant(''))();
  /// Količina — slobodan tekst (informativno, ne ulazi u formulu).
  TextColumn get kom => text().withDefault(const Constant(''))();
  /// Iznos se čuva kao REAL (float sa tačkom). Konverzija u srpski format SAMO pri prikazu.
  RealColumn get iznos => real().withDefault(const Constant(0.0))();
  BoolColumn get cekiran => boolean().withDefault(const Constant(false))();
  IntColumn get redosled => integer().withDefault(const Constant(0))();
}
