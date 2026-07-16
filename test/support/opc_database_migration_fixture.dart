import 'dart:io';

import 'package:drift/native.dart';
import 'package:opc_v4/core/database/database.dart';

typedef RawFixtureMutation = void Function(dynamic database);

final class OpcDatabaseMigrationFixture {
  OpcDatabaseMigrationFixture._(this.root, this.databaseFile);

  final Directory root;
  final File databaseFile;

  static Future<File> createPopulatedCurrentTemplate(Directory root) async {
    final file = File(
      '${root.path}${Platform.pathSeparator}opc_schema_21_template.sqlite',
    );
    final database = AppDatabase.forTesting(NativeDatabase(file));
    await database.customSelect('SELECT 1').get();
    await database.customStatement(
      "UPDATE firma_podaci SET naziv = 'SYNTHETIC MIGRATION FIRMA' WHERE id = 1",
    );
    await database.customStatement('''
      INSERT INTO korisnici (
        ime_prezime, uloga, pin_hash, aktivan, datum_kreiranja
      ) VALUES (
        'SYNTHETIC ADMIN', 'ADMINISTRATOR', 'synthetic_hash', 1,
        '2026-01-01T00:00:00.000'
      )
    ''');
    await database.customStatement('''
      INSERT INTO predmeti (
        broj_predmeta, datum_kreiranja, ime, prezime, status,
        docek_datum, parte_potrebna
      ) VALUES (
        'SYNTHETIC-001', '2026-01-02T00:00:00.000',
        'SYNTHETIC', 'PREDMET', 'OTVOREN', '2026-01-03', 1
      )
    ''');
    await database.customStatement('''
      INSERT INTO kontakt_lica (
        predmet_id, blok, ime_prezime, telefon, email, napomena, redosled
      ) VALUES (1, 'NARU_OPREMA', 'SYNTHETIC CONTACT', '', '', '', 1)
    ''');
    await database.customStatement('''
      INSERT INTO iriu (
        predmet_id, katalog_stable_article_id, interni_naziv,
        naziv_prikaz, kom, iznos, cekiran, redosled
      ) VALUES (
        1, 'synthetic-article', 'SANDUK', 'SYNTHETIC ITEM',
        '1', 125.5, 1, 1
      )
    ''');
    await database.customStatement('''
      INSERT OR REPLACE INTO ceremony_reminder_settings (
        predmet_id, enabled, frequency_hours, delivery_times,
        scheduled_notification_ids, updated_at
      ) VALUES (1, 1, 24, '["09:00"]', '[]', '2026-01-02')
    ''');
    await database.customStatement('''
      INSERT INTO stanje_robe_stavke (
        stable_article_id, trenutna_kolicina, minimalna_kolicina,
        aktivna, datum_kreiranja, datum_azuriranja
      ) VALUES ('synthetic-article', 10.0, 2.0, 1, '2026-01-01', '2026-01-01')
    ''');
    await database.customStatement('''
      INSERT INTO stanje_robe_applied_effects (
        predmet_id, iriu_id, kategorija, stable_article_id,
        effect_quantity, effect_status, effect_reason,
        datum_kreiranja, datum_azuriranja
      ) VALUES (
        1, 1, 'SANDUK', 'synthetic-article', 1.0, 'APPLIED',
        'synthetic', '2026-01-02', '2026-01-02'
      )
    ''');
    await database.customStatement('''
      INSERT INTO stanje_robe_posledice (
        predmet_id, iriu_id, kategorija, katalog_stable_article_id,
        selected_naziv_snapshot, selected_iznos_snapshot, consequence_type,
        status, created_at, updated_at, source_lifecycle_event, effect_quantity
      ) VALUES (
        1, 1, 'SANDUK', 'synthetic-article', 'SYNTHETIC ITEM', 125.5,
        'STOCK_EFFECT', 'UNRESOLVED', '2026-01-02', '2026-01-02',
        'SYNTHETIC_TEST', 1.0
      )
    ''');
    await database.customStatement('''
      INSERT INTO parte_predlosci (
        id, firma_id, naziv, schema_version, config_json, created_at, updated_at
      ) VALUES (
        'synthetic-template', 1, 'SYNTHETIC TEMPLATE', 1, '{}',
        '2026-01-02', '2026-01-02'
      )
    ''');
    await database.customStatement('''
      INSERT INTO parte_pripreme (
        predmet_id, predmet_broj, status, created_at, updated_at,
        source_fingerprint, template_id, template_snapshot_json, draft_json
      ) VALUES (
        1, 'SYNTHETIC-001', 'IN_PROGRESS', '2026-01-02', '2026-01-02',
        'synthetic-fingerprint', 'synthetic-template', '{}', '{}'
      )
    ''');
    await database.close();
    return file;
  }

  static Future<OpcDatabaseMigrationFixture> copyFromTemplate({
    required File template,
    required String name,
  }) async {
    final root = await Directory.systemTemp.createTemp('opc_migration_$name');
    final file = File('${root.path}${Platform.pathSeparator}opc_$name.sqlite');
    await template.copy(file.path);
    return OpcDatabaseMigrationFixture._(root, file);
  }

