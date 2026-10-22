// Deterministically derives platform icons from the existing approved OPC master.
// Run with: dart run tool/generate_official_opc_icons.dart
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source = img.decodePng(
    File('assets/app_icon/opc_app_icon_master_1024.png').readAsBytesSync(),
  );
  if (source == null || source.width != 1024 || source.height != 1024) {
    throw StateError('Approved OPC master icon is missing or invalid.');
  }

  void png(String path, int size, {bool opaque = false}) {
    final resized = img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final output = opaque
        ? img.compositeImage(
            img.Image(width: size, height: size, numChannels: 4)
              ..clear(img.ColorRgba8(47, 61, 79, 255)),
            resized,
          )
        : resized;
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(img.encodePng(output));
  }

  png('web/favicon.png', 48);
  png('web/icons/Icon-192.png', 192);
  png('web/icons/Icon-512.png', 512);
  png('web/icons/Icon-maskable-192.png', 192, opaque: true);
  png('web/icons/Icon-maskable-512.png', 512, opaque: true);
  png('web/icons/apple-touch-icon.png', 180, opaque: true);

  final iosManifest =
      jsonDecode(
            File(
              'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final entry in iosManifest['images'] as List<dynamic>) {
    final item = entry as Map<String, dynamic>;
    final filename = item['filename'] as String;
    final logical = double.parse((item['size'] as String).split('x').first);
    final scale = int.parse((item['scale'] as String).replaceFirst('x', ''));
    png(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename',
      (logical * scale).round(),
      opaque: true,
    );
  }

  for (final size in <int>[16, 32, 64, 128, 256, 512, 1024]) {
    png(
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png',
      size,
    );
  }

  for (final entry in <String, int>{
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  }.entries) {
    png(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      entry.value,
    );
  }

  final icon = img.copyResize(source, width: 256, height: 256);
  for (final size in <int>[16, 32, 48, 64, 128]) {
    icon.addFrame(img.copyResize(source, width: size, height: size));
  }
  File(
    'windows/runner/resources/app_icon.ico',
  ).writeAsBytesSync(img.encodeIco(icon));
}
