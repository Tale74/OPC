import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';

class IriuOrderingService {
  const IriuOrderingService();

  static const List<String> _systemCategoryOrder = <String>[
    // Existing scenario-dependent order is preserved as one leading block.
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

  List<IriuData> orderedRows(List<IriuData> rows) {
    final currentRows = List<IriuData>.from(rows)
      ..sort((a, b) => a.redosled.compareTo(b.redosled));

    if (currentRows.any((row) => row.scenarioUpravlja)) {
      final managed = currentRows.where((row) => row.scenarioUpravlja).toList()
        ..sort((a, b) {
          final section = a.poslovnaCelina.compareTo(b.poslovnaCelina);
          return section != 0
              ? section
              : a.poslovniRedosled.compareTo(b.poslovniRedosled);
        });
      final manual = currentRows.where((row) => !row.scenarioUpravlja).toList();
      return List<IriuData>.unmodifiable([...managed, ...manual]);
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
