import 'package:flutter/material.dart';

import 'parte_models.dart';

enum ParteFitStatus { notApplicable, fitted, failed }

class ParteRenderBlock {
  const ParteRenderBlock({
    required this.id,
    required this.kind,
    required this.rect,
    required this.layer,
    this.lines = const [],
    this.fontSize = 0,
    this.bold = false,
    this.alignment = ParteTextAlign.center,
    this.fontFamily = ParteFontCatalog.notoSans,
    this.horizontalScale = 1,
    this.brightness = 1,
    this.contrast = 1,
    this.sharpness = 0,
    this.grayscale = false,
    this.border = false,
    this.borderWidth = 1,
    this.imageShape = ParteImageShape.rectangle,
    this.assetPath,
    this.mediaKey,
    this.minimumFontSize = 0,
    this.maximumFontSize = 0,
    this.fitStatus = ParteFitStatus.notApplicable,
    this.visible = true,
    this.exportEligible = true,
    this.sourceAspectRatio,
  });

  final String id;
  final ParteBlockKind kind;
  final ParteRectMm rect;
  final int layer;
  final List<String> lines;
  final double fontSize;
  final bool bold;
  final ParteTextAlign alignment;
  final String fontFamily;
  final double horizontalScale;
  final double brightness;
  final double contrast;
  final double sharpness;
  final bool grayscale;
  final bool border;
  final double borderWidth;
  final ParteImageShape imageShape;
  final String? assetPath;
  final String? mediaKey;
  final double minimumFontSize;
  final double maximumFontSize;
  final ParteFitStatus fitStatus;
  final bool visible;
  final bool exportEligible;
  final double? sourceAspectRatio;

  String get resolvedText => lines.join('\n');

  Map<String, Object?> toFingerprintJson() => {
    'id': id,
    'kind': kind.name,
    'rect': rect.toJson(),
    'layer': layer,
    'lines': lines,
    'fontSize': fontSize,
    'bold': bold,
    'alignment': alignment.name,
    'fontFamily': fontFamily,
    'horizontalScale': horizontalScale,
    'brightness': brightness,
    'contrast': contrast,
    'sharpness': sharpness,
    'grayscale': grayscale,
    'border': border,
    'borderWidth': borderWidth,
    'imageShape': imageShape.name,
    'assetPath': assetPath,
    'mediaKey': mediaKey,
    'minimumFontSize': minimumFontSize,
    'maximumFontSize': maximumFontSize,
    'fitStatus': fitStatus.name,
    'visible': visible,
    'exportEligible': exportEligible,
    'sourceAspectRatio': sourceAspectRatio,
  };
}

class ParteRenderPlan {
  const ParteRenderPlan({
    required this.widthMm,
    required this.heightMm,
    required this.horizontalMarginMm,
    required this.verticalMarginMm,
    this.printableZoneXmm = 0,
    this.printableZoneYmm = 0,
    double? printableZoneWidthMm,
    double? printableZoneHeightMm,
    required this.blocks,
    required this.warnings,
    required this.blockers,
    required this.fingerprint,
  }) : printableZoneWidthMm = printableZoneWidthMm ?? widthMm,
       printableZoneHeightMm = printableZoneHeightMm ?? heightMm;

  final double widthMm;
  final double heightMm;
  final double horizontalMarginMm;
  final double verticalMarginMm;
  final double printableZoneXmm;
  final double printableZoneYmm;
  final double printableZoneWidthMm;
  final double printableZoneHeightMm;
  double get marginMm => horizontalMarginMm;
  final List<ParteRenderBlock> blocks;
  final List<String> warnings;
  final List<String> blockers;
  final String fingerprint;

  bool get canConfirmPreview => blockers.isEmpty;
  bool get canGeneratePdf => blockers.isEmpty;

  static const requiredTextBlockIds = <String>{
    'intro',
    'name',
    'years',
    'death',
    'ceremony',
    'mournersHeading',
    'mourners',
  };

  void validateForExport() {
    if (blockers.isNotEmpty) {
      throw StateError('PARTE render plan ima nereÅ¡ene blokere.');
    }
    final ids = <String>{};
    for (final block in blocks) {
      if (!ids.add(block.id)) {
        throw StateError('PARTE render plan sadrÅ¾i dupli blok ${block.id}.');
      }
      if (!block.visible || !block.exportEligible) continue;
      if (block.kind == ParteBlockKind.text &&
          (block.resolvedText.trim().isEmpty ||
              block.fitStatus == ParteFitStatus.failed)) {
        throw StateError('PARTE blok ${block.id} nije spreman za izvoz.');
      }
    }
    final missing = requiredTextBlockIds.difference(ids);
    if (missing.isNotEmpty) {
      throw StateError(
        'PARTE izvoz nema obavezne blokove: ${missing.join(', ')}.',
      );
    }
    final years = blocks.where((block) => block.id == 'years').single;
    if (years.resolvedText.contains('\u2014')) {
      throw StateError('PARTE raspon godina sadrÅ¾i em-dash.');
    }
  }
}

