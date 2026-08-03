import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('SCENARIO module seeds defaults as editable data', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );

    await repository.ensureModuleAndDefaults();
    final definitions = await repository.getDefinitions();

    expect(definitions, hasLength(11));
    final module = await repository.ensureModule();
    expect(repository.readOsnovniPaket(module), hasLength(9));
    expect(
      repository.readOsnovniPaket(module),
      containsAll([
        'SANDUK',
        'OBELEZJE',
        'POKROV_GARNITURA',
        'PESKIR_ZA_KRST',
        'POSMRTNE_PARTE',
        'CRNINA',
        'AGENCIJSKE_USLUGE',
        'CVECE',
        'CITULJA_POLITIKA',
      ]),
    );
    expect(
      definitions.singleWhere((item) => item.id == 'BIOHAZARD').naziv,
      'ZARAZNA SMRT VAN BOLNICE',
    );
    final cituljaConfig = await (db.select(
      db.iriuKatalogConfig,
    )..where((row) => row.interniNaziv.equals('CITULJA_POLITIKA'))).getSingle();
    final cituljaArtikli = await (db.select(
      db.katalogArtikli,
    )..where(
          (row) => row.interniNazivKategorije.equals('CITULJA_POLITIKA'),
        ))
        .get();
    expect(cituljaConfig.nazivPrikaz, 'Čitulja Politika');
    expect(cituljaArtikli.length, greaterThan(1));
    expect(
      definitions.where((item) => item.jePodrazumevani).map((item) => item.id),
      containsAll([
        'STAN',
        'DOM_ZA_STARE',
        'ULICA_JAVNO_MESTO',
        'BOLNICA',
        'LIMENI_ULOZAK',
        'LEMOVANJE',
        'LOKALNO_GROBLJE',
        'OPELO',
        'BIOHAZARD',
        'SAHRANA_VAN_SRBIJE',
        'DOCEK_POSMRTNIH_OSTATAKA',
      ]),
    );
  });

  test(
    'legacy seven definitions migrate to eleven independently editable scenarios',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );

      await repository.ensureModule();
      await _seedLegacySevenDefinitions(repository);
      final before = await repository.getDefinitions();
      expect(before, hasLength(7));
      expect(
        repository.readOsnovniPaket(await repository.ensureModule()),
        isEmpty,
      );

      await repository.ensureModuleAndDefaults();
      final migrated = await repository.getDefinitions();
      final migratedIds = migrated.map((item) => item.id).toSet();
      expect(migrated, hasLength(11));
      expect(
        migratedIds,
        containsAll(<String>{
          'STAN',
          'DOM_ZA_STARE',
          'ULICA_JAVNO_MESTO',
          'BOLNICA',
          'LIMENI_ULOZAK',
          'LEMOVANJE',
          'LOKALNO_GROBLJE',
          'OPELO',
          'BIOHAZARD',
          'SAHRANA_VAN_SRBIJE',
          'DOCEK_POSMRTNIH_OSTATAKA',
        }),
      );
      expect(migratedIds.intersection(<String>{
        'MESTO_SMRTI_BLOK',
        'MESTO_SMRTI_BOLNICA',
        'OPREMA_PREMA_USLOVU',
      }), isEmpty);
      expect(
        repository.readOsnovniPaket(await repository.ensureModule()),
        hasLength(9),
      );

      final stanRecord = migrated.singleWhere((item) => item.id == 'STAN');
      final domBefore = repository.definitionFromRecord(
        migrated.singleWhere((item) => item.id == 'DOM_ZA_STARE'),
      );
      final stanBefore = repository.definitionFromRecord(stanRecord);
      expect(
        stanBefore.consequences.map(
          (item) => item.katalogCategoryInternalName,
        ),
        contains('IZNOSENJE'),
      );
      expect(
        domBefore.consequences.map(
          (item) => item.katalogCategoryInternalName,
        ),
        contains('IZNOSENJE'),
      );

      await repository.saveDefinition(
        id: stanRecord.id,
        version: stanRecord.version,
        naziv: stanRecord.naziv,
        condition: stanBefore.condition,
        consequences: const <ScenarioConsequence>[
          ScenarioConsequence(
            katalogCategoryInternalName: 'SANDUK',
            action: ScenarioConsequenceAction.required,
          ),
        ],
        jePodrazumevani: stanRecord.jePodrazumevani,
        status: stanRecord.status,
      );
      await repository.ensureModuleAndDefaults();

      final afterEdit = await repository.getDefinitions();
      final stanAfter = repository.definitionFromRecord(
        afterEdit.singleWhere((item) => item.id == 'STAN'),
      );
      final domAfter = repository.definitionFromRecord(
        afterEdit.singleWhere((item) => item.id == 'DOM_ZA_STARE'),
      );
      expect(
        stanAfter.consequences.map(
          (item) => item.katalogCategoryInternalName,
        ),
        <String>['SANDUK'],
      );
      expect(
        domAfter.consequences.map(
          (item) => item.katalogCategoryInternalName,
        ),
        contains('IZNOSENJE'),
      );
      expect(
        domAfter.condition.criterion?.values,
        containsAll(<String>['DOM ZA STARE', 'PRIVATNA BOLNICA', 'DRUGO']),
      );
      expect(
        repository
            .definitionFromRecord(
              afterEdit.singleWhere((item) => item.id == 'LIMENI_ULOZAK'),
            )
            .consequences
            .single
            .katalogCategoryInternalName,
        'LIMENI_ULOZAK',
      );
      expect(
        repository
            .definitionFromRecord(
              afterEdit.singleWhere((item) => item.id == 'LEMOVANJE'),
            )
            .consequences
            .single
            .katalogCategoryInternalName,
        'LEMOVANJE',
      );
    },
  );

  test('SCENARIO module persists the base package and a user rule', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(db);

    final module = await repository.ensureModule();
    await repository.saveOsnovniPaket({'SANDUK', 'CITULJE'});
    await repository.saveDefinition(
      id: 'BOLNICA_GRADSKO',
      version: 1,
      naziv: 'Bolnica i gradsko groblje',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: ['BOLNICA'],
        ),
      ),
      consequences: const [
        ScenarioConsequence(
          katalogCategoryInternalName: 'SANDUK',
          action: ScenarioConsequenceAction.recommended,
        ),
      ],
      jePodrazumevani: true,
    );

    final savedModule =
        await (db.select(
              db.scenarioModules,
            )..where((row) => row.id.equals(ScenarioModuleRepository.moduleId)))
            .getSingle();
    expect(repository.readOsnovniPaket(savedModule), {'CITULJE', 'SANDUK'});

    final saved = await (db.select(
      db.scenarioDefinitions,
    )..where((row) => row.id.equals('BOLNICA_GRADSKO'))).getSingle();
    final definition = repository.definitionFromRecord(saved);
    expect(definition.name, 'Bolnica i gradsko groblje');
    expect(
      definition.consequences.single.katalogCategoryInternalName,
      'SANDUK',
    );
    expect(module.id, ScenarioModuleRepository.moduleId);
  });
}

