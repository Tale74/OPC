import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../../core/utils/export_utils.dart';
import '../data/parte_media_store.dart';
import '../data/parte_preparation_repository.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_image_effects.dart';
import '../domain/parte_models.dart';

class PartePdfExportResult {
  const PartePdfExportResult({required this.file, required this.bytes});

  final KoriceFileEntry file;
  final Uint8List bytes;
}

class PartePdfRenderer {
  const PartePdfRenderer({required this.mediaStore});

  final ParteMediaStore mediaStore;

  Future<Uint8List> build({
    required ParteRenderPlan plan,
    double horizontalCorrectionMm = 0,
    double verticalCorrectionMm = 0,
  }) async {
    if (!plan.canGeneratePdf) {
      throw StateError('PARTE PDF ima nerešene blokere.');
    }
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final serif = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSerif-Variable.ttf'),
    );
    final fonts = <String, ({pw.Font regular, pw.Font bold})>{
      ParteFontCatalog.notoSans: (regular: regular, bold: bold),
      ParteFontCatalog.notoSerif: (regular: serif, bold: serif),
    };
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final document = pw.Document(
      title: 'PARTA',
      creator: 'OPC',
      producer: 'OPC',
      theme: theme,
    );
    final widgets = <pw.Widget>[];
    for (final block in plan.blocks) {
      widgets.add(
        await _buildBlock(
          block,
          fonts,
          horizontalCorrectionMm,
          verticalCorrectionMm,
        ),
      );
    }
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          plan.widthMm * PdfPageFormat.mm,
          plan.heightMm * PdfPageFormat.mm,
          marginAll: 0,
        ),
        theme: theme,
        build: (_) => pw.Stack(children: widgets),
      ),
    );
    return document.save();
  }

  Future<Uint8List> buildCalibration({required ParteRenderPlan plan}) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final document = pw.Document(
      title: 'OPC PARTE fizička kalibracija',
      creator: 'OPC',
    );
    const mm = PdfPageFormat.mm;
    final referenceWidth = plan.widthMm >= 120 ? 100.0 : 50.0;
    final referenceHeight = plan.heightMm >= 80 ? 50.0 : 25.0;
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          plan.widthMm * mm,
          plan.heightMm * mm,
          marginAll: 0,
        ),
        build: (_) => pw.Stack(
          children: [
            pw.Positioned.fill(
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              ),
            ),
            pw.Positioned(
              left: plan.printableZoneXmm * mm,
              top: plan.printableZoneYmm * mm,
              child: pw.Container(
                width: plan.printableZoneWidthMm * mm,
                height: plan.printableZoneHeightMm * mm,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.8, color: PdfColors.orange),
                ),
              ),
            ),
            pw.Positioned(
              left: (plan.printableZoneXmm + plan.horizontalMarginMm) * mm,
              top: (plan.printableZoneYmm + plan.verticalMarginMm) * mm,
              child: pw.Container(
                width:
                    (plan.printableZoneWidthMm - plan.horizontalMarginMm * 2) *
                    mm,
                height:
                    (plan.printableZoneHeightMm - plan.verticalMarginMm * 2) *
                    mm,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.8, color: PdfColors.red),
                ),
              ),
            ),
            pw.Positioned(
              left: (plan.printableZoneXmm + plan.horizontalMarginMm + 5) * mm,
              top: (plan.printableZoneYmm + plan.verticalMarginMm + 30) * mm,
              child: pw.Container(
                width: referenceWidth * mm,
                height: referenceHeight * mm,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1.2, color: PdfColors.blue),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${referenceWidth.toStringAsFixed(0)} × ${referenceHeight.toStringAsFixed(0)} mm',
                  style: pw.TextStyle(font: regular, fontSize: 12),
                ),
              ),
            ),
            for (var mark = 0; mark <= plan.widthMm.floor(); mark += 10)
              pw.Positioned(
                left: mark * mm,
                top: 0,
                child: pw.Container(
                  width: 0.4,
                  height: 4 * mm,
                  color: PdfColors.black,
                ),
              ),
            for (var mark = 0; mark <= plan.heightMm.floor(); mark += 10)
              pw.Positioned(
                left: 0,
                top: mark * mm,
                child: pw.Container(
                  width: 4 * mm,
                  height: 0.4,
                  color: PdfColors.black,
                ),
              ),
            pw.Positioned(
              left:
                  (plan.printableZoneXmm + plan.printableZoneWidthMm / 2) * mm,
              top: plan.printableZoneYmm * mm,
              child: pw.Container(
                width: 0.5,
                height: plan.printableZoneHeightMm * mm,
                color: PdfColors.blueGrey,
              ),
            ),
            pw.Positioned(
              left: plan.printableZoneXmm * mm,
              top:
                  (plan.printableZoneYmm + plan.printableZoneHeightMm / 2) * mm,
              child: pw.Container(
                width: plan.printableZoneWidthMm * mm,
                height: 0.5,
                color: PdfColors.blueGrey,
              ),
            ),
            pw.Positioned(
              left: (plan.printableZoneXmm + plan.horizontalMarginMm + 5) * mm,
              top: (plan.printableZoneYmm + plan.verticalMarginMm + 5) * mm,
              child: pw.SizedBox(
                width:
                    (plan.printableZoneWidthMm -
                        plan.horizontalMarginMm * 2 -
                        10) *
                    mm,
                child: pw.Text(
                  'OPC PARTE KALIBRACIJA – stranica '
                  '${plan.widthMm.toStringAsFixed(1)} × ${plan.heightMm.toStringAsFixed(1)} mm\n'
                  'Zona: X=${plan.printableZoneXmm.toStringAsFixed(1)}, '
                  'Y=${plan.printableZoneYmm.toStringAsFixed(1)}, '
                  '${plan.printableZoneWidthMm.toStringAsFixed(1)} × '
                  '${plan.printableZoneHeightMm.toStringAsFixed(1)} mm.\n'
                  'Narandžasta: zona štampe. Crvena: sigurna površina. Plava: poznata mera.\n'
                  'Štampati isključivo uz Actual size / 100%. Ne koristiti Fit, Shrink ili Scale to page.\n'
                  'Izmerite odstupanje preseka osa od centra obrasca: horizontalno (- levo / + desno) i vertikalno (- gore / + dole).',
                  style: pw.TextStyle(font: regular, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  Future<pw.Widget> _buildBlock(
    ParteRenderBlock block,
    Map<String, ({pw.Font regular, pw.Font bold})> fonts,
    double horizontalCorrectionMm,
    double verticalCorrectionMm,
  ) async {
    final rect = block.rect;
    final child = switch (block.kind) {
      ParteBlockKind.text => _textBlock(block, fonts),
      ParteBlockKind.photo || ParteBlockKind.symbol => await _imageBlock(block),
    };
    return pw.Positioned(
      left: (rect.x + horizontalCorrectionMm) * PdfPageFormat.mm,
      top: (rect.y + verticalCorrectionMm) * PdfPageFormat.mm,
      child: pw.SizedBox(
        width: rect.width * PdfPageFormat.mm,
        height: rect.height * PdfPageFormat.mm,
        child: child,
      ),
    );
  }

  pw.Widget _textBlock(
    ParteRenderBlock block,
    Map<String, ({pw.Font regular, pw.Font bold})> fonts,
  ) {
    final selected = fonts[ParteFontCatalog.safe(block.fontFamily)]!;
    final alignment = switch (block.alignment) {
      ParteTextAlign.left => pw.CrossAxisAlignment.start,
      ParteTextAlign.center => pw.CrossAxisAlignment.center,
      ParteTextAlign.right => pw.CrossAxisAlignment.end,
    };
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        for (final line in block.lines)
          pw.Transform(
            transform: Matrix4.diagonal3Values(block.horizontalScale, 1, 1),
            alignment: switch (block.alignment) {
              ParteTextAlign.left => pw.Alignment.centerLeft,
              ParteTextAlign.center => pw.Alignment.center,
              ParteTextAlign.right => pw.Alignment.centerRight,
            },
            child: pw.Text(
              line,
              maxLines: 1,
              softWrap: false,
              textAlign: switch (block.alignment) {
                ParteTextAlign.left => pw.TextAlign.left,
                ParteTextAlign.center => pw.TextAlign.center,
                ParteTextAlign.right => pw.TextAlign.right,
              },
              style: pw.TextStyle(
                font: block.bold ? selected.bold : selected.regular,
                fontSize: block.fontSize,
                height: 1.22,
                fontWeight: block.bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  Future<pw.Widget> _imageBlock(ParteRenderBlock block) async {
    final bytes = block.mediaKey != null
        ? await mediaStore.read(block.mediaKey!)
        : await rootBundle
              .load(block.assetPath!)
              .then(
                (data) => data.buffer.asUint8List(
                  data.offsetInBytes,
                  data.lengthInBytes,
                ),
              );
    final renderedBytes = applyParteImageEffects(bytes, block);
    pw.Widget image = pw.Image(
      pw.MemoryImage(renderedBytes),
      fit: pw.BoxFit.contain,
      alignment: pw.Alignment.center,
    );
    image = switch (block.imageShape) {
      ParteImageShape.rectangle => image,
      ParteImageShape.roundedRectangle => pw.ClipRRect(
        horizontalRadius: 8,
        verticalRadius: 8,
        child: image,
      ),
      ParteImageShape.oval => pw.ClipOval(child: image),
    };
    return pw.Container(
      decoration: block.border
          ? pw.BoxDecoration(border: pw.Border.all(width: block.borderWidth))
          : null,
      child: image,
    );
  }
}

class PartePdfExportService {
  const PartePdfExportService({
    required this.renderer,
    required this.repository,
  });

  final PartePdfRenderer renderer;
  final PartePreparationRepository repository;

  Future<PartePdfExportResult> export({
    required PartePripremeData preparation,
    required PredmetiData predmet,
    required ParteRenderPlan plan,
    required KorisniciData actor,
    required OpcEntitlementPolicy entitlement,
    double horizontalCorrectionMm = 0,
    double verticalCorrectionMm = 0,
  }) async {
    if (preparation.previewConfirmedFingerprint != plan.fingerprint) {
      throw StateError('Potvrdite aktuelni pregled pripreme pre PDF izvoza.');
    }
    final bytes = await renderer.build(
      plan: plan,
      horizontalCorrectionMm: horizontalCorrectionMm,
      verticalCorrectionMm: verticalCorrectionMm,
    );
    final filename = koricePdfDerivatFajlNaziv(
      predmet,
      'PARTA',
      includePredmetVersion: true,
    );
    final file = await sacuvajKoricePdfFajlDetalji(filename, bytes);
    final location = koriceFajlLokacija(file);
    await repository.recordSuccessfulExport(
      preparationId: preparation.id,
      plan: plan,
      filename: file.name,
      location: location,
      actor: actor,
      entitlement: entitlement,
    );
    return PartePdfExportResult(file: file, bytes: bytes);
  }

  Future<PartePdfExportResult> exportCalibration({
    required ParteRenderPlan plan,
  }) async {
    final bytes = await renderer.buildCalibration(plan: plan);
    final width = plan.widthMm.toStringAsFixed(1).replaceAll('.', '_');
    final height = plan.heightMm.toStringAsFixed(1).replaceAll('.', '_');
    final file = await sacuvajKoricePdfFajlDetalji(
      'OPC_PARTE_KALIBRACIJA_${width}x$height.pdf',
      bytes,
    );
    return PartePdfExportResult(file: file, bytes: bytes);
  }
}
