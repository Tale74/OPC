import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'migration_test_database_selector.dart';

Future<QueryExecutor?> openMigrationTestDatabaseExecutor() async {
  final file = await resolveMigrationTestDatabaseFile();
  if (file == null) return null;
  return NativeDatabase(file);
}
