import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/podesavanja/presentation/podesavanja_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/pdf/racun_document_data.dart';
import 'package:opc_v4/features/predmeti/pdf/racun_docx_exporter.dart';
import 'package:opc_v4/features/predmeti/pdf/racun_pdf_export.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';

import 'support/opc_database_migration_fixture.dart';
import 'test_bootstrap.dart';

void main() {
  test('fresh FIRMA singleton defaults RAČUN to enabled', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final firma = await (db.select(
      db.firmaPodaci,
    )..where((row) => row.id.equals(1))).getSingle();

    expect(firma.racunOmogucen, isTrue);
  });

  test(
    'schema 35 adds the RAČUN toggle without replacing FIRMA data',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'opc_racun_migration_',
      );
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final template =
          await OpcDatabaseMigrationFixture.createPopulatedCurrentTemplate(
            root,
          );
      final fixture = await OpcDatabaseMigrationFixture.copyFromTemplate(
        template: template,
        name: 'racun_v35',
      );
      addTearDown(fixture.dispose);
      final db = fixture.openAtVersion(35);
      addTearDown(db.close);

      final columns = await db
          .customSelect('PRAGMA table_info(firma_podaci)')
          .get();
      final firma = await (db.select(
        db.firmaPodaci,
      )..where((row) => row.id.equals(1))).getSingle();

      expect(
        columns.map((row) => row.read<String>('name')),
        contains('racun_omogucen'),
      );
      final columnNames = columns.map((row) => row.read<String>('name'));
      expect(columnNames, isNot(contains('preduzetnik')));
      expect(columnNames, isNot(contains('pdv')));
      expect(firma.naziv, 'SYNTHETIC MIGRATION FIRMA');
      expect(firma.racunOmogucen, isTrue);
    },
  );

  testWidgets('FIRMA RAČUN setting persists both OFF and ON', (tester) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
    final authRepo = AuthRepository(db);
    final session = SessionService();
    final admin = await authRepo.kreirajPrvogAdmina(
      imePrezime: 'Test Administrator',
      pin: '1234',
    );
    session.prijavi(admin);

    await tester.pumpWidget(
      wrapForTest(
        PodesavanjaScreen(
          repo: PodesavanjaRepository(db),
          authRepo: authRepo,
          session: session,
          initialSection: OpcSettingsSection.podaciFirme,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RAČUN'), findsOneWidget);
    expect(
      find.text(
        'Račun može da se formira ukoliko je pravno lice preduzetnik i nije u sistemu PDV',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    final switchFinder = find.byType(SwitchListTile);
    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    final saveFinder = find.widgetWithText(FilledButton, 'SAČUVAJ');
    await tester.ensureVisible(saveFinder);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(
      (await (db.select(
        db.firmaPodaci,
      )..where((row) => row.id.equals(1))).getSingle()).racunOmogucen,
      isFalse,
    );

    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveFinder);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();
    expect(
      (await (db.select(
        db.firmaPodaci,
      )..where((row) => row.id.equals(1))).getSingle()).racunOmogucen,
      isTrue,
    );
    session.dispose();
  });

  testWidgets('PREDMET exposes PDF and DOCX together only when enabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = createTestDatabase();
    final session = SessionService();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      session.dispose();
      await db.close();
    });
    final admin = await AuthRepository(
      db,
    ).kreirajPrvogAdmina(imePrezime: 'Test Administrator', pin: '1234');
    session.prijavi(admin);
    final repository = PredmetiRepository(db);
    final predmetId = await repository.kreirajPredmet(savetnikId: admin.id);
    final entitlement = OpcEntitlementPolicy.fromPayload(
      OpcEntitlementPayload.presentationPotpun,
    );

    Future<void> mountScreen(bool enabled, TargetPlatform platform) async {
      await (db.update(db.firmaPodaci)..where((row) => row.id.equals(1))).write(
        FirmaPodaciCompanion(racunOmogucen: Value(enabled)),
      );
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          theme: ThemeData(platform: platform),
          home: PredmetScreen(
            key: UniqueKey(),
            predmetId: predmetId,
            predmetiRepo: repository,
            session: session,
            openDocuments: true,
            entitlementPolicy: entitlement,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final platform in const [
      TargetPlatform.windows,
      TargetPlatform.android,
    ]) {
      await mountScreen(false, platform);
      expect(find.text('RAČUN PDF'), findsNothing);
      expect(find.text('RAČUN DOCX'), findsNothing);
      expect(find.text('PREDMET PDF snapshot'), findsNothing);

      await mountScreen(true, platform);
      expect(find.text('RAČUN PDF'), findsOneWidget);
      expect(find.text('RAČUN DOCX'), findsOneWidget);
      expect(find.text('PREDMET PDF snapshot'), findsNothing);
    }
  });

  test(
    'Backup preserves RAČUN toggle and defaults legacy backups to enabled',
    () async {
      final source = createTestDatabase();
      final restored = createTestDatabase();
      final legacyRestored = createTestDatabase();
      addTearDown(source.close);
      addTearDown(restored.close);
      addTearDown(legacyRestored.close);

      await (source.update(source.firmaPodaci)
            ..where((row) => row.id.equals(1)))
          .write(const FirmaPodaciCompanion(racunOmogucen: Value(false)));
      final backup =
          jsonDecode(await serializeBackupJsonForTest(db: source))
              as Map<String, dynamic>;
      final exportedFirma = backup['firmaPodaci'] as Map<String, dynamic>;
      expect(exportedFirma['racunOmogucen'], isFalse);

      await importBackupJsonMapForTest(db: restored, json: backup);
      expect(
        (await (restored.select(
          restored.firmaPodaci,
        )..where((row) => row.id.equals(1))).getSingle()).racunOmogucen,
        isFalse,
      );

      final legacy = jsonDecode(jsonEncode(backup)) as Map<String, dynamic>;
      (legacy['firmaPodaci'] as Map<String, dynamic>).remove('racunOmogucen');
      await importBackupJsonMapForTest(db: legacyRestored, json: legacy);
      expect(
        (await (legacyRestored.select(
          legacyRestored.firmaPodaci,
        )..where((row) => row.id.equals(1))).getSingle()).racunOmogucen,
        isTrue,
      );
    },
  );

  test('PDF and DOCX consume the same canonical RAČUN snapshot', () async {
    final sample = await _createRepresentativeRacun();
    final db = sample.db;
    addTearDown(db.close);
    final data = sample.data;
    expect(data.headerTitle, 'RAČUN BR: RACUN-001');
    expect(data.payerHeading, 'PLATILAC: PETAR PLATILAC');
    expect(data.items.map((item) => item.naziv), contains('Test sanduk'));
    expect(data.labels.article33, contains('člana 33.'));
    expect(data.advisorName, 'Savetnik Test');
    expect(data.financialRows.map((row) => row.label), [
      'ROBA I USLUGE',
      'AVANS',
      'OSTATAK',
      'TROŠKOVI JKP',
      'UKUPNO',
      'POPUST',
      '',
      'UKUPNO',
    ]);
    expect(
      data.filenameFor('pdf').replaceFirst(RegExp(r'\.pdf$'), ''),
      data.filenameFor('docx').replaceFirst(RegExp(r'\.docx$'), ''),
    );
    expect(data.filenameFor('pdf'), endsWith('.pdf'));
    expect(data.filenameFor('docx'), endsWith('.docx'));

    final singlePredmet = jsonDecode(
      await serializePredmetJsonForTest(
        db: db,
        predmetId: sample.predmetId,
      ),
    );
    expect(jsonEncode(singlePredmet), isNot(contains('racunOmogucen')));

    final pdf = await buildRacunPdf(data);
    expect(utf8.decode(pdf.take(5).toList()), startsWith('%PDF-'));

    final docx = await buildRacunDocx(data);
    final reviewOutputPath =
        Platform.environment['OPC_RACUN_REVIEW_OUTPUT_DIR'];
    if (reviewOutputPath != null && reviewOutputPath.trim().isNotEmpty) {
      final reviewOutput = Directory(reviewOutputPath);
      await reviewOutput.create(recursive: true);
      await File(
        '${reviewOutput.path}${Platform.pathSeparator}representative-RACUN-001.pdf',
      ).writeAsBytes(pdf);
      await File(
        '${reviewOutput.path}${Platform.pathSeparator}representative-RACUN-001.docx',
      ).writeAsBytes(docx);
    }
    final archive = ZipDecoder().decodeBytes(docx);
    final archiveNames = archive.files.map((file) => file.name).toSet();
    expect(
      archiveNames,
      containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'word/document.xml',
        'word/styles.xml',
        'word/footer1.xml',
        'word/_rels/document.xml.rels',
      ]),
    );
    final documentXml = utf8.decode(
      archive.findFile('word/document.xml')!.content as List<int>,
    );
    expect(documentXml, contains('RAČUN BR: RACUN-001'));
    expect(documentXml, contains('FIRMA TEST'));
    expect(documentXml, contains('123456789'));
    expect(documentXml, contains('10000001'));
    expect(documentXml, contains('160-TEST'));
    expect(documentXml, contains('PETAR PLATILAC'));
    expect(documentXml, contains('Ulica 1'));
    expect(documentXml, contains('Test sanduk'));
    expect(documentXml, contains('člana 33.'));
    expect(documentXml, contains(data.financialRows.last.value));
  });

  test('RAČUN DOCX OOXML follows the PDF block structure', () async {
    final sample = await _createRepresentativeRacun();
    addTearDown(sample.db.close);

    final archive = ZipDecoder().decodeBytes(await buildRacunDocx(sample.data));
    final documentXml = _archiveText(archive, 'word/document.xml');
    final relationshipsXml = _archiveText(
      archive,
      'word/_rels/document.xml.rels',
    );
    final stylesXml = _archiveText(archive, 'word/styles.xml');
    final footerXml = _archiveText(archive, 'word/footer1.xml');

    final memorandum = _tableContaining(documentXml, 'FIRMA TEST');
    expect(memorandum, contains('Bulevar 1, Beograd'));
    expect(memorandum, contains('+381 11 123 4567 | office@example.test'));
    expect(memorandum, contains('PIB 123456789'));
    expect(memorandum, contains('MB 10000001'));
    expect(memorandum, contains('Račun 160-TEST'));
    expect(memorandum, contains('w:gridCol w:w="6900"'));

    final issueRow = _tableContaining(documentXml, 'RAČUN BR: RACUN-001');
    expect(issueRow, contains('FIRMA TEST'));
    expect(issueRow, contains('w:gridCol w:w="300"'));
    expect(issueRow, contains('<w:gridSpan w:val="2"/>'));
    expect(issueRow, contains('Datum izdavanja:'));
    expect(issueRow, contains('w:jc w:val="right"'));
    expect(issueRow, isNot(contains('Datum:')));

    final deceased = _tableContaining(
      documentXml,
      'PREMINULO LICE: ANA PRIMER',
    );
    expect(deceased, contains('<w:shd'));
    expect(deceased, contains('<w:tblBorders>'));

    final payer = _tableContaining(documentXml, 'PLATILAC: PETAR PLATILAC');
    expect(payer, contains('<w:gridSpan w:val="3"/>'));
    expect(payer, contains('JMBG: '));
    expect(payer, contains('0101990712345'));
    expect(payer, contains('Adresa: '));
    expect(payer, contains('Ulica 1, Beograd'));
    expect(payer, contains('Telefon 2: '));
    expect(payer, contains('+381 64 333 444'));
    expect(payer, contains('LK / pasoš: '));
    expect(payer, contains('AB123456'));
    expect(payer, contains('Telefon 1: '));
    expect(payer, contains('+381 60 111 222'));
    expect(
      payer.indexOf('JMBG: ') < payer.indexOf('Adresa: ') &&
          payer.indexOf('Adresa: ') < payer.indexOf('Telefon 2: ') &&
          payer.indexOf('Telefon 2: ') < payer.indexOf('LK / pasoš: ') &&
          payer.indexOf('LK / pasoš: ') < payer.indexOf('Telefon 1: '),
      isTrue,
    );

    final iriu = _tableContaining(documentXml, 'IRIU: IZABRANA ROBA I USLUGE');
    expect(_count(iriu, '<w:tbl>'), 3);
    expect(iriu, contains('NAZIV'));
    expect(iriu, contains('KOM'));
    expect(iriu, contains('IZNOS'));
    expect(iriu, contains('Test sanduk'));
    expect(iriu, contains('1.200,00 RSD'));
    expect(iriu, contains('ROBA I USLUGE'));
    expect(iriu, contains('TROŠKOVI JKP'));
    expect(iriu, contains('UKUPNO'));
    expect(iriu.indexOf('člana 33.') < iriu.indexOf('TROŠKOVI JKP'), isTrue);

    final signature = _tableContaining(documentXml, 'Potpis', ancestor: 1);
    expect(signature, contains('Potpis'));
    expect(signature, contains('MP'));
    expect(signature, contains('w:bottom w:val="single"'));
    expect(signature, contains('</w:tbl><w:p>'));
    expect(signature, isNot(contains('________________')));

    expect(documentXml, contains('<w:pgSz w:w="11906" w:h="16838"/>'));
    expect(documentXml, contains('w:top="400"'));
    expect(documentXml, contains('w:bottom="320"'));
    expect(documentXml, contains('w:footerReference w:type="default"'));
    expect(relationshipsXml, contains('Target="footer1.xml"'));
    expect(footerXml, contains(sample.data.advisorFooter));
    expect(footerXml, contains(sample.data.statusFooter));
    expect(footerXml, contains('w:instr=" PAGE "'));
    expect(footerXml, contains('w:instr=" NUMPAGES "'));
    expect(footerXml, contains('<w:tbl>'));
    expect(stylesXml, contains('w:ascii="Noto Sans"'));
    expect(stylesXml, contains('<w:sz w:val="16"/>'));
  });

  test('RAČUN DOCX logo is floating and anchored behind text', () async {
    final sample = await _createRepresentativeRacun();
    addTearDown(sample.db.close);

    final archive = ZipDecoder().decodeBytes(await buildRacunDocx(sample.data));
    final documentXml = _archiveText(archive, 'word/document.xml');
    final relationshipsXml = _archiveText(
      archive,
      'word/_rels/document.xml.rels',
    );

    expect(documentXml, contains('<wp:anchor'));
    expect(documentXml, contains('behindDoc="1"'));
    expect(documentXml, contains('<wp:wrapNone/>'));
    expect(documentXml, contains('<wp:positionH relativeFrom="page">'));
    expect(documentXml, contains('<wp:positionV relativeFrom="page">'));
    expect(documentXml, isNot(contains('<wp:inline')));
    expect(relationshipsXml, contains('Id="rIdFirmaLogo"'));
    expect(relationshipsXml, contains('Target="media/firma_logo.png"'));
  });

  test('disabled FIRMA toggle fails closed for both RAČUN adapters', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await (db.update(db.firmaPodaci)..where((row) => row.id.equals(1))).write(
      const FirmaPodaciCompanion(racunOmogucen: Value(false)),
    );
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion(
            brojPredmeta: const Value('RACUN-OFF'),
            datumKreiranja: Value(DateTime(2026, 9, 20).toIso8601String()),
          ),
        );

    await expectLater(
      RacunDocumentData.load(db: db, predmetId: predmetId),
      throwsA(isA<StateError>()),
    );
  });
}

