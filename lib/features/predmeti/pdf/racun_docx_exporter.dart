import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../../core/utils/document_text_codec.dart';
import '../../../core/utils/export_utils.dart';
import 'lista_pdf_data_builder.dart';
import 'memorandum_logo.dart';
import 'racun_document_data.dart';

const _racunDocxMimeType =
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

const _pageWidthDxa = 11906;
const _pageHeightDxa = 16838;
const _pageTopMarginDxa = 400;
const _pageRightMarginDxa = 480;
const _pageBottomMarginDxa = 320;
const _pageLeftMarginDxa = 480;
const _documentWidthDxa =
    _pageWidthDxa - _pageLeftMarginDxa - _pageRightMarginDxa;

const _noTableBorders =
    '<w:top w:val="nil"/><w:left w:val="nil"/>'
    '<w:bottom w:val="nil"/><w:right w:val="nil"/>'
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>';

const _sectionTableBorders =
    '<w:top w:val="single" w:sz="5" w:color="B8C2CC"/>'
    '<w:left w:val="single" w:sz="5" w:color="B8C2CC"/>'
    '<w:bottom w:val="single" w:sz="5" w:color="B8C2CC"/>'
    '<w:right w:val="single" w:sz="5" w:color="B8C2CC"/>'
    '<w:insideH w:val="single" w:sz="4" w:color="D3D9DE"/>'
    '<w:insideV w:val="single" w:sz="4" w:color="D3D9DE"/>';

Future<void> izvoziRacunDocx({
  required BuildContext ctx,
  required AppDatabase db,
  required int predmetId,
}) async {
  try {
    final data = await RacunDocumentData.load(db: db, predmetId: predmetId);
    final bytes = await buildRacunDocx(data);
    final file = await sacuvajKoriceDokumentFajlDetalji(
      data.filenameFor('docx'),
      bytes,
      mimeType: _racunDocxMimeType,
    );
    if (!ctx.mounted) return;
    prikaziPdfExportSuccessSnackBar(
      ctx,
      poruka: 'RAČUN sačuvan: ${koriceFajlLokacija(file)}',
      fajl: file,
    );
  } catch (error) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Greška pri DOCX izvozu RAČUNA: $error'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      ),
    );
  }
}

/// Builds editable OOXML directly from the shared RAČUN snapshot.
///
/// The PDF remains the visual authority. This adapter mirrors its section and
/// column geometry while keeping business meaning in [RacunDocumentData].
Future<Uint8List> buildRacunDocx(RacunDocumentData data) async {
  final archive = Archive();
  final relationships = <String>[
    '<Relationship Id="rIdStyles" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
        'Target="styles.xml"/>',
    '<Relationship Id="rIdFooter" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" '
        'Target="footer1.xml"/>',
  ];

  var logoDrawing = '';
  final logo = data.firma.logo;
  if (logo != null && logo.isNotEmpty) {
    final decoded = img.decodeImage(logo);
    if (decoded == null) {
      throw const FormatException('FIRMA logo nije moguće čitati za DOCX.');
    }
    final png = Uint8List.fromList(img.encodePng(decoded));
    archive.addFile(ArchiveFile('word/media/firma_logo.png', png.length, png));
    relationships.add(
      '<Relationship Id="rIdFirmaLogo" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
      'Target="media/firma_logo.png"/>',
    );
    logoDrawing = _floatingLogoDrawing(decoded.width / decoded.height);
  }

  final body = <String>[
    _memorandumAndIssueBlock(data, logoDrawing),
    _spacer(100),
    _deceasedBlock(data.deceasedHeading),
    if (data.payerTitle.trim().isNotEmpty) ...[_spacer(100), _payerBlock(data)],
    _spacer(100),
    _itemsAndFinancialBlock(data),
    _spacer(500),
    _signatureBlock(data),
  ];

  _addText(archive, '[Content_Types].xml', _contentTypes);
  _addText(archive, '_rels/.rels', _rootRelationships);
  _addText(archive, 'word/styles.xml', _styles);
  _addText(archive, 'word/footer1.xml', _footer(data));
  _addText(
    archive,
    'word/_rels/document.xml.rels',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '${relationships.join()}'
        '</Relationships>',
  );
  _addText(archive, 'word/document.xml', _document(body.join()));

  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded);
}

