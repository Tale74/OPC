import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_rule_engine.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'predefined editable policy produces every required business result',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final scenarios = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );
      final module = await scenarios.ensureModuleAndDefaults();
      final definitions = await scenarios.getActiveDefinitions();
      final base = scenarios.readOsnovniPaket(module);
      final predmeti = PredmetiRepository(db);
      final id = await predmeti.kreirajPredmet(savetnikId: 1);

      expect(base, hasLength(9));
      expect(base, isNot(contains(IriuK.prevozDoGroblja)));

      Future<ScenarioRuleEvaluation> evaluate(PredmetiCompanion change) async {
        await predmeti.azurirajPredmet(id, change);
        return const ScenarioRuleEngine().evaluate(
          scenarios: definitions,
          predmet: await predmeti.getPredmet(id),
          osnovniPaket: base,
        );
      }

      const fullPlacePackage = <String>{
        IriuK.iznosenje,
        IriuK.transportnaVreca,
        IriuK.prevozDoHladnjace,
        IriuK.hladnjaca,
        IriuK.spremaanjePokojnika,
        IriuK.prevozDoGroblja,
      };
      for (final place in const [
        'STAN',
        'DOM ZA STARE',
        'PRIVATNA BOLNICA',
        'DRUGO',
        'ULICA / JAVNO MESTO',
      ]) {
        final result = await evaluate(
          PredmetiCompanion(mestoSmrti: Value(place)),
        );
        expect(result.effectiveCategories, containsAll(fullPlacePackage));
        if (place == 'PRIVATNA BOLNICA' || place == 'DRUGO') {
          expect(
            result.matchedScenarioIds,
            contains(
              place == 'PRIVATNA BOLNICA' ? 'PRIVATNA_BOLNICA' : 'DRUGO',
            ),
          );
          expect(result.matchedScenarioIds, isNot(contains('DOM_ZA_STARE')));
        }
      }

      final hospital = await evaluate(
        const PredmetiCompanion(mestoSmrti: Value('BOLNICA')),
      );
      expect(hospital.effectiveCategories.difference(base), {
        IriuK.prevozDoGroblja,
      });

      final localAndOpelo = await evaluate(
        const PredmetiCompanion(
          mestoSmrti: Value('BOLNICA'),
          tipGroblja: Value('LOKALNO'),
          opelo: Value('DA'),
        ),
      );
      expect(
        localAndOpelo.decisions[IriuK.prevozSprovoda]!.businessStatus,
        'PREPORUČENO',
      );
      expect(
        localAndOpelo.decisions[IriuK.kompletZaOpelo]!.businessStatus,
        'PREPORUČENO',
      );

      final cremation = await evaluate(
        const PredmetiCompanion(
          vrstaCeremonije: Value('KREMACIJA'),
          uzrokSmrti: Value('ZARAZNA'),
          tipGrobnogMesta: Value('GROBNICA'),
        ),
      );
      expect(
        cremation.effectiveCategories,
        isNot(contains(IriuK.limeniUlozak)),
      );
      expect(cremation.effectiveCategories, isNot(contains(IriuK.lemovanje)));

      final nonHospitalBiohazard = await evaluate(
        const PredmetiCompanion(
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          uzrokSmrti: Value('ZARAZNA'),
          sahranaVanSrbije: Value(true),
          docekPosmrtnihOstataka: Value(true),
        ),
      );
      expect(
        nonHospitalBiohazard.decisions[IriuK.spremaanjePokojnika]!.warning,
        isNotEmpty,
      );
      expect(
        nonHospitalBiohazard.effectiveCategories,
        containsAll([
          IriuK.medjunarodniPrevoz,
          IriuK.medjunarodnaDocumentacija,
          IriuK.balsamovanje,
          IriuK.cargoTroskovi,
        ]),
      );

      final noConditions = await evaluate(
        const PredmetiCompanion(
          mestoSmrti: Value('BOLNICA'),
          uzrokSmrti: Value('PRIRODNA'),
          sahranaVanSrbije: Value(false),
          docekPosmrtnihOstataka: Value(false),
        ),
      );
      expect(
        noConditions.effectiveCategories,
        isNot(contains(IriuK.cargoTroskovi)),
      );
      expect(
        noConditions.effectiveCategories,
        isNot(contains(IriuK.medjunarodniPrevoz)),
      );
    },
  );
}
