import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:opc_v4/features/predmeti/parte/domain/parte_composer.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_image_effects.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';

void main() {
  test('isolate request preserves existing photo effect output', () {
    final sourceImage = img.Image(width: 8, height: 8);
    img.fill(sourceImage, color: img.ColorRgb8(100, 140, 190));
    final source = Uint8List.fromList(img.encodePng(sourceImage));
    const block = ParteRenderBlock(
      id: 'photo',
      kind: ParteBlockKind.photo,
      rect: ParteRectMm(x: 10, y: 10, width: 50, height: 40),
      layer: 1,
      mediaKey: 'test-photo',
      brightness: 1.1,
      contrast: 1.2,
      sharpness: 0.3,
      grayscale: true,
    );

    final expected = applyParteImageEffects(source, block);
    final actual = applyParteImageEffectsRequest(<String, Object>{
      'source': source,
      'brightness': block.brightness,
      'contrast': block.contrast,
      'sharpness': block.sharpness,
      'grayscale': block.grayscale,
    });

    expect(actual, orderedEquals(expected));
  });

  test('decode failure remains an error in worker path', () {
    expect(
      () => applyParteImageEffectsRequest(<String, Object>{
        'source': Uint8List.fromList([1, 2, 3]),
        'brightness': 1.2,
        'contrast': 1.1,
        'sharpness': 0.1,
        'grayscale': false,
      }),
      throwsA(isA<RangeError>()),
    );
  });
}
