import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('unchanged owner maps are a startup no-op', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );

    await repository.ensureModuleAndDefaults();
    await db.customStatement(
      "UPDATE scenario_definitions SET updated_at = 'fixed-before-noop'",
    );
    final before = {
      for (final row in await repository.getDefinitions()) row.id: row,
    };

    await repository.ensureModuleAndDefaults();
    final after = {
      for (final row in await repository.getDefinitions()) row.id: row,
    };
    final changedIds = before.keys
        .where((id) => before[id]!.updatedAt != after[id]!.updatedAt)
        .toList(growable: false);

    expect(changedIds, isEmpty);
    for (final id in before.keys) {
      final oldRow = before[id]!;
      final newRow = after[id]!;
      expect(newRow.id, oldRow.id);
      expect(newRow.moduleId, oldRow.moduleId);
      expect(newRow.version, oldRow.version);
      expect(newRow.status, oldRow.status);
      expect(newRow.naziv, oldRow.naziv);
      expect(newRow.conditionJson, oldRow.conditionJson);
      expect(newRow.consequencesJson, oldRow.consequencesJson);
      expect(newRow.jePodrazumevani, oldRow.jePodrazumevani);
      expect(newRow.createdAt, oldRow.createdAt);
    }
  });

  test(
    'genuine legacy protective-equipment gap repairs once then stabilizes',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );

      await repository.ensureModuleAndDefaults();
      const legacyId = 'MAP_NASILNA_STAN_SAHRANA_GRADSKO_GROB_NE_NE_NE';
      final before = (await repository.getDefinitions()).singleWhere(
        (row) => row.id == legacyId,
      );
      final legacyConsequences = (jsonDecode(before.consequencesJson) as List)
          .where(
            (item) =>
                item['katalogCategoryInternalName'] !=
                IriuK.zastitnaIDodatnaOprema,
          )
          .toList(growable: false);
      await (db.update(
        db.scenarioDefinitions,
      )..where((row) => row.id.equals(legacyId))).write(
        ScenarioDefinitionsCompanion(
          consequencesJson: Value(jsonEncode(legacyConsequences)),
          updatedAt: const Value('legacy-before-repair'),
        ),
      );

      await repository.ensureModuleAndDefaults();
      final repaired = (await repository.getDefinitions()).singleWhere(
        (row) => row.id == legacyId,
      );
      expect(repaired.updatedAt, isNot('legacy-before-repair'));
      expect(
        jsonDecode(repaired.consequencesJson),
        contains(
          predicate<Map<String, dynamic>>(
            (item) =>
                item['katalogCategoryInternalName'] ==
                IriuK.zastitnaIDodatnaOprema,
          ),
        ),
      );

      await repository.ensureModuleAndDefaults();
      final stable = (await repository.getDefinitions()).singleWhere(
        (row) => row.id == legacyId,
      );
      expect(stable.updatedAt, repaired.updatedAt);
      expect(stable.consequencesJson, repaired.consequencesJson);
    },
  );

  test(
    'user-edited owner-map definitions are protected from startup repair',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      await repository.ensureModuleAndDefaults();
      const editedId = 'MAP_NASILNA_STAN_SAHRANA_GRADSKO_GROB_NE_NE_NE';
      const editedPayload =
          '[{"katalogCategoryInternalName":"RUCNO_EDITOVANO","action":"required","order":10}]';
      await (db.update(
        db.scenarioDefinitions,
      )..where((row) => row.id.equals(editedId))).write(
        const ScenarioDefinitionsCompanion(
          consequencesJson: Value(editedPayload),
          jePodrazumevani: Value(false),
          updatedAt: Value('user-edit-before-startup'),
        ),
      );

      await repository.ensureModuleAndDefaults();
      final after = (await repository.getDefinitions()).singleWhere(
        (row) => row.id == editedId,
      );
      expect(after.jePodrazumevani, isFalse);
      expect(after.consequencesJson, editedPayload);
      expect(after.updatedAt, 'user-edit-before-startup');
    },
  );

  test(
    'canonical-shaped copy remains stable during startup initialization',
    skip: Platform.environment['OPC_STARTUP_MUTATION_FORENSIC_COPY'] == null
        ? 'Set OPC_STARTUP_MUTATION_FORENSIC_COPY to an isolated DB copy.'
        : null,
    () async {
      final file = File(
        Platform.environment['OPC_STARTUP_MUTATION_FORENSIC_COPY']!,
      );
      expect(file.existsSync(), isTrue);
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      final repository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      final before = {
        for (final row in await repository.getDefinitions()) row.id: row,
      };

      await repository.ensureModuleAndDefaults();
      final after = {
        for (final row in await repository.getDefinitions()) row.id: row,
      };
      final changedIds = before.keys
          .where((id) => before[id]!.updatedAt != after[id]!.updatedAt)
          .toList(growable: false);

      expect(changedIds, isEmpty);
      for (final id in before.keys) {
        final oldRow = before[id]!;
        final newRow = after[id]!;
        expect(newRow.id, oldRow.id);
        expect(newRow.moduleId, oldRow.moduleId);
        expect(newRow.version, oldRow.version);
        expect(newRow.status, oldRow.status);
        expect(newRow.naziv, oldRow.naziv);
        expect(newRow.conditionJson, oldRow.conditionJson);
        expect(newRow.consequencesJson, oldRow.consequencesJson);
        expect(newRow.jePodrazumevani, oldRow.jePodrazumevani);
        expect(newRow.createdAt, oldRow.createdAt);
      }
    },
  );
}