String _memorandumAndIssueBlock(RacunDocumentData data, String logoDrawing) {
  const leftWidth = 6900;
  const middleWidth = 300;
  const issueLeftWidth = 7200;
  const rightWidth = _documentWidthDxa - leftWidth;
  const issueRightWidth = _documentWidthDxa - issueLeftWidth;
  final companyLines = <String>[
    if (data.firma.adresa.trim().isNotEmpty) data.firma.adresa.trim(),
    if (_companyContact(data).isNotEmpty) _companyContact(data),
    ...buildMemorandumIdentityRows(
      pib: data.firma.pib,
      mb: data.firma.mb,
      racun: data.app.ziroRacun,
    ),
  ];
  final memoParagraphs = <String>[
    _paragraphWithDrawing(
      data.firma.naziv,
      logoDrawing,
      bold: true,
      fontSizeHalfPoints: 28,
      lineTwips: 360,
      afterTwips: 30,
    ),
    for (final line in companyLines)
      _paragraph(line, fontSizeHalfPoints: 16, lineTwips: 220, afterTwips: 15),
  ];

  final memorandumRow = _row([
    _cell(widthDxa: leftWidth, content: memoParagraphs.join()),
    _cell(
      widthDxa: rightWidth,
      content: logoDrawing.isEmpty
          ? _paragraph('', fontSizeHalfPoints: 2, lineTwips: 1)
          : _spacer(2400),
      gridSpan: 2,
    ),
  ]);
  final issueRow = _row(
    [
      _cell(
        widthDxa: issueLeftWidth,
        content: _paragraph(
          data.headerTitle,
          bold: true,
          fontSizeHalfPoints: 22,
          lineTwips: 280,
        ),
        gridSpan: 2,
      ),
      _cell(
        widthDxa: issueRightWidth,
        content: _paragraph(
          '${data.labels.issueDate} ${formatDateForDocument(data.issueDate)}',
          bold: true,
          fontSizeHalfPoints: 16,
          alignment: 'right',
          lineTwips: 240,
        ),
      ),
    ],
    tablePropertiesException:
        '<w:tblPrEx><w:tblBorders>'
        '<w:bottom w:val="single" w:sz="6" w:color="AEB7BF"/>'
        '</w:tblBorders><w:tblCellMar>'
        '<w:bottom w:w="100" w:type="dxa"/>'
        '</w:tblCellMar></w:tblPrEx>',
  );
  return _table(
    gridWidths: [leftWidth, middleWidth, issueRightWidth],
    rows: [memorandumRow, issueRow],
    borders: _noTableBorders,
    cellMarginsDxa: 0,
  );
}

String _companyContact(RacunDocumentData data) => <String>[
  if (data.firma.telefon.trim().isNotEmpty) data.firma.telefon.trim(),
  if (data.firma.email.trim().isNotEmpty) data.firma.email.trim(),
  if (data.firma.sajt.trim().isNotEmpty) data.firma.sajt.trim(),
].join(' | ');

String _deceasedBlock(String heading) {
  final row = _row([
    _cell(
      widthDxa: _documentWidthDxa,
      fill: 'EEF2F5',
      content: _paragraph(
        heading,
        bold: true,
        fontSizeHalfPoints: 18,
        lineTwips: 240,
      ),
    ),
  ]);
  return _table(
    gridWidths: [_documentWidthDxa],
    rows: [row],
    borders: _sectionTableBorders,
    cellMarginsDxa: 110,
  );
}

