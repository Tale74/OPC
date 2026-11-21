import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/wasm.dart';
import 'package:flutter/material.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/migration_backup_preflight_web.dart';
import 'package:opc_v4/core/database/predmet_iriu_order.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';

Future<AppDatabase> _open(String name) async {
  final result = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: Uri.base.resolve('sqlite3.wasm'),
    driftWorkerUri: Uri.base.resolve('drift_worker.dart.js'),
  );
  if (result.chosenImplementation == WasmStorageImplementation.inMemory) {
    await result.resolvedExecutor.close();
    throw StateError('PWA probe requires persistent browser storage');
  }
  return AppDatabase.forTesting(result.resolvedExecutor);
}

Future<void> _seedFirma(AppDatabase db) async {
  final firma = await db.select(db.firmaPodaci).getSingle();
  await (db.update(db.firmaPodaci)..where((row) => row.id.equals(firma.id)))
      .write(const FirmaPodaciCompanion(
        pib: Value('111111111'),
        mb: Value('10000001'),
      ));
}

Future<void> _restoreProbe() async {
  final nonce = DateTime.now().microsecondsSinceEpoch;
  final sourceName = 'opc-qa-order-source-$nonce';
  final restoreName = 'opc-qa-order-restore-$nonce';
  final source = await _open(sourceName);
  late String backup;
  try {
    await _seedFirma(source);
    final predmetId = await source.into(source.predmeti).insert(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('OPC-PWA-SYNTHETIC/2026'),
        datumKreiranja: const Value('2026-11-20T10:00:00Z'),
      ),
    );
    await source.into(source.iriu).insert(
      IriuCompanion.insert(
        predmetId: predmetId,
        interniNaziv: 'CARGO_TROSKOVI',
        nazivPrikaz: const Value('Sintetička stavka'),
        iznos: const Value(725),
        redosled: const Value(4),
      ),
    );
    await source.customStatement('DROP TABLE predmet_iriu_order');
    await source.customStatement('PRAGMA user_version = 36');
  } finally {
    await source.close();
  }

  final snapshotName = await ensureOrderUpgradeBackup(
    databaseName: sourceName, targetVersion: 37,
  );
  if (snapshotName == null) throw StateError('Missing durable migration backup');

  final migrated = await _open(sourceName);
  try {
    final version = await migrated.customSelect('PRAGMA user_version').getSingle();
    if (version.read<int>('user_version') != 37) {
      throw StateError('Migration did not update the schema version');
    }
    final predmet = await migrated.select(migrated.predmeti).getSingle();
    await savePredmetIriuOrder(
      migrated, predmet.id, const PredmetIriuOrder(basic: ['SANDUK']),
    );
    backup = await serializeBackupJsonForTest(db: migrated);
  } finally {
    await migrated.close();
  }

  final destination = await _open(restoreName);
  try {
    await _seedFirma(destination);
    await importBackupJsonMapForTest(
      db: destination,
      json: (jsonDecode(backup) as Map).cast<String, dynamic>(),
    );
  } finally {
    await destination.close();
  }

  final reopened = await _open(restoreName);
  try {
    final predmet = await reopened.select(reopened.predmeti).getSingle();
    final row = await reopened.select(reopened.iriu).getSingle();
    if (predmet.brojPredmeta != 'OPC-PWA-SYNTHETIC/2026' ||
        row.predmetId != predmet.id ||
        row.iznos != 725 ||
        row.redosled != 4 ||
        (await readPredmetIriuOrder(reopened, predmet.id))?.basic.single != 'SANDUK') {
      throw StateError('Restored business data does not match the source');
    }
  } finally {
    await reopened.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String result;
  try {
    await _restoreProbe();
    result = 'OPC_PWA_BACKUP_RESTORE_PASS';
  } on Object catch (error, stack) {
    debugPrintStack(label: error.toString(), stackTrace: stack);
    result = 'OPC_PWA_BACKUP_RESTORE_FAIL: $error';
  }
  runApp(MaterialApp(home: Scaffold(body: Center(child: Text(result)))));
}
