import 'dart:convert';
import 'dart:js_interop';

import 'package:drift/drift.dart' show Value;
import 'package:drift/wasm.dart';
import 'package:flutter/widgets.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/predmet_iriu_order.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:web/web.dart' as web;

Future<AppDatabase> open(String databaseName) async {
  final result = await WasmDatabase.open(
    databaseName: databaseName,
    sqlite3Uri: Uri.base.resolve('sqlite3.wasm'),
    driftWorkerUri: Uri.base.resolve('drift_worker.dart.js'),
  );
  if (result.chosenImplementation == WasmStorageImplementation.inMemory) {
    await result.resolvedExecutor.close();
    throw StateError('Persistent WASM storage unavailable');
  }
  return AppDatabase.forTesting(result.resolvedExecutor);
}

Future<void> seedFirm(AppDatabase db, String pib) async {
  await db
      .into(db.firmaPodaci)
      .insertOnConflictUpdate(
        FirmaPodaciCompanion(
          id: const Value(1),
          pib: Value(pib),
          mb: const Value('0WEB-MB1'),
          naziv: const Value('Synthetic PWA FIRMA'),
        ),
      );
}

Future<void> produce() async {
  final db = await open('opc-compat-002-producer');
  try {
    await seedFirm(db, '00WEB-PIB1');
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('PWA-COMPAT-002'),
            datumKreiranja: const Value('2026-01-01'),
            avans: const Value(41.25),
            troskoviJkp: const Value(18.75),
            popust: const Value(4.5),
          ),
        );

    for (final key in ['qa-a', 'qa-b']) {
      final row = await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: id,
              interniNaziv: key,
              portableOccurrenceId: Value(key),
              iznos: const Value(125),
            ),
          );
      await db
          .into(db.iriuProvenance)
          .insert(
            IriuProvenanceCompanion.insert(
              iriuId: Value(row),
              origin: 'SCENARIO_PAKET',
              createdAt: '2026-01-01',
            ),
          );
    }
    await savePredmetIriuOrder(
      db,
      id,
      const PredmetIriuOrder(basic: ['SANDUK'], scenario: ['qa-b', 'qa-a']),
    );
    final backup = await serializeBackupJsonForTest(db: db);
    final response = await web.window
        .fetch(
          '/fixture.json'.toJS,
          web.RequestInit(method: 'POST', body: backup.toJS),
        )
        .toDart;
    if (!response.ok) {
      throw StateError('Synthetic fixture could not be captured');
    }
  } finally {
    await db.close();
  }
}

Future<void> restore(String expectedCode) async {
  final response = await web.window.fetch('/fixture.json'.toJS).toDart;
  if (!response.ok) throw StateError('Missing JSON fixture');
  final backupText = (await response.text().toDart).toDart;
  final backup = (jsonDecode(backupText) as Map).cast<String, dynamic>();
  const targetName = 'opc-compat-002-restore';
  final db = await open(targetName);
  try {
    await seedFirm(db, 'WRONG-FIRMA');
    var rejected = false;
    try {
      await importBackupJsonMapForTest(db: db, json: backup);
    } on Object {
      rejected = true;
    }
    if (!rejected ||
        (await db.select(db.firmaPodaci).getSingle()).pib != 'WRONG-FIRMA' ||
        (await db.select(db.predmeti).get()).isNotEmpty) {
      throw StateError('Backup crossed the FIRMA guard');
    }
    await seedFirm(db, '00WEB-PIB1');
    await importBackupJsonMapForTest(db: db, json: backup);
  } finally {
    await db.close();
  }
  final reopened = await open(targetName);
  try {
    final firm = await reopened.select(reopened.firmaPodaci).getSingle();
    final predmet = await reopened.select(reopened.predmeti).getSingle();
    final order = await readPredmetIriuOrder(reopened, predmet.id);
    final rows = await reopened.select(reopened.iriu).get();
    if (firm.pib != '00WEB-PIB1' ||
        firm.mb != '0WEB-MB1' ||
        predmet.brojPredmeta != 'PWA-COMPAT-002' ||
        predmet.avans != 41.25 ||
        predmet.troskoviJkp != 18.75 ||
        predmet.popust != 4.5 ||
        order?.basic.join(',') != 'SANDUK' ||
        order?.scenario.join(',') != 'qa-b,qa-a' ||
        rows.length != 2 ||
        rows.any((item) => item.predmetId != predmet.id || item.iznos != 125)) {
      throw StateError('Restored business graph differs');
    }
    if (expectedCode != 'RSD') {
      throw StateError('SRB supports the historical RSD contract only');
    }
  } finally {
    await reopened.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final args = Uri.base.queryParameters;
  try {
    if (args['mode'] == 'export') {
      await produce();
    } else {
      await restore(args['currency']!);
    }
    web.document.documentElement!.setAttribute(
      'data-opc-compat-result',
      'PASS',
    );
  } on Object catch (error, stack) {
    debugPrint('$error\n$stack');
    web.document.documentElement!.setAttribute(
      'data-opc-compat-result',
      'FAIL: $error',
    );
  }
  runApp(const SizedBox.shrink());
}
