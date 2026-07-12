import 'dart:convert';

import 'package:crypto/crypto.dart';

const String parteBuiltinTemplateId = 'builtin_parte_standard_v1';
const int parteTemplateSchemaVersion = 1;
const int parteDraftSchemaVersion = 1;

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

  ParteRectMm clampTo({
    required double pageWidth,
    required double pageHeight,
    required double margin,
  }) {
    final maxWidth = (pageWidth - margin * 2).clamp(1.0, pageWidth);
    final maxHeight = (pageHeight - margin * 2).clamp(1.0, pageHeight);
    final safeWidth = width.clamp(1.0, maxWidth).toDouble();
    final safeHeight = height.clamp(1.0, maxHeight).toDouble();
    return ParteRectMm(
      x: x.clamp(margin, pageWidth - margin - safeWidth).toDouble(),
      y: y.clamp(margin, pageHeight - margin - safeHeight).toDouble(),
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
  final int layer;

  ParteBlockSpec copyWith({
    ParteRectMm? rect,
    double? initialFontSize,
    bool? bold,
    ParteTextAlign? alignment,
  }) => ParteBlockSpec(
    id: id,
    kind: kind,
    rect: rect ?? this.rect,
    initialFontSize: initialFontSize ?? this.initialFontSize,
    minimumFontSize: minimumFontSize,
    maximumFontSize: maximumFontSize,
    bold: bold ?? this.bold,
    alignment: alignment ?? this.alignment,
    layer: layer,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'kind': kind.name,
    'rect': rect.toJson(),
    'initialFontSize': initialFontSize,
    'minimumFontSize': minimumFontSize,
    'maximumFontSize': maximumFontSize,
    'bold': bold,
    'alignment': alignment.name,
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
    alignment: ParteTextAlign.values.byName(json['alignment'] as String),
    layer: json['layer'] as int,
  );
}

class ParteTemplate {
  const ParteTemplate({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.marginMm,
    required this.blocks,
    this.builtIn = false,
    this.schemaVersion = parteTemplateSchemaVersion,
  });

  final String id;
  final String name;
  final double widthMm;
  final double heightMm;
  final double marginMm;
  final List<ParteBlockSpec> blocks;
  final bool builtIn;
  final int schemaVersion;

  bool get isValidLandscape =>
      widthMm > heightMm &&
      widthMm >= 120 &&
      widthMm <= 500 &&
      heightMm >= 90 &&
      heightMm <= 350 &&
      marginMm == 5 &&
      blocks.isNotEmpty;

  Map<String, Object> toJson({bool includeIdentity = true}) => {
    'schemaVersion': schemaVersion,
    if (includeIdentity) 'id': id,
    if (includeIdentity) 'name': name,
    'format': 'CUSTOM_MM_LANDSCAPE',
    'widthMm': widthMm,
    'heightMm': heightMm,
    'marginMm': marginMm,
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
      'blocks',
    };
    if (json.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('Šablon sadrži nedozvoljena polja.');
    }
    if (json['schemaVersion'] != parteTemplateSchemaVersion ||
        json['format'] != 'CUSTOM_MM_LANDSCAPE') {
      throw const FormatException(
        'Verzija ili format PARTE šablona nije podržan.',
      );
    }
    final rawBlocks = json['blocks'];
    if (rawBlocks is! List || rawBlocks.length > 32) {
      throw const FormatException('PARTE šablon ima neispravne blokove.');
    }
    final template = ParteTemplate(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      widthMm: (json['widthMm'] as num).toDouble(),
      heightMm: (json['heightMm'] as num).toDouble(),
      marginMm: (json['marginMm'] as num).toDouble(),
      blocks: rawBlocks
          .map(
            (item) =>
                ParteBlockSpec.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList(growable: false),
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
        margin: template.marginMm,
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
    name: 'OPC standard — landscape',
    widthMm: 224,
    heightMm: 170,
    marginMm: 5,
    builtIn: true,
    blocks: [
      ParteBlockSpec(
        id: 'photo',
        kind: ParteBlockKind.photo,
        rect: ParteRectMm(x: 7, y: 12, width: 36, height: 48),
        layer: 1,
      ),
      ParteBlockSpec(
        id: 'symbol',
        kind: ParteBlockKind.symbol,
        rect: ParteRectMm(x: 190, y: 10, width: 24, height: 30),
        layer: 2,
      ),
      ParteBlockSpec(
        id: 'intro',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 46, y: 10, width: 140, height: 13),
        initialFontSize: 18,
        minimumFontSize: 12,
        maximumFontSize: 24,
        layer: 3,
      ),
      ParteBlockSpec(
        id: 'name',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 46, y: 25, width: 140, height: 31),
        initialFontSize: 40,
        minimumFontSize: 18,
        maximumFontSize: 58,
        bold: true,
        layer: 4,
      ),
      ParteBlockSpec(
        id: 'profession',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 46, y: 57, width: 140, height: 12),
        initialFontSize: 17,
        minimumFontSize: 10,
        maximumFontSize: 22,
        layer: 5,
      ),
      ParteBlockSpec(
        id: 'years',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 46, y: 70, width: 140, height: 11),
        initialFontSize: 16,
        minimumFontSize: 10,
        maximumFontSize: 22,
        bold: true,
        layer: 6,
      ),
      ParteBlockSpec(
        id: 'death',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 84, width: 196, height: 15),
        initialFontSize: 15,
        minimumFontSize: 9,
        maximumFontSize: 20,
        layer: 7,
      ),
      ParteBlockSpec(
        id: 'ceremony',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 100, width: 196, height: 24),
        initialFontSize: 14,
        minimumFontSize: 8,
        maximumFontSize: 18,
        layer: 8,
      ),
      ParteBlockSpec(
        id: 'secondary',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 125, width: 196, height: 13),
        initialFontSize: 13,
        minimumFontSize: 8,
        maximumFontSize: 18,
        layer: 9,
      ),
      ParteBlockSpec(
        id: 'mourners',
        kind: ParteBlockKind.text,
        rect: ParteRectMm(x: 14, y: 139, width: 196, height: 24),
        initialFontSize: 11,
        minimumFontSize: 7,
        maximumFontSize: 16,
        bold: true,
        layer: 10,
      ),
    ],
  );
}