String _payerBlock(RacunDocumentData data) {
  const columnCount = 3;
  final widths = List<int>.generate(
    columnCount,
    (index) => index == columnCount - 1
        ? _documentWidthDxa - ((_documentWidthDxa ~/ columnCount) * 2)
        : _documentWidthDxa ~/ columnCount,
  );
  final header = _cell(
    widthDxa: _documentWidthDxa,
    gridSpan: columnCount,
    fill: 'EEF2F5',
    content: _paragraph(
      data.payerHeading,
      bold: true,
      fontSizeHalfPoints: 18,
      lineTwips: 240,
    ),
  );
  final rows = <String>[
    _row([header]),
  ];
  final columns = _splitIntoColumns(data.payerDetails, columnCount);
  if (columns.isEmpty) {
    rows.add(
      _row([
        _cell(
          widthDxa: _documentWidthDxa,
          gridSpan: columnCount,
          content: _paragraph(
            data.labels.emptyPayer,
            italic: true,
            fontSizeHalfPoints: 15,
            lineTwips: 220,
          ),
        ),
      ]),
    );
  } else {
    final rowCount = columns
        .map((column) => column.length)
        .reduce((a, b) => a > b ? a : b);
    for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final cells = <String>[];
      for (var columnIndex = 0; columnIndex < columnCount; columnIndex++) {
        final column = columnIndex < columns.length
            ? columns[columnIndex]
            : const <ListaPdfLabelValue>[];
        final detail = rowIndex < column.length ? column[rowIndex] : null;
        cells.add(
          _cell(
            widthDxa: widths[columnIndex],
            content: detail == null
                ? _paragraph('', fontSizeHalfPoints: 2, lineTwips: 1)
                : _fieldParagraph(
                    detail.label,
                    detail.value,
                    fontSizeHalfPoints: 15,
                    lineTwips: 210,
                  ),
          ),
        );
      }
      rows.add(_row(cells));
    }
  }
  return _table(
    gridWidths: widths,
    rows: rows,
    borders: _sectionTableBorders,
    cellMarginsDxa: 90,
  );
}

String _itemsAndFinancialBlock(RacunDocumentData data) {
  const leftWidth = (_documentWidthDxa * 3) ~/ 5;
  const rightWidth = _documentWidthDxa - leftWidth;
  final itemGrid = <int>[
    (leftWidth * 58) ~/ 100,
    (leftWidth * 14) ~/ 100,
    leftWidth - ((leftWidth * 58) ~/ 100) - ((leftWidth * 14) ~/ 100),
  ];
  final summaryGrid = <int>[
    (rightWidth * 64) ~/ 100,
    rightWidth - ((rightWidth * 64) ~/ 100),
  ];

  final header = _cell(
    widthDxa: _documentWidthDxa,
    gridSpan: 2,
    fill: 'E7EDF2',
    content: _paragraph(
      data.labels.itemsSection,
      bold: true,
      fontSizeHalfPoints: 18,
      lineTwips: 240,
    ),
  );
  final leftCell = _cell(
    widthDxa: leftWidth,
    content:
        _itemsTable(data, itemGrid) +
        _spacer(70) +
        _paragraph(
          data.labels.article33,
          fontSizeHalfPoints: 14,
          lineTwips: 180,
          keepLines: true,
        ),
  );
  final rightCell = _cell(
    widthDxa: rightWidth,
    content: _financialTable(data, summaryGrid) + _requiredTrailingParagraph(),
    verticalAlignment: 'top',
  );
  final contentRow = _row([leftCell, rightCell]);
  return _table(
    gridWidths: [leftWidth, rightWidth],
    rows: [
      _row([header]),
      contentRow,
    ],
    borders: _sectionTableBorders,
    cellMarginsDxa: 100,
  );
}

