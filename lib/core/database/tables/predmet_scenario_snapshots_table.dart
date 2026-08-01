import 'package:drift/drift.dart';

import 'predmeti_table.dart';

class PredmetScenarioSnapshots extends Table {
  IntColumn get predmetId => integer()
      .named('predmet_id')
      .references(Predmeti, #id, onDelete: KeyAction.cascade)();
  TextColumn get moduleId => text().named('module_id')();
  TextColumn get scenarioId => text().named('scenario_id')();
  IntColumn get scenarioVersion => integer().named('scenario_version')();
  TextColumn get snapshotJson => text().named('snapshot_json')();
  TextColumn get snapshotHash => text().named('snapshot_hash')();
  TextColumn get assignedAt => text().named('assigned_at')();
  IntColumn get assignedByKorisnikId =>
      integer().named('assigned_by_korisnik_id').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {predmetId};
}
