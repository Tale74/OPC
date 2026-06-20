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
