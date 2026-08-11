import '../../../../core/database/database.dart';
import '../../data/iriu_repository.dart';
import 'scenario_module_repository.dart';

/// Reconciles an open PREDMET when the production SCENARIO module observes it.
///
/// The first production hand-off must happen on the MODULI -> SCENARIO path,
/// not only from the IRiU editor or a test harness.  The repository is called
/// in preview mode so a changed, already assigned scenario remains subject to
/// the existing keep/remove lifecycle; a first assignment is materialized
/// immediately because it has no previous snapshot to invalidate.
class ScenarioRuntimeReconciliationService {
  const ScenarioRuntimeReconciliationService(this._db);

  final AppDatabase _db;

  Future<ScenarioSyncResult> reconcileOpenPredmet(PredmetiData predmet) async {
    final repository = ScenarioModuleRepository(_db);
    final module = await repository.ensureModuleAndDefaults();
    final scenarios = await repository.getActiveDefinitions();
    return IriuRepository(_db).syncScenarioRows(
      predmetId: predmet.id,
      predmet: predmet,
      scenarios: scenarios,
      osnovniPaket: repository.readOsnovniPaket(module),
      applyScenarioChange: false,
    );
  }
}
