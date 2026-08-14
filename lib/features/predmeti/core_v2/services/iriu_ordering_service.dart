import '../../../../core/database/database.dart';

/// Immutable context used to derive presentation/document order.  It is
/// intentionally detached from Drift so the same authority can be used by
/// repositories, widgets and every document exporter.
class IriuOrderingContext {
  const IriuOrderingContext({
    this.osnovniCategories = const <String>{},
    this.osnovniBusinessOrders = const <String, int>{},
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
  final Map<String, int> osnovniBusinessOrders;
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

  List<IriuData> orderedRows(
    List<IriuData> rows, {
    Map<int, String>? provenanceOrigins,
    IriuOrderingContext? context,
  }) {
    final currentRows = List<IriuData>.from(rows)
      ..sort((a, b) => a.redosled.compareTo(b.redosled));

    final effectiveContext =
        context ??
        IriuOrderingContext(provenanceOrigins: provenanceOrigins ?? const {});
    final hasManagedContext =
        effectiveContext.osnovniCategories.isNotEmpty ||
        effectiveContext.scenarioCategories.isNotEmpty;
    if (hasManagedContext) {
      final osnovni = <IriuData>[];
      final scenario = <IriuData>[];
      final manual = <IriuData>[];
      for (final row in currentRows) {
        final inOsnovni = effectiveContext.osnovniCategories.contains(
          row.interniNaziv,
        );
        final inScenario = effectiveContext.scenarioCategories.contains(
          row.interniNaziv,
        );
        if (inOsnovni && !inScenario) {
          osnovni.add(row);
        } else if (inScenario && !inOsnovni) {
          scenario.add(row);
        } else {
          // A row outside both package memberships is manual/unpredicted,
          // regardless of scenario flags or provenance metadata.
          manual.add(row);
        }
      }
      int packageOrder(IriuData row, {required bool osnovni}) {
        final configured = osnovni
            ? effectiveContext.osnovniBusinessOrders[row.interniNaziv]
            : effectiveContext.scenarioBusinessOrders[row.interniNaziv];
        // A missing configured order is an unconfigured tie, not permission
        // to promote persisted redosled into business authority.
        return configured ?? 1 << 30;
      }

      int comparePackage(IriuData a, IriuData b, {required bool osnovni}) {
        final business = packageOrder(
          a,
          osnovni: osnovni,
        ).compareTo(packageOrder(b, osnovni: osnovni));
        if (business != 0) return business;
        return a.id.compareTo(b.id);
      }

      osnovni.sort((a, b) => comparePackage(a, b, osnovni: true));
      scenario.sort((a, b) => comparePackage(a, b, osnovni: false));
      manual.sort((a, b) {
        final stored = a.redosled.compareTo(b.redosled);
        return stored != 0 ? stored : a.id.compareTo(b.id);
      });
      return List<IriuData>.unmodifiable([...osnovni, ...scenario, ...manual]);
    }

    // No package authority is available for this legacy/malformed lane. Keep
    // the deterministic raw projection, but never present it as business
    // ordering authority or replace it with a hard-coded category sequence.
    return List<IriuData>.unmodifiable(currentRows);
  }
}
