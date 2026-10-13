import 'dart:convert';

import 'package:flutter/services.dart';

class OpcGuideSection {
  const OpcGuideSection({required this.title, required this.text});

  final String title;
  final String text;

  factory OpcGuideSection.fromJson(Map<String, dynamic> json) =>
      OpcGuideSection(
        title: json['title'] as String,
        text: json['text'] as String,
      );
}

class OpcGuideChapter {
  const OpcGuideChapter({
    required this.id,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String id;
  final String title;
  final String intro;
  final List<OpcGuideSection> sections;

  factory OpcGuideChapter.fromJson(Map<String, dynamic> json) =>
      OpcGuideChapter(
        id: json['id'] as String,
        title: json['title'] as String,
        intro: json['intro'] as String,
        sections: (json['sections'] as List<dynamic>)
            .map(
              (section) =>
                  OpcGuideSection.fromJson(section as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
}

class OpcGuideRepository {
  const OpcGuideRepository();

  static const assetPath = 'assets/opc_user_guide.json';

  /// Called only after a user taps POMOĆ or RAD U APLIKACIJI.
  Future<List<OpcGuideChapter>> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['version'] != 1) {
      throw const FormatException('Nepoznata verzija OPC uputstva.');
    }
    final chapters = (decoded['chapters'] as List<dynamic>)
        .map(
          (chapter) =>
              OpcGuideChapter.fromJson(chapter as Map<String, dynamic>),
        )
        .toList(growable: false);
    final ids = chapters.map((chapter) => chapter.id).toSet();
    if (chapters.isEmpty || ids.length != chapters.length) {
      throw const FormatException(
        'Spisak poglavlja OPC uputstva nije ispravan.',
      );
    }
    return chapters;
  }
}
