import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/database.dart';

const memorandumLogoWidth = 192.0;
const memorandumLogoHeight = 120.0;
const memorandumLogoLeftMargin = 8.0;

String resolveSavetnikDisplayName({
  required KorisniciData? localUser,
  required String? portableName,
}) {
  final portable = portableName?.trim();
  if (portable != null && portable.isNotEmpty) return portable;
  final local = localUser?.imePrezime.trim();
  return local ?? '';
}

List<String> buildMemorandumIdentityRows({
  required String pib,
  required String mb,
  required String racun,
}) => <String>[
  if (pib.trim().isNotEmpty) 'PIB ${pib.trim()}',
  if (mb.trim().isNotEmpty) 'MB ${mb.trim()}',
  if (racun.trim().isNotEmpty) 'Račun ${racun.trim()}',
];

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
