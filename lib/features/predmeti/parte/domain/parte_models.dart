import 'dart:convert';

import 'package:crypto/crypto.dart';

const String parteBuiltinTemplateId = 'builtin_parte_standard_v1';
const int parteTemplateSchemaVersion = 5;
const int parteDraftSchemaVersion = 5;

enum PartePreparationStatus {
  inProgress('IN_PROGRESS'),
  cleanupPending('CLEANUP_PENDING'),
  completed('COMPLETED');

  const PartePreparationStatus(this.dbValue);
  final String dbValue;

  static PartePreparationStatus fromDb(String value) => values.firstWhere(
    (item) => item.dbValue == value,
    orElse: () => inProgress,
  );
}

enum ParteBlockKind { text, photo, symbol }

enum ParteTextAlign { left, center, right }

enum ParteImageShape { rectangle, roundedRectangle, oval }

abstract final class ParteFontCatalog {
  static const String notoSans = 'NotoSans';
  static const String notoSerif = 'NotoSerif';
  static const supported = <String>[notoSans, notoSerif];

  static String displayName(String value) => switch (safe(value)) {
    notoSerif => 'Noto Serif',
    _ => 'Noto Sans',
  };

  static String safe(String value) =>
      supported.contains(value) ? value : notoSerif;
}

