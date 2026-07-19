import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PartePrintProfile {
  const PartePrintProfile({
    this.horizontalCorrectionMm = 0,
    this.verticalCorrectionMm = 0,
  });

  final double horizontalCorrectionMm;
  final double verticalCorrectionMm;

  bool get isCentered =>
      horizontalCorrectionMm.abs() < 0.0001 &&
      verticalCorrectionMm.abs() < 0.0001;

  Map<String, Object> toJson() => {
    'schemaVersion': 1,
    'horizontalCorrectionMm': horizontalCorrectionMm,
    'verticalCorrectionMm': verticalCorrectionMm,
  };

  factory PartePrintProfile.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1) return const PartePrintProfile();
    return PartePrintProfile(
      horizontalCorrectionMm: ((json['horizontalCorrectionMm'] as num?) ?? 0)
          .toDouble()
          .clamp(-25, 25),
      verticalCorrectionMm: ((json['verticalCorrectionMm'] as num?) ?? 0)
          .toDouble()
          .clamp(-25, 25),
    );
  }
}

/// Machine-local printer calibration. It is deliberately excluded from
/// PREDMET, preparation drafts, portable templates and DOCX geometry. Profiles
/// are associated with template IDs only inside this machine-local store.
class PartePrintProfileStore {
  PartePrintProfileStore({Future<Directory> Function()? rootDirectory})
    : _rootDirectory = rootDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _rootDirectory;

  Future<File> _file() async =>
      File(p.join((await _rootDirectory()).path, 'parte_print_profile.json'));

  Future<Map<String, dynamic>?> _readRoot() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      return (jsonDecode(await file.readAsString()) as Map)
          .cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeProfiles(Map<String, PartePrintProfile> profiles) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'schemaVersion': 2,
        'profilesByTemplateId': {
          for (final entry in profiles.entries) entry.key: entry.value.toJson(),
        },
      }),
      flush: true,
    );
  }

  Map<String, PartePrintProfile> _decodeProfiles(Map<String, dynamic>? root) {
    if (root?['schemaVersion'] != 2) return {};
    final raw = root?['profilesByTemplateId'];
    if (raw is! Map) return {};
    return {
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is Map)
          entry.key as String: PartePrintProfile.fromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
    };
  }

  Future<PartePrintProfile> loadForTemplate(String templateId) async {
    final root = await _readRoot();
    if (root?['schemaVersion'] == 1) {
      final legacy = PartePrintProfile.fromJson(root!);
      await _writeProfiles({templateId: legacy});
      return legacy;
    }
    return _decodeProfiles(root)[templateId] ?? const PartePrintProfile();
  }

  Future<void> saveForTemplate(
    String templateId,
    PartePrintProfile profile,
  ) async {
    final root = await _readRoot();
    final profiles = _decodeProfiles(root);
    profiles[templateId] = profile;
    await _writeProfiles(profiles);
  }

  Future<void> resetForTemplate(String templateId) async {
    final profiles = _decodeProfiles(await _readRoot())..remove(templateId);
    await _writeProfiles(profiles);
  }
}
