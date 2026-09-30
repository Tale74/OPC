import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'SCENARIO provenance failure rolls back materialized rows and snapshot',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await seedScenarioCatalogForTest(db);

      final predmetRepository = PredmetiRepository(db);
      final scenarioRepository = ScenarioModuleRepository(db);
      final iriuRepository = IriuRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final manualId = await iriuRepository.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_ATOMICITY_TEST',
        nazivPrikaz: 'Ručna stavka za rollback test',
      );
      final beforeRows = await iriuRepository.getIriu(predmetId);
      final beforeProvenance = await (db.select(
        db.iriuProvenance,
      )..where((row) => row.iriuId.equals(manualId))).get();
      final module = await scenarioRepository.ensureModuleAndDefaults();
      final scenarios = await scenarioRepository.getActiveDefinitions();

      await db.customStatement('''
      CREATE TRIGGER fail_scenario_provenance_insert
      BEFORE INSERT ON iriu_provenance
      WHEN NEW.origin = 'SCENARIO_PAKET'
      BEGIN
        SELECT RAISE(ABORT, 'synthetic SCENARIO provenance failure');
      END;
    ''');

      await expectLater(
        iriuRepository.syncScenarioRows(
          predmetId: predmetId,
          predmet: await predmetRepository.getPredmet(predmetId),
          scenarios: scenarios,
          osnovniPaket: scenarioRepository.readOsnovniPaket(module),
        ),
        throwsA(anything),
      );

      expect(await iriuRepository.getIriu(predmetId), beforeRows);
      expect(
        await (db.select(
          db.iriuProvenance,
        )..where((row) => row.iriuId.equals(manualId))).get(),
        beforeProvenance,
      );
      expect(await db.select(db.iriuProvenance).get(), isEmpty);
      expect(
        await (db.select(
          db.predmetScenarioSnapshots,
        )..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull(),
        null,
      );
    },
  );
}
