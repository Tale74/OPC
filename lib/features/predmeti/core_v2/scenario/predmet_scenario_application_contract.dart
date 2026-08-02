import '../../../../core/database/database.dart';
import 'scenario_persistence_contract.dart';
import 'scenario_reconciliation_contract.dart';

enum PredmetScenarioApplicationRejection {
  predmetNotOpen,
  planAssignmentMismatch,
}

class PredmetScenarioApplicationException implements Exception {
  const PredmetScenarioApplicationException(this.reason);

  final PredmetScenarioApplicationRejection reason;

  @override
  String toString() => 'PredmetScenarioApplicationException: ${reason.name}';
}

/// Pure PREDMET-side gate for selecting and applying a scenario assignment.
///
/// The contract validates authority and confirmation boundaries only. It does
/// not write the PREDMET snapshot, IRIU rows or any other module state.
class PredmetScenarioApplicationPlan {
  const PredmetScenarioApplicationPlan({
    required this.predmetId,
    required this.assignment,
    required this.reconciliation,
    required this.requiresUserConfirmation,
    required this.isNoOp,
  });

  final int predmetId;
  final ScenarioAssignmentSnapshot assignment;
  final ScenarioReconciliationPlan reconciliation;
  final bool requiresUserConfirmation;
  final bool isNoOp;
}

class PredmetScenarioApplicationContract {
  const PredmetScenarioApplicationContract();

  PredmetScenarioApplicationPlan prepare({
    required PredmetiData predmet,
    required ScenarioAssignmentSnapshot assignment,
    required ScenarioReconciliationPlan reconciliation,
    String? currentSnapshotHash,
  }) {
    if (predmet.status.trim() != 'OTVOREN') {
      throw const PredmetScenarioApplicationException(
        PredmetScenarioApplicationRejection.predmetNotOpen,
      );
    }
    if (assignment.moduleId != reconciliation.moduleId ||
        assignment.scenarioId != reconciliation.scenarioId ||
        assignment.scenarioVersion != reconciliation.scenarioVersion) {
      throw const PredmetScenarioApplicationException(
        PredmetScenarioApplicationRejection.planAssignmentMismatch,
      );
    }

    final normalizedCurrentHash = currentSnapshotHash?.trim();
    final isNoOp =
        normalizedCurrentHash != null &&
        normalizedCurrentHash.isNotEmpty &&
        normalizedCurrentHash == assignment.snapshotHash &&
        reconciliation.isNoOp;
    return PredmetScenarioApplicationPlan(
      predmetId: predmet.id,
      assignment: assignment,
      reconciliation: reconciliation,
      requiresUserConfirmation: !isNoOp,
      isNoOp: isNoOp,
    );
  }
}