class ParteRectMm {
  const ParteRectMm({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;
  double get bottom => y + height;
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  ParteRectMm normalizedToAspectRatio(double ratio) {
    if (!ratio.isFinite || ratio <= 0 || width <= 0 || height <= 0) {
      return this;
    }
    final current = width / height;
    final nextWidth = current > ratio ? height * ratio : width;
    final nextHeight = current > ratio ? height : width / ratio;
    return ParteRectMm(
      x: centerX - nextWidth / 2,
      y: centerY - nextHeight / 2,
      width: nextWidth,
      height: nextHeight,
    );
  }

  ParteRectMm clampTo({
    required double pageWidth,
    required double pageHeight,
    double? margin,
    double? horizontalMargin,
    double? verticalMargin,
    double originX = 0,
    double originY = 0,
    double? usableWidth,
    double? usableHeight,
  }) {
    final horizontal = horizontalMargin ?? margin ?? 0;
    final vertical = verticalMargin ?? margin ?? 0;
    final areaWidth = usableWidth ?? pageWidth;
    final areaHeight = usableHeight ?? pageHeight;
    final maxWidth = (areaWidth - horizontal * 2).clamp(1.0, areaWidth);
    final maxHeight = (areaHeight - vertical * 2).clamp(1.0, areaHeight);
    final safeWidth = width.clamp(1.0, maxWidth).toDouble();
    final safeHeight = height.clamp(1.0, maxHeight).toDouble();
    return ParteRectMm(
      x: x
          .clamp(
            originX + horizontal,
            originX + areaWidth - horizontal - safeWidth,
          )
          .toDouble(),
      y: y
          .clamp(
            originY + vertical,
            originY + areaHeight - vertical - safeHeight,
          )
          .toDouble(),
      width: safeWidth,
      height: safeHeight,
    );
  }

  Map<String, Object> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  factory ParteRectMm.fromJson(Map<String, dynamic> json) => ParteRectMm(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );
}

class ParteBlockSpec {
  const ParteBlockSpec({
    required this.id,
    required this.kind,
    required this.rect,
    this.initialFontSize = 12,
    this.minimumFontSize = 8,
    this.maximumFontSize = 60,
    this.bold = false,
    this.alignment = ParteTextAlign.center,
    this.fontFamily = ParteFontCatalog.notoSerif,
    this.horizontalScale = 1,
    this.lockAspectRatio = true,
    this.sourceAspectRatio,
    this.brightness = 1,
    this.contrast = 1,
    this.sharpness = 0,
    this.grayscale = false,
    this.border = false,
    this.borderWidth = 1,
    this.imageShape = ParteImageShape.rectangle,
    this.layer = 0,
  });

  final String id;
  final ParteBlockKind kind;
  final ParteRectMm rect;
  final double initialFontSize;
  final double minimumFontSize;
  final double maximumFontSize;
  final bool bold;
  final ParteTextAlign alignment;
  final String fontFamily;
  final double horizontalScale;
  final bool lockAspectRatio;
  final double? sourceAspectRatio;
  final double brightness;
  final double contrast;
  final double sharpness;
  final bool grayscale;
  final bool border;
  final double borderWidth;
  final ParteImageShape imageShape;
  final int layer;

  ParteBlockSpec copyWith({
    ParteRectMm? rect,
    double? initialFontSize,
    double? minimumFontSize,
    double? maximumFontSize,
    bool? bold,
    ParteTextAlign? alignment,
    String? fontFamily,
    double? horizontalScale,
    bool? lockAspectRatio,
    double? sourceAspectRatio,
    double? brightness,
    double? contrast,
    double? sharpness,
    bool? grayscale,
    bool? border,
    double? borderWidth,
    ParteImageShape? imageShape,
  }) => ParteBlockSpec(
    id: id,
    kind: kind,
    rect: rect ?? this.rect,
    initialFontSize: initialFontSize ?? this.initialFontSize,
    minimumFontSize: minimumFontSize ?? this.minimumFontSize,
    maximumFontSize: maximumFontSize ?? this.maximumFontSize,
    bold: bold ?? this.bold,
    alignment: alignment ?? this.alignment,
    fontFamily: ParteFontCatalog.safe(fontFamily ?? this.fontFamily),
    horizontalScale: (horizontalScale ?? this.horizontalScale)
        .clamp(0.5, 1.0)
        .toDouble(),
    lockAspectRatio: lockAspectRatio ?? this.lockAspectRatio,
    sourceAspectRatio: sourceAspectRatio ?? this.sourceAspectRatio,
    brightness: (brightness ?? this.brightness).clamp(0.5, 1.5).toDouble(),
    contrast: (contrast ?? this.contrast).clamp(0.5, 1.5).toDouble(),
    sharpness: (sharpness ?? this.sharpness).clamp(0, 1).toDouble(),
    grayscale: grayscale ?? this.grayscale,
    border: border ?? this.border,
    borderWidth: (borderWidth ?? this.borderWidth).clamp(0, 5).toDouble(),
    imageShape: imageShape ?? this.imageShape,
    layer: layer,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'rect': rect.toJson(),
    'initialFontSize': initialFontSize,
    'minimumFontSize': minimumFontSize,
    'maximumFontSize': maximumFontSize,
    'bold': bold,
    'alignment': alignment.name,
    'fontFamily': fontFamily,
    'horizontalScale': horizontalScale,
    'lockAspectRatio': lockAspectRatio,
    'sourceAspectRatio': sourceAspectRatio,
    'brightness': brightness,
    'contrast': contrast,
    'sharpness': sharpness,
    'grayscale': grayscale,
    'border': border,
    'borderWidth': borderWidth,
    'imageShape': imageShape.name,
    'layer': layer,
  };

  factory ParteBlockSpec.fromJson(Map<String, dynamic> json) => ParteBlockSpec(
    id: json['id'] as String,
    kind: ParteBlockKind.values.byName(json['kind'] as String),
    rect: ParteRectMm.fromJson((json['rect'] as Map).cast<String, dynamic>()),
    initialFontSize: (json['initialFontSize'] as num).toDouble(),
    minimumFontSize: (json['minimumFontSize'] as num).toDouble(),
    maximumFontSize: (json['maximumFontSize'] as num).toDouble(),
    bold: json['bold'] as bool,
    alignment: ParteTextAlign.values.byName(
      (json['alignment'] as String?) ?? ParteTextAlign.center.name,
    ),
    fontFamily: ParteFontCatalog.safe(
      (json['fontFamily'] as String?) ?? ParteFontCatalog.notoSerif,
    ),
    horizontalScale: ((json['horizontalScale'] as num?) ?? 1).toDouble().clamp(
      0.5,
      1.0,
    ),
    lockAspectRatio: (json['lockAspectRatio'] as bool?) ?? true,
    sourceAspectRatio: (json['sourceAspectRatio'] as num?)?.toDouble(),
    brightness: ((json['brightness'] as num?) ?? 1).toDouble(),
    contrast: ((json['contrast'] as num?) ?? 1).toDouble(),
    sharpness: ((json['sharpness'] as num?) ?? 0).toDouble(),
    grayscale: (json['grayscale'] as bool?) ?? false,
    border: (json['border'] as bool?) ?? false,
    borderWidth: ((json['borderWidth'] as num?) ?? 1).toDouble(),
    imageShape: ParteImageShape.values.byName(
      (json['imageShape'] as String?) ?? ParteImageShape.rectangle.name,
    ),
    layer: json['layer'] as int,
  );
}

class ParteTemplate {
  const ParteTemplate({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    double marginMm = 5,
    double? horizontalMarginMm,
    double? verticalMarginMm,
    this.printableZoneXmm = 0,
    this.printableZoneYmm = 0,
    double? printableZoneWidthMm,
    double? printableZoneHeightMm,
    required this.blocks,
    this.builtIn = false,
    this.schemaVersion = parteTemplateSchemaVersion,
  }) : horizontalMarginMm = horizontalMarginMm ?? marginMm,
       verticalMarginMm = verticalMarginMm ?? marginMm,
       printableZoneWidthMm = printableZoneWidthMm ?? widthMm,
       printableZoneHeightMm = printableZoneHeightMm ?? heightMm;

  final String id;
  final String name;
  final double widthMm;
  final double heightMm;
  final double horizontalMarginMm;
  final double verticalMarginMm;
  final double printableZoneXmm;
  final double printableZoneYmm;
  final double printableZoneWidthMm;
  final double printableZoneHeightMm;
  double get marginMm => horizontalMarginMm;
  final List<ParteBlockSpec> blocks;
  final bool builtIn;
  final int schemaVersion;

  bool get isValidLandscape =>
      widthMm > heightMm &&
      widthMm >= 120 &&
      widthMm <= 500 &&
      heightMm >= 90 &&
      heightMm <= 350 &&
      horizontalMarginMm >= 0 &&
      verticalMarginMm >= 0 &&
      printableZoneXmm >= 0 &&
      printableZoneYmm >= 0 &&
      printableZoneWidthMm > 0 &&
      printableZoneHeightMm > 0 &&
      printableZoneXmm + printableZoneWidthMm <= widthMm &&
      printableZoneYmm + printableZoneHeightMm <= heightMm &&
      horizontalMarginMm * 2 < printableZoneWidthMm &&
      verticalMarginMm * 2 < printableZoneHeightMm &&
      blocks.isNotEmpty;

  Map<String, Object> toJson({bool includeIdentity = true}) => {
    'schemaVersion': schemaVersion,
    if (includeIdentity) 'id': id,
    if (includeIdentity) 'name': name,
    'format': 'CUSTOM_MM_LANDSCAPE',
    'widthMm': widthMm,
    'heightMm': heightMm,
    'horizontalMarginMm': horizontalMarginMm,
    'verticalMarginMm': verticalMarginMm,
    'printableZoneXmm': printableZoneXmm,
    'printableZoneYmm': printableZoneYmm,
    'printableZoneWidthMm': printableZoneWidthMm,
    'printableZoneHeightMm': printableZoneHeightMm,
    'blocks': blocks.map((block) => block.toJson()).toList(),
  };

  factory ParteTemplate.fromJson(
    Map<String, dynamic> json, {
    bool builtIn = false,
  }) {
    final allowed = {
      'schemaVersion',
      'id',
      'name',
      'format',
      'widthMm',
      'heightMm',
      'marginMm',
      'horizontalMarginMm',
      'verticalMarginMm',
      'printableZoneXmm',
      'printableZoneYmm',
      'printableZoneWidthMm',
      'printableZoneHeightMm',
      'blocks',
    };
    if (json.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('Šablon sadrži nedozvoljena polja.');
    }
    final sourceVersion = json['schemaVersion'] as int? ?? 1;
    if (sourceVersion < 1 ||
        sourceVersion > parteTemplateSchemaVersion ||
        json['format'] != 'CUSTOM_MM_LANDSCAPE') {
      throw const FormatException(
        'Verzija ili format PARTE šablona nije podržan.',
      );
    }
    final rawBlocks = json['blocks'];
    if (rawBlocks is! List || rawBlocks.length > 32) {
      throw const FormatException('PARTE šablon ima neispravne blokove.');
    }
    final blocks = rawBlocks
        .map(
          (item) =>
              ParteBlockSpec.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList(growable: true);
    _migrateMournersBlocks(blocks);
    _migrateTextLimits(blocks);
    final legacyMargin = ((json['marginMm'] as num?) ?? 5).toDouble();
    final template = ParteTemplate(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      widthMm: (json['widthMm'] as num).toDouble(),
      heightMm: (json['heightMm'] as num).toDouble(),
      horizontalMarginMm: ((json['horizontalMarginMm'] as num?) ?? legacyMargin)
          .toDouble(),
      verticalMarginMm: ((json['verticalMarginMm'] as num?) ?? legacyMargin)
          .toDouble(),
      printableZoneXmm: ((json['printableZoneXmm'] as num?) ?? 0).toDouble(),
      printableZoneYmm: ((json['printableZoneYmm'] as num?) ?? 0).toDouble(),
      printableZoneWidthMm: (json['printableZoneWidthMm'] as num?)?.toDouble(),
      printableZoneHeightMm: (json['printableZoneHeightMm'] as num?)
          ?.toDouble(),
      blocks: List<ParteBlockSpec>.unmodifiable(blocks),
      builtIn: builtIn,
    );
    if (!template.isValidLandscape ||
        template.blocks.map((block) => block.id).toSet().length !=
            template.blocks.length) {
      throw const FormatException('PARTE šablon nema bezbednu geometriju.');
    }
    for (final block in template.blocks) {
      final clamped = block.rect.clampTo(
        pageWidth: template.widthMm,
        pageHeight: template.heightMm,
        horizontalMargin: template.horizontalMarginMm,
        verticalMargin: template.verticalMarginMm,
        originX: template.printableZoneXmm,
        originY: template.printableZoneYmm,
        usableWidth: template.printableZoneWidthMm,
        usableHeight: template.printableZoneHeightMm,
      );
      if (clamped.toJson().toString() != block.rect.toJson().toString()) {
        throw const FormatException(
          'Blok šablona izlazi iz upotrebljive površine.',
        );
      }
    }
    return template;
  }

  static const builtInStandard = ParteTemplate(
    id: parteBuiltinTemplateId,
    name: 'OPC standard – landscape',
    widthMm: 224,
    heightMm: 170,
    horizontalMarginMm: 5,
    verticalMarginMm: 5,
    builtIn: true,
    blocks: [
      ParteBlockSpec(
        id: 'photo',
        kind: ParteBlockKind.photo,
        rect: ParteRectMm(x: 174, y: 10, width: 38, height: 50),
        layer: 1,
      ),
      ParteBlockSpec(
        id: 'symbol',
        kind: ParteBlockKind.symbol,
        rect: ParteRectMm(x: 102, y: 5, width: 20, height: 27),
        layer: 2,
      ),
      ParteBlockSpec(
        id: 'intro',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 10, y: 12, width: 80, height: 18),
        initialFontSize: 14,
        minimumFontSize: 8,
        maximumFontSize: 22,
        alignment: ParteTextAlign.left,
        layer: 3,
      ),
      ParteBlockSpec(
        id: 'name',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 15, y: 34, width: 155, height: 26),
        initialFontSize: 52,
        minimumFontSize: 28,
        maximumFontSize: 74,
        bold: true,
        layer: 4,
      ),
      ParteBlockSpec(
        id: 'profession',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 45, y: 62, width: 116, height: 12),
        initialFontSize: 17,
        minimumFontSize: 10,
        maximumFontSize: 22,
        layer: 5,
      ),
      ParteBlockSpec(
        id: 'years',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 55, y: 75, width: 96, height: 11),
        initialFontSize: 16,
        minimumFontSize: 10,
        maximumFontSize: 22,
        bold: true,
        layer: 6,
      ),
      ParteBlockSpec(
        id: 'death',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 89, width: 196, height: 15),
        initialFontSize: 14,
        minimumFontSize: 8,
        maximumFontSize: 22,
        layer: 7,
      ),
      ParteBlockSpec(
        id: 'ceremony',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 105, width: 196, height: 20),
        initialFontSize: 14,
        minimumFontSize: 8,
        maximumFontSize: 22,
        alignment: ParteTextAlign.left,
        layer: 8,
      ),
      ParteBlockSpec(
        id: 'secondary',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 126, width: 196, height: 13),
        initialFontSize: 14,
        minimumFontSize: 8,
        maximumFontSize: 22,
        alignment: ParteTextAlign.left,
        layer: 9,
      ),
      ParteBlockSpec(
        id: 'mournersHeading',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 28, y: 142, width: 42, height: 8),
        initialFontSize: 11,
        minimumFontSize: 7,
        maximumFontSize: 16,
        bold: true,
        layer: 10,
      ),
      ParteBlockSpec(
        id: 'mourners',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 28, y: 151, width: 168, height: 12),
        initialFontSize: 11,
        minimumFontSize: 7,
        maximumFontSize: 16,
        bold: true,
        layer: 11,
      ),
    ],
  );

  static void _migrateMournersBlocks(List<ParteBlockSpec> blocks) {
    if (blocks.any((block) => block.id == 'mournersHeading')) return;
    final index = blocks.indexWhere((block) => block.id == 'mourners');
    if (index < 0) return;
    final legacy = blocks[index];
    final headingHeight = (legacy.rect.height * 0.38).clamp(4.0, 8.0);
    blocks[index] = legacy.copyWith(
      rect: ParteRectMm(
        x: legacy.rect.x,
        y: legacy.rect.y + headingHeight,
        width: legacy.rect.width,
        height: (legacy.rect.height - headingHeight).clamp(
          1.0,
          legacy.rect.height,
        ),
      ),
    );
    blocks.insert(
      index,
      ParteBlockSpec(
        id: 'mournersHeading',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(
          x: legacy.rect.x,
          y: legacy.rect.y,
          width: legacy.rect.width,
          height: headingHeight,
        ),
        initialFontSize: legacy.initialFontSize,
        minimumFontSize: legacy.minimumFontSize,
        maximumFontSize: legacy.maximumFontSize,
        bold: legacy.bold,
        alignment: legacy.alignment,
        fontFamily: legacy.fontFamily,
        layer: legacy.layer,
      ),
    );
  }

  static void _migrateTextLimits(List<ParteBlockSpec> blocks) {
    final nameIndex = blocks.indexWhere((block) => block.id == 'name');
    if (nameIndex < 0) return;
    final name = blocks[nameIndex];
    if (name.maximumFontSize >= 74) return;
    blocks[nameIndex] = name.copyWith(maximumFontSize: 74);
  }
}

