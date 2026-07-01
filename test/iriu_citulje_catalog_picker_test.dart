import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_row_tile.dart';

void main() {
  group('IRiU citulje catalog picker', () {
    test('uses Politika and Novosti catalog categories for citulje rows', () {
      expect(
        resolveIriuCatalogPickerCategoryKeys(IriuK.cituljaP),
        const [IriuK.cituljaP, IriuK.cituljaNo],
      );
      expect(
        resolveIriuCatalogPickerCategoryKeys(IriuK.cituljaNo),
        const [IriuK.cituljaP, IriuK.cituljaNo],
      );
    });

    test('keeps non-citulje rows scoped to their own catalog category', () {
      expect(
        resolveIriuCatalogPickerCategoryKeys(IriuK.sanduk),
        const [IriuK.sanduk],
      );
    });
  });
}
