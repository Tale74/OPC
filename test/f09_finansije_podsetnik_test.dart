import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/financial_truth_service.dart';

import 'test_bootstrap.dart';

void main() {
  group('F-09 FINANSIJE obligations', () {
    test('shared ZA NAPLATU calculation preserves finance inputs', () {
      const service = FinancialTruthService();

      expect(
        service.calculateZaNaplatu(
          robaIUsluge: 200,
          refundacijaPio: 20,
          avans: 50,
          troskoviJkp: 30,
          jkpPlacaSamostalno: false,
          popust: 10,
        ),
        150,
      );
      expect(
        service.calculateZaNaplatu(
          robaIUsluge: 200,
          refundacijaPio: 20,
          avans: 50,
          troskoviJkp: 30,
          jkpPlacaSamostalno: true,
          popust: 10,
        ),
        120,
      );
    });

    test('PLATITI RAČUN uses only positive JKP cost and payer flag', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final payOnlyId = await _insertPredmet(
        db,
        broj: 'F09-PAY-ONLY',
        troskoviJkp: 100,
        avans: 101,
        jkpPlacaSamostalno: false,
      );
      final zeroId = await _insertPredmet(
        db,
        broj: 'F09-ZERO-JKP',
        troskoviJkp: 0,
        jkpPlacaSamostalno: false,
      );
      final selfPaidId = await _insertPredmet(
        db,
        broj: 'F09-SELF-PAID',
        troskoviJkp: 100,
        jkpPlacaSamostalno: true,
      );
      final negativeId = await _insertPredmet(
        db,
        broj: 'F09-NEGATIVE-JKP',
        troskoviJkp: -1,
        jkpPlacaSamostalno: false,
      );

      final payOnly = await _current(db, payOnlyId);
      expect(_ids(payOnly), contains(platiJkpRacunRuleId));
      expect(_ids(payOnly), isNot(contains(naplatiObavezeRuleId)));
      expect(
        payOnly
            .singleWhere(
              (item) => item.rule.stableRuleId == platiJkpRacunRuleId,
            )
            .rule
            .parentRuleId,
        finansijeParentRuleId,
      );
      expect(_ids(await _current(db, zeroId)), isEmpty);
      expect(_ids(await _current(db, selfPaidId)), isEmpty);
      expect(_ids(await _current(db, negativeId)), isEmpty);
    });

    test('NAPLATITI OBAVEZE uses strict positive ZA NAPLATU', () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final positiveId = await _insertPredmet(
        db,
        broj: 'F09-RECEIVABLE-POSITIVE',
        avans: 99,
      );
      final zeroId = await _insertPredmet(
        db,
        broj: 'F09-RECEIVABLE-ZERO',
        avans: 100,
      );
      final negativeId = await _insertPredmet(
        db,
        broj: 'F09-RECEIVABLE-NEGATIVE',
        avans: 101,
      );
      for (final id in [positiveId, zeroId, negativeId]) {
        await _insertFinancialRow(db, predmetId: id, amount: 100);
      }

      final positive = await _current(db, positiveId);
      expect(_ids(positive), [finansijeParentRuleId, naplatiObavezeRuleId]);
      expect(_ids(await _current(db, zeroId)), isEmpty);
      expect(_ids(await _current(db, negativeId)), isEmpty);
      expect(
        positive
            .singleWhere(
              (item) => item.rule.stableRuleId == naplatiObavezeRuleId,
            )
            .rule
            .parentRuleId,
        finansijeParentRuleId,
      );
    });

    test(
      'sibling completion derives the parent and reopens generically',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final id = await _insertPredmet(
          db,
          broj: 'F09-GROUP-COMPLETION',
          troskoviJkp: 40,
          jkpPlacaSamostalno: false,
        );
        await _insertFinancialRow(db, predmetId: id, amount: 60);
        final repository = PodsetnikObligationRepository(db);
        var current = await repository.reconcileForPredmet(id);

        expect(current.map((item) => item.rule.stableRuleId), [
          finansijeParentRuleId,
          platiJkpRacunRuleId,
          naplatiObavezeRuleId,
        ]);
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == platiJkpRacunRuleId,
              )
              .completed,
          isFalse,
        );
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == naplatiObavezeRuleId,
              )
              .completed,
          isFalse,
        );
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == finansijeParentRuleId,
              )
              .completed,
          isFalse,
        );
        expect(podsetnikReviewBarText(current, 0), 'FINANSIJE');

        await repository.setAtomicCompletion(
          predmetId: id,
          stableRuleId: platiJkpRacunRuleId,
          completed: true,
        );
        current = await repository.currentForPredmet(id);
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == finansijeParentRuleId,
              )
              .completed,
          isFalse,
        );
        expect(podsetnikReviewBarText(current, 0), 'FINANSIJE');

        await repository.setParentCompletion(
          predmetId: id,
          parentRuleId: finansijeParentRuleId,
          completed: true,
        );
        current = await repository.currentForPredmet(id);
        expect(
          current
              .where((item) => item.rule.parentRuleId == finansijeParentRuleId)
              .every((item) => item.completed),
          isTrue,
        );
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == finansijeParentRuleId,
              )
              .completed,
          isTrue,
        );
        expect(podsetnikReviewBarText(current, 0), 'OBAVEZE ISPUNJENE');

        await repository.setAtomicCompletion(
          predmetId: id,
          stableRuleId: naplatiObavezeRuleId,
          completed: false,
        );
        current = await repository.currentForPredmet(id);
        expect(
          current
              .singleWhere(
                (item) => item.rule.stableRuleId == finansijeParentRuleId,
              )
              .completed,
          isFalse,
        );
        expect(podsetnikReviewBarText(current, 0), 'FINANSIJE');
      },
    );

    test('source-fact stream refreshes finance membership live', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await _insertPredmet(db, broj: 'F09-LIVE-SOURCE');
      final repository = PodsetnikObligationRepository(db);
      final events = StreamIterator(repository.watchCurrentForPredmet(id));
      addTearDown(events.cancel);

      expect(await events.moveNext(), isTrue);
      expect(podsetnikReviewBarText(events.current, 0), 'OBAVEZE ISPUNJENE');

      await _insertFinancialRow(db, predmetId: id, amount: 25);
      expect(await events.moveNext(), isTrue);
      expect(podsetnikReviewBarText(events.current, 0), 'FINANSIJE');

      await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
        const PredmetiCompanion(avans: Value(25)),
      );
      expect(await events.moveNext(), isTrue);
      expect(podsetnikReviewBarText(events.current, 0), 'OBAVEZE ISPUNJENE');
    });

    test(
      'single-PREDMET JSON preserves derived F-09 child completion',
      () async {
        final source = createTestDatabase();
        final target = createTestDatabase();
        addTearDown(source.close);
        addTearDown(target.close);
        final sourceId = await _insertPredmet(
          source,
          broj: 'F09-SINGLE-TRANSFER',
          troskoviJkp: 50,
          jkpPlacaSamostalno: false,
        );
        final sourceRepository = PodsetnikObligationRepository(source);
        await sourceRepository.reconcileForPredmet(sourceId);
        await sourceRepository.setParentCompletion(
          predmetId: sourceId,
          parentRuleId: finansijeParentRuleId,
          completed: true,
        );
        final json =
            jsonDecode(
                  await serializePredmetJsonForTest(
                    db: source,
                    predmetId: sourceId,
                  ),
                )
                as Map<String, dynamic>;
        final actor = await target
            .into(target.korisnici)
            .insert(
              KorisniciCompanion.insert(
                imePrezime: 'F09 Importer',
                uloga: 'ADMINISTRATOR',
                pinHash: 'f09-transfer-test-hash',
                datumKreiranja: '2026-09-19',
              ),
            );

        await importPredmetJsonMapForTest(
          db: target,
          json: json,
          localActorKorisnikId: actor,
        );
        final importedId =
            (await target.select(target.predmeti).get()).single.id;
        final imported = await PodsetnikObligationRepository(
          target,
        ).currentForPredmet(importedId);
        expect(
          imported
              .where((item) => item.rule.parentRuleId == finansijeParentRuleId)
              .every((item) => item.completed),
          isTrue,
        );
        expect(
          imported
              .singleWhere(
                (item) => item.rule.stableRuleId == finansijeParentRuleId,
              )
              .completed,
          isTrue,
        );
      },
    );

    test('full Backup JSON preserves derived F-09 child completion', () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final sourceId = await _insertPredmet(
        source,
        broj: 'F09-FULL-BACKUP',
        troskoviJkp: 75,
        jkpPlacaSamostalno: false,
      );
      final sourceRepository = PodsetnikObligationRepository(source);
      await sourceRepository.reconcileForPredmet(sourceId);
      await sourceRepository.setParentCompletion(
        predmetId: sourceId,
        parentRuleId: finansijeParentRuleId,
        completed: true,
      );
      final json =
          jsonDecode(await serializeBackupJsonForTest(db: source))
              as Map<String, dynamic>;

      await importBackupJsonMapForTest(db: target, json: json);
      final importedId = (await target.select(target.predmeti).get()).single.id;
      final imported = await PodsetnikObligationRepository(
        target,
      ).currentForPredmet(importedId);
      expect(
        imported
            .where((item) => item.rule.parentRuleId == finansijeParentRuleId)
            .every((item) => item.completed),
        isTrue,
      );
      expect(
        imported
            .singleWhere(
              (item) => item.rule.stableRuleId == finansijeParentRuleId,
            )
            .completed,
        isTrue,
      );
    });
  });
}