class ParteDraft {
  const ParteDraft({
    required this.textByBlock,
    required this.blocks,
    required this.widthMm,
    required this.heightMm,
    required this.symbolId,
    this.horizontalMarginMm = 5,
    this.verticalMarginMm = 5,
    this.printableZoneXmm = 0,
    this.printableZoneYmm = 0,
    double? printableZoneWidthMm,
    double? printableZoneHeightMm,
    this.schemaVersion = parteDraftSchemaVersion,
  }) : printableZoneWidthMm = printableZoneWidthMm ?? widthMm,
       printableZoneHeightMm = printableZoneHeightMm ?? heightMm;

  final int schemaVersion;
  final Map<String, String> textByBlock;
  final List<ParteBlockSpec> blocks;
  final double widthMm;
  final double heightMm;
  final double horizontalMarginMm;
  final double verticalMarginMm;
  final double printableZoneXmm;
  final double printableZoneYmm;
  final double printableZoneWidthMm;
  final double printableZoneHeightMm;
  final String symbolId;

  ParteDraft copyWith({
    Map<String, String>? textByBlock,
    List<ParteBlockSpec>? blocks,
    double? widthMm,
    double? heightMm,
    double? horizontalMarginMm,
    double? verticalMarginMm,
    double? printableZoneXmm,
    double? printableZoneYmm,
    double? printableZoneWidthMm,
    double? printableZoneHeightMm,
  }) => ParteDraft(
    textByBlock: textByBlock ?? this.textByBlock,
    blocks: blocks ?? this.blocks,
    widthMm: widthMm ?? this.widthMm,
    heightMm: heightMm ?? this.heightMm,
    horizontalMarginMm: horizontalMarginMm ?? this.horizontalMarginMm,
    verticalMarginMm: verticalMarginMm ?? this.verticalMarginMm,
    printableZoneXmm: printableZoneXmm ?? this.printableZoneXmm,
    printableZoneYmm: printableZoneYmm ?? this.printableZoneYmm,
    printableZoneWidthMm: printableZoneWidthMm ?? this.printableZoneWidthMm,
    printableZoneHeightMm: printableZoneHeightMm ?? this.printableZoneHeightMm,
    symbolId: symbolId,
  );

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'textByBlock': textByBlock,
    'blocks': blocks.map((block) => block.toJson()).toList(),
    'widthMm': widthMm,
    'heightMm': heightMm,
    'horizontalMarginMm': horizontalMarginMm,
    'verticalMarginMm': verticalMarginMm,
    'printableZoneXmm': printableZoneXmm,
    'printableZoneYmm': printableZoneYmm,
    'printableZoneWidthMm': printableZoneWidthMm,
    'printableZoneHeightMm': printableZoneHeightMm,
    'symbolId': symbolId,
  };

  factory ParteDraft.fromJson(Map<String, dynamic> json) {
    final sourceVersion = json['schemaVersion'] as int? ?? 1;
    if (sourceVersion < 1 || sourceVersion > parteDraftSchemaVersion) {
      throw const FormatException('Verzija PARTE pripreme nije podržana.');
    }
    final text = (json['textByBlock'] as Map).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    if (!text.containsKey('mournersHeading')) {
      final legacy = text['mourners'] ?? '';
      final lines = legacy.split('\n');
      text['mournersHeading'] = lines.isEmpty ? 'Ožalošćeni:' : lines.first;
      text['mourners'] = lines.length <= 1 ? '' : lines.skip(1).join('\n');
    }
    final legacyMargin = ((json['marginMm'] as num?) ?? 5).toDouble();
    final blocks = (json['blocks'] as List)
        .map(
          (item) =>
              ParteBlockSpec.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList(growable: true);
    ParteTemplate._migrateMournersBlocks(blocks);
    ParteTemplate._migrateTextLimits(blocks);
    return ParteDraft(
      textByBlock: text,
      blocks: List<ParteBlockSpec>.unmodifiable(blocks),
      widthMm: (json['widthMm'] as num).toDouble(),
      heightMm: (json['heightMm'] as num).toDouble(),
      horizontalMarginMm: ((json['horizontalMarginMm'] as num?) ?? legacyMargin)
          .toDouble(),
      verticalMarginMm: ((json['verticalMarginMm'] as num?) ?? legacyMargin)
          .toDouble(),
      printableZoneXmm: ((json['printableZoneXmm'] as num?) ?? 0).toDouble(),
      printableZoneYmm: ((json['printableZoneYmm'] as num?) ?? 0).toDouble(),
      printableZoneWidthMm: (json['printableZoneWidthMm'] as num?)?.toDouble(),
      printableZoneHeightMm: (json['printableZoneHeightMm'] as num?)
          ?.toDouble(),
      symbolId: json['symbolId'] as String,
    );
  }

  String encode() => jsonEncode(toJson());

  ParteDraft reflowTo({
    required double widthMm,
    required double heightMm,
    required double horizontalMarginMm,
    required double verticalMarginMm,
    double printableZoneXmm = 0,
    double printableZoneYmm = 0,
    double? printableZoneWidthMm,
    double? printableZoneHeightMm,
  }) {
    final newZoneWidth = printableZoneWidthMm ?? widthMm;
    final newZoneHeight = printableZoneHeightMm ?? heightMm;
    final oldUsableWidth =
        (this.printableZoneWidthMm - this.horizontalMarginMm * 2).clamp(
          1.0,
          this.printableZoneWidthMm,
        );
    final oldUsableHeight =
        (this.printableZoneHeightMm - this.verticalMarginMm * 2).clamp(
          1.0,
          this.printableZoneHeightMm,
        );
    final newUsableWidth = (newZoneWidth - horizontalMarginMm * 2).clamp(
      1.0,
      newZoneWidth,
    );
    final newUsableHeight = (newZoneHeight - verticalMarginMm * 2).clamp(
      1.0,
      newZoneHeight,
    );
    final scaleX = newUsableWidth / oldUsableWidth;
    final scaleY = newUsableHeight / oldUsableHeight;
    final fontScale = scaleX < scaleY ? scaleX : scaleY;
    final transformed = blocks
        .map((block) {
          final source = block.rect;
          final mappedCenterX =
              printableZoneXmm +
              horizontalMarginMm +
              (source.centerX -
                      this.printableZoneXmm -
                      this.horizontalMarginMm) *
                  scaleX;
          final mappedCenterY =
              printableZoneYmm +
              verticalMarginMm +
              (source.centerY - this.printableZoneYmm - this.verticalMarginMm) *
                  scaleY;
          final mediaScale = scaleX < scaleY ? scaleX : scaleY;
          final mappedWidth =
              block.kind != ParteBlockKind.text && block.lockAspectRatio
              ? source.width * mediaScale
              : source.width * scaleX;
          final mappedHeight =
              block.kind != ParteBlockKind.text && block.lockAspectRatio
              ? source.height * mediaScale
              : source.height * scaleY;
          var mapped = ParteRectMm(
            x: mappedCenterX - mappedWidth / 2,
            y: mappedCenterY - mappedHeight / 2,
            width: mappedWidth,
            height: mappedHeight,
          );
          if (block.kind != ParteBlockKind.text &&
              block.lockAspectRatio &&
              block.sourceAspectRatio != null) {
            mapped = mapped.normalizedToAspectRatio(block.sourceAspectRatio!);
          }
          final rect = mapped.clampTo(
            pageWidth: widthMm,
            pageHeight: heightMm,
            horizontalMargin: horizontalMarginMm,
            verticalMargin: verticalMarginMm,
            originX: printableZoneXmm,
            originY: printableZoneYmm,
            usableWidth: newZoneWidth,
            usableHeight: newZoneHeight,
          );
          return block.copyWith(
            rect: rect,
            initialFontSize: block.kind == ParteBlockKind.text
                ? (block.initialFontSize * fontScale)
                      .clamp(block.minimumFontSize, block.maximumFontSize)
                      .toDouble()
                : block.initialFontSize,
          );
        })
        .toList(growable: false);
    return copyWith(
      blocks: transformed,
      widthMm: widthMm,
      heightMm: heightMm,
      horizontalMarginMm: horizontalMarginMm,
      verticalMarginMm: verticalMarginMm,
      printableZoneXmm: printableZoneXmm,
      printableZoneYmm: printableZoneYmm,
      printableZoneWidthMm: newZoneWidth,
      printableZoneHeightMm: newZoneHeight,
    );
  }

  static ParteDraft decode(String source) =>
      ParteDraft.fromJson((jsonDecode(source) as Map).cast<String, dynamic>());
}

