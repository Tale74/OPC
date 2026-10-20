import 'dart:typed_data';

/// Native platforms use the existing filesystem/document-provider routes.
void downloadJsonBytes(Uint8List bytes, String filename) {
  throw UnsupportedError(
    'Browser JSON download adapter is unavailable on this platform.',
  );
}
