import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/schema_recovery.dart';

import 'support/opc_database_migration_fixture.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory suiteRoot;
  late File currentTemplate;

  setUpAll(() async {
    suiteRoot = await Directory.systemTemp.createTemp(
      'opc_canonical_migration_suite_',
    );
    currentTemplate =
        await OpcDatabaseMigrationFixture.createPopulatedCurrentTemplate(
          suiteRoot,
        );
  });

  tearDownAll(() async {
    if (await suiteRoot.exists()) await suiteRoot.delete(recursive: true);
  });

  group('confirmed v19 to v26 recovery states', () {
    test('empty database is created directly as a valid schema 26', () async {
      final root = await Directory.systemTemp.createTemp('opc_empty_schema_');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final file = File('${root.path}${Platform.pathSeparator}opc.sqlite');
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      expect(await _userVersion(db), 30);
      expect(
        await _tableNames(db),
        containsAll(['predmeti', 'parte_pripreme']),
      );
    });

    test(
      'State A: v19 without docek_datum adds valid v20/v21/v22/v23/v24/v25/v26 schema',
      () async {
        final fixture = await _fixture(currentTemplate, 'state_a');
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(19);
        addTearDown(db.close);

        await _expectMigratedAndPreserved(db);
        expect(await _columnNames(db, 'predmeti'), contains('docek_datum'));
        expect(
          await _columnNames(db, 'predmeti'),
          contains('groblje_polaganja_urne'),
        );
      },
    );

    test('State B: v19 with valid docek_datum does not duplicate it', () async {
      final fixture = await _fixture(currentTemplate, 'state_b');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(
        19,
        mutateBeforeOpen: (raw) {
          raw.execute(
            "ALTER TABLE predmeti ADD COLUMN docek_datum TEXT NOT NULL DEFAULT ''",
          );
        },
      );
      addTearDown(db.close);

      await _expectMigratedAndPreserved(db);
      expect(
        (await _columnNames(
          db,
          'predmeti',
        )).where((name) => name == 'docek_datum'),
        hasLength(1),
      );
    });

    test('State C: physical v21 with stale v19 checkpoint recovers', () async {
      final fixture = await _fixture(currentTemplate, 'state_c');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(19, physicalVersion: 21);
      addTearDown(db.close);

      await _expectMigratedAndPreserved(
        db,
        expectReminder: true,
        expectParte: true,
        expectStock: true,
      );
    });

    test(
      'State C preserves existing empty auth metadata during schema recovery',
      () async {
        final fixture = await _fixture(currentTemplate, 'state_c_auth');
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(
          19,
          physicalVersion: 21,
          mutateBeforeOpen: (raw) {
            raw.execute(
              "UPDATE korisnici SET pin_updated_at = '', pin_hash_version = ''",
            );
          },
        );
        addTearDown(db.close);

        await _expectMigratedAndPreserved(
          db,
          expectReminder: true,
          expectParte: true,
          expectStock: true,
        );
        final authMetadata = await db
            .customSelect(
              'SELECT pin_updated_at, pin_hash_version FROM korisnici',
            )
            .getSingle();
        expect(authMetadata.read<String>('pin_updated_at'), isEmpty);
        expect(authMetadata.read<String>('pin_hash_version'), isEmpty);
      },
    );

    test(
      'State D: v20 adds only missing valid v21/v22/v23/v24/v25/v26 objects',
      () async {
        final fixture = await _fixture(currentTemplate, 'state_d');
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(20);
        addTearDown(db.close);

        await _expectMigratedAndPreserved(
          db,
          expectReminder: true,
          expectStock: true,
        );
        expect(
          await _tableNames(db),
          containsAll(['parte_predlosci', 'parte_pripreme']),
        );
      },
    );

    test('State E: valid v26 opens repeatedly without schema drift', () async {
      final fixture = await _fixture(currentTemplate, 'state_e');
      addTearDown(fixture.dispose);
      final first = fixture.openAtVersion(22);
      await _expectMigratedAndPreserved(
        first,
        expectReminder: true,
        expectParte: true,
        expectStock: true,
      );
      final signature = await _schemaSignature(first);
      await first.close();

      final second = AppDatabase.forTesting(
        NativeDatabase(fixture.databaseFile),
      );
      await _expectMigratedAndPreserved(
        second,
        expectReminder: true,
        expectParte: true,
        expectStock: true,
      );
      expect(await _schemaSignature(second), signature);
      await second.close();
    });
  });

  group('supported historical checkpoints', () {
    for (var version = 1; version <= 24; version++) {
      test('populated schema $version migrates in place and reopens', () async {
        final fixture = await _fixture(currentTemplate, 'history_$version');
        addTearDown(fixture.dispose);
        final first = fixture.openAtVersion(version);
        await _expectMigratedAndPreserved(
          first,
          expectReminder: version >= 18,
          expectParte: version >= 21,
          expectStock: version >= 16,
        );
        final firstSignature = await _schemaSignature(first);
        await first.close();

        final second = AppDatabase.forTesting(
          NativeDatabase(fixture.databaseFile),
        );
        expect(await _userVersion(second), 30);
        expect(await _schemaSignature(second), firstSignature);
        expect(await _count(second, 'predmeti'), 1);
        await second.close();
      });
    }
  });

  test('schema 27 migration keeps historical responsibility unknown', () async {
    final fixture = await _fixture(
      currentTemplate,
      'schema_27_unknown_responsibility',
    );
    addTearDown(fixture.dispose);
    final first = fixture.openAtVersion(
      27,
      mutateBeforeOpen: (raw) {
        raw.execute('''
            UPDATE predmeti
            SET savetnik_id = 1,
                created_by_korisnik_id = 1,
                last_business_modified_by_korisnik_id = 1
            WHERE id = 1
          ''');
      },
    );
    addTearDown(first.close);

    final migrated = await first.select(first.predmeti).getSingle();
    expect(migrated.savetnikId, 1);
    expect(migrated.businessResponsibleName, equals(null));
    expect(migrated.businessResponsibleRole, equals(null));
  });

  group('malformed and unsupported states stop safely', () {
    for (final malformed in <String, String>{
      'wrong type':
          'ALTER TABLE predmeti ADD COLUMN docek_datum INTEGER NOT NULL DEFAULT 0',
      'nullable': "ALTER TABLE predmeti ADD COLUMN docek_datum TEXT DEFAULT ''",
      'wrong default':
          "ALTER TABLE predmeti ADD COLUMN docek_datum TEXT NOT NULL DEFAULT 'WRONG'",
    }.entries) {
      test('docek_datum ${malformed.key} is rejected precisely', () async {
        final fixture = await _fixture(
          currentTemplate,
          'malformed_docek_${malformed.key.replaceAll(' ', '_')}',
        );
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(
          19,
          mutateBeforeOpen: (raw) => raw.execute(malformed.value),
        );
        addTearDown(db.close);

        await expectLater(
          _open(db),
          throwsA(
            isA<OpcSchemaMismatch>().having(
              (error) => error.message,
              'message',
              contains('predmeti.docek_datum'),
            ),
          ),
        );
      });
    }

    test('missing foundational predmeti table is rejected', () async {
      final fixture = await _fixture(currentTemplate, 'missing_predmeti');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(
        19,
        physicalVersion: 21,
        mutateBeforeOpen: (raw) => raw.execute('DROP TABLE predmeti'),
      );
      addTearDown(db.close);

      await expectLater(
        _open(db),
        throwsA(
          isA<OpcSchemaMismatch>().having(
            (error) => error.message,
            'message',
            contains('predmeti'),
          ),
        ),
      );
    });

    test('existing malformed PARTE table is rejected', () async {
      final fixture = await _fixture(currentTemplate, 'malformed_parte');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(
        20,
        mutateBeforeOpen: (raw) {
          raw.execute('CREATE TABLE parte_predlosci (id TEXT PRIMARY KEY)');
        },
      );
      addTearDown(db.close);

      await expectLater(
        _open(db),
        throwsA(
          isA<OpcSchemaMismatch>().having(
            (error) => error.message,
            'message',
            contains('parte_predlosci'),
          ),
        ),
      );
    });

    test('conflicting same-name index is rejected', () async {
      final fixture = await _fixture(currentTemplate, 'malformed_index');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(
        21,
        mutateBeforeOpen: (raw) {
          raw.execute('''
            CREATE INDEX idx_stanje_robe_posledice_predmet
            ON stanje_robe_posledice(status)
          ''');
        },
      );
      addTearDown(db.close);

      await expectLater(
        _open(db),
        throwsA(
          isA<OpcSchemaMismatch>().having(
            (error) => error.message,
            'message',
            contains('idx_stanje_robe_posledice_predmet'),
          ),
        ),
      );
    });

    test('newer user_version is rejected without downgrade', () async {
      final fixture = await _fixture(currentTemplate, 'future_version');
      addTearDown(fixture.dispose);
      // Schema 30 is the current supported version (OPELO responsibility);
      // use the next checkpoint to exercise the future-version guard.
      final db = fixture.openAtVersion(31, physicalVersion: 30);
      addTearDown(db.close);

      await expectLater(
        _open(db),
        throwsA(
          isA<OpcSchemaMismatch>().having(
            (error) => error.message,
            'message',
            contains('unsupported migration checkpoint 31 -> 30'),
          ),
        ),
      );
    });

    test('non-empty user_version zero database is rejected', () async {
      final fixture = await _fixture(currentTemplate, 'unknown_zero');
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(0, physicalVersion: 21);
      addTearDown(db.close);

      await expectLater(
        _open(db),
        throwsA(
          isA<OpcSchemaMismatch>().having(
            (error) => error.message,
            'message',
            contains('user_version 0'),
          ),
        ),
      );
    });
  });

  test('DDL committed before beforeOpen failure is safe on retry', () async {
    final fixture = await _fixture(currentTemplate, 'interrupted_retry');
    addTearDown(fixture.dispose);
    final interrupted = fixture.openAtVersion(
      19,
      mutateBeforeOpen: (raw) {
        raw.execute('''
          CREATE INDEX idx_stanje_robe_posledice_predmet
          ON stanje_robe_posledice(status)
        ''');
      },
    );

    await expectLater(_open(interrupted), throwsA(isA<OpcSchemaMismatch>()));
    await interrupted.close();

    final retried = AppDatabase.forTesting(
      NativeDatabase(
        fixture.databaseFile,
        setup: (raw) {
          raw.execute('DROP INDEX idx_stanje_robe_posledice_predmet');
        },
      ),
    );
    await _expectMigratedAndPreserved(retried);
    expect(await _userVersion(retried), 30);
    await retried.close();
  });

  test(
    'migration does not recreate absent historical business KATALOG rows',
    () async {
      final fixture = await _fixture(
        currentTemplate,
        'missing_business_defaults',
      );
      addTearDown(fixture.dispose);
      final migrated = fixture.openAtVersion(
        21,
        mutateBeforeOpen: (raw) {
          raw.execute('''
            DELETE FROM iriu_katalog_config
            WHERE interni_naziv IN (
              'AGENCIJSKE_USLUGE',
              'DORADA_POGREBNE_OPREME',
              'KUCANJE_OBELEZJA',
              'SLOVA_I_BROJEVI'
            )
          ''');
        },
      );
      addTearDown(migrated.close);

      await _open(migrated);
      expect(await _count(migrated, 'iriu_katalog_config'), 1);
      expect(
        await migrated
            .customSelect('''SELECT COUNT(*) AS count FROM iriu_katalog_config
                 WHERE interni_naziv IN (
                   'AGENCIJSKE_USLUGE',
                   'DORADA_POGREBNE_OPREME',
                   'KUCANJE_OBELEZJA',
                   'SLOVA_I_BROJEVI'
                 )''')
            .getSingle()
            .then((row) => row.read<int>('count')),
        0,
      );
    },
  );
}

