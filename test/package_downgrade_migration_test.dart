import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';

void main() {
  group('TASK 038 package-downgrade migration compatibility', () {
    test(
      'schema 16 migration adds STANJE ROBE operational toggle as OFF',
      () async {
        final db = _databaseWithSchema16AppPodesavanja(
          includeOperationalToggleColumn: false,
          operationalToggleValue: null,
        );
        addTearDown(db.close);

        final columns = await _appPodesavanjaColumnNames(db);
        final appPodesavanja = await _getAppPodesavanja(db);

        expect(columns, contains('stanje_robe_operativno_omoguceno'));
        expect(appPodesavanja.stanjeRobeOperativnoOmoguceno, isFalse);
      },
    );

    test(
      'schema 16 migration skips STANJE ROBE operational toggle when present',
      () async {
        final db = _databaseWithSchema16AppPodesavanja(
          includeOperationalToggleColumn: true,
          operationalToggleValue: 1,
        );
        addTearDown(db.close);

        final columns = await _appPodesavanjaColumnNames(db);
        final appPodesavanja = await _getAppPodesavanja(db);

        expect(
          columns.where((name) => name == 'stanje_robe_operativno_omoguceno'),
          hasLength(1),
        );
        expect(appPodesavanja.stanjeRobeOperativnoOmoguceno, isTrue);
      },
    );

    test(
      'open guard adds missing STANJE ROBE operational toggle as OFF',
      () async {
        final db = _databaseWithAppPodesavanjaSchemaVersion(
          schemaVersion: 17,
          includeOperationalToggleColumn: false,
          operationalToggleValue: null,
        );
        addTearDown(db.close);

        final columns = await _appPodesavanjaColumnNames(db);
        final appPodesavanja = await _getAppPodesavanja(db);

        expect(columns, contains('stanje_robe_operativno_omoguceno'));
        expect(appPodesavanja.stanjeRobeOperativnoOmoguceno, isFalse);
      },
    );

    test('package runtime policy does not fork core database truth', () {
      final policies = <OpcEntitlementPolicy>[
        _policy(OpcPackageLevel.osnovni),
        _policy(OpcPackageLevel.srednji),
        _policy(OpcPackageLevel.srednji, addOns: {OpcAddOn.stanjeRobe}),
        _policy(OpcPackageLevel.potpun),
      ];

      for (final policy in policies) {
        expect(policy.isModuleAvailable(OpcModule.predmetCore), isTrue);
        expect(policy.isModuleAvailable(OpcModule.katalog), isTrue);
        expect(policy.isModuleAvailable(OpcModule.jsonSinglePredmetTransfer),
            isTrue);
        expect(policy.isModuleAvailable(OpcModule.businessPolicyScenario),
            isTrue);
      }

      expect(
        policies
            .map((policy) => policy.isModuleAvailable(OpcModule.stanjeRobe))
            .toList(growable: false),
        <bool>[false, false, true, true],
      );
    });

    test('RACUN remains a standard operational PDF action', () {
      final policy = _policy(OpcPackageLevel.osnovni);

      expect(policy.isModuleAvailable(OpcModule.operationalDocuments), isTrue);
      expect(
        policy.isDocumentActionVisible(OpcDocumentAction.racunPdf),
        isTrue,
      );
    });
  });
}

AppDatabase _databaseWithSchema16AppPodesavanja({
  required bool includeOperationalToggleColumn,
  required int? operationalToggleValue,
}) {
  return _databaseWithAppPodesavanjaSchemaVersion(
    schemaVersion: 16,
    includeOperationalToggleColumn: includeOperationalToggleColumn,
    operationalToggleValue: operationalToggleValue,
  );
}

