import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../core_v2/business_policy/business_scenario_id.dart';

enum SacuvajPredmetIshod { prviSave, novoSacuvano, bezIzmena }

class PredmetiRepository {
  const PredmetiRepository(this._db);

  static const String _saveCommitSnapshotPolje = '__save_commit_snapshot__';
  static const String _confirmedCloseSnapshotPolje =
      '__confirmed_close_snapshot__';
  static const String redactedValue = 'redacted';
  static const int anonimizacijaPosleDana = 15;
  static const String _localSourceIdentity = 'local_opc';
  static final String _defaultBusinessScenarioId =
      BusinessScenarioId.defaultFuneralCeremonyPolicy.value;

  final AppDatabase _db;

  /// Izlaže bazu za kreiranje podrepozitorijuma (IriuRepository, KontaktLicaRepository).
  AppDatabase get db => _db;

  /// Reaktivni stream svih predmeta, sortiran po datumu kreiranja (noviji prvo).
  Stream<List<PredmetiData>> watchSvi() =>
      (_db.select(_db.predmeti)
            ..orderBy([(p) => OrderingTerm.desc(p.datumKreiranja)]))
          .watch();

  Future<PredmetiData> getPredmet(int id) =>
      (_db.select(_db.predmeti)..where((p) => p.id.equals(id))).getSingle();

  DateTime? _parseDatumCeremonije(String value) => parseDateValue(value);

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime? datumDostupnostiAnonimizacije(PredmetiData predmet) {
    final datum = _parseDatumCeremonije(predmet.datumCeremonije);
    if (datum == null) return null;
    return _dateOnly(datum).add(const Duration(days: anonimizacijaPosleDana));
  }

  bool mozeAnonimizacija(
    PredmetiData predmet, {
    DateTime? now,
  }) {
    return predmet.status == 'ZAVRŠEN';
  }

  bool _trebaAutomatskiZavrsiti(PredmetiData predmet) {
    if (predmet.status == 'ZAVRŠEN' || predmet.status == 'ANONIMIZOVAN') {
      return false;
    }
    final datum = _parseDatumCeremonije(predmet.datumCeremonije);
    if (datum == null) return false;
    final danas = DateTime.now();
    final danasDate = DateTime(danas.year, danas.month, danas.day);
    return datum.isBefore(danasDate);
  }

  Future<void> _upisiLogIzmene({
    required int predmetId,
    required int korisnikId,
    required String polje,
    required String staraVrednost,
    required String novaVrednost,
  }) {
    return _db.into(_db.logIzmena).insert(
      LogIzmenaCompanion.insert(
        predmetId: predmetId,
        korisnikId: korisnikId,
        datumVreme: DateTime.now().toIso8601String(),
        polje: polje,
        staraVrednost: Value(staraVrednost),
        novaVrednost: Value(novaVrednost),
      ),
    );
  }

  /// Kreira novi predmet sa generisanim brojem i vraća njegov ID.
  Future<int> kreirajPredmet({required int savetnikId}) {
    final sada = DateTime.now();
    return _db.into(_db.predmeti).insert(
      PredmetiCompanion(
        brojPredmeta: Value(kreirajBrojPredmeta(sada)),
        datumKreiranja: Value(sada.toIso8601String()),
        savetnikId: Value(savetnikId),
        businessScenarioId: Value(_defaultBusinessScenarioId),
        sourceIdentity: const Value(_localSourceIdentity),
        createdByKorisnikId: Value(savetnikId),
        pismo: const Value('CIRILICA'),
      ),
    );
  }

