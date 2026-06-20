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
import '../../podesavanja/domain/nbs_ips_qr_payload_builder.dart';
import 'lista_pdf_data_builder.dart';
import 'memorandum_logo.dart';

const _kPredracunPdfTitle = 'PREDRA\u010cUN';
const _kPredracunPdfFilenameToken = 'PREDRACUN';
const _kPageHorizontalMargin = 24.0;
const _kPageTopMargin = 20.0;
const _kPageBottomMargin = 16.0;
const _kSectionGap = 6.0;
const _kSectionPadding = 6.0;
const _kHeaderFontSize = 9.4;
const _kBodyFontSize = 7.9;
const _kCompactBodyFontSize = 7.2;

Future<void> izvoziPredracunPdf({
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

    final bytes = await _buildPredracunPdf(
      predmet: predmet,
      iriuStavke: iriuStavke,
      firma: firma,
      app: app,
      savetnik: savetnik,
    );

    final naziv = koricePdfDerivatFajlNaziv(
      predmet,
      _kPredracunPdfFilenameToken,
      includePredmetVersion: true,
    );
    final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);

    if (!ctx.mounted) return;
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'PREDRA\u010cUN sa\u010duvan: ${koriceFajlLokacija(fajl)}',
      fajl: fajl,
    );
  } catch (e) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Gre\u0161ka pri PREDRA\u010cUN izvozu: $e'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