class ParteDraft {
  const ParteDraft({
    required this.textByBlock,
    required this.blocks,
    required this.widthMm,
    required this.heightMm,
    required this.symbolId,
    this.schemaVersion = parteDraftSchemaVersion,
  });

  final int schemaVersion;
  final Map<String, String> textByBlock;
  final List<ParteBlockSpec> blocks;
  final double widthMm;
  final double heightMm;
  final String symbolId;

  ParteDraft copyWith({
    Map<String, String>? textByBlock,
    List<ParteBlockSpec>? blocks,
    double? widthMm,
    double? heightMm,
  }) => ParteDraft(
    textByBlock: textByBlock ?? this.textByBlock,
    blocks: blocks ?? this.blocks,
    widthMm: widthMm ?? this.widthMm,
    heightMm: heightMm ?? this.heightMm,
    symbolId: symbolId,
  );

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'textByBlock': textByBlock,
    'blocks': blocks.map((block) => block.toJson()).toList(),
    'widthMm': widthMm,
    'heightMm': heightMm,
    'symbolId': symbolId,
  };

  factory ParteDraft.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != parteDraftSchemaVersion) {
      throw const FormatException('Verzija PARTE pripreme nije podržana.');
    }
    return ParteDraft(
      textByBlock: (json['textByBlock'] as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      blocks: (json['blocks'] as List)
          .map(
            (item) =>
                ParteBlockSpec.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList(growable: false),
      widthMm: (json['widthMm'] as num).toDouble(),
      heightMm: (json['heightMm'] as num).toDouble(),
      symbolId: json['symbolId'] as String,
    );
  }

  String encode() => jsonEncode(toJson());

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
