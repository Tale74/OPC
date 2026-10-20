import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';

import 'test_bootstrap.dart';

const _pibA = '111111111';
const _mbA = '10000001';
const _pibB = '222222222';
const _mbB = '20000002';
const _successMessage = 'PREDMET uspešno uvezen kao novi lokalni predmet.';
const _predmetFirmaMismatchMessage =
    'PREDMET JSON nije moguće uvesti jer se identitet FIRME razlikuje '
    'od lokalne instalacije. Lokalni podaci nisu promenjeni.';
const _backupFirmaMismatchMessage =
    'Uvoz cele baze je blokiran: PIB/matični broj firme ne odgovara '
    'lokalnoj instalaciji. Lokalni podaci nisu promenjeni.';

void main() {
  group('PREDMET JSON import feedback through Settings UI', () {
    late FilePickerPlatform originalPicker;

    setUp(() {
      originalPicker = FilePickerPlatform.instance;
    });

    tearDown(() {
      FilePickerPlatform.instance = originalPicker;
    });

    testWidgets('same-FIRMA import completes and shows success SnackBar', (
      tester,
    ) async {
      final json = await _newPredmetJson();
      final picker = _ControlledFilePicker(_file(json));
      FilePickerPlatform.instance = picker;
      final db = await _mountSettings(tester, pib: _pibA, mb: _mbA);
      addTearDown(db.close);

      await _tapImport(tester);

      expect(picker.calls, 1);
      expect(picker.lastType, FileType.custom);
      expect(picker.lastAllowedExtensions, ['json']);
      expect(picker.lastWithData, isTrue);
      expect(
        (await db.select(db.predmeti).get()).map((row) => row.brojPredmeta),
        contains('WIDGET-FEEDBACK-001/2026'),
      );
      expect(find.byType(ScaffoldMessenger), findsOneWidget);
      expect(find.text(_successMessage), findsOneWidget);
    });

    testWidgets(
      'PREDMET result replaces active and queued notices in accessible navigation',
      (tester) async {
        final json = await _newPredmetJson();
        final picker = _ControlledFilePicker(_file(json));
        FilePickerPlatform.instance = picker;
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        final db = await _mountSettings(
          tester,
          pib: _pibA,
          mb: _mbA,
          messengerKey: messengerKey,
          accessibleNavigation: true,
        );
        addTearDown(db.close);

        _showRecoveryWarning(messengerKey);
        await tester.pump();
        await tester.pump(const Duration(seconds: 9));
        expect(
          find.textContaining('Sigurnosni kod nije podešen.'),
          findsOneWidget,
        );

        await _tapImport(tester);

        expect(picker.calls, 1);
        expect(
          (await db.select(db.predmeti).get()).map((row) => row.brojPredmeta),
          contains('WIDGET-FEEDBACK-001/2026'),
        );
        expect(find.text(_successMessage), findsOneWidget);
        expect(
          find.textContaining('Sigurnosni kod nije podešen.'),
          findsNothing,
        );
        expect(find.text('Čeka obaveštenje za oporavak.'), findsNothing);
      },
    );

    testWidgets(
      'cross-FIRMA PREDMET rejection is contextual and writes nothing',
      (tester) async {
        final json = await _newPredmetJson();
        final picker = _ControlledFilePicker(_file(json));
        FilePickerPlatform.instance = picker;
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        final db = await _mountSettings(
          tester,
          pib: _pibB,
          mb: _mbB,
          messengerKey: messengerKey,
          accessibleNavigation: true,
        );
        addTearDown(db.close);

        _showRecoveryWarning(messengerKey);
        await tester.pump();

        await _tapImport(tester);

        expect(picker.calls, 1);
        expect(
          find.text('Greška pri uvozu: $_predmetFirmaMismatchMessage'),
          findsOneWidget,
        );
        expect(find.text('Sigurnosni kod nije podešen.'), findsNothing);
        expect(find.textContaining('Uvoz cele baze'), findsNothing);
        expect(find.textContaining('backup'), findsNothing);
        await _expectNoBusinessWrites(db);
      },
    );

    testWidgets('cross-FIRMA full Backup retains its operation wording', (
      tester,
    ) async {
      final backup = await _newBackupJson();
      final picker = _ControlledFilePicker(_file(backup));
      FilePickerPlatform.instance = picker;
      final db = await _mountSettings(tester, pib: _pibB, mb: _mbB);
      addTearDown(db.close);

      await _tapImport(tester);

      expect(picker.calls, 1);
      expect(
        find.text('Greška pri uvozu: $_backupFirmaMismatchMessage'),
        findsOneWidget,
      );
      await _expectNoBusinessWrites(db);
    });

    testWidgets(
      'missing incoming FIRMA identity shows rejection and no write',
      (tester) async {
        final json = await _newPredmetJson();
        json.remove('firmaPodaci');
        final picker = _ControlledFilePicker(_file(json));
        FilePickerPlatform.instance = picker;
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        final db = await _mountSettings(
          tester,
          pib: _pibA,
          mb: _mbA,
          messengerKey: messengerKey,
          accessibleNavigation: true,
        );
        addTearDown(db.close);
        _showRecoveryWarning(messengerKey);
        await tester.pump();

        await _tapImport(tester);

        expect(picker.calls, 1);
        expect(
          find.textContaining('JSON nema FIRMA identifikaciju.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Sigurnosni kod nije podešen.'),
          findsNothing,
        );
        await _expectNoBusinessWrites(db);
      },
    );

    testWidgets(
      'incomplete incoming FIRMA identity shows distinct rejection and no write',
      (tester) async {
        final json = await _newPredmetJson();
        json['firmaPodaci'] = <String, dynamic>{'pib': _pibA, 'mb': ''};
        final picker = _ControlledFilePicker(_file(json));
        FilePickerPlatform.instance = picker;
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        final db = await _mountSettings(
          tester,
          pib: _pibA,
          mb: _mbA,
          messengerKey: messengerKey,
          accessibleNavigation: true,
        );
        addTearDown(db.close);
        _showRecoveryWarning(messengerKey);
        await tester.pump();

        await _tapImport(tester);

        expect(picker.calls, 1);
        expect(
          find.textContaining('JSON nema potpunu FIRMA identifikaciju.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Sigurnosni kod nije podešen.'),
          findsNothing,
        );
        await _expectNoBusinessWrites(db);
      },
    );

    testWidgets('cancelled selection is silent and does not mutate data', (
      tester,
    ) async {
      final picker = _ControlledFilePicker(null);
      FilePickerPlatform.instance = picker;
      final messengerKey = GlobalKey<ScaffoldMessengerState>();
      final db = await _mountSettings(
        tester,
        pib: _pibA,
        mb: _mbA,
        messengerKey: messengerKey,
        accessibleNavigation: true,
      );
      addTearDown(db.close);
      _showRecoveryWarning(messengerKey);
      await tester.pump();

      await _tapImport(tester);

      expect(picker.calls, 1);
      expect(await db.select(db.predmeti).get(), isEmpty);
      expect(await db.select(db.iriu).get(), isEmpty);
      expect(await db.select(db.kontaktLica).get(), isEmpty);
      expect(
        find.textContaining('Sigurnosni kod nije podešen.'),
        findsOneWidget,
      );
    });
  });
}

