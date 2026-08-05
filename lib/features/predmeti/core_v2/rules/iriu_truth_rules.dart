import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../models/iriu_truth_models.dart';
import '../scenario/owner_scenario_policy_kernel.dart';
import '../scenario/scenario_contract.dart';

class IriuManagedPolicy {
  const IriuManagedPolicy({
    required this.internalName,
    required this.kind,
    required this.manualDeletionAllowed,
    required this.requiresUserResolutionOnConditionChange,
    this.protectedFirstInOrdering = false,
    this.linkedCategories = const <String>[],
  });

  final String internalName;
  final IriuManagedKind kind;
  final bool manualDeletionAllowed;
  final bool requiresUserResolutionOnConditionChange;
  final bool protectedFirstInOrdering;
  final List<String> linkedCategories;
}

/// Centralizovana pravila za novi core truth lane.
///
/// Ovaj fajl ne rešava migraciju starog runtime-a; on samo eksplicitno opisuje
/// poslovnu istinu koju budući lane-ovi treba da čitaju.
abstract final class IriuTruthRules {
  static const String mestoSmrtiUlicaJavnoMesto = 'ULICA / JAVNO MESTO';
  static const String mestoSmrtiPrivatnaBolnica = 'PRIVATNA BOLNICA';

  static const Set<String> mestoSmrtiManagedCategories = <String>{
    IriuK.hladnjaca,
    IriuK.spremaanjePokojnika,
    IriuK.iznosenje,
    IriuK.prevozDoHladnjace,
    IriuK.prevozDoGroblja,
    IriuK.transportnaVreca,
  };

  static const Set<String> blok2ManagedCategories = <String>{
    IriuK.limeniUlozak,
    IriuK.lemovanje,
    IriuK.prevozSprovoda,
  };

  static const Set<String> derivativeOnlyDocumentScopedCategories = <String>{
    IriuK.cituljaP,
    IriuK.cituljaNo,
  };

  static const Map<String, IriuManagedPolicy> managedPolicies =
      <String, IriuManagedPolicy>{
        IriuK.sanduk: IriuManagedPolicy(
          internalName: IriuK.sanduk,
          kind: IriuManagedKind.protectedAnchor,
          protectedFirstInOrdering: true,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: false,
        ),
        IriuK.limeniUlozak: IriuManagedPolicy(
          internalName: IriuK.limeniUlozak,
          kind: IriuManagedKind.recommendedAutoManaged,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
          linkedCategories: <String>[IriuK.lemovanje],
        ),
        IriuK.lemovanje: IriuManagedPolicy(
          internalName: IriuK.lemovanje,
          kind: IriuManagedKind.recommendedAutoManaged,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
          linkedCategories: <String>[IriuK.limeniUlozak],
        ),
        IriuK.prevozSprovoda: IriuManagedPolicy(
          internalName: IriuK.prevozSprovoda,
          kind: IriuManagedKind.recommendedAutoManaged,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.hladnjaca: IriuManagedPolicy(
          internalName: IriuK.hladnjaca,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.spremaanjePokojnika: IriuManagedPolicy(
          internalName: IriuK.spremaanjePokojnika,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.iznosenje: IriuManagedPolicy(
          internalName: IriuK.iznosenje,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.prevozDoHladnjace: IriuManagedPolicy(
          internalName: IriuK.prevozDoHladnjace,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.prevozDoGroblja: IriuManagedPolicy(
          internalName: IriuK.prevozDoGroblja,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
        IriuK.transportnaVreca: IriuManagedPolicy(
          internalName: IriuK.transportnaVreca,
          kind: IriuManagedKind.conditionManagedOperational,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: true,
        ),
      };

  static IriuManagedPolicy policyFor(String internalName) {
    return managedPolicies[internalName] ??
        IriuManagedPolicy(
          internalName: internalName,
          kind: IriuManagedKind.none,
          manualDeletionAllowed: true,
          requiresUserResolutionOnConditionChange: false,
        );
  }

  static List<String> autoManagedMestoSmrtiCategories({
    required PredmetiData predmet,
  }) {
    return const OwnerScenarioPolicyKernel().autoManagedMestoSmrtiForTruth(
      predmet,
    );
  }

  static List<String> autoManagedBlok2Categories({
    required PredmetiData predmet,
  }) {
    return const OwnerScenarioPolicyKernel().autoManagedBlok2ForTruth(predmet);
  }

  static bool isOperationallyActive({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    return const OwnerScenarioPolicyKernel().isOperationallyActiveForTruth(
      predmet: predmet,
      internalName: row.interniNaziv,
    );
  }

  static bool isRecommended({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    final result = const OwnerScenarioPolicyKernel().evaluate(predmet);
    final baseAction = result.baseActions[row.interniNaziv];
    if (baseAction != null) {
      return baseAction == ScenarioConsequenceAction.recommended;
    }
    return result.consequences
        .where((item) => item.katalogCategoryInternalName == row.interniNaziv)
        .any((item) => item.action == ScenarioConsequenceAction.recommended);
  }

  static bool isBiohazard({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    final result = const OwnerScenarioPolicyKernel().evaluate(predmet);
    return result.consequences.any(
      (item) =>
          item.katalogCategoryInternalName == row.interniNaziv &&
          item.warning.trim().isNotEmpty,
    );
  }

  static int truthOrder(IriuData row) {
    final policy = policyFor(row.interniNaziv);
    if (policy.protectedFirstInOrdering) {
      return -100000;
    }
    return row.redosled;
  }

  static bool countsForFinancialTruth({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    final _ = predmet;
    if (!isOperationallyActive(predmet: predmet, row: row)) {
      return false;
    }
    return row.iznos > 0;
  }

  static Set<IriuDerivativeExclusion> derivativeExclusions({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    final exclusions = <IriuDerivativeExclusion>{};
    if (!isOperationallyActive(predmet: predmet, row: row)) {
      exclusions.add(IriuDerivativeExclusion.notOperationallyActive);
    }
    if (derivativeOnlyDocumentScopedCategories.contains(row.interniNaziv)) {
      exclusions.add(IriuDerivativeExclusion.documentScopedOut);
    }
    return exclusions;
  }

  static String normalizeMestoSmrti(String mestoSmrti) {
    return normalizeScenarioMestoSmrti(mestoSmrti);
  }
}
