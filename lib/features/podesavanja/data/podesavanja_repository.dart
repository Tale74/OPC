import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/utils/stable_id_generator.dart';

class KategorijaLifecycleStatus {
  const KategorijaLifecycleStatus({
    required this.interniNaziv,
    required this.tip,
    required this.jeKorisnicka,
    required this.koriscenaUIriu,
    required this.imaPovezaneArtikle,
  });

  final String interniNaziv;
  final String tip;
  final bool jeKorisnicka;
  final bool koriscenaUIriu;
  final bool imaPovezaneArtikle;

  bool get mozeFizickoBrisanje =>
      jeKorisnicka &&
      !koriscenaUIriu &&
      !(tip == 'KATALOSKA' && imaPovezaneArtikle);
}

class KategorijaLifecycleIshod {
  const KategorijaLifecycleIshod({
    required this.obrisana,
    required this.deaktivirana,
    required this.status,
  });

  final bool obrisana;
  final bool deaktivirana;
  final KategorijaLifecycleStatus status;
}

class KategorijaInsertIshod {
  const KategorijaInsertIshod({
    required this.uspeh,
    required this.kategorija,
  });

  final bool uspeh;
  final IriuKatalogConfigData? kategorija;
}

class KatalogPickerArticleSummary {
  const KatalogPickerArticleSummary({
    required this.id,
    required this.stableArticleId,
    required this.interniNazivKategorije,
    required this.naziv,
    required this.cena,
    required this.hasPhoto,
  });

  final int id;
  final String? stableArticleId;
  final String interniNazivKategorije;
  final String naziv;
  final double cena;
  final bool hasPhoto;
}

typedef KatalogPickerEntry = ({
  IriuKatalogConfigData config,
  List<KatalogPickerArticleSummary> artikli
});

class PodesavanjaRepository {
  const PodesavanjaRepository(this._db);

  final AppDatabase _db;

  AppDatabase get db => _db;

  // ── Firma podaci ───────────────────────────────────────────────────────────

  Future<FirmaPodaciData> getFirmaPodaci() =>
      (_db.select(_db.firmaPodaci)..where((t) => t.id.equals(1))).getSingle();

  Stream<FirmaPodaciData> watchFirmaPodaci() =>
      (_db.select(_db.firmaPodaci)..where((t) => t.id.equals(1))).watchSingle();

  Future<void> saveFirmaPodaci(FirmaPodaciCompanion companion) =>
      (_db.update(_db.firmaPodaci)..where((t) => t.id.equals(1)))
          .write(companion);

  Future<AppPodesavanjaData> getAppPodesavanja() =>
      (_db.select(_db.appPodesavanja)..where((t) => t.id.equals(1)))
          .getSingle();

  Future<void> saveAppPodesavanja(AppPodesavanjaCompanion companion) =>
      (_db.update(_db.appPodesavanja)..where((t) => t.id.equals(1)))
          .write(companion);

  Stream<bool> watchStanjeRobeOperativnoOmoguceno() =>
      (_db.select(_db.appPodesavanja)..where((t) => t.id.equals(1)))
          .watchSingle()
          .map((podesavanja) => podesavanja.stanjeRobeOperativnoOmoguceno);

  Future<bool> isStanjeRobeOperativnoOmoguceno() async {
    final podesavanja = await getAppPodesavanja();
    return podesavanja.stanjeRobeOperativnoOmoguceno;
  }

  Future<void> setStanjeRobeOperativnoOmoguceno(bool enabled) {
    return saveAppPodesavanja(
      AppPodesavanjaCompanion(
        stanjeRobeOperativnoOmoguceno: Value(enabled),
      ),
    );
  }

  // ── IRIU Katalog — config stavke ───────────────────────────────────────────

  Stream<List<IriuKatalogConfigData>> watchKatalog() =>
      (_db.select(_db.iriuKatalogConfig)
            ..orderBy([(k) => OrderingTerm.asc(k.redosled)]))
          .watch();

  Future<void> azurirajKatalogStavku(
    String interniNaziv,
    IriuKatalogConfigCompanion companion,
  ) =>
      (_db.update(_db.iriuKatalogConfig)
            ..where((k) => k.interniNaziv.equals(interniNaziv)))
          .write(companion);

  Future<KategorijaLifecycleStatus?> proveriKategorijuZaLifecycleAkciju(
    String interniNaziv,
  ) async {
    final kategorija = await (_db.select(_db.iriuKatalogConfig)
          ..where((k) => k.interniNaziv.equals(interniNaziv)))
        .getSingleOrNull();
    if (kategorija == null) return null;

    final koriscenaUIriu = await (_db.select(_db.iriu)
          ..where((i) => i.interniNaziv.equals(interniNaziv)))
        .get()
        .then((rows) => rows.isNotEmpty);
    final imaPovezaneArtikle = await (_db.select(_db.katalogArtikli)
          ..where((a) => a.interniNazivKategorije.equals(interniNaziv)))
        .get()
        .then((rows) => rows.isNotEmpty);

    return KategorijaLifecycleStatus(
      interniNaziv: kategorija.interniNaziv,
      tip: kategorija.tip,
      jeKorisnicka: kategorija.jeKorisnicka,
      koriscenaUIriu: koriscenaUIriu,
      imaPovezaneArtikle: imaPovezaneArtikle,
    );
  }

