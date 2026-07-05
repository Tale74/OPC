import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/pdf/memorandum_logo.dart';

void main() {
  test(
    'memorandum identity fields are three separate Serbian-labeled rows',
    () {
      final rows = buildMemorandumIdentityRows(
        pib: ' 123456789 ',
        mb: ' 12345678 ',
        racun: ' 160-1-01 ',
      );

      expect(rows, ['PIB 123456789', 'MB 12345678', 'Račun 160-1-01']);
      expect(rows, isNot(contains(contains(' | '))));
      expect(rows.where((row) => row.startsWith('Racun ')), isEmpty);
    },
  );

  test('memorandum identity rows omit empty values without merging rows', () {
    expect(buildMemorandumIdentityRows(pib: '', mb: '12345678', racun: ''), [
      'MB 12345678',
    ]);
  });
}
