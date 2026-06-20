import 'dart:typed_data';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../../core/utils/document_text_codec.dart';
import '../../../core/utils/export_utils.dart';
import 'memorandum_logo.dart';
import 'nalog_za_opremanje_pdf_data_builder.dart';

const _kNalogZaOpremanjePdfTitle = 'NALOG_ZA_OPREMANJE';
const _kNalogZaOpremanjePdfDisplayTitle = 'NALOG ZA OPREMANJE';
const _kPageHorizontalMargin = 24.0;
const _kPageTopMargin = 20.0;
const _kPageBottomMargin = 16.0;
const _kSectionGap = 10.0;
const _kBodyFontSize = 9.0;
const _kLabelWidth = 168.0;

Future<void> izvoziNalogZaOpremanjePdf({
  required BuildContext ctx,
  required AppDatabase db,
  required int predmetId,
}) async {
  try {
    final predmet = await (db.select(db.predmeti)
          ..where((t) => t.id.equals(predmetId)))
        .getSingle();
    final iriuStavke = await (db.select(db.iriu)
          ..where((t) => t.predmetId.equals(predmetId))
          ..orderBy([(t) => OrderingTerm.asc(t.redosled)]))
        .get();
    final firma = await (db.select(db.firmaPodaci)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    final app = await (db.select(db.appPodesavanja)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    final savetnik = predmet.savetnikId == null
        ? null
        : await (db.select(db.korisnici)
              ..where((t) => t.id.equals(predmet.savetnikId!)))
            .getSingleOrNull();

    final bytes = await _buildNalogZaOpremanjePdf(
      predmet: predmet,
      iriuStavke: iriuStavke,
      firma: firma,
      app: app,
      savetnik: savetnik,
    );

    final naziv = koricePdfDerivatFajlNaziv(
      predmet,
      _kNalogZaOpremanjePdfTitle,
      includePredmetVersion: true,
    );
    final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);
    final lokacija = koriceFajlLokacija(fajl);


    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('NALOG ZA OPREMANJE sa\u010Duvan: $lokacija'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'NALOG ZA OPREMANJE sa\u010duvan: $lokacija',
      fajl: fajl,
    );
  } catch (e) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Gre\u0161ka pri izvozu NALOGA ZA OPREMANJE: $e'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

Future<Uint8List> _buildNalogZaOpremanjePdf({
  required PredmetiData predmet,
  required List<IriuData> iriuStavke,
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required KorisniciData? savetnik,
}) async {
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

  final theme = pw.ThemeData.withFont(
    base: regularFont,
    bold: boldFont,
    italic: italicFont,
    boldItalic: boldItalicFont,
  );

  final prepared = const NalogZaOpremanjePdfDataBuilder().build(
    predmet: predmet,
    iriuStavke: iriuStavke,
  );
  final savetnikIme = documentTextCodec.normalize(
    savetnik?.imePrezime.trim().isNotEmpty == true
        ? savetnik!.imePrezime.trim()
        : '',
  );
  final dokumentVerzija = 'v${predmet.verzija}';

  final doc = pw.Document(
    title: _kNalogZaOpremanjePdfDisplayTitle,
    author: savetnikIme,
    theme: theme,
  );

  doc.addPage(
    pw.Page(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          _kPageHorizontalMargin,
          _kPageTopMargin,
          _kPageHorizontalMargin,
          _kPageBottomMargin,
        ),
        theme: theme,
      ),
      build: (context) => _buildPage(
        context: context,
        prepared: prepared,
        predmet: predmet,
        firma: firma,
        app: app,
        savetnikIme: savetnikIme,
        dokumentVerzija: dokumentVerzija,
      ),
    ),
  );

  return doc.save();
}

pw.Widget _buildPage({
  required pw.Context context,
  required NalogZaOpremanjePdfPreparedData prepared,
  required PredmetiData predmet,
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required String savetnikIme,
  required String dokumentVerzija,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _buildHeader(
        predmet: predmet,
        firma: firma,
        app: app,
      ),
      pw.SizedBox(height: _kSectionGap),
      _buildSection(
        'PODACI O PREMINULOM LICU',
        <NalogZaOpremanjePdfField>[
          NalogZaOpremanjePdfField('IME I PREZIME:', prepared.fullName),
          NalogZaOpremanjePdfField('GODINA RO\u0110ENJA:', prepared.godinaRodjenja),
          NalogZaOpremanjePdfField('GODINA SMRTI:', prepared.godinaSmrti),
          NalogZaOpremanjePdfField('MESTO SMRTI:', prepared.mestoSmrti),
        ],
      ),
      pw.SizedBox(height: _kSectionGap),
      _buildSection(
        _ceremonySectionTitle(prepared.vrstaCeremonije),
        <NalogZaOpremanjePdfField>[
          NalogZaOpremanjePdfField('Groblje:', prepared.mestoCeremonije),
          NalogZaOpremanjePdfField(
            _ceremonyDateLabel(prepared.vrstaCeremonije),
            prepared.datumCeremonije,
          ),
          NalogZaOpremanjePdfField(
            _ceremonyTimeLabel(prepared.vrstaCeremonije),
            prepared.vremeCeremonije,
          ),
        ],
      ),
      pw.SizedBox(height: _kSectionGap),
      _buildSection('IZABRANA OPREMA', prepared.oprema),
      pw.SizedBox(height: _kSectionGap),
      _buildSection('USLUGE', prepared.usluge),
      pw.Spacer(),
      _buildSignatures(),
      pw.SizedBox(height: 18),
      _buildFooter(
        context: context,
        savetnikIme: savetnikIme,
        status: predmet.status,
        dokumentVerzija: dokumentVerzija,
      ),
    ],
  );
}

