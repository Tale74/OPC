import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../../predmeti/core_v2/services/financial_truth_service.dart';
import '../../predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import '../../predmeti/reminders/urna_ashes_reminder_model.dart';

enum PodsetnikObligationPhase { preCeremony, postCeremony }

enum PodsetnikObligationKind { atomic, group }

const String cituljeParentRuleId = 'citulje.parent';
const String posebneObavezeParentRuleId = 'special.manual';
const String manualObligationRulePrefix = 'special.manual.';
const String finansijeParentRuleId = 'finance.parent';
const String platiJkpRacunRuleId = 'finance.pay_jkp_bill';
const String naplatiObavezeRuleId = 'finance.collect_receivable';

String cituljeChildRuleId(String portableOccurrenceId) =>
    'citulje.occurrence.$portableOccurrenceId';

String manualObligationRuleId(String portableId) =>
    '$manualObligationRulePrefix$portableId';

bool isManualObligationRuleId(String value) =>
    value.startsWith(manualObligationRulePrefix) &&
    value.length > manualObligationRulePrefix.length;

/// Language-neutral rule identity.  Display text is deliberately absent.
class PodsetnikObligationRule {
  const PodsetnikObligationRule({
    required this.stableRuleId,
    required this.phase,
    required this.kind,
    this.parentRuleId,
    this.futureBlocker = false,
    this.displayLabel,
    this.portableOccurrenceId,
  });

  final String stableRuleId;
  final PodsetnikObligationPhase phase;
  final PodsetnikObligationKind kind;
  final String? parentRuleId;
  final bool futureBlocker;
  final String? displayLabel;
  final String? portableOccurrenceId;
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

/// Returns the canonical root set used by overview projections. Children are
/// intentionally suppressed so a grouped obligation contributes one entry.
List<PodsetnikObligation> podsetnikOverviewRoots(
  Iterable<PodsetnikObligation> obligations,
) => List<PodsetnikObligation>.unmodifiable(
  obligations.where(
    (item) =>
        item.relevant && item.rule.parentRuleId == null && !item.completed,
  ),
);

/// Text projection used only by the Lista REVIEW BAR. It deliberately keeps
/// the generic root projection, so active CVEĆE, SLIKA, and derived
/// POSEBNE OBAVEZE roots participate without exposing child rows.
String podsetnikReviewBarText(
  Iterable<PodsetnikObligation> obligations,
  int rotationIndex,
) {
  final unfinished = podsetnikOverviewRoots(obligations);
  if (unfinished.isEmpty) return 'OBAVEZE ISPUNJENE';
  return podsetnikReviewBarDisplayLabel(
    unfinished[rotationIndex % unfinished.length].rule,
  );
}

/// Pure projection from current PREDMET/IRiU facts to the recovered contract.
/// It does not read or write a database and does not use Serbian display text
/// as identity.
class PodsetnikObligationDeriver {
  const PodsetnikObligationDeriver();

  static const _predmetIriuTruthService = PredmetIriuTruthService();
  static const _financialTruthService = FinancialTruthService();