Future<({AppDatabase db, int predmetId, RacunDocumentData data})>
_createRepresentativeRacun() async {
  final db = createTestDatabase();
  try {
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion(
            brojPredmeta: const Value('RACUN-001'),
            datumKreiranja: Value(DateTime(2026, 9, 20).toIso8601String()),
            ime: const Value('Ana'),
            prezime: const Value('Primer'),
            businessResponsibleName: const Value('Savetnik Test'),
            naruTip: const Value('FIZICKO_LICE'),
            naruImePrezime: const Value('Petar Platilac'),
            naruJmbg: const Value('0101990712345'),
            naruBrojLk: const Value('AB123456'),
            naruAdresa: const Value('Ulica 1, Beograd'),
            naruTelefon1: const Value('+381 60 111 222'),
            naruTelefon2: const Value('+381 64 333 444'),
            avans: const Value(100),
            troskoviJkp: const Value(25),
            popust: const Value(50),
          ),
        );
    final testLogo = await File(
      'assets/app_icon/opc_app_icon_preview_512.png',
    ).readAsBytes();
    await (db.update(db.firmaPodaci)..where((row) => row.id.equals(1))).write(
      FirmaPodaciCompanion(
        naziv: const Value('FIRMA TEST'),
        adresa: const Value('Bulevar 1, Beograd'),
        telefon: const Value('+381 11 123 4567'),
        email: const Value('office@example.test'),
        pib: const Value('123456789'),
        mb: const Value('10000001'),
        logo: Value(testLogo),
      ),
    );
    await (db.update(db.appPodesavanja)..where((row) => row.id.equals(1)))
        .write(const AppPodesavanjaCompanion(ziroRacun: Value('160-TEST')));
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'SANDUK',
            nazivPrikaz: const Value('Test sanduk'),
            kom: const Value('1'),
            iznos: const Value(1200),
            cekiran: const Value(true),
          ),
        );
    return (
      db: db,
      predmetId: predmetId,
      data: await RacunDocumentData.load(db: db, predmetId: predmetId),
    );
  } catch (_) {
    await db.close();
    rethrow;
  }
}

