import '../../../../core/database/database.dart';
import '../../data/iriu_repository.dart';
import 'scenario_module_repository.dart';

/// Reconciles an open PREDMET when the production SCENARIO module observes it.
///
/// The MODULI -> SCENARIO path is intentionally read-only. It may report what
/// current evaluation would change, but first application is performed only
/// by the PREDMET lifecycle, never by opening this module.
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
