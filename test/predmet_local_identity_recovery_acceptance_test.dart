import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/format/app_format.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('PREDMET local identity / recovery acceptance', () {
    test('new import ignores foreign numeric user identity', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);

      await _insertUser(source, id: 1, role: 'SAVETNIK');
      await _insertUser(target, id: 1, role: 'SAVETNIK');
      await _insertUser(target, id: 7, role: 'ADMINISTRATOR');
      final sourcePredmet = await _insertPredmet(
        source,
        broj: 'LOCAL-IMPORT-001/2026',
        savetnikId: 1,
        createdBy: 1,
        lastModifier: 1,
      );
      final json = await _predmetJson(source, sourcePredmet.id);

      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: 7,
      );

      final imported = (await target.select(target.predmeti).get()).single;
      // Legacy JSON without the portable responsibility snapshot keeps the
      // business responsible person unknown; importer identity remains only
      // creator/modifier attribution.
      expect(imported.savetnikId, isNull);
      expect(imported.createdByKorisnikId, 7);
      expect(imported.lastBusinessModifiedByKorisnikId, 7);
      expect(imported.ime, sourcePredmet.ime);
    });

    test('new import succeeds when source user id is absent locally', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);

      await _insertUser(source, id: 91, role: 'SAVETNIK');
      await _insertUser(target, id: 7, role: 'SAVETNIK');
      final sourcePredmet = await _insertPredmet(
        source,
        broj: 'LOCAL-IMPORT-002/2026',
        savetnikId: 91,
        createdBy: 91,
        lastModifier: 91,
      );
      await importPredmetJsonMapForTest(
        db: target,
        json: await _predmetJson(source, sourcePredmet.id),
        localActorKorisnikId: 7,
      );

      expect(
        (await target.select(target.predmeti).get()).single.savetnikId,
        isNull,
      );
    });

    test(
      'replacement preserves destination ownership and uses local actor',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        await _insertUser(db, id: 2, role: 'SAVETNIK');
        await _insertUser(db, id: 7, role: 'ADMINISTRATOR');
        final local = await _insertPredmet(
          db,
          broj: 'LOCAL-REPLACE-001/2026',
          savetnikId: 2,
          createdBy: 2,
          lastModifier: 2,
        );
        final incoming = local.copyWith(
          id: 999,
          ime: 'Replacement truth',
          savetnikId: const Value(91),
          createdByKorisnikId: const Value(91),
          lastBusinessModifiedByKorisnikId: const Value(91),
        );

        await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
          lokalniPredmetId: local.id,
          predmet: incoming,
          iriu: const [],
          kontaktLica: const [],
          auditKorisnikId: 7,
        );

        final replaced = await PredmetiRepository(db).getPredmet(local.id);
        expect(replaced.savetnikId, 2);
        expect(replaced.createdByKorisnikId, 2);
        expect(replaced.lastBusinessModifiedByKorisnikId, 7);
        expect(replaced.ime, 'Replacement truth');
        final event = (await db.select(db.logIzmena).get()).single;
        expect(event.korisnikId, 7);
        expect(event.polje, 'IMPORT_REPLACE');
      },
    );

    test(
      'missing or inactive actor fails before individual import mutation',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        final sourcePredmet = await _insertPredmet(
          source,
          broj: 'LOCAL-IMPORT-003/2026',
        );
        final json = await _predmetJson(source, sourcePredmet.id);

        await expectLater(
          importPredmetJsonMapForTest(
            db: target,
            json: json,
            localActorKorisnikId: null,
          ),
          throwsA(isA<StateError>()),
        );
        await _insertUser(target, id: 8, role: 'SAVETNIK', active: false);
        await expectLater(
          importPredmetJsonMapForTest(
            db: target,
            json: json,
            localActorKorisnikId: 8,
          ),
          throwsA(isA<StateError>()),
        );
        expect(await target.select(target.predmeti).get(), isEmpty);
      },
    );

    test(
      'creator-only and last-modifier-only references block deletion',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final auth = AuthRepository(db);
        await _insertUser(db, id: 9, role: 'SAVETNIK');
        final creatorOnly = await _insertPredmet(
          db,
          broj: 'DELETE-CREATOR-001/2026',
          createdBy: 9,
        );
        await expectLater(auth.trajnoObrisiKorisnika(9), throwsA(anything));
        await (db.update(db.predmeti)
              ..where((p) => p.id.equals(creatorOnly.id)))
            .write(const PredmetiCompanion(createdByKorisnikId: Value(null)));
        await (db.update(
          db.predmeti,
        )..where((p) => p.id.equals(creatorOnly.id))).write(
          const PredmetiCompanion(lastBusinessModifiedByKorisnikId: Value(9)),
        );
        await expectLater(auth.trajnoObrisiKorisnika(9), throwsA(anything));
      },
    );

    test(
      'deactivation and role change do not rewrite historical attribution',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final auth = AuthRepository(db);
        await _insertUser(db, id: 1, role: 'ADMINISTRATOR');
        await _insertUser(db, id: 9, role: 'SAVETNIK');
        final predmet = await _insertPredmet(
          db,
          broj: 'ATTRIBUTION-001/2026',
          savetnikId: 9,
          createdBy: 9,
          lastModifier: 9,
        );
        await db
            .into(db.logIzmena)
            .insert(
              LogIzmenaCompanion.insert(
                predmetId: predmet.id,
                korisnikId: 9,
                datumVreme: '2026-08-21T08:00:00.000',
                polje: 'test',
              ),
            );

        await auth.deaktivirajKorisnika(9, izvrsilacId: 1);
        await auth.promeniUlogu(9, 'ADMINISTRATOR', izvrsilacId: 1);

        final unchanged = await PredmetiRepository(db).getPredmet(predmet.id);
        expect(unchanged.savetnikId, 9);
        expect(unchanged.createdByKorisnikId, 9);
        expect(unchanged.lastBusinessModifiedByKorisnikId, 9);
        expect((await db.select(db.logIzmena).get()).single.korisnikId, 9);
      },
    );

    test(
      'matching full-backup identity passes and mismatch is non-destructive',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _setFirmaIdentity(source, pib: '111111111', mb: '10000001');
        await _setFirmaIdentity(target, pib: '111111111', mb: '10000001');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;
        await importBackupJsonMapForTest(db: target, json: backup);
        expect(
          (await target.select(target.firmaPodaci).getSingle()).pib,
          '111111111',
        );

        await _setFirmaIdentity(target, pib: '222222222', mb: '20000002');
        await expectLater(
          importBackupJsonMapForTest(db: target, json: backup),
          throwsA(anything),
        );
        final unchanged = await target.select(target.firmaPodaci).getSingle();
        expect(unchanged.pib, '222222222');
        expect(unchanged.mb, '20000002');
      },
    );

    test(
      'fresh local identity can be established from a complete backup',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _setFirmaIdentity(source, pib: '333333333', mb: '30000003');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;

        await importBackupJsonMapForTest(db: target, json: backup);

        final restored = await target.select(target.firmaPodaci).getSingle();
        expect(restored.pib, '333333333');
        expect(restored.mb, '30000003');
      },
    );

    test(
      'incomplete full-backup identity fails before destructive write',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _setFirmaIdentity(target, pib: 'LOCAL-PIB', mb: 'LOCAL-MB');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;

        await expectLater(
          importBackupJsonMapForTest(db: target, json: backup),
          throwsA(anything),
        );
        final unchanged = await target.select(target.firmaPodaci).getSingle();
        expect(unchanged.pib, 'LOCAL-PIB');
        expect(unchanged.mb, 'LOCAL-MB');
      },
    );

    test(
      'case-2 fallback imports only new unambiguous PREDMET families',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _insertPredmet(
          source,
          broj: 'CASE2-CONFLICT-001/2026',
          savetnikId: 91,
          createdBy: 91,
          lastModifier: 91,
        );
        await _insertPredmet(
          source,
          broj: 'CASE2-NEW-001/2026',
          savetnikId: 91,
          createdBy: 91,
          lastModifier: 91,
        );
        await _insertUser(target, id: 7, role: 'ADMINISTRATOR');
        final localConflict = await _insertPredmet(
          target,
          broj: 'CASE2-CONFLICT-001/2026',
          savetnikId: 7,
          createdBy: 7,
          lastModifier: 7,
        );
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;

        final plan = await buildCase2FallbackPlanForTest(
          db: target,
          json: backup,
        );
        expect(plan.newPredmetCount, 1);
        expect(plan.sameIdentityConflictCount, 1);
        expect(plan.ambiguousCount, 0);
        expect(plan.retainedFamilyCount, greaterThan(0));

        final outcome = await applyCase2FallbackForTest(
          db: target,
          json: backup,
          localActorKorisnikId: 7,
        );
        expect(outcome.importedPredmetCount, 1);
        expect(outcome.skippedConflictCount, 1);
        final rows = await target.select(target.predmeti).get();
        expect(rows, hasLength(2));
        final unchanged = rows.singleWhere(
          (row) => row.brojPredmeta == localConflict.brojPredmeta,
        );
        expect(unchanged.id, localConflict.id);
        expect(unchanged.savetnikId, 7);
        final imported = rows.singleWhere(
          (row) => row.brojPredmeta == 'CASE2-NEW-001/2026',
        );
        expect(imported.savetnikId, isNull);
        expect(imported.createdByKorisnikId, 7);
        expect(imported.lastBusinessModifiedByKorisnikId, 7);
      },
    );

    test(
      'case-2 duplicate incoming identity is ambiguous and non-mutating',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _insertPredmet(source, broj: 'CASE2-AMBIGUOUS-001/2026');
        await _insertUser(target, id: 7, role: 'ADMINISTRATOR');
        await _insertPredmet(target, broj: 'CASE2-LOCAL-001/2026');
        final backup =
            jsonDecode(await serializeBackupJsonForTest(db: source))
                as Map<String, dynamic>;
        final predmetRows = (backup['predmeti'] as List)
            .cast<Map<String, dynamic>>();
        predmetRows.add(Map<String, dynamic>.from(predmetRows.single));

        final plan = await buildCase2FallbackPlanForTest(
          db: target,
          json: backup,
        );
        expect(plan.newPredmetCount, 0);
        expect(plan.ambiguousCount, 2);
        final before = await target.select(target.predmeti).get();
        final outcome = await applyCase2FallbackForTest(
          db: target,
          json: backup,
          localActorKorisnikId: 7,
        );
        expect(outcome.importedPredmetCount, 0);
        expect(await target.select(target.predmeti).get(), before);
      },
    );

    test(
      'same-minute creation resolves collision without renumbering legacy rows',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        await _insertUser(db, id: 1, role: 'ADMINISTRATOR');
        final base = kreirajBrojPredmeta(DateTime.now());
        await _insertPredmet(db, broj: base);
        await _insertPredmet(db, broj: base);

        final createdId = await PredmetiRepository(
          db,
        ).kreirajPredmet(savetnikId: 1);
        final created = await PredmetiRepository(db).getPredmet(createdId);
        expect(created.brojPredmeta, isNot(base));
        expect(
          await (db.select(
            db.predmeti,
          )..where((p) => p.brojPredmeta.equals(base))).get(),
          hasLength(2),
        );
      },
    );

    test(
      'new individual import does not silently broaden IMPORT_NEW taxonomy',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        await _insertUser(target, id: 7, role: 'ADMINISTRATOR');
        final sourcePredmet = await _insertPredmet(
          source,
          broj: 'NO-IMPORT-NEW-001/2026',
        );
        await importPredmetJsonMapForTest(
          db: target,
          json: await _predmetJson(source, sourcePredmet.id),
          localActorKorisnikId: 7,
        );
        expect(await target.select(target.logIzmena).get(), isEmpty);
      },
    );
  });
}

Future<void> _insertUser(
  AppDatabase db, {
  required int id,
  required String role,
  bool active = true,
}) async {
  await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          id: Value(id),
          imePrezime: 'User $id',
          uloga: role,
          pinHash: 'hash-$id',
          aktivan: Value(active),
          datumKreiranja: '2026-08-21T00:00:00.000',
        ),
      );
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  required String broj,
  int? savetnikId,
  int? createdBy,
  int? lastModifier,
}) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-08-21T08:00:00.000'),
          savetnikId: Value(savetnikId),
          createdByKorisnikId: Value(createdBy),
          lastBusinessModifiedByKorisnikId: Value(lastModifier),
        ),
      );
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}

Future<Map<String, dynamic>> _predmetJson(AppDatabase db, int predmetId) async {
  return jsonDecode(
        await serializePredmetJsonForTest(db: db, predmetId: predmetId),
      )
      as Map<String, dynamic>;
}

Future<void> _setFirmaIdentity(
  AppDatabase db, {
  required String pib,
  required String mb,
}) {
  return (db.update(db.firmaPodaci)..where((f) => f.id.equals(1))).write(
    FirmaPodaciCompanion(pib: Value(pib), mb: Value(mb)),
  );
}
