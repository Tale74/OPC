import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/iriu_display_name_resolver.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/segments/iriu_row_tile.dart';

import 'test_bootstrap.dart';

void main() {
  test('KORISNIK_* resolves through KATALOG before stored technical text', () {
    final resolution = resolveIriuDisplayName(
      internalName: 'KORISNIK_1775943907013',
      catalogDisplayNames: const {'KORISNIK_1775943907013': 'Slika'},
      storedDisplayName: 'KORISNIK_1775943907013',
    );

    expect(resolution.isResolved, isTrue);
    expect(resolution.displayName, 'Slika');
    expect(resolution.userFacingText, 'Slika');
  });

  test('unresolved KORISNIK_* is an integrity error, not a business item', () {
    final resolution = resolveIriuDisplayName(
      internalName: 'KORISNIK_MISSING',
      storedDisplayName: 'KORISNIK_MISSING',
    );

    expect(resolution.isResolved, isFalse);
    expect(resolution.displayName, isNull);
    expect(resolution.userFacingText, unresolvedIriuCatalogItemLabel);
  });

  test(
    'scenario repository stores the current KATALOG name for Slika',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await db
          .into(db.iriuKatalogConfig)
          .insert(
            IriuKatalogConfigCompanion.insert(
              interniNaziv: 'KORISNIK_1775943907013',
              nazivPrikaz: 'Slika',
              tip: const Value('KATALOSKA'),
              jeKorisnicka: const Value(true),
            ),
          );
      final predmetRepository = PredmetiRepository(db);
      final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
      await predmetRepository.azurirajPredmet(
        predmetId,
        const PredmetiCompanion(mestoSmrti: Value('STAN')),
      );
      final result = await IriuRepository(db).syncScenarioRows(
        predmetId: predmetId,
        predmet: await predmetRepository.getPredmet(predmetId),
        scenarios: [
          const ScenarioDefinition(
            id: 'SLIKA_SCENARIO',
            name: 'Slika scenario',
            condition: ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.mestoSmrti,
                operator: ScenarioCriterionOperator.equals,
                values: ['STAN'],
              ),
            ),
            consequences: [
              ScenarioConsequence(
                katalogCategoryInternalName: 'KORISNIK_1775943907013',
                action: ScenarioConsequenceAction.required,
              ),
            ],
          ),
        ],
        osnovniPaket: const {},
      );

      expect(result.addedCategories, contains('KORISNIK_1775943907013'));
      final row = (await IriuRepository(db).getIriu(predmetId)).single;
      expect(row.nazivPrikaz, 'Slika');
    },
  );

  testWidgets('IRIU row displays Slika from the KATALOG map', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetRepository = PredmetiRepository(db);
    final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
    await db
        .into(db.iriu)
        .insert(
          IriuCompanion.insert(
            predmetId: predmetId,
            interniNaziv: 'KORISNIK_1775943907013',
            nazivPrikaz: const Value('KORISNIK_1775943907013'),
          ),
        );
    final row = (await IriuRepository(db).getIriu(predmetId)).single;

    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: IriuRowTile(
            stavka: row,
            iriuRepo: IriuRepository(db),
            podesavanjaRepo: PodesavanjaRepository(db),
            imaArtikalaStream: Stream<bool>.value(false),
            enabled: false,
            truthRow: null,
            stockConsequence: null,
            catalogDisplayNames: const {'KORISNIK_1775943907013': 'Slika'},
            isNarrowAndroid: false,
            preporucenoLabel: 'PREPORUČENO',
          ),
        ),
      ),
    );

    expect(find.text('Slika'), findsOneWidget);
    expect(find.text('Dodatna stavka'), findsNothing);
  });

  test('BIOHAZARD display and warning remain unchanged', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetRepository = PredmetiRepository(db);
    final predmetId = await predmetRepository.kreirajPredmet(savetnikId: 1);
    await predmetRepository.azurirajPredmet(
      predmetId,
      const PredmetiCompanion(
        mestoSmrti: Value('STAN'),
        uzrokSmrti: Value('ZARAZNA'),
      ),
    );
    await IriuRepository(db).syncScenarioRows(
      predmetId: predmetId,
      predmet: await predmetRepository.getPredmet(predmetId),
      scenarios: [
        const ScenarioDefinition(
          id: 'BIOHAZARD',
          name: 'ZARAZNA SMRT VAN BOLNICE',
          condition: ScenarioCondition.criterion(
            ScenarioCriterion(
              field: ScenarioCriterionField.uzrokSmrti,
              operator: ScenarioCriterionOperator.equals,
              values: ['ZARAZNA'],
            ),
          ),
          consequences: [
            ScenarioConsequence(
              katalogCategoryInternalName: 'SPREMANJE_POKOJNIKA',
              action: ScenarioConsequenceAction.required,
              warning: 'Postupati prema merama zaštite za zaraznu bolest.',
              reason: 'Uzrok smrti je zarazan, a mesto smrti nije bolnica.',
            ),
          ],
        ),
      ],
      osnovniPaket: const {},
    );

    final row = (await IriuRepository(db).getIriu(predmetId)).single;
    expect(row.nazivPrikaz, 'Spremanje preminulog lica');
    expect(
      row.poslovnoUpozorenje,
      'Postupati prema merama zaštite za zaraznu bolest.',
    );
  });
}
