import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Starts a direct download from the already-generated document bytes.
void downloadDocumentBytes(
  Uint8List bytes,
  String filename, {
  required String mimeType,
}) {
  final blob = Blob(<JSAny>[bytes.toJS].toJS, BlobPropertyBag(type: mimeType));
  final objectUrl = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = objectUrl
    ..download = filename
    ..style.display = 'none';

  document.body?.append(anchor);
  try {
    anchor.click();
  } finally {
    anchor.remove();
    Future<void>.delayed(
      const Duration(seconds: 1),
      () => URL.revokeObjectURL(objectUrl),
    );
  }
}
