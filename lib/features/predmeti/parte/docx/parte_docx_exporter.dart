import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import '../../../../core/database/database.dart';
import '../../../../core/utils/export_utils.dart';
import '../data/parte_media_store.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_image_effects.dart';
import '../domain/parte_models.dart';

class ParteDocxExportResult {
  const ParteDocxExportResult({required this.file, required this.bytes});

  final KoriceFileEntry file;
  final Uint8List bytes;
}

/// Creates a local, editable OOXML derivative. PDF remains the authoritative
/// WYSIWYG output and this exporter never changes preparation completion state.
class ParteDocxExporter {
  const ParteDocxExporter({required this.mediaStore});

  final ParteMediaStore mediaStore;

  Future<Uint8List> build({required ParteRenderPlan plan}) async {
    if (!plan.canGeneratePdf) {
      throw StateError('DOCX ima nerešene blokere kompozicije.');
    }
    final archive = Archive();
    final relationships = <String>[];
    final body = <String>[];
    var imageIndex = 0;
    final sorted = [...plan.blocks]
      ..sort((a, b) => a.rect.y.compareTo(b.rect.y));

    for (final block in sorted) {
      if (block.kind == ParteBlockKind.text) {
        body.add(_textParagraph(block));
        continue;
      }
      final source = block.mediaKey != null
          ? await mediaStore.read(block.mediaKey!)
          : await rootBundle
                .load(block.assetPath!)
                .then(
                  (data) => data.buffer.asUint8List(
                    data.offsetInBytes,
                    data.lengthInBytes,
                  ),
                );
      final effected = applyParteImageEffects(source, block);
      final decoded = img.decodeImage(effected);
      if (decoded == null) {
        throw const FormatException('DOCX medijski element nije čitljiv.');
      }
      final bytes = Uint8List.fromList(img.encodePng(decoded));
      imageIndex++;
      final relationId = 'rId$imageIndex';
      final mediaName = 'image$imageIndex.png';
      _addBytes(archive, 'word/media/$mediaName', bytes);
      relationships.add(
        '<Relationship Id="$relationId" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
        'Target="media/$mediaName"/>',
      );
      body.add(_imageParagraph(block, relationId, imageIndex));
    }

    _addText(archive, '[Content_Types].xml', _contentTypes);
    _addText(archive, '_rels/.rels', _rootRelationships);
    _addText(archive, 'word/styles.xml', _styles);
    _addText(
      archive,
      'word/_rels/document.xml.rels',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
          '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
          '${relationships.join()}'
          '<Relationship Id="rIdStyles" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
          'Target="styles.xml"/>'
          '</Relationships>',
    );
    _addText(archive, 'word/document.xml', _document(plan, body.join()));
    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  Future<ParteDocxExportResult> export({
    required ParteRenderPlan plan,
    required PredmetiData predmet,
  }) async {
    final bytes = await build(plan: plan);
    final filename = koriceDokumentDerivatFajlNaziv(
      predmet,
      'PARTA',
      'docx',
      includePredmetVersion: true,
    );
    final file = await sacuvajKoriceDokumentFajlDetalji(
      filename,
      bytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    return ParteDocxExportResult(file: file, bytes: bytes);
  }

  String _textParagraph(ParteRenderBlock block) {
    final align = switch (block.alignment) {
      ParteTextAlign.left => 'left',
      ParteTextAlign.center => 'center',
      ParteTextAlign.right => 'right',
    };
    final size = (block.fontSize * 2).round();
    final scale = (block.horizontalScale * 100).round();
    final font = _xml(ParteFontCatalog.displayName(block.fontFamily));
    final text = _xml(block.lines.join(' '));
    final left = (block.rect.x * 72 / 25.4).toStringAsFixed(3);
    final top = (block.rect.y * 72 / 25.4).toStringAsFixed(3);
    final width = (block.rect.width * 72 / 25.4).toStringAsFixed(3);
    final height = (block.rect.height * 72 / 25.4).toStringAsFixed(3);
    return '<w:p><w:r><w:pict><v:rect id="parte_${_xml(block.id)}" '
        'stroked="f" filled="f" '
        'style="position:absolute;margin-left:${left}pt;margin-top:${top}pt;'
        'width:${width}pt;height:${height}pt;z-index:${block.layer}">'
        '<v:textbox inset="0,0,0,0"><w:txbxContent>'
        '<w:p><w:pPr><w:jc w:val="$align"/><w:keepLines/></w:pPr>'
        '<w:r><w:rPr><w:rFonts w:ascii="$font" w:hAnsi="$font" '
        'w:eastAsia="$font" w:cs="$font"/><w:sz w:val="$size"/>'
        '<w:szCs w:val="$size"/><w:w w:val="$scale"/>'
        '${block.bold ? '<w:b/><w:bCs/>' : ''}</w:rPr>'
        '<w:t xml:space="preserve">$text</w:t></w:r></w:p>'
        '</w:txbxContent></v:textbox></v:rect></w:pict></w:r></w:p>';
  }

  String _imageParagraph(ParteRenderBlock block, String relationId, int id) {
    final width = (block.rect.width * 36000).round();
    final height = (block.rect.height * 36000).round();
    final x = (block.rect.x * 36000).round();
    final y = (block.rect.y * 36000).round();
    return '<w:p><w:r><w:drawing>'
        '<wp:anchor distT="0" distB="0" distL="0" distR="0" '
        'simplePos="0" relativeHeight="${block.layer}" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">'
        '<wp:simplePos x="0" y="0"/>'
        '<wp:positionH relativeFrom="page"><wp:posOffset>$x</wp:posOffset></wp:positionH>'
        '<wp:positionV relativeFrom="page"><wp:posOffset>$y</wp:posOffset></wp:positionV>'
        '<wp:extent cx="$width" cy="$height"/><wp:wrapNone/>'
        '<wp:docPr id="$id" name="PARTE element $id"/>'
        '<wp:cNvGraphicFramePr/>'
        '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">'
        '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        '<pic:nvPicPr><pic:cNvPr id="$id" name="image$id.png"/><pic:cNvPicPr/></pic:nvPicPr>'
        '<pic:blipFill><a:blip r:embed="$relationId"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        '<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="$width" cy="$height"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        '</pic:pic></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>';
  }

  String _document(ParteRenderPlan plan, String body) {
    final width = (plan.widthMm * 56.692913).round();
    final height = (plan.heightMm * 56.692913).round();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">'
        '<w:body>$body<w:sectPr><w:pgSz w:w="$width" w:h="$height" w:orient="landscape"/>'
        '<w:pgMar w:top="0" w:right="0" w:bottom="0" w:left="0" '
        'w:header="0" w:footer="0" w:gutter="0"/></w:sectPr></w:body></w:document>';
  }

  void _addText(Archive archive, String name, String value) =>
      _addBytes(archive, name, Uint8List.fromList(utf8.encode(value)));

  void _addBytes(Archive archive, String name, List<int> bytes) =>
      archive.addFile(ArchiveFile(name, bytes.length, bytes));

  String _xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static const _contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Default Extension="png" ContentType="image/png"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
      '</Types>';

  static const _rootRelationships =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '</Relationships>';

  static const _styles =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
      '<w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>'
      '<w:rPr><w:rFonts w:ascii="Noto Sans" w:hAnsi="Noto Sans"/></w:rPr></w:style></w:styles>';
}
