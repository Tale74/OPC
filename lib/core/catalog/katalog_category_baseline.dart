/// System-required KATALOG category baseline for a newly created database.
///
/// These rows carry only category identity and configuration. Business
/// articles are deliberately not part of this baseline.
final class KatalogCategoryBaselineEntry {
  const KatalogCategoryBaselineEntry({
    required this.internalName,
    required this.displayName,
    required this.type,
    required this.order,
  });

  final String internalName;
  final String displayName;
  final String type;
  final int order;

  double get defaultPrice => 0.0;
}

final class KatalogCategoryBaseline {
  const KatalogCategoryBaseline._();

  /// The current source-defined category set used by SCENARIO and its
  /// downstream category-key consumers. The set contains categories only;
  /// no business articles are seeded here.
  static const List<KatalogCategoryBaselineEntry> entries = [
    KatalogCategoryBaselineEntry(
      internalName: 'SANDUK',
      displayName: 'Sanduk',
      type: 'KATALOSKA',
      order: 1,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'POKROV_GARNITURA',
      displayName: 'Pokrov garnitura',
      type: 'KATALOSKA',
      order: 2,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'OBELEZJE',
      displayName: 'Obeležje',
      type: 'KATALOSKA',
      order: 3,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'PESKIR_ZA_KRST',
      displayName: 'Peškir za krst',
      type: 'FIKSNA',
      order: 4,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'POSMRTNE_PARTE',
      displayName: 'Posmrtne parte',
      type: 'FIKSNA',
      order: 5,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'HLADNJACA',
      displayName: 'Hladnjača',
      type: 'FIKSNA',
      order: 6,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'SPREMANJE_POKOJNIKA',
      displayName: 'Spremanje preminulog lica',
      type: 'FIKSNA',
      order: 7,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'IZNOSENJE',
      displayName: 'Iznošenje',
      type: 'FIKSNA',
      order: 8,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'PREVOZ_DO_HLADNJACE',
      displayName: 'Prevoz do hladnjače',
      type: 'FIKSNA',
      order: 9,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'PREVOZ_DO_GROBLJA',
      displayName: 'Prevoz do groblja',
      type: 'FIKSNA',
      order: 10,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'PREVOZ_SPROVODA',
      displayName: 'Prevoz sprovoda',
      type: 'FIKSNA',
      order: 11,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'CRNINA',
      displayName: 'Crnina',
      type: 'KATALOSKA',
      order: 12,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'LIMENI_ULOZAK',
      displayName: 'Limeni uložak',
      type: 'FIKSNA',
      order: 13,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'LEMOVANJE',
      displayName: 'Lemovanje',
      type: 'FIKSNA',
      order: 14,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'AGENCIJSKE_USLUGE',
      displayName: 'Agencijske usluge',
      type: 'FIKSNA',
      order: 15,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'TRANSPORTNA_VRECA',
      displayName: 'Transportna vreća',
      type: 'FIKSNA',
      order: 16,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'CVECE',
      displayName: 'Cveće',
      type: 'KATALOSKA',
      order: 17,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'KOMPLET_ZA_OPELO',
      displayName: 'Komplet za opelo',
      type: 'KATALOSKA',
      order: 18,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'CITULJA_POLITIKA',
      displayName: 'Čitulja Politika',
      type: 'KATALOSKA',
      order: 19,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'CITULJA_NOVOSTI',
      displayName: 'Čitulja Novosti',
      type: 'KATALOSKA',
      order: 20,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'MEDJUNARODNI_PREVOZ',
      displayName: 'Međunarodni prevoz',
      type: 'FIKSNA',
      order: 21,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'MEDJUNARODNA_DOKUMENTACIJA',
      displayName: 'Međunarodna dokumentacija',
      type: 'FIKSNA',
      order: 22,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'BALSAMOVANJE',
      displayName: 'Balsamovanje',
      type: 'FIKSNA',
      order: 23,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'CARGO_TROSKOVI',
      displayName: 'Cargo troškovi',
      type: 'FIKSNA',
      order: 24,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'SLIKA',
      displayName: 'Slika',
      type: 'KATALOSKA',
      order: 25,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'ZASTITNA_I_DODATNA_OPREMA',
      displayName: 'Zaštitna i dodatna oprema',
      type: 'FIKSNA',
      order: 26,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'DORADA_POGREBNE_OPREME',
      displayName: 'Dorada pogrebne opreme',
      type: 'FIKSNA',
      order: 1001,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'KUCANJE_OBELEZJA',
      displayName: 'Kucanje obeležja',
      type: 'FIKSNA',
      order: 1002,
    ),
    KatalogCategoryBaselineEntry(
      internalName: 'SLOVA_I_BROJEVI',
      displayName: 'Slova i brojevi',
      type: 'FIKSNA',
      order: 1003,
    ),
  ];

  static Set<String> get internalNames =>
      entries.map((entry) => entry.internalName).toSet();
}