  /// Popunjava IRIU tabelu zaključanim Blok 0 minimumom za nov predmet.
  /// Poziva se odmah nakon kreirajPredmet.
  Future<void> inicijalizujIriu(int predmetId) async {
    final katalog = await (_db.select(_db.iriuKatalogConfig)
          ..orderBy([(k) => OrderingTerm.asc(k.redosled)]))
        .get();
    final katalogByInternalName = {
      for (final row in katalog) row.interniNaziv: row,
    };
    final blok0Redosled = <({
      String interniNaziv,
      String? nazivPrikaz,
    })>[
      (interniNaziv: IriuK.sanduk, nazivPrikaz: null),
      (interniNaziv: IriuK.obelezje, nazivPrikaz: null),
      (interniNaziv: IriuK.pokrovGarnitura, nazivPrikaz: null),
      (interniNaziv: IriuK.peskirZaKrst, nazivPrikaz: IriuK.naziviPrikaz[IriuK.peskirZaKrst]),
      (interniNaziv: IriuK.posmrtneParte, nazivPrikaz: null),
      (interniNaziv: IriuK.crnina, nazivPrikaz: null),
      (interniNaziv: IriuK.agencijskeUsluge, nazivPrikaz: null),
      (interniNaziv: IriuK.cvece, nazivPrikaz: null),
      (interniNaziv: IriuK.cituljaP, nazivPrikaz: IriuK.naziviPrikaz[IriuK.cituljaP]),
    ];
    final korisnickeStavke = katalog
        .where((row) => row.jeKorisnicka)
        .map(
          (row) => (
            interniNaziv: row.interniNaziv,
            nazivPrikaz: row.nazivPrikaz,
          ),
        );
    final inicijalneStavke = <({
      String interniNaziv,
      String? nazivPrikaz,
    })>[
      ...blok0Redosled,
      ...korisnickeStavke,
    ];
    int red = 0;
    for (final stavka in inicijalneStavke) {
      final katalogRow = katalogByInternalName[stavka.interniNaziv];
      if (katalogRow == null) continue;
      await _db.into(_db.iriu).insert(
        IriuCompanion(
          predmetId: Value(predmetId),
          interniNaziv: Value(stavka.interniNaziv),
          nazivPrikaz: Value(stavka.nazivPrikaz ?? katalogRow.nazivPrikaz),
          kom: const Value('1'),
          redosled: Value(red++),
        ),
      );
    }
  }

  Future<void> obrisiPredmet(int id) =>
      _db.transaction(() async {
        await StanjeRobeLifecycleService(db: _db)
            .reconcileFullPredmetDelete(id);
        await (_db.delete(_db.logIzmena)
              ..where((l) => l.predmetId.equals(id)))
            .go();
        await (_db.delete(_db.kontaktLica)
              ..where((k) => k.predmetId.equals(id)))
            .go();
        await (_db.delete(_db.iriu)
              ..where((i) => i.predmetId.equals(id)))
            .go();
        await _db.customStatement(
          'DELETE FROM iriu_lifecycle_decisions WHERE predmet_id = ?',
          [id],
        );
        await (_db.delete(_db.predmeti)..where((p) => p.id.equals(id))).go();
      });

