import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/database.dart';
import '../../../core/utils/document_text_codec.dart';
import '../../../core/utils/export_utils.dart';
import '../data/iriu_repository.dart';
import 'memorandum_logo.dart';
import 'opc_pdf_shared.dart';

const _kTitle = 'NALOG CVEĆARI';
const _kFileTitle = 'NALOG_CVECARI';

class NalogCvecariPdfFlower {
  const NalogCvecariPdfFlower({
    required this.articleName,
    required this.ribbonText,
    this.imageBytes,
  });

  final String articleName;
  final String ribbonText;
  final Uint8List? imageBytes;
}

class NalogCvecariPdfPreparedData {
  const NalogCvecariPdfPreparedData({
    required this.fullName,
    required this.godinaRodjenja,
    required this.vrstaCeremonije,
    required this.mestoCeremonije,
    required this.datumCeremonije,
    required this.vremeCeremonije,
    required this.flowers,
  });

  final String fullName;
  final String godinaRodjenja;
  final String vrstaCeremonije;
  final String mestoCeremonije;
  final String datumCeremonije;
  final String vremeCeremonije;
  final List<NalogCvecariPdfFlower> flowers;
}

Future<void> izvoziNalogCvecariPdf({
  required BuildContext ctx,
  required AppDatabase db,
  required int predmetId,
}) async {
  try {
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final iriu = await IriuRepository(db).getIriu(predmetId);
    final firma = await (db.select(
      db.firmaPodaci,
    )..where((row) => row.id.equals(1))).getSingle();
    final app = await (db.select(
      db.appPodesavanja,
    )..where((row) => row.id.equals(1))).getSingle();
    final savetnik = predmet.savetnikId == null
        ? null
        : await (db.select(db.korisnici)
              ..where((row) => row.id.equals(predmet.savetnikId!)))
            .getSingleOrNull();
    final katalog = await db.select(db.katalogArtikli).get();
    final prepared = await _prepare(
      predmet: predmet,
      iriu: iriu,
      katalog: katalog,
    );
    final bytes = await _buildPdf(
      firma: firma,
      app: app,
      savetnikIme: documentTextCodec.normalize(
        resolveSavetnikDisplayName(
          localUser: savetnik,
          portableName: predmet.businessResponsibleName,
        ),
      ),
      status: predmet.status,
      dokumentVerzija: 'v${predmet.verzija}',
      prepared: prepared,
    );
    final naziv = koricePdfDerivatFajlNaziv(
      predmet,
      _kFileTitle,
      includePredmetVersion: true,
    );
    final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);
    if (!ctx.mounted) return;
    final poruka = 'NALOG CVEĆARI sačuvan: ${koriceFajlLokacija(fajl)}';
    prikaziPdfExportSuccessSnackBar(ctx, poruka: poruka, fajl: fajl);
  } catch (error) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Greška pri izvozu NALOGA CVEĆARI: $error'),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

/// Source/test seam for the current-PREDMET/current-IRiU derivative contract.
Future<NalogCvecariPdfPreparedData> pripremiNalogCvecariPdfPodatke({
  required PredmetiData predmet,
  required List<IriuData> iriu,
  required List<KatalogArtikliData> katalog,
}) => _prepare(predmet: predmet, iriu: iriu, katalog: katalog);

Future<Uint8List> buildNalogCvecariPdfBytes({
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required String savetnikIme,
  required String status,
  required String dokumentVerzija,
  required NalogCvecariPdfPreparedData prepared,
}) => _buildPdf(
      firma: firma,
      app: app,
      savetnikIme: savetnikIme,
      status: status,
      dokumentVerzija: dokumentVerzija,
      prepared: prepared,
    );

String nalogCvecariRibbonValueForPdf(String raw) =>
    documentTextCodec.normalize(raw.trim());

Future<NalogCvecariPdfPreparedData> _prepare({
  required PredmetiData predmet,
  required List<IriuData> iriu,
  required List<KatalogArtikliData> katalog,
}) async {
  final flowers = iriu.where((row) => row.interniNaziv == 'CVECE').toList();
  final result = <NalogCvecariPdfFlower>[];
  for (final row in flowers) {
    KatalogArtikliData? article;
    for (final candidate in katalog) {
      if (candidate.stableArticleId == row.katalogStableArticleId ||
          (candidate.naziv.trim().isNotEmpty &&
              candidate.naziv.trim() == row.nazivPrikaz.trim())) {
        article = candidate;
        break;
      }
    }
    Uint8List? image = article?.fotografija;
    if ((image == null || image.isEmpty) &&
        (article?.fotografijaPath?.trim().isNotEmpty ?? false)) {
      try {
        image = (await rootBundle.load(article!.fotografijaPath!.trim()))
            .buffer
            .asUint8List();
      } on Object {
        image = null;
      }
    }
    result.add(
      NalogCvecariPdfFlower(
        articleName: row.nazivPrikaz.trim().isEmpty
            ? 'CVEĆE'
            : row.nazivPrikaz.trim(),
        ribbonText: row.tekstTrake ?? '',
        imageBytes: image,
      ),
    );
  }
  return NalogCvecariPdfPreparedData(
    fullName: _join([predmet.ime, predmet.prezime]),
    godinaRodjenja: _extractYear(predmet.datumRodjenja),
    vrstaCeremonije: _ceremonyLabel(predmet.vrstaCeremonije),
    mestoCeremonije: _display(predmet.groblje),
    datumCeremonije: _display(predmet.datumCeremonije),
    vremeCeremonije: _display(predmet.vremeCeremonije),
    flowers: List.unmodifiable(result),
  );
}