  Future<KategorijaLifecycleIshod> ukloniIliDeaktivirajKorisnickuKategoriju(
    String interniNaziv,
  ) async {
    final status = await proveriKategorijuZaLifecycleAkciju(interniNaziv);
    if (status == null) {
      throw StateError('Kategorija nije pronađena.');
    }
    if (!status.jeKorisnicka) {
      throw StateError('Samo korisničke kategorije mogu menjati lifecycle.');
    }

    if (status.mozeFizickoBrisanje) {
      await _db.transaction(() async {
        await (_db.delete(_db.iriuKatalogConfig)
              ..where((k) => k.interniNaziv.equals(interniNaziv)))
            .go();
      });
      return KategorijaLifecycleIshod(
        obrisana: true,
        deaktivirana: false,
        status: status,
      );
    }

    await azurirajKatalogStavku(
      interniNaziv,
      const IriuKatalogConfigCompanion(vidljiv: Value(false)),
    );
    return KategorijaLifecycleIshod(
      obrisana: false,
      deaktivirana: true,
      status: status,
    );
  }

  // ── Katalog artikli ────────────────────────────────────────────────────────

  /// Učitava sve vidljive katalog kategorije sortirane po redosledu.
  Future<List<IriuKatalogConfigData>> getKatalogVidljive() =>
      (_db.select(_db.iriuKatalogConfig)
            ..where((k) => k.vidljiv.equals(true))
            ..orderBy([(k) => OrderingTerm.asc(k.redosled)]))
          .get();

  /// Učitava sve vidljive katalog kategorije + artikle za KATALOSKA tip.
  Future<List<({IriuKatalogConfigData config, List<KatalogArtikliData> artikli})>>
      getKatalogSaArtiklima() async {
    final kategorije = await getKatalogVidljive();
    final result =
        <({IriuKatalogConfigData config, List<KatalogArtikliData> artikli})>[];
    for (final kat in kategorije) {
      final artikli = kat.tip == 'KATALOSKA'
          ? await getArtikliZaKategoriju(kat.interniNaziv)
          : <KatalogArtikliData>[];
      result.add((config: kat, artikli: artikli));
    }
    return result;
  }

  Future<List<KatalogPickerEntry>> getKatalogSaArtiklimaLightweight() async {
    final kategorije = await getKatalogVidljive();
    final result = <KatalogPickerEntry>[];
    for (final kat in kategorije) {
      final artikli = kat.tip == 'KATALOSKA'
          ? await getArtikliZaKategorijuLightweight(kat.interniNaziv)
          : <KatalogPickerArticleSummary>[];
      result.add((config: kat, artikli: artikli));
    }
    return result;
  }

  Future<List<KatalogPickerEntry>> getKatalogSaArtiklimaLightweightZaKategorije(
    Iterable<String> interniNazivi,
  ) async {
    final requested = interniNazivi
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (requested.isEmpty) return const <KatalogPickerEntry>[];

    final kategorije = await ((_db.select(_db.iriuKatalogConfig)
              ..where(
                (k) =>
                    k.vidljiv.equals(true) &
                    k.interniNaziv.isIn(requested),
              )
              ..orderBy([(k) => OrderingTerm.asc(k.redosled)]))
            .get());
    final result = <KatalogPickerEntry>[];
    for (final kat in kategorije) {
      final artikli = kat.tip == 'KATALOSKA'
          ? await getArtikliZaKategorijuLightweight(kat.interniNaziv)
          : <KatalogPickerArticleSummary>[];
      result.add((config: kat, artikli: artikli));
    }
    return result;
  }

  Future<List<KatalogArtikliData>> getArtikliZaKategoriju(
    String interniNaziv,
  ) =>
      (_db.select(_db.katalogArtikli)
            ..where(
              (a) => a.interniNazivKategorije.equals(interniNaziv),
            )
            ..orderBy([(a) => OrderingTerm.asc(a.id)]))
          .get();