AppDatabase _databaseWithAppPodesavanjaSchemaVersion({
  required int schemaVersion,
  required bool includeOperationalToggleColumn,
  required int? operationalToggleValue,
}) {
  return AppDatabase.forTesting(
    NativeDatabase.memory(
      setup: (rawDb) {
        _createMinimalSchema16(rawDb, includeOperationalToggleColumn);
        final columns = <String>[
          'id',
          'ziro_racun',
          'naziv_banke',
          'qr_primalac_naziv',
          'qr_sifra_placanja',
          'qr_svrha_placanja',
          'poziv_na_broj_tip',
          'refundacija_pio_iznos',
          if (includeOperationalToggleColumn)
            'stanje_robe_operativno_omoguceno',
        ];
        final values = <Object?>[
          1,
          '',
          '',
          '',
          '289',
          '',
          'BROJ_PREDMETA',
          0.0,
          if (includeOperationalToggleColumn) operationalToggleValue,
        ];
        final placeholders = List.filled(values.length, '?').join(', ');
        rawDb.execute(
          'INSERT INTO app_podesavanja (${columns.join(', ')}) '
          'VALUES ($placeholders)',
          values,
        );
        rawDb.execute('PRAGMA user_version = $schemaVersion');
      },
    ),
  );
}

void _createMinimalSchema16(
  dynamic rawDb,
  bool includeOperationalToggleColumn,
) {
  rawDb.execute('''
    CREATE TABLE app_podesavanja (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ziro_racun TEXT NOT NULL DEFAULT '',
      naziv_banke TEXT NOT NULL DEFAULT '',
      qr_primalac_naziv TEXT NOT NULL DEFAULT '',
      qr_sifra_placanja TEXT NOT NULL DEFAULT '289',
      qr_svrha_placanja TEXT NOT NULL DEFAULT '',
      poziv_na_broj_tip TEXT NOT NULL DEFAULT 'BROJ_PREDMETA',
      refundacija_pio_iznos REAL NOT NULL DEFAULT 0.0
      ${includeOperationalToggleColumn ? ", stanje_robe_operativno_omoguceno INTEGER NOT NULL DEFAULT 1 CHECK (stanje_robe_operativno_omoguceno IN (0, 1))" : ""}
    )
  ''');
  rawDb.execute('''
    CREATE TABLE katalog_artikli (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stable_article_id TEXT,
      interni_naziv_kategorije TEXT NOT NULL DEFAULT '',
      naziv TEXT NOT NULL DEFAULT '',
      cena REAL NOT NULL DEFAULT 0.0
    )
  ''');
  rawDb.execute('''
    CREATE TABLE stanje_robe_stavke (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stable_article_id TEXT NOT NULL,
      trenutna_kolicina REAL NOT NULL DEFAULT 0.0,
      minimalna_kolicina REAL NOT NULL DEFAULT 0.0,
      aktivna INTEGER NOT NULL DEFAULT 1,
      datum_kreiranja TEXT NOT NULL DEFAULT '',
      datum_azuriranja TEXT NOT NULL DEFAULT ''
    )
  ''');
  rawDb.execute('''
    CREATE TABLE stanje_robe_applied_effects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      predmet_id INTEGER NOT NULL,
      iriu_id INTEGER,
      kategorija TEXT NOT NULL,
      stable_article_id TEXT NOT NULL,
      effect_quantity REAL NOT NULL,
      effect_status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
  rawDb.execute('''
    CREATE TABLE stanje_robe_posledice (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      predmet_id INTEGER NOT NULL,
      iriu_id INTEGER NOT NULL,
      kategorija TEXT NOT NULL,
      stable_article_id TEXT NOT NULL,
      selected_naziv_snapshot TEXT NOT NULL,
      selected_iznos_snapshot REAL NOT NULL,
      consequence_type TEXT NOT NULL,
      status TEXT NOT NULL,
      effect_quantity REAL NOT NULL,
      source_lifecycle_event TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}

Future<Set<String>> _appPodesavanjaColumnNames(AppDatabase db) async {
  final rows = await db.customSelect('PRAGMA table_info(app_podesavanja)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<AppPodesavanjaData> _getAppPodesavanja(AppDatabase db) {
  return (db.select(db.appPodesavanja)..where((p) => p.id.equals(1)))
      .getSingle();
}

OpcEntitlementPolicy _policy(
  OpcPackageLevel packageLevel, {
  Set<OpcAddOn> addOns = const <OpcAddOn>{},
}) {
  return OpcEntitlementPolicy.fromPayload(
    OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: OpcEntitlementEnvironment.test,
      packageLevel: packageLevel,
      enabledAddOns: addOns,
    ),
  );
}
