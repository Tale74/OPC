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
import 'lista_pdf_data_builder.dart';
import 'memorandum_logo.dart';

const _kListaPdfTitle = 'LISTA';
const _kPageHorizontalMargin = 24.0;
const _kPageTopMargin = 24.0;
const _kPageBottomMargin = 20.0;
const _kSectionGap = 8.0;
const _kFieldGap = 2.5;
const _kHeaderFontSize = 10.0;
const _kBodyFontSize = 8.1;
const _kCompactBodyFontSize = 7.6;

Future<void> izvoziListaPdf({
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

    final bytes = await _buildListaPdf(
      predmet: predmet,
      iriuStavke: iriuStavke,
      firma: firma,
      app: app,
      savetnik: savetnik,
    );

    final naziv = koricePdfDerivatFajlNaziv(
      predmet,
      _kListaPdfTitle,
      includePredmetVersion: true,
    );
    final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);
    final lokacija = koriceFajlLokacija(fajl);


    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('LISTA sacuvana: $lokacija'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'LISTA sacuvana: $lokacija',
      fajl: fajl,
    );
  } catch (e) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Greška pri LISTA izvozu: $e'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

Future<Uint8List> _buildListaPdf({
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
  final snapshot = _ListaPdfSnapshot.fromPreparedData(
    preparedData,
  );

  final doc = pw.Document(
    title: _kListaPdfTitle,
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
      build: (_) => _buildPageFrame(
        header: _buildHeader(snapshot),
        body: _buildPageOneBody(snapshot),
        footer: _buildFooter(
          pageNumber: 1,
          pageCount: 2,
          savetnikIme: snapshot.savetnikIme,
          status: snapshot.predmet.status,
          dokumentVerzija: snapshot.dokumentVerzija,
        ),
      ),
    ),
  );

  doc.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (_) => _buildPageFrame(
        body: _buildPageTwoBody(snapshot),
        footer: _buildFooter(
          pageNumber: 2,
          pageCount: 2,
          savetnikIme: snapshot.savetnikIme,
          status: snapshot.predmet.status,
          dokumentVerzija: snapshot.dokumentVerzija,
        ),
      ),
    ),
  );

  return doc.save();
}

class _ListaPdfSnapshot {
  _ListaPdfSnapshot({
    required this.predmet,
    required this.firma,
    required this.app,
    required this.datumIzvoza,
    required this.savetnikIme,
    required this.dokumentVerzija,
    required this.preminuloSection,
    required this.payerSection,
    required this.ceremonySection,
    required this.iriuItems,
    required this.iriuPlan,
    required this.finansijskiRedovi,
    required this.napomene,
    required this.partePreview,
    required this.parteSimbol,
  });

  factory _ListaPdfSnapshot.fromPreparedData(ListaPdfPreparedData preparedData) {
    final iriuItems = preparedData.iriuItems;
    return _ListaPdfSnapshot(
      predmet: preparedData.predmet,
      firma: preparedData.firma,
      app: preparedData.app,
      datumIzvoza: preparedData.datumIzvoza,
      savetnikIme: preparedData.savetnikIme,
      dokumentVerzija: preparedData.dokumentVerzija,
      preminuloSection: preparedData.preminuloSection,
      payerSection: preparedData.payerSection,
      ceremonySection: preparedData.ceremonySection,
      iriuItems: iriuItems,
      iriuPlan: _planIriuLayout(iriuItems),
      finansijskiRedovi: preparedData.finansijskiRedovi,
      napomene: preparedData.napomene,
      partePreview: preparedData.partePreview,
      parteSimbol: preparedData.parteSimbol,
    );
  }

  final PredmetiData predmet;
  final FirmaPodaciData firma;
  final AppPodesavanjaData app;
  final DateTime datumIzvoza;
  final String savetnikIme;
  final String dokumentVerzija;
  final ListaPdfSectionData preminuloSection;
  final ListaPdfSectionData payerSection;
  final ListaPdfSectionData ceremonySection;
  final List<ListaPdfIriuRenderItem> iriuItems;
  final _IriuPagePlan iriuPlan;
  final List<ListaPdfLabelValue> finansijskiRedovi;
  final List<ListaPdfDocumentNote> napomene;
  final String partePreview;
  final String parteSimbol;
}

class _IriuLayoutProfile {
  const _IriuLayoutProfile({
    required this.rowFontSize,
    required this.headerFontSize,
    required this.checkSize,
    required this.pageOneBudget,
    required this.pageTwoBudget,
  });

  final double rowFontSize;
  final double headerFontSize;
  final double checkSize;
  final int pageOneBudget;
  final int pageTwoBudget;

