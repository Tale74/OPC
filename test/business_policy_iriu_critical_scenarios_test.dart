import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart';

import 'test_bootstrap.dart';

void main() {
  group('Business policy / IRIU critical scenarios', () {
    test(
      'dom za stare prirodna smrt gradsko postojece grobnica requires limeni ulozak and lemovanje',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          mestoSmrti: 'DOM ZA STARE',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROBNICA',
        );

        final plan = const Blok2IriuLifecycleService().planForCurrentState(
          predmet: predmet,
          storedRows: const <IriuData>[],
          dismissedCategories: const <String>{},
        );

        _expectLimeniUlozakAndLemovanje(plan.categoriesToInsert);
      },
    );

    test(
      'non-cremation grobnica requires limeni ulozak and lemovanje',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          mestoSmrti: 'STAN',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROBNICA',
        );

        final plan = const Blok2IriuLifecycleService().planForCurrentState(
          predmet: predmet,
          storedRows: const <IriuData>[],
          dismissedCategories: const <String>{},
        );

        _expectLimeniUlozakAndLemovanje(plan.categoriesToInsert);
      },
    );

    for (final overrideCause in const <String>{
      'NASILNA',
      'ZARAZNA',
      'NEDEFINISANA',
    }) {
      test(
        '$overrideCause keeps limeni ulozak and lemovanje required for grob',
        () async {
          final db = createTestDatabase();
          addTearDown(db.close);

          final predmet = await _insertPredmet(
            db,
            mestoSmrti: 'STAN',
            uzrokSmrti: overrideCause,
            tipGroblja: 'GRADSKO',
            grobnoMesto: 'POSTOJECE',
            tipGrobnogMesta: 'GROB',
          );

          final plan = const Blok2IriuLifecycleService().planForCurrentState(
            predmet: predmet,
            storedRows: const <IriuData>[],
            dismissedCategories: const <String>{},
          );

          _expectLimeniUlozakAndLemovanje(plan.categoriesToInsert);
        },
      );
    }

    test(
      'cremation keeps limeni ulozak and lemovanje excluded for grobnica',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final predmet = await _insertPredmet(
          db,
          mestoSmrti: 'STAN',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROBNICA',
          vrstaCeremonije: 'KREMACIJA',
        );

        final plan = const Blok2IriuLifecycleService().planForCurrentState(
          predmet: predmet,
          storedRows: const <IriuData>[],
          dismissedCategories: const <String>{},
        );

        expect(plan.categoriesToInsert, isNot(contains(IriuK.limeniUlozak)));
        expect(plan.categoriesToInsert, isNot(contains(IriuK.lemovanje)));
      },
    );

    test(
      'grobnica to grob transition requires removal confirmation',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final previous = await _insertPredmet(
          db,
          mestoSmrti: 'DOM ZA STARE',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROBNICA',
        );
        final current = previous.copyWith(tipGrobnogMesta: 'GROB');
        final storedRows = [
          await _insertIriuRow(
            db,
            predmetId: previous.id,
            interniNaziv: IriuK.limeniUlozak,
            redosled: 0,
          ),
          await _insertIriuRow(
            db,
            predmetId: previous.id,
            interniNaziv: IriuK.lemovanje,
            redosled: 1,
          ),
        ];

        final plan = const Blok2IriuLifecycleService().planForConditionChange(
          previousPredmet: previous,
          currentPredmet: current,
          storedRows: storedRows,
          dismissedCategories: const <String>{},
        );

        expect(plan.categoriesToInsert, isEmpty);
        expect(plan.additionsRequiringConfirmation, isEmpty);
        _expectLimeniUlozakAndLemovanje(_conflictInternalNames(plan));
      },
    );

    test(
      'grob to grobnica transition requires add confirmation',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final previous = await _insertPredmet(
          db,
          mestoSmrti: 'DOM ZA STARE',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROB',
        );
        final current = previous.copyWith(tipGrobnogMesta: 'GROBNICA');

        final plan = const Blok2IriuLifecycleService().planForConditionChange(
          previousPredmet: previous,
          currentPredmet: current,
          storedRows: const <IriuData>[],
          dismissedCategories: const <String>{},
        );

        expect(plan.categoriesToInsert, isEmpty);
        expect(plan.conflicts, isEmpty);
        _expectLimeniUlozakAndLemovanje(plan.additionsRequiringConfirmation);
      },
    );

    test(
      'dismissed blok 2 categories are not silently re-added on transition',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);

        final previous = await _insertPredmet(
          db,
          mestoSmrti: 'DOM ZA STARE',
          uzrokSmrti: 'PRIRODNA',
          tipGroblja: 'GRADSKO',
          grobnoMesto: 'POSTOJECE',
          tipGrobnogMesta: 'GROB',
        );
        final current = previous.copyWith(tipGrobnogMesta: 'GROBNICA');

        final plan = const Blok2IriuLifecycleService().planForConditionChange(
          previousPredmet: previous,
          currentPredmet: current,
          storedRows: const <IriuData>[],
          dismissedCategories: const <String>{
            IriuK.limeniUlozak,
            IriuK.lemovanje,
          },
        );

        expect(plan.categoriesToInsert, isEmpty);
        expect(plan.additionsRequiringConfirmation, isEmpty);
      },
    );
  });
}

void _expectLimeniUlozakAndLemovanje(Iterable<String> categories) {
  expect(categories, contains(IriuK.limeniUlozak));
  expect(categories, contains(IriuK.lemovanje));
}

Set<String> _conflictInternalNames(Blok2IriuLifecyclePlan plan) {
  return plan.conflicts.map((conflict) {
    return conflict.row.storedRow.interniNaziv;
  }).toSet();
}

Future<PredmetiData> _insertPredmet(
  AppDatabase db, {
  required String mestoSmrti,
  required String uzrokSmrti,
  required String tipGroblja,
  required String grobnoMesto,
  required String tipGrobnogMesta,
  String vrstaCeremonije = 'SAHRANA',
}) async {
  final id = await db.into(db.predmeti).insert(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('IRIU-CRITICAL-001/2026'),
          datumKreiranja: const Value('2026-05-17T09:00:00.000'),
          mestoSmrti: Value(mestoSmrti),
          uzrokSmrti: Value(uzrokSmrti),
          tipGroblja: Value(tipGroblja),
          grobnoMesto: Value(grobnoMesto),
          tipGrobnogMesta: Value(tipGrobnogMesta),
          vrstaCeremonije: Value(vrstaCeremonije),
        ),
      );

  return (db.select(db.predmeti)..where((p) => p.id.equals(id))).getSingle();
}

Future<IriuData> _insertIriuRow(
  AppDatabase db, {
  required int predmetId,
  required String interniNaziv,
  required int redosled,
}) async {
  final id = await db.into(db.iriu).insert(
        IriuCompanion(
          predmetId: Value(predmetId),
          interniNaziv: Value(interniNaziv),
          nazivPrikaz: Value(IriuK.naziviPrikaz[interniNaziv] ?? interniNaziv),
          redosled: Value(redosled),
        ),
      );

  return (db.select(db.iriu)..where((i) => i.id.equals(id))).getSingle();
}
