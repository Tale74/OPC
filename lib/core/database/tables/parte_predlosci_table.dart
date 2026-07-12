import 'package:drift/drift.dart';

/// FIRMA-level user PARTE templates containing technical layout/style only.
/// Built-in templates are immutable source definitions and do not need rows.
class PartePredlosci extends Table {
  TextColumn get id => text()();
  IntColumn get firmaId => integer().withDefault(const Constant(1))();
  TextColumn get naziv => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  TextColumn get configJson => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
