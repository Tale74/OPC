import '../../../../core/database/database.dart';
import '../models/iriu_truth_models.dart';
import '../rules/iriu_truth_rules.dart';
import 'predmet_iriu_truth_service.dart';

class Blok2IriuConflict {
  const Blok2IriuConflict({
    required this.row,
  });

  final IriuTruthRow row;
}

class Blok2IriuLifecyclePlan {
  const Blok2IriuLifecyclePlan({
    required this.categoriesToInsert,
    required this.conflicts,
    this.additionsRequiringConfirmation = const <String>[],
  });

  final List<String> categoriesToInsert;
  final List<Blok2IriuConflict> conflicts;
  final List<String> additionsRequiringConfirmation;
}

class Blok2IriuLifecycleService {
  const Blok2IriuLifecycleService({
    PredmetIriuTruthService predmetIriuTruthService =
        const PredmetIriuTruthService(),
  }) : _predmetIriuTruthService = predmetIriuTruthService;

  final PredmetIriuTruthService _predmetIriuTruthService;

  Blok2IriuLifecyclePlan planForCurrentState({
    required PredmetiData predmet,
    required List<IriuData> storedRows,
    required Set<String> dismissedCategories,
  }) {
    return Blok2IriuLifecyclePlan(
      categoriesToInsert: _categoriesToInsert(
        predmet: predmet,
        storedRows: storedRows,
        dismissedCategories: dismissedCategories,
      ),
      conflicts: const <Blok2IriuConflict>[],
      additionsRequiringConfirmation: const <String>[],
    );
  }

  Blok2IriuLifecyclePlan planForConditionChange({
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
          IriuTruthRules.blok2ManagedCategories.contains(
            row.storedRow.interniNaziv,
          ) &&
          previousRow.active &&
          row.requiresUserResolution;
    }).map((row) => Blok2IriuConflict(row: row)).toList(growable: false);

    return Blok2IriuLifecyclePlan(
      categoriesToInsert: const <String>[],
      conflicts: conflicts,
      additionsRequiringConfirmation: _categoriesToInsert(
        predmet: currentPredmet,
        storedRows: storedRows,
        dismissedCategories: dismissedCategories,
      ),
    );
  }

  List<String> _categoriesToInsert({
    required PredmetiData predmet,
    required List<IriuData> storedRows,
    required Set<String> dismissedCategories,
  }) {
    final presentCategories = storedRows.map((row) => row.interniNaziv).toSet();

    return IriuTruthRules.autoManagedBlok2Categories(predmet: predmet)
        .where(
          (internalName) =>
              !presentCategories.contains(internalName) &&
              !dismissedCategories.contains(internalName),
        )
        .toList(growable: false);
  }
}
