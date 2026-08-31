import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/utils/json_export_import.dart';
import 'package:opc_v4/features/podsetnik/data/podsetnik_obligation_repository.dart';
import 'package:opc_v4/features/podsetnik/domain/podsetnik_obligation.dart';

import 'test_bootstrap.dart';

void main() {
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
        'military.honors.notify_authority',
        'social.death_assistance',
        'social.death_assistance.submit_claim',
        'social.pio_refund',
      ]),
    );
  });

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
