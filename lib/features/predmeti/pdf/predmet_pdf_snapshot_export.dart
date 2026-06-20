import 'dart:convert';
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
import '../core_v2/models/iriu_truth_models.dart';
import '../core_v2/services/financial_truth_service.dart';
import '../core_v2/services/predmet_iriu_truth_service.dart';
import 'memorandum_logo.dart';

const _kPredmetPdfSnapshotTitle = 'PREDMET';
const _kLabelWidth = 150.0;
const _kSectionGap = 10.0;

Future<void> izvoziPredmetPdfSnapshot({
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

    final bytes = await _buildPredmetPdfSnapshot(
      predmet: predmet,
      iriuStavke: iriuStavke,
      firma: firma,
      app: app,
      savetnik: savetnik,
    );

    final naziv = _predmetPdfSnapshotFajlNaziv(predmet);
    final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);
    final lokacija = koriceFajlLokacija(fajl);


    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('PDF snapshot sačuvan: $lokacija'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'PDF snapshot sa\u010duvan: $lokacija',
      fajl: fajl,
    );
  } catch (e) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Greška pri PDF snapshot izvozu: $e'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

Future<Uint8List> _buildPredmetPdfSnapshot({
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

  final truthSnapshot = const PredmetIriuTruthService().evaluate(
    predmet: predmet,
    storedRows: iriuStavke,
  );
  final finansijskaOsnova =
      const FinancialTruthService().buildRobaIUsluge(truthSnapshot);
  final datumIzvoza = DateTime.now();
  final dokumentVerzija = 'v${predmet.verzija}';
  final savetnikIme = documentTextCodec.normalize(
    savetnik?.imePrezime.trim().isNotEmpty == true
        ? savetnik!.imePrezime
        : '',
  );

  final doc = pw.Document(
    title: _kPredmetPdfSnapshotTitle,
    author: savetnikIme,
    theme: theme,
  );

  final pageTheme = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(28, 34, 28, 34),
    theme: theme,
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (context) => context.pageNumber == 1
          ? _buildHeader(
              predmet: predmet,
              firma: firma,
              app: app,
              datumIzvoza: datumIzvoza,
            )
          : pw.SizedBox.shrink(),
      footer: (context) => _buildFooter(
        context: context,
        savetnikIme: savetnikIme,
        dokumentVerzija: dokumentVerzija,
      ),
      build: (context) => [
        ..._buildMetaSection(predmet),
        ..._buildPreminuloLiceSection(predmet),
        ..._buildNarucilacSection(predmet),
        ..._buildCeremonijaSection(predmet),
        ..._buildParteSection(predmet),
        ..._buildIriuSection(iriuStavke),
        ..._buildFinansijeSection(predmet, finansijskaOsnova),
      ],
    ),
  );

  return doc.save();
}

String _predmetPdfSnapshotFajlNaziv(PredmetiData predmet) {
  return koricePdfDerivatFajlNaziv(predmet, 'PREDMET');
}

pw.Widget _buildHeader({
  required PredmetiData predmet,
  required FirmaPodaciData firma,
  required AppPodesavanjaData app,
  required DateTime datumIzvoza,
}) {
  final contact = <String>[
    if (firma.telefon.trim().isNotEmpty) firma.telefon.trim(),
    if (firma.email.trim().isNotEmpty) firma.email.trim(),
    if (firma.sajt.trim().isNotEmpty) firma.sajt.trim(),
  ].join(' | ');

  final identitet = <String>[
    if (firma.pib.trim().isNotEmpty) 'PIB ${firma.pib.trim()}',
    if (firma.mb.trim().isNotEmpty) 'MB ${firma.mb.trim()}',
    if (app.ziroRacun.trim().isNotEmpty) 'Račun ${app.ziroRacun.trim()}',
  ].join(' | ');

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    padding: const pw.EdgeInsets.only(bottom: 10),
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
                      fontSize: 15,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    documentTextCodec.normalize(firma.adresa),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  if (contact.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      documentTextCodec.normalize(contact),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                  if (identitet.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      documentTextCodec.normalize(identitet),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ],
              ),
            ),
            if (firma.logo != null && firma.logo!.isNotEmpty)
              buildMemorandumLogo(
                firma.logo!,
                reservedWidth: 72,
                reservedHeight: 56,
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          _kPredmetPdfSnapshotTitle,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          _metadataLine(
            brojPredmeta: predmet.brojPredmeta,
            datumIzvoza: datumIzvoza,
            status: predmet.status,
          ),
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    ),
  );
}

