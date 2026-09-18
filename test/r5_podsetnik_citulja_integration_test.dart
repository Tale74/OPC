import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation_transfer.dart';
import 'package:opc_v4/features/podsetnik/presentation/podsetnik_module_screen.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';

import 'test_bootstrap.dart';

void main() {
  test('ČITULJA derives grouped parent and occurrence children', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await _insertPredmet(db, 'R5-DERIVE');
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-politika-a',
      type: IriuK.cituljaP,
      order: 1,
    );
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-politika-b',
      type: IriuK.cituljaP,
      order: 2,
    );
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-novosti-a',
      type: IriuK.cituljaNo,
      order: 3,
    );

    final obligations = await PodsetnikObligationRepository(
      db,
    ).reconcileForPredmet(predmetId);
    final parent = obligations.singleWhere(
      (item) => item.rule.stableRuleId == cituljeParentRuleId,
    );
    final children = obligations
        .where((item) => item.rule.parentRuleId == cituljeParentRuleId)
        .toList(growable: false);

    expect(parent.isGroup, isTrue);
    expect(parent.completed, isFalse);
    expect(children, hasLength(3));
    expect(
      children.map((item) => item.rule.portableOccurrenceId),
      containsAll(['r5-politika-a', 'r5-politika-b', 'r5-novosti-a']),
    );
    expect(children.map((item) => item.rule.stableRuleId).toSet(), hasLength(3));
    expect(children.map((item) => item.rule.displayLabel), containsAll([
      'ČITULJA POLITIKA 1',
      'ČITULJA POLITIKA 2',
      'ČITULJA NOVOSTI',
    ]));
    expect(
      children.any((item) => item.rule.displayLabel!.contains('r5-')),
      isFalse,
    );
  });

  test('no current ČITULJA occurrence produces no parent obligation', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await _insertPredmet(db, 'R5-NONE');
    final obligations = await PodsetnikObligationRepository(
      db,
    ).currentForPredmet(predmetId);
    expect(
      obligations.any((item) => item.rule.stableRuleId == cituljeParentRuleId),
      isFalse,
    );
  });

  test('ČITULJA parent uses canonical grouped completion semantics', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await _insertPredmet(db, 'R5-COMPLETION');
    await (db.update(db.predmeti)..where((row) => row.id.equals(predmetId))).write(
      const PredmetiCompanion(
        opelo: drift.Value('DA'),
        obavestitiSvestenika: drift.Value('DA'),
      ),
    );
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-child-a',
      type: IriuK.cituljaP,
      order: 1,
    );
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-child-b',
      type: IriuK.cituljaNo,
      order: 2,
    );
    final repository = PodsetnikObligationRepository(db);
    final initial = await repository.reconcileForPredmet(predmetId);
    final childA = initial.firstWhere(
      (item) => item.rule.portableOccurrenceId == 'r5-child-a',
    );
    final childB = initial.firstWhere(
      (item) => item.rule.portableOccurrenceId == 'r5-child-b',
    );

    // A stale R5 independent-parent value must never become authoritative.
    await (db.update(db.podsetnikObaveze)..where(
          (row) => row.stableRuleId.equals(cituljeParentRuleId),
        ))
        .write(const PodsetnikObavezeCompanion(completed: drift.Value(true)));
    var current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isFalse,
    );

    await repository.setAtomicCompletion(
      predmetId: predmetId,
      stableRuleId: childA.rule.stableRuleId,
      completed: true,
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isFalse,
    );
    expect(
      current
          .singleWhere((item) => item.rule.stableRuleId == childA.rule.stableRuleId)
          .completed,
      isTrue,
    );
    expect(
      current
          .singleWhere((item) => item.rule.stableRuleId == childB.rule.stableRuleId)
          .completed,
      isFalse,
    );

    await repository.setAtomicCompletion(
      predmetId: predmetId,
      stableRuleId: childB.rule.stableRuleId,
      completed: true,
    );

    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isTrue,
    );

    await repository.setAtomicCompletion(
      predmetId: predmetId,
      stableRuleId: childA.rule.stableRuleId,
      completed: false,
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isFalse,
    );

    await repository.setParentCompletion(
      predmetId: predmetId,
      parentRuleId: cituljeParentRuleId,
      completed: true,
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isTrue,
    );
    expect(
      current
          .where(
            (item) =>
                item.rule.parentRuleId == cituljeParentRuleId && item.isAtomic,
          )
          .every((item) => item.completed),
      isTrue,
    );
    expect(
      current.singleWhere(
        (item) => item.rule.stableRuleId == 'ceremony.opelo.notify_priest',
      ).completed,
      isFalse,
    );

    await repository.setParentCompletion(
      predmetId: predmetId,
      parentRuleId: cituljeParentRuleId,
      completed: false,
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere((item) => item.rule.stableRuleId == cituljeParentRuleId).completed,
      isFalse,
    );
    expect(current.where((item) => item.isAtomic).every((item) => !item.completed), isTrue);
  });

  test('completed ČITULJA occurrence keeps minimal completion across IRiU absence', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await _insertPredmet(db, 'R5-MEMBERSHIP');
    final occurrenceId = await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-membership-a',
      type: IriuK.cituljaP,
      order: 1,
    );
    final repository = PodsetnikObligationRepository(db);
    var current = await repository.reconcileForPredmet(predmetId);
    final child = current.singleWhere(
      (item) => item.rule.portableOccurrenceId == 'r5-membership-a',
    );
    await repository.setAtomicCompletion(
      predmetId: predmetId,
      stableRuleId: child.rule.stableRuleId,
      completed: true,
    );

    await (db.update(db.iriu)..where((row) => row.id.equals(occurrenceId))).write(
      const IriuCompanion(poslovniStatus: drift.Value('NE PRIKAZUJE SE')),
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.any((item) => item.rule.portableOccurrenceId == 'r5-membership-a'),
      isFalse,
    );
    expect(
      current.any((item) => item.rule.stableRuleId == cituljeParentRuleId),
      isFalse,
    );
    expect(
      (await (db.select(db.podsetnikObaveze)..where(
            (row) => row.stableRuleId.equals('citulje.occurrence.r5-membership-a'),
          ))
          .getSingle())
          .completed,
      isTrue,
    );

    await (db.update(db.iriu)..where((row) => row.id.equals(occurrenceId))).write(
      const IriuCompanion(poslovniStatus: drift.Value('AKTIVNO')),
    );
    current = await repository.currentForPredmet(predmetId);
    expect(
      current.singleWhere(
        (item) => item.rule.portableOccurrenceId == 'r5-membership-a',
      ).completed,
      isTrue,
    );

    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-membership-new',
      type: IriuK.cituljaP,
      order: 2,
    );
    current = await repository.reconcileForPredmet(predmetId);
    expect(
      current.singleWhere(
        (item) => item.rule.portableOccurrenceId == 'r5-membership-new',
      ).completed,
      isFalse,
    );
    expect(
      current.singleWhere(
        (item) => item.rule.stableRuleId == cituljeParentRuleId,
      ).completed,
      isFalse,
    );
    expect(
      current.where((item) => item.rule.portableOccurrenceId != null).length,
      2,
    );
  });

  test('ČITULJA completion survives PREDMET JSON transfer by occurrence identity', () async {
    final source = createTestDatabase();
    final target = createTestDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    final sourceId = await _insertPredmet(source, 'R5-JSON');
    await _insertCitulja(
      source,
      predmetId: sourceId,
      portableId: 'r5-json-a',
      type: IriuK.cituljaP,
      order: 1,
    );
    await _insertCitulja(
      source,
      predmetId: sourceId,
      portableId: 'r5-json-b',
      type: IriuK.cituljaP,
      order: 2,
    );
    final sourceRepository = PodsetnikObligationRepository(source);
    final sourceObligations = await sourceRepository.reconcileForPredmet(sourceId);
    await sourceRepository.setParentCompletion(
      predmetId: sourceId,
      parentRuleId: cituljeParentRuleId,
      completed: true,
    );
    await sourceRepository.setAtomicCompletion(
      predmetId: sourceId,
      stableRuleId: sourceObligations
          .singleWhere((item) => item.rule.portableOccurrenceId == 'r5-json-b')
          .rule
          .stableRuleId,
      completed: true,
    );
    await sourceRepository.setAtomicCompletion(
      predmetId: sourceId,
      stableRuleId: sourceObligations
          .singleWhere((item) => item.rule.portableOccurrenceId == 'r5-json-b')
          .rule
          .stableRuleId,
      completed: false,
    );
    final json = jsonDecode(
      await serializePredmetJsonForTest(db: source, predmetId: sourceId),
    ) as Map<String, dynamic>;
    final actor = await _insertActor(target);
    await importPredmetJsonMapForTest(
      db: target,
      json: json,
      localActorKorisnikId: actor,
    );
    final targetId = (await target.select(target.predmeti).get()).single.id;
    final imported = await PodsetnikObligationRepository(
      target,
    ).currentForPredmet(targetId);

    expect(imported.singleWhere((item) => item.isGroup).completed, isFalse);
    expect(
      imported.singleWhere(
        (item) => item.rule.portableOccurrenceId == 'r5-json-a',
      ).completed,
      isTrue,
    );
    expect(
      imported.singleWhere(
        (item) => item.rule.portableOccurrenceId == 'r5-json-b',
      ).completed,
      isFalse,
    );
  });

  test(
    'non-current completed ČITULJA state survives PREDMET JSON and reappears by identity',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final sourceId = await _insertPredmet(source, 'R5-COR-003-JSON');
      final occurrenceId = await _insertCitulja(
        source,
        predmetId: sourceId,
        portableId: 'r5-cor-003-json-a',
        type: IriuK.cituljaP,
        order: 1,
      );
      final sourceRepository = PodsetnikObligationRepository(source);
      final sourceObligations = await sourceRepository.reconcileForPredmet(
        sourceId,
      );
      await sourceRepository.setAtomicCompletion(
        predmetId: sourceId,
        stableRuleId: sourceObligations
            .singleWhere(
              (item) => item.rule.portableOccurrenceId == 'r5-cor-003-json-a',
            )
            .rule
            .stableRuleId,
        completed: true,
      );
      await (source.update(source.iriu)..where(
            (row) => row.id.equals(occurrenceId),
          ))
          .write(
            const IriuCompanion(
              poslovniStatus: drift.Value('NE PRIKAZUJE SE'),
            ),
          );

      final sourceCurrent = await sourceRepository.currentForPredmet(sourceId);
      expect(
        sourceCurrent.any(
          (item) => item.rule.portableOccurrenceId == 'r5-cor-003-json-a',
        ),
        isFalse,
      );
      expect(
        (await (source.select(source.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals(
                    'citulje.occurrence.r5-cor-003-json-a',
                  ),
                ))
                .getSingle())
            .completed,
        isTrue,
      );

      final json = jsonDecode(
        await serializePredmetJsonForTest(db: source, predmetId: sourceId),
      ) as Map<String, dynamic>;
      final actor = await _insertActor(target);
      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: actor,
      );
      final targetId = (await target.select(target.predmeti).get()).single.id;
      final targetRepository = PodsetnikObligationRepository(target);
      var targetCurrent = await targetRepository.currentForPredmet(targetId);
      expect(
        targetCurrent.any(
          (item) => item.rule.portableOccurrenceId == 'r5-cor-003-json-a',
        ),
        isFalse,
      );
      expect(
        (await (target.select(target.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals(
                    'citulje.occurrence.r5-cor-003-json-a',
                  ),
                ))
                .getSingle())
            .completed,
        isTrue,
      );

      await (target.update(target.iriu)..where(
            (row) => row.portableOccurrenceId.equals('r5-cor-003-json-a'),
          ))
          .write(const IriuCompanion(poslovniStatus: drift.Value('AKTIVNO')));
      targetCurrent = await targetRepository.currentForPredmet(targetId);
      expect(
        targetCurrent
            .singleWhere(
              (item) => item.rule.portableOccurrenceId == 'r5-cor-003-json-a',
            )
            .completed,
        isTrue,
      );

      await _insertCitulja(
        target,
        predmetId: targetId,
        portableId: 'r5-cor-003-json-new',
        type: IriuK.cituljaP,
        order: 2,
      );
      targetCurrent = await targetRepository.reconcileForPredmet(targetId);
      expect(
        targetCurrent
            .singleWhere(
              (item) => item.rule.portableOccurrenceId == 'r5-cor-003-json-new',
            )
            .completed,
        isFalse,
      );
    },
  );

  test(
    'non-current completed ČITULJA state survives OPC Backup and rejects stale identities',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final sourceId = await _insertPredmet(source, 'R5-COR-003-BACKUP');
      final occurrenceId = await _insertCitulja(
        source,
        predmetId: sourceId,
        portableId: 'r5-cor-003-backup-a',
        type: IriuK.cituljaNo,
        order: 1,
      );
      final sourceRepository = PodsetnikObligationRepository(source);
      final sourceObligations = await sourceRepository.reconcileForPredmet(
        sourceId,
      );
      await sourceRepository.setAtomicCompletion(
        predmetId: sourceId,
        stableRuleId: sourceObligations
            .singleWhere(
              (item) =>
                  item.rule.portableOccurrenceId == 'r5-cor-003-backup-a',
            )
            .rule
            .stableRuleId,
        completed: true,
      );
      await (source.update(source.iriu)..where(
            (row) => row.id.equals(occurrenceId),
          ))
          .write(
            const IriuCompanion(
              poslovniStatus: drift.Value('NE PRIKAZUJE SE'),
            ),
          );
      final backup = jsonDecode(
        await serializeBackupJsonForTest(db: source),
      ) as Map<String, dynamic>;
      await importBackupJsonMapForTest(db: target, json: backup);
      final targetId = (await target.select(target.predmeti).get()).single.id;
      final targetRepository = PodsetnikObligationRepository(target);
      expect(
        (await (target.select(target.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals(
                    'citulje.occurrence.r5-cor-003-backup-a',
                  ),
                ))
                .getSingle())
            .completed,
        isTrue,
      );
      expect(
        (await targetRepository.currentForPredmet(targetId)).any(
          (item) => item.rule.portableOccurrenceId == 'r5-cor-003-backup-a',
        ),
        isFalse,
      );

      await targetRepository.importPortableState(
        predmetId: targetId,
        states: [
          const PodsetnikObligationTransferState(
            stableRuleId: 'citulje.occurrence.unknown',
            phase: 'preCeremony',
            kind: 'atomic',
            parentRuleId: cituljeParentRuleId,
            sourceFingerprint: 'unknown',
            completed: true,
            completedAt: null,
          ),
          const PodsetnikObligationTransferState(
            stableRuleId: 'social.fake',
            phase: 'preCeremony',
            kind: 'atomic',
            parentRuleId: null,
            sourceFingerprint: 'unknown',
            completed: true,
            completedAt: null,
          ),
          const PodsetnikObligationTransferState(
            stableRuleId: cituljeParentRuleId,
            phase: 'preCeremony',
            kind: 'group',
            parentRuleId: null,
            sourceFingerprint: 'unknown',
            completed: true,
            completedAt: null,
          ),
        ],
      );
      expect(
        (await (target.select(target.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals('citulje.occurrence.unknown'),
                ))
                .get())
            .isEmpty,
        isTrue,
      );
      expect(
        (await (target.select(target.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals('social.fake'),
                ))
                .get())
            .isEmpty,
        isTrue,
      );
      expect(
        (await (target.select(target.podsetnikObaveze)..where(
                  (row) => row.stableRuleId.equals(cituljeParentRuleId),
                ))
                .get())
            .isEmpty,
        isTrue,
      );

      await (target.update(target.iriu)..where(
            (row) => row.portableOccurrenceId.equals('r5-cor-003-backup-a'),
          ))
          .write(const IriuCompanion(poslovniStatus: drift.Value('AKTIVNO')));
      expect(
        (await targetRepository.currentForPredmet(targetId))
            .singleWhere(
              (item) => item.rule.portableOccurrenceId == 'r5-cor-003-backup-a',
            )
            .completed,
        isTrue,
      );
    },
  );

  test(
    'ČITULJA persistence retains only valid completed non-current state',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetId = await _insertPredmet(db, 'R5-COR-004-CLEANUP');
      final keepId = await _insertCitulja(
        db,
        predmetId: predmetId,
        portableId: 'r5-cor-004-keep',
        type: IriuK.cituljaP,
        order: 1,
      );
      final dropId = await _insertCitulja(
        db,
        predmetId: predmetId,
        portableId: 'r5-cor-004-drop',
        type: IriuK.cituljaNo,
        order: 2,
      );
      final repository = PodsetnikObligationRepository(db);
      final initial = await repository.reconcileForPredmet(predmetId);
      await repository.setAtomicCompletion(
        predmetId: predmetId,
        stableRuleId: initial
            .singleWhere(
              (item) => item.rule.portableOccurrenceId == 'r5-cor-004-keep',
            )
            .rule
            .stableRuleId,
        completed: true,
      );
      await (db.update(db.iriu)..where((row) => row.id.equals(keepId))).write(
        const IriuCompanion(poslovniStatus: drift.Value('NE PRIKAZUJE SE')),
      );
      await (db.update(db.iriu)..where((row) => row.id.equals(dropId))).write(
        const IriuCompanion(poslovniStatus: drift.Value('NE PRIKAZUJE SE')),
      );

      // These rows model the old broad-prefix retention debt and a derived
      // parent cache. None is a durable ČITULJA business fact.
      await (db.update(db.podsetnikObaveze)..where(
            (row) => row.stableRuleId.equals(
              'citulje.occurrence.r5-cor-004-drop',
            ),
          ))
          .write(const PodsetnikObavezeCompanion(completed: drift.Value(false)));
      await db.into(db.podsetnikObaveze).insert(
        PodsetnikObavezeCompanion(
          predmetId: drift.Value(predmetId),
          stableRuleId: const drift.Value('citulje.occurrence.r5-cor-004-orphan'),
          phase: const drift.Value('preCeremony'),
          kind: const drift.Value('atomic'),
          parentRuleId: const drift.Value(cituljeParentRuleId),
          sourceFingerprint: const drift.Value('orphan'),
          completed: const drift.Value(true),
        ),
      );
      await db.into(db.podsetnikObaveze).insert(
        PodsetnikObavezeCompanion(
          predmetId: drift.Value(predmetId),
          stableRuleId: const drift.Value(cituljeParentRuleId),
          phase: const drift.Value('preCeremony'),
          kind: const drift.Value('group'),
          sourceFingerprint: const drift.Value('parent'),
          completed: const drift.Value(true),
        ),
      );

      final current = await repository.currentForPredmet(predmetId);
      expect(current, isEmpty);
      final persisted = await (db.select(db.podsetnikObaveze)
            ..where((row) => row.predmetId.equals(predmetId)))
          .get();
      expect(
        persisted.map((row) => row.stableRuleId),
        contains('citulje.occurrence.r5-cor-004-keep'),
      );
      expect(
        persisted.map((row) => row.stableRuleId),
        isNot(contains('citulje.occurrence.r5-cor-004-drop')),
      );
      expect(
        persisted.map((row) => row.stableRuleId),
        isNot(contains('citulje.occurrence.r5-cor-004-orphan')),
      );
      expect(
        persisted.map((row) => row.stableRuleId),
        isNot(contains(cituljeParentRuleId)),
      );

      final predmetJson = jsonDecode(
        await serializePredmetJsonForTest(db: db, predmetId: predmetId),
      ) as Map<String, dynamic>;
      final transferredStates = ((predmetJson['podsetnikObaveze'] as Map)
          .cast<String, dynamic>()['items'] as List);
      expect(transferredStates, hasLength(1));
      expect(
        (transferredStates.single as Map)['stableRuleId'],
        'citulje.occurrence.r5-cor-004-keep',
      );

      final backup = jsonDecode(await serializeBackupJsonForTest(db: db))
          as Map<String, dynamic>;
      (backup['podsetnikObaveze'] as List)
        ..add({
          'predmetId': predmetId,
          'stableRuleId': 'citulje.occurrence.r5-cor-004-drop',
          'phase': 'preCeremony',
          'kind': 'atomic',
          'parentRuleId': cituljeParentRuleId,
          'sourceFingerprint': 'stale',
          'completed': false,
        })
        ..add({
          'predmetId': predmetId,
          'stableRuleId': 'citulje.occurrence.r5-cor-004-orphan',
          'phase': 'preCeremony',
          'kind': 'atomic',
          'parentRuleId': cituljeParentRuleId,
          'sourceFingerprint': 'orphan',
          'completed': true,
        })
        ..add({
          'predmetId': predmetId,
          'stableRuleId': cituljeParentRuleId,
          'phase': 'preCeremony',
          'kind': 'group',
          'sourceFingerprint': 'parent',
          'completed': true,
        });
      final target = createTestDatabase();
      addTearDown(target.close);
      await importBackupJsonMapForTest(db: target, json: backup);
      final restored = await (target.select(target.podsetnikObaveze)
            ..where((row) => row.predmetId.equals(predmetId)))
          .get();
      expect(
        restored.map((row) => row.stableRuleId),
        contains('citulje.occurrence.r5-cor-004-keep'),
      );
      expect(
        restored.map((row) => row.stableRuleId),
        isNot(contains('citulje.occurrence.r5-cor-004-drop')),
      );
      expect(
        restored.map((row) => row.stableRuleId),
        isNot(contains('citulje.occurrence.r5-cor-004-orphan')),
      );
      expect(
        restored.map((row) => row.stableRuleId),
        isNot(contains(cituljeParentRuleId)),
      );
    },
  );

  test('ČITULJA completion survives OPC Backup JSON round trip', () async {
    final source = createTestDatabase();
    final target = createTestDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    final sourceId = await _insertPredmet(source, 'R5-BACKUP');
    await _insertCitulja(
      source,
      predmetId: sourceId,
      portableId: 'r5-backup-a',
      type: IriuK.cituljaNo,
      order: 1,
    );
    final repository = PodsetnikObligationRepository(source);
    final obligations = await repository.reconcileForPredmet(sourceId);
    await repository.setAtomicCompletion(
      predmetId: sourceId,
      stableRuleId: obligations
          .singleWhere((item) => item.rule.portableOccurrenceId == 'r5-backup-a')
          .rule
          .stableRuleId,
      completed: true,
    );
    final backup = jsonDecode(await serializeBackupJsonForTest(db: source))
        as Map<String, dynamic>;
    await importBackupJsonMapForTest(db: target, json: backup);
    final targetId = (await target.select(target.predmeti).get()).single.id;
    final imported = await PodsetnikObligationRepository(
      target,
    ).currentForPredmet(targetId);
    expect(
      imported.singleWhere(
        (item) => item.rule.portableOccurrenceId == 'r5-backup-a',
      ).completed,
      isTrue,
    );
  });

  testWidgets('ČITULJA child exposes a non-technical canonical PDF action', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    });
    final predmetId = await _insertPredmet(db, 'R5-UI');
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-ui-occurrence',
      type: IriuK.cituljaP,
      order: 1,
    );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    String? capturedOccurrence;

    await tester.pumpWidget(
      MaterialApp(
        home: PodsetnikPredmetSettings(
          predmet: predmet,
          database: db,
          onCituljaPdf: (context, occurrenceId) async {
            capturedOccurrence = occurrenceId;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ČITULJA'), findsOneWidget);
    expect(
      tester.widget<Checkbox>(
        find.byKey(
          const ValueKey('podsetnik-parent-checkbox-citulje.parent'),
        ),
      ).value,
      isFalse,
    );
    expect(find.text('ČITULJA POLITIKA'), findsNothing);
    expect(find.text('Čitulja PDF'), findsNothing);
    expect(find.textContaining('r5-ui-occurrence'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('podsetnik-parent-label-citulje.parent')),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Checkbox>(
        find.byKey(
          const ValueKey('podsetnik-parent-checkbox-citulje.parent'),
        ),
      ).value,
      isFalse,
    );
    expect(find.text('ČITULJA POLITIKA'), findsOneWidget);
    expect(find.text('Čitulja PDF'), findsOneWidget);
    expect(find.textContaining('r5-ui-occurrence'), findsNothing);
    await tester.tap(find.text('Čitulja PDF'));
    await tester.pumpAndSettle();
    expect(capturedOccurrence, 'r5-ui-occurrence');
  });

  test('LISTA receives ČITULJA parent and children from the shared model',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await _insertPredmet(db, 'R5-LISTA');
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-lista-a',
      type: IriuK.cituljaP,
      order: 1,
    );
    await _insertCitulja(
      db,
      predmetId: predmetId,
      portableId: 'r5-lista-b',
      type: IriuK.cituljaNo,
      order: 2,
    );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final prepared = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: await (db.select(
        db.iriu,
      )..where((row) => row.predmetId.equals(predmetId))).get(),
      firma: await db.select(db.firmaPodaci).getSingle(),
      app: await db.select(db.appPodesavanja).getSingle(),
      savetnik: null,
    );
    expect(prepared.podsetnikChecklist.map((item) => item.label), containsAll([
      'ČITULJA',
      'ČITULJA POLITIKA',
      'ČITULJA NOVOSTI',
    ]));
    expect(
      prepared.podsetnikChecklist.any(
        (item) => item.label.contains('r5-lista-'),
      ),
      isFalse,
    );
  });
}

Future<int> _insertPredmet(AppDatabase db, String brojPredmeta) => db
    .into(db.predmeti)
    .insert(
      PredmetiCompanion.insert(
        brojPredmeta: drift.Value(brojPredmeta),
        datumKreiranja: const drift.Value('2026-09-06T00:00:00.000'),
        status: const drift.Value('OTVOREN'),
      ),
    );

Future<int> _insertCitulja(
  AppDatabase db, {
  required int predmetId,
  required String portableId,
  required String type,
  required int order,
}) => db
    .into(db.iriu)
    .insert(
      IriuCompanion.insert(
        predmetId: predmetId,
        portableOccurrenceId: drift.Value(portableId),
        interniNaziv: type,
        nazivPrikaz: const drift.Value('Čitulje'),
        redosled: drift.Value(order),
      ),
    );

Future<int> _insertActor(AppDatabase db) => db
    .into(db.korisnici)
    .insert(
      KorisniciCompanion.insert(
        imePrezime: 'R5 Actor',
        uloga: 'ADMINISTRATOR',
        pinHash: 'r5-test-hash',
        datumKreiranja: '2026-09-06T00:00:00.000',
      ),
    );
