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

    expect(
      definitions.where((item) => item.id.startsWith('MAP_')),
      hasLength(1008),
    );
    final module = await repository.ensureModule();
    expect(repository.readOsnovniPaket(module), hasLength(11));
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
    final cituljaArtikli =
        await (db.select(db.katalogArtikli)..where(
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
        'PRIVATNA_BOLNICA',
        'DRUGO',
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
    'collapsed DOM legacy alias definition expands into independent place branches',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = ScenarioModuleRepository(
        db,
        loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
      );

      await repository.ensureModuleAndDefaults();
      final initial = await repository.getDefinitions();
      final dom = initial.singleWhere((item) => item.id == 'DOM_ZA_STARE');
      final domDefinition = repository.definitionFromRecord(dom);
      await repository.saveDefinition(
        id: dom.id,
        version: dom.version,
        naziv: dom.naziv,
        condition: const ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.inSet,
            values: ['DOM ZA STARE', 'PRIVATNA BOLNICA', 'DRUGO'],
          ),
        ),
        consequences: domDefinition.consequences,
        jePodrazumevani: dom.jePodrazumevani,
        status: dom.status,
        allowBaseOverlap: true,
      );
      for (final id in const ['PRIVATNA_BOLNICA', 'DRUGO']) {
        final record = initial.singleWhere((item) => item.id == id);
        await repository.deleteDefinition(record.id, record.version);
      }

      await repository.ensureModuleAndDefaults();
      final migrated = await repository.getDefinitions();
      expect(migrated, hasLength(1021));
      expect(
        repository
            .definitionFromRecord(
              migrated.singleWhere((item) => item.id == 'DOM_ZA_STARE'),
            )
            .condition
            .criterion
            ?.values,
        ['DOM ZA STARE'],
      );
      expect(
        repository
            .definitionFromRecord(
              migrated.singleWhere((item) => item.id == 'PRIVATNA_BOLNICA'),
            )
            .condition
            .criterion
            ?.values,
        ['PRIVATNA BOLNICA'],
      );
      expect(
        repository
            .definitionFromRecord(
              migrated.singleWhere((item) => item.id == 'DRUGO'),
            )
            .condition
            .criterion
            ?.values,
        ['DRUGO'],
      );
    },
  );

  test(
    'legacy seven definitions migrate to thirteen independently editable scenarios',
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
      expect(migrated, hasLength(1021));
      expect(
        migratedIds,
        containsAll(<String>{
          'STAN',
          'DOM_ZA_STARE',
          'PRIVATNA_BOLNICA',
          'DRUGO',
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
      expect(
        migratedIds.intersection(<String>{
          'MESTO_SMRTI_BLOK',
          'MESTO_SMRTI_BOLNICA',
          'OPREMA_PREMA_USLOVU',
        }),
        isEmpty,
      );
      expect(
        repository.readOsnovniPaket(await repository.ensureModule()),
        hasLength(11),
      );

      final stanRecord = migrated.singleWhere((item) => item.id == 'STAN');
      final domBefore = repository.definitionFromRecord(
        migrated.singleWhere((item) => item.id == 'DOM_ZA_STARE'),
      );
      final stanBefore = repository.definitionFromRecord(stanRecord);
      expect(
        stanBefore.consequences.map((item) => item.katalogCategoryInternalName),
        contains('IZNOSENJE'),
      );
      expect(
        domBefore.consequences.map((item) => item.katalogCategoryInternalName),
        contains('IZNOSENJE'),
      );

      await repository.saveDefinition(
        id: stanRecord.id,
        version: stanRecord.version,
        naziv: stanRecord.naziv,
        condition: stanBefore.condition,
        consequences: const <ScenarioConsequence>[
          ScenarioConsequence(
            katalogCategoryInternalName: 'IZNOSENJE',
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
        stanAfter.consequences.map((item) => item.katalogCategoryInternalName),
        <String>['IZNOSENJE'],
      );
      expect(
        domAfter.consequences.map((item) => item.katalogCategoryInternalName),
        contains('IZNOSENJE'),
      );
      expect(domAfter.condition.criterion?.values, ['DOM ZA STARE']);
      for (final id in const ['PRIVATNA_BOLNICA', 'DRUGO']) {
        final split = repository.definitionFromRecord(
          afterEdit.singleWhere((item) => item.id == id),
        );
        expect(split.condition.criterion?.values, [
          id == 'DRUGO' ? 'DRUGO' : 'PRIVATNA BOLNICA',
        ]);
        expect(
          split.consequences.map((item) => item.katalogCategoryInternalName),
          contains('IZNOSENJE'),
        );
      }
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
    await repository.saveOsnovniPaket({'SANDUK', 'CITULJA_POLITIKA'});
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
          katalogCategoryInternalName: 'IZNOSENJE',
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
    expect(repository.readOsnovniPaket(savedModule), {
      'CITULJA_POLITIKA',
      'SANDUK',
    });

    final saved = await (db.select(
      db.scenarioDefinitions,
    )..where((row) => row.id.equals('BOLNICA_GRADSKO'))).getSingle();
    final definition = repository.definitionFromRecord(saved);
    expect(definition.name, 'Bolnica i gradsko groblje');
    expect(
      definition.consequences.single.katalogCategoryInternalName,
      'IZNOSENJE',
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
  final seeds =
      <
        ({
          String id,
          ScenarioCondition condition,
          List<ScenarioConsequence> consequences,
        })
      >[
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
