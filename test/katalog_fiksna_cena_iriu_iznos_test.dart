import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/domain/iriu_catalog_selection.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_row_tile.dart';

import 'test_bootstrap.dart';

void main() {
  test('FIKSNA cena saves and reopens without a photo model', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = PodesavanjaRepository(db);

    await repo.azurirajKatalogStavku(
      IriuK.limeniUlozak,
      const IriuKatalogConfigCompanion(cena: Value(1250.5)),
    );
    final reopened = await (db.select(
      db.iriuKatalogConfig,
    )..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak))).getSingle();
    expect(reopened.cena, 1250.5);
    expect(
      await repo.getArtikliZaKategorijuLightweight(IriuK.limeniUlozak),
      isEmpty,
    );
  });

  test(
    'CRNINA correction is idempotent and preserves the stable identity',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final before = await (db.select(
        db.iriuKatalogConfig,
      )..where((row) => row.interniNaziv.equals(IriuK.crnina))).getSingle();
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.crnina)))
          .write(const IriuKatalogConfigCompanion(tip: Value('FIKSNA')));

      await db.repairKnownCatalogIntegrity();
      await db.repairKnownCatalogIntegrity();
      final rows = await (db.select(
        db.iriuKatalogConfig,
      )..where((row) => row.interniNaziv.equals(IriuK.crnina))).get();
      expect(rows, hasLength(1));
      expect(rows.single.interniNaziv, before.interniNaziv);
      expect(rows.single.tip, 'KATALOSKA');
    },
  );

  test('IRiU stores the applied price and computes KOM times CENA', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final i = IriuRepository(db);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion(
            brojPredmeta: const Value('PRICE-001'),
            datumKreiranja: Value(DateTime.now().toIso8601String()),
            savetnikId: const Value(1),
          ),
        );
    await (db.update(db.iriuKatalogConfig)
          ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
        .write(const IriuKatalogConfigCompanion(cena: Value(1250.5)));

    final rowId = await i.dodajStavku(
      predmetId: predmetId,
      interniNaziv: IriuK.limeniUlozak,
      nazivPrikaz: 'Sanduk',
      kom: '2',
    );
    var row = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    expect(row.cena, 1250.5);
    expect(row.iznos, 2501.0);

    await i.azurirajStavku(rowId, const IriuCompanion(iznos: Value(999.0)));
    row = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    expect(row.iznos, 999.0);
    expect(row.cena, 1250.5);
  });

  test('KATALOSKA article price is snapshotted into IRiU', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final i = IriuRepository(db);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion(
            brojPredmeta: const Value('PRICE-002'),
            datumKreiranja: Value(DateTime.now().toIso8601String()),
            savetnikId: const Value(1),
          ),
        );
    const stableId = 'TEST-CRNINA-001';
    await db
        .into(db.katalogArtikli)
        .insert(
          const KatalogArtikliCompanion(
            stableArticleId: Value(stableId),
            interniNazivKategorije: Value(IriuK.crnina),
            naziv: Value('Crni flor'),
            cena: Value(75.25),
          ),
        );
    final rowId = await i.dodajStavku(
      predmetId: predmetId,
      interniNaziv: IriuK.crnina,
      nazivPrikaz: 'Crni flor',
      katalogStableArticleId: stableId,
      kom: '3',
    );
    final row = await (db.select(
      db.iriu,
    )..where((r) => r.id.equals(rowId))).getSingle();
    expect(row.cena, 75.25);
    expect(row.iznos, 225.75);
  });

  test(
    'new price fields participate in existing Drift JSON round-trip',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final config =
          await (db.select(db.iriuKatalogConfig)
                ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
              .getSingle();
      final configJson = config.copyWith(cena: 99.5).toJson();
      expect(configJson['cena'], 99.5);
      expect(IriuKatalogConfigData.fromJson(configJson).cena, 99.5);
    },
  );

  test('FIKSNA picker remains a direct category selection', () {
    expect(resolveIriuCatalogPickerCategoryKeys(IriuK.limeniUlozak), [
      IriuK.limeniUlozak,
    ]);
    expect(resolveIriuCatalogPickerCategoryKeys(IriuK.crnina), [IriuK.crnina]);
  });

  test(
    'live concrete selection shares add/reselect semantics and snapshots',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = IriuRepository(db);
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion(
              brojPredmeta: const Value('LIVE-SELECTION-001'),
              datumKreiranja: Value(DateTime.now().toIso8601String()),
              savetnikId: const Value(1),
            ),
          );
      await db
          .into(db.katalogArtikli)
          .insert(
            const KatalogArtikliCompanion(
              stableArticleId: Value('CRNINA-FLOR-1'),
              interniNazivKategorije: Value(IriuK.crnina),
              naziv: Value('Flor'),
              cena: Value(100),
            ),
          );
      await db
          .into(db.katalogArtikli)
          .insert(
            const KatalogArtikliCompanion(
              stableArticleId: Value('CRNINA-ESARPA-1'),
              interniNazivKategorije: Value(IriuK.crnina),
              naziv: Value('Ešarpa'),
              cena: Value(120),
            ),
          );
      await db
          .into(db.katalogArtikli)
          .insert(
            const KatalogArtikliCompanion(
              stableArticleId: Value('SANDUK-1'),
              interniNazivKategorije: Value(IriuK.sanduk),
              naziv: Value('Sanduk A'),
              cena: Value(500),
            ),
          );

      final florId = await repo.dodajKatalogSelection(
        predmetId: predmetId,
        selection: const IriuCatalogSelection(
          interniNaziv: IriuK.crnina,
          nazivPrikaz: 'Flor',
          katalogStableArticleId: 'CRNINA-FLOR-1',
          cena: 100,
          kom: '2',
          iznos: 200,
        ),
      );
      var flor = await (db.select(
        db.iriu,
      )..where((r) => r.id.equals(florId))).getSingle();
      expect(flor.katalogStableArticleId, 'CRNINA-FLOR-1');
      expect(flor.nazivPrikaz, 'Flor');
      expect(flor.cena, 100);
      expect(flor.kom, '2');
      expect(flor.iznos, 200);

      await repo.azurirajKatalogSelection(
        row: flor,
        selection: const IriuCatalogSelection(
          interniNaziv: IriuK.crnina,
          nazivPrikaz: 'Ešarpa',
          katalogStableArticleId: 'CRNINA-ESARPA-1',
          cena: 120,
          kom: '3',
          iznos: 360,
        ),
      );
      flor = await (db.select(
        db.iriu,
      )..where((r) => r.id.equals(florId))).getSingle();
      expect(flor.katalogStableArticleId, 'CRNINA-ESARPA-1');
      expect(flor.nazivPrikaz, 'Ešarpa');
      expect(flor.cena, 120);
      expect(flor.kom, '3');
      expect(flor.iznos, 360);

      await repo.dodajKatalogSelection(
        predmetId: predmetId,
        selection: const IriuCatalogSelection(
          interniNaziv: IriuK.sanduk,
          nazivPrikaz: 'Sanduk A',
          katalogStableArticleId: 'SANDUK-1',
          cena: 500,
        ),
      );
      await (db.update(
        db.katalogArtikli,
      )..where((row) => row.stableArticleId.equals('CRNINA-ESARPA-1'))).write(
        const KatalogArtikliCompanion(
          naziv: Value('Ešarpa NOVA'),
          cena: Value(999),
        ),
      );
      final reopened = await (db.select(
        db.iriu,
      )..where((row) => row.id.equals(florId))).getSingle();
      expect(reopened.nazivPrikaz, 'Ešarpa');
      expect(reopened.cena, 120);
    },
  );
}
