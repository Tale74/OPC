import 'package:drift/drift.dart';

/// Singleton tabela — uvek id = 1.
class AppPodesavanja extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ziroRacun => text().withDefault(const Constant(''))();
  TextColumn get nazivBanke => text().withDefault(const Constant(''))();
  TextColumn get qrPrimalacNaziv => text().withDefault(const Constant(''))();
  TextColumn get qrSifraPlacanja => text().withDefault(const Constant('289'))();
  TextColumn get qrSvrhaPlacanja => text().withDefault(const Constant(''))();
  // IME_PREZIME ili BROJ_PREDMETA
  TextColumn get pozivNaBrojTip =>
      text().withDefault(const Constant('BROJ_PREDMETA'))();
  // Iznos PIO refundacije — unosi se jednom godišnje
  RealColumn get refundacijaPioIznos =>
      real().withDefault(const Constant(0.0))();
  BoolColumn get stanjeRobeOperativnoOmoguceno =>
      boolean().withDefault(const Constant(false))();
}