Future<OpcDatabaseMigrationFixture> _fixture(File template, String name) =>
    OpcDatabaseMigrationFixture.copyFromTemplate(
      template: template,
      name: name,
    );

Future<void> _open(AppDatabase db) => db.customSelect('SELECT 1').get();

Future<void> _expectMigratedAndPreserved(
  AppDatabase db, {
  bool expectReminder = false,
  bool expectParte = false,
  bool expectStock = false,
}) async {
  expect(await _userVersion(db), 30);
  expect(await _count(db, 'predmeti'), 1);
  expect(await _count(db, 'korisnici'), 1);
  expect(await _count(db, 'kontakt_lica'), 1);
  expect(await _count(db, 'iriu'), 1);
  expect(
    await _columnNames(db, 'predmeti'),
    contains('groblje_polaganja_urne'),
  );
  expect(
    await _tableNames(db),
    containsAll(<String>[
      'scenario_modules',
      'scenario_definitions',
      'predmet_scenario_snapshots',
      'iriu_provenance',
    ]),
  );
  expect(await _count(db, 'scenario_modules'), 0);
  expect(await _count(db, 'scenario_definitions'), 0);
  expect(await _count(db, 'predmet_scenario_snapshots'), 0);
  expect(await _count(db, 'iriu_provenance'), 0);
  expect(
    await _columnNames(db, 'iriu_katalog_config'),
    contains('osnovna_u_svakom_predmetu'),
  );
  expect(
    await _scalarInt(
      db,
      '''SELECT osnovna_u_svakom_predmetu FROM iriu_katalog_config
         WHERE interni_naziv = 'KORISNIK_LEGACY' ''',
    ),
    0,
  );
  expect(
    await _scalarInt(
      db,
      '''SELECT osnovna_u_svakom_predmetu FROM iriu_katalog_config
         WHERE interni_naziv = 'AGENCIJSKE_USLUGE' ''',
    ),
    1,
  );
  expect(
    await _scalarInt(
      db,
      '''SELECT COUNT(*) FROM iriu_katalog_config WHERE interni_naziv IN
         ('DORADA_POGREBNE_OPREME','KUCANJE_OBELEZJA','SLOVA_I_BROJEVI')''',
    ),
    3,
  );
  expect(
    (await db
            .customSelect('SELECT broj_predmeta FROM predmeti WHERE id = 1')
            .getSingle())
        .read<String>('broj_predmeta'),
    'SYNTHETIC-001',
  );
  expect(
    (await db
            .customSelect('SELECT naziv FROM firma_podaci WHERE id = 1')
            .getSingle())
        .read<String>('naziv'),
    'SYNTHETIC MIGRATION FIRMA',
  );
  expect(
    (await db
            .customSelect('SELECT pin_hash FROM korisnici WHERE id = 1')
            .getSingle())
        .read<String>('pin_hash'),
    'synthetic_hash',
  );
  expect(
    (await db.customSelect('SELECT iznos FROM iriu WHERE id = 1').getSingle())
        .read<double>('iznos'),
    125.5,
  );
  if (expectReminder) expect(await _count(db, 'ceremony_reminder_settings'), 1);
  if (expectParte) {
    expect(await _count(db, 'parte_predlosci'), 1);
    expect(await _count(db, 'parte_pripreme'), 1);
  }
  if (expectStock) {
    expect(await _count(db, 'stanje_robe_stavke'), 1);
    expect(await _count(db, 'stanje_robe_applied_effects'), 1);
    expect(await _count(db, 'stanje_robe_posledice'), 1);
  }
}

