import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';

void main() {
  test(
    'schema 20 to 21 preserves PREDMET rows and adds empty PARTE state',
    () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final root = await Directory.systemTemp.createTemp('opc_parte_v20_');
      final file = File('${root.path}${Platform.pathSeparator}opc.sqlite');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });

      final current = AppDatabase.forTesting(NativeDatabase(file));
      await current.customStatement('INSERT INTO predmeti DEFAULT VALUES');
      expect(await _predmetCount(current), 1);
      await current.close();

      final migrated = AppDatabase.forTesting(
        NativeDatabase(
          file,
          setup: (rawDb) {
            rawDb.execute('DROP TABLE parte_pripreme');
            rawDb.execute('DROP TABLE parte_predlosci');
            rawDb.execute('PRAGMA user_version = 20');
          },
        ),
      );
      addTearDown(migrated.close);

      expect(await _predmetCount(migrated), 1);
      expect(await migrated.select(migrated.partePripreme).get(), isEmpty);
      expect(await migrated.select(migrated.partePredlosci).get(), isEmpty);
      expect(await _columns(migrated, 'predmeti'), contains('parte_potrebna'));
      expect(
        await _columns(migrated, 'firma_podaci'),
        contains('parte_default_template_id'),
      );
    },
  );
}

Future<int> _predmetCount(AppDatabase db) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS count FROM predmeti')
      .getSingle();
  return row.read<int>('count');
}

Future<Set<String>> _columns(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info($table)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}