pw.Widget _buildFooter({
  required pw.Context context,
  required String savetnikIme,
  required String dokumentVerzija,
}) {
  final imaViseStrana = context.pagesCount > 1;
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
      ),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'Savetnik: ${savetnikIme.trim()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.center,
            child: imaViseStrana
                ? pw.Text(
                    '${context.pageNumber}/${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9),
                  )
                : pw.SizedBox(),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Verzija predmeta: $dokumentVerzija',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    ),
  );
}

List<pw.Widget> _buildMetaSection(PredmetiData predmet) {
  return _buildSection(
    title: 'META',
    fields: [
      ('ID', predmet.id),
      ('BROJ PREDMETA', predmet.brojPredmeta),
      ('STATUS', predmet.status),
      ('DATUM KREIRANJA', predmet.datumKreiranja),
      ('SAVETNIK ID', predmet.savetnikId?.toString() ?? ''),
      ('VERZIJA PREDMETA', 'v${predmet.verzija}'),
      ('EXPORT VERZIJA', predmet.exportVerzija.toString()),
    ],
  );
}

List<pw.Widget> _buildPreminuloLiceSection(PredmetiData p) {
  return _buildSection(
    title: 'PREMINULO LICE',
    fields: [
      ('IME', p.ime),
      ('PREZIME', p.prezime),
      ('SREDNJE IME', p.srednje),
      ('DEVOJAČKO PREZIME', p.devojackoPrezime),
      ('JMBG', p.jmbg),
      ('POL', p.pol),
      ('DATUM ROĐENJA', p.datumRodjenja),
      ('MESTO ROĐENJA', p.mestoRodjenja),
      ('DATUM SMRTI', p.datumSmrti),
      ('MESTO SMRTI', p.mestoSmrti),
      ('UZROK SMRTI', p.uzrokSmrti),
      ('ADRESA', p.adresa),
      ('IME OCA', p.imeOca),
      ('IME MAJKE', p.imeMajke),
      ('BRAČNO STANJE', p.bracnoStanje),
      ('BRAČNI DRUG IME', p.bracniDrugIme),
      ('BRAČNI DRUG PREZIME', p.bracniDrugPrezime),
      ('BRAČNI DRUG POL', p.bracniDrugPol),
      ('BRAČNI DRUG JMBG', p.bracniDrugJmbg),
      ('BRAČNI DRUG DEVOJAČKO', p.bracniDrugDevojacko),
      ('ZANIMANJE', p.zanimanje),
      ('ZANIMANJE NA PARTI', _boolToDaNe(p.zanimanjeNaParti)),
      ('TITULA', p.titula),
      ('TITULA ISPRED', _boolToDaNe(p.titulaIspred)),
      ('ČIN', p.cin),
      ('ČIN NA PARTI', _boolToDaNe(p.cinNaParti)),
      ('SREDNJE NA PARTI', _boolToDaNe(p.srednjeNaParti)),
      ('NADIMAK', p.nadimak),
      ('NADIMAK NA PARTI', _boolToDaNe(p.nadimakNaParti)),
      ('NADIMAK CRTICA', _boolToDaNe(p.nadimakCrtica)),
      ('RADNI STATUS', _joinJsonOptions(p.radniStatus)),
      ('PENZIONER', p.penzioner),
      ('PENZIONER SRBIJE', p.penzionerSrbije),
      ('VOJNI PENZIONER', p.vojniPenzioner),
      ('VOJNE POČASTI', p.vojnePocasti),
      ('POSMRTNA POMOĆ', p.posmrtnaPomoc),
      ('REFUNDACIJA PIO', formatMoneyRsd(p.refundacijaPio)),
      ('NARUČILAC REFUNDIRA', p.narucilacRefundira),
      ('BRAČNI DRUG OSTVARUJE PRAVO', p.bracniDrugOstvarujePravo),
      ('BRAČNI DRUG JE PENZIONER', p.bracniDrugJePenzioner),
      ('PENZIONER NAPOMENA', p.penzionerNapomena),
    ],
  );
}

