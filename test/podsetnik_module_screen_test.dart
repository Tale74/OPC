import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podsetnik/presentation/podsetnik_module_screen.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test(
    'PODSETNIK candidates use canonical status filters and newest first',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = PredmetiRepository(db);

      await _insert(
        db,
        ime: 'Stariji',
        status: 'OTVOREN',
        createdAt: '2026-07-10T10:00:00.000',
      );
      await _insert(
        db,
        ime: 'Najnoviji',
        status: 'ZATVOREN',
        createdAt: '2026-07-12T10:00:00.000',
      );
      await _insert(
        db,
        ime: 'DrugiStatus',
        status: 'U_OBRADI',
        createdAt: '2026-07-11T10:00:00.000',
      );
      await _insert(
        db,
        ime: 'Zavrseni',
        status: 'ZAVRŠEN',
        createdAt: '2026-07-14T10:00:00.000',
      );
      await _insert(
        db,
        ime: 'Anonimizovani',
        status: 'ANONIMIZOVAN',
        createdAt: '2026-07-15T10:00:00.000',
      );

      final candidates = await repo.getPodsetnikKandidate();

      expect(candidates.map((predmet) => predmet.ime), [
        'Najnoviji',
        'DrugiStatus',
        'Stariji',
      ]);
      expect(candidates.map((predmet) => predmet.status), [
        'ZATVOREN',
        'U_OBRADI',
        'OTVOREN',
      ]);
    },
  );

  testWidgets('PODSETNIK selector omits number prefix and keeps flow usable', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
    final id = await _insert(
      db,
      ime: 'Mila',
      prezime: 'Milić',
      status: 'OTVOREN',
      createdAt: '2026-07-12T10:00:00.000',
      brojPredmeta: '2026-0042',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PodsetnikModuleScreen(
          predmetiRepository: PredmetiRepository(db),
          predmetId: id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mila Milić'), findsOneWidget);
    expect(find.textContaining('#'), findsNothing);
    expect(find.textContaining('2026-0042'), findsNothing);
    expect(find.byKey(const Key('podsetnik-module-settings')), findsOneWidget);
    expect(
      find.byKey(const Key('podsetnik-reminders-enabled')),
      findsOneWidget,
    );
  });

  testWidgets('PODSETNIK renders an empty candidate list safely', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
    await _insert(
      db,
      ime: 'Zavrseni',
      status: 'ZAVRŠEN',
      createdAt: '2026-07-12T10:00:00.000',
    );
    await _insert(
      db,
      ime: 'Anonimizovani',
      status: 'ANONIMIZOVAN',
      createdAt: '2026-07-13T10:00:00.000',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PodsetnikModuleScreen(predmetiRepository: PredmetiRepository(db)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nema PREDMETA dostupnih za PODSETNIK.'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}

Future<int> _insert(
  AppDatabase db, {
  required String ime,
  required String status,
  required String createdAt,
  String prezime = 'Test',
  String brojPredmeta = '',
}) => db
    .into(db.predmeti)
    .insert(
      PredmetiCompanion.insert(
        brojPredmeta: Value(brojPredmeta),
        datumKreiranja: Value(createdAt),
        ime: Value(ime),
        prezime: Value(prezime),
        status: Value(status),
      ),
    );
