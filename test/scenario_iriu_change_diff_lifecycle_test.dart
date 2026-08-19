import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'A to B preview is no-mutation and confirmed additions snapshot FIKSNA price',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(predmetRepository, predmetId, burialPlace: 'GROB');
      await scenarioRepository.ensureModuleAndDefaults();
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final first = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(first.scenarioSnapshotChanged, isFalse);

      final persisted = await _rowByName(db, predmetId, IriuK.prevozDoGroblja);
      await iriuRepository.azurirajStavku(
        persisted.id,
        const IriuCompanion(kom: Value('3'), iznos: Value(777.0)),
      );
      final manualId = await iriuRepository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_LIFECYCLE',
        nazivPrikaz: 'Ručna lifecycle stavka',
        kom: '2',
        iznos: 333.0,
      );
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
          .write(const IriuKatalogConfigCompanion(cena: Value(12.5)));
      final beforeRows = await iriuRepository.getIriu(predmetId);
      final beforeSnapshot = await _snapshot(db, predmetId);

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      final preview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(preview.scenarioSnapshotChanged, isTrue);
      expect(
        preview.addedCategories,
        containsAll([IriuK.limeniUlozak, IriuK.lemovanje]),
      );
      expect(preview.removedCategories, isEmpty);
      expect(preview.changedCategories, contains(IriuK.prevozDoGroblja));
      expect(await iriuRepository.getIriu(predmetId), _sameRowsAs(beforeRows));
      expect(await _snapshot(db, predmetId), beforeSnapshot);

      final applied = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      expect(applied.addedCategories, contains(IriuK.limeniUlozak));
      expect(applied.pendingUserDecisionRows, isEmpty);
      final added = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(added.cena, 12.5);
      expect(added.kom, '1');
      expect(added.iznos, 12.5);
      final preserved = await _rowByName(db, predmetId, IriuK.prevozDoGroblja);
      expect(preserved.id, persisted.id);
      expect(preserved.kom, '3');
      expect(preserved.iznos, 777.0);
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).any((row) => row.id == manualId),
        isTrue,
      );
      expect(
        (await _snapshot(db, predmetId)).scenarioId,
        applied.matchedScenarioIds.single,
      );
    },
  );

  test(
    'same identity status change is diffed and updates only scenario state',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
        cemeteryType: 'GRADSKO',
      );
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final limeni = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      await iriuRepository.azurirajStavku(
        limeni.id,
        const IriuCompanion(kom: Value('4'), iznos: Value(901.0)),
      );
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
        cemeteryType: 'LOKALNO',
      );
      final preview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(preview.changedCategories, contains(IriuK.limeniUlozak));
      expect(preview.changedCategoryLabels, contains('Limeni uložak'));
      final before = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(before.iznos, 901.0);
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final after = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(after.id, before.id);
      expect(after.kom, '4');
      expect(after.iznos, 901.0);
      expect(after.poslovniStatus, 'PREPORUČENO');
      final provenance = await (db.select(
        db.iriuProvenance,
      )..where((row) => row.iriuId.equals(after.id))).getSingle();
      expect(provenance.scenarioId, contains('LOKALNO'));
    },
  );

  test(
    'multiple unconfirmed changes resolve from applied A and stay per PREDMET',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final predmetA = await predmetRepository.kreirajPredmet(savetnikId: 1);
      final predmetB = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(predmetRepository, predmetA, burialPlace: 'GROB');
      await _setBurialState(
        predmetRepository,
        predmetB,
        burialPlace: 'GROBNICA',
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetB,
        scenarios,
        module,
      );
      final snapshotB = await _snapshot(db, predmetB);

      await _setBurialState(
        predmetRepository,
        predmetA,
        burialPlace: 'GROBNICA',
      );
      final pendingB = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(pendingB.matchedScenarioIds.single, contains('GROBNICA'));
      await _setBurialState(
        predmetRepository,
        predmetA,
        burialPlace: 'GROBNICA',
        cemeteryType: 'LOKALNO',
      );
      final pendingC = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetA,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(pendingC.matchedScenarioIds.single, contains('LOKALNO'));
      expect(
        (await _snapshot(db, predmetA)).scenarioId,
        isNot(contains('LOKALNO')),
      );
      expect(await _snapshot(db, predmetB), snapshotB);
      expect(await iriuRepository.getIriu(predmetB), isNotEmpty);
    },
  );

  test(
    'removed scenario item is not retained and is re-added as a fresh snapshot',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);
      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      await (db.update(db.iriuKatalogConfig)
            ..where((row) => row.interniNaziv.equals(IriuK.limeniUlozak)))
          .write(const IriuKatalogConfigCompanion(cena: Value(17.0)));
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final original = await _rowByName(db, predmetId, IriuK.limeniUlozak);

      await _setBurialState(predmetRepository, predmetId, burialPlace: 'GROB');
      final removalPreview = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      expect(removalPreview.removedCategories, contains(IriuK.limeniUlozak));
      final appliedRemoval = await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      for (final row in appliedRemoval.pendingUserDecisionRows) {
        await iriuRepository.resolveScenarioConditionChange(
          predmetId: predmetId,
          row: row,
          keepRow: false,
        );
      }
      expect(
        (await iriuRepository.getIriu(
          predmetId,
        )).any((row) => row.interniNaziv == IriuK.limeniUlozak),
        isFalse,
      );

      await _setBurialState(
        predmetRepository,
        predmetId,
        burialPlace: 'GROBNICA',
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
        applyScenarioChange: false,
      );
      await _sync(
        predmetRepository,
        iriuRepository,
        scenarioRepository,
        predmetId,
        scenarios,
        module,
      );
      final readded = await _rowByName(db, predmetId, IriuK.limeniUlozak);
      expect(readded.id, isNot(original.id));
      expect(readded.cena, 17.0);
      expect(readded.iznos, 17.0);
    },
  );

  test('confirmed scenario snapshot survives close and reopen', () async {
    final root = await Directory.systemTemp.createTemp('opc_scenario_reopen_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final file = File('${root.path}${Platform.pathSeparator}opc.sqlite');
    final firstDb = AppDatabase.forTesting(NativeDatabase(file));
    await seedScenarioCatalogForTest(firstDb);
    final predmetRepository = PredmetiRepository(firstDb);
    final scenarioRepository = ScenarioModuleRepository(firstDb);
    final iriuRepository = IriuRepository(firstDb);
    final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
    await _setBurialState(
      predmetRepository,
      predmetId,
      burialPlace: 'GROBNICA',
    );
    final module = await scenarioRepository.ensureModuleAndDefaults();
    final scenarios = await scenarioRepository.getActiveDefinitions();
    await _sync(
      predmetRepository,
      iriuRepository,
      scenarioRepository,
      predmetId,
      scenarios,
      module,
    );
    final expected = await _snapshot(firstDb, predmetId);
    await firstDb.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopened.close);
    final snapshot = await _snapshot(reopened, predmetId);
    expect(snapshot, expected);
    expect((await IriuRepository(reopened).getIriu(predmetId)), isNotEmpty);
  });
}

