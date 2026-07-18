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
/// PREDMET, preparation drafts, templates and DOCX geometry.
class PartePrintProfileStore {
  PartePrintProfileStore({Future<Directory> Function()? rootDirectory})
    : _rootDirectory = rootDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _rootDirectory;

  Future<File> _file() async =>
      File(p.join((await _rootDirectory()).path, 'parte_print_profile.json'));

  Future<PartePrintProfile> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const PartePrintProfile();
      return PartePrintProfile.fromJson(
        (jsonDecode(await file.readAsString()) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      return const PartePrintProfile();
    }
  }

  Future<void> save(PartePrintProfile profile) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(profile.toJson()), flush: true);
  }

  Future<void> reset() => save(const PartePrintProfile());
}
