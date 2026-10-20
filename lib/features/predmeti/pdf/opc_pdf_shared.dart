import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../../core/utils/document_text_codec.dart';
import 'memorandum_logo.dart';

const opcPdfCompanyFontSize = 14.0;
const opcPdfBodyFontSize = 9.0;
const opcPdfMetadataFontSize = 8.5;
const opcPdfSubtleFontSize = 8.2;
const opcPdfDocumentTitleFontSize = 11.0;
const opcPdfSectionLabelFontSize = 10.0;
const opcPdfPastelSectionBackgroundHex = '#E7EFE5';
const opcPdfPastelSectionBorderHex = '#B4C5B2';
const opcPdfPastelSectionTextHex = '#415047';

Future<pw.ThemeData> loadOpcPdfTheme() async {
  final regularFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
  );
  final boldFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
  );
  final italicFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Italic.ttf'),
  );
  final boldItalicFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-BoldItalic.ttf'),
  );
  return pw.ThemeData.withFont(
    base: regularFont,
    bold: boldFont,
    italic: italicFont,
    boldItalic: boldItalicFont,
  );
}

pw.Widget buildOpcMemorandumHeader({
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required String documentTitle,
  required String? caseNumber,
}) {
  final contact = <String>[
    if (firma.telefon.trim().isNotEmpty) firma.telefon.trim(),
    if (firma.email.trim().isNotEmpty) firma.email.trim(),
    if (firma.sajt.trim().isNotEmpty) firma.sajt.trim(),
  ].join(' | ');
  final identityRows = buildMemorandumIdentityRows(
    pib: firma.pib,
    mb: firma.mb,
    racun: app.ziroRacun,
  );

  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    documentTextCodec.normalize(firma.naziv),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: opcPdfCompanyFontSize,
                    ),
                  ),
                  if (firma.adresa.trim().isNotEmpty)
                    _subtleText(firma.adresa.trim()),
                  if (contact.isNotEmpty) _subtleText(contact),
                  for (final identityRow in identityRows) _subtleText(identityRow),
                ],
              ),
            ),
            if (firma.logo?.isNotEmpty ?? false) buildMemorandumLogo(firma.logo!),
          ],
        ),
        pw.SizedBox(height: 7),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    documentTextCodec.normalize(documentTitle),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: opcPdfDocumentTitleFontSize,
                    ),
                  ),
                  if (caseNumber != null && caseNumber.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 1),
                      child: pw.Text(
                        documentTextCodec.normalize('Broj predmeta: ${caseNumber.trim()}'),
                        style: const pw.TextStyle(fontSize: opcPdfMetadataFontSize),
                      ),
                    ),
                ],
              ),
            ),
            pw.Text(
              documentTextCodec.normalize('Datum: ${formatDateForDocument(DateTime.now())}'),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: opcPdfMetadataFontSize,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _subtleText(String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Text(
        documentTextCodec.normalize(value),
        style: const pw.TextStyle(fontSize: opcPdfSubtleFontSize),
      ),
    );

pw.Widget buildOpcDocumentFooter({
  required pw.Context context,
  required String savetnikIme,
  required String status,
  required String dokumentVerzija,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 7),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.8)),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            documentTextCodec.normalize('Savetnik: ${savetnikIme.trim()}'),
            style: const pw.TextStyle(fontSize: opcPdfSubtleFontSize),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              '${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: opcPdfSubtleFontSize),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              documentTextCodec.normalize(
                'Status: $status · Verzija predmeta: $dokumentVerzija',
              ),
              style: const pw.TextStyle(fontSize: opcPdfSubtleFontSize),
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget buildOpcPastelSectionLabel(String title) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex(opcPdfPastelSectionBackgroundHex),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(
        color: PdfColor.fromHex(opcPdfPastelSectionBorderHex),
        width: 0.6,
      ),
    ),
    child: pw.Text(
      documentTextCodec.normalize(title),
      style: pw.TextStyle(
        color: PdfColor.fromHex(opcPdfPastelSectionTextHex),
        fontWeight: pw.FontWeight.bold,
        fontSize: opcPdfSectionLabelFontSize,
      ),
    ),
  );
}
