import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/json_transfer/predmet_json_transfer_core.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/stanje_robe/application/stanje_robe_lifecycle_service.dart';
import 'package:opc_v4/features/stanje_robe/data/stanje_robe_posledice_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('JSON transfer regression foundation', () {
    test('PREDMET JSON data keeps locked identity metadata', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final predmet = await _insertPredmet(
        db,
        brojPredmeta: 'JSON-001/2026',
        ime: 'Petar',
        prezime: 'Petrovic',
        businessScenarioId: 'default_funeral_ceremony_policy',
        sourceIdentity: 'local_opc',
        exportVerzija: 4,
      );

      final json = jsonDecode(jsonEncode(predmet.toJson()))
          as Map<String, dynamic>;

      expect(json['brojPredmeta'], 'JSON-001/2026');
      expect(json['businessScenarioId'], 'default_funeral_ceremony_policy');
      expect(json['sourceIdentity'], 'local_opc');
      expect(json['exportVerzija'], 4);
      expect(json['ime'], 'Petar');
      expect(json['prezime'], 'Petrovic');
    });

    test(
      'single-PREDMET import preserves unknown katalogStableArticleId '
      'without catalog relinking',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final template = await _insertPredmet(
          db,
          brojPredmeta: 'LOCAL-TEMPLATE/2026',
        );
        final importedPredmet = template.copyWith(
          id: 999,
          brojPredmeta: 'IMPORTED-001/2026',
          ime: 'Import',
          prezime: 'Predmet',
          exportVerzija: 7,
          sourceIdentity: 'imported_test_source',
        );
        const unknownStableId = 'unknown-stable-article-id';
        final importedIriu = _iriuFromJson(
          predmetId: importedPredmet.id,
          stableId: unknownStableId,
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Uvozni sanduk',
        );

        final newId = await PredmetiRepository(db)
            .uveziPredmetSaPovezanimPodacima(
          predmet: importedPredmet,
          iriu: [importedIriu],
          kontaktLica: const [],
        );

        final savedPredmet = await _getPredmet(db, newId);
        final savedIriu = await _getIriuForPredmet(db, newId);
        final unknownCatalogRows = await (db.select(db.katalogArtikli)
              ..where((k) => k.stableArticleId.equals(unknownStableId)))
            .get();

        expect(savedPredmet.id, isNot(importedPredmet.id));
        expect(savedPredmet.brojPredmeta, 'IMPORTED-001/2026');
        expect(savedPredmet.exportVerzija, 7);
        expect(savedPredmet.sourceIdentity, 'imported_test_source');
        expect(savedIriu, hasLength(1));
        expect(
          savedIriu.single.katalogStableArticleId,
          unknownStableId,
        );
        expect(savedIriu.single.predmetId, newId);
        expect(unknownCatalogRows, isEmpty);
      },
    );

    test(
      'replacement import keeps local PREDMET id and imported business state',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final local = await _insertPredmet(
          db,
          brojPredmeta: 'DUP-001/2026',
          ime: 'Lokalni',
          prezime: 'Predmet',
        );
        await _insertIriu(
          db,
          predmetId: local.id,
          stableId: 'local-stable-id',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Lokalni sanduk',
        );
        await db.into(db.kontaktLica).insert(
              KontaktLicaCompanion.insert(
                predmetId: local.id,
                blok: 'NARU_OPREMA',
                imePrezime: const Value('Lokalni kontakt'),
              ),
            );

        final replacementPredmet = local.copyWith(
          id: 5000,
          brojPredmeta: local.brojPredmeta,
          ime: 'Uvozni',
          prezime: 'Zamenjen',
          exportVerzija: 11,
          sourceIdentity: 'replacement_source',
        );
        final replacementIriu = _iriuFromJson(
          predmetId: replacementPredmet.id,
          stableId: 'replacement-stable-id',
          interniNaziv: 'OBELEZJE',
          nazivPrikaz: 'Uvozno obelezje',
        );
        final replacementContact = _kontaktFromJson(
          predmetId: replacementPredmet.id,
          imePrezime: 'Uvozni kontakt',
        );

        await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
          lokalniPredmetId: local.id,
          predmet: replacementPredmet,
          iriu: [replacementIriu],
          kontaktLica: [replacementContact],
        );

        final savedPredmeti = await db.select(db.predmeti).get();
        final savedPredmet = await _getPredmet(db, local.id);
        final savedIriu = await _getIriuForPredmet(db, local.id);
        final savedContacts = await _getContactsForPredmet(db, local.id);

        expect(savedPredmeti, hasLength(1));
        expect(savedPredmet.id, local.id);
        expect(savedPredmet.brojPredmeta, 'DUP-001/2026');
        expect(savedPredmet.ime, 'Uvozni');
        expect(savedPredmet.prezime, 'Zamenjen');
        expect(savedPredmet.exportVerzija, 11);
        expect(savedPredmet.sourceIdentity, 'replacement_source');
        expect(savedIriu, hasLength(1));
        expect(savedIriu.single.interniNaziv, 'OBELEZJE');
        expect(savedIriu.single.katalogStableArticleId, 'replacement-stable-id');
        expect(savedIriu.single.predmetId, local.id);
        expect(savedContacts, hasLength(1));
        expect(savedContacts.single.imePrezime, 'Uvozni kontakt');
      },
    );

    test(
      'old single-PREDMET JSON without stanjeRobeConsequenceTransfer imports',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'OLD-JSON-001/2026',
        );
        await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'old-json-stable',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Stari JSON sanduk',
        );

        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;

        expect(json.containsKey('stanjeRobeConsequenceTransfer'), isFalse);
        expect(json.containsKey('stanjeRobeOperativnoOmoguceno'), isFalse);

        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmeti = await targetDb.select(targetDb.predmeti).get();
        final importedIriu =
            await _getIriuForPredmet(targetDb, importedPredmeti.single.id);

        expect(importedPredmeti, hasLength(1));
        expect(importedPredmeti.single.brojPredmeta, 'OLD-JSON-001/2026');
        expect(importedIriu.single.katalogStableArticleId, 'old-json-stable');
      },
    );

    test(
      'candidate import normalization matches runtime legacy metadata defaults',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'LEGACY-METADATA-001/2026',
          ime: 'Legacy',
          prezime: 'Metadata',
          businessScenarioId: 'default_funeral_ceremony_policy',
          sourceIdentity: 'local_opc',
          exportVerzija: 12,
        );
        await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'legacy-metadata-stable',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Legacy sanduk',
        );

        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;
        json.remove('exportVerzija');
        final predmetMap = json['predmet'] as Map<String, dynamic>;
        predmetMap['id'] = 99999;
        predmetMap.remove('exportVerzija');
        predmetMap.remove('businessScenarioId');
        predmetMap.remove('sourceIdentity');
        predmetMap.remove('createdByKorisnikId');
        predmetMap.remove('lastBusinessModifiedByKorisnikId');
        predmetMap.remove('lastBusinessModifiedAt');

        final candidateDocument = PredmetJsonTransferCore.decode(
          jsonEncode(json),
        );
        final candidateNormalized =
            PredmetJsonTransferCore.normalizePredmetImportMap(
          predmet: candidateDocument.predmet,
          root: json,
        );

        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmeti = await targetDb.select(targetDb.predmeti).get();
        final importedPredmet = importedPredmeti.single;
        final importedIriu =
            await _getIriuForPredmet(targetDb, importedPredmet.id);

        expect(candidateDocument.brojPredmeta, 'LEGACY-METADATA-001/2026');
        expect(candidateNormalized['id'], 99999);
        expect(candidateNormalized['brojPredmeta'], importedPredmet.brojPredmeta);
        expect(candidateNormalized['exportVerzija'], importedPredmet.exportVerzija);
        expect(
          candidateNormalized['businessScenarioId'],
          importedPredmet.businessScenarioId,
        );
        expect(candidateNormalized['sourceIdentity'], importedPredmet.sourceIdentity);
        expect(
          candidateNormalized['createdByKorisnikId'],
          importedPredmet.createdByKorisnikId,
        );
        expect(
          candidateNormalized['lastBusinessModifiedByKorisnikId'],
          importedPredmet.lastBusinessModifiedByKorisnikId,
        );
        expect(
          candidateNormalized['lastBusinessModifiedAt'],
          importedPredmet.lastBusinessModifiedAt,
        );
        expect(importedPredmet.id, isNot(99999));
        expect(importedIriu.single.katalogStableArticleId,
            'legacy-metadata-stable');
      },
    );

    test(
      'candidate core reserializes current single-PREDMET export map',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          brojPredmeta: 'CANDIDATE-001/2026',
          ime: 'Milan',
          prezime: 'Milic',
          businessScenarioId: 'default_funeral_ceremony_policy',
          sourceIdentity: 'local_opc',
          exportVerzija: 3,
        );
        await _insertIriu(
          db,
          predmetId: predmet.id,
          stableId: 'candidate-stable-001',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Kandidat sanduk',
          iznos: 1200,
        );
        await db.into(db.kontaktLica).insert(
              KontaktLicaCompanion.insert(
                predmetId: predmet.id,
                blok: 'NARU_OPREMA',
                imePrezime: const Value('Kontakt kandidat'),
              ),
            );

        final runtimeJsonString = await serializePredmetJsonForTest(
          db: db,
          predmetId: predmet.id,
        );
        final runtimeMap = jsonDecode(runtimeJsonString) as Map<String, dynamic>;
        final candidateDocument =
            PredmetJsonTransferCore.decode(runtimeJsonString);
        final candidateMap = jsonDecode(
          PredmetJsonTransferCore.encode(candidateDocument),
        ) as Map<String, dynamic>;
        final encodedFromRuntimeMap = jsonDecode(
          PredmetJsonTransferCore.encodeMap(runtimeMap),
        ) as Map<String, dynamic>;

        expect(candidateDocument.brojPredmeta, 'CANDIDATE-001/2026');
        expect(candidateDocument.isCurrentPredmetFormat, isTrue);
        expect(candidateMap, runtimeMap);
        expect(encodedFromRuntimeMap, runtimeMap);
        _expectNoSinglePredmetStockOwnershipPayload(candidateMap);
        expect(
          candidateMap.containsKey('stanjeRobeConsequenceTransfer'),
          isFalse,
        );
        expect(candidateMap.containsKey('stanjeRobeStavke'), isFalse);
        expect(candidateMap.containsKey('stanjeRobeAppliedEffects'), isFalse);
      },
    );

    test(
      'legacy full backup without operational toggle imports with stock OFF',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        await _insertPredmet(sourceDb, brojPredmeta: 'LEGACY-FULL-001/2026');
        final json = await _backupJsonFromDb(sourceDb);
        final appPodesavanja =
            json['appPodesavanja'] as Map<String, dynamic>;
        appPodesavanja.remove('stanjeRobeOperativnoOmoguceno');

        await importBackupJsonMapForTest(db: targetDb, json: json);

        final importedAppPodesavanja =
            await _getAppPodesavanja(targetDb);
        final importedPredmeti = await targetDb.select(targetDb.predmeti).get();

        expect(importedPredmeti.single.brojPredmeta, 'LEGACY-FULL-001/2026');
        expect(
          importedAppPodesavanja.stanjeRobeOperativnoOmoguceno,
          isFalse,
        );
      },
    );

    test(
      'full backup preserves explicit operational toggle bool values',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        await _setOperationalToggle(sourceDb, true);
        final enabledJson = await _backupJsonFromDb(sourceDb);
        await importBackupJsonMapForTest(db: targetDb, json: enabledJson);

        expect(
          (await _getAppPodesavanja(targetDb))
              .stanjeRobeOperativnoOmoguceno,
          isTrue,
        );

        await _setOperationalToggle(sourceDb, false);
        final disabledJson = await _backupJsonFromDb(sourceDb);
        await importBackupJsonMapForTest(db: targetDb, json: disabledJson);

        expect(
          (await _getAppPodesavanja(targetDb))
              .stanjeRobeOperativnoOmoguceno,
          isFalse,
        );
      },
    );

    test(
      'full backup rejects invalid operational toggle value',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final json = await _backupJsonFromDb(sourceDb);
        final appPodesavanja =
            json['appPodesavanja'] as Map<String, dynamic>;
        appPodesavanja['stanjeRobeOperativnoOmoguceno'] = 'false';

        await expectLater(
          importBackupJsonMapForTest(db: targetDb, json: json),
          throwsA(anything),
        );
      },
    );

    test(
      'export with unresolved consequence emits safe transfer block',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          brojPredmeta: 'STOCK-JSON-001/2026',
        );
        final iriuId = await _insertIriu(
          db,
          predmetId: predmet.id,
          stableId: 'stock-stable-001',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Uvozni sanduk',
          iznos: 1200,
        );
        await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'stock-stable-001',
          kategorija: 'SANDUK',
          naziv: 'Uvozni sanduk',
          iznos: 1200,
        );

        final json = jsonDecode(
          await serializePredmetJsonForTest(db: db, predmetId: predmet.id),
        ) as Map<String, dynamic>;
        final block =
            json['stanjeRobeConsequenceTransfer'] as Map<String, dynamic>;
        final items = block['items'] as List<dynamic>;
        final item = items.single as Map<String, dynamic>;

        expect(json['schemaVersion'], 7);
        expect(block['schemaVersion'], 1);
        expect(block['policy'], 'single_predmet_unresolved_consequence_v1');
        expect(item['iriuTransferIndex'], 0);
        expect(item['kategorija'], 'SANDUK');
        expect(item['katalogStableArticleId'], 'stock-stable-001');
        expect(item['selectedNazivSnapshot'], 'Uvozni sanduk');
        expect(item['selectedIznosSnapshot'], 1200.0);
        expect(item['consequenceType'], 'INSUFFICIENT_STOCK');
        expect(item['status'], 'UNRESOLVED');
        expect(item['effectQuantity'], 1.0);
        expect(item.containsKey('id'), isFalse);
        expect(item.containsKey('predmetId'), isFalse);
        expect(item.containsKey('iriuId'), isFalse);
        expect(item.containsKey('availableQuantityAtCreation'), isFalse);
        expect(item.containsKey('shortageQuantityAtCreation'), isFalse);
      },
    );

    test(
      'candidate core reserializes current consequence transfer boundary',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          brojPredmeta: 'CANDIDATE-STOCK-001/2026',
        );
        final iriuId = await _insertIriu(
          db,
          predmetId: predmet.id,
          stableId: 'candidate-stock-stable-001',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Kandidat stock sanduk',
          iznos: 1500,
        );
        await _insertUnresolvedConsequence(
          db,
          predmetId: predmet.id,
          iriuId: iriuId,
          stableId: 'candidate-stock-stable-001',
          kategorija: 'SANDUK',
          naziv: 'Kandidat stock sanduk',
          iznos: 1500,
        );

        final runtimeJsonString = await serializePredmetJsonForTest(
          db: db,
          predmetId: predmet.id,
        );
        final runtimeMap = jsonDecode(runtimeJsonString) as Map<String, dynamic>;
        final candidateDocument =
            PredmetJsonTransferCore.decode(runtimeJsonString);
        final candidateMap = jsonDecode(
          PredmetJsonTransferCore.encode(candidateDocument),
        ) as Map<String, dynamic>;
        final encodedFromRuntimeMap = jsonDecode(
          PredmetJsonTransferCore.encodeMap(runtimeMap),
        ) as Map<String, dynamic>;
        final candidateBlock =
            candidateMap['stanjeRobeConsequenceTransfer']
                as Map<String, dynamic>;
        final candidateItem =
            (candidateBlock['items'] as List<dynamic>).single
                as Map<String, dynamic>;

        expect(candidateMap, runtimeMap);
        expect(encodedFromRuntimeMap, runtimeMap);
        expect(candidateDocument.consequenceTransfer?.items, hasLength(1));
        expect(candidateMap['schemaVersion'], 7);
        _expectNoSinglePredmetStockOwnershipPayload(candidateMap);
        expect(candidateItem['iriuTransferIndex'], 0);
        expect(candidateItem['katalogStableArticleId'],
            'candidate-stock-stable-001');
        for (final field in forbiddenStanjeRobeConsequenceTransferItemFields) {
          expect(candidateItem.containsKey(field), isFalse);
        }
        expect(candidateMap.containsKey('stanjeRobeStavke'), isFalse);
        expect(candidateMap.containsKey('stanjeRobeAppliedEffects'), isFalse);
      },
    );

    test(
      'covered stock availability helper uses active quantity without effects',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final service = StanjeRobeLifecycleService(db: db);

        expect(
          await service.hasSufficientStockForCoveredSelection(
            kategorija: 'SANDUK',
            stableArticleId: 'availability-helper-stable',
          ),
          isFalse,
        );

        await _insertStock(
          db,
          stableId: 'availability-helper-stable',
          quantity: 0,
        );

        expect(
          await service.hasSufficientStockForCoveredSelection(
            kategorija: 'SANDUK',
            stableArticleId: 'availability-helper-stable',
          ),
          isFalse,
        );

        await (db.update(db.stanjeRobeStavke)
              ..where(
                (s) => s.stableArticleId.equals('availability-helper-stable'),
              ))
            .write(
          const StanjeRobeStavkeCompanion(
            trenutnaKolicina: Value(1),
            aktivna: Value(false),
          ),
        );

        expect(
          await service.hasSufficientStockForCoveredSelection(
            kategorija: 'SANDUK',
            stableArticleId: 'availability-helper-stable',
          ),
          isFalse,
        );

        await (db.update(db.stanjeRobeStavke)
              ..where(
                (s) => s.stableArticleId.equals('availability-helper-stable'),
              ))
            .write(
          const StanjeRobeStavkeCompanion(
            aktivna: Value(true),
          ),
        );

        expect(
          await service.hasSufficientStockForCoveredSelection(
            kategorija: 'SANDUK',
            stableArticleId: 'availability-helper-stable',
          ),
          isTrue,
        );
        expect(await _getAppliedEffects(db), isEmpty);
      },
    );

    test(
      'import preserves unresolved consequence without mutating stock',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'STOCK-JSON-002/2026',
        );
        final sourceIriuId = await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'stock-stable-002',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Sanduk sa posledicom',
        );
        await _insertUnresolvedConsequence(
          sourceDb,
          predmetId: sourcePredmet.id,
          iriuId: sourceIriuId,
          stableId: 'stock-stable-002',
          kategorija: 'SANDUK',
          naziv: 'Sanduk sa posledicom',
        );
        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;

        await _insertStock(targetDb, stableId: 'stock-stable-002', quantity: 5);
        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmet = (await targetDb.select(targetDb.predmeti).get())
            .single;
        final consequences =
            await _getActiveConsequences(targetDb, importedPredmet.id);
        final stock = await _getStock(targetDb, 'stock-stable-002');
        final effects = await _getAppliedEffects(targetDb);

        expect(stock.trenutnaKolicina, 5);
        expect(consequences, hasLength(1));
        expect(consequences.single.katalogStableArticleId, 'stock-stable-002');
        expect(consequences.single.status, 'UNRESOLVED');
        expect(effects, isEmpty);
      },
    );

    test(
      'unknown katalogStableArticleId remains consequence metadata only',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'STOCK-JSON-003/2026',
        );
        final sourceIriuId = await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'unknown-stock-stable',
          interniNaziv: 'OBELEZJE',
          nazivPrikaz: 'Nepoznato obelezje',
        );
        await _insertUnresolvedConsequence(
          sourceDb,
          predmetId: sourcePredmet.id,
          iriuId: sourceIriuId,
          stableId: 'unknown-stock-stable',
          kategorija: 'OBELEZJE',
          naziv: 'Nepoznato obelezje',
        );
        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;

        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmet = (await targetDb.select(targetDb.predmeti).get())
            .single;
        final consequences =
            await _getActiveConsequences(targetDb, importedPredmet.id);
        final catalogRows = await (targetDb.select(targetDb.katalogArtikli)
              ..where(
                (k) => k.stableArticleId.equals('unknown-stock-stable'),
              ))
            .get();

        expect(consequences.single.katalogStableArticleId,
            'unknown-stock-stable');
        expect(catalogRows, isEmpty);
      },
    );

    test(
      'local stock sufficient does not auto-resolve or decrement on import',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'STOCK-JSON-004/2026',
        );
        final sourceIriuId = await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'stock-stable-004',
          interniNaziv: 'POKROV_GARNITURA',
          nazivPrikaz: 'Pokrov garnitura',
        );
        await _insertUnresolvedConsequence(
          sourceDb,
          predmetId: sourcePredmet.id,
          iriuId: sourceIriuId,
          stableId: 'stock-stable-004',
          kategorija: 'POKROV_GARNITURA',
          naziv: 'Pokrov garnitura',
        );
        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;

        await _insertStock(targetDb, stableId: 'stock-stable-004', quantity: 2);
        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmet = (await targetDb.select(targetDb.predmeti).get())
            .single;
        final consequences =
            await _getActiveConsequences(targetDb, importedPredmet.id);
        final stock = await _getStock(targetDb, 'stock-stable-004');

        expect(consequences.single.status, 'UNRESOLVED');
        expect(stock.trenutnaKolicina, 2);
      },
    );

    test(
      'local stock insufficient does not create duplicate applied effects',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final sourcePredmet = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'STOCK-JSON-005/2026',
        );
        final sourceIriuId = await _insertIriu(
          sourceDb,
          predmetId: sourcePredmet.id,
          stableId: 'stock-stable-005',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Nedostupan sanduk',
        );
        await _insertUnresolvedConsequence(
          sourceDb,
          predmetId: sourcePredmet.id,
          iriuId: sourceIriuId,
          stableId: 'stock-stable-005',
          kategorija: 'SANDUK',
          naziv: 'Nedostupan sanduk',
        );
        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: sourcePredmet.id,
          ),
        ) as Map<String, dynamic>;

        await _insertStock(targetDb, stableId: 'stock-stable-005', quantity: 0);
        await importPredmetJsonMapForTest(db: targetDb, json: json);

        final importedPredmet = (await targetDb.select(targetDb.predmeti).get())
            .single;
        final consequences =
            await _getActiveConsequences(targetDb, importedPredmet.id);
        final effects = await _getAppliedEffects(targetDb);

        expect(consequences, hasLength(1));
        expect(effects, isEmpty);
      },
    );

    test(
      'conflict replacement clears stale local consequences and imports incoming',
      () async {
        final sourceDb = createTestDatabase();
        final targetDb = createTestDatabase();
        addTearDown(sourceDb.close);
        addTearDown(targetDb.close);

        final local = await _insertPredmet(
          targetDb,
          brojPredmeta: 'DUP-STOCK-001/2026',
        );
        final localIriuId = await _insertIriu(
          targetDb,
          predmetId: local.id,
          stableId: 'local-stale-stable',
          interniNaziv: 'SANDUK',
          nazivPrikaz: 'Stari sanduk',
        );
        await _insertUnresolvedConsequence(
          targetDb,
          predmetId: local.id,
          iriuId: localIriuId,
          stableId: 'local-stale-stable',
          kategorija: 'SANDUK',
          naziv: 'Stari sanduk',
        );

        final incoming = await _insertPredmet(
          sourceDb,
          brojPredmeta: 'DUP-STOCK-001/2026',
        );
        final incomingIriuId = await _insertIriu(
          sourceDb,
          predmetId: incoming.id,
          stableId: 'incoming-stable',
          interniNaziv: 'OBELEZJE',
          nazivPrikaz: 'Uvozno obelezje',
        );
        await _insertUnresolvedConsequence(
          sourceDb,
          predmetId: incoming.id,
          iriuId: incomingIriuId,
          stableId: 'incoming-stable',
          kategorija: 'OBELEZJE',
          naziv: 'Uvozno obelezje',
        );
        final json = jsonDecode(
          await serializePredmetJsonForTest(
            db: sourceDb,
            predmetId: incoming.id,
          ),
        ) as Map<String, dynamic>;

        await importPredmetJsonMapForTest(
          db: targetDb,
          json: json,
          replaceLocalPredmetId: local.id,
        );

        final consequences = await _getActiveConsequences(targetDb, local.id);
        final iriu = await _getIriuForPredmet(targetDb, local.id);

        expect(iriu.single.katalogStableArticleId, 'incoming-stable');
        expect(consequences, hasLength(1));
        expect(consequences.single.katalogStableArticleId, 'incoming-stable');
        expect(consequences.single.kategorija, 'OBELEZJE');
      },
    );

    test('forbidden consequence inventory fields reject in candidate and runtime',
        () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);

      final sourcePredmet = await _insertPredmet(
        sourceDb,
        brojPredmeta: 'STOCK-JSON-008/2026',
      );
      final sourceIriuId = await _insertIriu(
        sourceDb,
        predmetId: sourcePredmet.id,
        stableId: 'stock-stable-008',
        interniNaziv: 'SANDUK',
        nazivPrikaz: 'Sanduk',
      );
      await _insertUnresolvedConsequence(
        sourceDb,
        predmetId: sourcePredmet.id,
        iriuId: sourceIriuId,
        stableId: 'stock-stable-008',
        kategorija: 'SANDUK',
        naziv: 'Sanduk',
      );
      final json = jsonDecode(
        await serializePredmetJsonForTest(
          db: sourceDb,
          predmetId: sourcePredmet.id,
        ),
      ) as Map<String, dynamic>;
      final block =
          json['stanjeRobeConsequenceTransfer'] as Map<String, dynamic>;
      final item = (block['items'] as List<dynamic>).single
          as Map<String, dynamic>;
      item['trenutnaKolicina'] = 10;

      expect(
        () => PredmetJsonTransferCore.decode(jsonEncode(json)),
        throwsA(isA<PredmetJsonTransferValidationException>()),
      );
      await expectLater(
        importPredmetJsonMapForTest(db: targetDb, json: json),
        throwsA(anything),
      );
      expect(await targetDb.select(targetDb.predmeti).get(), isEmpty);
    });

    test('invalid iriuTransferIndex blocks import', () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);

      final sourcePredmet = await _insertPredmet(
        sourceDb,
        brojPredmeta: 'STOCK-JSON-006/2026',
      );
      final sourceIriuId = await _insertIriu(
        sourceDb,
        predmetId: sourcePredmet.id,
        stableId: 'stock-stable-006',
        interniNaziv: 'SANDUK',
        nazivPrikaz: 'Sanduk',
      );
      await _insertUnresolvedConsequence(
        sourceDb,
        predmetId: sourcePredmet.id,
        iriuId: sourceIriuId,
        stableId: 'stock-stable-006',
        kategorija: 'SANDUK',
        naziv: 'Sanduk',
      );
      final json = jsonDecode(
        await serializePredmetJsonForTest(
          db: sourceDb,
          predmetId: sourcePredmet.id,
        ),
      ) as Map<String, dynamic>;
      final block =
          json['stanjeRobeConsequenceTransfer'] as Map<String, dynamic>;
      final item = (block['items'] as List<dynamic>).single
          as Map<String, dynamic>;
      item['iriuTransferIndex'] = 99;

      expect(
        () => PredmetJsonTransferCore.decode(jsonEncode(json)),
        throwsA(isA<PredmetJsonTransferValidationException>()),
      );
      await expectLater(
        importPredmetJsonMapForTest(db: targetDb, json: json),
        throwsA(anything),
      );
      expect(await targetDb.select(targetDb.predmeti).get(), isEmpty);
    });

    test('unsupported future consequence schema rejects safely', () async {
      final sourceDb = createTestDatabase();
      final targetDb = createTestDatabase();
      addTearDown(sourceDb.close);
      addTearDown(targetDb.close);

      final sourcePredmet = await _insertPredmet(
        sourceDb,
        brojPredmeta: 'STOCK-JSON-007/2026',
      );
      final sourceIriuId = await _insertIriu(
        sourceDb,
        predmetId: sourcePredmet.id,
        stableId: 'stock-stable-007',
        interniNaziv: 'SANDUK',
        nazivPrikaz: 'Sanduk',
      );
      await _insertUnresolvedConsequence(
        sourceDb,
        predmetId: sourcePredmet.id,
        iriuId: sourceIriuId,
        stableId: 'stock-stable-007',
        kategorija: 'SANDUK',
        naziv: 'Sanduk',
      );
      final json = jsonDecode(
        await serializePredmetJsonForTest(
          db: sourceDb,
          predmetId: sourcePredmet.id,
        ),
      ) as Map<String, dynamic>;
      final block =
          json['stanjeRobeConsequenceTransfer'] as Map<String, dynamic>;
      block['schemaVersion'] = 2;

      expect(
        () => PredmetJsonTransferCore.decode(jsonEncode(json)),
        throwsA(isA<PredmetJsonTransferValidationException>()),
      );
      await expectLater(
        importPredmetJsonMapForTest(db: targetDb, json: json),
        throwsA(anything),
      );
      expect(await targetDb.select(targetDb.predmeti).get(), isEmpty);
    });
  });
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  required String brojPredmeta,
  String ime = '',
  String prezime = '',
  String businessScenarioId = 'default_funeral_ceremony_policy',
  String sourceIdentity = 'local_opc',
  int exportVerzija = 0,
}) async {
  final id = await db.into(db.predmeti).insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(brojPredmeta),
          datumKreiranja: const Value('2026-05-17T08:00:00.000'),
          ime: Value(ime),
          prezime: Value(prezime),
          businessScenarioId: Value(businessScenarioId),
          sourceIdentity: Value(sourceIdentity),
          exportVerzija: Value(exportVerzija),
        ),
      );
  return _getPredmet(db, id);
}

