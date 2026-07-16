import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';

void main() {
  final configuredPath = Platform.environment['OPC_OWNER_MIGRATION_COPY'];
  final enabled = configuredPath != null && configuredPath.trim().isNotEmpty;

  test(
    'verified owner-derived copy migrates and reopens through AppDatabase',
    () async {
      final file = File(configuredPath!);
      final normalized = file.absolute.path.toLowerCase();
      expect(normalized, contains('migration_test'));
      expect(normalized, isNot(endsWith('opc_v4_release.sqlite')));
      expect(normalized, isNot(endsWith('opc_v4_windows_test.sqlite')));
      expect(await file.exists(), isTrue);

      final first = AppDatabase.forTesting(NativeDatabase(file));
      expect(await _userVersion(first), first.schemaVersion);
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      expect(await _userVersion(second), second.schemaVersion);
      await second.close();
    },
    skip: enabled
        ? false
        : 'Set OPC_OWNER_MIGRATION_COPY to a verified isolated copy.',
  );
}

Future<int> _userVersion(AppDatabase db) async =>
    (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
      'user_version',
    );
