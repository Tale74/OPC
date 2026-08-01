import 'package:drift/drift.dart';

import 'iriu_table.dart';

class IriuProvenance extends Table {
  IntColumn get iriuId => integer()
      .named('iriu_id')
      .references(Iriu, #id, onDelete: KeyAction.cascade)();
  TextColumn get origin => text()();
  TextColumn get moduleId => text().named('module_id').nullable()();
  TextColumn get scenarioId => text().named('scenario_id').nullable()();
  IntColumn get scenarioVersion =>
      integer().named('scenario_version').nullable()();
  TextColumn get ruleId => text().named('rule_id').nullable()();
  TextColumn get operationId => text().named('operation_id').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {iriuId};
}