  Future<void> zatvoriPredmet(int id, {required int korisnikId}) =>
      _db.transaction(() async {
        final predmet = await getPredmet(id);
        if (predmet.status == 'ZATVOREN') return;
        final trenutniSnapshot = snapshotZaSaveCommit(predmet);
        final poslednjiPotvrdjeniSnapshot =
            await procitajPoslednjiConfirmedCloseSnapshot(id);
        final sourceIdentity = predmet.sourceIdentity.trim().isEmpty
            ? _localSourceIdentity
            : predmet.sourceIdentity;
        final businessScenarioId = predmet.businessScenarioId.trim().isEmpty
            ? _defaultBusinessScenarioId
            : predmet.businessScenarioId;
        final imaPrethodnoPotvrdjenoStanje =
            poslednjiPotvrdjeniSnapshot != null;
        final imaPoslovnihIzmena =
            !imaPrethodnoPotvrdjenoStanje ||
            poslednjiPotvrdjeniSnapshot != trenutniSnapshot;
        final staraVerzija = predmet.verzija;
        final novaVerzija = imaPrethodnoPotvrdjenoStanje
            ? (imaPoslovnihIzmena ? staraVerzija + 1 : staraVerzija)
            : staraVerzija;
        final sada = DateTime.now().toIso8601String();
        await (_db.update(_db.predmeti)..where((p) => p.id.equals(id))).write(
          PredmetiCompanion(
            status: const Value('ZATVOREN'),
            verzija: Value(novaVerzija),
            businessScenarioId: Value(businessScenarioId),
            sourceIdentity: Value(sourceIdentity),
            lastBusinessModifiedByKorisnikId: imaPoslovnihIzmena
                ? Value(korisnikId)
                : const Value.absent(),
            lastBusinessModifiedAt: imaPoslovnihIzmena
                ? Value(sada)
                : const Value.absent(),
          ),
        );
        final azuriran = await getPredmet(id);
        if (novaVerzija != staraVerzija) {
          await _upisiLogIzmene(
            predmetId: id,
            korisnikId: korisnikId,
            polje: 'verzija',
            staraVrednost: 'v$staraVerzija',
            novaVrednost: 'v$novaVerzija',
          );
        }
        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: _confirmedCloseSnapshotPolje,
          staraVrednost: poslednjiPotvrdjeniSnapshot ?? '',
          novaVrednost: trenutniSnapshot,
        );
        final poslednjiSaveSnapshot = await procitajPoslednjiSaveCommitSnapshot(
          id,
        );
        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: _saveCommitSnapshotPolje,
          staraVrednost: poslednjiSaveSnapshot ?? '',
          novaVrednost: trenutniSnapshot,
        );
        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: 'radni_ciklus',
          staraVrednost: 'v${predmet.verzija}:${predmet.status}',
          novaVrednost: 'v${azuriran.verzija}:${azuriran.status}',
        );
      });

  Future<void> otvoriPredmet(int id, {required int korisnikId}) =>
      _db.transaction(() async {
        final predmet = await getPredmet(id);
        final trenutniSnapshot = snapshotZaSaveCommit(predmet);
        final poslednjiPotvrdjeniSnapshot =
            await procitajPoslednjiConfirmedCloseSnapshot(id);
        if (poslednjiPotvrdjeniSnapshot == null) {
          await _upisiLogIzmene(
            predmetId: id,
            korisnikId: korisnikId,
            polje: _confirmedCloseSnapshotPolje,
            staraVrednost: '',
            novaVrednost: trenutniSnapshot,
          );
        }
        final poslednjiSaveSnapshot = await procitajPoslednjiSaveCommitSnapshot(
          id,
        );
        if (poslednjiSaveSnapshot == null) {
          await _upisiLogIzmene(
            predmetId: id,
            korisnikId: korisnikId,
            polje: _saveCommitSnapshotPolje,
            staraVrednost: '',
            novaVrednost: trenutniSnapshot,
          );
        }
        await azurirajPredmet(
          id,
          const PredmetiCompanion(status: Value('OTVOREN')),
        );
        final azuriran = await getPredmet(id);
        if (azuriran.verzija != predmet.verzija) {
          await _upisiLogIzmene(
            predmetId: id,
            korisnikId: korisnikId,
            polje: 'verzija',
            staraVrednost: 'v${predmet.verzija}',
            novaVrednost: 'v${azuriran.verzija}',
          );
        }
        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: 'radni_ciklus',
          staraVrednost: 'v${predmet.verzija}:${predmet.status}',
          novaVrednost: 'v${azuriran.verzija}:${azuriran.status}',
        );
      });

  Future<bool> osveziAutomatskiStatusPredmeta(int id) async {
    final predmet = await getPredmet(id);
    if (!_trebaAutomatskiZavrsiti(predmet)) return false;
    await azurirajPredmet(
      id,
      const PredmetiCompanion(status: Value('ZAVRŠEN')),
    );
    return true;
  }

  Future<int> osveziAutomatskeStatuse() async {
    final kandidati = await (_db.select(_db.predmeti)
          ..where(
            (p) =>
                p.status.equals('ZAVRŠEN').not() &
                p.status.equals('ANONIMIZOVAN').not() &
                p.datumCeremonije.isNotValue(''),
          ))
        .get();
    int promenjeno = 0;
    for (final predmet in kandidati) {
      if (_trebaAutomatskiZavrsiti(predmet)) {
        await azurirajPredmet(
          predmet.id,
          const PredmetiCompanion(status: Value('ZAVRŠEN')),
        );
        promenjeno++;
      }
    }
    return promenjeno;
  }

  /// Rediguje zaštićene identifikacione i kontakt podatke.
  /// Imena ostaju vidljiva u OPC v1.
  Future<void> anonimizujPredmet(int id) async {
    await ((_db.update(_db.kontaktLica)
          ..where((k) => k.predmetId.equals(id))))
        .write(
          const KontaktLicaCompanion(
            telefon: Value(redactedValue),
            email: Value(redactedValue),
          ),
        );
    await azurirajPredmet(
      id,
      const PredmetiCompanion(
        status: Value('ANONIMIZOVAN'),
        jmbg: Value(redactedValue),
        datumRodjenja: Value(redactedValue),
        mestoRodjenja: Value(redactedValue),
        adresa: Value(redactedValue),
        bracniDrugJmbg: Value(redactedValue),
        naruJmbg: Value(redactedValue),
        naruAdresa: Value(redactedValue),
        naruBrojLk: Value(redactedValue),
        naruTelefon1: Value(redactedValue),
        naruTelefon2: Value(redactedValue),
        naruEmail: Value(redactedValue),
        naruPlAdresa: Value(redactedValue),
        naruPlTelefon1: Value(redactedValue),
        naruPlTelefon2: Value(redactedValue),
        naruPlEmail: Value(redactedValue),
        jkpJmbg: Value(redactedValue),
        jkpAdresa: Value(redactedValue),
        jkpBrojLk: Value(redactedValue),
        jkpTelefon1: Value(redactedValue),
        jkpTelefon2: Value(redactedValue),
        jkpEmail: Value(redactedValue),
        jkpPlAdresa: Value(redactedValue),
        jkpPlTelefon1: Value(redactedValue),
        jkpPlEmail: Value(redactedValue),
      ),
    );
  }

  /// ZAVRŠEN predmeti — osnova za GDPR provjeru po starosti.
  Future<List<PredmetiData>> getZavrseneZaGdpr() =>
      (_db.select(_db.predmeti)
            ..where((p) => p.status.equals('ZAVRŠEN')))
          .get();

  String snapshotZaSaveCommit(PredmetiData predmet) {
    final data = Map<String, dynamic>.from(predmet.toJson())
      ..remove('status')
      ..remove('verzija')
      ..remove('exportVerzija')
      ..remove('businessScenarioId')
      ..remove('sourceIdentity')
      ..remove('createdByKorisnikId')
      ..remove('lastBusinessModifiedByKorisnikId')
      ..remove('lastBusinessModifiedAt');
    return jsonEncode(data);
  }

  Future<String?> procitajPoslednjiSaveCommitSnapshot(int predmetId) async {
    return _procitajPoslednjiSnapshotPoPolju(
      predmetId,
      _saveCommitSnapshotPolje,
    );
  }

  Future<String?> procitajPoslednjiConfirmedCloseSnapshot(int predmetId) async {
    return _procitajPoslednjiSnapshotPoPolju(
      predmetId,
      _confirmedCloseSnapshotPolje,
    );
  }

  Future<String?> _procitajPoslednjiSnapshotPoPolju(
    int predmetId,
    String polje,
  ) async {
    final poslednji = await ((_db.select(_db.logIzmena)
          ..where(
            (l) =>
                l.predmetId.equals(predmetId) &
                l.polje.equals(polje),
          )
          ..limit(1)
          ..orderBy([(l) => OrderingTerm.desc(l.id)]))
        .getSingleOrNull());
    return poslednji?.novaVrednost;
  }

  Future<bool> imaNesacuvanihIzmena(
    int id, {
    String? fallbackSnapshot,
  }) async {
    final trenutno = await getPredmet(id);
    final poslednjiSnapshot =
        await procitajPoslednjiSaveCommitSnapshot(id) ?? fallbackSnapshot;
    if (poslednjiSnapshot == null) {
      return true;
    }
    return snapshotZaSaveCommit(trenutno) != poslednjiSnapshot;
  }

  Future<SacuvajPredmetIshod> sacuvajPredmet(
    int id, {
    required int korisnikId,
    String? fallbackSnapshot,
  }) =>
      _db.transaction(() async {
        final trenutno = await getPredmet(id);
        final trenutniSnapshot = snapshotZaSaveCommit(trenutno);
        final poslednjiSaveSnapshot = await procitajPoslednjiSaveCommitSnapshot(
          id,
        );
        final poslednjiSnapshot = poslednjiSaveSnapshot ?? fallbackSnapshot;

        final jePrviSaveCommit = poslednjiSaveSnapshot == null;
        if (!jePrviSaveCommit && poslednjiSnapshot == trenutniSnapshot) {
          return SacuvajPredmetIshod.bezIzmena;
        }
        final sada = DateTime.now().toIso8601String();
        final businessScenarioId = trenutno.businessScenarioId.trim().isEmpty
            ? _defaultBusinessScenarioId
            : trenutno.businessScenarioId;
        final sourceIdentity = trenutno.sourceIdentity.trim().isEmpty
            ? _localSourceIdentity
            : trenutno.sourceIdentity;

        await (_db.update(_db.predmeti)..where((p) => p.id.equals(id))).write(
          PredmetiCompanion(
            businessScenarioId: Value(businessScenarioId),
            sourceIdentity: Value(sourceIdentity),
            lastBusinessModifiedByKorisnikId: Value(korisnikId),
            lastBusinessModifiedAt: Value(sada),
          ),
        );

        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: _saveCommitSnapshotPolje,
          staraVrednost: poslednjiSnapshot ?? '',
          novaVrednost: trenutniSnapshot,
        );
        return jePrviSaveCommit
            ? SacuvajPredmetIshod.prviSave
            : SacuvajPredmetIshod.novoSacuvano;
      });

  Future<void> azurirajPredmet(int id, PredmetiCompanion companion) =>
      _db.transaction(() async {
        final trenutno = await getPredmet(id);
        final sledece = trenutno.copyWithCompanion(companion);
        if (sledece == trenutno) return;

        await (_db.update(_db.predmeti)..where((p) => p.id.equals(id)))
            .write(companion);
      });

  Future<int> uveziPredmetSaPovezanimPodacima({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required List<KontaktLicaData> kontaktLica,
  }) =>
      _db.transaction(() async {
        final newId = await _db.into(_db.predmeti).insert(
              predmet.toCompanion(true).copyWith(id: const Value.absent()),
            );

        for (final stavka in iriu) {
          await _db.into(_db.iriu).insert(
                stavka.toCompanion(true).copyWith(
                      id: const Value.absent(),
                      predmetId: Value(newId),
                    ),
              );
        }

        for (final kontakt in kontaktLica) {
          await _db.into(_db.kontaktLica).insert(
                kontakt.toCompanion(true).copyWith(
                      id: const Value.absent(),
                      predmetId: Value(newId),
                    ),
              );
        }

        return newId;
      });

  Future<void> zameniPredmetSaPovezanimPodacima({
    required int lokalniPredmetId,
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required List<KontaktLicaData> kontaktLica,
  }) =>
      _db.transaction(() async {
        await StanjeRobeLifecycleService(db: _db)
            .reconcilePredmetReplacement(lokalniPredmetId);
        await (_db.delete(_db.logIzmena)
              ..where((l) => l.predmetId.equals(lokalniPredmetId)))
            .go();
        await (_db.delete(_db.kontaktLica)
              ..where((k) => k.predmetId.equals(lokalniPredmetId)))
            .go();
        await (_db.delete(_db.iriu)
              ..where((i) => i.predmetId.equals(lokalniPredmetId)))
            .go();
        await _db.customStatement(
          'DELETE FROM iriu_lifecycle_decisions WHERE predmet_id = ?',
          [lokalniPredmetId],
        );

        await _db.update(_db.predmeti).replace(
              predmet.copyWith(id: lokalniPredmetId),
            );

        for (final stavka in iriu) {
          await _db.into(_db.iriu).insert(
                stavka.toCompanion(true).copyWith(
                      id: const Value.absent(),
                      predmetId: Value(lokalniPredmetId),
                    ),
              );
        }

        for (final kontakt in kontaktLica) {
          await _db.into(_db.kontaktLica).insert(
                kontakt.toCompanion(true).copyWith(
                      id: const Value.absent(),
                      predmetId: Value(lokalniPredmetId),
                    ),
              );
        }
      });

  /// Svi predmeti — za izveštaje.
  Future<List<PredmetiData>> getSvePredmete() =>
      _db.select(_db.predmeti).get();

  /// Svi korisnici — za izveštaj III (po savetnicima).
  Future<List<KorisniciData>> getSveKorisnike() =>
      _db.select(_db.korisnici).get();

  /// Reaktivni stream jednog savetnika — za header predmeta.
  Stream<KorisniciData?> watchSavetnik(int id) =>
      (_db.select(_db.korisnici)..where((k) => k.id.equals(id)))
          .watchSingleOrNull();
}
