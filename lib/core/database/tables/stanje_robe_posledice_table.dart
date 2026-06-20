import 'package:drift/drift.dart';

import 'iriu_table.dart';
import 'predmeti_table.dart';

class StanjeRobePosledice extends Table {
  @override
  String get tableName => 'stanje_robe_posledice';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get predmetId => integer()
      .named('predmet_id')
      .references(Predmeti, #id, onDelete: KeyAction.cascade)();

  IntColumn get iriuId => integer()
      .named('iriu_id')
      .references(Iriu, #id, onDelete: KeyAction.cascade)();

  TextColumn get kategorija => text().named('kategorija')();

  TextColumn get katalogStableArticleId =>
      text().named('katalog_stable_article_id')();

  TextColumn get selectedNazivSnapshot =>
      text().named('selected_naziv_snapshot')();

  RealColumn get selectedIznosSnapshot =>
      real().named('selected_iznos_snapshot').withDefault(const Constant(0.0))();

  TextColumn get consequenceType => text().named('consequence_type')();

  TextColumn get status => text().named('status')();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();

  TextColumn get resolvedAt => text().named('resolved_at').nullable()();

  TextColumn get resolvedReason =>
      text().named('resolved_reason').nullable()();

  TextColumn get sourceLifecycleEvent =>
      text().named('source_lifecycle_event')();

  RealColumn get effectQuantity =>
      real().named('effect_quantity').withDefault(const Constant(1.0))();

  RealColumn get availableQuantityAtCreation =>
      real().named('available_quantity_at_creation').nullable()();

  RealColumn get shortageQuantityAtCreation =>
      real().named('shortage_quantity_at_creation').nullable()();
}
