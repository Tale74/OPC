import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class StanjeRobeRepository {
  const StanjeRobeRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  AppDatabase get db => _db;

  Stream<List<StanjeRobeStavkeData>> watchSveStavke() =>
      (_db.select(_db.stanjeRobeStavke)
            ..orderBy([(t) => OrderingTerm.asc(t.stableArticleId)]))
          .watch();

  Future<List<StanjeRobeStavkeData>> getSveStavke() =>
      (_db.select(_db.stanjeRobeStavke)
            ..orderBy([(t) => OrderingTerm.asc(t.stableArticleId)]))
          .get();

  Stream<StanjeRobeStavkeData?> watchByStableArticleId(String stableArticleId) {
    final normalized = _normalizeStableArticleId(stableArticleId);
    return (_db.select(_db.stanjeRobeStavke)
          ..where((t) => t.stableArticleId.equals(normalized)))
        .watchSingleOrNull();
  }

  Future<StanjeRobeStavkeData?> getByStableArticleId(
    String stableArticleId,
  ) async {
    final normalized = _normalizeStableArticleId(stableArticleId);
    return (_db.select(_db.stanjeRobeStavke)
          ..where((t) => t.stableArticleId.equals(normalized)))
        .getSingleOrNull();
  }

  Future<void> sacuvajStanje({
    required String stableArticleId,
    required double trenutnaKolicina,
    required double minimalnaKolicina,
    bool? aktivna,
  }) async {
    final normalized = _normalizeStableArticleId(stableArticleId);
    final now = DateTime.now().toIso8601String();

    await _db.transaction(() async {
      final postojeca = await (_db.select(_db.stanjeRobeStavke)
            ..where((t) => t.stableArticleId.equals(normalized)))
          .getSingleOrNull();

      if (postojeca == null) {
        await _db.into(_db.stanjeRobeStavke).insert(
              StanjeRobeStavkeCompanion.insert(
                stableArticleId: normalized,
                trenutnaKolicina: Value(trenutnaKolicina),
                minimalnaKolicina: Value(minimalnaKolicina),
                aktivna: Value(aktivna ?? true),
                datumKreiranja: Value(now),
                datumAzuriranja: Value(now),
              ),
            );
        return;
      }

      await (_db.update(_db.stanjeRobeStavke)
            ..where((t) => t.stableArticleId.equals(normalized)))
          .write(
        StanjeRobeStavkeCompanion(
          trenutnaKolicina: Value(trenutnaKolicina),
          minimalnaKolicina: Value(minimalnaKolicina),
          aktivna: aktivna == null ? const Value.absent() : Value(aktivna),
          datumAzuriranja: Value(now),
        ),
      );
    });
  }

  Future<int> inicijalizujNedostajuceStavke(
    Iterable<String> stableArticleIds,
  ) async {
    final normalizedIds = <String>{};
    for (final stableArticleId in stableArticleIds) {
      normalizedIds.add(_normalizeStableArticleId(stableArticleId));
    }
    if (normalizedIds.isEmpty) return 0;

    final now = DateTime.now().toIso8601String();
    return _db.transaction(() async {
      var inserted = 0;
      for (final stableArticleId in normalizedIds) {
        final postojeca = await (_db.select(_db.stanjeRobeStavke)
              ..where((t) => t.stableArticleId.equals(stableArticleId)))
            .getSingleOrNull();
        if (postojeca != null) continue;

        await _db.into(_db.stanjeRobeStavke).insert(
              StanjeRobeStavkeCompanion.insert(
                stableArticleId: stableArticleId,
                trenutnaKolicina: const Value(0),
                minimalnaKolicina: const Value(0),
                aktivna: const Value(true),
                datumKreiranja: Value(now),
                datumAzuriranja: Value(now),
              ),
            );
        inserted++;
      }
      return inserted;
    });
  }

  Future<void> postaviAktivnost(
    String stableArticleId, {
    required bool aktivna,
  }) async {
    final normalized = _normalizeStableArticleId(stableArticleId);
    final now = DateTime.now().toIso8601String();

    await (_db.update(_db.stanjeRobeStavke)
          ..where((t) => t.stableArticleId.equals(normalized)))
        .write(
      StanjeRobeStavkeCompanion(
        aktivna: Value(aktivna),
        datumAzuriranja: Value(now),
      ),
    );
  }

  Future<StanjeRobeStavkeData> zahtevajByStableArticleId(
    String stableArticleId,
  ) async {
    final stanje = await getByStableArticleId(stableArticleId);
    if (stanje == null) {
      throw StateError(
        'STANJE ROBE record not found for stableArticleId: $stableArticleId',
      );
    }
    return stanje;
  }

  Future<StanjeRobeStavkeData> promeniTrenutnuKolicinu({
    required String stableArticleId,
    required double delta,
  }) async {
    final normalized = _normalizeStableArticleId(stableArticleId);
    final now = DateTime.now().toIso8601String();

    return _db.transaction(() async {
      final postojeca = await (_db.select(_db.stanjeRobeStavke)
            ..where((t) => t.stableArticleId.equals(normalized)))
          .getSingleOrNull();

      if (postojeca == null) {
        throw StateError(
          'STANJE ROBE record not found for stableArticleId: $normalized',
        );
      }

      final novaKolicina = postojeca.trenutnaKolicina + delta;
      if (novaKolicina < 0) {
        throw StateError(
          'STANJE ROBE quantity would become negative for stableArticleId: $normalized',
        );
      }

      await (_db.update(_db.stanjeRobeStavke)
            ..where((t) => t.id.equals(postojeca.id)))
          .write(
        StanjeRobeStavkeCompanion(
          trenutnaKolicina: Value(novaKolicina),
          datumAzuriranja: Value(now),
        ),
      );

      return postojeca.copyWith(
        trenutnaKolicina: novaKolicina,
        datumAzuriranja: now,
      );
    });
  }

  String _normalizeStableArticleId(String stableArticleId) {
    final normalized = stableArticleId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        stableArticleId,
        'stableArticleId',
        'stableArticleId must not be empty.',
      );
    }
    return normalized;
  }
}