Future<Uint8List> _buildPredracunPdf({
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

  final preparedData = const ListaPdfDataBuilder().build(
    predmet: predmet,
    iriuStavke: iriuStavke,
    firma: firma,
    app: app,
    savetnik: savetnik,
  );
  final snapshot = _PredracunPdfSnapshot.fromPreparedData(preparedData);

  final doc = pw.Document(
    title: _kPredracunPdfTitle,
    author: snapshot.savetnikIme,
    theme: theme,
  );

  final pageTheme = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(
      _kPageHorizontalMargin,
      _kPageTopMargin,
      _kPageHorizontalMargin,
      _kPageBottomMargin,
    ),
    theme: theme,
  );

  doc.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(snapshot),
          pw.SizedBox(height: _kSectionGap),
          _buildSimpleSection(
            title:
                'PREMINULO LICE: ${snapshot.preminuloImePrezime.toUpperCase()}',
          ),
          if (snapshot.platilacNaslov.trim().isNotEmpty) ...[
            pw.SizedBox(height: _kSectionGap),
            _buildPayerSection(snapshot),
          ],
          pw.SizedBox(height: _kSectionGap),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: _buildIriuSection(snapshot.iriuItems),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                flex: 2,
                child: _buildFinancialSection(snapshot.finansijskiRedovi),
              ),
            ],
          ),
          pw.SizedBox(height: _kSectionGap),
          _buildPrimalacUplateSection(snapshot),
          pw.Spacer(),
          _buildFooter(
            context: context,
            savetnikIme: snapshot.savetnikIme,
            status: snapshot.status,
            dokumentVerzija: snapshot.dokumentVerzija,
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

class _PredracunPdfSnapshot {
  const _PredracunPdfSnapshot({
    required this.firma,
    required this.app,
    required this.brojPredmeta,
    required this.datumPredracuna,
    required this.savetnikIme,
    required this.status,
    required this.dokumentVerzija,
    required this.preminuloImePrezime,
    required this.platilacNaslov,
    required this.platilacDetalji,
    required this.iriuItems,
    required this.finansijskiRedovi,
    required this.zaNaplatu,
    required this.qrPayload,
  });

  factory _PredracunPdfSnapshot.fromPreparedData(
    ListaPdfPreparedData preparedData,
  ) {
    final preminuloImePrezime = _displayName(
      preparedData.predmet.ime,
      preparedData.predmet.prezime,
    );
    final finansijskiRedovi = preparedData.finansijskiRedovi;
    final zaNaplatu = _resolveZaNaplatu(finansijskiRedovi);

    final qr = NbsIpsQrPayloadBuilder.build(
      config: preparedData.app,
      iznosZaNaplatu: zaNaplatu,
      primalacNaziv: preparedData.firma.naziv,
      svrhaPlacanja: NbsIpsQrPayloadBuilder.obaveznaSvrhaPlacanja,
    );

    return _PredracunPdfSnapshot(
      firma: preparedData.firma,
      app: preparedData.app,
      brojPredmeta: preparedData.predmet.brojPredmeta.trim(),
      datumPredracuna: preparedData.datumIzvoza,
      savetnikIme: preparedData.savetnikIme,
      status: preparedData.predmet.status,
      dokumentVerzija: preparedData.dokumentVerzija,
      preminuloImePrezime: preminuloImePrezime,
      platilacNaslov: _resolvePlatilacNaslov(preparedData.predmet),
      platilacDetalji: _buildPlatilacDetalji(preparedData.predmet),
      iriuItems: preparedData.iriuItems,
      finansijskiRedovi: finansijskiRedovi,
      zaNaplatu: zaNaplatu,
      qrPayload: qr.payload,
    );
  }

  final FirmaPodaciData firma;
  final AppPodesavanjaData app;
  final String brojPredmeta;
  final DateTime datumPredracuna;
  final String savetnikIme;
  final String status;
  final String dokumentVerzija;
  final String preminuloImePrezime;
  final String platilacNaslov;
  final List<ListaPdfLabelValue> platilacDetalji;
  final List<ListaPdfIriuRenderItem> iriuItems;
  final List<ListaPdfLabelValue> finansijskiRedovi;
  final double zaNaplatu;
  final String qrPayload;
}

pw.Widget _buildHeader(_PredracunPdfSnapshot snapshot) {
  final contact = <String>[
    if (snapshot.firma.telefon.trim().isNotEmpty) snapshot.firma.telefon.trim(),
    if (snapshot.firma.email.trim().isNotEmpty) snapshot.firma.email.trim(),
    if (snapshot.firma.sajt.trim().isNotEmpty) snapshot.firma.sajt.trim(),
  ].join(' | ');

  final identitet = <String>[
    if (snapshot.firma.pib.trim().isNotEmpty) 'PIB ${snapshot.firma.pib.trim()}',
    if (snapshot.firma.mb.trim().isNotEmpty) 'MB ${snapshot.firma.mb.trim()}',
    if (snapshot.app.ziroRacun.trim().isNotEmpty)
      'Ra\u010dun ${snapshot.app.ziroRacun.trim()}',
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
                    documentTextCodec.normalize(snapshot.firma.naziv),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (snapshot.firma.adresa.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(snapshot.firma.adresa.trim()),
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
            if (snapshot.firma.logo?.isNotEmpty ?? false)
              buildMemorandumLogo(
                snapshot.firma.logo!,
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
                    documentTextCodec.normalize(_kPredracunPdfTitle),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  if (snapshot.brojPredmeta.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 1),
                      child: pw.Text(
                        documentTextCodec.normalize(
                          'Broj predmeta: ${snapshot.brojPredmeta}',
                        ),
                        style: const pw.TextStyle(fontSize: _kBodyFontSize),
                      ),
                    ),
                ],
              ),
            ),
            pw.Text(
              documentTextCodec.normalize(
                'Datum predra\u010duna: ${formatDateForDocument(snapshot.datumPredracuna)}',
              ),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: _kBodyFontSize,
              ),
            ),
          ],
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

pw.Widget _buildSimpleSection({
  required String title,
}) {
  return _buildSectionShell(
    title: title,
    child: pw.SizedBox.shrink(),
  );
}

pw.Widget _buildPayerSection(_PredracunPdfSnapshot snapshot) {
  final columns = _splitIntoColumns(snapshot.platilacDetalji, 3);
  return _buildSectionShell(
    title: 'PLATILAC: ${snapshot.platilacNaslov.toUpperCase()}',
    child: columns.isEmpty
        ? pw.Text(
            documentTextCodec.normalize('Nema evidentiranih podataka.'),
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              fontSize: _kCompactBodyFontSize,
              color: PdfColors.grey700,
            ),
          )
        : pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                pw.Expanded(child: _buildFieldList(columns[i])),
                if (i < columns.length - 1) pw.SizedBox(width: 8),
              ],
            ],
          ),
  );
}