String _itemsTable(RacunDocumentData data, List<int> widths) {
  final rows = <String>[];
  if (data.items.isEmpty) {
    rows.add(
      _row([
        _cell(
          widthDxa: widths.reduce((a, b) => a + b),
          gridSpan: 3,
          fill: 'F1F4F6',
          content: _paragraph(
            data.labels.emptyItems,
            italic: true,
            fontSizeHalfPoints: 15,
            lineTwips: 210,
          ),
        ),
      ]),
    );
  } else {
    rows.add(
      _row([
        _cell(
          widthDxa: widths[0],
          fill: 'EEF2F5',
          content: _paragraph(
            data.labels.itemName,
            bold: true,
            fontSizeHalfPoints: 16,
            lineTwips: 210,
          ),
        ),
        _cell(
          widthDxa: widths[1],
          fill: 'EEF2F5',
          content: _paragraph(
            data.labels.itemQuantity,
            bold: true,
            fontSizeHalfPoints: 16,
            alignment: 'center',
            lineTwips: 210,
          ),
        ),
        _cell(
          widthDxa: widths[2],
          fill: 'EEF2F5',
          content: _paragraph(
            data.labels.itemAmount,
            bold: true,
            fontSizeHalfPoints: 16,
            alignment: 'right',
            lineTwips: 210,
          ),
        ),
      ]),
    );
    for (final item in data.items) {
      rows.add(
        _row([
          _cell(
            widthDxa: widths[0],
            content: _paragraph(
              item.naziv,
              fontSizeHalfPoints: 15,
              lineTwips: 210,
            ),
          ),
          _cell(
            widthDxa: widths[1],
            content: _paragraph(
              item.kom,
              fontSizeHalfPoints: 15,
              alignment: 'center',
              lineTwips: 210,
            ),
          ),
          _cell(
            widthDxa: widths[2],
            content: _paragraph(
              formatMoneyRsd(item.iznos),
              fontSizeHalfPoints: 15,
              alignment: 'right',
              lineTwips: 210,
            ),
          ),
        ]),
      );
    }
  }
  return _table(
    gridWidths: widths,
    rows: rows,
    borders: _sectionTableBorders,
    cellMarginsDxa: 70,
  );
}

String _financialTable(RacunDocumentData data, List<int> widths) {
  final rows = <String>[];
  for (final row in data.financialRows) {
    if (row.kind == ListaPdfRowKind.divider) {
      rows.add(
        _row([
          _cell(
            widthDxa: widths.reduce((a, b) => a + b),
            gridSpan: 2,
            content:
                '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" '
                'w:sz="6" w:color="AEB7BF"/></w:pBdr>'
                '<w:spacing w:before="0" w:after="0" w:line="30" '
                'w:lineRule="exact"/></w:pPr><w:r><w:t></w:t></w:r></w:p>',
          ),
        ]),
      );
      continue;
    }

    final emphasis = row.kind == ListaPdfRowKind.emphasis;
    final size = emphasis ? 18 : 15;
    rows.add(
      _row([
        _cell(
          widthDxa: widths[0],
          content: _paragraph(
            row.label,
            bold: true,
            fontSizeHalfPoints: size,
            lineTwips: 210,
          ),
        ),
        _cell(
          widthDxa: widths[1],
          content: _paragraph(
            row.value,
            bold: true,
            fontSizeHalfPoints: size,
            alignment: 'right',
            lineTwips: 210,
          ),
        ),
      ]),
    );
  }
  return _table(
    gridWidths: widths,
    rows: rows,
    borders: _sectionTableBorders,
    cellMarginsDxa: 55,
  );
}

String _signatureBlock(RacunDocumentData data) {
  const widths = [2000, 3600];
  final emptyCell = _cell(
    widthDxa: widths[0],
    content: _paragraph('', fontSizeHalfPoints: 2, lineTwips: 1),
  );
  final lineCell = _cell(
    widthDxa: widths[1],
    content: _paragraph('', fontSizeHalfPoints: 2, lineTwips: 1),
    borders:
        '<w:top w:val="nil"/><w:left w:val="nil"/>'
        '<w:bottom w:val="single" w:sz="8" w:color="70777D"/>'
        '<w:right w:val="nil"/>',
  );
  final labelCell = _cell(
    widthDxa: widths[0],
    content: _paragraph('', fontSizeHalfPoints: 2, lineTwips: 1),
  );
  final labelsCell = _cell(
    widthDxa: widths[1],
    content: _table(
      gridWidths: [3000, 600],
      rows: [
        _row([
          _cell(
            widthDxa: 3000,
            content: _paragraph(
              data.labels.signature,
              fontSizeHalfPoints: 15,
              alignment: 'center',
              lineTwips: 210,
            ),
          ),
          _cell(
            widthDxa: 600,
            content: _paragraph(
              data.labels.stamp,
              fontSizeHalfPoints: 15,
              alignment: 'right',
              lineTwips: 210,
            ),
          ),
        ]),
      ],
      borders: _noTableBorders,
      cellMarginsDxa: 0,
    ) +
        _requiredTrailingParagraph(),
  );
  return _table(
    gridWidths: widths,
    rows: [
      _row([emptyCell, lineCell]),
      _row([labelCell, labelsCell]),
    ],
    borders: _noTableBorders,
    justification: 'center',
    cellMarginsDxa: 0,
  );
}

