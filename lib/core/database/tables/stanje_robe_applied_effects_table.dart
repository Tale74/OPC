import 'package:drift/drift.dart';

class StanjeRobeAppliedEffects extends Table {
  @override
  String get tableName => 'stanje_robe_applied_effects';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get predmetId =>
      integer().named('predmet_id').customConstraint('NOT NULL')();

  IntColumn get iriuId => integer().named('iriu_id').nullable()();

  TextColumn get kategorija => text().named('kategorija')();

  TextColumn get stableArticleId => text().named('stable_article_id')();

  RealColumn get effectQuantity =>
      real().named('effect_quantity').withDefault(const Constant(1.0))();

  TextColumn get effectStatus => text().named('effect_status')();

  TextColumn get effectReason => text().named('effect_reason')();

  TextColumn get datumKreiranja =>
      text().named('datum_kreiranja').withDefault(const Constant(''))();

  TextColumn get datumAzuriranja =>
      text().named('datum_azuriranja').withDefault(const Constant(''))();
}
