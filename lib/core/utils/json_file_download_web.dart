import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Delivers an already-serialized JSON payload as a direct browser download.
void downloadJsonBytes(Uint8List bytes, String filename) {
  final blob = Blob(
    <JSAny>[bytes.toJS].toJS,
    BlobPropertyBag(type: 'application/json'),
  );
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
    // Allow the browser to begin consuming the Blob before releasing its URL.
    Future<void>.delayed(
      const Duration(seconds: 1),
      () => URL.revokeObjectURL(objectUrl),
    );
  }
}
