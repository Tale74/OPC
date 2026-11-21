import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

/// Makes a SQLite-consistent snapshot before Drift is allowed to upgrade an
/// existing native database. The application never replaces the user's file.
Future<void> ensureMigrationBackupBeforeOpen({
  File? databaseFile,
  Directory? backupDirectory,
  int targetVersion = 37,
}) async {
  final source =
      databaseFile ??
      File(
        path.join(
          (await getApplicationDocumentsDirectory()).path,
          '$kDatabaseName.sqlite',
        ),
      );
  if (!await source.exists()) return;

  final connection = NativeDatabase(source, enableMigrations: false);
  try {
    await connection.ensureOpen(_InspectionOnlyUser());
    final version =
        (await connection.runSelect(
              'PRAGMA user_version',
              const [],
            )).single['user_version']
            as int;
    if (version > targetVersion) {
      throw StateError(
        'Baza je novija od ove verzije OPC-a. Otvaranje je zaustavljeno.',
      );
    }
    if (version == targetVersion) return;
    if (version < 1) {
      throw StateError(
        'Nepodržana verzija postojeće baze. Otvaranje je zaustavljeno.',
      );
    }
    await _requireIntegrity(connection);

    final directory =
        backupDirectory ??
        Directory(
          path.join(
            (await getApplicationSupportDirectory()).path,
            'opc_migration_backups',
          ),
        );
    await directory.create(recursive: true);
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final backup = File(
      path.join(
        directory.path,
        '${path.basenameWithoutExtension(source.path)}-v$version-$stamp.sqlite',
      ),
    );
    try {
      // SQLite includes committed WAL contents in this consistent snapshot.
      await connection.runCustom('VACUUM INTO ?', [backup.path]);
      if (!await backup.exists() || await backup.length() == 0) {
        throw StateError('Zaštitna kopija baze nije napravljena.');
      }
      final saved = NativeDatabase(backup, enableMigrations: false);
      try {
        await saved.ensureOpen(_InspectionOnlyUser());
        await _requireIntegrity(saved);
        final savedVersion =
            (await saved.runSelect(
                  'PRAGMA user_version',
                  const [],
                )).single['user_version']
                as int;
        if (savedVersion != version) {
          throw StateError('Zaštitna kopija ima drugu verziju šeme.');
        }
      } finally {
        await saved.close();
      }
      // Read every byte and fail closed if the file cannot be read completely.
      await sha256.bind(backup.openRead()).first;
    } on Object {
      // An incomplete snapshot must not be mistaken for a recovery point.
      if (await backup.exists()) await backup.delete();
      rethrow;
    }
  } finally {
    await connection.close();
  }
}

Future<void> _requireIntegrity(QueryExecutor connection) async {
  final rows = await connection.runSelect('PRAGMA integrity_check', const []);
  if (rows.length != 1 || rows.single.values.single != 'ok') {
    throw StateError(
      'Integritet baze nije potvrđen. Otvaranje je zaustavljeno.',
    );
  }
}

class _InspectionOnlyUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
