import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/presentation/segments/preminulo_lice_segment.dart';

void main() {
  test('BRAČNO STANJE options follow POL preminulog lica', () {
    expect(maritalStatusOptionsForSex('M'), const [
      'OŽENJEN',
      'UDOVAC',
      'RAZVEDEN',
      'NEOŽENJEN',
      'VANBRAČNA ZAJEDNICA',
    ]);
    expect(maritalStatusOptionsForSex('Z'), const [
      'UDATA',
      'UDOVICA',
      'RAZVEDENA',
      'NEUDATA',
      'VANBRAČNA ZAJEDNICA',
    ]);
  });
}
