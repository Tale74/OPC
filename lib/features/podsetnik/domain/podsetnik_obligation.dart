import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';

enum PodsetnikObligationPhase { preCeremony, postCeremony }

enum PodsetnikObligationKind { atomic, group }

/// Language-neutral rule identity.  Display text is deliberately absent.
class PodsetnikObligationRule {
  const PodsetnikObligationRule({
    required this.stableRuleId,
    required this.phase,
    required this.kind,
    this.parentRuleId,
    this.futureBlocker = false,
  });

  final String stableRuleId;
  final PodsetnikObligationPhase phase;
  final PodsetnikObligationKind kind;
  final String? parentRuleId;
  final bool futureBlocker;
}

class PodsetnikObligation {
  const PodsetnikObligation({
    required this.rule,
    required this.predmetId,
    required this.sourceFingerprint,
    required this.relevant,
    required this.completed,
  });

  final PodsetnikObligationRule rule;
  final int predmetId;
  final String sourceFingerprint;
  final bool relevant;
  final bool completed;

  bool get isAtomic => rule.kind == PodsetnikObligationKind.atomic;
  bool get isGroup => rule.kind == PodsetnikObligationKind.group;
}

/// Pure projection from current PREDMET/IRiU facts to the recovered contract.
/// It does not read or write a database and does not use Serbian display text
/// as identity.
class PodsetnikObligationDeriver {
  const PodsetnikObligationDeriver();