Future<ScenarioSyncResult> _sync(
  PredmetiRepository predmetRepository,
  IriuRepository iriuRepository,
  ScenarioModuleRepository scenarioRepository,
  int predmetId,
  List<ScenarioDefinition> scenarios,
  ScenarioModule module, {
  bool applyScenarioChange = true,
}) async {
  return iriuRepository.syncScenarioRows(
    predmetId: predmetId,
    predmet: await predmetRepository.getPredmet(predmetId),
    scenarios: scenarios,
    osnovniPaket: scenarioRepository.readOsnovniPaket(module),
    applyScenarioChange: applyScenarioChange,
  );
}

Future<void> _setBurialState(
  PredmetiRepository repository,
  int predmetId, {
  required String burialPlace,
  String cemeteryType = 'GRADSKO',
}) => repository.azurirajPredmet(
  predmetId,
  PredmetiCompanion(
    uzrokSmrti: const Value('PRIRODNA'),
    mestoSmrti: const Value('STAN'),
    vrstaCeremonije: const Value('SAHRANA'),
    tipGroblja: Value(cemeteryType),
    tipGrobnogMesta: Value(burialPlace),
    opelo: const Value('NE'),
  ),
);

Future<IriuData> _rowByName(AppDatabase db, int predmetId, String name) =>
    (db.select(db.iriu)..where(
          (row) =>
              row.predmetId.equals(predmetId) & row.interniNaziv.equals(name),
        ))
        .getSingle();

Future<PredmetScenarioSnapshot> _snapshot(AppDatabase db, int predmetId) =>
    (db.select(
      db.predmetScenarioSnapshots,
    )..where((row) => row.predmetId.equals(predmetId))).getSingle();

Matcher _sameRowsAs(List<IriuData> expected) =>
    predicate<List<IriuData>>((actual) {
      if (actual.length != expected.length) return false;
      for (var index = 0; index < actual.length; index++) {
        if (actual[index] != expected[index]) return false;
      }
      return true;
    }, 'rows equal expected values');
