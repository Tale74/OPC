import 'package:drift/drift.dart';

class KatalogArtikli extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stableArticleId =>
      text().named('stable_article_id').nullable()();
  /// Interni naziv kategorije kojoj artikal pripada (npr. SANDUK, CVECE).
  TextColumn get interniNazivKategorije => text()();
  TextColumn get naziv => text()();
  RealColumn get cena => real().withDefault(const Constant(0.0))();
  BlobColumn get fotografija => blob().nullable()();
  /// Asset path za fotografiju iz kataloga (npr. assets/katalog_foto/katalog_001.jpg).
  TextColumn get fotografijaPath => text().nullable()();
}
