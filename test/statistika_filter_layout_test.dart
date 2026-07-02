import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/presentation/izvestaji_screen.dart';

void main() {
  test('uses compact statistics filters only on Android', () {
    expect(useCompactStatistikaFilters(TargetPlatform.android), isTrue);
    expect(useCompactStatistikaFilters(TargetPlatform.windows), isFalse);
    expect(useCompactStatistikaFilters(TargetPlatform.linux), isFalse);
    expect(useCompactStatistikaFilters(TargetPlatform.macOS), isFalse);
  });
}
