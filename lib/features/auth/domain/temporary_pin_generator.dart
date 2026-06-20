import 'dart:math';

class TemporaryPinGenerator {
  TemporaryPinGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const int duzinaPina = 4;
  static const int _minVrednost = 1000;
  static const int _raspon = 9000;

  String generate() {
    final vrednost = _minVrednost + _random.nextInt(_raspon);
    return vrednost.toString().padLeft(duzinaPina, '0');
  }
}
