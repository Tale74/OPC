import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../core_v2/business_policy/business_scenario_id.dart';
import '../core_v2/scenario/scenario_module_repository.dart';

enum SacuvajPredmetIshod { prviSave, novoSacuvano, bezIzmena }

class PartePreparationBlockException implements Exception {
  const PartePreparationBlockException();

  @override
  String toString() =>
      'PREDMET ima započetu PARTE pripremu koja nije završena.';
}

class PredmetImmutableLifecycleException implements Exception {
  const PredmetImmutableLifecycleException();

  @override
  String toString() =>
      'PREDMET je u završenom lifecycle statusu i ne može se menjati.';
}

class PredmetCompletionStateException implements Exception {
  const PredmetCompletionStateException();

  @override
  String toString() => 'PREDMET mora prvo biti označen kao ZATVOREN.';
}

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
  Stream<List<PredmetiData>> watchSvi() => (_db.select(
    _db.predmeti,
  )..orderBy([(p) => OrderingTerm.desc(p.datumKreiranja)])).watch();

  /// PREDMETI koje PODSETNIK sme da ponudi, od najnovijeg ka starijem.
  ///
  /// Koristi canonical lifecycle vrednosti iz PREDMETA. ZAVRŠEN i
  /// ANONIMIZOVAN nikada nisu aktivni izbori za podešavanje podsetnika.
  Future<List<PredmetiData>> getPodsetnikKandidate() =>
      (_db.select(_db.predmeti)
            ..where(
              (p) =>
                  p.status.equals('ZAVRŠEN').not() &
                  p.status.equals('ANONIMIZOVAN').not(),
            )
            ..orderBy([
              (p) => OrderingTerm.desc(p.datumKreiranja),
              (p) => OrderingTerm.desc(p.id),
            ]))
          .get();

  Future<PredmetiData> getPredmet(int id) =>
      (_db.select(_db.predmeti)..where((p) => p.id.equals(id))).getSingle();

  Future<bool> imaAktivnuNezavrsenuPartePripremu(int predmetId) async {
    final preparation =
        await (_db.select(_db.partePripreme)..where(
              (row) =>
                  row.predmetId.equals(predmetId) &
                  row.status.equals('IN_PROGRESS'),
            ))
            .getSingleOrNull();
    return preparation != null;
  }

  Future<void> _zahtevajDaParteNeBlokira(int predmetId) async {
    if (await imaAktivnuNezavrsenuPartePripremu(predmetId)) {
      throw const PartePreparationBlockException();
    }
  }

  DateTime? _parseDatumCeremonije(String value) => parseDateValue(value);

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime? datumDostupnostiAnonimizacije(PredmetiData predmet) {
    final datum = _parseDatumCeremonije(predmet.datumCeremonije);
    if (datum == null) return null;
    return _dateOnly(datum).add(const Duration(days: anonimizacijaPosleDana));
  }

  bool mozeAnonimizacija(PredmetiData predmet, {DateTime? now}) {
    return predmet.status == 'ZAVRŠEN';
  }

  Future<void> _upisiLogIzmene({
    required int predmetId,
    required int korisnikId,
    required String polje,
    required String staraVrednost,
    required String novaVrednost,
  }) {
    return _db
        .into(_db.logIzmena)
        .insert(
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
    return _db.transaction(() async {
      final brojPredmeta = await _alocirajJedinstveniBrojPredmeta(sada);
      return _db
          .into(_db.predmeti)
          .insert(
            PredmetiCompanion(
              brojPredmeta: Value(brojPredmeta),
              datumKreiranja: Value(sada.toIso8601String()),
              savetnikId: Value(savetnikId),
              businessScenarioId: Value(_defaultBusinessScenarioId),
              sourceIdentity: const Value(_localSourceIdentity),
              createdByKorisnikId: Value(savetnikId),
              pismo: const Value('CIRILICA'),
            ),
          );
    });
  }

  Future<String> _alocirajJedinstveniBrojPredmeta(DateTime sada) async {
    final base = kreirajBrojPredmeta(sada);
    var candidate = base;
    var suffix = 1;
    while ((await (_db.select(_db.predmeti)
            ..where((p) => p.brojPredmeta.equals(candidate)))
          .get())
        .isNotEmpty) {
      suffix++;
      candidate = '$base-$suffix';
    }
    return candidate;
  }

  Future<KorisniciData> zahtevajAktivnogLokalnogAktora(int? korisnikId) async {
    if (korisnikId == null) {
      throw StateError('Active local user is required for PREDMET transfer.');
    }
    final korisnik = await (_db.select(_db.korisnici)
          ..where((k) => k.id.equals(korisnikId)))
        .getSingleOrNull();
    if (korisnik == null ||
        !korisnik.aktivan ||
        (korisnik.uloga != 'ADMINISTRATOR' && korisnik.uloga != 'SAVETNIK')) {
      throw StateError(
        'An active local ADMINISTRATOR or SAVETNIK is required for PREDMET transfer.',
      );
    }
    return korisnik;
  }

  /// Materijalizuje osnovne IRIU redove samo za nov PREDMET.
  ///
  /// Scenario redovi ostaju u postojećim lifecycle servisima. Ovaj snapshot
  /// politike KATALOGA se kasnije ne usklađuje retroaktivno.
  /// Poziva se odmah nakon kreirajPredmet.
  Future<void> inicijalizujIriu(int predmetId) async {
    final katalog = await (_db.select(
      _db.iriuKatalogConfig,
    )..orderBy([(k) => OrderingTerm.asc(k.redosled)])).get();
    final katalogByInternalName = {
      for (final row in katalog) row.interniNaziv: row,
    };
    // KATALOG only describes categories.  The SCENARIO module is the single
    // source of truth for the basic package; the legacy catalog boolean is
    // intentionally inert (kept in the schema for compatibility).
    final scenarioRepository = ScenarioModuleRepository(_db);
    final module = await scenarioRepository.ensureModuleAndDefaults();
    final osnovniPaket = scenarioRepository.readOsnovniPaket(module);
    final inicijalneStavke = <({String interniNaziv, String? nazivPrikaz})>[
      for (final interniNaziv in osnovniPaket)
        (interniNaziv: interniNaziv, nazivPrikaz: null),
    ];
    final materializedInternalNames = <String>{};
    int red = 0;
    for (final stavka in inicijalneStavke) {
      if (!materializedInternalNames.add(stavka.interniNaziv)) continue;
      final katalogRow = katalogByInternalName[stavka.interniNaziv];
      if (katalogRow == null) continue;
      await _db
          .into(_db.iriu)
          .insert(
            IriuCompanion(
              predmetId: Value(predmetId),
              interniNaziv: Value(stavka.interniNaziv),
              nazivPrikaz: Value(stavka.nazivPrikaz ?? katalogRow.nazivPrikaz),
              kom: const Value('1'),
              // OSNOVNI PAKET is materialized before the SCENARIO
              // reconciliation pass.  Carry the fixed KATALOG price at
              // this boundary so the persisted IRiU row has the same
              // price/amount semantics as a scenario-added row.
              cena: Value(katalogRow.tip == 'FIKSNA' ? katalogRow.cena : 0.0),
              iznos: Value(katalogRow.tip == 'FIKSNA' ? katalogRow.cena : 0.0),
              redosled: Value(red++),
            ),
          );
    }
  }

  Future<void> obrisiPredmet(int id) => _db.transaction(() async {
    await StanjeRobeLifecycleService(db: _db).reconcileFullPredmetDelete(id);
    await _db.customStatement(
      'DELETE FROM ceremony_reminder_settings WHERE predmet_id = ?',
      [id],
    );
    await (_db.delete(
      _db.partePripreme,
    )..where((p) => p.predmetId.equals(id))).go();
    await (_db.delete(
      _db.logIzmena,
    )..where((l) => l.predmetId.equals(id))).go();
    await (_db.delete(
      _db.kontaktLica,
    )..where((k) => k.predmetId.equals(id))).go();
    await _db.customStatement(
      '''
      DELETE FROM iriu_provenance
      WHERE iriu_id IN (SELECT id FROM iriu WHERE predmet_id = ?)
      ''',
      [id],
    );
    await (_db.delete(
      _db.predmetScenarioSnapshots,
    )..where((snapshot) => snapshot.predmetId.equals(id))).go();
    await (_db.delete(_db.iriu)..where((i) => i.predmetId.equals(id))).go();
    await _db.customStatement(
      'DELETE FROM iriu_lifecycle_decisions WHERE predmet_id = ?',
      [id],
    );
    await (_db.delete(_db.predmeti)..where((p) => p.id.equals(id))).go();
  });

  Future<void> zatvoriPredmet(
    int id, {
    required int korisnikId,
  }) => _db.transaction(() async {
    final predmet = await getPredmet(id);
    if (predmet.status == 'ZATVOREN') return;
    if (predmet.status == 'ZAVRŠEN' || predmet.status == 'ANONIMIZOVAN') {
      throw const PredmetImmutableLifecycleException();
    }
    await _zahtevajDaParteNeBlokira(id);
    final trenutniSnapshot = snapshotZaSaveCommit(predmet);
    final poslednjiPotvrdjeniSnapshot =
        await procitajPoslednjiConfirmedCloseSnapshot(id);
    final sourceIdentity = predmet.sourceIdentity.trim().isEmpty
        ? _localSourceIdentity
        : predmet.sourceIdentity;
    final businessScenarioId = predmet.businessScenarioId.trim().isEmpty
        ? _defaultBusinessScenarioId
        : predmet.businessScenarioId;
    final imaPrethodnoPotvrdjenoStanje = poslednjiPotvrdjeniSnapshot != null;
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
    final poslednjiSaveSnapshot = await procitajPoslednjiSaveCommitSnapshot(id);
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
        if (predmet.status == 'ZAVRŠEN' || predmet.status == 'ANONIMIZOVAN') {
          throw const PredmetImmutableLifecycleException();
        }
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

  /// Automatsko označavanje kao ZAVRŠEN je povučeno.
  ///
  /// Metod ostaje radi kompatibilnosti sa starijim klijentima i uvek je bez
  /// efekta. Jedini dozvoljeni prelaz u ZAVRŠEN je [zavrsiPredmet].
  Future<bool> osveziAutomatskiStatusPredmeta(int id) async => false;

  /// Automatsko označavanje kao ZAVRŠEN je povučeno; nema masovne promene.
  Future<int> osveziAutomatskeStatuse() async => 0;

  /// Eksplicitno označava zatvoren PREDMET kao ZAVRŠEN i time ga zaključava
  /// za poslovne izmene. Ponovni prelaz ili otvaranje nisu dozvoljeni; GDPR
  /// anonimizacija ostaje zasebna lifecycle operacija.
  Future<void> zavrsiPredmet(int id, {required int korisnikId}) =>
      _db.transaction(() async {
        final predmet = await getPredmet(id);
        if (predmet.status == 'ZAVRŠEN') return;
        if (predmet.status == 'ANONIMIZOVAN') {
          throw const PredmetImmutableLifecycleException();
        }
        if (predmet.status != 'ZATVOREN') {
          throw const PredmetCompletionStateException();
        }
        await _zahtevajDaParteNeBlokira(id);
        final sada = DateTime.now().toIso8601String();
        await (_db.update(_db.predmeti)..where((p) => p.id.equals(id))).write(
          PredmetiCompanion(
            status: const Value('ZAVRŠEN'),
            lastBusinessModifiedByKorisnikId: Value(korisnikId),
            lastBusinessModifiedAt: Value(sada),
          ),
        );
        await _upisiLogIzmene(
          predmetId: id,
          korisnikId: korisnikId,
          polje: 'radni_ciklus',
          staraVrednost: 'v${predmet.verzija}:${predmet.status}',
          novaVrednost: 'v${predmet.verzija}:ZAVRŠEN',
        );
      });

  /// Rediguje zaštićene identifikacione i kontakt podatke.
  /// Imena ostaju vidljiva u OPC v1.
  Future<void> anonimizujPredmet(int id) async {
    await _zahtevajDaParteNeBlokira(id);
    await ((_db.update(
      _db.kontaktLica,
    )..where((k) => k.predmetId.equals(id)))).write(
      const KontaktLicaCompanion(
        telefon: Value(redactedValue),
        email: Value(redactedValue),
      ),
    );
    await _azurirajPredmet(
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
      allowLockedLifecycle: true,
    );
  }

  /// ZAVRŠEN predmeti — osnova za GDPR provjeru po starosti.
  Future<List<PredmetiData>> getZavrseneZaGdpr() => (_db.select(
    _db.predmeti,
  )..where((p) => p.status.equals('ZAVRŠEN'))).get();

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
    final poslednji =
        await ((_db.select(_db.logIzmena)
              ..where(
                (l) => l.predmetId.equals(predmetId) & l.polje.equals(polje),
              )
              ..limit(1)
              ..orderBy([(l) => OrderingTerm.desc(l.id)]))
            .getSingleOrNull());
    return poslednji?.novaVrednost;
  }

  Future<bool> imaNesacuvanihIzmena(int id, {String? fallbackSnapshot}) async {
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
  }) => _db.transaction(() async {
    final trenutno = await getPredmet(id);
    if (trenutno.status == 'ZAVRŠEN' || trenutno.status == 'ANONIMIZOVAN') {
      throw const PredmetImmutableLifecycleException();
    }
    final trenutniSnapshot = snapshotZaSaveCommit(trenutno);
    final poslednjiSaveSnapshot = await procitajPoslednjiSaveCommitSnapshot(id);
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
      _azurirajPredmet(id, companion);

  Future<void> _azurirajPredmet(
    int id,
    PredmetiCompanion companion, {
    bool allowLockedLifecycle = false,
  }) => _db.transaction(() async {
    final trenutno = await getPredmet(id);
    if (!allowLockedLifecycle &&
        (trenutno.status == 'ZAVRŠEN' || trenutno.status == 'ANONIMIZOVAN')) {
      throw const PredmetImmutableLifecycleException();
    }
    if (!allowLockedLifecycle &&
        companion.status.present &&
        companion.status.value == 'ZAVRŠEN') {
      throw StateError(
        'ZAVRŠEN se postavlja samo eksplicitnom lifecycle akcijom.',
      );
    }
    final sledece = trenutno.copyWithCompanion(companion);
    if (sledece == trenutno) return;

    await (_db.update(
      _db.predmeti,
    )..where((p) => p.id.equals(id))).write(companion);
  });

  Future<int> uveziPredmetSaPovezanimPodacima({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required List<KontaktLicaData> kontaktLica,
    required int localActorKorisnikId,
  }) => _db.transaction(
    () => uveziPredmetSaPovezanimPodacimaUnutarTransakcije(
      predmet: predmet,
      iriu: iriu,
      kontaktLica: kontaktLica,
      localActorKorisnikId: localActorKorisnikId,
    ),
  );

  /// Imports one PREDMET while the caller owns the surrounding transaction.
  /// This keeps bounded multi-PREDMET fallback imports atomic without creating
  /// a second database-merge abstraction.
  Future<int> uveziPredmetSaPovezanimPodacimaUnutarTransakcije({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required List<KontaktLicaData> kontaktLica,
    required int localActorKorisnikId,
  }) async {
    final actor = await zahtevajAktivnogLokalnogAktora(localActorKorisnikId);
    final sada = DateTime.now().toIso8601String();
    final localPredmet = predmet.copyWith(
      savetnikId: Value(actor.id),
      createdByKorisnikId: Value(actor.id),
      lastBusinessModifiedByKorisnikId: Value(actor.id),
      lastBusinessModifiedAt: Value(sada),
    );
    final newId = await _db
        .into(_db.predmeti)
        .insert(
          localPredmet.toCompanion(true).copyWith(id: const Value.absent()),
        );

    for (final stavka in iriu) {
      await _db
          .into(_db.iriu)
          .insert(
            stavka
                .toCompanion(true)
                .copyWith(id: const Value.absent(), predmetId: Value(newId)),
          );
    }

    for (final kontakt in kontaktLica) {
      await _db
          .into(_db.kontaktLica)
          .insert(
            kontakt
                .toCompanion(true)
                .copyWith(id: const Value.absent(), predmetId: Value(newId)),
          );
    }

    return newId;
  }

  Future<void> zameniPredmetSaPovezanimPodacima({
    required int lokalniPredmetId,
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required List<KontaktLicaData> kontaktLica,
    required int auditKorisnikId,
  }) => _db.transaction(() async {
    final existing = await getPredmet(lokalniPredmetId);
    await zahtevajAktivnogLokalnogAktora(auditKorisnikId);
    await StanjeRobeLifecycleService(
      db: _db,
    ).reconcilePredmetReplacement(lokalniPredmetId);
    await (_db.delete(
      _db.kontaktLica,
    )..where((k) => k.predmetId.equals(lokalniPredmetId))).go();
    await _db.customStatement(
      '''
      DELETE FROM iriu_provenance
      WHERE iriu_id IN (SELECT id FROM iriu WHERE predmet_id = ?)
      ''',
      [lokalniPredmetId],
    );
    await (_db.delete(
      _db.iriu,
    )..where((i) => i.predmetId.equals(lokalniPredmetId))).go();
    await (_db.delete(
      _db.predmetScenarioSnapshots,
    )..where((snapshot) => snapshot.predmetId.equals(lokalniPredmetId))).go();
    await _db.customStatement(
      'DELETE FROM iriu_lifecycle_decisions WHERE predmet_id = ?',
      [lokalniPredmetId],
    );

    await _db.update(_db.predmeti).replace(
      predmet.copyWith(
        id: lokalniPredmetId,
        savetnikId: Value(existing.savetnikId),
        createdByKorisnikId: Value(existing.createdByKorisnikId),
        lastBusinessModifiedByKorisnikId: Value(auditKorisnikId),
        lastBusinessModifiedAt: Value(DateTime.now().toIso8601String()),
      ),
    );

    for (final stavka in iriu) {
      await _db
          .into(_db.iriu)
          .insert(
            stavka
                .toCompanion(true)
                .copyWith(
                  id: const Value.absent(),
                  predmetId: Value(lokalniPredmetId),
                ),
          );
    }

    for (final kontakt in kontaktLica) {
      await _db
          .into(_db.kontaktLica)
          .insert(
            kontakt
                .toCompanion(true)
                .copyWith(
                  id: const Value.absent(),
                  predmetId: Value(lokalniPredmetId),
                ),
          );
    }

    // Local audit history belongs to the stable destination PREDMET identity.
    // Preserve prior entries and append one truthful replacement event inside
    // the same transaction as the accepted business replacement.
    await _upisiLogIzmene(
      predmetId: lokalniPredmetId,
      korisnikId: auditKorisnikId,
      polje: 'IMPORT_REPLACE',
      staraVrednost: '',
      novaVrednost: '',
    );
  });

  /// Svi predmeti — za izveštaje.
  Future<List<PredmetiData>> getSvePredmete() => _db.select(_db.predmeti).get();

  /// Svi korisnici — za izveštaj III (po savetnicima).
  Future<List<KorisniciData>> getSveKorisnike() =>
      _db.select(_db.korisnici).get();

  /// Reaktivni stream jednog savetnika — za header predmeta.
  Stream<KorisniciData?> watchSavetnik(int id) => (_db.select(
    _db.korisnici,
  )..where((k) => k.id.equals(id))).watchSingleOrNull();
}