Future<int> _insertIriu(
  AppDatabase db, {
  required int predmetId,
  required String stableId,
  required String interniNaziv,
  required String nazivPrikaz,
  double iznos = 0.0,
}) {
  return db.into(db.iriu).insert(
        IriuCompanion.insert(
          predmetId: predmetId,
          katalogStableArticleId: Value(stableId),
          interniNaziv: interniNaziv,
          nazivPrikaz: Value(nazivPrikaz),
          kom: const Value('1'),
          iznos: Value(iznos),
          redosled: const Value(0),
        ),
      );
}

Future<void> _insertUnresolvedConsequence(
  AppDatabase db, {
  required int predmetId,
  required int iriuId,
  required String stableId,
  required String kategorija,
  required String naziv,
  double iznos = 0.0,
}) async {
  await StanjeRobePoslediceRepository(db).createOrUpdateUnresolved(
    predmetId: predmetId,
    iriuId: iriuId,
    kategorija: kategorija,
    katalogStableArticleId: stableId,
    selectedNazivSnapshot: naziv,
    selectedIznosSnapshot: iznos,
    sourceLifecycleEvent: stanjeRobePosledicaEventFirstSelection,
    effectQuantity: 1.0,
    availableQuantityAtCreation: 0,
    shortageQuantityAtCreation: 1,
  );
}