String _footer(RacunDocumentData data) {
  const leftWidth = 3400;
  const centerWidth = 3400;
  const rightWidth = _documentWidthDxa - leftWidth - centerWidth;
  final rows = [
    _row([
      _cell(
        widthDxa: leftWidth,
        content: _paragraph(
          data.advisorFooter,
          fontSizeHalfPoints: 17,
          lineTwips: 220,
        ),
      ),
      _cell(
        widthDxa: centerWidth,
        content:
            '<w:p>${_paragraphProperties(alignment: 'center', lineTwips: 220)}'
            '${_simpleField(' PAGE ', '1', 17)}'
            '${_run('/', fontSizeHalfPoints: 17)}'
            '${_simpleField(' NUMPAGES ', '1', 17)}</w:p>',
      ),
      _cell(
        widthDxa: rightWidth,
        content: _paragraph(
          data.statusFooter,
          fontSizeHalfPoints: 17,
          alignment: 'right',
          lineTwips: 220,
        ),
      ),
    ]),
  ];
  const topRule =
      '<w:top w:val="single" w:sz="6" w:color="AEB7BF"/>'
      '<w:left w:val="nil"/><w:bottom w:val="nil"/>'
      '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>';
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '${_table(gridWidths: [leftWidth, centerWidth, rightWidth], rows: rows, borders: topRule, cellMarginsDxa: 0, topCellMarginDxa: 100)}'
      '</w:ftr>';
}

String _floatingLogoDrawing(double aspectRatio) {
  const maxWidthEmu = memorandumLogoWidth * 12700;
  const maxHeightEmu = memorandumLogoHeight * 12700;
  final width = aspectRatio >= maxWidthEmu / maxHeightEmu
      ? maxWidthEmu.round()
      : (maxHeightEmu * aspectRatio).round();
  final height = aspectRatio >= maxWidthEmu / maxHeightEmu
      ? (maxWidthEmu / aspectRatio).round()
      : maxHeightEmu.round();
  final x = _dxaToEmu(_pageWidthDxa - _pageRightMarginDxa) - width;
  final y = _dxaToEmu(_pageTopMarginDxa);
  return '<wp:anchor distT="0" distB="0" distL="0" distR="0" '
      'simplePos="0" relativeHeight="251658240" behindDoc="1" '
      'locked="0" layoutInCell="0" allowOverlap="1">'
      '<wp:simplePos x="0" y="0"/>'
      '<wp:positionH relativeFrom="page"><wp:posOffset>$x</wp:posOffset></wp:positionH>'
      '<wp:positionV relativeFrom="page"><wp:posOffset>$y</wp:posOffset></wp:positionV>'
      '<wp:extent cx="$width" cy="$height"/>'
      '<wp:effectExtent l="0" t="0" r="0" b="0"/>'
      '<wp:wrapNone/><wp:docPr id="1" name="FIRMA logo"/>'
      '<wp:cNvGraphicFramePr/><a:graphic>'
      '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
      '<pic:pic><pic:nvPicPr><pic:cNvPr id="1" name="firma_logo.png"/>'
      '<pic:cNvPicPr/></pic:nvPicPr>'
      '<pic:blipFill><a:blip r:embed="rIdFirmaLogo"/>'
      '<a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
      '<pic:spPr><a:xfrm><a:off x="0" y="0"/>'
      '<a:ext cx="$width" cy="$height"/></a:xfrm>'
      '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
      '</pic:pic></a:graphicData></a:graphic></wp:anchor>';
}

