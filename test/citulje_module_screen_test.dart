import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/citulje/data/citulje_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/citulje/domain/citulje_models.dart';
import 'package:opc_v4/features/predmeti/citulje/presentation/citulje_module_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ČITULJE module prepares and finalizes an independent occurrence',
    (tester) async {
      final db = _createCituljeTestDatabase();
      final navigationObserver = _RecordingNavigatorObserver();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        await db.close();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      });
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('R3-UI-001'),
              ime: const Value('Ana'),
              prezime: const Value('Test'),
            ),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: 'CITULJA_POLITIKA',
              portableOccurrenceId: const Value('ui-politika-1'),
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: CituljeModuleScreen(predmetiRepository: PredmetiRepository(db)),
          navigatorObservers: [navigationObserver],
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }

      expect(
        find.byKey(const Key('citulje-module-predmet-list')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('citulje-predmet-selector')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ana Test'), findsOneWidget);
      await tester.tap(find.textContaining('Ana Test'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('citulje-card-ui-politika-1')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<CituljePreparationScreen>(
              find.byType(CituljePreparationScreen),
            )
            .predmet
            .id,
        predmetId,
      );
      expect(navigationObserver.preparationPushCount, 1);
      expect(find.text('OTVORI ČITULJE'), findsNothing);
      expect(find.text('ČITULJA POLITIKA'), findsOneWidget);
      expect(find.textContaining('portableOccurrenceId:'), findsNothing);
      expect(find.byKey(const Key('citulje-note')), findsNothing);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('citulje-publication-date')),
            )
            .readOnly,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('citulje-parte-text-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NE').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('citulje-publication-text')),
        'Samostalan tekst A',
      );
      await _selectCituljePublicationDate(tester);
      await tester.tap(find.byKey(const Key('citulje-save')));
      await tester.pumpAndSettle();
      expect(find.text('Samostalan tekst A'), findsOneWidget);
      expect(find.text('Informativno: 3 reči'), findsOneWidget);
      expect(find.byKey(const Key('citulje-export-pdf')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('citulje-publication-text')),
        'Samostalan tekst B',
      );
      await _selectCituljePublicationDate(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('citulje-finalize')));
      await tester.pumpAndSettle();
      expect(find.text('Finalizuj ČITULJA pripremu?'), findsOneWidget);
      await tester.tap(find.text('FINALIZUJ').last);
      await tester.pumpAndSettle();
      expect(find.text('FINALIZOVANO'), findsOneWidget);
      expect(
        find.textContaining('PARTE više ne menja ovu finalizovanu pripremu'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('citulje-publication-date')),
            )
            .enabled,
        isTrue,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('citulje-publication-text')),
            )
            .enabled,
        isTrue,
      );
      expect(find.byKey(const Key('citulje-remove')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('citulje-publication-text')),
        'Ručna korekcija teksta',
      );
      await _selectCituljePublicationDate(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('citulje-save')));
      await tester.pumpAndSettle();
      final finalized = (await db.select(db.cituljePripreme).getSingle());
      expect(finalized.publicationText, 'Ručna korekcija teksta');
      expect(
        finalized.publicationDate,
        matches(RegExp(r'^\d{2}\.\d{2}\.\d{4}\.$')),
      );
      expect(finalized.note, isEmpty);
      expect(finalized.finalized, isTrue);
      expect(finalized.finalizedAt, isNotNull);
      await tester.tap(find.byKey(const Key('citulje-remove')));
      await tester.pumpAndSettle();
      expect(find.text('Ukloniti ČITULJA pripremu?'), findsOneWidget);
      await tester.tap(find.text('UKLONI'));
      await tester.pumpAndSettle();
      expect(await db.select(db.cituljePripreme).get(), isEmpty);
      expect(await db.select(db.iriu).get(), hasLength(1));
    },
  );

  testWidgets(
    'ČITULJE selector preserves eligible statuses and invalidates terminal candidates',
    (tester) async {
      final db = _createCituljeTestDatabase();
      final navigationObserver = _RecordingNavigatorObserver();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        await db.close();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      });

      final openId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('CIT-OPEN'),
              ime: const Value('Otvoren'),
              prezime: const Value('Predmet'),
              datumKreiranja: const Value('2026-09-12T10:00:00.000'),
              status: const Value('OTVOREN'),
            ),
          );
      final closedId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('CIT-CLOSED'),
              ime: const Value('Zatvoren'),
              prezime: const Value('Predmet'),
              datumKreiranja: const Value('2026-09-11T10:00:00.000'),
              status: const Value('ZATVOREN'),
            ),
          );
      final finishedId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('CIT-FINISHED'),
              ime: const Value('Završen'),
              prezime: const Value('Predmet'),
              datumKreiranja: const Value('2026-09-10T10:00:00.000'),
              status: const Value('ZAVRŠEN'),
            ),
          );
      for (final row in [
        (openId, 'citulja-open'),
        (closedId, 'citulja-closed'),
        (finishedId, 'citulja-finished'),
      ]) {
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: row.$1,
                interniNaziv: 'CITULJA_POLITIKA',
                portableOccurrenceId: Value(row.$2),
              ),
            );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: CituljeModuleScreen(predmetiRepository: PredmetiRepository(db)),
          navigatorObservers: [navigationObserver],
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('citulje-predmet-selector')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Otvoren Predmet'), findsOneWidget);
      expect(find.textContaining('Zatvoren Predmet'), findsOneWidget);
      expect(find.textContaining('Završen Predmet'), findsNothing);
      await tester.tap(find.textContaining('Zatvoren Predmet'));
      await tester.pumpAndSettle();
      expect(find.byType(CituljePreparationScreen), findsOneWidget);
      expect(
        tester
            .widget<CituljePreparationScreen>(
              find.byType(CituljePreparationScreen),
            )
            .predmet
            .id,
        closedId,
      );
      expect(navigationObserver.preparationPushCount, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(navigationObserver.preparationPushCount, 1);
      expect(find.text('OTVORI ČITULJE'), findsNothing);

      final selector = tester.widget<DropdownButtonFormField<int>>(
        find.byKey(const Key('citulje-predmet-selector')),
      );
      selector.onChanged!(null);
      await tester.pumpAndSettle();
      expect(navigationObserver.preparationPushCount, 1);

      await (db.update(db.predmeti)..where((row) => row.id.equals(closedId)))
          .write(const PredmetiCompanion(status: Value('ZAVRŠEN')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('citulje-predmet-selector')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Zatvoren Predmet'), findsNothing);
      expect(find.textContaining('Otvoren Predmet'), findsOneWidget);
      expect(find.textContaining('Završen Predmet'), findsNothing);
    },
  );

  testWidgets(
    'ČITULJE selector keeps a name primary and number only secondary for fallback',
    (tester) async {
      final db = _createCituljeTestDatabase();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        await db.close();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      });
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('CIT-FALLBACK'),
              datumKreiranja: const Value('2026-09-12T12:00:00.000'),
              status: const Value('OTVOREN'),
            ),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: 'CITULJA_NOVOSTI',
              portableOccurrenceId: const Value('citulja-fallback'),
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: CituljeModuleScreen(predmetiRepository: PredmetiRepository(db)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('citulje-predmet-selector')));
      await tester.pumpAndSettle();

      expect(find.textContaining('PREDMET'), findsAtLeastNWidgets(1));
      expect(
        find.textContaining('Broj PREDMETA: CIT-FALLBACK'),
        findsOneWidget,
      );
    },
  );

  testWidgets('DA proposal is editable before finalization', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(brojPredmeta: const Value('R3-DA-UI')),
        );
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'CITULJA_POLITIKA',
            portableOccurrenceId: const Value('da-ui-1'),
          ),
        );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final repository = CituljePreparationRepository(db);
    final row = (await repository.ensureCurrentForPredmet(predmetId)).single;
    await repository.configure(
      preparationId: row.id,
      mode: CituljeParteTextMode.da,
    );
    await (db.update(
      db.cituljePripreme,
    )..where((item) => item.id.equals(row.id))).write(
      const CituljePripremeCompanion(
        publicationText: Value('PARTE potvrđeni predlog'),
        state: Value('PARTE_SNAPSHOT_AVAILABLE'),
        parteSnapshotFingerprint: Value('ui-fingerprint'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CituljePreparationScreen(
          predmet: predmet,
          preparations: repository,
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    final field = tester.widget<TextField>(
      find.byKey(const Key('citulje-publication-text')),
    );
    expect(field.enabled, isTrue);
    await tester.enterText(
      find.byKey(const Key('citulje-publication-text')),
      'ČITULJE ručno dopunjen predlog',
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('citulje-save')));
    await tester.pumpAndSettle();
    expect(
      (await repository.findByOccurrence(
        predmetId: predmetId,
        portableOccurrenceId: 'da-ui-1',
      ))!.publicationText,
      'ČITULJE ručno dopunjen predlog',
    );
  });

  testWidgets('ČITULJE preparation follows the established wide layout', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
      await tester.binding.setSurfaceSize(null);
    });
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(brojPredmeta: const Value('CIT-LAYOUT')),
        );
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'CITULJA_POLITIKA',
            portableOccurrenceId: const Value('layout-1'),
          ),
        );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final repository = CituljePreparationRepository(db);
    await repository.ensureCurrentForPredmet(predmetId);

    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: CituljePreparationScreen(
          predmet: predmet,
          preparations: repository,
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    final mode = find.byKey(const Key('citulje-parte-text-mode'));
    final date = find.byKey(const Key('citulje-publication-date'));
    final text = find.byKey(const Key('citulje-publication-text'));
    final save = find.byKey(const Key('citulje-save'));
    expect(tester.getTopLeft(mode).dx, lessThan(tester.getTopLeft(text).dx));
    expect(tester.getTopLeft(date).dx, lessThan(tester.getTopLeft(text).dx));
    expect(find.byKey(const Key('citulje-note')), findsNothing);
    expect(tester.getTopLeft(save).dx, greaterThan(tester.getTopLeft(mode).dx));
    expect(tester.takeException(), equals(null));

    await tester.binding.setSurfaceSize(const Size(360, 900));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(date).dx,
      closeTo(tester.getTopLeft(text).dx, 0.1),
    );
    expect(tester.takeException(), equals(null));
  });

  testWidgets('ČITULJE UI follows the current concrete KATALOG article name', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('CIT-02-UI'),
            ime: const Value('Milan'),
            prezime: const Value('Test'),
          ),
        );
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'CITULJA_POLITIKA',
            nazivPrikaz: const Value('Porodična čitulja'),
            katalogStableArticleId: const Value('CIT-P-001'),
            portableOccurrenceId: const Value('citulja-concrete-ui-1'),
          ),
        );
    final predmet = (await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle());

    final repository = CituljePreparationRepository(db);
    final preparation = (await repository.ensureCurrentForPredmet(
      predmetId,
    )).single;
    expect(
      await repository.currentCituljaDisplayValue(preparation),
      'Porodična čitulja',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CituljePreparationScreen(
          predmet: predmet,
          preparations: repository,
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    final renderedLabels = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    expect(renderedLabels, contains('Porodična čitulja'));
    expect(find.text('ČITULJA POLITIKA'), findsNothing);
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int preparationPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null && route is MaterialPageRoute<dynamic>) {
      preparationPushCount++;
    }
    super.didPush(route, previousRoute);
  }
}

AppDatabase _createCituljeTestDatabase() => AppDatabase.forTesting(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Future<void> _selectCituljePublicationDate(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('citulje-publication-date')));
  await tester.pumpAndSettle();
  expect(find.byType(CalendarDatePicker), findsOneWidget);
  final day = DateTime.now().day.toString();
  await tester.tap(
    find
        .descendant(
          of: find.byType(CalendarDatePicker),
          matching: find.text(day),
        )
        .last,
  );
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}
