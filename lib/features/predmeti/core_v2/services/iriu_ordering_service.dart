import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';

/// Immutable context used to derive presentation/document order.  It is
/// intentionally detached from Drift so the same authority can be used by
/// repositories, widgets and every document exporter.
class IriuOrderingContext {
  const IriuOrderingContext({
    this.osnovniCategories = const <String>{},
    this.scenarioCategories = const <String>{},
    this.scenarioBusinessSections = const <String, int>{},
    this.scenarioBusinessOrders = const <String, int>{},
    this.provenanceOrigins = const <int, String>{},
    this.moduleId,
    this.scenarioId,
    this.scenarioVersion,
    this.scenarioRuleIds = const <String, String>{},
  });

  final Set<String> osnovniCategories;
  final Set<String> scenarioCategories;
  final Map<String, int> scenarioBusinessSections;
  final Map<String, int> scenarioBusinessOrders;
  final Map<int, String> provenanceOrigins;
  final String? moduleId;
  final String? scenarioId;
  final int? scenarioVersion;
  final Map<String, String> scenarioRuleIds;
}

class IriuOrderingService {
  const IriuOrderingService();

  static const List<String> _systemCategoryOrder = <String>[
    // Scenario-dependent order is applied only inside its own partition.
    IriuK.iznosenje,
    IriuK.transportnaVreca,
    IriuK.prevozDoHladnjace,
    IriuK.hladnjaca,
    IriuK.spremaanjePokojnika,
    IriuK.prevozDoGroblja,
    IriuK.limeniUlozak,
    IriuK.lemovanje,
    IriuK.prevozSprovoda,
    IriuK.kompletZaOpelo,
    IriuK.medjunarodniPrevoz,
    IriuK.medjunarodnaDocumentacija,
    IriuK.balsamovanje,
    IriuK.cargoTroskovi,
    // Existing built-in basic rows keep their established relative order.
    ...IriuK.ugradjeneOsnovnePreAgencijskih,
    IriuK.cituljaNo,
    // User-configurable basic and manual rows retain their stored order after
    // this explicit boundary category.
    IriuK.agencijskeUsluge,
  ];

  static final Set<String> _systemCategories = _systemCategoryOrder.toSet();

  bool isSystemManagedCategory(String internalName) {
    return _systemCategories.contains(internalName);
  }

  List<IriuData> orderedRows(
    List<IriuData> rows, {
    Map<int, String>? provenanceOrigins,
    IriuOrderingContext? context,
  }) {
    final currentRows = List<IriuData>.from(rows)
      ..sort((a, b) => a.redosled.compareTo(b.redosled));

    final effectiveOrigins = provenanceOrigins ?? context?.provenanceOrigins;
    final effectiveContext =
        context ??
        IriuOrderingContext(provenanceOrigins: effectiveOrigins ?? const {});
    final hasManagedContext =
        effectiveContext.osnovniCategories.isNotEmpty ||
        effectiveContext.scenarioCategories.isNotEmpty;
    if (effectiveOrigins != null &&
        (currentRows.any((row) => row.scenarioUpravlja) || hasManagedContext)) {
      final osnovni = <IriuData>[];
      final scenario = <IriuData>[];
      final managedUnclassified = <IriuData>[];
      final manual = <IriuData>[];
      for (final row in currentRows) {
        final origin = effectiveOrigins[row.id];
        final snapshotScenario = effectiveContext.scenarioCategories.contains(
          row.interniNaziv,
        );
        final snapshotOsnovni = effectiveContext.osnovniCategories.contains(
          row.interniNaziv,
        );
        if (origin == 'OSNOVNI_PAKET' ||
            (origin == null && snapshotOsnovni && !snapshotScenario) ||
            (origin == null &&
                row.scenarioUpravlja &&
                row.poslovnaCelina <= 1)) {
          osnovni.add(row);
        } else if (origin == 'SCENARIO_PAKET' ||
            (origin == null && snapshotScenario) ||
            (origin == null &&
                row.scenarioUpravlja &&
                row.poslovnaCelina >= 2)) {
          scenario.add(row);
        } else if (row.scenarioUpravlja) {
          managedUnclassified.add(row);
        } else {
          manual.add(row);
        }
      }
      int businessSection(IriuData row) =>
          effectiveContext.scenarioBusinessSections[row.interniNaziv] ??
          row.poslovnaCelina;
      int businessOrder(IriuData row) =>
          effectiveContext.scenarioBusinessOrders[row.interniNaziv] ??
          row.poslovniRedosled;
      int compareBusiness(IriuData a, IriuData b) {
        final section = businessSection(a).compareTo(businessSection(b));
        if (section != 0) return section;
        final business = businessOrder(a).compareTo(businessOrder(b));
        if (business != 0) return business;
        final stored = a.redosled.compareTo(b.redosled);
        return stored != 0 ? stored : a.id.compareTo(b.id);
      }

      osnovni.sort(compareBusiness);
      scenario.sort(compareBusiness);
      managedUnclassified.sort(compareBusiness);
      manual.sort((a, b) {
        final stored = a.redosled.compareTo(b.redosled);
        return stored != 0 ? stored : a.id.compareTo(b.id);
      });
      return List<IriuData>.unmodifiable([
        ...osnovni,
        ...scenario,
        ...managedUnclassified,
        ...manual,
      ]);
    }

    final rowsByCategory = <String, List<IriuData>>{};
    for (final row in currentRows) {
      rowsByCategory.putIfAbsent(row.interniNaziv, () => <IriuData>[]).add(row);
    }

    final ordered = <IriuData>[];
    final appendedIds = <int>{};

    for (final internalName in _systemCategoryOrder) {
      final categoryRows = rowsByCategory[internalName];
      if (categoryRows == null || categoryRows.isEmpty) continue;
      for (final row in categoryRows) {
        if (appendedIds.add(row.id)) {
          ordered.add(row);
        }
      }
    }

    for (final row in currentRows) {
      if (appendedIds.add(row.id)) {
        ordered.add(row);
      }
    }

    return List<IriuData>.unmodifiable(ordered);
  }
}