Future<void> _insertStock(
  AppDatabase db, {
  required String stableId,
  required double quantity,
}) {
  return db.into(db.stanjeRobeStavke).insert(
        StanjeRobeStavkeCompanion.insert(
          stableArticleId: stableId,
          trenutnaKolicina: Value(quantity),
          minimalnaKolicina: const Value(0),
          aktivna: const Value(true),
          datumKreiranja: const Value('2026-05-17T08:00:00.000'),
          datumAzuriranja: const Value('2026-05-17T08:00:00.000'),
        ),
      );
}

Future<StanjeRobeStavkeData> _getStock(
  AppDatabase db,
  String stableId,
) {
  return (db.select(db.stanjeRobeStavke)
        ..where((s) => s.stableArticleId.equals(stableId)))
      .getSingle();
}

Future<List<StanjeRobeAppliedEffect>> _getAppliedEffects(AppDatabase db) {
  return db.select(db.stanjeRobeAppliedEffects).get();
}

Future<List<StanjeRobePoslediceData>> _getActiveConsequences(
  AppDatabase db,
  int predmetId,
) {
  return StanjeRobePoslediceRepository(db)
      .listActiveUnresolvedForPredmet(predmetId);
}

IriuData _iriuFromJson({
  required int predmetId,
  required String stableId,
  required String interniNaziv,
  required String nazivPrikaz,
}) {
  return IriuData.fromJson(<String, dynamic>{
    'id': 8000,
    'predmetId': predmetId,
    'katalogStableArticleId': stableId,
    'interniNaziv': interniNaziv,
    'nazivPrikaz': nazivPrikaz,
    'kom': '1',
    'iznos': 0.0,
    'cekiran': false,
    'redosled': 0,
  });
}

