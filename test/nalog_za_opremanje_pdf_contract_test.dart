import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart';

void main() {
  const ceremonyTypes = <String>[
    'Sahrana',
    'Kremacija',
    'Sme\u0161taj urne',
    'Rasipanje pepela',
    'Nepoznata ceremonija',
  ];

  test('NALOG ZA OPREMANJE uses generic ceremony date/time labels', () {
    for (final ceremonyType in ceremonyTypes) {
      expect(nalogZaOpremanjeDateLabel(ceremonyType), 'Datum:');
      expect(nalogZaOpremanjeTimeLabel(ceremonyType), 'Vreme:');
    }
  });
}
