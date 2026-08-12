import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/iriu_ordering_service.dart';

void main() {
  test(
    'OSNOVNI package remains before SCENARIO package after persisted drift',
    () {
      final rows = [
        _row(1, 'SCENARIO', redosled: 0, section: 2, businessOrder: 20),
        _row(2, 'OSNOVNI', redosled: 1, section: 1, businessOrder: 9),
        _row(3, 'MANUAL', redosled: 2, section: 6, businessOrder: 0),
      ];
      final ordered = const IriuOrderingService().orderedRows(
        rows,
        provenanceOrigins: {1: 'SCENARIO_PAKET', 2: 'OSNOVNI_PAKET'},
      );
      expect(ordered.map((row) => row.id), [2, 1, 3]);
    },
  );
}

IriuData _row(
  int id,
  String name, {
  required int redosled,
  required int section,
  required int businessOrder,
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
  scenarioUpravlja: true,
  cekaOdlukuKorisnika: false,
  cena: 0,
);
