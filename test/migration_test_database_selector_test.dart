import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/config/app_config.dart';
import 'package:opc_v4/core/database/migration_test_database_selector.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory documents;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('opc_migration_selector_');
    documents = await Directory(p.join(root.path, 'documents')).create();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<Directory> documentsProvider() async => documents;

  test(
    'PRODUCTION ignores the test-only define and keeps its normal lane',
    () async {
      var documentsLookupCalled = false;

      final selected = await resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.production,
        configuredPath: p.join(root.path, 'missing_MIGRATION_TEST.sqlite'),
        documentsDirectoryProvider: () async {
          documentsLookupCalled = true;
          return documents;
        },
      );

      expect(selected, isNull);
      expect(documentsLookupCalled, isFalse);
    },
  );

  test('WINDOWS_TEST rejects a missing define', () async {
    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: '',
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('requires')),
    );
  });

  test('WINDOWS_TEST rejects a relative path', () async {
    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: 'owner_MIGRATION_TEST.sqlite',
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('absolute')),
    );
  });

  test('WINDOWS_TEST rejects the canonical filename', () async {
    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: p.join(root.path, 'opc_v4_release.sqlite'),
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('canonical')),
    );
  });

  test('WINDOWS_TEST rejects a non MIGRATION_TEST filename', () async {
    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: p.join(root.path, 'opc_copy.sqlite'),
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('MIGRATION_TEST')),
    );
  });

  test('WINDOWS_TEST rejects a missing file', () async {
    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: p.join(root.path, 'owner_MIGRATION_TEST.sqlite'),
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('existing file')),
    );
  });

  test('WINDOWS_TEST rejects a file without a SQLite header', () async {
    final invalid = File(p.join(root.path, 'owner_MIGRATION_TEST.sqlite'));
    await invalid.writeAsString('not a sqlite database');

    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: invalid.path,
        documentsDirectoryProvider: documentsProvider,
      ),
      throwsA(_selectionErrorContaining('SQLite 3 header')),
    );
  });

  test('WINDOWS_TEST rejects a filesystem alias of canonical', () async {
    final canonical = File(p.join(documents.path, 'opc_v4_release.sqlite'));
    await _writeSqliteHeader(canonical);
    final candidate = File(p.join(root.path, 'owner_MIGRATION_TEST.sqlite'));
    await _writeSqliteHeader(candidate);

    await expectLater(
      resolveMigrationTestDatabaseFile(
        buildVariant: AppBuildVariant.windowsTest,
        configuredPath: candidate.path,
        documentsDirectoryProvider: documentsProvider,
        fileIdentityProvider: (firstPath, secondPath) async {
          expect(firstPath, candidate.path);
          expect(secondPath, canonical.path);
          return true;
        },
      ),
      throwsA(_selectionErrorContaining('filesystem alias')),
    );
  });

  test('WINDOWS_TEST accepts only the explicit valid copy', () async {
    final canonical = File(p.join(documents.path, 'opc_v4_release.sqlite'));
    await _writeSqliteHeader(canonical);
    final candidate = File(p.join(root.path, 'owner_MIGRATION_TEST.sqlite'));
    await _writeSqliteHeader(candidate);

    final selected = await resolveMigrationTestDatabaseFile(
      buildVariant: AppBuildVariant.windowsTest,
      configuredPath: candidate.path,
      documentsDirectoryProvider: documentsProvider,
      fileIdentityProvider: (firstPath, secondPath) async => false,
    );

    expect(selected?.path, candidate.path);
  });
}

Matcher _selectionErrorContaining(String text) {
  return isA<OpcMigrationTestDatabaseSelectionException>().having(
    (error) => error.message,
    'message',
    contains(text),
  );
}

Future<void> _writeSqliteHeader(File file) async {
  await file.writeAsBytes(<int>[
    ...ascii.encode('SQLite format 3\u0000'),
    ...List<int>.filled(32, 0),
  ]);
}
