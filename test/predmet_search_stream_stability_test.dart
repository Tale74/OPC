import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/lista_predmeta_screen.dart';

void main() {
  test('watchSvi creates a new stream instance for each call', () {
    final db = _createDatabase();
    addTearDown(db.close);
    final repository = PredmetiRepository(db);

    expect(identical(repository.watchSvi(), repository.watchSvi()), isFalse);
  });

  testWidgets(
    'PREDMET search keeps the existing list stream while filters change',
    (tester) async {
      final db = _createDatabase();
      final authRepo = AuthRepository(db);
      final session = SessionService();
      final admin = await authRepo.kreirajPrvogAdmina(
        imePrezime: 'Synthetic Search Admin',
        pin: '1234',
      );
      session.prijavi(admin);

      final alphaId = await PredmetiRepository(db).kreirajPredmet(
        savetnikId: admin.id,
      );
      final betaId = await PredmetiRepository(db).kreirajPredmet(
        savetnikId: admin.id,
      );
      await (db.update(
        db.predmeti,
      )..where((row) => row.id.equals(alphaId))).write(
        const PredmetiCompanion(
          ime: Value('Alpha'),
          prezime: Value('Synthetic'),
          brojPredmeta: Value('QA-ALPHA-001'),
        ),
      );
      await (db.update(
        db.predmeti,
      )..where((row) => row.id.equals(betaId))).write(
        const PredmetiCompanion(
          ime: Value('Beta'),
          prezime: Value('Synthetic'),
          brojPredmeta: Value('QA-BETA-002'),
        ),
      );
      final rows = await db.select(db.predmeti).get();
      final repository = _DelayedWatchPredmetiRepository(db);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        session.dispose();
        await db.close();
        await tester.idle();
        await tester.pump();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ListaPredmetaScreen(
            predmetiRepo: repository,
            authRepo: authRepo,
            podesavanjaRepo: PodesavanjaRepository(db),
            session: session,
            runStartupSideEffects: false,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.emitInitial(rows);
      await tester.pump();

      expect(repository.watchCalls, 1);
      expect(find.text('Broj predmeta: QA-ALPHA-001'), findsOneWidget);
      expect(find.text('Broj predmeta: QA-BETA-002'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final search = find.byType(TextField).first;
      Future<void> enterSearch(String value) async {
        await tester.enterText(search, value);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(repository.watchCalls, 1);
      }

      await enterSearch('Q');
      expect(find.text('Broj predmeta: QA-ALPHA-001'), findsOneWidget);
      await enterSearch('QA-');
      expect(find.text('Broj predmeta: QA-BETA-002'), findsOneWidget);
      await enterSearch('QA-ALPHA');
      expect(find.text('Broj predmeta: QA-ALPHA-001'), findsOneWidget);
      expect(find.text('Broj predmeta: QA-BETA-002'), findsNothing);
      await enterSearch('NO-MATCH');
      expect(find.text('Nema predmeta koji odgovaraju filteru.'), findsOneWidget);
      await enterSearch('NO-MATC');
      expect(find.text('Nema predmeta koji odgovaraju filteru.'), findsOneWidget);
      await enterSearch('QA-BETA');
      expect(find.text('Broj predmeta: QA-BETA-002'), findsOneWidget);
      expect(find.text('Broj predmeta: QA-ALPHA-001'), findsNothing);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(repository.watchCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Broj predmeta: QA-ALPHA-001'), findsOneWidget);
      expect(find.text('Broj predmeta: QA-BETA-002'), findsOneWidget);
      expect(tester.takeException(), null);
    },
  );
}

class _DelayedWatchPredmetiRepository extends PredmetiRepository {
  _DelayedWatchPredmetiRepository(super.db);

  int watchCalls = 0;
  final Completer<List<PredmetiData>> _initialRows =
      Completer<List<PredmetiData>>();

  void emitInitial(List<PredmetiData> rows) => _initialRows.complete(rows);

  @override
  Stream<List<PredmetiData>> watchSvi() {
    watchCalls++;
    final future = watchCalls == 1
        ? _initialRows.future
        : Completer<List<PredmetiData>>().future;
    return future.asStream();
  }
}

AppDatabase _createDatabase() => AppDatabase.forTesting(
  DatabaseConnection(
    NativeDatabase.memory(),
    closeStreamsSynchronously: true,
  ),
);