List<pw.Widget> _buildNarucilacSection(PredmetiData p) {
  return _buildSection(
    title: 'PLATILAC',
    fields: [
      ('TIP NARUČIOCA', p.naruTip),
      ('NARUČILAC IME', p.naruIme),
      ('NARUČILAC PREZIME', p.naruPrezime),
      ('NARUČILAC IME I PREZIME', p.naruImePrezime),
      ('NARUČILAC JMBG', p.naruJmbg),
      ('NARUČILAC ADRESA', p.naruAdresa),
      ('NARUČILAC BROJ LK', p.naruBrojLk),
      ('NARUČILAC TELEFON 1', p.naruTelefon1),
      ('NARUČILAC TELEFON 2', p.naruTelefon2),
      ('NARUČILAC EMAIL', p.naruEmail),
      ('NARUČILAC PRAVNO LICE NAZIV', p.naruPlNaziv),
      ('NARUČILAC PRAVNO LICE ADRESA', p.naruPlAdresa),
      ('NARUČILAC PRAVNO LICE PIB', p.naruPlPib),
      ('NARUČILAC PRAVNO LICE MB', p.naruPlMb),
      ('NARUČILAC PRAVNO LICE ODGOVORNO LICE', p.naruPlOdgovornoLice),
      ('NARUČILAC PRAVNO LICE TELEFON 1', p.naruPlTelefon1),
      ('NARUČILAC PRAVNO LICE TELEFON 2', p.naruPlTelefon2),
      ('NARUČILAC PRAVNO LICE EMAIL', p.naruPlEmail),
      ('NARUČILAC ISTI ZA JKP', _boolToDaNe(p.naruIstiZaJkp)),
      ('JKP TIP', p.jkpTip),
      ('JKP IME', p.jkpIme),
      ('JKP PREZIME', p.jkpPrezime),
      ('JKP IME I PREZIME', p.jkpImePrezime),
      ('JKP JMBG', p.jkpJmbg),
      ('JKP ADRESA', p.jkpAdresa),
      ('JKP BROJ LK', p.jkpBrojLk),
      ('JKP TELEFON 1', p.jkpTelefon1),
      ('JKP TELEFON 2', p.jkpTelefon2),
      ('JKP EMAIL', p.jkpEmail),
      ('JKP PRAVNO LICE NAZIV', p.jkpPlNaziv),
      ('JKP PRAVNO LICE ADRESA', p.jkpPlAdresa),
      ('JKP PRAVNO LICE PIB', p.jkpPlPib),
      ('JKP PRAVNO LICE MB', p.jkpPlMb),
      ('JKP PRAVNO LICE ODGOVORNO LICE', p.jkpPlOdgovornoLice),
      ('JKP PRAVNO LICE TELEFON 1', p.jkpPlTelefon1),
      ('JKP PRAVNO LICE EMAIL', p.jkpPlEmail),
    ],
  );
}

List<pw.Widget> _buildCeremonijaSection(PredmetiData p) {
  return _buildSection(
    title: 'POGREBNA CEREMONIJA',
    fields: [
      ('GROBLJE', p.groblje),
      ('TIP GROBLJA', p.tipGroblja),
      ('VRSTA CEREMONIJE', p.vrstaCeremonije),
      ('DATUM CEREMONIJE', p.datumCeremonije),
      ('VREME CEREMONIJE', p.vremeCeremonije),
      ('OPELO', p.opelo),
      ('OPELO MESTO', p.opeloMesto),
      ('VREME OPELA', p.vremeOpela),
      ('VREME ISPRAĆAJA', p.vremeIspracaja),
      ('GROBNO MESTO', p.grobnoMesto),
      ('TIP GROBNOG MESTA', p.tipGrobnogMesta),
      ('PARCELA', p.parcela),
      ('GROB BROJ', p.grobBroj),
      ('RED GROB', p.redGrob),
      ('NPK', p.npk),
      ('GROBNICA', p.grobnica),
      ('URNA ŠIFRA', p.urnaSifra),
      ('TIP POLAGANJA', p.tipPolaganja),
      ('URNA PARCELA', p.urnaParcela),
      ('URNA BROJ', p.urnaBroj),
      ('URNA RED', p.urnaRed),
      ('URNA NPK', p.urnaNpk),
      ('SAHRANA VAN SRBIJE', _boolToDaNe(p.sahranaVanSrbije)),
      ('SVIS ZEMLJA', p.svisZemlja),
      ('SVIS GRAD', p.svisGrad),
      ('DOČEK POSMRTNIH OSTATAKA', _boolToDaNe(p.docekPosmrtnihOstataka)),
      ('DOČEK MESTO', p.docekMesto),
      ('DOČEK VREME', p.docekVreme),
    ],
  );
}

List<pw.Widget> _buildParteSection(PredmetiData p) {
  return _buildSection(
    title: 'PARTE',
    fields: [
      ('SIMBOL', p.simbol),
      ('PISMO', p.pismo),
      ('PARTE IME', p.parteIme),
      ('OŽALOŠĆENI', p.ozaloseni),
    ],
  );
}

