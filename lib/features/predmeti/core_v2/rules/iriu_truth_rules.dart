import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../models/iriu_truth_models.dart';

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
    final normalizedMestoSmrti = normalizeMestoSmrti(predmet.mestoSmrti);
    final categories = <String>[];
    if (_mestoSmrtiBlockQualified(normalizedMestoSmrti)) {
      categories.addAll(const <String>[
        IriuK.hladnjaca,
        IriuK.spremaanjePokojnika,
        IriuK.iznosenje,
        IriuK.prevozDoHladnjace,
        IriuK.transportnaVreca,
        IriuK.prevozDoGroblja,
      ]);
    } else if (_mestoSmrtiBolnicaQualified(normalizedMestoSmrti)) {
      categories.add(IriuK.prevozDoGroblja);
    }
    return List<String>.unmodifiable(categories);
  }

  static List<String> autoManagedBlok2Categories({
    required PredmetiData predmet,
  }) {
    final categories = <String>[];
    if (_shouldAutoAddLimeniUlozak(predmet)) {
      categories.add(IriuK.limeniUlozak);
    }
    if (_shouldAutoAddLemovanje(predmet)) {
      categories.add(IriuK.lemovanje);
    }
    if (_shouldRecommendPrevozSprovoda(predmet)) {
      categories.add(IriuK.prevozSprovoda);
    }
    return List<String>.unmodifiable(categories);
  }

  static bool isOperationallyActive({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    switch (row.interniNaziv) {
      case IriuK.hladnjaca:
      case IriuK.spremaanjePokojnika:
      case IriuK.iznosenje:
      case IriuK.prevozDoHladnjace:
      case IriuK.prevozDoGroblja:
      case IriuK.transportnaVreca:
        return autoManagedMestoSmrtiCategories(predmet: predmet)
            .contains(row.interniNaziv);
      case IriuK.limeniUlozak:
      case IriuK.lemovanje:
      case IriuK.prevozSprovoda:
        return autoManagedBlok2Categories(predmet: predmet)
            .contains(row.interniNaziv);
      case IriuK.medjunarodniPrevoz:
      case IriuK.medjunarodnaDocumentacija:
      case IriuK.balsamovanje:
        return predmet.sahranaVanSrbije;
      case IriuK.cargoTroskovi:
        return predmet.docekPosmrtnihOstataka;
      default:
        return true;
    }
  }

  static bool isRecommended({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    switch (row.interniNaziv) {
      case IriuK.limeniUlozak:
        return _shouldAutoAddLimeniUlozak(predmet);
      case IriuK.lemovanje:
        return _shouldAutoAddLemovanje(predmet);
      case IriuK.prevozSprovoda:
        return _shouldRecommendPrevozSprovoda(predmet);
      default:
        return false;
    }
  }

  static bool isBiohazard({
    required PredmetiData predmet,
    required IriuData row,
  }) {
    if (row.interniNaziv != IriuK.spremaanjePokojnika) {
      return false;
    }
    final normalizedMestoSmrti = normalizeMestoSmrti(predmet.mestoSmrti);
    return predmet.uzrokSmrti == 'ZARAZNA' &&
        normalizedMestoSmrti.isNotEmpty &&
        normalizedMestoSmrti != 'BOLNICA';
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
    final normalized = mestoSmrti.trim();
    switch (normalized) {
      case 'ULICA':
      case 'JAVNO MESTO':
      case mestoSmrtiUlicaJavnoMesto:
        return mestoSmrtiUlicaJavnoMesto;
      default:
        return normalized;
    }
  }

  static bool _mestoSmrtiBlockQualified(String mestoSmrti) {
    return const <String>{
      'STAN',
      'DOM ZA STARE',
      mestoSmrtiUlicaJavnoMesto,
      'DRUGO',
    }.contains(mestoSmrti);
  }

  static bool _mestoSmrtiBolnicaQualified(String mestoSmrti) {
    return mestoSmrti == 'BOLNICA';
  }

  static bool _shouldAutoAddLimeniUlozak(PredmetiData predmet) {
    if (_isKremacija(predmet)) {
      return false;
    }
    if (_hasUzrokSmrtiOverride(predmet.uzrokSmrti)) {
      return true;
    }
    return predmet.tipGrobnogMesta == 'GROBNICA';
  }

  static bool _shouldAutoAddLemovanje(PredmetiData predmet) {
    if (_isKremacija(predmet)) {
      return false;
    }
    if (_hasUzrokSmrtiOverride(predmet.uzrokSmrti)) {
      return true;
    }
    return predmet.tipGrobnogMesta == 'GROBNICA';
  }

  static bool _shouldRecommendPrevozSprovoda(PredmetiData predmet) {
    return predmet.tipGroblja == 'LOKALNO';
  }

  static bool _isKremacija(PredmetiData predmet) {
    return predmet.vrstaCeremonije == 'KREMACIJA' ||
        predmet.vrstaCeremonije == 'KREMACIJA_EKSPRES';
  }

  static bool _hasUzrokSmrtiOverride(String uzrokSmrti) {
    return const <String>{
      'NASILNA',
      'ZARAZNA',
      'NEDEFINISANA',
    }.contains(uzrokSmrti);
  }
}