  List<PodsetnikObligationRule> deriveRules({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    bool unresolvedStock = false,
    List<PodsetnikObligationRule> additionalRules = const [],
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

    final zaNaplatu = _calculateZaNaplatu(predmet, iriu);
    final platiJkpRacunRelevant =
        predmet.troskoviJkp > 0 && !predmet.jkpPlacaSamostalno;
    final naplatiObavezeRelevant = zaNaplatu > 0;
    if (platiJkpRacunRelevant || naplatiObavezeRelevant) {
      group(finansijeParentRuleId, pre);
      if (platiJkpRacunRelevant) {
        child(platiJkpRacunRuleId, pre, finansijeParentRuleId);
      }
      if (naplatiObavezeRelevant) {
        child(naplatiObavezeRuleId, pre, finansijeParentRuleId);
      }
    }

    final rsPensioner =
        _isYes(predmet.penzionerSrbije) ||
        _canonical(predmet.radniStatus) == 'PENZIONER_SRBIJE';
    final militaryPensioner = _isYes(predmet.vojniPenzioner);
    final firmaPioResponsibility = _isNo(predmet.narucilacRefundira);
    if ((rsPensioner || militaryPensioner) && firmaPioResponsibility) {
      group('social.pio_refund', post);
      child('social.pio_refund.submit_claim', post, 'social.pio_refund');
    }
    final married = {
      'OZENJEN',
      'UDATA',
    }.contains(_canonical(predmet.bracnoStanje));
    if (_isYes(predmet.bracniDrugOstvarujePravo) &&
        married &&
        (rsPensioner || militaryPensioner) &&
        firmaPioResponsibility) {
      group('social.family_pension', post);
      child(
        'social.family_pension.submit_claim',
        post,
        'social.family_pension',
      );
    }
    if (militaryPensioner && _isYes(predmet.posmrtnaPomoc)) {
      group('social.death_assistance', post);
      child(
        'social.death_assistance.submit_claim',
        post,
        'social.death_assistance',
      );
    }
    if (militaryPensioner && _isYes(predmet.vojnePocasti)) {
      group('military.honors', pre);
      child('military.honors.notify_authority', pre, 'military.honors');
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

    final cituljeRows =
        iriu
            .where(
              (row) =>
                  (row.interniNaziv == IriuK.cituljaP ||
                      row.interniNaziv == IriuK.cituljaNo) &&
                  _isCurrentOperationalRow(row) &&
                  row.portableOccurrenceId?.trim().isNotEmpty == true,
            )
            .toList()
          ..sort(
            (left, right) => left.redosled != right.redosled
                ? left.redosled.compareTo(right.redosled)
                : left.id.compareTo(right.id),
          );
    if (cituljeRows.isNotEmpty) {
      group(cituljeParentRuleId, pre);
      final sameTypeCounts = <String, int>{};
      for (final row in cituljeRows) {
        final type = row.interniNaziv;
        sameTypeCounts[type] = (sameTypeCounts[type] ?? 0) + 1;
      }
      final sameTypeIndexes = <String, int>{};
      for (final row in cituljeRows) {
        final occurrence = row.portableOccurrenceId!.trim();
        final type = row.interniNaziv;
        final index = (sameTypeIndexes[type] ?? 0) + 1;
        sameTypeIndexes[type] = index;
        final suffix = sameTypeCounts[type]! > 1 ? ' $index' : '';
        rules.add(
          PodsetnikObligationRule(
            stableRuleId: cituljeChildRuleId(occurrence),
            phase: pre,
            kind: PodsetnikObligationKind.atomic,
            parentRuleId: cituljeParentRuleId,
            displayLabel: '${_cituljaLabel(type)}$suffix',
            portableOccurrenceId: occurrence,
          ),
        );
      }
    }

    final urnRelevant = isUrnaAshesObligationRelevant(
      ceremonyType: predmet.vrstaCeremonije,
      placementType: predmet.tipPolaganja,
    );
    if (urnRelevant) {
      final label = buildUrnaAshesReminderText(
        deceasedFirstName: predmet.ime,
        deceasedLastName: predmet.prezime,
        placementType: predmet.tipPolaganja,
        urnaCemetery: predmet.grobljePolaganjaUrne,
      );
      rules.add(
        PodsetnikObligationRule(
          stableRuleId: 'post.urn_ashes',
          phase: post,
          kind: PodsetnikObligationKind.group,
          displayLabel: label,
        ),
      );
      rules.add(
        PodsetnikObligationRule(
          stableRuleId: 'post.urn_ashes.arrange_placement',
          phase: post,
          kind: PodsetnikObligationKind.atomic,
          parentRuleId: 'post.urn_ashes',
          displayLabel: label,
        ),
      );
    }
    return List<PodsetnikObligationRule>.unmodifiable([
      ...rules,
      ...additionalRules,
    ]);
  }

  List<PodsetnikObligation> project({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    Map<String, bool> completedByRule = const <String, bool>{},
    bool unresolvedStock = false,
    List<PodsetnikObligationRule> additionalRules = const [],
  }) {
    final rules = deriveRules(
      predmet: predmet,
      iriu: iriu,
      unresolvedStock: unresolvedStock,
      additionalRules: additionalRules,
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
      'military.honors' || 'military.honors.notify_authority' => [
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
      finansijeParentRuleId => [
        (predmet.troskoviJkp > 0 && !predmet.jkpPlacaSamostalno).toString(),
        (_calculateZaNaplatu(predmet, iriu) > 0).toString(),
      ],
      platiJkpRacunRuleId => [predmet.troskoviJkp, predmet.jkpPlacaSamostalno],
      naplatiObavezeRuleId => [_calculateZaNaplatu(predmet, iriu)],
      cituljeParentRuleId => [
        iriu
            .where(
              (row) =>
                  (row.interniNaziv == IriuK.cituljaP ||
                      row.interniNaziv == IriuK.cituljaNo) &&
                  _isCurrentOperationalRow(row) &&
                  row.portableOccurrenceId?.trim().isNotEmpty == true,
            )
            .map(
              (row) =>
                  '${row.interniNaziv}:${row.portableOccurrenceId!.trim()}',
            )
            .toList()
          ..sort(),
      ],
      _ when rule.stableRuleId.startsWith('citulje.occurrence.') => [
        rule.portableOccurrenceId ?? '',
        rule.stableRuleId,
      ],
      _ when isManualObligationRuleId(rule.stableRuleId) => [
        rule.displayLabel ?? '',
      ],
      'post.urn_ashes' || 'post.urn_ashes.arrange_placement' => [
        predmet.vrstaCeremonije,
        predmet.tipPolaganja,
        predmet.grobljePolaganjaUrne,
      ],
      _ => const <String>[],
    };
    return [
      rule.stableRuleId,
      ...values.map((value) => value.toString().trim().toUpperCase()),
    ].join('|');
  }

  double _calculateZaNaplatu(PredmetiData predmet, List<IriuData> iriu) {
    final truth = _predmetIriuTruthService.evaluate(
      predmet: predmet,
      storedRows: iriu,
    );
    final robaIUsluge = _financialTruthService
        .buildRobaIUsluge(truth)
        .robaIUsluge;
    final refundacijaPio =
        predmet.penzionerSrbije == 'DA' &&
            predmet.narucilacRefundira != 'DA' &&
            predmet.refundacijaPio > 0
        ? predmet.refundacijaPio
        : 0.0;
    return _financialTruthService.calculateZaNaplatu(
      robaIUsluge: robaIUsluge,
      refundacijaPio: refundacijaPio,
      avans: predmet.avans,
      troskoviJkp: predmet.troskoviJkp,
      jkpPlacaSamostalno: predmet.jkpPlacaSamostalno,
      popust: predmet.popust,
    );
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

  static String _cituljaLabel(String type) => switch (type) {
    IriuK.cituljaP => 'ČITULJA POLITIKA',
    IriuK.cituljaNo => 'ČITULJA NOVOSTI',
    _ => 'ČITULJA',
  };
}

String podsetnikObligationDisplayLabel(PodsetnikObligationRule rule) {
  final concrete = rule.displayLabel?.trim();
  if (concrete != null && concrete.isNotEmpty) return concrete;
  return switch (rule.stableRuleId) {
    'ceremony.opelo' => 'OPELO',
    'ceremony.opelo.notify_priest' => 'Obavestiti sveštenika',
    'ceremony.opelo.prepare_kit' => 'Spremiti komplet za opelo',
    'social.pio_refund' => 'REFUNDACIJA PIO',
    'social.pio_refund.submit_claim' => 'Podneti zahtev PIO',
    'social.family_pension' => 'PORODIČNA PENZIJA',
    'social.family_pension.submit_claim' =>
      'Podneti zahtev za porodičnu penziju',
    'social.death_assistance' => 'POSMRTNA POMOĆ',
    'social.death_assistance.submit_claim' =>
      'Podneti zahtev za posmrtnu pomoć',
    'military.honors' => 'VOJNE POČASTI',
    'military.honors.notify_authority' => 'OBAVESTITI NADLEŽNU SLUŽBU',
    'ceremony.parte' => 'PARTE',
    'goods.equipment' => 'OPREMA',
    'goods.photo' => 'SLIKA',
    'goods.mourning' => 'CRNINA',
    'goods.flowers' => 'CVEĆE',
    'ceremony.international' => 'Spremiti međunarodna dokumenta',
    'ceremony.reception' => 'Preuzeti posmrtne ostatke',
    'goods.stock' => 'Razreši stanje robe',
    finansijeParentRuleId => 'FINANSIJE',
    platiJkpRacunRuleId => 'PLATITI RAČUN',
    naplatiObavezeRuleId => 'NAPLATITI OBAVEZE',
    'post.urn_ashes' => 'URNA / PEPEO',
    'post.urn_ashes.arrange_placement' => 'Organizovati polaganje urne',
    posebneObavezeParentRuleId => 'POSEBNE OBAVEZE',
    cituljeParentRuleId => 'ČITULJA',
    _ => rule.stableRuleId,
  };
}

/// REVIEW BAR-only label projection. Full URNA wording remains available
/// through [podsetnikObligationDisplayLabel] to PODSETNIK and LISTA outputs.
String podsetnikReviewBarDisplayLabel(PodsetnikObligationRule rule) {
  if (rule.stableRuleId == 'post.urn_ashes' ||
      rule.stableRuleId == 'post.urn_ashes.arrange_placement') {
    return 'ZAKAZATI POLAGANJE URNE';
  }
  return podsetnikObligationDisplayLabel(rule);
}