String _paragraphWithDrawing(
  String value,
  String drawing, {
  bool bold = false,
  required int fontSizeHalfPoints,
  required int lineTwips,
  int afterTwips = 0,
}) =>
    '<w:p>${_paragraphProperties(afterTwips: afterTwips, lineTwips: lineTwips)}'
    '${_run(value, bold: bold, fontSizeHalfPoints: fontSizeHalfPoints)}'
    '${drawing.isEmpty ? '' : '<w:r><w:drawing>$drawing</w:drawing></w:r>'}'
    '</w:p>';

String _paragraph(
  String value, {
  bool bold = false,
  bool italic = false,
  int fontSizeHalfPoints = 16,
  String? alignment,
  int beforeTwips = 0,
  int afterTwips = 0,
  int lineTwips = 220,
  bool keepLines = false,
}) =>
    '<w:p>${_paragraphProperties(alignment: alignment, beforeTwips: beforeTwips, afterTwips: afterTwips, lineTwips: lineTwips, keepLines: keepLines)}'
    '${_run(value, bold: bold, italic: italic, fontSizeHalfPoints: fontSizeHalfPoints)}'
    '</w:p>';

String _fieldParagraph(
  String label,
  String value, {
  required int fontSizeHalfPoints,
  required int lineTwips,
}) =>
    '<w:p>${_paragraphProperties(lineTwips: lineTwips)}'
    '${_run('$label: ', bold: true, fontSizeHalfPoints: fontSizeHalfPoints)}'
    '${_run(value, fontSizeHalfPoints: fontSizeHalfPoints)}'
    '</w:p>';

String _paragraphProperties({
  String? alignment,
  int beforeTwips = 0,
  int afterTwips = 0,
  int lineTwips = 220,
  bool keepLines = false,
}) {
  final props = StringBuffer('<w:pPr>');
  if (keepLines) props.write('<w:keepLines/>');
  props.write(
    '<w:spacing w:before="$beforeTwips" w:after="$afterTwips" '
    'w:line="$lineTwips" w:lineRule="exact"/>',
  );
  if (alignment != null) props.write('<w:jc w:val="$alignment"/>');
  props.write('</w:pPr>');
  return props.toString();
}

String _run(
  String value, {
  bool bold = false,
  bool italic = false,
  int fontSizeHalfPoints = 16,
}) {
  final properties = StringBuffer(
    '<w:rPr><w:rFonts w:ascii="Noto Sans" w:hAnsi="Noto Sans" '
    'w:eastAsia="Noto Sans" w:cs="Noto Sans"/>',
  );
  if (bold) properties.write('<w:b/>');
  if (italic) properties.write('<w:i/>');
  properties.write(
    '<w:sz w:val="$fontSizeHalfPoints"/><w:szCs w:val="$fontSizeHalfPoints"/>'
    '<w:lang w:val="sr-Latn-RS"/></w:rPr>',
  );
  final text = _xml(documentTextCodec.normalize(value));
  return '<w:r>${properties.toString()}<w:t xml:space="preserve">$text</w:t></w:r>';
}

String _simpleField(String instruction, String value, int fontSizeHalfPoints) =>
    '<w:fldSimple w:instr="$instruction">'
    '${_run(value, fontSizeHalfPoints: fontSizeHalfPoints)}'
    '</w:fldSimple>';

String _row(
  List<String> cells, {
  String? tablePropertiesException,
}) =>
    '<w:tr>${tablePropertiesException ?? ''}'
    '<w:trPr><w:cantSplit/></w:trPr>${cells.join()}</w:tr>';

String _cell({
  required int widthDxa,
  required String content,
  int? gridSpan,
  String? fill,
  String? borders,
  String verticalAlignment = 'center',
}) {
  final properties = StringBuffer(
    '<w:tcPr><w:tcW w:w="$widthDxa" w:type="dxa"/>',
  );
  if (gridSpan != null) properties.write('<w:gridSpan w:val="$gridSpan"/>');
  if (fill != null) {
    properties.write('<w:shd w:val="clear" w:color="auto" w:fill="$fill"/>');
  }
  if (borders != null) properties.write('<w:tcBorders>$borders</w:tcBorders>');
  properties.write('<w:vAlign w:val="$verticalAlignment"/></w:tcPr>');
  return '<w:tc>${properties.toString()}$content</w:tc>';
}

