import 'package:drift/drift.dart';

class ScenarioModules extends Table {
  TextColumn get id => text()();
  TextColumn get naziv => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('AKTIVAN'))();
  IntColumn get schemaVersion =>
      integer().named('schema_version').withDefault(const Constant(1))();
  TextColumn get osnovniPaketJson =>
      text().named('osnovni_paket_json').withDefault(const Constant('[]'))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
