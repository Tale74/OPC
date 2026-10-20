import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class OpcGuideTestAssetBundle extends CachingAssetBundle {
  OpcGuideTestAssetBundle(this._guideJson);

  final String _guideJson;

  @override
  Future<ByteData> load(String key) async {
    if (key != 'assets/opc_user_guide.json') {
      throw StateError('Unexpected test asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(_guideJson)));
  }
}

Future<OpcGuideTestAssetBundle> loadOpcGuideTestAssetBundle(
  WidgetTester tester,
) async {
  final guideJson = await tester.runAsync(
    () => File('assets/opc_user_guide.json').readAsString(),
  );
  return OpcGuideTestAssetBundle(guideJson!);
}
