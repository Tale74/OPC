import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/iriu_ordering_service.dart';

void main() {
  test('package partitions outrank stale persisted order', () {
    final rows = [
      _row(1, 'scenario-b', redosled: 0, scenarioUpravlja: true),
      _row(2, 'base-a', redosled: 4, scenarioUpravlja: true),
      _row(3, 'manual-a', redosled: 1, scenarioUpravlja: false),
      _row(4, 'base-b', redosled: 3, scenarioUpravlja: true),
      _row(5, 'scenario-a', redosled: 2, scenarioUpravlja: true),
    ];
    final ordered = const IriuOrderingService().orderedRows(
      rows,
      context: const IriuOrderingContext(
        osnovniCategories: {'base-a', 'base-b'},
        osnovniBusinessOrders: {'base-a': 1, 'base-b': 0},
        scenarioCategories: {'scenario-a', 'scenario-b'},
        scenarioBusinessOrders: {'scenario-a': 0, 'scenario-b': 1},
        provenanceOrigins: {
          1: 'SCENARIO_PAKET',
          2: 'OSNOVNI_PAKET',
          4: 'OSNOVNI_PAKET',
          5: 'SCENARIO_PAKET',
        },
      ),
    );
    expect(ordered.map((row) => row.id), [4, 2, 5, 1, 3]);
  });

  test('changing OSNOVNI configured order changes only the base partition', () {
    final rows = [
      _row(1, 'base-a', redosled: 0, scenarioUpravlja: true),
      _row(2, 'base-b', redosled: 1, scenarioUpravlja: true),
      _row(3, 'scenario-a', redosled: 2, scenarioUpravlja: true),
    ];
    const service = IriuOrderingService();
    final first = service.orderedRows(
      rows,
      context: const IriuOrderingContext(
        osnovniCategories: {'base-a', 'base-b'},
        osnovniBusinessOrders: {'base-a': 0, 'base-b': 1},
        scenarioCategories: {'scenario-a'},
        scenarioBusinessOrders: {'scenario-a': 0},
        provenanceOrigins: {
          1: 'OSNOVNI_PAKET',
          2: 'OSNOVNI_PAKET',
          3: 'SCENARIO_PAKET',
        },
      ),
    );
    final second = service.orderedRows(
      rows,
      context: const IriuOrderingContext(
        osnovniCategories: {'base-a', 'base-b'},
        osnovniBusinessOrders: {'base-a': 1, 'base-b': 0},
        scenarioCategories: {'scenario-a'},
        scenarioBusinessOrders: {'scenario-a': 0},
        provenanceOrigins: {
          1: 'OSNOVNI_PAKET',
          2: 'OSNOVNI_PAKET',
          3: 'SCENARIO_PAKET',
        },
      ),
    );
    expect(first.map((row) => row.id), [1, 2, 3]);
    expect(second.map((row) => row.id), [2, 1, 3]);
  });

  test(
    'changing SCENARIO configured order changes only the scenario partition',
    () {
      final rows = [
        _row(1, 'base-a', redosled: 0, scenarioUpravlja: true),
        _row(2, 'scenario-a', redosled: 1, scenarioUpravlja: true),
        _row(3, 'scenario-b', redosled: 2, scenarioUpravlja: true),
        _row(4, 'manual-a', redosled: 3, scenarioUpravlja: false),
      ];
      const service = IriuOrderingService();
      final first = service.orderedRows(
        rows,
        context: const IriuOrderingContext(
          osnovniCategories: {'base-a'},
          osnovniBusinessOrders: {'base-a': 0},
          scenarioCategories: {'scenario-a', 'scenario-b'},
          scenarioBusinessOrders: {'scenario-a': 0, 'scenario-b': 1},
        ),
      );
      final second = service.orderedRows(
        rows,
        context: const IriuOrderingContext(
          osnovniCategories: {'base-a'},
          osnovniBusinessOrders: {'base-a': 0},
          scenarioCategories: {'scenario-a', 'scenario-b'},
          scenarioBusinessOrders: {'scenario-a': 1, 'scenario-b': 0},
        ),
      );
      expect(first.map((row) => row.id), [1, 2, 3, 4]);
      expect(second.map((row) => row.id), [1, 3, 2, 4]);
    },
  );

  test(
    'different package sizes and manual rows require no algorithm change',
    () {
      final rows = [
        _row(1, 'manual-a', redosled: 0, scenarioUpravlja: false),
        _row(2, 'scenario-a', redosled: 1, scenarioUpravlja: true),
        _row(3, 'base-a', redosled: 2, scenarioUpravlja: true),
        _row(4, 'manual-b', redosled: 3, scenarioUpravlja: false),
      ];
      final ordered = const IriuOrderingService().orderedRows(
        rows,
        context: const IriuOrderingContext(
          osnovniCategories: {'base-a'},
          osnovniBusinessOrders: {'base-a': 0},
          scenarioCategories: {'scenario-a'},
          scenarioBusinessOrders: {'scenario-a': 0},
          provenanceOrigins: {
            2: 'SCENARIO_PAKET',
            3: 'OSNOVNI_PAKET',
            1: 'RUCNA_STAVKA',
            4: 'RUCNA_STAVKA',
          },
        ),
      );
      expect(ordered.map((row) => row.id), [3, 2, 1, 4]);
    },
  );

  test('scenario-flagged row outside both packages remains in manual tail', () {
    final ordered = const IriuOrderingService().orderedRows(
      <IriuData>[
        _row(1, 'manual-flagged', redosled: 0, scenarioUpravlja: true),
        _row(2, 'base-a', redosled: 1, scenarioUpravlja: true),
        _row(3, 'scenario-a', redosled: 2, scenarioUpravlja: true),
      ],
      context: const IriuOrderingContext(
        osnovniCategories: {'base-a'},
        osnovniBusinessOrders: {'base-a': 0},
        scenarioCategories: {'scenario-a'},
        scenarioBusinessOrders: {'scenario-a': 0},
      ),
    );
    expect(ordered.map((row) => row.id), [2, 3, 1]);
  });
}

IriuData _row(
  int id,
  String name, {
  required int redosled,
  required bool scenarioUpravlja,
}) => IriuData(
  id: id,
  predmetId: 1,
  interniNaziv: name,
  nazivPrikaz: name,
  kom: '1',
  iznos: 0,
  cekiran: false,
  redosled: redosled,
  poslovniStatus: 'AKTIVNO',
  obezbedjuje: 'FIRMA',
  poslovnoUpozorenje: '',
  poslovniRazlog: '',
  poslovnaCelina: 99,
  poslovniRedosled: 999,
  finansijskiUkljuceno: true,
  scenarioUpravlja: scenarioUpravlja,
  cekaOdlukuKorisnika: false,
  cena: 0,
);
