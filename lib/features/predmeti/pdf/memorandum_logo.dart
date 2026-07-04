import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

const memorandumLogoWidth = 192.0;
const memorandumLogoHeight = 120.0;
const memorandumLogoLeftMargin = 8.0;

pw.Widget buildMemorandumLogo(Uint8List logoBytes) {
  final image = pw.MemoryImage(logoBytes);

  return pw.Container(
    width: memorandumLogoWidth,
    height: memorandumLogoHeight,
    margin: const pw.EdgeInsets.only(left: memorandumLogoLeftMargin),
    alignment: pw.Alignment.centerRight,
    child: pw.Image(
      image,
      width: memorandumLogoWidth,
      height: memorandumLogoHeight,
      fit: pw.BoxFit.contain,
      alignment: pw.Alignment.centerRight,
    ),
  );
}