  int get totalBudget => pageOneBudget + pageTwoBudget;
}

class _IriuPagePlan {
  const _IriuPagePlan({
    required this.profile,
    required this.pageOneItems,
    required this.pageTwoItems,
  });

  final _IriuLayoutProfile profile;
  final List<ListaPdfIriuRenderItem> pageOneItems;
  final List<ListaPdfIriuRenderItem> pageTwoItems;
}

const _kIriuProfiles = <_IriuLayoutProfile>[
  _IriuLayoutProfile(
    rowFontSize: 7.6,
    headerFontSize: 8.0,
    checkSize: 7.0,
    pageOneBudget: 30,
    pageTwoBudget: 24,
  ),
  _IriuLayoutProfile(
    rowFontSize: 7.1,
    headerFontSize: 7.7,
    checkSize: 6.6,
    pageOneBudget: 36,
    pageTwoBudget: 30,
  ),
  _IriuLayoutProfile(
    rowFontSize: 6.7,
    headerFontSize: 7.3,
    checkSize: 6.2,
    pageOneBudget: 42,
    pageTwoBudget: 36,
  ),
  _IriuLayoutProfile(
    rowFontSize: 6.2,
    headerFontSize: 7.0,
    checkSize: 5.8,
    pageOneBudget: 48,
    pageTwoBudget: 42,
  ),
];

_IriuPagePlan _planIriuLayout(List<ListaPdfIriuRenderItem> items) {
  final totalUnits = items.fold<int>(0, (sum, item) => sum + item.estimatedUnits);
  final profile = _kIriuProfiles.firstWhere(
    (candidate) => totalUnits <= candidate.totalBudget,
    orElse: () => _kIriuProfiles.last,
  );

  final pageOne = <ListaPdfIriuRenderItem>[];
  final pageTwo = <ListaPdfIriuRenderItem>[];
  var usedOnPageOne = 0;

  for (final item in items) {
    final nextUnits = usedOnPageOne + item.estimatedUnits;
    if (nextUnits <= profile.pageOneBudget || pageOne.isEmpty) {
      pageOne.add(item);
      usedOnPageOne = nextUnits;
    } else {
      pageTwo.add(item);
    }
  }

  return _IriuPagePlan(
    profile: profile,
    pageOneItems: List<ListaPdfIriuRenderItem>.unmodifiable(pageOne),
    pageTwoItems: List<ListaPdfIriuRenderItem>.unmodifiable(pageTwo),
  );
}

pw.Widget _buildPageFrame({
  required pw.Widget body,
  required pw.Widget footer,
  pw.Widget? header,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      // pdf Column expects non-nullable List<pw.Widget>; null-aware element
      // replacements here were not toolchain-safe for `pw.Widget? header`.
      // ignore: use_null_aware_elements
      if (header != null) header,
      pw.Expanded(child: body),
      pw.SizedBox(height: 8),
      footer,
    ],
  );
}

pw.Widget _buildHeader(_ListaPdfSnapshot snapshot) {
  final contact = <String>[
    if (snapshot.firma.telefon.trim().isNotEmpty) snapshot.firma.telefon.trim(),
    if (snapshot.firma.email.trim().isNotEmpty) snapshot.firma.email.trim(),
    if (snapshot.firma.sajt.trim().isNotEmpty) snapshot.firma.sajt.trim(),
  ].join(' | ');

  final identitet = <String>[
    if (snapshot.firma.pib.trim().isNotEmpty) 'PIB ${snapshot.firma.pib.trim()}',
    if (snapshot.firma.mb.trim().isNotEmpty) 'MB ${snapshot.firma.mb.trim()}',
    if (snapshot.app.ziroRacun.trim().isNotEmpty)
      'Racun ${snapshot.app.ziroRacun.trim()}',
  ].join(' | ');

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
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
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  if (contact.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(contact),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  if (identitet.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        documentTextCodec.normalize(identitet),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                ],
              ),
            ),
            if (snapshot.firma.logo?.isNotEmpty ?? false)
              buildMemorandumLogo(
                snapshot.firma.logo!,
                reservedWidth: 76,
                reservedHeight: 56,
              ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          documentTextCodec.normalize(
            'LISTA',
          ),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10.2,
          ),
        ),
        if (snapshot.predmet.brojPredmeta.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              documentTextCodec.normalize(
                'Broj predmeta: ${snapshot.predmet.brojPredmeta.trim()}',
              ),
              style: const pw.TextStyle(fontSize: 8.3),
            ),
          ),
      ],
    ),
  );
}

