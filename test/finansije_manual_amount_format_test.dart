import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/format/app_money_format.dart';

void main() {
  test('FINANSIJE manual fields use Serbian amount normalization', () {
    for (final input in const ['1234,56', '1234.56', '1.234.56', '1.234,56']) {
      expect(normalizeSerbianManualAmount(input), '1.234,56');
      expect(tryParseSerbianManualAmount(input), 1234.56);
    }
    expect(normalizeSerbianManualAmount('pogrešno'), isNull);
  });
}