Future<Uint8List> _buildPdf({
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required String savetnikIme,
  required String status,
  required String dokumentVerzija,
  required NalogCvecariPdfPreparedData prepared,
}) async {
  final theme = await loadOpcPdfTheme();
  final doc = pw.Document(title: _kTitle, author: savetnikIme, theme: theme);
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 26),
        theme: theme,
      ),
      header: (_) => buildOpcMemorandumHeader(
        firma: firma,
        app: app,
        documentTitle: _kTitle,
        caseNumber: null,
      ),
      footer: (context) => buildOpcDocumentFooter(
        context: context,
        savetnikIme: savetnikIme,
        status: status,
        dokumentVerzija: dokumentVerzija,
      ),
      build: (_) => [
        _section('PODACI O PREMINULOM LICU', [
          _field('IME I PREZIME:', prepared.fullName),
          _field('GODINA ROĐENJA:', prepared.godinaRodjenja),
        ]),
        pw.SizedBox(height: 10),
        _section(nalogCvecariCeremonyHeading(prepared.vrstaCeremonije), [
          _field('Groblje:', prepared.mestoCeremonije),
          _field('Datum:', prepared.datumCeremonije),
          _field('Vreme:', prepared.vremeCeremonije),
        ]),
        pw.SizedBox(height: 10),
        _section(
          'IZABRANO CVEĆE',
          prepared.flowers.isEmpty
              ? [_field('CVEĆE:', '—')]
              : prepared.flowers.map(_flowerItemBlock).toList(growable: false),
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _section(String title, List<pw.Widget> children) => pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          buildOpcPastelSectionLabel(title),
          pw.SizedBox(height: 5),
          ...children,
        ],
      ),
    );

pw.Widget _field(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 170,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: opcPdfBodyFontSize)),
          ),
          pw.Expanded(
            child: pw.Text(
              documentTextCodec.normalize(value),
              style: const pw.TextStyle(fontSize: opcPdfBodyFontSize),
            ),
          ),
        ],
      ),
    );

pw.Widget _flowerItemBlock(NalogCvecariPdfFlower flower) => pw.Inseparable(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 44,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    documentTextCodec.normalize(flower.articleName),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: opcPdfBodyFontSize,
                    ),
                  ),
                  pw.SizedBox(height: 7),
                  pw.Text(
                    nalogCvecariRibbonValueForPdf(flower.ribbonText),
                    style: const pw.TextStyle(fontSize: opcPdfBodyFontSize),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(flex: 56, child: _imageBox(flower)),
          ],
        ),
      ),
    );

pw.Widget _imageBox(NalogCvecariPdfFlower flower) => pw.Container(
      height: 112,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.55),
      ),
      child: flower.imageBytes == null
          ? null
          : pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(2),
              child: pw.Image(
                pw.MemoryImage(flower.imageBytes!),
                fit: pw.BoxFit.contain,
              ),
            ),
    );

String _join(List<String> values) {
  final value = values.map((item) => item.trim()).where((item) => item.isNotEmpty).join(' ');
  return value.isEmpty ? '—' : value;
}

String _display(String value) => value.trim().isEmpty ? '—' : value.trim();

String _extractYear(String raw) {
  final trimmed = raw.trim();
  if (trimmed.length == 4 && int.tryParse(trimmed) != null) return trimmed;
  final parts = trimmed.split(RegExp(r'[./-]'));
  for (final part in parts.reversed) {
    if (part.length == 4 && int.tryParse(part) != null) return part;
  }
  return _display(trimmed);
}

String _ceremonyLabel(String raw) => switch (raw.trim()) {
      'SAHRANA' || 'SAHRANA_EKSPRES' => 'SAHRANA',
      'KREMACIJA' || 'KREMACIJA_EKSPRES' => 'KREMACIJA',
      'SMESTAJ_URNE' => 'SMESTAJ URNE',
      'RASIPANJE_PEPELA' => 'RASIPANJE PEPELA',
      _ => raw.trim().isEmpty ? 'SAHRANA' : raw.trim(),
    };

String nalogCvecariCeremonyHeading(String raw) => switch (raw.trim()) {
      'SAHRANA' || 'SAHRANA_EKSPRES' || 'Sahrana' => 'PODACI O SAHRANI',
      'KREMACIJA' || 'KREMACIJA_EKSPRES' || 'Kremacija' =>
        'PODACI O KREMACIJI',
      'SMESTAJ_URNE' || 'Smeštaj urne' => 'PODACI O SMEŠTAJU URNE',
      'RASIPANJE_PEPELA' || 'Rasipanje pepela' =>
        'PODACI O RASIPANJU PEPELA',
      _ => 'PODACI O CEREMONIJI',
    };
