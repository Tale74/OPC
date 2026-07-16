import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';

import 'support/opc_database_migration_fixture.dart';

void main() {
  group('TASK 038 package-downgrade migration compatibility', () {
    late Directory migrationRoot;
    late File currentTemplate;

    setUpAll(() async {
      migrationRoot = await Directory.systemTemp.createTemp(
        'opc_package_migration_',
      );
      currentTemplate =
          await OpcDatabaseMigrationFixture.createPopulatedCurrentTemplate(
            migrationRoot,
          );
    });

    tearDownAll(() async {
      if (await migrationRoot.exists()) {
        await migrationRoot.delete(recursive: true);
      }
    });

    test(
      'schema 16 migration adds STANJE ROBE operational toggle as OFF',
      () async {
        final fixture = await OpcDatabaseMigrationFixture.copyFromTemplate(
          template: currentTemplate,
          name: 'package_v16_missing_toggle',
        );
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(16);
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
        final fixture = await OpcDatabaseMigrationFixture.copyFromTemplate(
          template: currentTemplate,
          name: 'package_v16_existing_toggle',
        );
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(
          16,
          physicalVersion: 17,
          mutateBeforeOpen: (raw) => raw.execute('''
            UPDATE app_podesavanja
            SET stanje_robe_operativno_omoguceno = 1
            WHERE id = 1
          '''),
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
        final fixture = await OpcDatabaseMigrationFixture.copyFromTemplate(
          template: currentTemplate,
          name: 'package_v17_missing_toggle',
        );
        addTearDown(fixture.dispose);
        final db = fixture.openAtVersion(
          17,
          mutateBeforeOpen: (raw) => raw.execute('''
            ALTER TABLE app_podesavanja
            DROP COLUMN stanje_robe_operativno_omoguceno
          '''),
        );
        addTearDown(db.close);

        final columns = await _appPodesavanjaColumnNames(db);
        final appPodesavanja = await _getAppPodesavanja(db);

        expect(columns, contains('stanje_robe_operativno_omoguceno'));
        expect(appPodesavanja.stanjeRobeOperativnoOmoguceno, isFalse);
      },
    );

    test('schema 19 migration adds empty DATUM DOCEKA column', () async {
      final fixture = await OpcDatabaseMigrationFixture.copyFromTemplate(
        template: currentTemplate,
        name: 'package_v19_docek',
      );
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(19);
      addTearDown(db.close);

      final columns = await _predmetiColumnNames(db);
      expect(columns, contains('docek_datum'));
    });

    test('retained package data does not restrict native functionality', () {
      final policies = <OpcEntitlementPolicy>[
        _policy(OpcPackageLevel.osnovni),
        _policy(OpcPackageLevel.srednji),
        _policy(OpcPackageLevel.srednji, addOns: {OpcAddOn.stanjeRobe}),
        _policy(OpcPackageLevel.potpun),
      ];

      for (final policy in policies) {
        expect(policy.isModuleAvailable(OpcModule.predmetCore), isTrue);
        expect(policy.isModuleAvailable(OpcModule.katalog), isTrue);
        expect(
          policy.isModuleAvailable(OpcModule.jsonSinglePredmetTransfer),
          isTrue,
        );
        expect(
          policy.isModuleAvailable(OpcModule.businessPolicyScenario),
          isTrue,
        );
      }

      expect(
        policies
            .map((policy) => policy.isModuleAvailable(OpcModule.stanjeRobe))
            .toList(growable: false),
        <bool>[true, true, true, true],
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

Future<Set<String>> _appPodesavanjaColumnNames(AppDatabase db) async {
  final rows = await db
      .customSelect('PRAGMA table_info(app_podesavanja)')
      .get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<Set<String>> _predmetiColumnNames(AppDatabase db) async {
  final rows = await db.customSelect('PRAGMA table_info(predmeti)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<AppPodesavanjaData> _getAppPodesavanja(AppDatabase db) {
  return (db.select(
    db.appPodesavanja,
  )..where((p) => p.id.equals(1))).getSingle();
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
