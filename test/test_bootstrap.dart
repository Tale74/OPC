import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';

import 'package:opc_v4/core/database/database.dart';

bool _driftMultipleDatabaseWarningDisabled = false;

AppDatabase createTestDatabase() {
  if (!_driftMultipleDatabaseWarningDisabled) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    _driftMultipleDatabaseWarningDisabled = true;
  }
  return AppDatabase.forTesting(NativeDatabase.memory());
}

Widget wrapForTest(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: child,
  );
}
