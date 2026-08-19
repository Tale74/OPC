import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/core/database/database.dart';

/// Explicit business-fixture setup for tests that exercise SCENARIO/KATALOG
/// persistence. Production test databases intentionally start empty; callers
/// opt into this fixture when their scenario contract requires catalog rows.
Future<void> seedScenarioCatalogForTest(AppDatabase db) async {
  const fixedCategories = <String>[
    'SANDUK',
    'POKROV_GARNITURA',
    'OBELEZJE',
    'PESKIR_ZA_KRST',
    'POSMRTNE_PARTE',
    'HLADNJACA',
    'SPREMANJE_POKOJNIKA',
    'IZNOSENJE',
    'PREVOZ_DO_HLADNJACE',
    'PREVOZ_DO_GROBLJA',
    'PREVOZ_SPROVODA',
    'CRNINA',
    'LIMENI_ULOZAK',
    'LEMOVANJE',
    'AGENCIJSKE_USLUGE',
    'TRANSPORTNA_VRECA',
    'CVECE',
    'KOMPLET_ZA_OPELO',
    'CITULJA_POLITIKA',
    'CITULJA_NOVOSTI',
    'SLIKA',
    'ZASTITNA_I_DODATNA_OPREMA',
    'MEDJUNARODNI_PREVOZ',
    'MEDJUNARODNA_DOKUMENTACIJA',
    'BALSAMOVANJE',
    'CARGO_TROSKOVI',
    'DORADA_POGREBNE_OPREME',
    'KUCANJE_OBELEZJA',
    'SLOVA_I_BROJEVI',
  ];
  for (final category in fixedCategories) {
    await db
        .into(db.iriuKatalogConfig)
        .insert(
          IriuKatalogConfigCompanion.insert(
            interniNaziv: category,
            nazivPrikaz: switch (category) {
              'CITULJA_POLITIKA' => 'Čitulja Politika',
              'LIMENI_ULOZAK' => 'Limeni uložak',
              'ZASTITNA_I_DODATNA_OPREMA' => 'Zaštitna i dodatna oprema',
              _ => category,
            },
            tip: Value(
              {
                    'SANDUK',
                    'POKROV_GARNITURA',
                    'OBELEZJE',
                    'CRNINA',
                    'CVECE',
                    'KOMPLET_ZA_OPELO',
                    'CITULJA_POLITIKA',
                    'CITULJA_NOVOSTI',
                    'SLIKA',
                  }.contains(category)
                  ? 'KATALOSKA'
                  : 'FIKSNA',
            ),
            osnovnaUSvakomPredmetu: Value(category == 'CVECE'),
          ),
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