Future<int> _insertPredmet(
  AppDatabase db, {
  required String broj,
  double troskoviJkp = 0,
  bool jkpPlacaSamostalno = false,
  double avans = 0,
}) {
  return db
      .into(db.predmeti)
      .insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(broj),
          datumKreiranja: const Value('2026-09-19'),
          troskoviJkp: Value(troskoviJkp),
          jkpPlacaSamostalno: Value(jkpPlacaSamostalno),
          avans: Value(avans),
        ),
      );
}

Future<void> _insertFinancialRow(
  AppDatabase db, {
  required int predmetId,
  required double amount,
}) async {
  await db
      .into(db.iriu)
      .insert(
        IriuCompanion(
          predmetId: Value(predmetId),
          portableOccurrenceId: Value('f09-financial-$predmetId'),
          interniNaziv: const Value('F09_TEST_FINANCIAL_ROW'),
          nazivPrikaz: const Value('F09 test financial row'),
          iznos: Value(amount),
        ),
      );
}

Future<List<PodsetnikObligation>> _current(AppDatabase db, int predmetId) =>
    PodsetnikObligationRepository(db).currentForPredmet(predmetId);

List<String> _ids(List<PodsetnikObligation> obligations) =>
    obligations.map((item) => item.rule.stableRuleId).toList(growable: false);
