import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'parte_composer.dart';
import 'parte_models.dart';

Uint8List applyParteImageEffects(
  Uint8List source,
  ParteRenderBlock block, {
  double? brightness,
  double? contrast,
  double? sharpness,
}) {
  final resolvedBrightness = brightness ?? block.brightness;
  final resolvedContrast = contrast ?? block.contrast;
  final resolvedSharpness = sharpness ?? block.sharpness;
  if (block.kind != ParteBlockKind.photo ||
      (resolvedBrightness == 1 &&
          resolvedContrast == 1 &&
          resolvedSharpness == 0 &&
          !block.grayscale)) {
    return source;
  }
  return applyParteImageEffectsValues(
    source,
    brightness: resolvedBrightness,
    contrast: resolvedContrast,
    sharpness: resolvedSharpness,
    grayscale: block.grayscale,
  );
}

Uint8List applyParteImageEffectsRequest(Map<String, Object> request) =>
    applyParteImageEffectsValues(
      request['source']! as Uint8List,
      brightness: request['brightness']! as double,
      contrast: request['contrast']! as double,
      sharpness: request['sharpness']! as double,
      grayscale: request['grayscale']! as bool,
    );

Uint8List applyParteImageEffectsValues(
  Uint8List source, {
  required double brightness,
  required double contrast,
  required double sharpness,
  required bool grayscale,
}) {
  if (brightness == 1 && contrast == 1 && sharpness == 0 && !grayscale) {
    return source;
  }
  var image = img.decodeImage(source);
  if (image == null) {
    throw const FormatException('PARTE fotografija nije čitljiva.');
  }
  image = img.adjustColor(
    image,
    brightness: brightness,
    contrast: contrast,
    saturation: grayscale ? 0 : 1,
  );
  if (sharpness > 0) {
    image = img.convolution(
      image,
      filter: const [0, -1, 0, -1, 5, -1, 0, -1, 0],
      amount: sharpness,
    );
  }
  return Uint8List.fromList(img.encodePng(image));
}
