import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    // Sprečiti default zatvaranje — hendlujemo ga sami u WindowListener
    await windowManager.setPreventClose(true);
  }

  // Inicijalizacija srpskog locale za formatiranje datuma u parte
  await initializeDateFormatting('sr_Latn_RS');
  final db = AppDatabase();
  runApp(OpcApp(db: db));
}
