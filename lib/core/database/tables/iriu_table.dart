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

  /// Količina — slobodan tekst; when a unit price is applied it drives IZNOS.
  TextColumn get kom => text().withDefault(const Constant(''))();

  /// Applied unit-price snapshot. KATALOG changes never rewrite an existing
  /// PREDMET row; the row keeps the price that was applied at selection time.
  RealColumn get cena => real().withDefault(const Constant(0.0))();

  /// Iznos se čuva kao REAL (float sa tačkom). Konverzija u srpski format SAMO pri prikazu.
  RealColumn get iznos => real().withDefault(const Constant(0.0))();
  BoolColumn get cekiran => boolean().withDefault(const Constant(false))();
  IntColumn get redosled => integer().withDefault(const Constant(0))();

  /// Materijalizovani, objašnjivi rezultat jedinog SCENARIO evaluatora.
  /// PREDMET ostaje izvor činjenica; ova polja su izvedeni rezultat za red.
  TextColumn get poslovniStatus =>
      text().named('poslovni_status').withDefault(const Constant('AKTIVNO'))();
  TextColumn get obezbedjuje => text().withDefault(const Constant('FIRMA'))();
  TextColumn get poslovnoUpozorenje =>
      text().named('poslovno_upozorenje').withDefault(const Constant(''))();
  TextColumn get poslovniRazlog =>
      text().named('poslovni_razlog').withDefault(const Constant(''))();
  IntColumn get poslovnaCelina =>
      integer().named('poslovna_celina').withDefault(const Constant(6))();
  IntColumn get poslovniRedosled =>
      integer().named('poslovni_redosled').withDefault(const Constant(0))();
  BoolColumn get finansijskiUkljuceno => boolean()
      .named('finansijski_ukljuceno')
      .withDefault(const Constant(true))();
  BoolColumn get scenarioUpravlja =>
      boolean().named('scenario_upravlja').withDefault(const Constant(false))();
  BoolColumn get cekaOdlukuKorisnika => boolean()
      .named('ceka_odluku_korisnika')
      .withDefault(const Constant(false))();
}