Future<void> _seedLegacySevenDefinitions(
  ScenarioModuleRepository repository,
) async {
  const mestoBlokCondition = ScenarioCondition.criterion(
    ScenarioCriterion(
      field: ScenarioCriterionField.mestoSmrti,
      operator: ScenarioCriterionOperator.inSet,
      values: <String>[
        'STAN',
        'DOM ZA STARE',
        'PRIVATNA BOLNICA',
        'ULICA / JAVNO MESTO',
        'DRUGO',
      ],
    ),
  );
  const equipmentCondition = ScenarioCondition.all(<ScenarioCondition>[
    ScenarioCondition.criterion(
      ScenarioCriterion(
        field: ScenarioCriterionField.vrstaCeremonije,
        operator: ScenarioCriterionOperator.notInSet,
        values: <String>['KREMACIJA', 'KREMACIJA_EKSPRES'],
      ),
    ),
    ScenarioCondition.criterion(
      ScenarioCriterion(
        field: ScenarioCriterionField.uzrokSmrti,
        operator: ScenarioCriterionOperator.inSet,
        values: <String>['NASILNA', 'ZARAZNA', 'NEDEFINISANA'],
      ),
    ),
  ]);
  final seeds = <({
    String id,
    ScenarioCondition condition,
    List<ScenarioConsequence> consequences,
  })>[
    (
      id: 'MESTO_SMRTI_BLOK',
      condition: mestoBlokCondition,
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'IZNOSENJE',
          action: ScenarioConsequenceAction.required,
        ),
        ScenarioConsequence(
          katalogCategoryInternalName: 'PREVOZ_DO_GROBLJA',
          action: ScenarioConsequenceAction.required,
        ),
      ],
    ),
    (
      id: 'MESTO_SMRTI_BOLNICA',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.mestoSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: <String>['BOLNICA'],
        ),
      ),
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'PREVOZ_DO_GROBLJA',
          action: ScenarioConsequenceAction.required,
        ),
      ],
    ),
    (
      id: 'OPREMA_PREMA_USLOVU',
      condition: equipmentCondition,
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'LIMENI_ULOZAK',
          action: ScenarioConsequenceAction.recommended,
        ),
        ScenarioConsequence(
          katalogCategoryInternalName: 'LEMOVANJE',
          action: ScenarioConsequenceAction.recommended,
        ),
      ],
    ),
    (
      id: 'LOKALNO_GROBLJE',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.tipGroblja,
          operator: ScenarioCriterionOperator.equals,
          values: <String>['LOKALNO'],
        ),
      ),
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'PREVOZ_SPROVODA',
          action: ScenarioConsequenceAction.recommended,
        ),
      ],
    ),
    (
      id: 'SAHRANA_VAN_SRBIJE',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.sahranaVanSrbije,
          operator: ScenarioCriterionOperator.isTrue,
        ),
      ),
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'MEDJUNARODNI_PREVOZ',
          action: ScenarioConsequenceAction.required,
        ),
      ],
    ),
    (
      id: 'DOCEK_POSMRTNIH_OSTATAKA',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.docekPosmrtnihOstataka,
          operator: ScenarioCriterionOperator.isTrue,
        ),
      ),
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'CARGO_TROSKOVI',
          action: ScenarioConsequenceAction.required,
        ),
      ],
    ),
    (
      id: 'OPELO',
      condition: const ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.opelo,
          operator: ScenarioCriterionOperator.equals,
          values: <String>['DA'],
        ),
      ),
      consequences: const <ScenarioConsequence>[
        ScenarioConsequence(
          katalogCategoryInternalName: 'KOMPLET_ZA_OPELO',
          action: ScenarioConsequenceAction.recommended,
        ),
      ],
    ),
  ];
  for (final seed in seeds) {
    await repository.saveDefinition(
      id: seed.id,
      version: 1,
      naziv: seed.id,
      condition: seed.condition,
      consequences: seed.consequences,
      jePodrazumevani: true,
      status: 'PRIMENJEN',
    );
  }
}
