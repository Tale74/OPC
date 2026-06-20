import '../../../../core/database/database.dart';
import '../models/iriu_truth_models.dart';
import '../rules/iriu_truth_rules.dart';
import 'predmet_iriu_truth_service.dart';

class MestoSmrtiIriuConflict {
  const MestoSmrtiIriuConflict({
    required this.row,
  });

  final IriuTruthRow row;
}

class MestoSmrtiIriuLifecyclePlan {
  const MestoSmrtiIriuLifecyclePlan({
    required this.categoriesToInsert,
    required this.conflicts,
  });

  final List<String> categoriesToInsert;
  final List<MestoSmrtiIriuConflict> conflicts;
}

class MestoSmrtiIriuLifecycleService {
  const MestoSmrtiIriuLifecycleService({
    PredmetIriuTruthService predmetIriuTruthService =
        const PredmetIriuTruthService(),
  }) : _predmetIriuTruthService = predmetIriuTruthService;

  final PredmetIriuTruthService _predmetIriuTruthService;

  MestoSmrtiIriuLifecyclePlan planForCurrentState({
    required PredmetiData predmet,
    required List<IriuData> storedRows,
    required Set<String> dismissedCategories,
  }) {
    return MestoSmrtiIriuLifecyclePlan(
      categoriesToInsert: _categoriesToInsert(
        predmet: predmet,
        storedRows: storedRows,
        dismissedCategories: dismissedCategories,
      ),
      conflicts: const <MestoSmrtiIriuConflict>[],
    );
  }

  MestoSmrtiIriuLifecyclePlan planForConditionChange({
    required PredmetiData previousPredmet,
    required PredmetiData currentPredmet,
    required List<IriuData> storedRows,
    required Set<String> dismissedCategories,
  }) {
    final previousSnapshot = _predmetIriuTruthService.evaluate(
      predmet: previousPredmet,
      storedRows: storedRows,
    );
    final currentSnapshot = _predmetIriuTruthService.evaluate(
      predmet: currentPredmet,
      storedRows: storedRows,
    );
    final previousRowsById = <int, IriuTruthRow>{
      for (final row in previousSnapshot.rows) row.storedRow.id: row,
    };
    final conflicts = currentSnapshot.rows.where((row) {
      final previousRow = previousRowsById[row.storedRow.id];
      return previousRow != null &&
          IriuTruthRules.mestoSmrtiManagedCategories.contains(
            row.storedRow.interniNaziv,
          ) &&
          previousRow.active &&
          row.requiresUserResolution;
    }).map((row) => MestoSmrtiIriuConflict(row: row)).toList(growable: false);

    return MestoSmrtiIriuLifecyclePlan(
      categoriesToInsert: _categoriesToInsert(
        predmet: currentPredmet,
        storedRows: storedRows,
        dismissedCategories: dismissedCategories,
      ),
      conflicts: conflicts,
    );
  }

  bool isMestoSmrtiManagedCategory(String internalName) {
    return IriuTruthRules.mestoSmrtiManagedCategories.contains(internalName);
  }

  List<String> _categoriesToInsert({
    required PredmetiData predmet,
    required List<IriuData> storedRows,
    required Set<String> dismissedCategories,
  }) {
    final presentCategories = storedRows
        .map((row) => row.interniNaziv)
        .toSet();

    return IriuTruthRules.autoManagedMestoSmrtiCategories(predmet: predmet)
        .where(
          (internalName) =>
              !presentCategories.contains(internalName) &&
              !dismissedCategories.contains(internalName),
        )
        .toList(growable: false);
  }
}
