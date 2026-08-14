/// Immutable snapshot of one concrete KATALOG article selected for IRiU.
///
/// Category-only scenario/base rows intentionally do not use this type. The
/// stored IRiU row remains the authority for historical name, price, quantity
/// and amount after this snapshot is applied.
class IriuCatalogSelection {
  static const Object _unset = Object();

  const IriuCatalogSelection({
    required this.interniNaziv,
    required this.nazivPrikaz,
    required this.katalogStableArticleId,
    required this.cena,
    this.kom = '1',
    this.iznos = 0.0,
  });

  final String interniNaziv;
  final String nazivPrikaz;
  final String? katalogStableArticleId;
  final double cena;
  final String kom;
  final double iznos;

  IriuCatalogSelection copyWith({
    String? interniNaziv,
    String? nazivPrikaz,
    Object? katalogStableArticleId = _unset,
    double? cena,
    String? kom,
    double? iznos,
  }) {
    return IriuCatalogSelection(
      interniNaziv: interniNaziv ?? this.interniNaziv,
      nazivPrikaz: nazivPrikaz ?? this.nazivPrikaz,
      katalogStableArticleId: identical(katalogStableArticleId, _unset)
          ? this.katalogStableArticleId
          : katalogStableArticleId as String?,
      cena: cena ?? this.cena,
      kom: kom ?? this.kom,
      iznos: iznos ?? this.iznos,
    );
  }
}
