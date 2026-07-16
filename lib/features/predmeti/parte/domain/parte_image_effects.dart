import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'parte_composer.dart';
import 'parte_models.dart';

Uint8List applyParteImageEffects(Uint8List source, ParteRenderBlock block) {
  if (block.kind != ParteBlockKind.photo ||
      (block.brightness == 1 &&
          block.contrast == 1 &&
          block.sharpness == 0 &&
          !block.grayscale)) {
    return source;
  }
  var image = img.decodeImage(source);
  if (image == null) {
    throw const FormatException('PARTE fotografija nije čitljiva.');
  }
  image = img.adjustColor(
    image,
    brightness: block.brightness,
    contrast: block.contrast,
    saturation: block.grayscale ? 0 : 1,
  );
  if (block.sharpness > 0) {
    image = img.convolution(
      image,
      filter: const [0, -1, 0, -1, 5, -1, 0, -1, 0],
      amount: block.sharpness,
    );
  }
  return Uint8List.fromList(img.encodePng(image));
}