pw.Widget _buildFieldList(List<ListaPdfLabelValue> rows) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: rows
        .map(
          (row) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: documentTextCodec.normalize('${row.label}: '),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: _kCompactBodyFontSize,
                    ),
                  ),
                  pw.TextSpan(
                    text: documentTextCodec.normalize(row.value),
                    style: const pw.TextStyle(fontSize: _kCompactBodyFontSize),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(growable: false),
  );
}

pw.Widget _buildIriuSection(List<ListaPdfIriuRenderItem> items) {
  return _buildSectionShell(
    title: 'IRIU: IZABRANA ROBA I USLUGE',
    child: items.isEmpty
        ? pw.Text(
            documentTextCodec.normalize(
              'Nema poslovno relevantnih IRIU stavki za prikaz.',
            ),
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              fontSize: _kCompactBodyFontSize,
              color: PdfColors.grey700,
            ),
          )
        : pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
            columnWidths: const <int, pw.TableColumnWidth>{
              0: pw.FlexColumnWidth(5.8),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(2.8),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
                children: [
                  _buildTableHeaderCell('NAZIV'),
                  _buildTableHeaderCell('KOM', horizontalPadding: 3),
                  _buildTableHeaderCell(
                    'IZNOS',
                    alignRight: true,
                    horizontalPadding: 2,
                  ),
                ],
              ),
              ...items.map(
                (item) => pw.TableRow(
                  children: [
                    _buildTableBodyCell(item.naziv),
                    _buildTableBodyCell(item.kom, horizontalPadding: 3),
                    _buildTableBodyCell(
                      formatMoneyRsd(item.iznos),
                      alignRight: true,
                      horizontalPadding: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}

pw.Widget _buildFinancialSection(List<ListaPdfLabelValue> rows) {
  return _buildSectionShell(
    title: 'FINANSIJSKI PREGLED',
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: rows
          .map(
            (row) {
              if (row.kind == ListaPdfRowKind.divider) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Divider(
                    height: 1,
                    thickness: 0.8,
                    color: PdfColors.grey500,
                  ),
                );
              }

              final isEmphasis = row.kind == ListaPdfRowKind.emphasis;
              final fontSize = isEmphasis ? _kHeaderFontSize : _kBodyFontSize;

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        documentTextCodec.normalize(row.label),
                        style: pw.TextStyle(
                          fontSize: fontSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      documentTextCodec.normalize(row.value),
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
          .toList(growable: false),
    ),
  );
}

pw.Widget _buildPrimalacUplateSection(_PredracunPdfSnapshot snapshot) {
  final levaKolona = <ListaPdfLabelValue>[
    ListaPdfLabelValue('Primalac', snapshot.firma.naziv.trim()),
    ListaPdfLabelValue('Adresa', snapshot.firma.adresa.trim()),
    ListaPdfLabelValue('Teku\u0107i ra\u010dun', snapshot.app.ziroRacun.trim()),
    ListaPdfLabelValue('Naziv banke', snapshot.app.nazivBanke.trim()),
    ListaPdfLabelValue('Iznos za uplatu', formatMoneyRsd(snapshot.zaNaplatu)),
    const ListaPdfLabelValue(
      'Svrha pla\u0107anja',
      NbsIpsQrPayloadBuilder.obaveznaSvrhaPlacanja,
    ),
    ListaPdfLabelValue('Poziv na broj', snapshot.preminuloImePrezime),
  ].where((row) => row.value.trim().isNotEmpty).toList(growable: false);

  return _buildSectionShell(
    title: 'PRIMALAC UPLATE',
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: _buildFieldList(levaKolona),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                documentTextCodec.normalize('NBS IPS QR'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: _kHeaderFontSize,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: 110,
                height: 110,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey500,
                    width: 0.8,
                  ),
                ),
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: snapshot.qrPayload,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableHeaderCell(
  String text, {
  bool alignRight = false,
  double horizontalPadding = 4,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 4,
    ),
    child: pw.Text(
      documentTextCodec.normalize(text),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 8.0,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _buildTableBodyCell(
  String text, {
  bool alignRight = false,
  double horizontalPadding = 4,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 3,
    ),
    child: pw.Text(
      documentTextCodec.normalize(text.trim()),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      style: const pw.TextStyle(fontSize: _kCompactBodyFontSize),
    ),
  );
}

pw.Widget _buildSectionShell({
  required String title,
  required pw.Widget child,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(_kSectionPadding),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          color: PdfColors.blueGrey50,
          child: pw.Text(
            documentTextCodec.normalize(title),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: _kHeaderFontSize,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        child,
      ],
    ),
  );
}

String _displayName(String ime, String prezime) {
  final fullName = [ime.trim(), prezime.trim()]
      .where((value) => value.isNotEmpty)
      .join(' ');
  return fullName.isEmpty ? '-' : fullName;
}

double _resolveZaNaplatu(List<ListaPdfLabelValue> rows) {
  final found = rows.where((item) => item.label.trim() == 'ZA NAPLATU');
  if (found.isEmpty) return 0;
  return _parseMoney(found.first.value);
}

double _parseMoney(String formatted) {
  final normalized = formatted
      .replaceAll('RSD', '')
      .replaceAll('.', '')
      .replaceAll(' ', '')
      .replaceAll(',', '.')
      .trim();
  return double.tryParse(normalized) ?? 0;
}

String _resolvePlatilacNaslov(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') {
    return predmet.naruPlNaziv.trim();
  }
  final fullName = predmet.naruImePrezime.trim();
  if (fullName.isNotEmpty) return fullName;
  return _displayName(predmet.naruIme, predmet.naruPrezime);
}

List<ListaPdfLabelValue> _buildPlatilacDetalji(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') {
    return _compactValues([
      ListaPdfLabelValue('Adresa', predmet.naruPlAdresa),
      ListaPdfLabelValue('PIB', predmet.naruPlPib),
      ListaPdfLabelValue('Mati\u010dni broj', predmet.naruPlMb),
      ListaPdfLabelValue('Odgovorno lice', predmet.naruPlOdgovornoLice),
      ListaPdfLabelValue('Telefon 1', predmet.naruPlTelefon1),
      ListaPdfLabelValue('Telefon 2', predmet.naruPlTelefon2),
      ListaPdfLabelValue('Email', predmet.naruPlEmail),
    ]);
  }

  return _compactValues([
    ListaPdfLabelValue('JMBG', predmet.naruJmbg),
    ListaPdfLabelValue('LK / paso\u0161', predmet.naruBrojLk),
    ListaPdfLabelValue('Adresa', predmet.naruAdresa),
    ListaPdfLabelValue('Telefon 1', predmet.naruTelefon1),
    ListaPdfLabelValue('Telefon 2', predmet.naruTelefon2),
    ListaPdfLabelValue('Email', predmet.naruEmail),
  ]);
}

List<ListaPdfLabelValue> _compactValues(List<ListaPdfLabelValue> values) {
  return values
      .where((value) => value.value.trim().isNotEmpty)
      .toList(growable: false);
}

List<List<ListaPdfLabelValue>> _splitIntoColumns(
  List<ListaPdfLabelValue> values,
  int columnCount,
) {
  if (values.isEmpty) return const <List<ListaPdfLabelValue>>[];
  final normalizedCount =
      values.length < columnCount ? values.length : columnCount;
  final perColumn = (values.length / normalizedCount).ceil();
  final columns = <List<ListaPdfLabelValue>>[];
  for (var i = 0; i < values.length; i += perColumn) {
    final end = (i + perColumn) > values.length ? values.length : i + perColumn;
    columns.add(List<ListaPdfLabelValue>.unmodifiable(values.sublist(i, end)));
  }
  return List<List<ListaPdfLabelValue>>.unmodifiable(columns);
}




