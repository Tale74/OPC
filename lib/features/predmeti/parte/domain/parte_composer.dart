import 'package:flutter/material.dart';

import 'parte_models.dart';

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
    this.assetPath,
    this.mediaKey,
  });

  final String id;
  final ParteBlockKind kind;
  final ParteRectMm rect;
  final int layer;
  final List<String> lines;
  final double fontSize;
  final bool bold;
  final ParteTextAlign alignment;
  final String? assetPath;
  final String? mediaKey;

  Map<String, Object?> toFingerprintJson() => {
    'id': id,
    'kind': kind.name,
    'rect': rect.toJson(),
    'layer': layer,
    'lines': lines,
    'fontSize': fontSize,
    'bold': bold,
    'alignment': alignment.name,
    'assetPath': assetPath,
    'mediaKey': mediaKey,
  };
}

class ParteRenderPlan {
  const ParteRenderPlan({
    required this.widthMm,
    required this.heightMm,
    required this.marginMm,
    required this.blocks,
    required this.warnings,
    required this.blockers,
    required this.fingerprint,
  });

  final double widthMm;
  final double heightMm;
  final double marginMm;
  final List<ParteRenderBlock> blocks;
  final List<String> warnings;
  final List<String> blockers;
  final String fingerprint;

  bool get canConfirmPreview => blockers.isEmpty;
  bool get canGeneratePdf => blockers.isEmpty;
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
      warnings.add('SLOBODAN IZBOR — nastavak bez unetog simbola.');
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
        margin: input.template.marginMm,
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
            ),
          );
        }
        continue;
      }

      final content = input.draft.textByBlock[spec.id]?.trim() ?? '';
      if (content.isEmpty) continue;
      final adjustedSpec = _contentAwareTextSpec(
        spec,
        hasPhoto: hasPhoto,
        hasSymbol: hasRenderedSymbol,
        pageWidth: draft.widthMm,
        margin: input.template.marginMm,
      );
      final fit = _fitText(content, adjustedSpec);
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
        ),
      );
    }

    final fingerprintSource = <String, Object?>{
      'widthMm': draft.widthMm,
      'heightMm': draft.heightMm,
      'marginMm': input.template.marginMm,
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
      marginMm: input.template.marginMm,
      blocks: List.unmodifiable(blocks),
      warnings: List.unmodifiable(warnings),
      blockers: List.unmodifiable(blockers.toSet()),
      fingerprint: parteCanonicalFingerprint(fingerprintSource),
    );
  }

  ParteBlockSpec _contentAwareTextSpec(
    ParteBlockSpec spec, {
    required bool hasPhoto,
    required bool hasSymbol,
    required double pageWidth,
    required double margin,
  }) {
    if (!{'intro', 'name', 'profession', 'years'}.contains(spec.id)) {
      return spec;
    }
    final left = hasPhoto ? spec.rect.x : 14.0;
    final right = hasSymbol ? 186.0 : pageWidth - margin;
    return spec.copyWith(
      rect: ParteRectMm(
        x: left,
        y: spec.rect.y,
        width: (right - left).clamp(20.0, pageWidth - margin * 2),
        height: spec.rect.height,
      ),
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
      );
      final height = lines.length * size * _lineHeightFactor;
      if (height <= spec.rect.height * _pointsPerMm) {
        return _ParteTextFit(lines: lines, fontSize: size, fits: true);
      }
      size -= 0.5;
    }
    final minimum = spec.minimumFontSize;
    return _ParteTextFit(
      lines: _wrap(content, spec.rect.width * _pointsPerMm, minimum, spec.bold),
      fontSize: minimum,
      fits: false,
    );
  }

  List<String> _wrap(
    String content,
    double maxWidth,
    double fontSize,
    bool bold,
  ) {
    final result = <String>[];
    for (final paragraph in content.split('\n')) {
      if (paragraph.isEmpty) {
        result.add('');
        continue;
      }
      var current = '';
      for (final word in paragraph.split(RegExp(r'\s+'))) {
        final candidate = current.isEmpty ? word : '$current $word';
        if (_textWidth(candidate, fontSize, bold) <= maxWidth) {
          current = candidate;
          continue;
        }
        if (current.isNotEmpty) result.add(current);
        if (_textWidth(word, fontSize, bold) <= maxWidth) {
          current = word;
          continue;
        }
        var part = '';
        for (final rune in word.runes) {
          final char = String.fromCharCode(rune);
          final next = '$part$char';
          if (part.isNotEmpty && _textWidth(next, fontSize, bold) > maxWidth) {
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

  double _textWidth(String text, double fontSize, bool bold) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'NotoSans',
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
    required this.fits,
  });

  final List<String> lines;
  final double fontSize;
  final bool fits;
}
