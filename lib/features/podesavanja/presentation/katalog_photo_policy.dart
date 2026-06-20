import 'dart:typed_data';

import 'package:flutter/material.dart';

final class KatalogPhotoPolicy {
  const KatalogPhotoPolicy._();

  static const int storedImportTargetLongEdge = 1600;
  static const int temporaryHardUpperLongEdge = 1920;
  static const int smallThumbnailDecodeTarget = 256;
  static const int largeThumbnailDecodeTarget = 320;
  static const int androidPhonePreviewDecodeTarget = 1280;
  static const int androidTabletPreviewDecodeTarget = 1440;
  static const int windowsDesktopPreviewDecodeTarget = 1600;

  static bool isAndroidPhone(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android &&
        MediaQuery.sizeOf(context).width < 600;
  }

  static int gridThumbnailDecodeTarget(BuildContext context) {
    return isAndroidPhone(context)
        ? smallThumbnailDecodeTarget
        : largeThumbnailDecodeTarget;
  }

  static int previewDecodeTarget(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android) {
      return isAndroidPhone(context)
          ? androidPhonePreviewDecodeTarget
          : androidTabletPreviewDecodeTarget;
    }
    return windowsDesktopPreviewDecodeTarget;
  }

  static Image memoryImage(
    Uint8List bytes, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    int? cacheWidth,
    int? cacheHeight,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: errorBuilder,
    );
  }
}
