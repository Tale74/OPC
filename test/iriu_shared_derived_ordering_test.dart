import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/iriu_ordering_service.dart';

void main() {
  test(
    'configured package order governs production-shaped rows, not stale redosled',
    () {
      const base = <String>{
        'AGENCIJSKE_USLUGE',
        'CITULJA_POLITIKA',
        'CRNINA',
        'ESARPA',
        'CVEĆE',
        'OBELEZJE',
        'PESKIR_ZA_KRST',
        'POKROV_GARNITURA',
        'POSMRTNE_PARTE',
        'SANDUK',
        'SLIKA',
      };
      const scenario = <String>{
        'TRANSPORTNA_VRECA',
        'IZNOSENJE',
        'PREVOZ_DO_HLADNJACE',
        'HLADNJACA',
        'SPREMANJE_POKOJNIKA',
        'PREVOZ_DO_GROBLJA',
        'KOMPLET_ZA_OPELO',
      };
      final rows = <IriuData>[
        _row(1, 'AGENCIJSKE_USLUGE', 17, 1, 1),
        _row(2, 'CITULJA_POLITIKA', 16, 1, 2),
        _row(3, 'CRNINA', 0, 1, 3),
        _row(4, 'ESARPA', 1, 1, 4),
        _row(5, 'CVEĆE', 2, 1, 5),
        _row(6, 'OBELEZJE', 3, 1, 6),
        _row(7, 'PESKIR_ZA_KRST', 4, 1, 7),
        _row(8, 'POKROV_GARNITURA', 5, 1, 8),
        _row(9, 'POSMRTNE_PARTE', 6, 1, 9),
        _row(10, 'SANDUK', 7, 1, 10),
        _row(11, 'SLIKA', 8, 1, 11),
        _row(12, 'TRANSPORTNA_VRECA', 9, 2, 10),
        _row(13, 'IZNOSENJE', 10, 2, 20),
        _row(14, 'PREVOZ_DO_HLADNJACE', 11, 2, 30),
        _row(15, 'HLADNJACA', 12, 2, 40),
        _row(16, 'SPREMANJE_POKOJNIKA', 13, 2, 50),
        _row(17, 'PREVOZ_DO_GROBLJA', 14, 2, 60),
        // Legacy consequence metadata is deliberately wrong/absent.
        _row(18, 'KOMPLET_ZA_OPELO', 15, 6, 0),
      ];
      final ordered = const IriuOrderingService().orderedRows(
        rows,
        context: const IriuOrderingContext(
          osnovniCategories: base,
          osnovniBusinessOrders: {
            'AGENCIJSKE_USLUGE': 0,
            'CITULJA_POLITIKA': 1,
            'CRNINA': 2,
            'ESARPA': 3,
            'CVEĆE': 4,
            'OBELEZJE': 5,
            'PESKIR_ZA_KRST': 6,
            'POKROV_GARNITURA': 7,
            'POSMRTNE_PARTE': 8,
            'SANDUK': 9,
            'SLIKA': 10,
          },
          scenarioCategories: scenario,
          scenarioBusinessSections: {
            'TRANSPORTNA_VRECA': 2,
            'IZNOSENJE': 2,
            'PREVOZ_DO_HLADNJACE': 2,
            'HLADNJACA': 2,
            'SPREMANJE_POKOJNIKA': 2,
            'PREVOZ_DO_GROBLJA': 2,
            'KOMPLET_ZA_OPELO': 2,
          },
          scenarioBusinessOrders: {
            'TRANSPORTNA_VRECA': 10,
            'IZNOSENJE': 20,
            'PREVOZ_DO_HLADNJACE': 30,
            'HLADNJACA': 40,
            'SPREMANJE_POKOJNIKA': 50,
            'PREVOZ_DO_GROBLJA': 60,
            'KOMPLET_ZA_OPELO': 70,
          },
          provenanceOrigins: {},
        ),
      );
      expect(ordered.map((row) => row.id), <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
      ]);
    },
  );

  test(
    'duplicate package rows use stable id tie order, not persisted rank',
    () {
      final ordered = const IriuOrderingService().orderedRows(
        <IriuData>[
          _row(20, 'CRNINA', 5, 1, 3),
          _row(21, 'CRNINA', 4, 1, 3),
          _row(22, 'MANUAL', 1, 6, 0, scenario: false),
        ],
        context: const IriuOrderingContext(
          osnovniCategories: {'CRNINA'},
          osnovniBusinessOrders: {'CRNINA': 0},
          provenanceOrigins: {},
        ),
      );
      expect(ordered.map((row) => row.id), [20, 21, 22]);
    },
  );

  test('manual rows remain in a final partition after managed rows', () {
    final ordered = const IriuOrderingService().orderedRows(
      <IriuData>[
        _row(30, 'MANUAL', 0, 0, 0, scenario: false),
        _row(31, 'KOMPLET_ZA_OPELO', 99, 6, 0),
      ],
      context: const IriuOrderingContext(
        scenarioCategories: {'KOMPLET_ZA_OPELO'},
        scenarioBusinessSections: {'KOMPLET_ZA_OPELO': 2},
        scenarioBusinessOrders: {'KOMPLET_ZA_OPELO': 70},
        provenanceOrigins: {},
      ),
    );
    expect(ordered.map((row) => row.id), [31, 30]);
  });
}

IriuData _row(
  int id,
  String name,
  int redosled,
  int section,
  int businessOrder, {
  bool scenario = true,
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
  poslovnaCelina: section,
  poslovniRedosled: businessOrder,
  finansijskiUkljuceno: true,
  scenarioUpravlja: scenario,
  cekaOdlukuKorisnika: false,
  cena: 0,
);
