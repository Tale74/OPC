import 'package:drift/drift.dart';

class StanjeRobeStavke extends Table {
  @override
  String get tableName => 'stanje_robe_stavke';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get stableArticleId => text().named('stable_article_id')();

  RealColumn get trenutnaKolicina =>
      real().named('trenutna_kolicina').withDefault(const Constant(0.0))();

  RealColumn get minimalnaKolicina =>
      real().named('minimalna_kolicina').withDefault(const Constant(0.0))();

  BoolColumn get aktivna =>
      boolean().named('aktivna').withDefault(const Constant(true))();

  TextColumn get datumKreiranja =>
      text().named('datum_kreiranja').withDefault(const Constant(''))();

  TextColumn get datumAzuriranja =>
      text().named('datum_azuriranja').withDefault(const Constant(''))();
}
