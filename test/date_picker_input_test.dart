import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/format/app_date_format.dart';

void main() {
  test('calendar selection preserves Serbian date field formats', () {
    final selected = DateTime(2026, 7, 2);
    expect(formatCalendarPickerSelection(selected), '02.07.2026');
    expect(
      formatCalendarPickerSelection(selected, trailingDot: true),
      '02.07.2026.',
    );
  });
}