class ParteCompositionInput {
  const ParteCompositionInput({
    required this.draft,
    required this.template,
    required this.photoMediaKey,
    required this.customSymbolMediaKey,
    required this.noPhotoAccepted,
    required this.noCustomSymbolAccepted,
    required this.lowResolutionPhoto,
    required this.lowResolutionAccepted,
    required this.grammarRequiresReview,
    required this.grammarVerified,
  });

  final ParteDraft draft;
  final ParteTemplate template;
  final String? photoMediaKey;
  final String? customSymbolMediaKey;
  final bool noPhotoAccepted;
  final bool noCustomSymbolAccepted;
  final bool lowResolutionPhoto;
  final bool lowResolutionAccepted;
  final bool grammarRequiresReview;
  final bool grammarVerified;
}

/// One measured composition pipeline shared by Flutter preview and PDF.
/// The adapters consume the resulting immutable plan and do not reflow text.
class ParteComposer {
  const ParteComposer();

  static const double _pointsPerMm = 72 / 25.4;
  static const double _lineHeightFactor = 1.22;
  static const double _singleLineNameSafetyFactor = 0.94;

  ParteRenderPlan compose(ParteCompositionInput input) {
    final warnings = <String>[];
    final blockers = <String>[];
    final draft = input.draft;

    if (draft.widthMm <= draft.heightMm ||
        draft.widthMm < 120 ||
        draft.widthMm > 500 ||
        draft.heightMm < 90 ||
        draft.heightMm > 350) {
      blockers.add('Dimenzije moraju biti bezbedan landscape format.');
    }
    if (draft.printableZoneXmm < 0 ||
        draft.printableZoneYmm < 0 ||
        draft.printableZoneWidthMm <= 0 ||
        draft.printableZoneHeightMm <= 0 ||
        draft.printableZoneXmm + draft.printableZoneWidthMm > draft.widthMm ||
        draft.printableZoneYmm + draft.printableZoneHeightMm > draft.heightMm ||
        draft.horizontalMarginMm * 2 >= draft.printableZoneWidthMm ||
        draft.verticalMarginMm * 2 >= draft.printableZoneHeightMm) {
      blockers.add('Zona štampe ili njena sigurna margina nisu bezbedne.');
    }

    final hasPhoto = input.photoMediaKey?.trim().isNotEmpty == true;
    if (!hasPhoto) {
      warnings.add('Fotografija nije uneta.');
      if (!input.noPhotoAccepted) {
        blockers.add('Potvrdite nastavak bez fotografije.');
      }
    }
    if (input.lowResolutionPhoto) {
      warnings.add('Fotografija je niske rezolucije za izabranu veličinu.');
      if (!input.lowResolutionAccepted) {
        blockers.add('Potvrdite kvalitet fotografije ili je zamenite.');
      }
    }
    if (input.grammarRequiresReview && !input.grammarVerified) {
      warnings.add('Gramatički oblik zahteva ljudsku proveru.');
      blockers.add('Potvrdite ili uredite gramatički oblik.');
    }

    final symbolId = draft.symbolId;
    final isNoSymbol = symbolId == 'BEZ_SIMBOLA';
    final isCustom = symbolId == 'SLOBODAN_IZBOR';
    final standardSymbol = ParteSymbolCatalog.byId(symbolId);
    final hasCustomSymbol =
        input.customSymbolMediaKey?.trim().isNotEmpty == true;
    if (isCustom && !hasCustomSymbol) {
      warnings.add('SLOBODAN IZBOR – nastavak bez unetog simbola.');
      if (!input.noCustomSymbolAccepted) {
        blockers.add('Potvrdite nastavak bez prilagođenog simbola.');
      }
    } else if (!isNoSymbol && !isCustom && standardSymbol == null) {
      blockers.add('Standardni simbol nije dostupan u PARTE katalogu.');
    }

    final hasRenderedSymbol =
        (!isNoSymbol && !isCustom && standardSymbol != null) ||
        (isCustom && hasCustomSymbol);
    final blocks = <ParteRenderBlock>[];
    final sorted = [...draft.blocks]
      ..sort((a, b) => a.layer.compareTo(b.layer));
    for (final spec in sorted) {
      final clamped = spec.rect.clampTo(
        pageWidth: draft.widthMm,
        pageHeight: draft.heightMm,
        horizontalMargin: draft.horizontalMarginMm,
        verticalMargin: draft.verticalMarginMm,
        originX: draft.printableZoneXmm,
        originY: draft.printableZoneYmm,
        usableWidth: draft.printableZoneWidthMm,
        usableHeight: draft.printableZoneHeightMm,
      );
      if (!_sameRect(spec.rect, clamped)) {
        blockers.add('Blok ${spec.id} izlazi iz upotrebljive površine.');
        continue;
      }
      if (spec.kind == ParteBlockKind.photo) {
        if (hasPhoto) {
          blocks.add(
            ParteRenderBlock(
              id: spec.id,
              kind: spec.kind,
              rect: spec.rect,
              layer: spec.layer,
              mediaKey: input.photoMediaKey,
              brightness: spec.brightness,
              contrast: spec.contrast,
              sharpness: spec.sharpness,
              grayscale: spec.grayscale,
              border: spec.border,
              borderWidth: spec.borderWidth,
              imageShape: spec.imageShape,
              sourceAspectRatio: spec.sourceAspectRatio,
            ),
          );
        }
        continue;
      }
      if (spec.kind == ParteBlockKind.symbol) {
        if (hasRenderedSymbol) {
          blocks.add(
            ParteRenderBlock(
              id: spec.id,
              kind: spec.kind,
              rect: spec.rect,
              layer: spec.layer,
              assetPath: isCustom ? null : standardSymbol?.assetPath,
              mediaKey: isCustom ? input.customSymbolMediaKey : null,
              border: spec.border,
              borderWidth: spec.borderWidth,
              imageShape: spec.imageShape,
              sourceAspectRatio: spec.sourceAspectRatio,
            ),
          );
        }
        continue;
      }

      final content = _canonicalText(
        spec.id,
        input.draft.textByBlock[spec.id]?.trim() ?? '',
      );
      if (content.isEmpty) continue;
      final adjustedSpec = spec;
      final fit = spec.id == 'name'
          ? _fitSingleLineName(content, adjustedSpec)
          : _fitText(content, adjustedSpec);
      if (!fit.fits) {
        blockers.add(
          'Sadržaj bloka ${spec.id} ne može da stane bez skraćivanja.',
        );
      }
      blocks.add(
        ParteRenderBlock(
          id: spec.id,
          kind: spec.kind,
          rect: adjustedSpec.rect,
          layer: spec.layer,
          lines: fit.lines,
          fontSize: fit.fontSize,
          bold: adjustedSpec.bold,
          alignment: adjustedSpec.alignment,
          fontFamily: adjustedSpec.fontFamily,
          horizontalScale: fit.horizontalScale,
          minimumFontSize: adjustedSpec.minimumFontSize,
          maximumFontSize: adjustedSpec.maximumFontSize,
          fitStatus: fit.fits ? ParteFitStatus.fitted : ParteFitStatus.failed,
        ),
      );
    }

    final presentIds = blocks.map((block) => block.id).toSet();
    final missingRequired = ParteRenderPlan.requiredTextBlockIds.difference(
      presentIds,
    );
    for (final id in missingRequired) {
      blockers.add('Obavezni blok $id nema sadrÅ¾aj za izvoz.');
    }

    final fingerprintSource = <String, Object?>{
      'widthMm': draft.widthMm,
      'heightMm': draft.heightMm,
      'horizontalMarginMm': draft.horizontalMarginMm,
      'verticalMarginMm': draft.verticalMarginMm,
      'printableZoneXmm': draft.printableZoneXmm,
      'printableZoneYmm': draft.printableZoneYmm,
      'printableZoneWidthMm': draft.printableZoneWidthMm,
      'printableZoneHeightMm': draft.printableZoneHeightMm,
      'blocks': blocks.map((block) => block.toFingerprintJson()).toList(),
      'warnings': warnings,
      'blockers': blockers,
      'noPhotoAccepted': input.noPhotoAccepted,
      'noCustomSymbolAccepted': input.noCustomSymbolAccepted,
      'lowResolutionAccepted': input.lowResolutionAccepted,
      'grammarVerified': input.grammarVerified,
    };
    return ParteRenderPlan(
      widthMm: draft.widthMm,
      heightMm: draft.heightMm,
      horizontalMarginMm: draft.horizontalMarginMm,
      verticalMarginMm: draft.verticalMarginMm,
      printableZoneXmm: draft.printableZoneXmm,
      printableZoneYmm: draft.printableZoneYmm,
      printableZoneWidthMm: draft.printableZoneWidthMm,
      printableZoneHeightMm: draft.printableZoneHeightMm,
      blocks: List.unmodifiable(blocks),
      warnings: List.unmodifiable(warnings),
      blockers: List.unmodifiable(blockers.toSet()),
      fingerprint: parteCanonicalFingerprint(fingerprintSource),
    );
  }

