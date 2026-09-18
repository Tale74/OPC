import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../../../core/utils/document_text_codec.dart';
import '../../../../core/utils/export_utils.dart';
import '../data/citulje_preparation_repository.dart';
import '../domain/citulje_concrete_format_projection.dart' as projection;

const String cituljePdfTitle = 'ČITULJA';

/// The complete persisted input for one concrete ČITULJA PDF.
///
/// This is deliberately a small output snapshot. It contains no PREDMET,
/// PARTE, UI-controller, or technical occurrence identity presentation data.
class CituljaPdfPreparedData {
  const CituljaPdfPreparedData({
    required this.articleLabel,
    required this.publicationDate,
    required this.publicationText,
  });

  final String articleLabel;
  final String publicationDate;
  final String publicationText;
}

CituljaPdfPreparedData prepareCituljaPdfData(
  CituljePripremeData preparation, {
  IriuData? currentIriu,
}) {
  return CituljaPdfPreparedData(
    articleLabel: projection.resolveCituljeConcreteFormatDisplay(
      articleType: preparation.articleType,
      currentDisplayName: currentIriu?.nazivPrikaz,
    ),
    publicationDate: _documentDate(preparation.publicationDate),
    publicationText: documentTextCodec.normalize(preparation.publicationText),
  );
}

String cituljaArticleDisplayValue(String articleType) =>
    projection.cituljaArticleDisplayValue(articleType);

String _documentDate(String? value) {
  final parsed = parseDateValue(value);
  return parsed == null ? value?.trim() ?? '' : formatDateForDocument(parsed);
}

/// Builds only the canonical ČITULJA content. It is intentionally independent
/// of the memorandum/PREDMET PDF helpers.
Future<Uint8List> buildCituljaPdf(CituljaPdfPreparedData prepared) async {
  final regularFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
  );
  final boldFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
  );
  final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);
  final document = pw.Document(title: cituljePdfTitle, theme: theme);

  document.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 48, 42, 42),
        theme: theme,
      ),
      build: (_) => <pw.Widget>[
        _labelValue('Format čitulje:', prepared.articleLabel, boldFont),
        pw.SizedBox(height: 12),
        _labelValue('Datum objave:', prepared.publicationDate, boldFont),
        pw.SizedBox(height: 24),
        ..._publicationTextWidgets(prepared.publicationText),
      ],
    ),
  );

  return document.save();
}

List<pw.Widget> _publicationTextWidgets(String text) {
  final chunks = <String>[];
  for (final line in text.split('\n')) {
    if (line.isEmpty) {
      chunks.add('');
      continue;
    }
    var buffer = StringBuffer();
    for (final word in line.split(RegExp(r'(?<=\s)'))) {
      if (buffer.length + word.length > 900 && buffer.isNotEmpty) {
        chunks.add(buffer.toString());
        buffer = StringBuffer();
      }
      buffer.write(word);
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString());
  }
  return chunks
      .map(
        (chunk) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            chunk,
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
          ),
        ),
      )
      .toList(growable: false);
}

pw.Widget _labelValue(String label, String value, pw.Font boldFont) {
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: documentTextCodec.normalize('$label '),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: boldFont),
        ),
        pw.TextSpan(text: documentTextCodec.normalize(value)),
      ],
    ),
  );
}

String cituljaPdfFilename(
  PredmetiData predmet,
  CituljePripremeData preparation, {
  required Iterable<String> currentSameTypeOccurrenceIds,
}) {
  final occurrenceIds = currentSameTypeOccurrenceIds
      .map((id) => id.trim())
      .toList(growable: false);
  if (occurrenceIds.any((id) => id.isEmpty) ||
      occurrenceIds.toSet().length != occurrenceIds.length) {
    throw StateError(
      'ČITULJE current occurrences require unique portable identities.',
    );
  }

  final sortedOccurrenceIds = [...occurrenceIds]..sort();
  final occurrence = preparation.portableOccurrenceId.trim();
  final currentIndex = sortedOccurrenceIds.indexOf(occurrence);
  final suffix = currentIndex >= 0 && sortedOccurrenceIds.length > 1
      ? _alphabeticOccurrenceSuffix(currentIndex)
      : null;

  return joinFilenameParts([
    predmet.prezime,
    predmet.ime,
    predmet.brojPredmeta,
    cituljaArticleDisplayValue(preparation.articleType),
    ...(suffix == null ? const <String>[] : <String>[suffix]),
  ], 'pdf');
}

String _alphabeticOccurrenceSuffix(int zeroBasedIndex) {
  var value = zeroBasedIndex + 1;
  final letters = StringBuffer();
  while (value > 0) {
    value--;
    letters.writeCharCode('A'.codeUnitAt(0) + value % 26);
    value ~/= 26;
  }
  return letters.toString().split('').reversed.join();
}

/// Exports the current persisted preparation. Unsaved controller values are
/// intentionally not part of this operation.
Future<void> izvoziCituljaPdf({
  required BuildContext ctx,
  required AppDatabase db,
  required int preparationId,
}) async {
  try {
    final preparation = await (db.select(
      db.cituljePripreme,
    )..where((row) => row.id.equals(preparationId))).getSingle();
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(preparation.predmetId))).getSingle();
    final currentIriu = await CituljePreparationRepository(
      db,
    ).findCurrentIriuForPreparation(preparation);
    final currentSameTypeRows = await (db.select(db.iriu)..where(
          (row) =>
              row.predmetId.equals(preparation.predmetId) &
              row.interniNaziv.equals(preparation.articleType),
        ))
        .get();
    final currentSameTypeOccurrenceIds = currentSameTypeRows.map((row) {
      final occurrence = row.portableOccurrenceId?.trim();
      if (occurrence == null || occurrence.isEmpty) {
        throw StateError('ČITULJE occurrence nema portable identitet.');
      }
      return occurrence;
    });
    final bytes = await buildCituljaPdf(
      prepareCituljaPdfData(preparation, currentIriu: currentIriu),
    );
    final fajl = await sacuvajKoricePdfFajlDetalji(
      cituljaPdfFilename(
        predmet,
        preparation,
        currentSameTypeOccurrenceIds: currentSameTypeOccurrenceIds,
      ),
      bytes,
    );
    if (!ctx.mounted) return;
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'ČITULJA PDF sačuvan: ${koriceFajlLokacija(fajl)}',
      fajl: fajl,
    );
  } catch (error) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Greška pri ČITULJA PDF izvozu: $error'),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}
