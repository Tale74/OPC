import 'package:drift/drift.dart';

import 'scenario_modules_table.dart';

@DataClassName('ScenarioDefinitionRecord')
class ScenarioDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get moduleId => text()
      .named('module_id')
      .references(ScenarioModules, #id, onDelete: KeyAction.cascade)();
  IntColumn get version => integer()();
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  TextColumn get naziv => text().withDefault(const Constant(''))();
  TextColumn get conditionJson =>
      text().named('condition_json').withDefault(const Constant('{}'))();
  TextColumn get consequencesJson =>
      text().named('consequences_json').withDefault(const Constant('[]'))();
  BoolColumn get jePodrazumevani =>
      boolean().named('je_podrazumevani').withDefault(const Constant(false))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id, version};
}
