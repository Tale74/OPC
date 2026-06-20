import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

pw.Widget buildMemorandumLogo(
  Uint8List logoBytes, {
  required double reservedWidth,
  required double reservedHeight,
  double leftMargin = 12,
}) {
  final image = pw.MemoryImage(logoBytes);

  return pw.Container(
    width: reservedWidth,
    height: reservedHeight,
    margin: pw.EdgeInsets.only(left: leftMargin),
    alignment: pw.Alignment.centerRight,
    child: pw.Image(
      image,
      width: reservedWidth,
      height: reservedHeight,
      fit: pw.BoxFit.contain,
      alignment: pw.Alignment.centerRight,
    ),
  );
}