  AppDatabase openAtVersion(
    int userVersion, {
    int? physicalVersion,
    RawFixtureMutation? mutateBeforeOpen,
  }) {
    return AppDatabase.forTesting(
      NativeDatabase(
        databaseFile,
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA foreign_keys = OFF');
          _downgradePhysicalSchema(rawDatabase, physicalVersion ?? userVersion);
          mutateBeforeOpen?.call(rawDatabase);
          rawDatabase.execute('PRAGMA user_version = $userVersion');
        },
      ),
    );
  }

  Future<void> dispose() async {
    if (await root.exists()) await root.delete(recursive: true);
  }

  static void _downgradePhysicalSchema(dynamic db, int version) {
    for (final index in const [
      'idx_katalog_artikli_stable_article_id',
      'idx_stanje_robe_stavke_stable_article_id',
      'idx_stanje_robe_applied_effects_predmet',
      'idx_stanje_robe_applied_effects_selection',
      'idx_stanje_robe_applied_effects_article_status',
      'idx_stanje_robe_applied_effects_current_selection',
      'idx_stanje_robe_posledice_predmet',
      'idx_stanje_robe_posledice_iriu',
      'idx_stanje_robe_posledice_predmet_iriu',
      'idx_stanje_robe_posledice_predmet_status',
      'idx_stanje_robe_posledice_active_row',
    ]) {
      db.execute('DROP INDEX IF EXISTS $index');
    }

    if (version < 21) {
      db.execute('DROP TABLE IF EXISTS parte_pripreme');
      db.execute('DROP TABLE IF EXISTS parte_predlosci');
      _dropColumn(db, 'predmeti', 'parte_potrebna');
      _dropColumn(db, 'firma_podaci', 'parte_default_template_id');
    }
    if (version < 20) _dropColumn(db, 'predmeti', 'docek_datum');
    if (version < 19) {
      _dropColumn(db, 'ceremony_reminder_settings', 'delivery_times');
    }
    if (version < 18) {
      db.execute('DROP TABLE IF EXISTS ceremony_reminder_settings');
    }
    if (version < 17) {
      _dropColumn(db, 'app_podesavanja', 'stanje_robe_operativno_omoguceno');
    }
    if (version < 16) db.execute('DROP TABLE IF EXISTS stanje_robe_posledice');
    if (version < 15) {
      db.execute('DROP TABLE IF EXISTS stanje_robe_applied_effects');
    }
    if (version < 14) db.execute('DROP TABLE IF EXISTS stanje_robe_stavke');
    if (version < 13) _dropColumn(db, 'iriu', 'katalog_stable_article_id');
    if (version < 12) {
      _dropColumn(db, 'katalog_artikli', 'stable_article_id');
    }
    if (version < 11) {
      for (final column in const [
        'business_scenario_id',
        'source_identity',
        'created_by_korisnik_id',
        'last_business_modified_by_korisnik_id',
        'last_business_modified_at',
      ]) {
        _dropColumn(db, 'predmeti', column);
      }
    }
    if (version < 10) {
      db.execute('DROP TABLE IF EXISTS auth_audit_log');
      db.execute('DROP TABLE IF EXISTS security_settings');
      _dropColumn(db, 'korisnici', 'must_change_pin');
      _dropColumn(db, 'korisnici', 'pin_updated_at');
      _dropColumn(db, 'korisnici', 'pin_hash_version');
    }
    if (version < 9) {
      _dropColumn(db, 'app_podesavanja', 'qr_primalac_naziv');
      _dropColumn(db, 'app_podesavanja', 'qr_sifra_placanja');
      _dropColumn(db, 'app_podesavanja', 'qr_svrha_placanja');
    }
    if (version < 8) {
      db.execute('DROP TABLE IF EXISTS iriu_lifecycle_decisions');
    }
    if (version < 7) _dropColumn(db, 'predmeti', 'uzrok_smrti');
    if (version < 6) _dropColumn(db, 'predmeti', 'export_verzija');
    if (version < 5) {
      _dropColumn(db, 'predlosci_dokumenata', 'zakljucan');
    }
    if (version < 3) {
      _dropColumn(db, 'katalog_artikli', 'fotografija_path');
    }
    if (version < 2) {
      for (final column in const [
        'radni_status',
        'naru_ime',
        'naru_prezime',
        'jkp_ime',
        'jkp_prezime',
      ]) {
        _dropColumn(db, 'predmeti', column);
      }
      _dropColumn(db, 'app_podesavanja', 'refundacija_pio_iznos');
    }
  }

  static void _dropColumn(dynamic db, String table, String column) {
    final columns =
        db.select('PRAGMA table_info("$table")') as Iterable<dynamic>;
    var exists = false;
    for (final dynamic row in columns) {
      final String name = row['name'] as String;
      if (name == column) exists = true;
    }
    if (exists) {
      db.execute('ALTER TABLE "$table" DROP COLUMN "$column"');
    }
  }
}
