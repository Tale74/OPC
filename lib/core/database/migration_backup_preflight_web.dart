import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../config/app_config.dart';
import 'predmet_iriu_order.dart' show predmetIriuOrderCreateSql;

Future<void> ensureMigrationBackupBeforeOpen({
  Object? databaseFile,
  Object? backupDirectory,
  int targetVersion = 37,
}) => ensureOrderUpgradeBackup(
  databaseName: kDatabaseName,
  targetVersion: targetVersion,
);

/// Only the single additive order-table upgrade is supported on the web.
Future<String?> ensureOrderUpgradeBackup({
  required String databaseName,
  required int targetVersion,
}) async {
  final sqliteUri = Uri.base.resolve('sqlite3.wasm');
  final workerUri = Uri.base.resolve('drift_worker.dart.js');
  final result = await WasmDatabase.open(
    databaseName: databaseName,
    sqlite3Uri: sqliteUri,
    driftWorkerUri: workerUri,
    enableMigrations: false,
  );
  final connection = result.resolvedExecutor;
  const reader = _InspectionOnlyUser();
  try {
    await connection.ensureOpen(reader);
    final version = await _version(connection);
    if (version == 0 || version == targetVersion) return null;
    final storage = result.chosenImplementation.storageApi;
    if (version != 36 || targetVersion != 37 || storage == null ||
        result.chosenImplementation ==
            WasmStorageImplementation.unsafeIndexedDb) {
      throw StateError('Web baza zahteva proverenu kopiju pre nadogradnje.');
    }

    final probe = await WasmDatabase.probe(
      databaseName: databaseName,
      sqlite3Uri: sqliteUri,
      driftWorkerUri: workerUri,
    );
    final transaction = connection.beginTransaction();
    try {
      await transaction.ensureOpen(reader);
      if (await _version(transaction) != version) {
        throw StateError('Web baza je promenjena. Pokrenite aplikaciju ponovo.');
      }
      final original = await _fingerprint(transaction);
      final bytes = await probe.exportDatabase((storage, databaseName));
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Kopija Web baze nije dostupna.');
      }
      final backupName = '$databaseName-pre-order-v$version-'
          '${DateTime.now().microsecondsSinceEpoch}';
      final backup = await probe.open(
        result.chosenImplementation,
        backupName,
        initializeDatabase: () => bytes,
        enableMigrations: false,
      );
      try {
        await backup.ensureOpen(reader);
      } finally {
        await backup.close();
      }
      final restored = await probe.open(
        result.chosenImplementation, backupName, enableMigrations: false,
      );
      try {
        await restored.ensureOpen(reader);
        if (await _version(restored) != version ||
            await _fingerprint(restored) != original) {
          throw StateError('Trajna kopija Web baze ne odgovara izvoru.');
        }
      } finally {
        await restored.close();
      }

      // The read snapshot remains open until the additive DDL commits. SQLite
      // discards this transaction if the snapshot can no longer become a writer.
      await transaction.runCustom(predmetIriuOrderCreateSql, const []);
      await transaction.runCustom('PRAGMA user_version = $targetVersion', const []);
      await transaction.send();
      return backupName;
    } on Object {
      await transaction.rollback();
      rethrow;
    }
  } finally {
    await connection.close();
  }
}

Future<int> _version(QueryExecutor db) async =>
    (await db.runSelect('PRAGMA user_version', const []))
        .single['user_version'] as int;

Future<String> _fingerprint(QueryExecutor db) async {
  final integrity = await db.runSelect('PRAGMA integrity_check', const []);
  if (integrity.length != 1 || integrity.single.values.single != 'ok') {
    throw StateError('Web baza nije prošla SQLite integrity_check.');
  }
  final schema = await db.runSelect(
    'SELECT type, name, tbl_name, sql FROM sqlite_master ORDER BY type, name',
    const [],
  );
  final parts = <Object?>[schema];
  for (final table in schema.where((row) => row['type'] == 'table')) {
    final escaped = (table['name'] as String).replaceAll('"', '""');
    final rows = await db.runSelect('SELECT * FROM "$escaped"', const []);
    final encoded = rows.map(jsonEncode).toList()..sort();
    parts.add(sha256.convert(utf8.encode(jsonEncode(encoded))).toString());
  }
  return sha256.convert(utf8.encode(jsonEncode(parts))).toString();
}

class _InspectionOnlyUser implements QueryExecutorUser {
  const _InspectionOnlyUser();

  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}
