import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/catalog/katalog_category_baseline.dart';

/// Explicit business-fixture setup for tests that exercise SCENARIO/KATALOG
/// persistence. Production test databases intentionally start empty; callers
/// opt into this fixture when their scenario contract requires catalog rows.
Future<void> seedScenarioCatalogForTest(AppDatabase db) async {
  for (final entry in KatalogCategoryBaseline.entries) {
    await db
        .into(db.iriuKatalogConfig)
        .insert(
          IriuKatalogConfigCompanion.insert(
            interniNaziv: entry.internalName,
            nazivPrikaz: entry.displayName,
            tip: Value(entry.type),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
  for (final entry in const [
    ('CITULJA_POLITIKA', 'Test citulja 1'),
    ('CITULJA_POLITIKA', 'Test citulja 2'),
  ]) {
    await db
        .into(db.katalogArtikli)
        .insert(
          KatalogArtikliCompanion.insert(
            stableArticleId: Value('TEST-${entry.$2.replaceAll(' ', '-')}'),
            interniNazivKategorije: entry.$1,
            naziv: entry.$2,
            cena: const Value(100),
          ),
        );
  }
}

bool _driftMultipleDatabaseWarningDisabled = false;

AppDatabase createTestDatabase() {
  if (!_driftMultipleDatabaseWarningDisabled) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    _driftMultipleDatabaseWarningDisabled = true;
  }
  return AppDatabase.forTesting(NativeDatabase.memory());
}

Widget wrapForTest(Widget child) {
  return MaterialApp(debugShowCheckedModeBanner: false, home: child);
}