pw.Widget _buildFooter({
  required int pageNumber,
  required int pageCount,
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
              '$pageNumber/$pageCount',
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

pw.Widget _buildPageOneBody(_ListaPdfSnapshot snapshot) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _buildPreparedSection(snapshot.preminuloSection),
      pw.SizedBox(height: _kSectionGap),
      _buildPreparedSection(snapshot.ceremonySection),
      pw.SizedBox(height: _kSectionGap),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(
              child: _buildIriuFinanceLayout(snapshot),
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildPageTwoBody(_ListaPdfSnapshot snapshot) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _buildPreparedSection(snapshot.payerSection),
      pw.SizedBox(height: _kSectionGap),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(child: _buildNotesSection(snapshot.napomene)),
            pw.SizedBox(height: _kSectionGap),
            _buildParteSection(
              predmet: snapshot.predmet,
              partePreview: snapshot.partePreview,
              simbolLabel: snapshot.parteSimbol,
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildIriuFinanceLayout(_ListaPdfSnapshot snapshot) {
  final leftItems = snapshot.iriuPlan.pageOneItems;
  final rightItems = snapshot.iriuPlan.pageTwoItems;

  return _buildSectionShell(
    title: 'IRIU: IZABRANA ROBA I USLUGE',
    fillChild: true,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: leftItems.isEmpty
              ? pw.Text(
                  documentTextCodec.normalize(
                    'Nema poslovno relevantnih IRIU stavki za prikaz.',
                  ),
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    fontSize: snapshot.iriuPlan.profile.rowFontSize,
                    color: PdfColors.grey700,
                  ),
                )
              : _buildIriuTable(leftItems, snapshot.iriuPlan.profile),
        ),
        pw.SizedBox(width: _kSectionGap),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (rightItems.isNotEmpty)
                _buildIriuTable(rightItems, snapshot.iriuPlan.profile)
              else
                pw.Text(
                  documentTextCodec.normalize(''),
                  style: pw.TextStyle(
                    fontSize: snapshot.iriuPlan.profile.rowFontSize,
                  ),
                ),
              pw.SizedBox(height: _kSectionGap),
              _buildFinancialSection(snapshot.finansijskiRedovi),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildPreparedSection(ListaPdfSectionData section) {
  final hasPanels = section.panels.isNotEmpty;
  final body = hasPanels
      ? pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: section.panels
              .map(
                (panel) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: _buildMiniBlock(
                    panel.title,
                    _buildPreparedColumns(panel.columns),
                  ),
                ),
              )
              .toList(growable: false),
        )
      : _buildPreparedColumns(section.columns);

  return _buildSectionShell(
    title: section.title,
    child: body,
  );
}

pw.Widget _buildPreparedColumns(List<List<ListaPdfLabelValue>> columns) {
  if (columns.isEmpty) {
    return pw.Text(
      documentTextCodec.normalize('Nema evidentiranih podataka.'),
      style: pw.TextStyle(
        fontStyle: pw.FontStyle.italic,
        fontSize: _kCompactBodyFontSize,
        color: PdfColors.grey700,
      ),
    );
  }

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < columns.length; i++) ...[
        pw.Expanded(child: _buildFieldList(columns[i])),
        if (i < columns.length - 1) pw.SizedBox(width: 10),
      ],
    ],
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

pw.Widget _buildIriuTable(
  List<ListaPdfIriuRenderItem> items,
  _IriuLayoutProfile profile,
) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
    columnWidths: const <int, pw.TableColumnWidth>{
      0: pw.FixedColumnWidth(18),
      1: pw.FlexColumnWidth(5.6),
      2: pw.FlexColumnWidth(1.4),
      3: pw.FlexColumnWidth(2.8),
    },
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
        children: [
          _buildIriuHeaderCell('', profile),
          _buildIriuHeaderCell('Stavka', profile),
          _buildIriuHeaderCell('Kom', profile, horizontalPadding: 3),
          _buildIriuHeaderCell(
            'Iznos',
            profile,
            alignRight: true,
            horizontalPadding: 2,
          ),
        ],
      ),
      ...items.map(
        (item) => pw.TableRow(
          children: [
            _buildIriuCheckCell(profile),
            _buildIriuBodyCell(item.naziv, profile),
            _buildIriuBodyCell(
              item.kom,
              profile,
              horizontalPadding: 3,
            ),
            _buildIriuBodyCell(
              formatMoneyRsd(item.iznos),
              profile,
              alignRight: true,
              horizontalPadding: 2,
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildNotesSection(List<ListaPdfDocumentNote> notes) {
  final standaloneNotes = notes
      .where((note) => note.groupTitle == null || note.groupTitle!.trim().isEmpty)
      .toList(growable: false);
  final groupedNotes = <String, List<ListaPdfDocumentNote>>{};
  for (final note in notes) {
    final groupTitle = note.groupTitle?.trim() ?? '';
    if (groupTitle.isEmpty) continue;
    groupedNotes.putIfAbsent(groupTitle, () => <ListaPdfDocumentNote>[]).add(note);
  }

  return _buildSectionShell(
    title: 'NAPOMENE',
    fillChild: true,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (standaloneNotes.isEmpty && groupedNotes.isEmpty)
          pw.Text(
            documentTextCodec.normalize('Prostor za operativne i rucne napomene.'),
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              fontSize: _kCompactBodyFontSize,
              color: PdfColors.grey700,
            ),
          )
        else ...[
          if (groupedNotes.containsKey('Finansijske napomene'))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: _buildMiniBlock(
                'Finansijske napomene',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: groupedNotes['Finansijske napomene']!
                      .map(
                        (note) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: documentTextCodec.normalize('${note.label}: '),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: _kCompactBodyFontSize,
                                  ),
                                ),
                                pw.TextSpan(
                                  text: documentTextCodec.normalize(note.value),
                                  style: const pw.TextStyle(
                                    fontSize: _kCompactBodyFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ...standaloneNotes.map(
            (note) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: documentTextCodec.normalize('${note.label}: '),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: _kCompactBodyFontSize,
                      ),
                    ),
                    pw.TextSpan(
                      text: documentTextCodec.normalize(note.value),
                      style: const pw.TextStyle(fontSize: _kCompactBodyFontSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        pw.Spacer(),
      ],
    ),
  );
}

pw.Widget _buildParteSection({
  required PredmetiData predmet,
  required String partePreview,
  required String simbolLabel,
}) {
  return _buildSectionShell(
    title: 'PARTE',
    child: pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFDE7'),
        border: pw.Border.all(color: PdfColor.fromHex('#BDBD9F')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (predmet.simbol != 'BEZ_SIMBOLA' && simbolLabel.isNotEmpty) ...[
            pw.Text(
              documentTextCodec.normalize('[ $simbolLabel ]'),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
          ],
          pw.Text(
            documentTextCodec.normalize(partePreview),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10.2, lineSpacing: 2.6),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _buildMiniBlock(String title, pw.Widget child) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          documentTextCodec.normalize(title),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: _kCompactBodyFontSize,
          ),
        ),
        pw.SizedBox(height: 4),
        child,
      ],
    ),
  );
}

pw.Widget _buildFieldList(List<ListaPdfLabelValue> fields) {
  final compact = _compactLabelValues(fields);
  if (compact.isEmpty) {
    return pw.Text(
      documentTextCodec.normalize('Nema evidentiranih podataka.'),
      style: pw.TextStyle(
        fontStyle: pw.FontStyle.italic,
        fontSize: _kCompactBodyFontSize,
        color: PdfColors.grey700,
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: compact
        .map(
          (field) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: _kFieldGap),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: documentTextCodec.normalize('${field.label}: '),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: _kCompactBodyFontSize,
                    ),
                  ),
                  pw.TextSpan(
                    text: documentTextCodec.normalize(field.value),
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

pw.Widget _buildIriuHeaderCell(
  String text,
  _IriuLayoutProfile profile, {
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
        fontSize: profile.headerFontSize,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _buildIriuBodyCell(
  String text,
  _IriuLayoutProfile profile, {
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
      style: pw.TextStyle(fontSize: profile.rowFontSize),
    ),
  );
}

pw.Widget _buildIriuCheckCell(_IriuLayoutProfile profile) {
  final side = _safeLayoutValue(profile.checkSize, fallback: 6.0);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Container(
        width: side,
        height: side,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey700, width: 0.7),
        ),
      ),
    ),
  );
}

pw.Widget _buildSectionShell({
  required String title,
  required pw.Widget child,
  bool fillChild = false,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey50,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            documentTextCodec.normalize(title),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: _kHeaderFontSize,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        fillChild ? pw.Expanded(child: child) : child,
      ],
    ),
  );
}

List<ListaPdfLabelValue> _compactLabelValues(List<ListaPdfLabelValue> values) {
  return values
      .where((value) => value.value.trim().isNotEmpty)
      .toList(growable: false);
}

double _safeDouble(double? value) {
  if (value == null || value.isNaN || value.isInfinite) {
    return 0.0;
  }
  return value;
}

double _safeLayoutValue(
  double? value, {
  required double fallback,
  double min = 0.0,
  double max = 1000.0,
}) {
  final safe = _safeDouble(value);
  if (safe <= min) return fallback;
  if (safe >= max) return max;
  return safe;
}