List<pw.Widget> _buildIriuSection(List<IriuData> stavke) {
  final widgets = <pw.Widget>[
    _sectionTitle('IRIU — IZABRANA ROBA I USLUGE'),
  ];

  if (stavke.isEmpty) {
    widgets.add(_fieldRow('STAVKE', ''));
    widgets.add(pw.SizedBox(height: _kSectionGap));
    return widgets;
  }

  for (final stavka in stavke) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _fieldRow('REDOSLED', stavka.redosled.toString()),
            _fieldRow('INTERNI NAZIV', stavka.interniNaziv),
            _fieldRow('NAZIV', stavka.nazivPrikaz),
            _fieldRow('KOM', stavka.kom),
            _fieldRow('IZNOS', formatMoneyRsd(stavka.iznos)),
            _fieldRow('ČEKIRAN', _boolToDaNe(stavka.cekiran)),
          ],
        ),
      ),
    );
  }

  widgets.add(pw.SizedBox(height: _kSectionGap));
  return widgets;
}

List<pw.Widget> _buildFinansijeSection(
  PredmetiData p,
  FinancialTruthBasis osnova,
) {
  final prikazRefundacije = p.penzionerSrbije == 'DA';
  final refund = prikazRefundacije && p.narucilacRefundira != 'DA'
      ? p.refundacijaPio
      : 0.0;
  final doplata = osnova.robaIUsluge - refund;
  final ostatak = p.avans > 0 ? doplata - p.avans : doplata;
  final jkp = p.jkpPlacaSamostalno ? 0.0 : p.troskoviJkp;
  final saJkp = ostatak + jkp;
  final zaNaplatu = saJkp - p.popust;

  return _buildSection(
    title: 'FINANSIJSKI PREGLED',
    fields: [
      ('AVANS', _formatDeductionMoney(p.avans)),
      ('TROŠKOVI JKP', formatMoneyRsd(p.troskoviJkp)),
      ('JKP PLAĆA SAMOSTALNO', _boolToDaNe(p.jkpPlacaSamostalno)),
      ('POPUST', formatMoneyRsd(p.popust)),
      ('NAČIN PLAĆANJA', _joinJsonOptions(p.nacinPlacanja)),
      ('NAPOMENA PLAĆANJA', p.napomenaPlacanja),
      ('NAPOMENA', p.napomena),
      ('ROBA I USLUGE', formatMoneyRsd(osnova.robaIUsluge)),
      ('REFUNDACIJA PIO', _formatDeductionMoney(refund)),
      ('DOPLATA', formatMoneyRsd(doplata)),
      ('OSTATAK', formatMoneyRsd(ostatak)),
      ('DODATAK JKP', formatMoneyRsd(jkp)),
      ('UKUPNO PRE POPUSTA', formatMoneyRsd(saJkp)),
      ('ZA NAPLATU', formatMoneyRsd(zaNaplatu)),
    ],
  );
}

List<pw.Widget> _buildSection({
  required String title,
  required List<(String, Object?)> fields,
}) {
  return [
    _sectionTitle(title),
    ...fields.map((field) => _fieldRow(field.$1, _formatValue(field.$2))),
    pw.SizedBox(height: _kSectionGap),
  ];
}

pw.Widget _sectionTitle(String title) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: const pw.BoxDecoration(
      color: PdfColors.blueGrey50,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(
      documentTextCodec.normalize(title),
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}

pw.Widget _fieldRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: _kLabelWidth,
          child: pw.Text(
            documentTextCodec.normalize(label),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            documentTextCodec.normalize(value),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}

String _metadataLine({
  required String brojPredmeta,
  required DateTime datumIzvoza,
  required String status,
}) {
  return 'Broj predmeta: $brojPredmeta | Datum izvoza: ${formatDateForDocument(datumIzvoza)} | Status: $status';
}

String _formatValue(Object? value) {
  if (value == null) return '';
  if (value is bool) return _boolToDaNe(value);
  if (value is double) return formatMoneyRsd(value);
  if (value is int) return value.toString();
  final text = value.toString();
  if (text.trim().isEmpty) return '';
  final parsedDate = DateTime.tryParse(text);
  if (parsedDate != null && text.contains('T')) {
    return '${formatDateForDocument(parsedDate)} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
  }
  return text;
}

String _formatDeductionMoney(double value) {
  if (value <= 0) {
    return formatMoneyRsd(value);
  }
  return '-${formatMoneyRsd(value)}';
}

String _boolToDaNe(bool value) => value ? 'DA' : 'NE';

String _joinJsonOptions(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      return decoded
          .map((value) => value?.toString() ?? '')
          .where((value) => value.trim().isNotEmpty)
          .join(', ');
    }
  } catch (_) {
    // Fallback below.
  }
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    final compact = trimmed.substring(1, trimmed.length - 1).trim();
    if (compact.isEmpty) return '';
    final decoded = compact
        .split(',')
        .map((part) => part.trim().replaceAll('"', ''))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return decoded.join(', ');
  }
  return raw;
}




