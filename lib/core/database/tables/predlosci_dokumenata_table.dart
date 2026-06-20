import 'package:drift/drift.dart';

class PredlosciDokumenata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get naziv => text()();
  /// JSON lista segmenata: ["PREMINULO_LICE","NARUCILAC","CEREMONIJA","PARTE","IRIU","FINANSIJE"]
  TextColumn get segmenti => text().withDefault(const Constant('[]'))();
  // PDF / JSON / OBA
  TextColumn get format => text().withDefault(const Constant('PDF'))();
  BoolColumn get predefinisan =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get napomeneUkljucene =>
      boolean().withDefault(const Constant(false))();
  /// true = ne može da se briše niti menja (samo BELEŽNICA)
  BoolColumn get zakljucan =>
      boolean().withDefault(const Constant(false))();
}
