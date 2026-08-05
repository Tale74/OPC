import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/owner_scenario_policy_kernel.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  const kernel = OwnerScenarioPolicyKernel();

  test('owner map generator covers 1008 unique complete combinations', () {
    final keys = kernel.allKeys();
    expect(keys, hasLength(1008));
    expect(keys.toSet(), hasLength(1008));
    expect(keys.where((key) => key.docek), hasLength(144));
    expect(keys.where((key) => !key.docek), hasLength(864));
    expect(keys.where((key) => key.docek && key.place == null), hasLength(144));
    expect(keys.map((key) => key.stableId).toSet(), hasLength(1008));
  });

  test('owner kernel applies hospital exception and stable ordering', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = PredmetiRepository(db);
    final id = await repository.kreirajPredmet(savetnikId: 1);
    await repository.azurirajPredmet(
      id,
      const PredmetiCompanion(
        uzrokSmrti: Value('ZARAZNA'),
        mestoSmrti: Value('BOLNICA'),
        vrstaCeremonije: Value('SAHRANA'),
        tipGroblja: Value('GRADSKO'),
        tipGrobnogMesta: Value('GROB'),
        opelo: Value('DA'),
        sahranaVanSrbije: Value(false),
      ),
    );
    final result = kernel.evaluate(await repository.getPredmet(id));
    expect(result.isComplete, isTrue);
    expect(result.key!.place, 'BOLNICA');
    expect(
      result.consequences.map((item) => item.katalogCategoryInternalName),
      [IriuK.prevozDoGroblja, IriuK.kompletZaOpelo],
    );
    expect(
      result.consequences.any(
        (item) => item.katalogCategoryInternalName == IriuK.iznosenje,
      ),
      isFalse,
    );
  });

  test(
    'owner kernel marks infectious non-hospital operational rows as BIOHAZARD',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = PredmetiRepository(db);
      final id = await repository.kreirajPredmet(savetnikId: 1);
      await repository.azurirajPredmet(
        id,
        const PredmetiCompanion(
          uzrokSmrti: Value('ZARAZNA'),
          mestoSmrti: Value('STAN'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('GRADSKO'),
          tipGrobnogMesta: Value('GROB'),
          opelo: Value('NE'),
        ),
      );
      final result = kernel.evaluate(await repository.getPredmet(id));
      final iznosenje = result.consequences.singleWhere(
        (item) => item.katalogCategoryInternalName == IriuK.iznosenje,
      );
      final spremanje = result.consequences.singleWhere(
        (item) => item.katalogCategoryInternalName == IriuK.spremaanjePokojnika,
      );
      expect(
        iznosenje.warning,
        'Postupati prema merama zaštite za zaraznu bolest.',
      );
      expect(spremanje.warning, iznosenje.warning);
      expect(
        result.consequences.any(
          (item) =>
              item.katalogCategoryInternalName == IriuK.zastitnaIDodatnaOprema,
        ),
        isTrue,
      );
    },
  );

  test(
    'reception excludes death place and supports inner sanduk change',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = PredmetiRepository(db);
      final id = await repository.kreirajPredmet(savetnikId: 1);
      await repository.azurirajPredmet(
        id,
        const PredmetiCompanion(
          uzrokSmrti: Value('PRIRODNA'),
          mestoSmrti: Value('BOLNICA'),
          vrstaCeremonije: Value('SAHRANA'),
          tipGroblja: Value('LOKALNO'),
          tipGrobnogMesta: Value('GROBNICA'),
          opelo: Value('NE'),
          sahranaVanSrbije: Value(false),
          docekPosmrtnihOstataka: Value(true),
          promenaSanduka: Value(true),
        ),
      );
      final result = kernel.evaluate(await repository.getPredmet(id));
      expect(result.isComplete, isTrue);
      expect(result.key!.place, isNull);
      expect(
        result.baseActions[IriuK.sanduk],
        ScenarioConsequenceAction.required,
      );
      expect(
        result.consequences.map((item) => item.katalogCategoryInternalName),
        containsAll(<String>[
          IriuK.cargoTroskovi,
          IriuK.spremaanjePokojnika,
          IriuK.limeniUlozak,
          IriuK.lemovanje,
        ]),
      );
      expect(
        result.consequences.map((item) => item.katalogCategoryInternalName),
        isNot(contains(IriuK.transportnaVreca)),
      );
    },
  );
}
