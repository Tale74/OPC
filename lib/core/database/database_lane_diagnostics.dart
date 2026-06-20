import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

const kKnownOpcDatabaseLaneNames = <String>[
  'opc_v4_release',
  'opc_v4_android_test',
  'opc_v4_windows_test',
];

class DatabaseLaneDiagnostic {
  const DatabaseLaneDiagnostic({
    required this.buildVariant,
    required this.buildVariantLabel,
    required this.activeDatabaseName,
    required this.documentsDirectoryPath,
    required this.lanes,
  });

  final String buildVariant;
  final String buildVariantLabel;
  final String activeDatabaseName;
  final String documentsDirectoryPath;
  final List<DatabaseLaneFileInfo> lanes;

  List<DatabaseLaneFileInfo> get existingAlternateLanes => lanes
      .where((lane) => lane.exists && !lane.isActive)
      .toList(growable: false);
}

class DatabaseLaneFileInfo {
  const DatabaseLaneFileInfo({
    required this.databaseName,
    required this.fileName,
    required this.filePath,
    required this.isActive,
    required this.exists,
    this.sizeBytes,
    this.lastModified,
  });

  final String databaseName;
  final String fileName;
  final String filePath;
  final bool isActive;
  final bool exists;
  final int? sizeBytes;
  final DateTime? lastModified;
}

class DatabaseLaneDiagnostics {
  const DatabaseLaneDiagnostics._();

  static Future<DatabaseLaneDiagnostic> read() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final lanes = <DatabaseLaneFileInfo>[];

    for (final databaseName in kKnownOpcDatabaseLaneNames) {
      final fileName = '$databaseName.sqlite';
      final file = File(path.join(documentsDirectory.path, fileName));
      final exists = await file.exists();
      FileStat? stat;

      if (exists) {
        stat = await file.stat();
      }

      lanes.add(
        DatabaseLaneFileInfo(
          databaseName: databaseName,
          fileName: fileName,
          filePath: file.path,
          isActive: databaseName == kDatabaseName,
          exists: exists,
          sizeBytes: stat?.size,
          lastModified: stat?.modified,
        ),
      );
    }

    return DatabaseLaneDiagnostic(
      buildVariant: kBuildVariant,
      buildVariantLabel: kBuildVarijanta,
      activeDatabaseName: kDatabaseName,
      documentsDirectoryPath: documentsDirectory.path,
      lanes: lanes,
    );
  }
}
