import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/migration_backup_preflight.dart';

void main() {
  test(
    'native preflight keeps a readable snapshot before schema upgrade',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'opc-migration-backup-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}${Platform.pathSeparator}source.sqlite');
      final backupDir = Directory(
        '${dir.path}${Platform.pathSeparator}backups',
      );
      final db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customSelect('SELECT 1').get();
      await db.customStatement('PRAGMA user_version = 36');
      await db.customStatement('CREATE TABLE preflight_probe (value TEXT)');
      await db.customStatement(
        "INSERT INTO preflight_probe VALUES ('preserved')",
      );
      await db.close();

      await ensureMigrationBackupBeforeOpen(
        databaseFile: file,
        backupDirectory: backupDir,
      );
      final backups = await backupDir
          .list()
          .where((entry) => entry is File)
          .toList();
      expect(backups, hasLength(1));
      final saved = AppDatabase.forTesting(
        NativeDatabase(backups.single as File),
      );
      addTearDown(saved.close);
      expect(
        (await saved.customSelect('SELECT value FROM preflight_probe').get())
            .single
            .read<String>('value'),
        'preserved',
      );
      expect(await file.exists(), isTrue);
    },
  );

  test('current database is accepted without an unnecessary backup', () async {
    final dir = await Directory.systemTemp.createTemp(
      'opc-current-database-',
    );
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}source.sqlite');
    final backupDir = Directory('${dir.path}${Platform.pathSeparator}backups');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    await db.customStatement('PRAGMA user_version = 37');
    await db.close();

    await ensureMigrationBackupBeforeOpen(
      databaseFile: file,
      backupDirectory: backupDir,
    );
    expect(await backupDir.exists(), isFalse);
    expect(await file.exists(), isTrue);
  });

  test('unsupported newer database is not replaced or backed up', () async {
    final dir = await Directory.systemTemp.createTemp('opc-newer-database-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}source.sqlite');
    final backupDir = Directory('${dir.path}${Platform.pathSeparator}backups');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    await db.customStatement('PRAGMA user_version = 38');
    await db.close();
    await expectLater(
      ensureMigrationBackupBeforeOpen(
        databaseFile: file,
        backupDirectory: backupDir,
      ),
      throwsStateError,
    );
    expect(await backupDir.exists(), isFalse);
    expect(await file.exists(), isTrue);
  });

  test('failed backup stops upgrade and a later retry can succeed', () async {
    final dir = await Directory.systemTemp.createTemp('opc-backup-retry-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}source.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    await db.customStatement('PRAGMA user_version = 36');
    await db.close();

    final blockedDirectory = File(
      '${dir.path}${Platform.pathSeparator}blocked',
    );
    await blockedDirectory.writeAsString('not a directory');
    await expectLater(
      ensureMigrationBackupBeforeOpen(
        databaseFile: file,
        backupDirectory: Directory(blockedDirectory.path),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(await file.exists(), isTrue);

    final goodDirectory = Directory(
      '${dir.path}${Platform.pathSeparator}valid',
    );
    await ensureMigrationBackupBeforeOpen(
      databaseFile: file,
      backupDirectory: goodDirectory,
    );
    expect(await goodDirectory.list().length, 1);
  });

  test(
    'snapshot includes committed WAL rows while another connection is open',
    () async {
      final dir = await Directory.systemTemp.createTemp('opc-wal-snapshot-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}${Platform.pathSeparator}source.sqlite');
      final db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customSelect('SELECT 1').get();
      await db.customStatement('PRAGMA journal_mode = WAL');
      await db.customStatement('PRAGMA user_version = 36');
      await db.customStatement('CREATE TABLE preflight_wal (value TEXT)');
      await db.customStatement(
        "INSERT INTO preflight_wal VALUES ('committed')",
      );

      final backups = Directory('${dir.path}${Platform.pathSeparator}backups');
      await ensureMigrationBackupBeforeOpen(
        databaseFile: file,
        backupDirectory: backups,
      );
      await db.close();
      final backup = (await backups.list().toList()).single as File;
      final restored = AppDatabase.forTesting(NativeDatabase(backup));
      addTearDown(restored.close);
      expect(
        (await restored.customSelect('SELECT value FROM preflight_wal').get())
            .single
            .read<String>('value'),
        'committed',
      );
    },
  );
}
