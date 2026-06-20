import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'NotoSans';

  static TextTheme textTheme(TextTheme base) {
    return base.apply(
      fontFamily: fontFamily,
      displayColor: null,
      bodyColor: null,
    );
  }
}
