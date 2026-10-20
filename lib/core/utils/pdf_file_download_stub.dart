import 'dart:typed_data';

/// Native platforms continue to use the existing filesystem/document routes.
void downloadPdfBytes(Uint8List bytes, String filename) {
  throw UnsupportedError(
    'Browser PDF download adapter is unavailable on this platform.',
  );
}
