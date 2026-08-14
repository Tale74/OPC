import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'characterization: unchanged owner map rewrites 36 BOLNICA timestamps',
    () async {
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

      expect(changedIds, hasLength(36));
      expect(changedIds, everyElement(startsWith('MAP_NASILNA_BOLNICA_')));
      for (final id in changedIds) {
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

  test(
    'canonical-shaped copy reproduces the same 36 timestamp-only writes',
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

      expect(changedIds, hasLength(36));
      expect(changedIds, everyElement(startsWith('MAP_NASILNA_BOLNICA_')));
      for (final id in changedIds) {
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