String _archiveText(Archive archive, String path) =>
    utf8.decode(archive.findFile(path)!.content as List<int>);

String _tableContaining(String xml, String marker, {int ancestor = 0}) {
  final markerIndex = xml.indexOf(marker);
  if (markerIndex < 0) throw StateError('OOXML marker not found: $marker');
  final tableStarts = RegExp(r'<w:tbl>')
      .allMatches(xml.substring(0, markerIndex))
      .map((match) => match.start)
      .toList();
  final containing = <(int, int)>[];
  for (final start in tableStarts) {
    var depth = 0;
    for (final match in RegExp(r'</?w:tbl>').allMatches(xml, start)) {
      if (match.start >= markerIndex && depth == 0) break;
      if (match.group(0) == '<w:tbl>') {
        depth++;
      } else {
        depth--;
        if (depth == 0) {
          if (match.end > markerIndex) containing.add((start, match.end));
          break;
        }
      }
    }
  }
  if (containing.length <= ancestor) {
    throw StateError('OOXML table ancestor $ancestor not found for: $marker');
  }
  final (start, end) = containing[containing.length - ancestor - 1];
  return xml.substring(start, end);
}

int _count(String value, String substring) => substring.isEmpty
    ? 0
    : RegExp(RegExp.escape(substring)).allMatches(value).length;
