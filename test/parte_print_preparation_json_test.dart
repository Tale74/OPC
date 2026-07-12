import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_template_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';

import 'test_bootstrap.dart';

void main() {
  const potpun = OpcEntitlementPolicy.fromSource(
    OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
  );

  test(
    'single-PREDMET JSON keeps business decision and excludes preparation',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actor = await _insertAdmin(db);
      final predmet = await _insertPredmet(db);
      await PartePreparationRepository(db).initializeOrResume(
        predmetId: predmet.id,
        actor: actor,
        entitlement: potpun,
      );

      final root =
          jsonDecode(
                await serializePredmetJsonForTest(
                  db: db,
                  predmetId: predmet.id,
                ),
              )
              as Map<String, dynamic>;

      expect((root['predmet'] as Map)['partePotrebna'], isTrue);
      expect(root, isNot(contains('partePripreme')));
      expect(root, isNot(contains('partePredlosci')));
      expect(jsonEncode(root), isNot(contains('photoMediaKey')));
      expect(jsonEncode(root), isNot(contains('templateSnapshotJson')));
    },
  );

  test(
    'full backup includes user templates but excludes draft and media',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final actor = await _insertAdmin(db);
      final predmet = await _insertPredmet(db);
      final templates = ParteTemplateRepository(db);
      final created = await templates.createUserTemplate(
        actor: actor,
        name: 'Prenosivi tehnički šablon',
        technicalSource: ParteTemplate.builtInStandard,
      );
      await templates.setDefault(templateId: created.id, actor: actor);
      final preparation = await PartePreparationRepository(db)
          .initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: potpun,
          );
      await (db.update(
        db.partePripreme,
      )..where((row) => row.id.equals(preparation.id))).write(
        const PartePripremeCompanion(
          photoMediaKey: Value('owned/synthetic-photo.png'),
        ),
      );

      final root =
          jsonDecode(await serializeBackupJsonForTest(db: db))
              as Map<String, dynamic>;
      final encoded = jsonEncode(root);

      expect(root['partePredlosci'], isA<List<Object?>>());
      expect((root['partePredlosci'] as List), hasLength(1));
      expect(root, isNot(contains('partePripreme')));
      expect(encoded, isNot(contains('synthetic-photo.png')));
      expect(encoded, isNot(contains('textByBlock')));
    },
  );

  test('legacy backup without PARTE keys imports with safe defaults', () async {
    final source = createTestDatabase();
    final target = createTestDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    await _insertAdmin(source);
    await _insertPredmet(source);
    final root =
        jsonDecode(await serializeBackupJsonForTest(db: source))
            as Map<String, dynamic>;
    root.remove('partePredlosci');
    (root['firmaPodaci'] as Map).remove('parteDefaultTemplateId');
    for (final row in root['predmeti'] as List) {
      (row as Map).remove('partePotrebna');
    }

    await importBackupJsonMapForTest(db: target, json: root);

    final importedPredmet = await target.select(target.predmeti).getSingle();
    final firma = await target.select(target.firmaPodaci).getSingle();
    expect(importedPredmet.partePotrebna, isFalse);
    expect(firma.parteDefaultTemplateId, parteBuiltinTemplateId);
    expect(await target.select(target.partePredlosci).get(), isEmpty);
  });

  test(
    'invalid optional template is skipped and built-in fallback is restored',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      await _insertAdmin(source);
      await _insertPredmet(source);
      final root =
          jsonDecode(await serializeBackupJsonForTest(db: source))
              as Map<String, dynamic>;
      (root['firmaPodaci'] as Map)['parteDefaultTemplateId'] =
          'invalid-template';
      root['partePredlosci'] = [
        {
          'id': 'invalid-template',
          'firmaId': 1,
          'naziv': 'Nevalidan',
          'schemaVersion': 1,
          'configJson': '{"externalPath":"../private"}',
          'createdAt': '2026-07-11T10:00:00.000',
          'updatedAt': '2026-07-11T10:00:00.000',
        },
      ];

      await importBackupJsonMapForTest(db: target, json: root);

      expect(await target.select(target.partePredlosci).get(), isEmpty);
      final firma = await target.select(target.firmaPodaci).getSingle();
      expect(firma.parteDefaultTemplateId, parteBuiltinTemplateId);
    },
  );
}

Future<KorisniciData> _insertAdmin(AppDatabase db) async {
  final id = await db
      .into(db.korisnici)
      .insert(
        KorisniciCompanion.insert(
          imePrezime: 'Sintetički administrator',
          uloga: 'ADMINISTRATOR',
          pinHash: 'synthetic-hash',
          datumKreiranja: '2026-07-11T10:00:00.000',
        ),
      );
  return (db.select(
    db.korisnici,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<PredmetiData> _insertPredmet(AppDatabase db) async {
  final id = await db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('PARTE-JSON-001'),
          datumKreiranja: const Value('2026-07-11T10:00:00.000'),
          ime: const Value('Sintetičko'),
          prezime: const Value('Lice'),
          partePotrebna: const Value(true),
          pol: const Value('Z'),
          simbol: const Value('BEZ_SIMBOLA'),
        ),
      );
  return (db.select(
    db.predmeti,
  )..where((row) => row.id.equals(id))).getSingle();
}