pw.Widget _buildHeader({
  required PredmetiData predmet,
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
}) {
  final contact = <String>[
    if (firma.telefon.trim().isNotEmpty) firma.telefon.trim(),
    if (firma.email.trim().isNotEmpty) firma.email.trim(),
    if (firma.sajt.trim().isNotEmpty) firma.sajt.trim(),
  ].join(' | ');

  final identitet = <String>[
    if (firma.pib.trim().isNotEmpty) 'PIB ${firma.pib.trim()}',
    if (firma.mb.trim().isNotEmpty) 'MB ${firma.mb.trim()}',
    if (app.ziroRacun.trim().isNotEmpty) 'Ra\u010Dun ${app.ziroRacun.trim()}',
  ].join(' | ');

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
                      fontSize: 14,
                    ),
                  ),
                  if (firma.adresa.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(firma.adresa.trim()),
                        style: const pw.TextStyle(fontSize: 8.2),
                      ),
                    ),
                  if (contact.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(contact),
                        style: const pw.TextStyle(fontSize: 8.2),
                      ),
                    ),
                  if (identitet.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(identitet),
                        style: const pw.TextStyle(fontSize: 8.2),
                      ),
                    ),
                ],
              ),
            ),
            if (firma.logo?.isNotEmpty ?? false)
              buildMemorandumLogo(
                firma.logo!,
                reservedWidth: 72,
                reservedHeight: 52,
              ),
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
                    _kNalogZaOpremanjePdfDisplayTitle,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  if (predmet.brojPredmeta.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 1),
                      child: pw.Text(
                        documentTextCodec.normalize(
                          'Broj predmeta: ${predmet.brojPredmeta.trim()}',
                        ),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                ],
              ),
            ),
            pw.Text(
              documentTextCodec.normalize(
                'Datum: ${formatDateForDocument(DateTime.now())}',
              ),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _ceremonySectionTitle(String ceremonyType) {
  return switch (ceremonyType.trim()) {
    'Sahrana' => 'PODACI O SAHRANI',
    'Kremacija' => 'PODACI O KREMACIJI',
    'Sme\u0161taj urne' => 'PODACI O SME\u0160TAJU URNE',
    'Rasipanje pepela' => 'PODACI O RASIPANJU PEPELA',
    _ => 'PODACI O CEREMONIJI',
  };
}

String _ceremonyDateLabel(String ceremonyType) {
  return switch (ceremonyType.trim()) {
    'Sahrana' => 'Datum sahrane:',
    'Kremacija' => 'Datum kremacije:',
    'Sme\u0161taj urne' => 'Datum sme\u0161taja urne:',
    'Rasipanje pepela' => 'Datum rasipanja pepela:',
    _ => 'Datum ceremonije:',
  };
}

String _ceremonyTimeLabel(String ceremonyType) {
  return switch (ceremonyType.trim()) {
    'Sahrana' => 'Vreme sahrane:',
    'Kremacija' => 'Vreme kremacije:',
    'Sme\u0161taj urne' => 'Vreme sme\u0161taja urne:',
    'Rasipanje pepela' => 'Vreme rasipanja pepela:',
    _ => 'Vreme ceremonije:',
  };
}

pw.Widget _buildSection(
  String title,
  List<NalogZaOpremanjePdfField> fields,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#387DB8'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Text(
          documentTextCodec.normalize(title),
          style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      pw.SizedBox(height: 6),
      ...fields.map(_buildFieldRow),
    ],
  );
}

pw.Widget _buildFieldRow(NalogZaOpremanjePdfField field) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 2, bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: _kLabelWidth,
          child: pw.Text(
            documentTextCodec.normalize(field.label),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: _kBodyFontSize,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  documentTextCodec.normalize(field.value),
                  style: pw.TextStyle(
                    fontWeight: field.label == 'IME I PREZIME:'
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                    fontSize: _kBodyFontSize,
                  ),
                ),
              ),
              if (field.biohazard) ...[
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FDECEA'),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(3)),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#C0392B'),
                      width: 0.6,
                    ),
                  ),
                  child: pw.Text(
                    'ZARAZNA BOLEST',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#C0392B'),
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 7.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildFooter({
  required pw.Context context,
  required String savetnikIme,
  required String status,
  required String dokumentVerzija,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 7),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
      ),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            documentTextCodec.normalize('Savetnik: ${savetnikIme.trim()}'),
            style: const pw.TextStyle(fontSize: 8.5),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              '${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8.5),
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
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildSignatures() {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildSignatureBlock('Nalog izdao:'),
        ),
        pw.SizedBox(width: 32),
        pw.Expanded(
          child: _buildSignatureBlock('Opremanje izvr\u0161io:'),
        ),
      ],
    ),
  );
}

pw.Widget _buildSignatureBlock(String label) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        documentTextCodec.normalize(label),
        style: const pw.TextStyle(
          color: PdfColors.grey700,
          fontSize: 9,
        ),
      ),
      pw.SizedBox(height: 28),
      pw.Container(
        height: 1,
        color: PdfColors.grey600,
      ),
    ],
  );
}