  List<PodsetnikObligationRule> deriveRules({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    bool unresolvedStock = false,
  }) {
    final status = predmet.status.trim().toUpperCase();
    if (status != 'OTVOREN' && status != 'ZATVOREN') {
      return const <PodsetnikObligationRule>[];
    }
    final rules = <PodsetnikObligationRule>[];
    void group(String id, PodsetnikObligationPhase phase) => rules.add(
      PodsetnikObligationRule(
        stableRuleId: id,
        phase: phase,
        kind: PodsetnikObligationKind.group,
      ),
    );
    void child(String id, PodsetnikObligationPhase phase, String parent) =>
        rules.add(
          PodsetnikObligationRule(
            stableRuleId: id,
            phase: phase,
            kind: PodsetnikObligationKind.atomic,
            parentRuleId: parent,
          ),
        );
    void atomic(String id, PodsetnikObligationPhase phase) => rules.add(
      PodsetnikObligationRule(
        stableRuleId: id,
        phase: phase,
        kind: PodsetnikObligationKind.atomic,
      ),
    );

    const pre = PodsetnikObligationPhase.preCeremony;
    const post = PodsetnikObligationPhase.postCeremony;

    final rsPensioner =
        _isYes(predmet.penzionerSrbije) ||
        _canonical(predmet.radniStatus) == 'PENZIONER_SRBIJE';
    final militaryPensioner = _isYes(predmet.vojniPenzioner);
    final firmaPioResponsibility = _isNo(predmet.narucilacRefundira);
    if ((rsPensioner || militaryPensioner) && firmaPioResponsibility) {
      group('social.pio_refund', pre);
      child('social.pio_refund.submit_claim', pre, 'social.pio_refund');
    }
    final married = {
      'OZENJEN',
      'UDATA',
    }.contains(_canonical(predmet.bracnoStanje));
    if (_isYes(predmet.bracniDrugOstvarujePravo) &&
        married &&
        (rsPensioner || militaryPensioner) &&
        firmaPioResponsibility) {
      group('social.family_pension', pre);
      child('social.family_pension.submit_claim', pre, 'social.family_pension');
    }
    if (militaryPensioner && _isYes(predmet.posmrtnaPomoc)) {
      group('social.death_assistance', pre);
      child(
        'social.death_assistance.submit_claim',
        pre,
        'social.death_assistance',
      );
    }
    if (militaryPensioner && _isYes(predmet.vojnePocasti)) {
      atomic('military.honors.notify_authority', pre);
    }

    if (_isYes(predmet.opelo) && _isYes(predmet.obavestitiSvestenika)) {
      group('ceremony.opelo', pre);
      child('ceremony.opelo.notify_priest', pre, 'ceremony.opelo');
    }
    if (_isYes(predmet.opelo) &&
        _hasActiveCategory(iriu, IriuK.kompletZaOpelo)) {
      if (!rules.any((rule) => rule.stableRuleId == 'ceremony.opelo')) {
        group('ceremony.opelo', pre);
      }
      child('ceremony.opelo.prepare_kit', pre, 'ceremony.opelo');
    }

    if (predmet.partePotrebna) {
      atomic('ceremony.parte', pre);
    }

    final categoryRules = <String, String>{
      IriuK.sanduk: 'sanduk',
      IriuK.pokrovGarnitura: 'pokrov_garnitura',
      IriuK.obelezje: 'obelezje',
      IriuK.peskirZaKrst: 'peskir_za_krst',
      IriuK.posmrtneParte: 'posmrtne_parte',
      IriuK.doradaPogrebneOpreme: 'dorada_pogrebne_opreme',
      IriuK.zastitnaIDodatnaOprema: 'zastitna_i_dodatna_oprema',
      IriuK.slika: 'slika',
      IriuK.crnina: 'crnina',
      IriuK.cvece: 'cvece',
    };
    var equipment = false;
    var photo = false;
    var mourning = false;
    var flowers = false;
    for (final row in iriu) {
      if (!_isCurrentOperationalRow(row)) continue;
      final categoryKey = categoryRules[row.interniNaziv];
      if (categoryKey == null) continue;
      switch (categoryKey) {
        case 'slika':
          photo = true;
          break;
        case 'crnina':
          mourning = true;
          break;
        case 'cvece':
          flowers = true;
          break;
        default:
          equipment = true;
          break;
      }
    }
    if (equipment) atomic('goods.equipment', pre);
    if (photo) atomic('goods.photo', pre);
    if (mourning) atomic('goods.mourning', pre);
    if (flowers) atomic('goods.flowers', pre);

    if (predmet.sahranaVanSrbije) {
      atomic('ceremony.international', pre);
    }
    if (predmet.docekPosmrtnihOstataka) {
      atomic('ceremony.reception', pre);
    }
    if (unresolvedStock) {
      atomic('goods.stock', pre);
    }

    final ceremony = predmet.vrstaCeremonije.trim().toUpperCase();
    final urnRelevant =
        (ceremony == 'KREMACIJA' || ceremony == 'KREMACIJA_EKSPRES') &&
        predmet.tipPolaganja.trim().toUpperCase() != 'NAKNADNO';
    if (urnRelevant) {
      group('post.urn_ashes', post);
      child('post.urn_ashes.arrange_placement', post, 'post.urn_ashes');
    }
    return List<PodsetnikObligationRule>.unmodifiable(rules);
  }

  List<PodsetnikObligation> project({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    Map<String, bool> completedByRule = const <String, bool>{},
    bool unresolvedStock = false,
  }) {
    final rules = deriveRules(
      predmet: predmet,
      iriu: iriu,
      unresolvedStock: unresolvedStock,
    );
    return List<PodsetnikObligation>.unmodifiable(
      rules.map((rule) {
        final children = rules.where(
          (candidate) => candidate.parentRuleId == rule.stableRuleId,
        );
        final completed = rule.kind == PodsetnikObligationKind.group
            ? children.isNotEmpty &&
                  children.every(
                    (childRule) =>
                        completedByRule[childRule.stableRuleId] ?? false,
                  )
            : completedByRule[rule.stableRuleId] ?? false;
        return PodsetnikObligation(
          rule: rule,
          predmetId: predmet.id,
          sourceFingerprint: sourceFingerprint(
            rule,
            predmet,
            iriu,
            unresolvedStock,
          ),
          relevant: true,
          completed: completed,
        );
      }),
    );
  }

