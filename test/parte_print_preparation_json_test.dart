import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_template_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';
import 'package:opc_v4/features/predmeti/domain/iriu_catalog_selection.dart';

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
    'schema-9 full backup includes preparation metadata and excludes media bytes',
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
      expect(root['parteMediaPolicy'], 'bounded-exclusion-v1');
      expect(root['partePripreme'], isA<List<Object?>>());
      final exportedPreparation =
          (root['partePripreme'] as List).single as Map<String, dynamic>;
      expect(exportedPreparation['photoMediaKey'], equals(null));
      expect(encoded, isNot(contains('synthetic-photo.png')));
      expect(encoded, contains('templateSnapshotJson'));
      expect(encoded, contains('draftJson'));
    },
  );

  test(
    'fresh schema-9 restore clears unavailable app-owned media keys',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final actor = await _insertAdmin(source);
      final predmet = await _insertPredmet(source);
      final preparation = await PartePreparationRepository(source)
          .initializeOrResume(
            predmetId: predmet.id,
            actor: actor,
            entitlement: potpun,
          );
      await (source.update(
        source.partePripreme,
      )..where((row) => row.id.equals(preparation.id))).write(
        const PartePripremeCompanion(
          photoMediaKey: Value('owned/photo.png'),
          customSymbolMediaKey: Value('owned/symbol.png'),
        ),
      );
      final backup =
          jsonDecode(await serializeBackupJsonForTest(db: source))
              as Map<String, dynamic>;
      await importBackupJsonMapForTest(db: target, json: backup);
      final restored = await target.select(target.partePripreme).getSingle();
    expect(restored.photoMediaKey, equals(null));
    expect(restored.customSymbolMediaKey, equals(null));
    },
  );

  test('FULL restore identity mismatch is rejected before mutation', () async {
    final source = createTestDatabase();
    final target = createTestDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    await (source.update(
      source.firmaPodaci,
    )..where((row) => row.id.equals(1))).write(
      const FirmaPodaciCompanion(
        pib: Value('111111111'),
        mb: Value('10000001'),
      ),
    );
    await (target.update(
      target.firmaPodaci,
    )..where((row) => row.id.equals(1))).write(
      const FirmaPodaciCompanion(
        pib: Value('222222222'),
        mb: Value('20000002'),
      ),
    );
    final backup =
        jsonDecode(await serializeBackupJsonForTest(db: source))
            as Map<String, dynamic>;
    await expectLater(
      importBackupJsonMapForTest(db: target, json: backup),
      throwsA(isA<Exception>()),
    );
    final local = await target.select(target.firmaPodaci).getSingle();
    expect(local.pib, '222222222');
    expect(local.mb, '20000002');
  });

  test('nullable catalog stable identity can be explicitly cleared', () {
    const selection = IriuCatalogSelection(
      interniNaziv: 'CRNINA',
      nazivPrikaz: 'Flor',
      katalogStableArticleId: 'stable-1',
      cena: 10,
    );
    expect(
      selection.copyWith(katalogStableArticleId: null).katalogStableArticleId,
        equals(null),
    );
    expect(selection.copyWith().katalogStableArticleId, 'stable-1');
  });

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
