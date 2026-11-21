import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';

import 'test_bootstrap.dart';

Map<String, dynamic> decode(String json) =>
    (jsonDecode(json) as Map).cast<String, dynamic>();

void main() {
  test(
    'SRB refuses currency it cannot round-trip before modifying target',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      for (final db in [source, target]) {
        await db
            .into(db.firmaPodaci)
            .insertOnConflictUpdate(
              const FirmaPodaciCompanion(
                id: Value(1),
                naziv: Value('Synthetic FIRMA'),
                pib: Value('00QA-PIB'),
                mb: Value('0QA00001'),
              ),
            );
      }
      final actor = await AuthRepository(
        target,
      ).kreirajPrvogAdmina(imePrezime: 'SYNTHETIC ADMIN', pin: '2917');
      final id = await source
          .into(source.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('QA-COMPAT-002'),
              datumKreiranja: const Value('2026-01-02T00:00:00.000'),
              avans: const Value(41.25),
            ),
          );
      final backup = decode(await serializeBackupJsonForTest(db: source));
      final transfer = decode(
        await serializePredmetJsonForTest(db: source, predmetId: id),
      );
      final fullRow = (backup['predmeti'] as List).single as Map;
      final singleRow = transfer['predmet'] as Map;
      final before = decode(await serializeBackupJsonForTest(db: target))
        ..remove('exportDatum');
      for (final currency in ['EUR', null]) {
        fullRow['businessCurrencyCode'] = currency;
        singleRow['businessCurrencyCode'] = currency;
        await expectLater(
          importBackupJsonMapForTest(db: target, json: backup),
          throwsA(anything),
        );
        await expectLater(
          importPredmetJsonMapForTest(
            db: target,
            json: transfer,
            localActorKorisnikId: actor.id,
          ),
          throwsA(anything),
        );
        final after = decode(await serializeBackupJsonForTest(db: target))
          ..remove('exportDatum');
        expect(after, before);
      }
      singleRow['businessCurrencyCode'] = 'RSD';
      await importPredmetJsonMapForTest(
        db: target,
        json: transfer,
        localActorKorisnikId: actor.id,
      );
      expect((await target.select(target.predmeti).getSingle()).avans, 41.25);
    },
  );
}
