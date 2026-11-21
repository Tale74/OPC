import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/database/predmet_iriu_order.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  test('changing the default freezes existing PREDMET and affects new cases',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await seedScenarioCatalogForTest(db);
    final modules = ScenarioModuleRepository(db);
    final previous = modules.readOsnovniPaketOrder(
      await modules.ensureModuleAndDefaults(),
    );
    expect(previous.length, greaterThan(1));
    final predmeti = PredmetiRepository(db);
    final rows = IriuRepository(db);
    final oldId = await db.into(db.predmeti).insert(PredmetiCompanion.insert());
    await predmeti.inicijalizujIriu(oldId);
    await deletePredmetIriuOrder(db, oldId); // Legacy storage state.
    final old = await rows.getIriu(oldId);

    await modules.saveOsnovniPaket(previous.reversed.toSet(),
      expectedOrder: previous,
    );
    expect((await rows.getIriu(oldId)).map((row) => row.id),
      old.map((row) => row.id),
    );
    final newId = await predmeti.kreirajPredmetSaOsnovnimPaketom(savetnikId: 1);
    expect((await rows.getIriu(newId)).map((row) => row.interniNaziv),
      old.map((row) => row.interniNaziv).toList().reversed,
    );
    await expectLater(
      modules.saveOsnovniPaket(previous.toSet(), expectedOrder: previous),
      throwsStateError,
    );
  });

  test('SCENARIO override only reorders its own occurrences', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db.into(db.predmeti).insert(
      PredmetiCompanion.insert(),
    );
    await savePredmetIriuOrder(
      db, predmetId, const PredmetIriuOrder(basic: ['SANDUK']),
    );
    for (final (id, name, origin) in [
      ('base', 'SANDUK', 'OSNOVNI_PAKET'),
      ('one', 'PROBA_1', 'SCENARIO_PAKET'),
      ('two', 'PROBA_2', 'SCENARIO_PAKET'),
      ('manual', 'PROBA_3', 'RUCNA_STAVKA'),
    ]) {
      final rowId = await db.into(db.iriu).insert(IriuCompanion.insert(
        predmetId: predmetId,
        interniNaziv: name,
        portableOccurrenceId: Value(id),
        iznos: const Value(125),
      ));
      await db.into(db.iriuProvenance).insert(IriuProvenanceCompanion.insert(
        iriuId: Value(rowId),
        origin: origin,
        createdAt: '2026-11-20T10:00:00Z',
      ));
    }
    final repo = IriuRepository(db);
    await repo.saveScenarioOrder(
      predmetId, expected: ['one', 'two'], ordered: ['two', 'one'],
    );
    final rows = await repo.getIriu(predmetId);
    expect(rows.map((row) => row.portableOccurrenceId),
      ['base', 'two', 'one', 'manual'],
    );
    expect(rows.map((row) => row.iznos), everyElement(125));
    expect((await readPredmetIriuOrder(db, predmetId))!.scenario,
      ['two', 'one'],
    );
    await expectLater(
      repo.saveScenarioOrder(predmetId,
        expected: ['two', 'one'], ordered: ['two', 'manual'],
      ),
      throwsStateError,
    );

    final added = await db.into(db.iriu).insert(IriuCompanion.insert(
      predmetId: predmetId,
      interniNaziv: 'PROBA_4',
      portableOccurrenceId: const Value('later'),
    ));
    await db.into(db.iriuProvenance).insert(IriuProvenanceCompanion.insert(
      iriuId: Value(added),
      origin: 'SCENARIO_PAKET',
      createdAt: '2026-11-20T10:01:00Z',
    ));
    expect((await repo.getIriu(predmetId)).map((row) => row.portableOccurrenceId),
      ['base', 'two', 'one', 'later', 'manual'],
    );

    await repo.obrisiStavku(
      rows.singleWhere((row) => row.portableOccurrenceId == 'two').id,
    );
    expect((await readPredmetIriuOrder(db, predmetId))!.scenario, ['one']);
    expect((await repo.getIriu(predmetId)).map((row) => row.portableOccurrenceId),
      ['base', 'one', 'later', 'manual'],
    );
  });
}