KontaktLicaData _kontaktFromJson({
  required int predmetId,
  required String imePrezime,
}) {
  return KontaktLicaData.fromJson(<String, dynamic>{
    'id': 9000,
    'predmetId': predmetId,
    'blok': 'NARU_OPREMA',
    'imePrezime': imePrezime,
    'telefon': '',
    'email': '',
    'napomena': '',
    'redosled': 0,
  });
}

Future<PredmetiData> _getPredmet(AppDatabase db, int id) {
  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}

Future<List<IriuData>> _getIriuForPredmet(AppDatabase db, int predmetId) {
  return (db.select(db.iriu)..where((i) => i.predmetId.equals(predmetId)))
      .get();
}

Future<List<KontaktLicaData>> _getContactsForPredmet(
  AppDatabase db,
  int predmetId,
) {
  return (db.select(db.kontaktLica)
        ..where((k) => k.predmetId.equals(predmetId)))
      .get();
}

Future<Map<String, dynamic>> _backupJsonFromDb(AppDatabase db) async {
  return jsonDecode(await serializeBackupJsonForTest(db: db))
      as Map<String, dynamic>;
}

Future<AppPodesavanjaData> _getAppPodesavanja(AppDatabase db) {
  return (db.select(db.appPodesavanja)..where((p) => p.id.equals(1)))
      .getSingle();
}

Future<void> _setOperationalToggle(AppDatabase db, bool enabled) {
  return (db.update(db.appPodesavanja)..where((p) => p.id.equals(1))).write(
    AppPodesavanjaCompanion(
      stanjeRobeOperativnoOmoguceno: Value(enabled),
    ),
  );
}

void _expectNoSinglePredmetStockOwnershipPayload(Map<String, dynamic> json) {
  expect(json.containsKey('stanjeRobeStavke'), isFalse);
  expect(json.containsKey('stanjeRobeAppliedEffects'), isFalse);
  expect(json.containsKey('stanjeRobePosledice'), isFalse);
  expect(json.containsKey('stanjeRobeOperativnoOmoguceno'), isFalse);

  final block = json['stanjeRobeConsequenceTransfer'];
  if (block is! Map) return;
  final items = block['items'];
  if (items is! List) return;

  for (final rawItem in items) {
    final item = rawItem as Map<String, dynamic>;
    for (final field in forbiddenStanjeRobeConsequenceTransferItemFields) {
      expect(item.containsKey(field), isFalse);
    }
  }
}
