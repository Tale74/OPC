import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation.dart';
import 'package:opc_v4/features/predmeti/pdf/lista_pdf_data_builder.dart';

import 'test_bootstrap.dart';

void main() {
  test('overview roots include incomplete atomics and suppress children', () {
    const parent = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'parent',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.group,
      ),
      predmetId: 1,
      sourceFingerprint: 'p',
      relevant: true,
      completed: false,
    );
    const child = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'child',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.atomic,
        parentRuleId: 'parent',
      ),
      predmetId: 1,
      sourceFingerprint: 'c',
      relevant: true,
      completed: false,
    );
    const atomic = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'goods.flowers',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.atomic,
      ),
      predmetId: 1,
      sourceFingerprint: 'a',
      relevant: true,
      completed: false,
    );
    expect(podsetnikOverviewRoots([parent, child, atomic]), [parent, atomic]);
  });

  test('REVIEW BAR includes active CVEĆE and SLIKA category roots', () {
    const slika = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'goods.photo',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.atomic,
      ),
      predmetId: 1,
      sourceFingerprint: 'slika',
      relevant: true,
      completed: false,
    );
    const cvece = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'goods.flowers',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.atomic,
      ),
      predmetId: 1,
      sourceFingerprint: 'cvece',
      relevant: true,
      completed: false,
    );

    expect(
      podsetnikOverviewRoots([
        slika,
        cvece,
      ]).map((item) => podsetnikReviewBarDisplayLabel(item.rule)),
      ['SLIKA', 'CVEĆE'],
    );
  });

  test('REVIEW BAR includes active POSEBNE OBAVEZE parent only', () {
    const parent = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: posebneObavezeParentRuleId,
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.group,
      ),
      predmetId: 1,
      sourceFingerprint: 'parent',
      relevant: true,
      completed: false,
    );
    const child = PodsetnikObligation(
      rule: PodsetnikObligationRule(
        stableRuleId: 'special.manual.one',
        phase: PodsetnikObligationPhase.preCeremony,
        kind: PodsetnikObligationKind.atomic,
        parentRuleId: posebneObavezeParentRuleId,
      ),
      predmetId: 1,
      sourceFingerprint: 'child',
      relevant: true,
      completed: false,
    );

    expect(podsetnikReviewBarText([parent, child], 0), 'POSEBNE OBAVEZE');
  });

  test(
    'REVIEW BAR uses short URNA label and preserves full obligation label',
    () {
      const urna = PodsetnikObligationRule(
        stableRuleId: 'post.urn_ashes',
        phase: PodsetnikObligationPhase.postCeremony,
        kind: PodsetnikObligationKind.group,
        displayLabel: 'ZA TEST ZAKAZATI POLAGANJE URNE U GROB NA GROBLJE.',
      );
      const obligation = PodsetnikObligation(
        rule: urna,
        predmetId: 1,
        sourceFingerprint: 'urna',
        relevant: true,
        completed: false,
      );

      expect(
        podsetnikReviewBarText([obligation], 0),
        'ZAKAZATI POLAGANJE URNE',
      );
      expect(
        podsetnikObligationDisplayLabel(urna),
        'ZA TEST ZAKAZATI POLAGANJE URNE U GROB NA GROBLJE.',
      );
      expect(podsetnikReviewBarText(const [], 0), 'OBAVEZE ISPUNJENE');
    },
  );

  test(
    'stable obligation identity is independent of display wording',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('POD-ID-1'),
              datumKreiranja: const Value('2026-08-29'),
              opelo: const Value('DA'),
              obavestitiSvestenika: const Value('DA'),
            ),
          );
      final predmet = await (db.select(
        db.predmeti,
      )..where((p) => p.id.equals(id))).getSingle();
      final rules = const PodsetnikObligationDeriver().deriveRules(
        predmet: predmet,
        iriu: const [],
      );
      final priest = rules.singleWhere(
        (rule) => rule.stableRuleId == 'ceremony.opelo.notify_priest',
      );
      expect(priest.parentRuleId, 'ceremony.opelo');
      expect(priest.stableRuleId, isNot('Obavestiti sveštenika'));
    },
  );

  test('VOJNE POČASTI uses the generic grouped obligation structure', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('POD-VOJNE-POCASTI-1'),
            datumKreiranja: const Value('2026-08-29'),
            vojniPenzioner: const Value('DA'),
            vojnePocasti: const Value('DA'),
            narucilacRefundira: const Value('DA'),
          ),
        );
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(id))).getSingle();
    final rules = const PodsetnikObligationDeriver().deriveRules(
      predmet: predmet,
      iriu: const [],
    );
    final parent = rules.singleWhere(
      (rule) => rule.stableRuleId == 'military.honors',
    );
    final child = rules.singleWhere(
      (rule) => rule.stableRuleId == 'military.honors.notify_authority',
    );
    expect(parent.kind, PodsetnikObligationKind.group);
    expect(parent.phase, PodsetnikObligationPhase.preCeremony);
    expect(podsetnikObligationDisplayLabel(parent), 'VOJNE POČASTI');
    expect(child.kind, PodsetnikObligationKind.atomic);
    expect(child.parentRuleId, 'military.honors');
    expect(
      podsetnikObligationDisplayLabel(child),
      'OBAVESTITI NADLEŽNU SLUŽBU',
    );
    expect(
      podsetnikObligationDisplayLabel(child),
      isNot('VOJNE POČASTI — obavestiti nadležnu službu'),
    );

    final repo = PodsetnikObligationRepository(db);
    var current = await repo.reconcileForPredmet(id);
    expect(current.map((item) => item.rule.stableRuleId), [
      'military.honors',
      'military.honors.notify_authority',
    ]);
    expect(podsetnikReviewBarText(current, 0), 'VOJNE POČASTI');

    await repo.setAtomicCompletion(
      predmetId: id,
      stableRuleId: child.stableRuleId,
      completed: true,
    );
    current = await repo.currentForPredmet(id);
    expect(
      current
          .singleWhere((item) => item.rule.stableRuleId == 'military.honors')
          .completed,
      isTrue,
    );
    expect(podsetnikReviewBarText(current, 0), 'OBAVEZE ISPUNJENE');

    await repo.setAtomicCompletion(
      predmetId: id,
      stableRuleId: child.stableRuleId,
      completed: false,
    );
    current = await repo.currentForPredmet(id);
    expect(podsetnikReviewBarText(current, 0), 'VOJNE POČASTI');

    await repo.setParentCompletion(
      predmetId: id,
      parentRuleId: parent.stableRuleId,
      completed: true,
    );
    current = await repo.currentForPredmet(id);
    expect(
      current
          .singleWhere((item) => item.rule.stableRuleId == child.stableRuleId)
          .completed,
      isTrue,
    );

    final firma = await db.select(db.firmaPodaci).getSingle();
    final app = await db.select(db.appPodesavanja).getSingle();
    final lista = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: const [],
      firma: firma,
      app: app,
      savetnik: null,
    );
    expect(lista.podsetnikChecklist.map((item) => item.label).toList(), [
      'VOJNE POČASTI',
      'Obavestiti nadležnu službu',
    ]);
    expect(lista.podsetnikChecklist.map((item) => item.group).toList(), [
      true,
      false,
    ]);
    expect(
      lista.podsetnikChecklist.map((item) => item.label),
      isNot(contains('VOJNE POČASTI — obavestiti nadležnu službu')),
    );

    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      const PredmetiCompanion(vojnePocasti: Value('NE')),
    );
    expect(await repo.currentForPredmet(id), isEmpty);
  });

  test(
    'atomic completion persists and parent derives from current children',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('POD-FOUNDATION-1'),
              datumKreiranja: const Value('2026-08-29'),
              opelo: const Value('DA'),
              obavestitiSvestenika: const Value('DA'),
            ),
          );
      final repo = PodsetnikObligationRepository(db);
      final before = await repo.currentForPredmet(id);
      final priest = before.firstWhere(
        (item) => item.rule.stableRuleId == 'ceremony.opelo.notify_priest',
      );
      expect(priest.completed, isFalse);
      await repo.setAtomicCompletion(
        predmetId: id,
        stableRuleId: priest.rule.stableRuleId,
        completed: true,
      );
      expect(
        (await repo.currentForPredmet(id))
            .firstWhere(
              (item) => item.rule.stableRuleId == priest.rule.stableRuleId,
            )
            .completed,
        isTrue,
      );
      await repo.setParentCompletion(
        predmetId: id,
        parentRuleId: 'ceremony.opelo',
        completed: true,
      );
      expect(
        (await repo.currentForPredmet(id))
            .where((item) => item.rule.parentRuleId == 'ceremony.opelo')
            .every((item) => item.completed),
        isTrue,
      );
    },
  );

  test(
    'live completion stream refreshes REVIEW BAR projection and supports reopening',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final id = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('POD-LIVE-REFRESH-1'),
              datumKreiranja: const Value('2026-08-29'),
              opelo: const Value('DA'),
              obavestitiSvestenika: const Value('DA'),
            ),
          );
      final repo = PodsetnikObligationRepository(db);
      final events = StreamIterator(repo.watchCurrentForPredmet(id));
      addTearDown(events.cancel);

      expect(await events.moveNext(), isTrue);
      final initial = events.current;
      final child = initial.firstWhere(
        (item) => item.rule.stableRuleId == 'ceremony.opelo.notify_priest',
      );
      expect(podsetnikReviewBarText(initial, 0), 'OPELO');

      await repo.setAtomicCompletion(
        predmetId: id,
        stableRuleId: child.rule.stableRuleId,
        completed: true,
      );
      expect(await events.moveNext(), isTrue);
      final completed = events.current;
      expect(podsetnikOverviewRoots(completed), isEmpty);
      expect(podsetnikReviewBarText(completed, 0), 'OBAVEZE ISPUNJENE');

      await repo.setAtomicCompletion(
        predmetId: id,
        stableRuleId: child.rule.stableRuleId,
        completed: false,
      );
      expect(await events.moveNext(), isTrue);
      expect(podsetnikReviewBarText(events.current, 0), 'OPELO');
    },
  );

  test(
    'single PREDMET transfer carries completion without local ids',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final sourceId = await source
          .into(source.predmeti)
          .insert(
            PredmetiCompanion.insert(
              brojPredmeta: const Value('POD-TRANSFER-1'),
              datumKreiranja: const Value('2026-08-29'),
              vojnePocasti: const Value('DA'),
              vojniPenzioner: const Value('DA'),
            ),
          );
      final sourceRepo = PodsetnikObligationRepository(source);
      await sourceRepo.reconcileForPredmet(sourceId);
      await sourceRepo.setAtomicCompletion(
        predmetId: sourceId,
        stableRuleId: 'military.honors.notify_authority',
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
              imePrezime: 'Importer',
              uloga: 'ADMINISTRATOR',
              pinHash: 'hash',
              datumKreiranja: '2026-08-29',
            ),
          );
      await importPredmetJsonMapForTest(
        db: target,
        json: json,
        localActorKorisnikId: actor,
      );
      final importedId = (await target.select(target.predmeti).get()).single.id;
      final imported = await PodsetnikObligationRepository(
        target,
      ).currentForPredmet(importedId);
      expect(
        imported
            .singleWhere((item) => item.rule.stableRuleId == 'military.honors')
            .rule
            .kind,
        PodsetnikObligationKind.group,
      );
      expect(
        imported
            .singleWhere(
              (item) =>
                  item.rule.stableRuleId == 'military.honors.notify_authority',
            )
            .rule
            .parentRuleId,
        'military.honors',
      );
      expect(
        imported
            .singleWhere(
              (item) =>
                  item.rule.stableRuleId == 'military.honors.notify_authority',
            )
            .completed,
        isTrue,
      );
    },
  );

  test('eligibility is fail-closed and stale history is inert', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('POD-ELIGIBILITY-1'),
            datumKreiranja: const Value('2026-08-29'),
            vojniPenzioner: const Value('DA'),
            vojnePocasti: const Value('DA'),
          ),
        );
    final repo = PodsetnikObligationRepository(db);
    await repo.reconcileForPredmet(id);
    await repo.setAtomicCompletion(
      predmetId: id,
      stableRuleId: 'military.honors.notify_authority',
      completed: true,
    );
    await (db.update(db.predmeti)..where((row) => row.id.equals(id))).write(
      const PredmetiCompanion(status: Value('ZAVRŠEN')),
    );
    expect(await repo.currentForPredmet(id), isEmpty);
    expect(
      await (db.select(
        db.podsetnikObaveze,
      )..where((row) => row.predmetId.equals(id))).get(),
      isNotEmpty,
    );
  });

  test('responsibility and military prerequisites are fail-closed', () async {
    final noPension = await _derive(
      PredmetiCompanion.insert(brojPredmeta: const Value('POD-R1')),
    );
    expect(
      noPension.any((r) => r.stableRuleId.startsWith('social.pio')),
      isFalse,
    );

    final payer = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-R2'),
        penzionerSrbije: const Value('DA'),
        narucilacRefundira: const Value('DA'),
      ),
    );
    expect(payer.any((r) => r.stableRuleId.startsWith('social.pio')), isFalse);

    final firma = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-R3'),
        penzionerSrbije: const Value('DA'),
        narucilacRefundira: const Value('NE'),
      ),
    );
    expect(
      firma.map((r) => r.stableRuleId),
      containsAll(['social.pio_refund', 'social.pio_refund.submit_claim']),
    );

    final militaryHidden = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-R4'),
        vojnePocasti: const Value('DA'),
        posmrtnaPomoc: const Value('DA'),
      ),
    );
    expect(militaryHidden, isEmpty);

    final military = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-R5'),
        vojniPenzioner: const Value('DA'),
        vojnePocasti: const Value('DA'),
        posmrtnaPomoc: const Value('DA'),
        narucilacRefundira: const Value('NE'),
      ),
    );
    expect(
      military.map((r) => r.stableRuleId),
      containsAll([
        'military.honors',
        'military.honors.notify_authority',
        'social.death_assistance',
        'social.death_assistance.submit_claim',
        'social.pio_refund',
      ]),
    );
  });

  test('military pensioner payer PIO path stays informational', () async {
    final payerPath = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-R6'),
        vojniPenzioner: const Value('DA'),
        refundacijaPio: const Value(100.0),
        narucilacRefundira: const Value('DA'),
      ),
    );
    expect(
      payerPath.any((rule) => rule.stableRuleId.startsWith('social.pio')),
      isFalse,
    );
    expect(
      payerPath.any(
        (rule) => rule.stableRuleId == 'social.pio_refund.submit_claim',
      ),
      isFalse,
    );
  });

  test(
    'RS and military pensioner coexist without duplicate PIO obligation',
    () async {
      final rules = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-R7'),
          penzionerSrbije: const Value('DA'),
          vojniPenzioner: const Value('DA'),
          narucilacRefundira: const Value('NE'),
        ),
      );
      final ids = rules.map((rule) => rule.stableRuleId).toList();
      expect(ids.where((id) => id == 'social.pio_refund').length, 1);
      expect(
        ids.where((id) => id == 'social.pio_refund.submit_claim').length,
        1,
      );
    },
  );

  test('family pension requires married pensioner and FIRMA path', () async {
    final payer = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-F1'),
        bracnoStanje: const Value('UDATA'),
        bracniDrugOstvarujePravo: const Value('DA'),
        penzionerSrbije: const Value('DA'),
        narucilacRefundira: const Value('DA'),
      ),
    );
    expect(
      payer.any((r) => r.stableRuleId.startsWith('social.family')),
      isFalse,
    );
    final notMarried = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-F2'),
        bracniDrugOstvarujePravo: const Value('DA'),
        penzionerSrbije: const Value('DA'),
        narucilacRefundira: const Value('NE'),
      ),
    );
    expect(
      notMarried.any((r) => r.stableRuleId.startsWith('social.family')),
      isFalse,
    );
    final firma = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-F3'),
        bracnoStanje: const Value('OŽENJEN'),
        bracniDrugOstvarujePravo: const Value('DA'),
        vojniPenzioner: const Value('DA'),
        narucilacRefundira: const Value('NE'),
      ),
    );
    expect(
      firma.map((r) => r.stableRuleId),
      containsAll([
        'social.family_pension',
        'social.family_pension.submit_claim',
      ]),
    );
  });

  test(
    'PIO, family pension and funeral assistance are post-ceremony rules',
    () async {
      final pio = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-A-PIO'),
          penzionerSrbije: const Value('DA'),
          narucilacRefundira: const Value('NE'),
        ),
      );
      final family = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-A-FAMILY'),
          bracnoStanje: const Value('UDATA'),
          bracniDrugOstvarujePravo: const Value('DA'),
          penzionerSrbije: const Value('DA'),
          narucilacRefundira: const Value('NE'),
        ),
      );
      final funeral = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-A-FUNERAL'),
          vojniPenzioner: const Value('DA'),
          posmrtnaPomoc: const Value('DA'),
        ),
      );

      for (final rules in [pio, family, funeral]) {
        expect(
          rules
              .where((rule) => rule.stableRuleId.startsWith('social.'))
              .every(
                (rule) => rule.phase == PodsetnikObligationPhase.postCeremony,
              ),
          isTrue,
        );
        final socialParents = rules.where(
          (rule) =>
              rule.stableRuleId.startsWith('social.') &&
              rule.parentRuleId == null,
        );
        for (final parent in socialParents) {
          expect(
            rules
                .where((rule) => rule.parentRuleId == parent.stableRuleId)
                .every(
                  (rule) => rule.phase == PodsetnikObligationPhase.postCeremony,
                ),
            isTrue,
          );
        }
      }
    },
  );

  test(
    'phase correction preserves completion and portable transfer identity',
    () async {
      final source = createTestDatabase();
      final target = createTestDatabase();
      addTearDown(source.close);
      addTearDown(target.close);
      final predmet = PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-A-TRANSFER'),
        penzionerSrbije: const Value('DA'),
        narucilacRefundira: const Value('NE'),
      );
      final sourceId = await source.into(source.predmeti).insert(predmet);
      final targetId = await target.into(target.predmeti).insert(predmet);
      final sourceRepo = PodsetnikObligationRepository(source);
      final targetRepo = PodsetnikObligationRepository(target);

      await sourceRepo.reconcileForPredmet(sourceId);
      await sourceRepo.setAtomicCompletion(
        predmetId: sourceId,
        stableRuleId: 'social.pio_refund.submit_claim',
        completed: true,
      );
      final sourceRow =
          (await (source.select(source.podsetnikObaveze)..where(
                (row) =>
                    row.stableRuleId.equals('social.pio_refund.submit_claim'),
              ))
              .getSingle());
      expect(sourceRow.phase, 'postCeremony');
      expect(sourceRow.completed, isTrue);

      final exported = await sourceRepo.exportPortableState(sourceId);
      final transferred = exported.singleWhere(
        (state) => state.stableRuleId == 'social.pio_refund.submit_claim',
      );
      expect(transferred.phase, 'postCeremony');
      await targetRepo.importPortableState(
        predmetId: targetId,
        states: [transferred],
      );
      final restored =
          (await (target.select(target.podsetnikObaveze)..where(
                (row) =>
                    row.stableRuleId.equals('social.pio_refund.submit_claim'),
              ))
              .getSingle());
      expect(restored.phase, 'postCeremony');
      expect(restored.completed, isTrue);
    },
  );

  test(
    'OPELO responsibility and kit are independent grouped children',
    () async {
      final unknown = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-O1'),
          opelo: const Value('DA'),
        ),
      );
      expect(
        unknown.where((r) => r.stableRuleId.startsWith('ceremony.opelo')),
        isEmpty,
      );
      final family = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-O2'),
          opelo: const Value('DA'),
          obavestitiSvestenika: const Value('NE'),
        ),
      );
      expect(
        family.where((r) => r.stableRuleId == 'ceremony.opelo.notify_priest'),
        isEmpty,
      );
      final firma = await _derive(
        PredmetiCompanion.insert(
          brojPredmeta: const Value('POD-O3'),
          opelo: const Value('DA'),
          obavestitiSvestenika: const Value('DA'),
        ),
      );
      expect(
        firma.map((r) => r.stableRuleId),
        contains('ceremony.opelo.notify_priest'),
      );
      expect(firma.where((r) => r.stableRuleId.contains('church')), isEmpty);
    },
  );

  test('OPELO kit follows current IRiU relevance', () async {
    final irrelevant = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-O4'),
        opelo: const Value('DA'),
        obavestitiSvestenika: const Value('DA'),
      ),
    );
    expect(
      irrelevant.where(
        (rule) => rule.stableRuleId == 'ceremony.opelo.prepare_kit',
      ),
      isEmpty,
    );

    final relevant = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-O5'),
        opelo: const Value('DA'),
      ),
      iriu: [
        IriuCompanion.insert(predmetId: 0, interniNaziv: IriuK.kompletZaOpelo),
      ],
    );
    expect(
      relevant
          .where((rule) => rule.stableRuleId == 'ceremony.opelo.prepare_kit')
          .length,
      1,
    );
  });

  test('owner-defined atomic categories remain single rules', () async {
    final rules = await _derive(
      PredmetiCompanion.insert(
        brojPredmeta: const Value('POD-A1'),
        partePotrebna: const Value(true),
        sahranaVanSrbije: const Value(true),
        docekPosmrtnihOstataka: const Value(true),
      ),
      iriu: [
        IriuCompanion.insert(predmetId: 0, interniNaziv: IriuK.sanduk),
        IriuCompanion.insert(predmetId: 0, interniNaziv: IriuK.slika),
        IriuCompanion.insert(predmetId: 0, interniNaziv: IriuK.cvece),
        IriuCompanion.insert(predmetId: 0, interniNaziv: IriuK.crnina),
      ],
      unresolvedStock: true,
    );
    final ids = rules.map((r) => r.stableRuleId).toList();
    expect(
      ids,
      containsAll([
        'ceremony.parte',
        'goods.equipment',
        'goods.photo',
        'goods.flowers',
        'goods.mourning',
        'ceremony.international',
        'ceremony.reception',
        'goods.stock',
      ]),
    );
    expect(rules.where((r) => r.parentRuleId != null), isEmpty);
  });

  test('fingerprint mismatch cannot resurrect completion', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final id = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: const Value('POD-FP-1'),
            partePotrebna: const Value(true),
          ),
        );
    final repo = PodsetnikObligationRepository(db);
    await repo.reconcileForPredmet(id);
    await repo.setAtomicCompletion(
      predmetId: id,
      stableRuleId: 'ceremony.parte',
      completed: true,
    );
    expect((await repo.currentForPredmet(id)).single.completed, isTrue);
    await (db.update(db.predmeti)..where((p) => p.id.equals(id))).write(
      const PredmetiCompanion(partePotrebna: Value(false)),
    );
    expect(await repo.currentForPredmet(id), isEmpty);
    await (db.update(db.predmeti)..where((p) => p.id.equals(id))).write(
      const PredmetiCompanion(partePotrebna: Value(true)),
    );
    expect((await repo.currentForPredmet(id)).single.completed, isFalse);
  });
}

Future<List<PodsetnikObligationRule>> _derive(
  PredmetiCompanion predmet, {
  List<IriuCompanion> iriu = const [],
  bool unresolvedStock = false,
}) async {
  final db = createTestDatabase();
  final id = await db.into(db.predmeti).insert(predmet);
  for (final row in iriu) {
    await db.into(db.iriu).insert(row.copyWith(predmetId: Value(id)));
  }
  final p = await (db.select(
    db.predmeti,
  )..where((r) => r.id.equals(id))).getSingle();
  final rows = await (db.select(
    db.iriu,
  )..where((r) => r.predmetId.equals(id))).get();
  final result = const PodsetnikObligationDeriver().deriveRules(
    predmet: p,
    iriu: rows,
    unresolvedStock: unresolvedStock,
  );
  await db.close();
  return result;
}
