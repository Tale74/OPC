import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../catalog/stock_catalog_identity.dart';
import '../config/app_config.dart';
import '../constants/iriu_constants.dart';
import '../utils/stable_id_generator.dart';
import 'migration_test_database_selector.dart';
import 'schema_recovery.dart';

import 'tables/app_podesavanja_table.dart';
import 'tables/firma_podaci_table.dart';
import 'tables/iriu_katalog_config_table.dart';
import 'tables/iriu_provenance_table.dart';
import 'tables/iriu_table.dart';
import 'tables/katalog_artikli_table.dart';
import 'tables/kontakt_lica_table.dart';
import 'tables/korisnici_table.dart';
import 'tables/log_izmena_table.dart';
import 'tables/parte_predlosci_table.dart';
import 'tables/parte_pripreme_table.dart';
import 'tables/predlosci_dokumenata_table.dart';
import 'tables/predmeti_table.dart';
import 'tables/predmet_scenario_snapshots_table.dart';
import 'tables/scenario_definitions_table.dart';
import 'tables/scenario_modules_table.dart';
import 'tables/stanje_robe_applied_effects_table.dart';
import 'tables/stanje_robe_posledice_table.dart';
import 'tables/stanje_robe_stavke_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Korisnici,
    FirmaPodaci,
    AppPodesavanja,
    Predmeti,
    KontaktLica,
    Iriu,
    IriuProvenance,
    IriuKatalogConfig,
    KatalogArtikli,
    StanjeRobeStavke,
    StanjeRobeAppliedEffects,
    StanjeRobePosledice,
    PredlosciDokumenata,
    PartePredlosci,
    PartePripreme,
    LogIzmena,
    ScenarioModules,
    ScenarioDefinitions,
    PredmetScenarioSnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  static const String legacyPinHashVersion = 'LEGACY_SHA256';
  static final Map<String, Uint8List?> _catalogAssetCache =
      <String, Uint8List?>{};

  late final OpcSchemaRecovery _schemaRecovery = OpcSchemaRecovery(this);

  AppDatabase() : super(_openConnection());

  /// Korisnički konstruktor za testove — prihvata bilo koji QueryExecutor
  /// (npr. NativeDatabase.memory() iz package:drift/native.dart).
  // ignore: invalid_use_of_visible_for_testing_member
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 27;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await _rejectNonEmptyVersionZeroDatabase();
      await m.createAll();
      await _prepareAuthSecuritySchema();
      await _createIriuLifecycleDecisionTable();
      await _createCeremonyReminderSettingsTable();
      await _seedIriuKatalog();
      await repairKnownCatalogIntegrity();
      await _backfillBuiltInIriuBasicPolicy();
      await _seedPredlosciDokumenata();
      await _seedSingletons();
    },
    onUpgrade: (m, from, to) async {
      _requireSupportedUpgrade(from, to);
      if (from < 2) {
        await _ensureColumn(m, predmeti, predmeti.radniStatus);
        await _ensureColumn(m, predmeti, predmeti.naruIme);
        await _ensureColumn(m, predmeti, predmeti.naruPrezime);
        await _ensureColumn(m, predmeti, predmeti.jkpIme);
        await _ensureColumn(m, predmeti, predmeti.jkpPrezime);
        await _ensureColumn(
          m,
          appPodesavanja,
          appPodesavanja.refundacijaPioIznos,
        );
      }
      if (from < 3) {
        // fotografijaPath kolona (privremena — zamenjena BLOB-om u v4)
        await _ensureColumn(m, katalogArtikli, katalogArtikli.fotografijaPath);
      }
      if (from < 4) {
        // Popuni fotografija BLOB za sve sistemske artikle
        await _popuniFotoBlobove();
      }
      if (from < 5) {
        await _ensureColumn(
          m,
          predlosciDokumenata,
          predlosciDokumenata.zakljucan,
        );
        // BELEŽNICA je jedini zaključan predložak
        await (update(predlosciDokumenata)
              ..where((t) => t.naziv.equals('BELEŽNICA')))
            .write(const PredlosciDokumenataCompanion(zakljucan: Value(true)));
      }
      if (from < 6) {
        await _ensureColumn(m, predmeti, predmeti.exportVerzija);
      }
      if (from < 7) {
        await _ensureColumn(m, predmeti, predmeti.uzrokSmrti);
      }
      if (from < 8) {
        await _createIriuLifecycleDecisionTable();
      }
      if (from < 9) {
        await _ensureColumn(m, appPodesavanja, appPodesavanja.qrPrimalacNaziv);
        await _ensureColumn(m, appPodesavanja, appPodesavanja.qrSifraPlacanja);
        await _ensureColumn(m, appPodesavanja, appPodesavanja.qrSvrhaPlacanja);
      }
      if (from < 10) {
        await _prepareAuthSecuritySchema();
      }
      if (from < 11) {
        await _ensureColumn(m, predmeti, predmeti.businessScenarioId);
        await _ensureColumn(m, predmeti, predmeti.sourceIdentity);
        await _ensureColumn(m, predmeti, predmeti.createdByKorisnikId);
        await _ensureColumn(
          m,
          predmeti,
          predmeti.lastBusinessModifiedByKorisnikId,
        );
        await _ensureColumn(m, predmeti, predmeti.lastBusinessModifiedAt);
      }
      if (from < 12) {
        await _ensureColumn(m, katalogArtikli, katalogArtikli.stableArticleId);
      }
      if (from < 13) {
        await _ensureColumn(m, iriu, iriu.katalogStableArticleId);
      }
      if (from < 14) {
        await _ensureTable(m, stanjeRobeStavke);
      }
      if (from < 15) {
        await _ensureTable(m, stanjeRobeAppliedEffects);
      }
      if (from < 16) {
        await _ensureTable(m, stanjeRobePosledice);
      }
      if (from < 17) {
        await _ensureAppPodesavanjaStanjeRobeOperativnoColumn();
      }
      if (from < 18) {
        await _createCeremonyReminderSettingsTable();
      }
      if (from < 19) {
        await _ensureCeremonyReminderDeliveryTimesColumn();
      }
      if (from < 20) {
        await _ensureColumn(m, predmeti, predmeti.docekDatum);
      }
      if (from < 21) {
        await _ensureColumn(m, predmeti, predmeti.partePotrebna);
        await _ensureColumn(m, firmaPodaci, firmaPodaci.parteDefaultTemplateId);
        await _ensureTable(m, partePredlosci);
        await _ensureTable(m, partePripreme);
      }
      if (from < 22) {
        await _ensureColumn(
          m,
          iriuKatalogConfig,
          iriuKatalogConfig.osnovnaUSvakomPredmetu,
        );
        await _seedIriuKatalog();
        await _backfillBuiltInIriuBasicPolicy();
      }
      if (from < 23) {
        await _ensureTable(m, scenarioModules);
        await _ensureTable(m, scenarioDefinitions);
        await _ensureTable(m, predmetScenarioSnapshots);
        await _ensureTable(m, iriuProvenance);
      }
      if (from < 24) {
        await _ensureColumn(m, iriu, iriu.poslovniStatus);
        await _ensureColumn(m, iriu, iriu.obezbedjuje);
        await _ensureColumn(m, iriu, iriu.poslovnoUpozorenje);
        await _ensureColumn(m, iriu, iriu.poslovniRazlog);
        await _ensureColumn(m, iriu, iriu.poslovnaCelina);
        await _ensureColumn(m, iriu, iriu.poslovniRedosled);
        await _ensureColumn(m, iriu, iriu.finansijskiUkljuceno);
        await _ensureColumn(m, iriu, iriu.scenarioUpravlja);
        await _ensureColumn(m, iriu, iriu.cekaOdlukuKorisnika);
      }
      if (from < 25) {
        await _ensureColumn(m, predmeti, predmeti.grobljePolaganjaUrne);
      }
      if (from < 26) {
        await _ensureColumn(m, predmeti, predmeti.promenaSanduka);
      }
      if (from < 27) {
        await _ensureColumn(m, iriuKatalogConfig, iriuKatalogConfig.cena);
        await _ensureColumn(m, iriu, iriu.cena);
      }
    },
    beforeOpen: (details) async {
      final versionBefore = details.versionBefore;
      if (versionBefore != null && versionBefore > schemaVersion) {
        throw OpcSchemaMismatch(
          'database user_version $versionBefore is newer than supported '
          'version $schemaVersion',
        );
      }
      final migrator = createMigrator();
      await _recoverSupportedAdditiveSchema(migrator);
      final existingCatalogArticles = await select(katalogArtikli).get();
      await _seedIriuKatalog(loadPhotos: existingCatalogArticles.isEmpty);
      await repairKnownCatalogIntegrity();
      await _backfillBuiltInIriuBasicPolicy();
      await _ensureAppPodesavanjaStanjeRobeOperativnoColumn();
      await _ensureKatalogStableArticleIdUniqueIndex();
      await _ensureStanjeRobeStableArticleIdUniqueIndex();
      await _ensureStanjeRobeAppliedEffectsIndexes();
      await _ensureStanjeRobePoslediceIndexes();
      await _createCeremonyReminderSettingsTable();
      await _ensureCeremonyReminderDeliveryTimesColumn();
      await backfillMissingKatalogStableArticleIds();
      await canonicalizeSeedCatalogStableArticleIds();
      await _validateRequiredSchema();
    },
  );

  void _requireSupportedUpgrade(int from, int to) {
    if (from < 1 || from > schemaVersion || to != schemaVersion) {
      throw OpcSchemaMismatch(
        'unsupported migration checkpoint $from -> $to; supported existing '
        'database versions are 1 through $schemaVersion',
      );
    }
  }

  Future<void> _rejectNonEmptyVersionZeroDatabase() async {
    final existing = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name LIMIT 1",
    ).getSingleOrNull();
    if (existing != null) {
      throw OpcSchemaMismatch(
        'database has user_version 0 but already contains table '
        '"${existing.read<String>('name')}"; automatic creation is unsafe',
      );
    }
  }

  Future<void> _ensureColumn(
    Migrator migrator,
    TableInfo<Table, Object?> table,
    GeneratedColumn column,
  ) => _schemaRecovery.ensureGeneratedColumn(
    migrator: migrator,
    table: table,
    column: column,
  );

  Future<void> _ensureTable(
    Migrator migrator,
    TableInfo<Table, Object?> table,
  ) => _schemaRecovery.ensureGeneratedTable(migrator: migrator, table: table);

  /// Repairs only additive objects that belong to supported OPC migrations.
  /// It is intentionally repeatable because SQLite DDL may have committed even
  /// when Drift has not yet advanced `user_version`.
  Future<void> _recoverSupportedAdditiveSchema(Migrator migrator) async {
    const foundationalTables = <String>[
      'korisnici',
      'firma_podaci',
      'app_podesavanja',
      'predmeti',
      'kontakt_lica',
      'iriu',
      'iriu_katalog_config',
      'katalog_artikli',
      'predlosci_dokumenata',
      'log_izmena',
    ];
    for (final table in foundationalTables) {
      if (!await _schemaRecovery.tableExists(table)) {
        throw OpcSchemaMismatch(
          'required foundational table "$table" is missing',
        );
      }
    }

    await _ensureColumn(migrator, predmeti, predmeti.radniStatus);
    await _ensureColumn(migrator, predmeti, predmeti.naruIme);
    await _ensureColumn(migrator, predmeti, predmeti.naruPrezime);
    await _ensureColumn(migrator, predmeti, predmeti.jkpIme);
    await _ensureColumn(migrator, predmeti, predmeti.jkpPrezime);
    await _ensureColumn(
      migrator,
      appPodesavanja,
      appPodesavanja.refundacijaPioIznos,
    );
    await _ensureColumn(
      migrator,
      katalogArtikli,
      katalogArtikli.fotografijaPath,
    );
    await _ensureColumn(
      migrator,
      predlosciDokumenata,
      predlosciDokumenata.zakljucan,
    );
    await _ensureColumn(migrator, predmeti, predmeti.exportVerzija);
    await _ensureColumn(migrator, predmeti, predmeti.uzrokSmrti);
    await _ensureColumn(
      migrator,
      appPodesavanja,
      appPodesavanja.qrPrimalacNaziv,
    );
    await _ensureColumn(
      migrator,
      appPodesavanja,
      appPodesavanja.qrSifraPlacanja,
    );
    await _ensureColumn(
      migrator,
      appPodesavanja,
      appPodesavanja.qrSvrhaPlacanja,
    );
    await _prepareAuthSecuritySchema(backfillExistingMetadata: false);
    await _createIriuLifecycleDecisionTable();
    await _ensureColumn(migrator, predmeti, predmeti.businessScenarioId);
    await _ensureColumn(migrator, predmeti, predmeti.sourceIdentity);
    await _ensureColumn(migrator, predmeti, predmeti.createdByKorisnikId);
    await _ensureColumn(
      migrator,
      predmeti,
      predmeti.lastBusinessModifiedByKorisnikId,
    );
    await _ensureColumn(migrator, predmeti, predmeti.lastBusinessModifiedAt);
    await _ensureColumn(
      migrator,
      katalogArtikli,
      katalogArtikli.stableArticleId,
    );
    await _ensureColumn(migrator, iriu, iriu.katalogStableArticleId);
    await _ensureTable(migrator, stanjeRobeStavke);
    await _ensureTable(migrator, stanjeRobeAppliedEffects);
    await _ensureTable(migrator, stanjeRobePosledice);
    await _ensureAppPodesavanjaStanjeRobeOperativnoColumn();
    await _createCeremonyReminderSettingsTable();
    await _ensureCeremonyReminderDeliveryTimesColumn();
    await _ensureColumn(migrator, predmeti, predmeti.docekDatum);
    await _ensureColumn(migrator, predmeti, predmeti.grobljePolaganjaUrne);
    await _ensureColumn(migrator, predmeti, predmeti.promenaSanduka);
    await _ensureColumn(migrator, iriuKatalogConfig, iriuKatalogConfig.cena);
    await _ensureColumn(migrator, iriu, iriu.cena);
    await _ensureColumn(migrator, predmeti, predmeti.partePotrebna);
    await _ensureColumn(
      migrator,
      firmaPodaci,
      firmaPodaci.parteDefaultTemplateId,
    );
    await _ensureTable(migrator, partePredlosci);
    await _ensureTable(migrator, partePripreme);
    await _ensureColumn(
      migrator,
      iriuKatalogConfig,
      iriuKatalogConfig.osnovnaUSvakomPredmetu,
    );
    await _ensureTable(migrator, scenarioModules);
    await _ensureTable(migrator, scenarioDefinitions);
    await _ensureTable(migrator, predmetScenarioSnapshots);
    await _ensureTable(migrator, iriuProvenance);
    await _ensureColumn(migrator, iriu, iriu.poslovniStatus);
    await _ensureColumn(migrator, iriu, iriu.obezbedjuje);
    await _ensureColumn(migrator, iriu, iriu.poslovnoUpozorenje);
    await _ensureColumn(migrator, iriu, iriu.poslovniRazlog);
    await _ensureColumn(migrator, iriu, iriu.poslovnaCelina);
    await _ensureColumn(migrator, iriu, iriu.poslovniRedosled);
    await _ensureColumn(migrator, iriu, iriu.finansijskiUkljuceno);
    await _ensureColumn(migrator, iriu, iriu.scenarioUpravlja);
    await _ensureColumn(migrator, iriu, iriu.cekaOdlukuKorisnika);
  }

  Future<void> _validateRequiredSchema() async {
    for (final table in allTables) {
      if (table.actualTableName == 'korisnici') {
        await _schemaRecovery.validateGeneratedTable(
          table,
          allowedExtraColumns: const {
            'must_change_pin',
            'pin_updated_at',
            'pin_hash_version',
          },
        );
      } else if (table.actualTableName == 'app_podesavanja') {
        await _schemaRecovery.validateGeneratedTable(
          table,
          columnOverrides: const {
            'stanje_robe_operativno_omoguceno': SqliteColumnDefinition(
              name: 'stanje_robe_operativno_omoguceno',
              type: 'INTEGER',
              notNull: true,
              defaultSql: '0',
              primaryKeyPosition: 0,
              acceptedLegacyDefaultSql: <String?>['1'],
            ),
          },
        );
      } else {
        await _schemaRecovery.validateGeneratedTable(table);
      }
    }

    await _schemaRecovery.validateColumns('korisnici', const [
      SqliteColumnDefinition(
        name: 'must_change_pin',
        type: 'INTEGER',
        notNull: true,
        defaultSql: '0',
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'pin_updated_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'pin_hash_version',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
    ], rejectUnexpectedColumns: false);
    await _validateManualTables();
  }

  Future<void> _validateManualTables() async {
    await _schemaRecovery.validateColumns('security_settings', const [
      SqliteColumnDefinition(
        name: 'id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 1,
      ),
      SqliteColumnDefinition(
        name: 'recovery_code_hash',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'recovery_code_salt',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'recovery_code_version',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'recovery_configured_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'recovery_regenerated_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
    ]);
    await _schemaRecovery.validateColumns('auth_audit_log', const [
      SqliteColumnDefinition(
        name: 'id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 1,
      ),
      SqliteColumnDefinition(
        name: 'timestamp',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'event_type',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'actor_type',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'actor_user_id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'target_user_id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'result',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'details',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'install_context',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
    ]);
    await _schemaRecovery.validateColumns('iriu_lifecycle_decisions', const [
      SqliteColumnDefinition(
        name: 'id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 1,
      ),
      SqliteColumnDefinition(
        name: 'predmet_id',
        type: 'INTEGER',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'interni_naziv',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'scope_key',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'decision_key',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'created_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: null,
        primaryKeyPosition: 0,
      ),
    ]);
    await _schemaRecovery.validateColumns('ceremony_reminder_settings', const [
      SqliteColumnDefinition(
        name: 'predmet_id',
        type: 'INTEGER',
        notNull: false,
        defaultSql: null,
        primaryKeyPosition: 1,
      ),
      SqliteColumnDefinition(
        name: 'enabled',
        type: 'INTEGER',
        notNull: true,
        defaultSql: '1',
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'frequency_hours',
        type: 'INTEGER',
        notNull: true,
        defaultSql: '24',
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'delivery_times',
        type: 'TEXT',
        notNull: true,
        defaultSql: '\'["09:00"]\'',
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'scheduled_notification_ids',
        type: 'TEXT',
        notNull: true,
        defaultSql: "'[]'",
        primaryKeyPosition: 0,
      ),
      SqliteColumnDefinition(
        name: 'updated_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
    ]);
  }

  Future<void> _prepareAuthSecuritySchema({
    bool backfillExistingMetadata = true,
  }) async {
    await _ensureKorisniciAuthSecurityColumns(
      backfillExistingMetadata: backfillExistingMetadata,
    );
    await _createSecuritySettingsTable();
    await _seedSecuritySettings();
    await _createAuthAuditLogTable();
  }

  Future<void> _ensureAppPodesavanjaStanjeRobeOperativnoColumn() async {
    await _schemaRecovery.ensureColumn(
      tableName: 'app_podesavanja',
      expected: const SqliteColumnDefinition(
        name: 'stanje_robe_operativno_omoguceno',
        type: 'INTEGER',
        notNull: true,
        defaultSql: '0',
        primaryKeyPosition: 0,
        acceptedLegacyDefaultSql: <String?>['1'],
      ),
      addColumnSql: '''
        ALTER TABLE app_podesavanja
        ADD COLUMN stanje_robe_operativno_omoguceno INTEGER NOT NULL DEFAULT 0
        CHECK ("stanje_robe_operativno_omoguceno" IN (0, 1))
      ''',
    );
  }

  Future<void> _ensureCeremonyReminderDeliveryTimesColumn() async {
    await _schemaRecovery.ensureColumn(
      tableName: 'ceremony_reminder_settings',
      expected: const SqliteColumnDefinition(
        name: 'delivery_times',
        type: 'TEXT',
        notNull: true,
        defaultSql: '\'["09:00"]\'',
        primaryKeyPosition: 0,
      ),
      addColumnSql: '''
        ALTER TABLE ceremony_reminder_settings
        ADD COLUMN delivery_times TEXT NOT NULL DEFAULT '["09:00"]'
      ''',
    );
  }

  Future<void> _ensureKorisniciAuthSecurityColumns({
    required bool backfillExistingMetadata,
  }) async {
    await _schemaRecovery.ensureColumn(
      tableName: 'korisnici',
      expected: const SqliteColumnDefinition(
        name: 'must_change_pin',
        type: 'INTEGER',
        notNull: true,
        defaultSql: '0',
        primaryKeyPosition: 0,
      ),
      addColumnSql: '''
          ALTER TABLE korisnici
          ADD COLUMN must_change_pin INTEGER NOT NULL DEFAULT 0
        ''',
    );
    await _schemaRecovery.ensureColumn(
      tableName: 'korisnici',
      expected: const SqliteColumnDefinition(
        name: 'pin_updated_at',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      addColumnSql: '''
          ALTER TABLE korisnici
          ADD COLUMN pin_updated_at TEXT NOT NULL DEFAULT ''
        ''',
    );
    await _schemaRecovery.ensureColumn(
      tableName: 'korisnici',
      expected: const SqliteColumnDefinition(
        name: 'pin_hash_version',
        type: 'TEXT',
        notNull: true,
        defaultSql: "''",
        primaryKeyPosition: 0,
      ),
      addColumnSql: '''
          ALTER TABLE korisnici
          ADD COLUMN pin_hash_version TEXT NOT NULL DEFAULT ''
        ''',
    );
    if (backfillExistingMetadata) {
      await customStatement(
        '''
          UPDATE korisnici
          SET pin_hash_version = ?
          WHERE pin_hash_version = ''
        ''',
        [legacyPinHashVersion],
      );
      await customStatement('''
          UPDATE korisnici
          SET pin_updated_at = datum_kreiranja
          WHERE pin_updated_at = ''
        ''');
    }
  }

  Future<void> _createSecuritySettingsTable() {
    return customStatement('''
      CREATE TABLE IF NOT EXISTS security_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        recovery_code_hash TEXT NOT NULL DEFAULT '',
        recovery_code_salt TEXT NOT NULL DEFAULT '',
        recovery_code_version TEXT NOT NULL DEFAULT '',
        recovery_configured_at TEXT NOT NULL DEFAULT '',
        recovery_regenerated_at TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _seedSecuritySettings() {
    return customStatement('''
      INSERT OR IGNORE INTO security_settings (
        id,
        recovery_code_hash,
        recovery_code_salt,
        recovery_code_version,
        recovery_configured_at,
        recovery_regenerated_at
      ) VALUES (1, '', '', '', '', '')
    ''');
  }

  Future<void> _createAuthAuditLogTable() {
    return customStatement('''
      CREATE TABLE IF NOT EXISTS auth_audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        event_type TEXT NOT NULL,
        actor_type TEXT NOT NULL,
        actor_user_id INTEGER,
        target_user_id INTEGER,
        result TEXT NOT NULL,
        details TEXT NOT NULL DEFAULT '',
        install_context TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _createIriuLifecycleDecisionTable() {
    return customStatement('''
      CREATE TABLE IF NOT EXISTS iriu_lifecycle_decisions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        predmet_id INTEGER NOT NULL REFERENCES predmeti(id) ON DELETE CASCADE,
        interni_naziv TEXT NOT NULL,
        scope_key TEXT NOT NULL,
        decision_key TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(predmet_id, interni_naziv, scope_key, decision_key)
      )
    ''');
  }

  Future<void> _createCeremonyReminderSettingsTable() {
    return customStatement('''
      CREATE TABLE IF NOT EXISTS ceremony_reminder_settings (
        predmet_id INTEGER PRIMARY KEY REFERENCES predmeti(id) ON DELETE CASCADE,
        enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
        frequency_hours INTEGER NOT NULL DEFAULT 24,
        delivery_times TEXT NOT NULL DEFAULT '["09:00"]',
        scheduled_notification_ids TEXT NOT NULL DEFAULT '[]',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  // ── Singleton records ────────────────────────────────────────────────────

  Future<void> _seedSingletons() async {
    await into(firmaPodaci).insert(
      const FirmaPodaciCompanion(id: Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
    await into(appPodesavanja).insert(
      const AppPodesavanjaCompanion(
        id: Value(1),
        stanjeRobeOperativnoOmoguceno: Value(false),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // ── IRIU katalog — predefinisane stavke (sloj 1) ─────────────────────────

  Future<void> _seedIriuKatalog({bool loadPhotos = true}) async {
    final stavke = [
      (naziv: 'SANDUK', prikaz: 'Sanduk', tip: 'KATALOSKA', red: 1),
      (
        naziv: 'POKROV_GARNITURA',
        prikaz: 'Pokrov garnitura',
        tip: 'KATALOSKA',
        red: 2,
      ),
      (naziv: 'OBELEZJE', prikaz: 'Obeležje', tip: 'KATALOSKA', red: 3),
      (
        naziv: 'PESKIR_ZA_KRST',
        prikaz: 'Peškir za krst',
        tip: 'FIKSNA',
        red: 4,
      ),
      (
        naziv: 'POSMRTNE_PARTE',
        prikaz: 'Posmrtne parte',
        tip: 'FIKSNA',
        red: 5,
      ),
      (naziv: 'HLADNJACA', prikaz: 'Hladnjača', tip: 'FIKSNA', red: 6),
      (
        naziv: 'SPREMANJE_POKOJNIKA',
        prikaz: 'Spremanje preminulog lica',
        tip: 'FIKSNA',
        red: 7,
      ),
      (naziv: 'IZNOSENJE', prikaz: 'Iznošenje', tip: 'FIKSNA', red: 8),
      (
        naziv: 'PREVOZ_DO_HLADNJACE',
        prikaz: 'Prevoz do hladnjače',
        tip: 'FIKSNA',
        red: 9,
      ),
      (
        naziv: 'PREVOZ_DO_GROBLJA',
        prikaz: 'Prevoz do groblja',
        tip: 'FIKSNA',
        red: 10,
      ),
      (
        naziv: 'PREVOZ_SPROVODA',
        prikaz: 'Prevoz sprovoda',
        tip: 'FIKSNA',
        red: 11,
      ),
      (naziv: 'CRNINA', prikaz: 'Crnina', tip: 'KATALOSKA', red: 12),
      (naziv: 'LIMENI_ULOZAK', prikaz: 'Limeni uložak', tip: 'FIKSNA', red: 13),
      (naziv: 'LEMOVANJE', prikaz: 'Lemovanje', tip: 'FIKSNA', red: 14),
      (
        naziv: 'AGENCIJSKE_USLUGE',
        prikaz: 'Agencijske usluge',
        tip: 'FIKSNA',
        red: 15,
      ),
      (
        naziv: 'TRANSPORTNA_VRECA',
        prikaz: 'Transportna vreća',
        tip: 'FIKSNA',
        red: 16,
      ),
      (naziv: 'CVECE', prikaz: 'Cveće', tip: 'KATALOSKA', red: 17),
      (
        naziv: 'KOMPLET_ZA_OPELO',
        prikaz: 'Komplet za opelo',
        tip: 'KATALOSKA',
        red: 18,
      ),
      (
        naziv: 'CITULJA_POLITIKA',
        prikaz: 'Čitulja Politika',
        tip: 'KATALOSKA',
        red: 19,
      ),
      (
        naziv: 'CITULJA_NOVOSTI',
        prikaz: 'Čitulja Novosti',
        tip: 'KATALOSKA',
        red: 20,
      ),
      (naziv: IriuK.slika, prikaz: 'Slika', tip: 'KATALOSKA', red: 25),
      (
        naziv: IriuK.zastitnaIDodatnaOprema,
        prikaz: 'Zaštitna i dodatna oprema',
        tip: 'FIKSNA',
        red: 26,
      ),
      (
        naziv: IriuK.medjunarodniPrevoz,
        prikaz: 'Međunarodni prevoz',
        tip: 'FIKSNA',
        red: 21,
      ),
      (
        naziv: IriuK.medjunarodnaDocumentacija,
        prikaz: 'Međunarodna dokumentacija',
        tip: 'FIKSNA',
        red: 22,
      ),
      (
        naziv: IriuK.balsamovanje,
        prikaz: 'Balsamovanje',
        tip: 'FIKSNA',
        red: 23,
      ),
      (
        naziv: IriuK.cargoTroskovi,
        prikaz: 'Cargo troškovi',
        tip: 'FIKSNA',
        red: 24,
      ),
      (
        naziv: IriuK.doradaPogrebneOpreme,
        prikaz: 'Dorada pogrebne opreme',
        tip: 'FIKSNA',
        red: 1001,
      ),
      (
        naziv: IriuK.kucanjeObelezja,
        prikaz: 'Kucanje obeležja',
        tip: 'FIKSNA',
        red: 1002,
      ),
      (
        naziv: IriuK.slovaIBrojevi,
        prikaz: 'Slova i brojevi',
        tip: 'FIKSNA',
        red: 1003,
      ),
    ];

    for (final s in stavke) {
      await into(iriuKatalogConfig).insert(
        IriuKatalogConfigCompanion(
          interniNaziv: Value(s.naziv),
          nazivPrikaz: Value(s.prikaz),
          tip: Value(s.tip),
          redosled: Value(s.red),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Čitulja Politika — predefinisane stavke iz projektnog zadatka (poglavlje 11.1)
    // Grupisano: najpre Cela zemlja, pa Beogradsko izdanje
    final cituljePolitika = [
      // ── Cela zemlja ───────────────────────────────────────────────────────
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/46 mm — Cela zemlja', 1500.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/75 mm — Cela zemlja', 2900.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/90 mm — Cela zemlja', 3500.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/136 mm — Cela zemlja', 10000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/182 mm — Cela zemlja', 14000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/226 mm — Cela zemlja', 17000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/75 mm — Cela zemlja', 7800.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/90 mm — Cela zemlja', 14000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/136 mm — Cela zemlja', 21000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/182 mm — Cela zemlja', 27000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/226 mm — Cela zemlja', 34000.0),
      (
        'CITULJA_POLITIKA',
        'ČITULJA POLITIKA III/136 mm — Cela zemlja',
        31000.0,
      ),
      (
        'CITULJA_POLITIKA',
        'ČITULJA POLITIKA III/182 mm — Cela zemlja',
        41000.0,
      ),
      (
        'CITULJA_POLITIKA',
        'ČITULJA POLITIKA 1/4 strane — Cela zemlja',
        50000.0,
      ),
      (
        'CITULJA_POLITIKA',
        'ČITULJA POLITIKA 1/2 strane — Cela zemlja',
        102000.0,
      ),
      (
        'CITULJA_POLITIKA',
        'ČITULJA POLITIKA 1/1 strana — Cela zemlja',
        204000.0,
      ),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA Internet — samo sajt', 2500.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA Internet — uz štampano', 1000.0),
      // ── Beogradsko izdanje ────────────────────────────────────────────────
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/46 mm — Beograd', 1350.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/75 mm — Beograd', 2610.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/90 mm — Beograd', 3150.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/136 mm — Beograd', 9000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/182 mm — Beograd', 12600.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA I/226 mm — Beograd', 15300.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/75 mm — Beograd', 7020.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/90 mm — Beograd', 12600.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/136 mm — Beograd', 18900.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/182 mm — Beograd', 24300.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA II/226 mm — Beograd', 30600.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA III/136 mm — Beograd', 27900.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA III/182 mm — Beograd', 36900.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA 1/4 strane — Beograd', 45000.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA 1/2 strane — Beograd', 91800.0),
      ('CITULJA_POLITIKA', 'ČITULJA POLITIKA 1/1 strana — Beograd', 183600.0),
    ];

    // Čitulja Novosti — predefinisane stavke iz projektnog zadatka (poglavlje 11.2 i 11.3)
    final cituljaNovosti = [
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/12 stupca', 1800.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/6 stupca', 2800.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/4 stupca', 4100.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/3 stupca', 7500.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/2 stupca', 12500.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/18 strane', 9000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/12 strane', 12500.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/9 strane', 16000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/8 strane', 18000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/6 strane horiz.', 30000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/6 strane vert.', 30000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/4 strane', 60000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/2 strane', 115000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Print 1/1 strana', 220000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Online 1/4 web prikaza', 3000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Online 1/2 web prikaza', 10000.0),
      ('CITULJA_NOVOSTI', 'Čitulja Novosti Online 1/1 web prikaza', 20000.0),
    ];

    // Katalog artikli sa fotografijama (BLOB učitan iz assets)
    // Format: (interniNaziv, naziv, cena, assetPath)
    final sandukArtikli = [
      ('SANDUK', 'SANDUK V-0', 49960.0, 'assets/katalog_foto/katalog_001.jpg'),
      ('SANDUK', 'SANDUK V-4', 52790.0, 'assets/katalog_foto/katalog_004.jpg'),
      (
        'SANDUK',
        'SANDUK V-4 CVET',
        55790.0,
        'assets/katalog_foto/katalog_005.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-5 ELEGANCE',
        58790.0,
        'assets/katalog_foto/katalog_006.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-5 LJILJAN',
        58790.0,
        'assets/katalog_foto/katalog_007.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-5 CVEĆE',
        60790.0,
        'assets/katalog_foto/katalog_008.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-14 CVET POLUKOVČEG',
        69790.0,
        'assets/katalog_foto/katalog_009.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-15 POLUKOVČEG',
        69790.0,
        'assets/katalog_foto/katalog_010.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-16 CVEĆE POLUKOVČEG',
        70790.0,
        'assets/katalog_foto/katalog_011.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-16 POLUKOVČEG',
        70790.0,
        'assets/katalog_foto/katalog_012.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-17 POLUKOVČEG',
        75790.0,
        'assets/katalog_foto/katalog_013.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-18 POLUKOVČEG',
        78790.0,
        'assets/katalog_foto/katalog_014.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-19 KOVČEG',
        88790.0,
        'assets/katalog_foto/katalog_015.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-20 KOVČEG',
        88790.0,
        'assets/katalog_foto/katalog_016.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-21 KOVČEG',
        85790.0,
        'assets/katalog_foto/katalog_017.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-ŠESTOUGAONI TV',
        89790.0,
        'assets/katalog_foto/katalog_018.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-22 POLUKOVČEG',
        95790.0,
        'assets/katalog_foto/katalog_019.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-PALMA POLUKOVČEG',
        98790.0,
        'assets/katalog_foto/katalog_020.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-AMER POLUKOVČEG',
        98790.0,
        'assets/katalog_foto/katalog_021.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-84 HRAST',
        121790.0,
        'assets/katalog_foto/katalog_022.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-87 KOVČEG',
        125790.0,
        'assets/katalog_foto/katalog_023.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-JAMBO',
        220790.0,
        'assets/katalog_foto/katalog_024.jpg',
      ),
      (
        'SANDUK',
        'SANDUK VH-AMERIKAN',
        259790.0,
        'assets/katalog_foto/katalog_025.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-BELI',
        69790.0,
        'assets/katalog_foto/katalog_026.jpg',
      ),
      (
        'SANDUK',
        'SANDUK V-BELI ŠESTOUGAONI',
        89790.0,
        'assets/katalog_foto/katalog_027.jpg',
      ),
    ];

    // POKROV GARNITURA — 5 artikala
    final pokrovArtikli = [
      (
        'POKROV_GARNITURA',
        'POKROV GARNITURA BELA',
        10620.0,
        'assets/katalog_foto/katalog_002.jpg',
      ),
      (
        'POKROV_GARNITURA',
        'POKROV GARNITURA BRAON',
        10620.0,
        'assets/katalog_foto/katalog_030.jpg',
      ),
      (
        'POKROV_GARNITURA',
        'POKROV GARNITURA ST. ZLATO',
        10620.0,
        'assets/katalog_foto/katalog_031.jpg',
      ),
      (
        'POKROV_GARNITURA',
        'POKROV GARNITURA KREM',
        10620.0,
        'assets/katalog_foto/katalog_032.jpg',
      ),
      (
        'POKROV_GARNITURA',
        'POKROV GARNITURA BORDO',
        10620.0,
        'assets/katalog_foto/katalog_033.jpg',
      ),
    ];

    // OBELEŽJE (krst / piramida) — 3 artikla
    final obelezjeArtikli = [
      (
        'OBELEZJE',
        'SVETOSAVSKI KRST Topola/Hrast',
        8820.0,
        'assets/katalog_foto/katalog_003.jpg',
      ),
      (
        'OBELEZJE',
        'KRST Topola/Bukva/Hrast',
        6620.0,
        'assets/katalog_foto/katalog_028.jpg',
      ),
      ('OBELEZJE', 'PIRAMIDA', 6620.0, 'assets/katalog_foto/katalog_029.jpg'),
    ];

    // CVEĆE — 42 artikla (suze, buketi, venci)
    final ceceArtikli = [
      (
        'CVECE',
        'CVEĆE SUZA SU 1/1',
        10000.0,
        'assets/katalog_foto/katalog_044.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 1/2',
        10000.0,
        'assets/katalog_foto/katalog_034.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 1/3',
        10000.0,
        'assets/katalog_foto/katalog_035.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 1/4',
        10000.0,
        'assets/katalog_foto/katalog_036.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 2/1',
        12000.0,
        'assets/katalog_foto/katalog_037.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/1',
        15000.0,
        'assets/katalog_foto/katalog_038.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/2',
        15000.0,
        'assets/katalog_foto/katalog_039.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/3',
        15000.0,
        'assets/katalog_foto/katalog_040.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/4',
        15000.0,
        'assets/katalog_foto/katalog_041.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/5',
        15000.0,
        'assets/katalog_foto/katalog_042.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/6',
        15000.0,
        'assets/katalog_foto/katalog_043.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/7',
        15000.0,
        'assets/katalog_foto/katalog_045.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/8',
        15000.0,
        'assets/katalog_foto/katalog_046.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/9',
        15000.0,
        'assets/katalog_foto/katalog_047.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA SU 3/10',
        15000.0,
        'assets/katalog_foto/katalog_048.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA CE 1/1',
        15000.0,
        'assets/katalog_foto/katalog_051.jpg',
      ),
      (
        'CVECE',
        'CVEĆE BUKET E 1/1',
        20000.0,
        'assets/katalog_foto/katalog_049.jpg',
      ),
      (
        'CVECE',
        'CVEĆE BUKET E 1/2',
        20000.0,
        'assets/katalog_foto/katalog_050.jpg',
      ),
      (
        'CVECE',
        'CVEĆE BUKET E 1/3',
        20000.0,
        'assets/katalog_foto/katalog_052.jpg',
      ),
      (
        'CVECE',
        'CVEĆE BUKET 1/4',
        20000.0,
        'assets/katalog_foto/katalog_053.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA E 1/7',
        20000.0,
        'assets/katalog_foto/katalog_056.jpg',
      ),
      (
        'CVECE',
        'CVEĆE SUZA E 1/9',
        36000.0,
        'assets/katalog_foto/katalog_058.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC E 1/5',
        24000.0,
        'assets/katalog_foto/katalog_054.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC E 1/6',
        24000.0,
        'assets/katalog_foto/katalog_055.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC E 1/8',
        18000.0,
        'assets/katalog_foto/katalog_057.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 1/1',
        10000.0,
        'assets/katalog_foto/katalog_059.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 1/2',
        10000.0,
        'assets/katalog_foto/katalog_060.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 1/3',
        10000.0,
        'assets/katalog_foto/katalog_061.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 2/1',
        12000.0,
        'assets/katalog_foto/katalog_062.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 2/2',
        12000.0,
        'assets/katalog_foto/katalog_063.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/1',
        15000.0,
        'assets/katalog_foto/katalog_064.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/2',
        15000.0,
        'assets/katalog_foto/katalog_065.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/3',
        15000.0,
        'assets/katalog_foto/katalog_066.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/4',
        15000.0,
        'assets/katalog_foto/katalog_067.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/5',
        15000.0,
        'assets/katalog_foto/katalog_068.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/6',
        15000.0,
        'assets/katalog_foto/katalog_069.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/7',
        15000.0,
        'assets/katalog_foto/katalog_070.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/8',
        15000.0,
        'assets/katalog_foto/katalog_071.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/9',
        15000.0,
        'assets/katalog_foto/katalog_072.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 3/10',
        15000.0,
        'assets/katalog_foto/katalog_073.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 4/1',
        18000.0,
        'assets/katalog_foto/katalog_074.jpg',
      ),
      (
        'CVECE',
        'CVEĆE VENAC VE 4/2',
        18000.0,
        'assets/katalog_foto/katalog_075.jpg',
      ),
    ];

    // ── Katalog artikli sa fotografijama — samo u eksplicitnim TEST varijantama
    // Bezbedan fallback nikada ne sme aktivirati full photo seed.
    // Asset packaging ostaje nepromenjeno i nije deo ovog taska.
    if (kShouldSeedFullPhotoCatalog) {
      final sviArtikli = [
        ...sandukArtikli,
        ...pokrovArtikli,
        ...obelezjeArtikli,
        ...ceceArtikli,
      ].where((c) => kFullPhotoCatalogSeedKategorije.contains(c.$1));
      for (final c in sviArtikli) {
        final bytes = loadPhotos ? await _ucitajAsset(c.$4) : null;
        await into(katalogArtikli).insert(
          KatalogArtikliCompanion(
            stableArticleId: Value(
              StockCatalogIdentity.stableIdForSeedArticle(
                    interniNazivKategorije: c.$1,
                    naziv: c.$2,
                  ) ??
                  generateCatalogArticleStableId(),
            ),
            interniNazivKategorije: Value(c.$1),
            naziv: Value(c.$2),
            cena: Value(c.$3),
            fotografija: Value(bytes),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }

    // ── Čitulje — seede se uvek (standardni cenici novina) ───────────────────
    for (final c in [...cituljePolitika, ...cituljaNovosti]) {
      await into(katalogArtikli).insert(
        KatalogArtikliCompanion(
          stableArticleId: Value(generateCatalogArticleStableId()),
          interniNazivKategorije: Value(c.$1),
          naziv: Value(c.$2),
          cena: Value(c.$3),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// Repairs the two known catalog integrity defects without applying a
  /// broad name-based deduplication to user data.
  ///
  /// `SLIKA` is a built-in business identity. Older databases could also
  /// contain a user category with the same display name. References are
  /// mapped before the duplicate config row is removed, including stored
  /// IRIU rows, catalog articles, scenario packages/definitions and
  /// assignment snapshots.
  Future<void> repairKnownCatalogIntegrity() async {
    // CRNINA is a canonical category identity. Older databases stored it as
    // FIKSNA; migrate only this type in place so all existing references and
    // user data remain untouched.
    await (update(iriuKatalogConfig)
          ..where((row) => row.interniNaziv.equals(IriuK.crnina)))
        .write(const IriuKatalogConfigCompanion(tip: Value('KATALOSKA')));
    await (update(iriuKatalogConfig)..where(
          (row) => row.interniNaziv.equals(IriuK.zastitnaIDodatnaOprema),
        ))
        .write(
          const IriuKatalogConfigCompanion(
            nazivPrikaz: Value('Zaštitna i dodatna oprema'),
          ),
        );

    final canonical = await (select(
      iriuKatalogConfig,
    )..where((row) => row.interniNaziv.equals(IriuK.slika))).getSingleOrNull();
    if (canonical == null) return;

    final duplicates = (await select(iriuKatalogConfig).get())
        .where(
          (row) =>
              row.interniNaziv != canonical.interniNaziv &&
              _catalogBusinessKey(row.nazivPrikaz) == 'SLIKA',
        )
        .map((row) => row.interniNaziv)
        .toList(growable: false);
    for (final duplicate in duplicates) {
      await _mergeCatalogCategory(duplicate, canonical.interniNaziv);
    }
  }

  String? _catalogBusinessKey(String value) {
    final normalized = value.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return normalized == 'SLIKA' ? 'SLIKA' : null;
  }

  Future<void> _mergeCatalogCategory(String duplicate, String canonical) async {
    await transaction(() async {
      final duplicateRows = await (select(
        iriu,
      )..where((row) => row.interniNaziv.equals(duplicate))).get();
      for (final duplicateRow in duplicateRows) {
        final canonicalRow =
            await (select(iriu)
                  ..where(
                    (row) =>
                        row.predmetId.equals(duplicateRow.predmetId) &
                        row.interniNaziv.equals(canonical),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (canonicalRow == null) {
          await (update(iriu)..where((row) => row.id.equals(duplicateRow.id)))
              .write(IriuCompanion(interniNaziv: Value(canonical)));
          continue;
        }

        await (update(
          iriu,
        )..where((row) => row.id.equals(canonicalRow.id))).write(
          IriuCompanion(
            nazivPrikaz: canonicalRow.nazivPrikaz.trim().isEmpty
                ? Value(duplicateRow.nazivPrikaz)
                : const Value.absent(),
            kom: canonicalRow.kom.trim().isEmpty
                ? Value(duplicateRow.kom)
                : const Value.absent(),
            iznos: canonicalRow.iznos == 0 && duplicateRow.iznos != 0
                ? Value(duplicateRow.iznos)
                : const Value.absent(),
            redosled: canonicalRow.redosled <= 0
                ? Value(duplicateRow.redosled)
                : const Value.absent(),
          ),
        );
        await _mergeIriuProvenance(duplicateRow.id, canonicalRow.id);
        await (delete(
          iriu,
        )..where((row) => row.id.equals(duplicateRow.id))).go();
      }

      await (update(
        katalogArtikli,
      )..where((row) => row.interniNazivKategorije.equals(duplicate))).write(
        KatalogArtikliCompanion(interniNazivKategorije: Value(canonical)),
      );

      final modules = await select(scenarioModules).get();
      for (final module in modules) {
        final next = _replaceCategoryInJsonList(
          module.osnovniPaketJson,
          duplicate,
          canonical,
        );
        if (next != null) {
          await (update(scenarioModules)
                ..where((row) => row.id.equals(module.id)))
              .write(ScenarioModulesCompanion(osnovniPaketJson: Value(next)));
        }
      }

      final definitions = await select(scenarioDefinitions).get();
      for (final definition in definitions) {
        final next = _replaceCategoryInConsequences(
          definition.consequencesJson,
          duplicate,
          canonical,
        );
        if (next != null) {
          await (update(scenarioDefinitions)..where(
                (row) =>
                    row.id.equals(definition.id) &
                    row.version.equals(definition.version),
              ))
              .write(
                ScenarioDefinitionsCompanion(consequencesJson: Value(next)),
              );
        }
      }

      final snapshots = await select(predmetScenarioSnapshots).get();
      for (final snapshot in snapshots) {
        final decoded = _decodeJson(snapshot.snapshotJson);
        if (decoded == null) continue;
        final changed = _replaceCategoryInJsonValue(
          decoded,
          duplicate,
          canonical,
        );
        if (!changed) continue;
        await (update(
          predmetScenarioSnapshots,
        )..where((row) => row.predmetId.equals(snapshot.predmetId))).write(
          PredmetScenarioSnapshotsCompanion(
            snapshotJson: Value(jsonEncode(decoded)),
          ),
        );
      }

      await (delete(
        iriuKatalogConfig,
      )..where((row) => row.interniNaziv.equals(duplicate))).go();
    });
  }

  Future<void> _mergeIriuProvenance(int duplicateId, int canonicalId) async {
    final duplicate = await (select(
      iriuProvenance,
    )..where((row) => row.iriuId.equals(duplicateId))).getSingleOrNull();
    if (duplicate == null) return;
    final canonical = await (select(
      iriuProvenance,
    )..where((row) => row.iriuId.equals(canonicalId))).getSingleOrNull();
    if (canonical == null) {
      await (update(iriuProvenance)
            ..where((row) => row.iriuId.equals(duplicateId)))
          .write(IriuProvenanceCompanion(iriuId: Value(canonicalId)));
    } else {
      await (delete(
        iriuProvenance,
      )..where((row) => row.iriuId.equals(duplicateId))).go();
    }
  }

  String? _replaceCategoryInJsonList(
    String json,
    String duplicate,
    String canonical,
  ) {
    final decoded = _decodeJson(json);
    if (decoded is! List) return null;
    final next = <dynamic>[];
    var changed = false;
    for (final value in decoded) {
      if (value is! String) {
        next.add(value);
        continue;
      }
      final replacement = value == duplicate ? canonical : value;
      changed = changed || replacement != value;
      if (!next.contains(replacement)) next.add(replacement);
    }
    return changed ? jsonEncode(next) : null;
  }

  String? _replaceCategoryInConsequences(
    String json,
    String duplicate,
    String canonical,
  ) {
    final decoded = _decodeJson(json);
    if (decoded is! List) return null;
    final seen = <String>{};
    var changed = false;
    final next = <dynamic>[];
    for (final raw in decoded) {
      if (raw is! Map) {
        next.add(raw);
        continue;
      }
      final item = Map<String, dynamic>.from(raw);
      final value = item['katalogCategoryInternalName'];
      if (value == duplicate) {
        item['katalogCategoryInternalName'] = canonical;
        changed = true;
      }
      final key = item['katalogCategoryInternalName'];
      if (key is String && !seen.add(key)) {
        changed = true;
        continue;
      }
      next.add(item);
    }
    return changed ? jsonEncode(next) : null;
  }

  dynamic _decodeJson(String json) {
    try {
      return jsonDecode(json);
    } on Object {
      return null;
    }
  }

  bool _replaceCategoryInJsonValue(
    dynamic value,
    String duplicate,
    String canonical,
  ) {
    var changed = false;
    if (value is List) {
      for (var index = 0; index < value.length; index++) {
        final item = value[index];
        if (item is String && item == duplicate) {
          value[index] = canonical;
          changed = true;
        } else {
          changed =
              _replaceCategoryInJsonValue(item, duplicate, canonical) ||
              changed;
        }
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        final item = entry.value;
        if (item is String && item == duplicate) {
          value[entry.key] = canonical;
          changed = true;
        } else {
          changed =
              _replaceCategoryInJsonValue(item, duplicate, canonical) ||
              changed;
        }
      }
    }
    return changed;
  }

  Future<void> _backfillBuiltInIriuBasicPolicy() async {
    final builtInBasicCategories = <String>{
      ...IriuK.ugradjeneOsnovnePreAgencijskih,
      IriuK.agencijskeUsluge,
    };
    await (update(
      iriuKatalogConfig,
    )..where((row) => row.interniNaziv.isIn(builtInBasicCategories))).write(
      const IriuKatalogConfigCompanion(osnovnaUSvakomPredmetu: Value(true)),
    );
  }

  /// Učitava asset kao Uint8List (koristi se pri seeding-u i migraciji).
  Future<Uint8List?> _ucitajAsset(String path) async {
    if (_catalogAssetCache.containsKey(path)) {
      return _catalogAssetCache[path];
    }
    try {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();
      _catalogAssetCache[path] = bytes;
      return bytes;
    } catch (_) {
      _catalogAssetCache[path] = null;
      return null;
    }
  }

  Future<void> _ensureKatalogStableArticleIdUniqueIndex() async {
    await _schemaRecovery.ensureIndex(
      const SqliteIndexDefinition(
        name: 'idx_katalog_artikli_stable_article_id',
        table: 'katalog_artikli',
        unique: true,
        columns: ['stable_article_id'],
        whereSql:
            "WHERE stable_article_id IS NOT NULL AND TRIM(stable_article_id) <> ''",
        createSql: '''
          CREATE UNIQUE INDEX idx_katalog_artikli_stable_article_id
          ON katalog_artikli(stable_article_id)
          WHERE stable_article_id IS NOT NULL
            AND TRIM(stable_article_id) <> ''
        ''',
      ),
    );
  }

  Future<void> _ensureStanjeRobeStableArticleIdUniqueIndex() async {
    await _schemaRecovery.ensureIndex(
      const SqliteIndexDefinition(
        name: 'idx_stanje_robe_stavke_stable_article_id',
        table: 'stanje_robe_stavke',
        unique: true,
        columns: ['stable_article_id'],
        createSql: '''
          CREATE UNIQUE INDEX idx_stanje_robe_stavke_stable_article_id
          ON stanje_robe_stavke(stable_article_id)
        ''',
      ),
    );
  }

  Future<void> _ensureStanjeRobeAppliedEffectsIndexes() async {
    for (final index in const [
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_applied_effects_predmet',
        table: 'stanje_robe_applied_effects',
        unique: false,
        columns: ['predmet_id'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_applied_effects_predmet
          ON stanje_robe_applied_effects(predmet_id)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_applied_effects_selection',
        table: 'stanje_robe_applied_effects',
        unique: false,
        columns: ['predmet_id', 'iriu_id', 'kategorija', 'effect_status'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_applied_effects_selection
          ON stanje_robe_applied_effects(
            predmet_id, iriu_id, kategorija, effect_status
          )
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_applied_effects_article_status',
        table: 'stanje_robe_applied_effects',
        unique: false,
        columns: ['stable_article_id', 'effect_status'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_applied_effects_article_status
          ON stanje_robe_applied_effects(stable_article_id, effect_status)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_applied_effects_current_selection',
        table: 'stanje_robe_applied_effects',
        unique: true,
        columns: ['predmet_id', 'iriu_id', 'kategorija'],
        whereSql: "WHERE effect_status IN ('APPLIED', 'UNRESOLVED')",
        createSql: '''
          CREATE UNIQUE INDEX idx_stanje_robe_applied_effects_current_selection
          ON stanje_robe_applied_effects(predmet_id, iriu_id, kategorija)
          WHERE effect_status IN ('APPLIED', 'UNRESOLVED')
        ''',
      ),
    ]) {
      await _schemaRecovery.ensureIndex(index);
    }
  }

  Future<void> _ensureStanjeRobePoslediceIndexes() async {
    for (final index in const [
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_posledice_predmet',
        table: 'stanje_robe_posledice',
        unique: false,
        columns: ['predmet_id'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_posledice_predmet
          ON stanje_robe_posledice(predmet_id)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_posledice_iriu',
        table: 'stanje_robe_posledice',
        unique: false,
        columns: ['iriu_id'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_posledice_iriu
          ON stanje_robe_posledice(iriu_id)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_posledice_predmet_iriu',
        table: 'stanje_robe_posledice',
        unique: false,
        columns: ['predmet_id', 'iriu_id'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_posledice_predmet_iriu
          ON stanje_robe_posledice(predmet_id, iriu_id)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_posledice_predmet_status',
        table: 'stanje_robe_posledice',
        unique: false,
        columns: ['predmet_id', 'status'],
        createSql: '''
          CREATE INDEX idx_stanje_robe_posledice_predmet_status
          ON stanje_robe_posledice(predmet_id, status)
        ''',
      ),
      SqliteIndexDefinition(
        name: 'idx_stanje_robe_posledice_active_row',
        table: 'stanje_robe_posledice',
        unique: true,
        columns: ['predmet_id', 'iriu_id', 'kategorija'],
        whereSql: "WHERE status = 'UNRESOLVED'",
        createSql: '''
          CREATE UNIQUE INDEX idx_stanje_robe_posledice_active_row
          ON stanje_robe_posledice(predmet_id, iriu_id, kategorija)
          WHERE status = 'UNRESOLVED'
        ''',
      ),
    ]) {
      await _schemaRecovery.ensureIndex(index);
    }
  }

  Future<void> backfillMissingKatalogStableArticleIds() async {
    await transaction(() async {
      final rows = await customSelect(
        '''
        SELECT id
        FROM katalog_artikli
        WHERE stable_article_id IS NULL
           OR TRIM(stable_article_id) = ''
        ''',
        readsFrom: {katalogArtikli},
      ).get();

      for (final row in rows) {
        final id = row.read<int>('id');
        await customUpdate(
          '''
          UPDATE katalog_artikli
          SET stable_article_id = ?
          WHERE id = ?
            AND (stable_article_id IS NULL OR TRIM(stable_article_id) = '')
          ''',
          variables: [
            Variable<String>(generateCatalogArticleStableId()),
            Variable<int>(id),
          ],
          updates: {katalogArtikli},
        );
      }
    });
  }

  Future<void> canonicalizeSeedCatalogStableArticleIds() async {
    await transaction(() async {
      final rows = await customSelect(
        '''
        SELECT id, stable_article_id, interni_naziv_kategorije, naziv
        FROM katalog_artikli
        ''',
        readsFrom: {katalogArtikli},
      ).get();

      for (final row in rows) {
        final id = row.read<int>('id');
        final currentStableId = row.read<String?>('stable_article_id')?.trim();
        final category = row.read<String>('interni_naziv_kategorije');
        final name = row.read<String>('naziv');
        final canonicalStableId =
            StockCatalogIdentity.canonicalStableIdForKnownLegacySeedReference(
              interniNazivKategorije: category,
              naziv: name,
              currentStableArticleId: currentStableId ?? '',
            );
        if (canonicalStableId == null ||
            currentStableId == null ||
            currentStableId.isEmpty ||
            currentStableId == canonicalStableId) {
          continue;
        }

        final conflictingCatalogRow = await customSelect(
          '''
          SELECT id
          FROM katalog_artikli
          WHERE stable_article_id = ?
            AND id <> ?
          LIMIT 1
          ''',
          variables: [Variable<String>(canonicalStableId), Variable<int>(id)],
          readsFrom: {katalogArtikli},
        ).getSingleOrNull();
        if (conflictingCatalogRow != null) continue;

        final conflictingStockRow = await customSelect(
          '''
          SELECT id
          FROM stanje_robe_stavke
          WHERE stable_article_id = ?
          LIMIT 1
          ''',
          variables: [Variable<String>(canonicalStableId)],
          readsFrom: {stanjeRobeStavke},
        ).getSingleOrNull();
        final canMoveStockRow = conflictingStockRow == null;

        await customUpdate(
          '''
          UPDATE katalog_artikli
          SET stable_article_id = ?
          WHERE id = ?
          ''',
          variables: [Variable<String>(canonicalStableId), Variable<int>(id)],
          updates: {katalogArtikli},
        );
        await customUpdate(
          '''
          UPDATE iriu
          SET katalog_stable_article_id = ?
          WHERE katalog_stable_article_id = ?
          ''',
          variables: [
            Variable<String>(canonicalStableId),
            Variable<String>(currentStableId),
          ],
          updates: {iriu},
        );
        if (canMoveStockRow) {
          await customUpdate(
            '''
            UPDATE stanje_robe_stavke
            SET stable_article_id = ?
            WHERE stable_article_id = ?
            ''',
            variables: [
              Variable<String>(canonicalStableId),
              Variable<String>(currentStableId),
            ],
            updates: {stanjeRobeStavke},
          );
        }
        await customUpdate(
          '''
          UPDATE stanje_robe_applied_effects
          SET stable_article_id = ?
          WHERE stable_article_id = ?
          ''',
          variables: [
            Variable<String>(canonicalStableId),
            Variable<String>(currentStableId),
          ],
          updates: {stanjeRobeAppliedEffects},
        );
        await customUpdate(
          '''
          UPDATE stanje_robe_posledice
          SET katalog_stable_article_id = ?
          WHERE katalog_stable_article_id = ?
          ''',
          variables: [
            Variable<String>(canonicalStableId),
            Variable<String>(currentStableId),
          ],
          updates: {stanjeRobePosledice},
        );
      }
    });
  }

  /// Migracija v4 — popuni fotografija BLOB za sve sistemske artikle.
  Future<void> _popuniFotoBlobove() async {
    final mapa = {
      'SANDUK V-0': 'assets/katalog_foto/katalog_001.jpg',
      'SANDUK V-4': 'assets/katalog_foto/katalog_004.jpg',
      'SANDUK V-4 CVET': 'assets/katalog_foto/katalog_005.jpg',
      'SANDUK V-5 ELEGANCE': 'assets/katalog_foto/katalog_006.jpg',
      'SANDUK V-5 LJILJAN': 'assets/katalog_foto/katalog_007.jpg',
      'SANDUK V-5 CVEĆE': 'assets/katalog_foto/katalog_008.jpg',
      'SANDUK V-14 CVET POLUKOVČEG': 'assets/katalog_foto/katalog_009.jpg',
      'SANDUK V-15 POLUKOVČEG': 'assets/katalog_foto/katalog_010.jpg',
      'SANDUK V-16 CVEĆE POLUKOVČEG': 'assets/katalog_foto/katalog_011.jpg',
      'SANDUK V-16 POLUKOVČEG': 'assets/katalog_foto/katalog_012.jpg',
      'SANDUK V-17 POLUKOVČEG': 'assets/katalog_foto/katalog_013.jpg',
      'SANDUK V-18 POLUKOVČEG': 'assets/katalog_foto/katalog_014.jpg',
      'SANDUK V-19 KOVČEG': 'assets/katalog_foto/katalog_015.jpg',
      'SANDUK V-20 KOVČEG': 'assets/katalog_foto/katalog_016.jpg',
      'SANDUK V-21 KOVČEG': 'assets/katalog_foto/katalog_017.jpg',
      'SANDUK V-ŠESTOUGAONI TV': 'assets/katalog_foto/katalog_018.jpg',
      'SANDUK VH-22 POLUKOVČEG': 'assets/katalog_foto/katalog_019.jpg',
      'SANDUK VH-PALMA POLUKOVČEG': 'assets/katalog_foto/katalog_020.jpg',
      'SANDUK VH-AMER POLUKOVČEG': 'assets/katalog_foto/katalog_021.jpg',
      'SANDUK VH-84 HRAST': 'assets/katalog_foto/katalog_022.jpg',
      'SANDUK VH-87 KOVČEG': 'assets/katalog_foto/katalog_023.jpg',
      'SANDUK VH-JAMBO': 'assets/katalog_foto/katalog_024.jpg',
      'SANDUK VH-AMERIKAN': 'assets/katalog_foto/katalog_025.jpg',
      'SANDUK V-BELI': 'assets/katalog_foto/katalog_026.jpg',
      'SANDUK V-BELI ŠESTOUGAONI': 'assets/katalog_foto/katalog_027.jpg',
      'POKROV GARNITURA BELA': 'assets/katalog_foto/katalog_002.jpg',
      'POKROV GARNITURA BRAON': 'assets/katalog_foto/katalog_030.jpg',
      'POKROV GARNITURA ST. ZLATO': 'assets/katalog_foto/katalog_031.jpg',
      'POKROV GARNITURA KREM': 'assets/katalog_foto/katalog_032.jpg',
      'POKROV GARNITURA BORDO': 'assets/katalog_foto/katalog_033.jpg',
      'SVETOSAVSKI KRST Topola/Hrast': 'assets/katalog_foto/katalog_003.jpg',
      'KRST Topola/Bukva/Hrast': 'assets/katalog_foto/katalog_028.jpg',
      'PIRAMIDA': 'assets/katalog_foto/katalog_029.jpg',
      'CVEĆE SUZA SU 1/1': 'assets/katalog_foto/katalog_044.jpg',
      'CVEĆE SUZA SU 1/2': 'assets/katalog_foto/katalog_034.jpg',
      'CVEĆE SUZA SU 1/3': 'assets/katalog_foto/katalog_035.jpg',
      'CVEĆE SUZA SU 1/4': 'assets/katalog_foto/katalog_036.jpg',
      'CVEĆE SUZA SU 2/1': 'assets/katalog_foto/katalog_037.jpg',
      'CVEĆE SUZA SU 3/1': 'assets/katalog_foto/katalog_038.jpg',
      'CVEĆE SUZA SU 3/2': 'assets/katalog_foto/katalog_039.jpg',
      'CVEĆE SUZA SU 3/3': 'assets/katalog_foto/katalog_040.jpg',
      'CVEĆE SUZA SU 3/4': 'assets/katalog_foto/katalog_041.jpg',
      'CVEĆE SUZA SU 3/5': 'assets/katalog_foto/katalog_042.jpg',
      'CVEĆE SUZA SU 3/6': 'assets/katalog_foto/katalog_043.jpg',
      'CVEĆE SUZA SU 3/7': 'assets/katalog_foto/katalog_045.jpg',
      'CVEĆE SUZA SU 3/8': 'assets/katalog_foto/katalog_046.jpg',
      'CVEĆE SUZA SU 3/9': 'assets/katalog_foto/katalog_047.jpg',
      'CVEĆE SUZA SU 3/10': 'assets/katalog_foto/katalog_048.jpg',
      'CVEĆE SUZA CE 1/1': 'assets/katalog_foto/katalog_051.jpg',
      'CVEĆE BUKET E 1/1': 'assets/katalog_foto/katalog_049.jpg',
      'CVEĆE BUKET E 1/2': 'assets/katalog_foto/katalog_050.jpg',
      'CVEĆE BUKET E 1/3': 'assets/katalog_foto/katalog_052.jpg',
      'CVEĆE BUKET 1/4': 'assets/katalog_foto/katalog_053.jpg',
      'CVEĆE SUZA E 1/7': 'assets/katalog_foto/katalog_056.jpg',
      'CVEĆE SUZA E 1/9': 'assets/katalog_foto/katalog_058.jpg',
      'CVEĆE VENAC E 1/5': 'assets/katalog_foto/katalog_054.jpg',
      'CVEĆE VENAC E 1/6': 'assets/katalog_foto/katalog_055.jpg',
      'CVEĆE VENAC E 1/8': 'assets/katalog_foto/katalog_057.jpg',
      'CVEĆE VENAC VE 1/1': 'assets/katalog_foto/katalog_059.jpg',
      'CVEĆE VENAC VE 1/2': 'assets/katalog_foto/katalog_060.jpg',
      'CVEĆE VENAC VE 1/3': 'assets/katalog_foto/katalog_061.jpg',
      'CVEĆE VENAC VE 2/1': 'assets/katalog_foto/katalog_062.jpg',
      'CVEĆE VENAC VE 2/2': 'assets/katalog_foto/katalog_063.jpg',
      'CVEĆE VENAC VE 3/1': 'assets/katalog_foto/katalog_064.jpg',
      'CVEĆE VENAC VE 3/2': 'assets/katalog_foto/katalog_065.jpg',
      'CVEĆE VENAC VE 3/3': 'assets/katalog_foto/katalog_066.jpg',
      'CVEĆE VENAC VE 3/4': 'assets/katalog_foto/katalog_067.jpg',
      'CVEĆE VENAC VE 3/5': 'assets/katalog_foto/katalog_068.jpg',
      'CVEĆE VENAC VE 3/6': 'assets/katalog_foto/katalog_069.jpg',
      'CVEĆE VENAC VE 3/7': 'assets/katalog_foto/katalog_070.jpg',
      'CVEĆE VENAC VE 3/8': 'assets/katalog_foto/katalog_071.jpg',
      'CVEĆE VENAC VE 3/9': 'assets/katalog_foto/katalog_072.jpg',
      'CVEĆE VENAC VE 3/10': 'assets/katalog_foto/katalog_073.jpg',
      'CVEĆE VENAC VE 4/1': 'assets/katalog_foto/katalog_074.jpg',
      'CVEĆE VENAC VE 4/2': 'assets/katalog_foto/katalog_075.jpg',
    };
    for (final entry in mapa.entries) {
      final bytes = await _ucitajAsset(entry.value);
      if (bytes != null) {
        await (update(katalogArtikli)..where((a) => a.naziv.equals(entry.key)))
            .write(KatalogArtikliCompanion(fotografija: Value(bytes)));
      }
    }
  }

  // ── Predefinisani predlošci dokumenata ───────────────────────────────────

  Future<void> _seedPredlosciDokumenata() async {
    final predlosci = [
      (
        naziv: 'BELEŽNICA',
        segmenti:
            '["PREMINULO_LICE","NARUCILAC","CEREMONIJA","PARTE","IRIU","FINANSIJE"]',
        napomene: true,
        zakljucan: true,
      ),
      (
        naziv: 'LISTA',
        segmenti: '["PREMINULO_LICE","NARUCILAC","IRIU","FINANSIJE"]',
        napomene: true,
        zakljucan: false,
      ),
      (
        naziv: 'NALOG ZA OPREMANJE',
        segmenti: '["NALOG_ZA_OPREMANJE"]',
        napomene: true,
        zakljucan: false,
      ),
      (
        naziv: 'SPECIFIKACIJA TROŠKOVA',
        segmenti: '["PREMINULO_LICE","NARUCILAC","IRIU","FINANSIJE"]',
        napomene: false,
        zakljucan: false,
      ),
      (
        naziv: 'PREDRAČUN',
        segmenti:
            '["PREMINULO_LICE","NARUCILAC","IRIU","FINANSIJE","UPUTSTVO_ZA_PLACANJE"]',
        napomene: false,
        zakljucan: false,
      ),
    ];

    for (final p in predlosci) {
      await into(predlosciDokumenata).insert(
        PredlosciDokumenataCompanion(
          naziv: Value(p.naziv),
          segmenti: Value(p.segmenti),
          predefinisan: const Value(true),
          napomeneUkljucene: Value(p.napomene),
          zakljucan: Value(p.zakljucan),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  // ── Helpers za korisnika ─────────────────────────────────────────────────

  Future<bool> hasKorisnika() async {
    final count = await (select(
      korisnici,
    )..where((k) => k.aktivan.equals(true))).get();
    return count.isNotEmpty;
  }

  Future<KorisniciData?> prijavaPin(String pinHash) {
    return (select(korisnici)
          ..where((k) => k.pinHash.equals(pinHash) & k.aktivan.equals(true)))
        .getSingleOrNull();
  }

  Future<KorisniciData?> prijavaKorisnikPin(int korisnikId, String pinHash) {
    return (select(korisnici)..where(
          (k) =>
              k.id.equals(korisnikId) &
              k.pinHash.equals(pinHash) &
              k.aktivan.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<bool> pinJedinstven(String pinHash, {int? izuzmiId}) async {
    final q = select(korisnici)
      ..where((k) {
        final match = k.pinHash.equals(pinHash) & k.aktivan.equals(true);
        return izuzmiId != null ? match & k.id.equals(izuzmiId).not() : match;
      });
    return (await q.get()).isEmpty;
  }

  Future<int> brojAktivnihAdministratora() async {
    final administratori =
        await (select(korisnici)..where(
              (k) => k.aktivan.equals(true) & k.uloga.equals('ADMINISTRATOR'),
            ))
            .get();
    return administratori.length;
  }

  Future<KorisnikReferenceSummary> korisnikReferenceSummary(
    int korisnikId,
  ) async {
    final brojPredmetaExpr = predmeti.id.count();
    final brojPredmeta =
        await (selectOnly(predmeti)
              ..addColumns([brojPredmetaExpr])
              ..where(predmeti.savetnikId.equals(korisnikId)))
            .map((row) => row.read(brojPredmetaExpr) ?? 0)
            .getSingle();

    final brojLogovaExpr = logIzmena.id.count();
    final brojLogova =
        await (selectOnly(logIzmena)
              ..addColumns([brojLogovaExpr])
              ..where(logIzmena.korisnikId.equals(korisnikId)))
            .map((row) => row.read(brojLogovaExpr) ?? 0)
            .getSingle();

    return KorisnikReferenceSummary(
      brojPredmeta: brojPredmeta,
      brojLogova: brojLogova,
    );
  }

  Future<bool> korisnikMustChangePin(int korisnikId) async {
    final row = await customSelect(
      '''
        SELECT must_change_pin
        FROM korisnici
        WHERE id = ?
      ''',
      variables: [Variable.withInt(korisnikId)],
      readsFrom: {korisnici},
    ).getSingleOrNull();
    return (row?.read<int>('must_change_pin') ?? 0) == 1;
  }

  Future<void> postaviKorisnikMustChangePin(
    int korisnikId, {
    required bool mustChangePin,
  }) {
    return customStatement(
      '''
        UPDATE korisnici
        SET must_change_pin = ?
        WHERE id = ?
      ''',
      [mustChangePin ? 1 : 0, korisnikId],
    );
  }

  Future<void> azurirajPinSecurityMetadata(
    int korisnikId, {
    required String pinUpdatedAt,
    String pinHashVersion = legacyPinHashVersion,
  }) {
    return customStatement(
      '''
        UPDATE korisnici
        SET pin_updated_at = ?, pin_hash_version = ?
        WHERE id = ?
      ''',
      [pinUpdatedAt, pinHashVersion, korisnikId],
    );
  }
}

class KorisnikReferenceSummary {
  const KorisnikReferenceSummary({
    required this.brojPredmeta,
    required this.brojLogova,
  });

  final int brojPredmeta;
  final int brojLogova;

  bool get imaVezanePodatke => brojPredmeta > 0 || brojLogova > 0;

  List<String> get blokirajuceReference {
    final reference = <String>[];
    if (brojPredmeta > 0) {
      reference.add('predmeti ($brojPredmeta)');
    }
    if (brojLogova > 0) {
      reference.add('log izmena ($brojLogova)');
    }
    return reference;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final migrationTestFile = await resolveMigrationTestDatabaseFile();
    if (migrationTestFile != null) {
      return NativeDatabase(migrationTestFile);
    }
    return driftDatabase(name: kDatabaseName);
  });
}