Future<int> _userVersion(AppDatabase db) async =>
    (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
      'user_version',
    );

Future<int> _count(AppDatabase db, String table) async =>
    (await db
            .customSelect('SELECT COUNT(*) AS count FROM "$table"')
            .getSingle())
        .read<int>('count');

Future<int> _scalarInt(AppDatabase db, String sql) async {
  final row = await db.customSelect(sql).getSingle();
  return row.data.values.single as int;
}

Future<Set<String>> _columnNames(AppDatabase db, String table) async =>
    (await db.customSelect('PRAGMA table_info("$table")').get())
        .map((row) => row.read<String>('name'))
        .toSet();

Future<Set<String>> _tableNames(AppDatabase db) async =>
    (await db
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get())
        .map((row) => row.read<String>('name'))
        .toSet();

Future<String> _schemaSignature(AppDatabase db) async {
  final rows = await db.customSelect('''
    SELECT type, name, tbl_name, COALESCE(sql, '') AS sql
    FROM sqlite_master
    WHERE name NOT LIKE 'sqlite_%'
    ORDER BY type, name
  ''').get();
  return rows
      .map(
        (row) => [
          row.read<String>('type'),
          row.read<String>('name'),
          row.read<String>('tbl_name'),
          row.read<String>('sql').replaceAll(RegExp(r'\s+'), ' ').trim(),
        ].join('|'),
      )
      .join('\n');
}
