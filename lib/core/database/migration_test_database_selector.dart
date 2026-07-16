import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

const kMigrationTestDatabasePath = String.fromEnvironment(
  'MIGRATION_TEST_DATABASE_PATH',
  defaultValue: '',
);

final class OpcMigrationTestDatabaseSelectionException implements Exception {
  const OpcMigrationTestDatabaseSelectionException(this.message);

  final String message;

  @override
  String toString() => 'OpcMigrationTestDatabaseSelectionException: $message';
}

/// Resolves the one-shot owner-copy smoke target.
///
/// Non-WINDOWS_TEST variants deliberately ignore the define and retain their
/// established database lane. WINDOWS_TEST fails closed unless an existing,
/// absolute, clearly named SQLite copy is provided. The path is compile-time
/// input only and is never persisted by the application.
Future<File?> resolveMigrationTestDatabaseFile({
  String? buildVariant,
  String configuredPath = kMigrationTestDatabasePath,
  Future<Directory> Function() documentsDirectoryProvider =
      getApplicationDocumentsDirectory,
  Future<bool> Function(String firstPath, String secondPath)
      fileIdentityProvider =
      FileSystemEntity.identical,
}) async {
  final effectiveBuildVariant = buildVariant ?? kBuildVariant;
  if (effectiveBuildVariant != AppBuildVariant.windowsTest) return null;

  final rawPath = configuredPath.trim();
  if (rawPath.isEmpty) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'WINDOWS_TEST requires MIGRATION_TEST_DATABASE_PATH',
    );
  }
  if (!p.isAbsolute(rawPath)) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'MIGRATION_TEST_DATABASE_PATH must be absolute',
    );
  }

  final normalizedPath = p.normalize(rawPath);
  final filename = p.basename(normalizedPath);
  final filenameLower = filename.toLowerCase();
  if (p.extension(filenameLower) != '.sqlite') {
    throw const OpcMigrationTestDatabaseSelectionException(
      'WINDOWS_TEST accepts only a .sqlite file',
    );
  }
  if (filenameLower == 'opc_v4_release.sqlite') {
    throw const OpcMigrationTestDatabaseSelectionException(
      'the canonical opc_v4_release.sqlite database is forbidden',
    );
  }
  if (!filename.toUpperCase().contains('MIGRATION_TEST')) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'the selected .sqlite filename must contain MIGRATION_TEST',
    );
  }

  final candidate = File(normalizedPath);
  final candidateStat = await candidate.stat();
  if (candidateStat.type != FileSystemEntityType.file) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'MIGRATION_TEST_DATABASE_PATH must identify an existing file',
    );
  }

  final documentsDirectory = await documentsDirectoryProvider();
  final canonical = File(
    p.join(documentsDirectory.path, 'opc_v4_release.sqlite'),
  );
  if (await canonical.exists() &&
      await fileIdentityProvider(candidate.path, canonical.path)) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'the selected file is the canonical database or a filesystem alias of it',
    );
  }

  if (!await _hasSqlite3Header(candidate)) {
    throw const OpcMigrationTestDatabaseSelectionException(
      'the selected file does not have a valid SQLite 3 header',
    );
  }

  return candidate;
}

Future<bool> _hasSqlite3Header(File file) async {
  final handle = await file.open(mode: FileMode.read);
  try {
    final actual = await handle.read(16);
    final expected = ascii.encode('SQLite format 3\u0000');
    if (actual.length != expected.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (actual[index] != expected[index]) return false;
    }
    return true;
  } finally {
    await handle.close();
  }
}
