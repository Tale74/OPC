import 'dart:typed_data';

Future<void> writeMedia(String key, Uint8List bytes) =>
    Future<void>.error(UnsupportedError('Web media storage unavailable.'));
Future<Uint8List?> readMedia(String key) => Future<Uint8List?>.error(
  UnsupportedError('Web media storage unavailable.'),
);
Future<void> deleteMedia(String key) =>
    Future<void>.error(UnsupportedError('Web media storage unavailable.'));
Future<bool> existsMedia(String key) =>
    Future<bool>.error(UnsupportedError('Web media storage unavailable.'));
Future<Map<String, String>> stageDeletion(Set<String> keys) =>
    Future<Map<String, String>>.error(
      UnsupportedError('Web media storage unavailable.'),
    );
Future<void> restoreDeletion(Map<String, String> keys) =>
    Future<void>.error(UnsupportedError('Web media storage unavailable.'));
Future<void> purgeDeletion(Map<String, String> keys) =>
    Future<void>.error(UnsupportedError('Web media storage unavailable.'));