String _table({
  required List<int> gridWidths,
  required List<String> rows,
  String borders = _noTableBorders,
  String justification = 'left',
  int cellMarginsDxa = 70,
  int? topCellMarginDxa,
  int? bottomCellMarginDxa,
}) {
  final width = gridWidths.fold<int>(0, (sum, current) => sum + current);
  final grid = gridWidths.map((value) => '<w:gridCol w:w="$value"/>').join();
  final top = topCellMarginDxa ?? cellMarginsDxa;
  final bottom = bottomCellMarginDxa ?? cellMarginsDxa;
  return '<w:tbl><w:tblPr>'
      '<w:tblW w:w="$width" w:type="dxa"/>'
      '<w:jc w:val="$justification"/>'
      '<w:tblBorders>$borders</w:tblBorders>'
      '<w:tblLayout w:type="fixed"/>'
      '<w:tblCellMar><w:top w:w="$top" w:type="dxa"/>'
      '<w:left w:w="$cellMarginsDxa" w:type="dxa"/>'
      '<w:bottom w:w="$bottom" w:type="dxa"/>'
      '<w:right w:w="$cellMarginsDxa" w:type="dxa"/></w:tblCellMar>'
      '</w:tblPr><w:tblGrid>$grid</w:tblGrid>${rows.join()}</w:tbl>';
}

List<List<ListaPdfLabelValue>> _splitIntoColumns(
  List<ListaPdfLabelValue> values,
  int columnCount,
) {
  if (values.isEmpty) return const <List<ListaPdfLabelValue>>[];
  final normalizedCount = values.length < columnCount
      ? values.length
      : columnCount;
  final perColumn = (values.length / normalizedCount).ceil();
  final columns = <List<ListaPdfLabelValue>>[];
  for (var i = 0; i < values.length; i += perColumn) {
    final end = (i + perColumn) > values.length ? values.length : i + perColumn;
    columns.add(List<ListaPdfLabelValue>.unmodifiable(values.sublist(i, end)));
  }
  return List<List<ListaPdfLabelValue>>.unmodifiable(columns);
}

String _spacer(int lineTwips) =>
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" '
    'w:line="$lineTwips" w:lineRule="exact"/></w:pPr>'
    '<w:r><w:rPr><w:sz w:val="2"/></w:rPr><w:t></w:t></w:r></w:p>';

String _requiredTrailingParagraph() =>
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" '
    'w:line="1" w:lineRule="exact"/></w:pPr>'
    '<w:r><w:rPr><w:sz w:val="2"/></w:rPr><w:t></w:t></w:r></w:p>';

int _dxaToEmu(int dxa) => dxa * 635;

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

String _document(String body) =>
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
    'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
    'xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
    '<w:body>$body<w:sectPr>'
    '<w:footerReference w:type="default" r:id="rIdFooter"/>'
    '<w:pgSz w:w="$_pageWidthDxa" w:h="$_pageHeightDxa"/>'
    '<w:pgMar w:top="$_pageTopMarginDxa" w:right="$_pageRightMarginDxa" '
    'w:bottom="$_pageBottomMarginDxa" w:left="$_pageLeftMarginDxa" '
    'w:header="200" w:footer="280" w:gutter="0"/>'
    '</w:sectPr></w:body></w:document>';

const _contentTypes =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Default Extension="png" ContentType="image/png"/>'
    '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
    '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
    '<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>'
    '</Types>';

const _rootRelationships =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
    '</Relationships>';

const _styles =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Noto Sans" '
    'w:hAnsi="Noto Sans" w:eastAsia="Noto Sans" w:cs="Noto Sans"/>'
    '<w:sz w:val="16"/><w:szCs w:val="16"/></w:rPr></w:rPrDefault>'
    '<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" '
    'w:line="220" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>'
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
    '<w:name w:val="Normal"/><w:qFormat/><w:rPr><w:rFonts w:ascii="Noto Sans" '
    'w:hAnsi="Noto Sans" w:eastAsia="Noto Sans" w:cs="Noto Sans"/>'
    '<w:sz w:val="16"/><w:szCs w:val="16"/></w:rPr></w:style>'
    '</w:styles>';