  Future<List<KatalogPickerArticleSummary>> getArtikliZaKategorijuLightweight(
    String interniNazivKategorije,
  ) async {
    final photoPresent = _db.katalogArtikli.fotografija.isNotNull();
    final rows = await (_db.selectOnly(_db.katalogArtikli)
          ..addColumns([
            _db.katalogArtikli.id,
            _db.katalogArtikli.stableArticleId,
            _db.katalogArtikli.interniNazivKategorije,
            _db.katalogArtikli.naziv,
            _db.katalogArtikli.cena,
            photoPresent,
          ])
          ..where(
            _db.katalogArtikli.interniNazivKategorije.equals(
              interniNazivKategorije,
            ),
          )
          ..orderBy([OrderingTerm.asc(_db.katalogArtikli.id)]))
        .get();

    return rows
        .map(
          (row) => KatalogPickerArticleSummary(
            id: row.read(_db.katalogArtikli.id)!,
            stableArticleId: row.read(_db.katalogArtikli.stableArticleId),
            interniNazivKategorije:
                row.read(_db.katalogArtikli.interniNazivKategorije)!,
            naziv: row.read(_db.katalogArtikli.naziv)!,
            cena: row.read(_db.katalogArtikli.cena)!,
            hasPhoto: row.read(photoPresent) ?? false,
          ),
        )
        .toList(growable: false);
  }

  Future<Uint8List?> getKatalogArticlePhotoById(int id) async {
    final row = await (_db.selectOnly(_db.katalogArtikli)
          ..addColumns([_db.katalogArtikli.fotografija])
          ..where(_db.katalogArtikli.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row?.read(_db.katalogArtikli.fotografija);
  }

  /// Kreira novu korisničku kategoriju u IriuKatalogConfig.
  Future<KategorijaInsertIshod> dodajKorisnickaKategoriju({
    required String interniNaziv,
    required String nazivPrikaz,
    required String tip, // FIKSNA ili KATALOSKA
  }) async {
    final maxRed = await (_db.select(_db.iriuKatalogConfig)
          ..orderBy([(k) => OrderingTerm.desc(k.redosled)])
          ..limit(1))
        .getSingleOrNull();
    final noviRed = (maxRed?.redosled ?? 0) + 1;
    try {
      await _db.into(_db.iriuKatalogConfig).insert(
            IriuKatalogConfigCompanion(
              interniNaziv: Value(interniNaziv),
              nazivPrikaz: Value(nazivPrikaz),
              tip: Value(tip),
              jeKorisnicka: const Value(true),
              redosled: Value(noviRed),
            ),
          );
    } catch (_) {
      final postojeca = await (_db.select(_db.iriuKatalogConfig)
            ..where((k) => k.interniNaziv.equals(interniNaziv)))
          .getSingleOrNull();
      return KategorijaInsertIshod(
        uspeh: false,
        kategorija: postojeca,
      );
    }

    final upisana = await (_db.select(_db.iriuKatalogConfig)
          ..where((k) => k.interniNaziv.equals(interniNaziv)))
        .getSingleOrNull();
    return KategorijaInsertIshod(
      uspeh: upisana != null,
      kategorija: upisana,
    );
  }

  Stream<List<KatalogArtikliData>> watchArtikli(
    String interniNazivKategorije,
  ) =>
      (_db.select(_db.katalogArtikli)
            ..where(
              (a) =>
                  a.interniNazivKategorije.equals(interniNazivKategorije),
             )
             ..orderBy([(a) => OrderingTerm.asc(a.id)]))
           .watch();

  Stream<bool> watchImaArtikalaZaKategoriju(
    String interniNazivKategorije,
  ) {
    final brojArtikala = _db.katalogArtikli.id.count();
    return ((_db.selectOnly(_db.katalogArtikli)
              ..addColumns([brojArtikala])
              ..where(
                _db.katalogArtikli.interniNazivKategorije.equals(
                  interniNazivKategorije,
                ),
              ))
            .watchSingle())
        .map((row) => (row.read(brojArtikala) ?? 0) > 0);
  }

  Future<void> dodajArtikl(KatalogArtikliCompanion companion) {
    final existingStableId = companion.stableArticleId.present
        ? companion.stableArticleId.value
        : null;
    final stableId = existingStableId != null &&
            existingStableId.trim().isNotEmpty
        ? existingStableId
        : generateCatalogArticleStableId();
    return _db.into(_db.katalogArtikli).insert(
          companion.copyWith(stableArticleId: Value(stableId)),
        );
  }

  Future<void> azurirajArtikl(int id, KatalogArtikliCompanion companion) =>
      (_db.update(_db.katalogArtikli)..where((a) => a.id.equals(id)))
          .write(companion);

  Future<void> obrisiArtikl(int id) =>
      (_db.delete(_db.katalogArtikli)..where((a) => a.id.equals(id))).go();

  // ── Predlošci dokumenata ───────────────────────────────────────────────────

  Future<List<PredlosciDokumenataData>> getPredlosciDokumenata() =>
      (_db.select(_db.predlosciDokumenata)
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<int> dodajPredlosak(PredlosciDokumenataCompanion companion) =>
      _db.into(_db.predlosciDokumenata).insert(companion);

  Future<void> azurirajPredlosak(
    int id,
    PredlosciDokumenataCompanion companion,
  ) =>
      (_db.update(_db.predlosciDokumenata)..where((t) => t.id.equals(id)))
          .write(companion);

  Future<void> obrisiPredlosak(int id) =>
      (_db.delete(_db.predlosciDokumenata)..where((t) => t.id.equals(id)))
          .go();
}