class ParteSymbolAsset {
  const ParteSymbolAsset(this.id, this.label, this.assetPath);
  final String id;
  final String label;
  final String? assetPath;
}

abstract final class ParteSymbolCatalog {
  static const standard = <ParteSymbolAsset>[
    ParteSymbolAsset(
      'PRAVOSLAVNI_KRST_SVETOSAVSKI',
      'Svetosavski',
      'assets/simboli/Svetosavski.png',
    ),
    ParteSymbolAsset(
      'PRAVOSLAVNI_KRST_TROCKI',
      'Običan krst',
      'assets/simboli/parte_obican_krst.png',
    ),
    ParteSymbolAsset(
      'RIMOKATOLICKI_KRST',
      'Katolički',
      'assets/simboli/parte_katolicki_krst.png',
    ),
    ParteSymbolAsset(
      'POLUMESEC',
      'Polumesec',
      'assets/simboli/parte_polumesec.png',
    ),
    ParteSymbolAsset(
      'DAVIDOVA_ZVEZDA',
      'Davidova zvezda',
      'assets/simboli/parte_davidova_zvezda.png',
    ),
    ParteSymbolAsset(
      'PETOKRAKA',
      'Petokraka',
      'assets/simboli/parte_petokraka.png',
    ),
  ];

  static ParteSymbolAsset? byId(String id) {
    for (final item in standard) {
      if (item.id == id) return item;
    }
    return null;
  }
}

String parteCanonicalFingerprint(Map<String, Object?> value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
