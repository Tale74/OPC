import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class KontaktLicaRepository {
  const KontaktLicaRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  AppDatabase get db => _db;

  Stream<List<KontaktLicaData>> watchKontakti(int predmetId) =>
      (_db.select(_db.kontaktLica)
            ..where((k) => k.predmetId.equals(predmetId))
            ..orderBy([(k) => OrderingTerm.asc(k.redosled)]))
          .watch();

  Future<int> dodaj({
    required int predmetId,
    required String blok, // 'NARU_OPREMA' ili 'NARU_JKP'
    String imePrezime = '',
    String telefon = '',
    String email = '',
    String napomena = '',
    int redosled = 0,
  }) =>
      _db.into(_db.kontaktLica).insert(
        KontaktLicaCompanion(
          predmetId: Value(predmetId),
          blok: Value(blok),
          imePrezime: Value(imePrezime),
          telefon: Value(telefon),
          email: Value(email),
          napomena: Value(napomena),
          redosled: Value(redosled),
        ),
      );

  Future<void> azuriraj(int id, KontaktLicaCompanion companion) =>
      (_db.update(_db.kontaktLica)..where((k) => k.id.equals(id)))
          .write(companion);

  Future<void> obrisi(int id) =>
      (_db.delete(_db.kontaktLica)..where((k) => k.id.equals(id))).go();

  Future<void> obrisiSveZaPredmet(int predmetId) =>
      (_db.delete(_db.kontaktLica)
            ..where((k) => k.predmetId.equals(predmetId)))
          .go();
}
