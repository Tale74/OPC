import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/utils/export_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DOCX export uses browser download without native filesystem', () async {
    final file = await sacuvajKoriceDokumentFajlDetalji(
      'OPC_TEST_RACUN.docx',
      Uint8List.fromList(<int>[0x50, 0x4b, 0x03, 0x04]),
      mimeType:
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );

    expect(file.name, 'OPC_TEST_RACUN.docx');
    expect(file.locationLabel, 'Preuzimanje u browseru');
    expect(
      file.mimeType,
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    expect(file.path, isNull);
  }, skip: !kIsWeb);
}
