import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/financial_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'manual IRiU rows stay active, financial and in the final partition',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmeti = PredmetiRepository(db);
      final iriu = IriuRepository(db);
      final scenarios = ScenarioModuleRepository(db);

      await scenarios.ensureModuleAndDefaults();
      final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
      await predmeti.azurirajPredmet(
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
      await predmeti.inicijalizujIriu(predmetId);
      final module = await scenarios.ensureModule();
      final definitions = await scenarios.getActiveDefinitions();
      await iriu.syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmeti.getPredmet(predmetId),
        scenarios: definitions,
        osnovniPaket: scenarios.readOsnovniPaket(module),
      );

      final manualId = await iriu.dodajStavku(
        predmetId: predmetId,
        interniNaziv: 'RUCNO_REGRESSION',
        nazivPrikaz: 'Ručna regresiona stavka',
        kom: '1',
        iznos: 6000,
        redosled: await iriu.sledeciredosled(predmetId),
      );

      Future<void> resync() async {
        await iriu.syncScenarioRows(
          predmetId: predmetId,
          predmet: await predmeti.getPredmet(predmetId),
          scenarios: definitions,
          osnovniPaket: scenarios.readOsnovniPaket(module),
        );
      }

      await resync();
      final rows = await iriu.getIriu(predmetId);
      final manualIndex = rows.indexWhere((row) => row.id == manualId);
      expect(manualIndex, greaterThanOrEqualTo(0));
      expect(
        manualIndex,
        rows.length - 1,
        reason: 'manual/unpredicted rows must remain the final IRiU partition',
      );
      final truth = const PredmetIriuTruthService().evaluate(
        predmet: await predmeti.getPredmet(predmetId),
        storedRows: rows,
      );
      final manualTruth = truth.rows.singleWhere(
        (row) => row.storedRow.id == manualId,
      );
      expect(manualTruth.active, isTrue);
      expect(manualTruth.countsForFinancialTruth, isTrue);
      expect(
        const FinancialTruthService().buildRobaIUsluge(truth).robaIUsluge,
        6000,
      );

      await resync();
      final afterResync = await iriu.getIriu(predmetId);
      final afterManual = afterResync.singleWhere((row) => row.id == manualId);
      expect(afterManual.interniNaziv, 'RUCNO_REGRESSION');
      expect(afterManual.iznos, 6000);
      expect(afterResync.last.id, manualId);
    },
  );
}