  String sourceFingerprint(
    PodsetnikObligationRule rule,
    PredmetiData predmet,
    List<IriuData> iriu, [
    bool unresolvedStock = false,
  ]) {
    List<String> categoriesFor(Set<String> names) =>
        iriu
            .where(
              (row) =>
                  names.contains(row.interniNaziv.trim().toUpperCase()) &&
                  _isCurrentOperationalRow(row),
            )
            .map(
              (row) =>
                  '${row.interniNaziv.trim().toUpperCase()}: '
                  '${row.katalogStableArticleId?.trim() ?? ''}',
            )
            .toList()
          ..sort();
    final values = switch (rule.stableRuleId) {
      'social.pio_refund' || 'social.pio_refund.submit_claim' => [
        predmet.penzionerSrbije,
        predmet.vojniPenzioner,
        predmet.radniStatus,
        predmet.narucilacRefundira,
      ],
      'social.family_pension' || 'social.family_pension.submit_claim' => [
        predmet.bracnoStanje,
        predmet.bracniDrugOstvarujePravo,
        predmet.penzionerSrbije,
        predmet.vojniPenzioner,
        predmet.radniStatus,
        predmet.narucilacRefundira,
      ],
      'social.death_assistance' || 'social.death_assistance.submit_claim' => [
        predmet.vojniPenzioner,
        predmet.posmrtnaPomoc,
      ],
      'military.honors.notify_authority' => [
        predmet.vojniPenzioner,
        predmet.vojnePocasti,
      ],
      'ceremony.opelo' || 'ceremony.opelo.notify_priest' => [
        predmet.opelo,
        predmet.obavestitiSvestenika,
        categoriesFor({IriuK.kompletZaOpelo}).join(','),
      ],
      'ceremony.opelo.prepare_kit' => [
        predmet.opelo,
        categoriesFor({IriuK.kompletZaOpelo}).join(','),
      ],
      'ceremony.parte' => [predmet.partePotrebna.toString()],
      'goods.equipment' => [
        categoriesFor({
          IriuK.sanduk,
          IriuK.pokrovGarnitura,
          IriuK.obelezje,
          IriuK.peskirZaKrst,
          IriuK.posmrtneParte,
          IriuK.doradaPogrebneOpreme,
          IriuK.zastitnaIDodatnaOprema,
        }).join(','),
      ],
      'goods.photo' => [
        categoriesFor({IriuK.slika}).join(','),
      ],
      'goods.mourning' => [
        categoriesFor({IriuK.crnina}).join(','),
      ],
      'goods.flowers' => [
        categoriesFor({IriuK.cvece}).join(','),
      ],
      'ceremony.international' => [predmet.sahranaVanSrbije.toString()],
      'ceremony.reception' => [predmet.docekPosmrtnihOstataka.toString()],
      'goods.stock' => [unresolvedStock.toString()],
      'post.urn_ashes' || 'post.urn_ashes.arrange_placement' => [
        predmet.vrstaCeremonije,
        predmet.tipPolaganja,
        predmet.grobljePolaganjaUrne,
      ],
      _ => const <String>[],
    };
    return [
      rule.stableRuleId,
      ...values.map((value) => value.trim().toUpperCase()),
    ].join('|');
  }

  static bool _isYes(String value) => value.trim().toUpperCase() == 'DA';

  static bool _isNo(String value) => value.trim().toUpperCase() == 'NE';

  static String _canonical(String value) => value
      .trim()
      .toUpperCase()
      .replaceAll('Ž', 'Z')
      .replaceAll('Š', 'S')
      .replaceAll('Ć', 'C')
      .replaceAll('Č', 'C')
      .replaceAll('Đ', 'D');

  static bool _isCurrentOperationalRow(IriuData row) =>
      row.poslovniStatus.trim().toUpperCase() != 'NE PRIKAZUJE SE';

  static bool _hasActiveCategory(List<IriuData> rows, String category) =>
      rows.any(
        (row) => row.interniNaziv == category && _isCurrentOperationalRow(row),
      );
}