  _ParteTextFit _fitText(String content, ParteBlockSpec spec) {
    var size = spec.initialFontSize
        .clamp(spec.minimumFontSize, spec.maximumFontSize)
        .toDouble();
    while (size >= spec.minimumFontSize) {
      final lines = _wrap(
        content,
        spec.rect.width * _pointsPerMm,
        size,
        spec.bold,
        fontFamily: spec.fontFamily,
      );
      final height = lines.length * size * _lineHeightFactor;
      if (height <= spec.rect.height * _pointsPerMm) {
        return _ParteTextFit(
          lines: lines,
          fontSize: size,
          horizontalScale: 1,
          fits: true,
        );
      }
      size -= 0.5;
    }
    final minimum = spec.minimumFontSize;
    return _ParteTextFit(
      lines: _wrap(
        content,
        spec.rect.width * _pointsPerMm,
        minimum,
        spec.bold,
        fontFamily: spec.fontFamily,
      ),
      fontSize: minimum,
      horizontalScale: 1,
      fits: false,
    );
  }

  _ParteTextFit _fitSingleLineName(String content, ParteBlockSpec spec) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ');
    // Word and PDF font metrics are not byte-for-byte identical. Keep a small
    // canonical reserve so the one-line name remains complete in every adapter
    // instead of fitting exactly against the right edge.
    final available =
        spec.rect.width * _pointsPerMm * _singleLineNameSafetyFactor;
    var size = spec.initialFontSize
        .clamp(spec.minimumFontSize, spec.maximumFontSize)
        .toDouble();
    while (size >= spec.minimumFontSize) {
      final natural = _textWidth(
        normalized,
        size,
        spec.bold,
        fontFamily: spec.fontFamily,
      );
      final requiredScale = natural <= available ? 1.0 : available / natural;
      final heightFits =
          size * _lineHeightFactor <= spec.rect.height * _pointsPerMm;
      if (requiredScale >= 0.5 && heightFits) {
        return _ParteTextFit(
          lines: [normalized],
          fontSize: size,
          horizontalScale: requiredScale.clamp(0.5, 1.0).toDouble(),
          fits: true,
        );
      }
      size -= 0.5;
    }
    return _ParteTextFit(
      lines: [normalized],
      fontSize: spec.minimumFontSize,
      horizontalScale: 0.5,
      fits: false,
    );
  }

  String _canonicalText(String blockId, String value) =>
      blockId == 'years' ? value.replaceAll('\u2014', '\u2013') : value;

  List<String> _wrap(
    String content,
    double maxWidth,
    double fontSize,
    bool bold, {
    String fontFamily = ParteFontCatalog.notoSans,
  }) {
    final result = <String>[];
    for (final paragraph in content.split('\n')) {
      if (paragraph.isEmpty) {
        result.add('');
        continue;
      }
      var current = '';
      for (final word in paragraph.split(RegExp(r'\s+'))) {
        final candidate = current.isEmpty ? word : '$current $word';
        if (_textWidth(candidate, fontSize, bold, fontFamily: fontFamily) <=
            maxWidth) {
          current = candidate;
          continue;
        }
        if (current.isNotEmpty) result.add(current);
        if (_textWidth(word, fontSize, bold, fontFamily: fontFamily) <=
            maxWidth) {
          current = word;
          continue;
        }
        var part = '';
        for (final rune in word.runes) {
          final char = String.fromCharCode(rune);
          final next = '$part$char';
          if (part.isNotEmpty &&
              _textWidth(next, fontSize, bold, fontFamily: fontFamily) >
                  maxWidth) {
            result.add(part);
            part = char;
          } else {
            part = next;
          }
        }
        current = part;
      }
      if (current.isNotEmpty) result.add(current);
    }
    return result;
  }

  double _textWidth(
    String text,
    double fontSize,
    bool bold, {
    String fontFamily = ParteFontCatalog.notoSans,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  bool _sameRect(ParteRectMm a, ParteRectMm b) =>
      (a.x - b.x).abs() < 0.0001 &&
      (a.y - b.y).abs() < 0.0001 &&
      (a.width - b.width).abs() < 0.0001 &&
      (a.height - b.height).abs() < 0.0001;
}

class _ParteTextFit {
  const _ParteTextFit({
    required this.lines,
    required this.fontSize,
    required this.horizontalScale,
    required this.fits,
  });

  final List<String> lines;
  final double fontSize;
  final double horizontalScale;
  final bool fits;
}
