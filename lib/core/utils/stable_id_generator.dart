import 'dart:math';

final Random _stableIdRandom = Random();

String generateCatalogArticleStableId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = List<int>.generate(
    8,
    (_) => _stableIdRandom.nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return 'katalog_artikal_${timestamp}_$randomPart';
}

/// Generates the opaque identity of one concrete PREDMET/IRiU occurrence.
///
/// The value is created once at the occurrence boundary and then transported
/// as business-state metadata. It must never be recomputed from display text,
/// order or a destination-local database row id.
String generateIriuOccurrencePortableId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = List<int>.generate(
    12,
    (_) => _stableIdRandom.nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return 'iriu_occurrence_${timestamp}_$randomPart';
}

String resolveIriuOccurrencePortableId(String? candidate) {
  final normalized = candidate?.trim() ?? '';
  return normalized.isEmpty
      ? generateIriuOccurrencePortableId()
      : normalized;
}

String generatePodsetnikManualObligationId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = List<int>.generate(
    12,
    (_) => _stableIdRandom.nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return 'podsetnik_manual_${timestamp}_$randomPart';
}
