import 'dart:typed_data';

/// Native platforms continue to use the existing filesystem/document routes.
void downloadDocumentBytes(
  Uint8List bytes,
  String filename, {
  required String mimeType,
}) {
  throw UnsupportedError(
    'Browser PDF download adapter is unavailable on this platform.',
  );
}
