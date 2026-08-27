import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/json_transfer/predmet_json_transfer_core.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('same-FIRMA portable SAVETNIK responsibility', () {
    test('creation snapshots the local business responsible person', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await _user(db, 7, 'SYNTHETIC_ADMIN', 'SAVETNIK');

      final id = await PredmetiRepository(db).kreirajPredmet(savetnikId: 7);
      final predmet = await (db.select(
        db.predmeti,
      )..where((p) => p.id.equals(id))).getSingle();

      expect(predmet.savetnikId, 7);
      expect(predmet.businessResponsibleName, 'SYNTHETIC_ADMIN');
      expect(predmet.businessResponsibleRole, 'SAVETNIK');
    });

    test(
      'schema 8 carries responsibility and ignores a colliding numeric id',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);

        await _user(source, 4, 'SYNTHETIC_ADMIN', 'SAVETNIK');
        await _user(target, 4, 'SAŠA ANDONOV', 'ADMINISTRATOR');
        await _user(target, 9, 'SYNTHETIC_ADMIN', 'SAVETNIK');
        final sourceId = await source
            .into(source.predmeti)
            .insert(
              PredmetiCompanion.insert(
                brojPredmeta: const Value('PORTABLE-001'),
                savetnikId: const Value(4),
                businessResponsibleName: const Value('SYNTHETIC_ADMIN'),
                businessResponsibleRole: const Value('SAVETNIK'),
                createdByKorisnikId: const Value(4),
              ),
            );
        final json =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: source,
                    predmetId: sourceId,
                  ),
                )
                as Map<String, dynamic>;

        expect(json['schemaVersion'], 9);
        final wirePredmet = json['predmet'] as Map<String, dynamic>;
        expect(wirePredmet['businessResponsibleName'], 'SYNTHETIC_ADMIN');
        expect(wirePredmet['businessResponsibleRole'], 'SAVETNIK');
        expect(
          () => PredmetJsonTransferCore.assertSupportedRootSchema(json),
          returnsNormally,
        );

        await importPredmetJsonMapForTest(
          db: target,
          json: json,
          localActorKorisnikId: 4,
        );
        final imported = await (target.select(
          target.predmeti,
        )..where((p) => p.brojPredmeta.equals('PORTABLE-001'))).getSingle();
        expect(imported.businessResponsibleName, 'SYNTHETIC_ADMIN');
        expect(imported.businessResponsibleRole, 'SAVETNIK');
        expect(imported.savetnikId, 9);
        expect(imported.createdByKorisnikId, 4);
        expect(imported.lastBusinessModifiedByKorisnikId, 4);
      },
    );

    test(
      'legacy schema without portable responsibility remains unknown',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        await _user(db, 1, 'IMPORTER', 'ADMINISTRATOR');
        final source = createTestDatabase();
        addTearDown(source.close);
        final legacyId = await source
            .into(source.predmeti)
            .insert(
              PredmetiCompanion.insert(
                brojPredmeta: const Value('LEGACY-001'),
                savetnikId: const Value(99),
                createdByKorisnikId: const Value(99),
              ),
            );
        final json =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: source,
                    predmetId: legacyId,
                  ),
                )
                as Map<String, dynamic>;
        json['schemaVersion'] = 6;
        final legacyPredmet = json['predmet'] as Map<String, dynamic>;
        legacyPredmet.remove('businessResponsibleName');
        legacyPredmet.remove('businessResponsibleRole');

        await expectLater(
          importPredmetJsonMapForTest(
            db: db,
            json: json,
            localActorKorisnikId: 1,
          ),
          completes,
        );
        final imported = await (db.select(
          db.predmeti,
        )..where((p) => p.brojPredmeta.equals('LEGACY-001'))).getSingle();
        expect(imported.businessResponsibleName, isNull);
        expect(imported.businessResponsibleRole, isNull);
        expect(imported.savetnikId, isNull);
        expect(imported.createdByKorisnikId, 1);
      },
    );

    test('portable name without role stays unbound', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      await _user(source, 4, 'SYNTHETIC_ADMIN', 'SAVETNIK');
      await _user(target, 1, 'IMPORTER', 'ADMINISTRATOR');
      await _user(target, 9, 'SYNTHETIC_ADMIN', 'SAVETNIK');
      final sourceId = await source
          .into(source.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('MISSING-ROLE-001'),
              businessResponsibleName: const Value('SYNTHETIC_ADMIN'),
              createdByKorisnikId: const Value(4),
            ),
          );
      final json =
          jsonDecode(
                await serializePredmetJsonForTest(
                  db: source,
                  predmetId: sourceId,
                ),
              )
              as Map<String, dynamic>;

      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: 1,
      );
      final imported = await (target.select(
        target.predmeti,
      )..where((p) => p.brojPredmeta.equals('MISSING-ROLE-001'))).getSingle();
      expect(imported.businessResponsibleName, 'SYNTHETIC_ADMIN');
      expect(imported.businessResponsibleRole, isNull);
      expect(imported.savetnikId, isNull);
    });

    test('ambiguous destination name and role stays unbound', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      await _user(source, 4, 'SYNTHETIC_ADMIN', 'SAVETNIK');
      await _user(target, 1, 'IMPORTER', 'ADMINISTRATOR');
      await _user(target, 8, 'SYNTHETIC_ADMIN', 'SAVETNIK');
      await _user(target, 9, 'SYNTHETIC_ADMIN', 'SAVETNIK');
      final sourceId = await source
          .into(source.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('AMBIGUOUS-001'),
              businessResponsibleName: const Value('SYNTHETIC_ADMIN'),
              businessResponsibleRole: const Value('SAVETNIK'),
              createdByKorisnikId: const Value(4),
            ),
          );
      final json =
          jsonDecode(
                await serializePredmetJsonForTest(
                  db: source,
                  predmetId: sourceId,
                ),
              )
              as Map<String, dynamic>;

      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: 1,
      );
      final imported = await (target.select(
        target.predmeti,
      )..where((p) => p.brojPredmeta.equals('AMBIGUOUS-001'))).getSingle();
      expect(imported.businessResponsibleName, 'SYNTHETIC_ADMIN');
      expect(imported.businessResponsibleRole, 'SAVETNIK');
      expect(imported.savetnikId, isNull);
    });

    test(
      'replacement preserves incoming responsibility and records local modifier',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        await _user(db, 1, 'LOCAL_OWNER', 'SAVETNIK');
        await _user(db, 2, 'IMPORTER', 'ADMINISTRATOR');
        await _user(db, 8, 'SYNTHETIC_ADMIN', 'SAVETNIK');
        final localId = await db
            .into(db.predmeti)
            .insert(
              PredmetiCompanion.insert(
                brojPredmeta: const Value('REPLACE-001'),
                savetnikId: const Value(1),
                businessResponsibleName: const Value('LOCAL_OWNER'),
                businessResponsibleRole: const Value('SAVETNIK'),
                createdByKorisnikId: const Value(1),
              ),
            );
        final incoming =
            (await (db.select(
              db.predmeti,
            )..where((p) => p.id.equals(localId))).getSingle()).copyWith(
              id: 900,
              businessResponsibleName: const Value('SYNTHETIC_ADMIN'),
              businessResponsibleRole: const Value('SAVETNIK'),
              savetnikId: const Value(77),
            );
        expect(incoming.businessResponsibleName, 'SYNTHETIC_ADMIN');
        expect(incoming.businessResponsibleRole, 'SAVETNIK');
        expect(
          (await db.select(db.korisnici).get()).map(
            (u) => '${u.id}:${u.imePrezime}:${u.uloga}',
          ),
          contains('8:SYNTHETIC_ADMIN:SAVETNIK'),
        );
        expect(
          (await db.select(db.korisnici).get())
              .where(
                (u) =>
                    u.imePrezime == 'SYNTHETIC_ADMIN' && u.uloga == 'SAVETNIK',
              )
              .map((u) => u.id),
          [8],
        );

        await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
          lokalniPredmetId: localId,
          predmet: incoming,
          iriu: const [],
          kontaktLica: const [],
          auditKorisnikId: 2,
        );
        final replaced = await (db.select(
          db.predmeti,
        )..where((p) => p.id.equals(localId))).getSingle();
        expect(replaced.businessResponsibleName, 'SYNTHETIC_ADMIN');
        expect(replaced.savetnikId, 8);
        expect(replaced.createdByKorisnikId, 1);
        expect(replaced.lastBusinessModifiedByKorisnikId, 2);
        final logs = await (db.select(
          db.logIzmena,
        )..where((l) => l.predmetId.equals(localId))).get();
        expect(logs.any((l) => l.polje == 'IMPORT_REPLACE'), isTrue);
      },
    );
  });
}

Future<void> _user(AppDatabase db, int id, String name, String role) async {
  await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          id: Value(id),
          imePrezime: name,
          uloga: role,
          pinHash: 'test-$id',
          datumKreiranja: '2026-08-22T00:00:00.000',
        ),
      );
}
