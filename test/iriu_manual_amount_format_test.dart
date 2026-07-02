import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/format/app_money_format.dart';

void main() {
  group('IRiU manual amount Serbian normalization', () {
    const examples = <String, String>{
      '1234,56': '1.234,56',
      '1234.56': '1.234,56',
      '1.234.56': '1.234,56',
      '1.234,56': '1.234,56',
    };

    for (final example in examples.entries) {
      test('${example.key} -> ${example.value}', () {
        expect(normalizeSerbianManualAmount(example.key), example.value);
        expect(tryParseSerbianManualAmount(example.key), 1234.56);
      });
    }

    test('empty input keeps the existing zero/empty behavior', () {
      expect(tryParseSerbianManualAmount(''), 0.0);
      expect(normalizeSerbianManualAmount(''), '');
    });

    test('invalid input is rejected instead of becoming zero', () {
      expect(tryParseSerbianManualAmount('12,34x'), isNull);
      expect(normalizeSerbianManualAmount('12,34x'), isNull);
    });
  });
}
