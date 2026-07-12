import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../../core/utils/export_utils.dart';
import '../data/parte_media_store.dart';
import '../data/parte_preparation_repository.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_models.dart';

class PartePdfExportResult {
  const PartePdfExportResult({required this.file, required this.bytes});

  final KoriceFileEntry file;
  final Uint8List bytes;
}

class PartePdfRenderer {
  const PartePdfRenderer({required this.mediaStore});

  final ParteMediaStore mediaStore;

  Future<Uint8List> build({required ParteRenderPlan plan}) async {
    if (!plan.canGeneratePdf) {
      throw StateError('PARTE PDF ima nerešene blokere.');
    }
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final document = pw.Document(
      title: 'PARTA',
      creator: 'OPC',
      producer: 'OPC',
      theme: theme,
    );
    final widgets = <pw.Widget>[];
    for (final block in plan.blocks) {
      widgets.add(await _buildBlock(block));
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

  Future<pw.Widget> _buildBlock(ParteRenderBlock block) async {
    final rect = block.rect;
    final child = switch (block.kind) {
      ParteBlockKind.text => _textBlock(block),
      ParteBlockKind.photo || ParteBlockKind.symbol => await _imageBlock(block),
    };
    return pw.Positioned(
      left: rect.x * PdfPageFormat.mm,
      top: rect.y * PdfPageFormat.mm,
      child: pw.SizedBox(
        width: rect.width * PdfPageFormat.mm,
        height: rect.height * PdfPageFormat.mm,
        child: child,
      ),
    );
  }

  pw.Widget _textBlock(ParteRenderBlock block) {
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
          pw.Text(
            line,
            maxLines: 1,
            softWrap: false,
            textAlign: switch (block.alignment) {
              ParteTextAlign.left => pw.TextAlign.left,
              ParteTextAlign.center => pw.TextAlign.center,
              ParteTextAlign.right => pw.TextAlign.right,
            },
            style: pw.TextStyle(
              fontSize: block.fontSize,
              height: 1.22,
              fontWeight: block.bold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
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
    return pw.Image(
      pw.MemoryImage(bytes),
      fit: pw.BoxFit.contain,
      alignment: pw.Alignment.center,
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
  }) async {
    if (preparation.previewConfirmedFingerprint != plan.fingerprint) {
      throw StateError('Potvrdite aktuelni finalni preview pre PDF izvoza.');
    }
    final bytes = await renderer.build(plan: plan);
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
}
