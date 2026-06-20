import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import 'auth_security_repository.dart';

class ServiceRecoveryResult {
  const ServiceRecoveryResult({
    required this.targetUserId,
    required this.targetDisplayName,
    required this.temporaryPin,
  });

  final int targetUserId;
  final String targetDisplayName;
  final String temporaryPin;
}

class AuthRepository {
  AuthRepository(
    this._db, {
    AuthSecurityRepository? authSecurityRepo,
  }) : _authSecurityRepo = authSecurityRepo ?? AuthSecurityRepository(_db);

  final AppDatabase _db;
  final AuthSecurityRepository _authSecurityRepo;
  static const String _adminUloga = 'ADMINISTRATOR';

  String _hash(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasKorisnika() => _db.hasKorisnika();

  Future<KorisniciData?> prijava(String pin) =>
      _db.prijavaPin(_hash(pin));

  /// Verifikuje PIN za konkretnog korisnika (Opcija A — lista + PIN).
  Future<KorisniciData?> prijavaKorisnikPin(int korisnikId, String pin) =>
      _db.prijavaKorisnikPin(korisnikId, _hash(pin));

  /// Kreira prvog administratora pri prvom pokretanju.
  Future<KorisniciData> kreirajPrvogAdmina({
    required String imePrezime,
    required String pin,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = await _db.into(_db.korisnici).insert(
          KorisniciCompanion.insert(
            imePrezime: imePrezime,
            uloga: 'ADMINISTRATOR',
            pinHash: _hash(pin),
            datumKreiranja: now,
          ),
        );
    await _db.azurirajPinSecurityMetadata(id, pinUpdatedAt: now);
    await _db.postaviKorisnikMustChangePin(id, mustChangePin: false);
    return (await (_db.select(_db.korisnici)
              ..where((k) => k.id.equals(id)))
            .getSingle());
  }

  Future<List<KorisniciData>> sviKorisnici({bool samoAktivni = false}) {
    final query = _db.select(_db.korisnici)
      ..orderBy([(k) => OrderingTerm.asc(k.imePrezime)]);
    if (samoAktivni) {
      query.where((k) => k.aktivan.equals(true));
    }
    return query.get();
  }

  Future<List<KorisniciData>> aktivniAdministratori() {
    final query = _db.select(_db.korisnici)
      ..where((k) => k.aktivan.equals(true) & k.uloga.equals(_adminUloga))
      ..orderBy([(k) => OrderingTerm.asc(k.imePrezime)]);
    return query.get();
  }

  Future<bool> imaPodesenSigurnosniKod() =>
      _authSecurityRepo.hasInstallationRecoveryMaterial();

  Future<KorisniciData> kreirajKorisnika({
    required String imePrezime,
    required String uloga,
    required String pin,
  }) async {
    final hash = _hash(pin);
    final jedinstven = await _db.pinJedinstven(hash);
    if (!jedinstven) {
      throw Exception('PIN već postoji. Izaberite drugi PIN.');
    }
    final now = DateTime.now().toIso8601String();
    final id = await _db.into(_db.korisnici).insert(
          KorisniciCompanion.insert(
            imePrezime: imePrezime,
            uloga: uloga,
            pinHash: hash,
            datumKreiranja: now,
          ),
        );
    await _db.azurirajPinSecurityMetadata(id, pinUpdatedAt: now);
    await _db.postaviKorisnikMustChangePin(id, mustChangePin: false);
    return (await (_db.select(_db.korisnici)
              ..where((k) => k.id.equals(id)))
            .getSingle());
  }

  Future<void> deaktivirajKorisnika(int id, {int? izvrsilacId}) async {
    _zabraniSamodestruktivnuAdminAkciju(
      ciljniKorisnikId: id,
      izvrsilacId: izvrsilacId,
    );
    final korisnik = await (_db.select(_db.korisnici)
          ..where((k) => k.id.equals(id)))
        .getSingle();
    await _sacuvajNajmanjeJednogAktivnogAdmina(korisnik);
    await (_db.update(_db.korisnici)..where((k) => k.id.equals(id)))
        .write(const KorisniciCompanion(aktivan: Value(false)));
  }

  Future<void> promeniUlogu(
    int id,
    String novaUloga, {
    int? izvrsilacId,
  }) async {
    _zabraniSamodestruktivnuAdminAkciju(
      ciljniKorisnikId: id,
      izvrsilacId: izvrsilacId,
    );
    final korisnik = await (_db.select(_db.korisnici)
          ..where((k) => k.id.equals(id)))
        .getSingle();
    final skidaAktivnogAdmina =
        korisnik.aktivan &&
        korisnik.uloga == _adminUloga &&
        novaUloga != _adminUloga;
    if (skidaAktivnogAdmina) {
      await _sacuvajNajmanjeJednogAktivnogAdmina(korisnik);
    }
    await (_db.update(_db.korisnici)..where((k) => k.id.equals(id)))
        .write(KorisniciCompanion(uloga: Value(novaUloga)));
  }

  Future<void> resetujPin(
    int id,
    String noviPin, {
    bool zahtevajPromenuPina = false,
  }) async {
    final hash = _hash(noviPin);
    final jedinstven = await _db.pinJedinstven(hash, izuzmiId: id);
    if (!jedinstven) {
      throw Exception('PIN već postoji. Izaberite drugi PIN.');
    }
    await (_db.update(_db.korisnici)..where((k) => k.id.equals(id)))
        .write(KorisniciCompanion(pinHash: Value(hash)));
    final now = DateTime.now().toIso8601String();
    await _db.azurirajPinSecurityMetadata(id, pinUpdatedAt: now);
    await _db.postaviKorisnikMustChangePin(
      id,
      mustChangePin: zahtevajPromenuPina,
    );
  }

  Future<void> resetujPinUzAdminPotvrdu({
    required int adminId,
    required String adminPin,
    required int targetUserId,
    required String noviPin,
  }) {
    return _db.transaction(() async {
      final admin = await (_db.select(_db.korisnici)
            ..where((k) => k.id.equals(adminId)))
          .getSingle();
      if (!admin.aktivan || admin.uloga != _adminUloga) {
        throw Exception('Samo aktivni administrator moze da resetuje PIN.');
      }
      if (admin.pinHash != _hash(adminPin)) {
        throw Exception('Administratorski PIN nije tacan.');
      }

      final hash = _hash(noviPin);
      final jedinstven = await _db.pinJedinstven(hash, izuzmiId: targetUserId);
      if (!jedinstven) {
        throw Exception('PIN vec postoji. Izaberite drugi PIN.');
      }

      await (_db.update(_db.korisnici)
            ..where((k) => k.id.equals(targetUserId)))
          .write(KorisniciCompanion(pinHash: Value(hash)));
      final now = DateTime.now().toIso8601String();
      await _db.azurirajPinSecurityMetadata(targetUserId, pinUpdatedAt: now);
      await _db.postaviKorisnikMustChangePin(
        targetUserId,
        mustChangePin: true,
      );
      await _authSecurityRepo.writeAuthAuditEvent(
        eventType: 'admin_pin_reset',
        actorType: 'USER',
        actorUserId: adminId,
        targetUserId: targetUserId,
        result: 'SUCCESS',
        details: 'Administrator performed PIN reset. Must change PIN required.',
      );
    });
  }

  Future<ServiceRecoveryResult> oporaviAdministratorPristup({
    required String securityCode,
    required int targetAdminUserId,
  }) async {
    final normalizedCode = securityCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Sigurnosni kod je obavezan.');
    }

    final imaSigurnosniKod = await _authSecurityRepo
        .hasInstallationRecoveryMaterial();
    if (!imaSigurnosniKod) {
      throw Exception('Oporavak pristupa aplikaciji nije podešen.');
    }

    final targetAdmin = await (_db.select(_db.korisnici)
          ..where((k) =>
              k.id.equals(targetAdminUserId) &
              k.aktivan.equals(true) &
              k.uloga.equals(_adminUloga)))
        .getSingleOrNull();
    if (targetAdmin == null) {
      throw Exception('Administrator nije dostupan za oporavak pristupa.');
    }

    final validCode = await _authSecurityRepo
        .verifyInstallationRecoveryMaterial(normalizedCode);
    if (!validCode) {
      await _authSecurityRepo.writeAuthAuditEvent(
        eventType: 'service_recovery_failed',
        actorType: 'SERVICE',
        targetUserId: targetAdminUserId,
        result: 'FAILURE',
        details: 'Installation-level recovery code verification failed.',
      );
      throw Exception('Sigurnosni kod nije ispravan.');
    }

    return _db.transaction(() async {
      final temporaryPin = await _generateUniqueTemporaryPin(
        izuzmiId: targetAdmin.id,
      );
      final now = DateTime.now().toIso8601String();
      await (_db.update(_db.korisnici)
            ..where((k) => k.id.equals(targetAdmin.id)))
          .write(KorisniciCompanion(pinHash: Value(_hash(temporaryPin))));
      await _db.azurirajPinSecurityMetadata(
        targetAdmin.id,
        pinUpdatedAt: now,
      );
      await _db.postaviKorisnikMustChangePin(
        targetAdmin.id,
        mustChangePin: true,
      );
      await _authSecurityRepo.writeAuthAuditEvent(
        eventType: 'service_recovery_pin_reset',
        actorType: 'SERVICE',
        targetUserId: targetAdmin.id,
        result: 'SUCCESS',
        details:
            'Installation-level recovery verified. Temporary PIN issued. Must change PIN required.',
      );
      return ServiceRecoveryResult(
        targetUserId: targetAdmin.id,
        targetDisplayName: targetAdmin.imePrezime,
        temporaryPin: temporaryPin,
      );
    });
  }

  Future<void> promeniSopstveniPin(
    int id,
    String stariPin,
    String noviPin,
  ) async {
    final korisnik = await (_db.select(_db.korisnici)
          ..where((k) => k.id.equals(id)))
        .getSingle();
    if (korisnik.pinHash != _hash(stariPin)) {
      throw Exception('Stari PIN nije tačan.');
    }
    await resetujPin(id, noviPin);
    await _db.postaviKorisnikMustChangePin(id, mustChangePin: false);
  }

  Future<bool> korisnikMoraPromenitiPin(int id) =>
      _db.korisnikMustChangePin(id);

  Future<void> zavrsiObaveznuPromenuPina(int id, String noviPin) {
    return _db.transaction(() async {
      final hash = _hash(noviPin);
      final jedinstven = await _db.pinJedinstven(hash, izuzmiId: id);
      if (!jedinstven) {
        throw Exception('PIN vec postoji. Izaberite drugi PIN.');
      }
      await (_db.update(_db.korisnici)..where((k) => k.id.equals(id)))
          .write(KorisniciCompanion(pinHash: Value(hash)));
      final now = DateTime.now().toIso8601String();
      await _db.azurirajPinSecurityMetadata(id, pinUpdatedAt: now);
      await _db.postaviKorisnikMustChangePin(id, mustChangePin: false);
      await _authSecurityRepo.writeAuthAuditEvent(
        eventType: 'forced_pin_change_completed',
        actorType: 'USER',
        actorUserId: id,
        targetUserId: id,
        result: 'SUCCESS',
        details: 'User completed required PIN change after login.',
      );
    });
  }

  Future<void> oznaciDaKorisnikMoraPromenitiPin(int id) =>
      _db.postaviKorisnikMustChangePin(id, mustChangePin: true);

  Future<void> ocistiObaveznuPromenuPina(int id) =>
      _db.postaviKorisnikMustChangePin(id, mustChangePin: false);

  Future<bool> mozeTrajnoObrisatiKorisnika(
    int id, {
    int? izvrsilacId,
  }) async {
    try {
      await _proveriTrajnoBrisanjeKorisnika(
        id,
        izvrsilacId: izvrsilacId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Set<int>> trajnoObrisiviKorisnikIds(
    List<int> ids, {
    int? izvrsilacId,
  }) async {
    final deletableIds = <int>{};
    for (final id in ids) {
      if (await mozeTrajnoObrisatiKorisnika(id, izvrsilacId: izvrsilacId)) {
        deletableIds.add(id);
      }
    }
    return deletableIds;
  }

  Future<void> trajnoObrisiKorisnika(int id, {int? izvrsilacId}) async {
    final korisnik = await _proveriTrajnoBrisanjeKorisnika(
      id,
      izvrsilacId: izvrsilacId,
    );
    await (_db.delete(_db.korisnici)..where((k) => k.id.equals(korisnik.id)))
        .go();
  }

  Future<void> _sacuvajNajmanjeJednogAktivnogAdmina(
    KorisniciData korisnik,
  ) async {
    final metaAktivnogAdmina =
        korisnik.aktivan && korisnik.uloga == _adminUloga;
    if (!metaAktivnogAdmina) return;

    final brojAktivnihAdmina = await _db.brojAktivnihAdministratora();
    if (brojAktivnihAdmina <= 1) {
      throw Exception(
        'Nije dozvoljeno ukloniti poslednjeg aktivnog administratora.',
      );
    }
  }

  Future<KorisniciData> _proveriTrajnoBrisanjeKorisnika(
    int id, {
    int? izvrsilacId,
  }) async {
    if (izvrsilacId != null && id == izvrsilacId) {
      throw Exception('Ne možete obrisati sopstveni nalog.');
    }

    final korisnik = await (_db.select(_db.korisnici)
          ..where((k) => k.id.equals(id)))
        .getSingle();

    if (korisnik.aktivan && korisnik.uloga == _adminUloga) {
      final brojAktivnihAdmina = await _db.brojAktivnihAdministratora();
      if (brojAktivnihAdmina <= 1) {
        throw Exception('Poslednji aktivni administrator ne može biti obrisan.');
      }
    }

    final referenceSummary = await _db.korisnikReferenceSummary(id);
    if (referenceSummary.imaVezanePodatke) {
      final referenceOpis = referenceSummary.blokirajuceReference.join(', ');
      throw Exception(
        'Korisnik ne može biti obrisan jer ima vezane podatke: $referenceOpis.',
      );
    }

    return korisnik;
  }

  void _zabraniSamodestruktivnuAdminAkciju({
    required int ciljniKorisnikId,
    int? izvrsilacId,
  }) {
    if (izvrsilacId != null && ciljniKorisnikId == izvrsilacId) {
      throw Exception(
        'Nije dozvoljena destruktivna administratorska akcija nad trenutno prijavljenim korisnikom.',
      );
    }
  }

  Future<String> _generateUniqueTemporaryPin({required int izuzmiId}) async {
    for (var attempt = 0; attempt < 24; attempt++) {
      final candidate = _authSecurityRepo.generateTemporaryPin();
      final unique = await _db.pinJedinstven(
        _hash(candidate),
        izuzmiId: izuzmiId,
      );
      if (unique) return candidate;
    }
    throw Exception('Nije moguće generisati privremeni PIN. Pokušajte ponovo.');
  }
}
