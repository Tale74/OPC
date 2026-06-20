import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';

class IriuOrderingService {
  const IriuOrderingService();

  static const List<String> _systemCategoryOrder = <String>[
    IriuK.sanduk,
    IriuK.obelezje,
    IriuK.pokrovGarnitura,
    IriuK.peskirZaKrst,
    IriuK.posmrtneParte,
    IriuK.crnina,
    IriuK.agencijskeUsluge,
    IriuK.cvece,
    IriuK.cituljaP,
    IriuK.cituljaNo,
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
  ];

  static final Set<String> _systemCategories =
      _systemCategoryOrder.toSet();

  bool isSystemManagedCategory(String internalName) {
    return _systemCategories.contains(internalName);
  }

  List<IriuData> orderedRows(List<IriuData> rows) {
    final currentRows = List<IriuData>.from(rows)
      ..sort((a, b) => a.redosled.compareTo(b.redosled));

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
