import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_reminder_model.dart';
import 'package:opc_v4/features/predmeti/reminders/urna_ashes_reminder_model.dart';

import 'test_bootstrap.dart';

void main() {
  test('URNA obligation trigger is immediate and fail-closed', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    Future<List<String>> rules(String ceremony, String placement) async {
      final id = await db.into(db.predmeti).insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value('$ceremony-$placement'),
          vrstaCeremonije: Value(ceremony),
          tipPolaganja: Value(placement),
        ),
      );
      final predmet = await (db.select(db.predmeti)
            ..where((row) => row.id.equals(id)))
          .getSingle();
      return const PodsetnikObligationDeriver()
          .deriveRules(predmet: predmet, iriu: const [])
          .map((item) => item.stableRuleId)
          .toList();
    }

    expect(await rules('SAHRANA', 'GROB'), isEmpty);
    expect(await rules('KREMACIJA', 'NAKNADNO'), isEmpty);
    expect(
      await rules('KREMACIJA', 'GROB'),
      contains('post.urn_ashes.arrange_placement'),
    );
    expect(
      await rules('KREMACIJA_EKSPRES', 'RASIPANJE_PEPELA'),
      contains('post.urn_ashes.arrange_placement'),
    );
  });

  test('URNA cycle starts at +3 and uses selected delivery times', () {
    final occurrences = buildUrnaAshesReminderOccurrences(
      predmetId: 41,
      ceremonyAt: DateTime(2026, 9, 1, 12),
      ceremonyType: 'KREMACIJA',
      placementType: 'GROB',
      config: const CeremonyReminderConfig(deliveryTimes: ['08:00', '18:00']),
      now: DateTime(2026, 9, 1, 10),
      completed: false,
    );
    expect(occurrences.map((item) => item.scheduledAt), [
      DateTime(2026, 9, 4, 8),
      DateTime(2026, 9, 4, 18),
    ]);
    expect(
      buildUrnaAshesReminderOccurrences(
        predmetId: 41,
        ceremonyAt: DateTime(2026, 9, 1, 12),
        ceremonyType: 'KREMACIJA',
        placementType: 'GROB',
        config: const CeremonyReminderConfig(deliveryTimes: ['08:00']),
        now: DateTime(2026, 9, 5, 9),
        completed: true,
      ),
      isEmpty,
    );
  });

  test('URNA Windows secondary slot uses the same selected cadence after +3', () {
    final ceremonyAt = DateTime(2026, 9, 1, 12);
    expect(
      activeUrnaAshesReminderSlot(
        ceremonyAt: ceremonyAt,
        config: const CeremonyReminderConfig(deliveryTimes: ['08:00', '18:00']),
        now: DateTime(2026, 9, 4, 19),
        ceremonyType: 'KREMACIJA',
        placementType: 'GROB',
        completed: false,
      ),
      DateTime(2026, 9, 4, 18),
    );
    expect(
      activeUrnaAshesReminderSlot(
        ceremonyAt: ceremonyAt,
        config: const CeremonyReminderConfig(deliveryTimes: ['08:00']),
        now: DateTime(2026, 9, 3, 12),
        ceremonyType: 'KREMACIJA',
        placementType: 'GROB',
        completed: false,
      ),
      isNull,
    );
  });

  test('URNA notification wording uses only urna cemetery', () {
    expect(
      buildUrnaAshesReminderText(
        deceasedFirstName: 'Petar',
        deceasedLastName: 'Petrović',
        placementType: 'GROB',
        urnaCemetery: 'Novo groblje',
      ),
      'ZA Petar Petrović ZAKAZATI POLAGANJE URNE U GROB NA Novo groblje.',
    );
    expect(
      buildUrnaAshesReminderText(
        deceasedFirstName: 'Petar',
        deceasedLastName: 'Petrović',
        placementType: 'RASIPANJE_PEPELA',
        urnaCemetery: 'Novo groblje',
      ),
      'ZA Petar Petrović ZAKAZATI RASIPANJE PEPELA NA Novo groblje GROBLJU.',
    );
    expect(
      buildUrnaAshesReminderText(
        deceasedFirstName: 'Petar',
        deceasedLastName: 'Petrović',
        placementType: 'GROB',
        urnaCemetery: '',
      ),
      'Groblje za polaganje urne nije uneto',
    );
  });

  test('URNA completion is manually available and blocks ZAVRŠEN until done',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db.into(db.predmeti).insert(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('URNA-BLOCK-1'),
        status: const Value('ZATVOREN'),
        vrstaCeremonije: const Value('KREMACIJA'),
        tipPolaganja: const Value('GROB'),
      ),
    );
    final actorId = await db.into(db.korisnici).insert(
      KorisniciCompanion.insert(
        imePrezime: 'Savetnik',
        uloga: 'SAVETNIK',
        pinHash: 'urna-block-pin',
        datumKreiranja: '2026-09-01',
      ),
    );
    final repo = PodsetnikObligationRepository(db);
    await repo.reconcileForPredmet(predmetId);
    final predmetRepo = PredmetiRepository(db);
    expect(
      () => predmetRepo.zavrsiPredmet(predmetId, korisnikId: actorId),
      throwsA(isA<UrnaAshesCompletionBlockException>()),
    );
    await repo.setAtomicCompletion(
      predmetId: predmetId,
      stableRuleId: 'post.urn_ashes.arrange_placement',
      completed: true,
    );
    await predmetRepo.zavrsiPredmet(predmetId, korisnikId: actorId);
    expect((await predmetRepo.getPredmet(predmetId)).status, 'ZAVRŠEN');
  });

  test('manual obligations are role-gated, grouped and portable', () async {
    final source = createTestDatabase();
    final target = createTestDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    final sourceId = await source.into(source.predmeti).insert(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('F06-1'),
        status: const Value('OTVOREN'),
      ),
    );
    final sourceRepo = PodsetnikObligationRepository(source);
    expect(
      () => sourceRepo.addManualObligation(
        predmetId: sourceId,
        text: 'Posebna provera dokumentacije',
        actorRole: 'GOST',
      ),
      throwsStateError,
    );
    final manualId = await sourceRepo.addManualObligation(
      predmetId: sourceId,
      text: 'Posebna provera dokumentacije',
      actorRole: 'SAVETNIK',
    );
    final adminManualId = await sourceRepo.addManualObligation(
      predmetId: sourceId,
      text: 'Administratorska posebna obaveza',
      actorRole: 'ADMINISTRATOR',
    );
    await sourceRepo.reconcileForPredmet(sourceId);
    var current = await sourceRepo.currentForPredmet(sourceId);
    final parent = current.singleWhere(
      (item) => item.rule.stableRuleId == posebneObavezeParentRuleId,
    );
    expect(parent.completed, isFalse);
    expect(current.singleWhere((item) => item.rule.stableRuleId == manualId)
        .rule.displayLabel, 'Posebna provera dokumentacije');
    expect(
      current.any((item) => item.rule.stableRuleId == adminManualId),
      isTrue,
    );
    await sourceRepo.setParentCompletion(
      predmetId: sourceId,
      parentRuleId: posebneObavezeParentRuleId,
      completed: true,
    );
    current = await sourceRepo.currentForPredmet(sourceId);
    expect(current.singleWhere((item) => item.rule.stableRuleId == manualId)
        .completed, isTrue);
    final state = (await sourceRepo.exportPortableState(sourceId))
        .singleWhere((item) => item.stableRuleId == manualId);
    expect(state.obligationText, 'Posebna provera dokumentacije');

    final targetId = await target.into(target.predmeti).insert(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('F06-1-target'),
        status: const Value('OTVOREN'),
      ),
    );
    await PodsetnikObligationRepository(target).importPortableState(
      predmetId: targetId,
      states: [state],
    );
    final imported = await PodsetnikObligationRepository(target)
        .currentForPredmet(targetId);
    expect(imported.singleWhere((item) => item.rule.stableRuleId == manualId)
        .completed, isTrue);
    expect(imported.singleWhere((item) => item.rule.stableRuleId == manualId)
        .rule.displayLabel, 'Posebna provera dokumentacije');
  });
}