Future<Map<String, dynamic>> _newPredmetJson() async {
  final db = createTestDatabase();
  try {
    await _setFirmaIdentity(db, pib: _pibA, mb: _mbA);
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('WIDGET-FEEDBACK-001/2026'),
            datumKreiranja: const Value('2026-10-17T00:00:00.000'),
          ),
        );
    return jsonDecode(await serializePredmetJsonForTest(db: db, predmetId: id))
        as Map<String, dynamic>;
  } finally {
    await db.close();
  }
}

Future<Map<String, dynamic>> _newBackupJson() async {
  final db = createTestDatabase();
  try {
    await _setFirmaIdentity(db, pib: _pibA, mb: _mbA);
    return jsonDecode(await serializeBackupJsonForTest(db: db))
        as Map<String, dynamic>;
  } finally {
    await db.close();
  }
}

PlatformFile _file(Map<String, dynamic> json) {
  final bytes = Uint8List.fromList(utf8.encode(jsonEncode(json)));
  return PlatformFile(
    name: 'synthetic-predmet.json',
    size: bytes.length,
    bytes: bytes,
  );
}

Future<AppDatabase> _mountSettings(
  WidgetTester tester, {
  required String pib,
  required String mb,
  GlobalKey<ScaffoldMessengerState>? messengerKey,
  bool accessibleNavigation = false,
}) async {
  final db = createTestDatabase();
  await _setFirmaIdentity(db, pib: pib, mb: mb);
  final authRepo = AuthRepository(db);
  final admin = await authRepo.kreirajPrvogAdmina(
    imePrezime: 'Synthetic widget Administrator',
    pin: '1234',
  );
  final session = SessionService()..prijavi(admin);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(accessibleNavigation: accessibleNavigation),
        child: child!,
      ),
      home: PodesavanjaScreen(
        repo: PodesavanjaRepository(db),
        authRepo: authRepo,
        session: session,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byTooltip('Uvoz JSON'), findsOneWidget);
  return db;
}

Future<void> _tapImport(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Uvoz JSON'));
  await tester.pumpAndSettle();
}

void _showRecoveryWarning(GlobalKey<ScaffoldMessengerState> messengerKey) {
  messengerKey.currentState!.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 8),
      content: const Text(
        'Sigurnosni kod nije podešen. Aplikacija radi, '
        'ali podesite oporavak pristupa.',
      ),
      action: SnackBarAction(label: 'KORISNICI', onPressed: () {}),
    ),
  );
  messengerKey.currentState!.showSnackBar(
    const SnackBar(content: Text('Čeka obaveštenje za oporavak.')),
  );
}

Future<void> _setFirmaIdentity(
  AppDatabase db, {
  required String pib,
  required String mb,
}) async {
  final firma = await db.select(db.firmaPodaci).getSingle();
  await (db.update(db.firmaPodaci)..where((row) => row.id.equals(firma.id)))
      .write(FirmaPodaciCompanion(pib: Value(pib), mb: Value(mb)));
}

Future<void> _expectNoBusinessWrites(AppDatabase db) async {
  expect(await db.select(db.predmeti).get(), isEmpty);
  expect(await db.select(db.iriu).get(), isEmpty);
  expect(await db.select(db.kontaktLica).get(), isEmpty);
}

class _ControlledFilePicker extends FilePickerPlatform {
  _ControlledFilePicker(this.file);

  final PlatformFile? file;
  int calls = 0;
  FileType? lastType;
  List<String>? lastAllowedExtensions;
  bool? lastWithData;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async {
    calls++;
    lastType = type;
    lastAllowedExtensions = allowedExtensions;
    lastWithData = withData;
    return file == null ? null : FilePickerResult(<PlatformFile>[file!]);
  }
}
