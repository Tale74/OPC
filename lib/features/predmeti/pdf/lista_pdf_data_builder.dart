import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import '../../../core/utils/document_text_codec.dart';
import '../core_v2/models/iriu_truth_models.dart';
import '../core_v2/services/financial_truth_service.dart';
import '../core_v2/services/predmet_iriu_truth_service.dart';
import '../../podsetnik/domain/podsetnik_obligation.dart';
import 'memorandum_logo.dart';

class ListaPdfPreparedData {
  const ListaPdfPreparedData({
    required this.predmet,
    required this.firma,
    required this.app,
    required this.datumIzvoza,
    required this.savetnikIme,
    required this.dokumentVerzija,
    required this.preminuloSection,
    required this.payerSection,
    required this.ceremonySection,
    required this.iriuItems,
    required this.finansijskiRedovi,
    required this.napomene,
    required this.partePreview,
    required this.parteSimbol,
    this.podsetnikChecklist = const <ListaPdfChecklistItem>[],
  });

  final PredmetiData predmet;
  final FirmaPodaciData firma;
  final AppPodesavanjaData app;
  final DateTime datumIzvoza;
  final String savetnikIme;
  final String dokumentVerzija;
  final ListaPdfSectionData preminuloSection;
  final ListaPdfSectionData payerSection;
  final ListaPdfSectionData ceremonySection;
  final List<ListaPdfIriuRenderItem> iriuItems;
  final List<ListaPdfLabelValue> finansijskiRedovi;
  final List<ListaPdfDocumentNote> napomene;
  final String partePreview;
  final String parteSimbol;
  final List<ListaPdfChecklistItem> podsetnikChecklist;
}

class ListaPdfChecklistItem {
  const ListaPdfChecklistItem({
    required this.label,
    this.group = false,
    this.parentLabel,
    this.context = const <String>[],
  });

  final String label;
  final bool group;
  final String? parentLabel;
  final List<String> context;
}

class ListaPdfLabelValue {
  const ListaPdfLabelValue(
    this.label,
    this.value, {
    this.kind = ListaPdfRowKind.normal,
  });

  final String label;
  final String value;
  final ListaPdfRowKind kind;
}

class ListaPdfSectionData {
  const ListaPdfSectionData({
    required this.title,
    this.columns = const <List<ListaPdfLabelValue>>[],
    this.panels = const <ListaPdfSectionPanel>[],
  });

  final String title;
  final List<List<ListaPdfLabelValue>> columns;
  final List<ListaPdfSectionPanel> panels;
}

class ListaPdfSectionPanel {
  const ListaPdfSectionPanel({required this.title, required this.columns});

  final String title;
  final List<List<ListaPdfLabelValue>> columns;
}

enum ListaPdfRowKind { normal, divider, emphasis }

class ListaPdfDocumentNote {
  const ListaPdfDocumentNote(this.label, this.value, {this.groupTitle});

  final String label;
  final String value;
  final String? groupTitle;
}

class ListaPdfIriuRenderItem {
  const ListaPdfIriuRenderItem({
    required this.naziv,
    required this.kom,
    required this.iznos,
    this.tekstTrake,
  });

  final String naziv;
  final String kom;
  final double iznos;
  final String? tekstTrake;

  int get estimatedUnits {
    var units = 1;
    if (naziv.length > 34) units += 1;
    if (naziv.length > 68) units += 1;
    final ribbonLength = tekstTrake?.length ?? 0;
    if (ribbonLength > 36) units += 1;
    if (ribbonLength > 72) units += 1;
    if (ribbonLength > 108) units += 1;
    if (kom.isNotEmpty) units += 1;
    if (kom.length > 24) units += 1;
    return units;
  }
}

class ListaPdfDataBuilder {
  const ListaPdfDataBuilder();

  ListaPdfPreparedData build({
    required PredmetiData predmet,
    required List<IriuData> iriuStavke,
    required FirmaPodaciData firma,
    required AppPodesavanjaData app,
    required KorisniciData? savetnik,
    String? portableSavetnikName,
    List<PodsetnikObligationRule> additionalObligations = const [],
  }) {
    final truthSnapshot = const PredmetIriuTruthService().evaluate(
      predmet: predmet,
      storedRows: iriuStavke,
      preserveInputOrder: true,
    );
    final finansijskaOsnova = const FinancialTruthService().buildRobaIUsluge(
      truthSnapshot,
    );
    final savetnikIme = documentTextCodec.normalize(
      resolveSavetnikDisplayName(
        localUser: savetnik,
        portableName: portableSavetnikName,
      ),
    );
    final iriuItems = _buildListaIriuItems(truthSnapshot)
        .map(
          (row) => ListaPdfIriuRenderItem(
            naziv: row.storedRow.nazivPrikaz.trim(),
            kom: row.storedRow.kom.trim(),
            iznos: _safeDouble(row.storedRow.iznos),
            tekstTrake: row.storedRow.interniNaziv == IriuK.cvece
                ? row.storedRow.tekstTrake?.trim()
                : null,
          ),
        )
        .toList(growable: false);
    final finansijskiRedovi = _buildFinancialRows(
      predmet: predmet,
      finansijskaOsnova: finansijskaOsnova,
    );
    final visibleIriu = truthSnapshot
        .rowsVisibleToDerivative(
          excludedReasons: const <IriuDerivativeExclusion>{
            IriuDerivativeExclusion.notOperationallyActive,
          },
        )
        .map((row) => row.storedRow)
        .toList(growable: false);

    return ListaPdfPreparedData(
      predmet: predmet,
      firma: firma,
      app: app,
      datumIzvoza: DateTime.now(),
      savetnikIme: savetnikIme,
      dokumentVerzija: 'v${predmet.verzija}',
      preminuloSection: _buildPreminuloSection(predmet),
      payerSection: _buildPayerSection(predmet),
      ceremonySection: _buildCeremonySection(predmet),
      iriuItems: iriuItems,
      finansijskiRedovi: finansijskiRedovi,
      napomene: _buildNotes(predmet),
      partePreview: _buildPartePreviewText(predmet),
      parteSimbol: _parteSimbolNaziv(predmet.simbol),
      podsetnikChecklist: _buildPodsetnikChecklist(
        predmet: predmet,
        iriu: iriuStavke,
        visibleIriu: visibleIriu,
        finansijskiRedovi: finansijskiRedovi,
        additionalObligations: additionalObligations,
      ),
    );
  }
}

List<ListaPdfChecklistItem> _buildPodsetnikChecklist({
  required PredmetiData predmet,
  required List<IriuData> iriu,
  required List<IriuData> visibleIriu,
  required List<ListaPdfLabelValue> finansijskiRedovi,
  required List<PodsetnikObligationRule> additionalObligations,
}) {
  final rules = const PodsetnikObligationDeriver().deriveRules(
    predmet: predmet,
    iriu: iriu,
    additionalRules: additionalObligations,
  );
  final labels = <String, String>{};
  for (final rule in rules) {
    final label = podsetnikPresentationLabel(
      rule,
      urnPlacementType: predmet.tipPolaganja,
    ).trim();
    // The shared resolver intentionally falls back to stable identity for
    // unknown rules. LISTA is a business document, so never print that key.
    final technicalLiteral =
        label == rule.stableRuleId ||
        RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$').hasMatch(label);
    if (label.isNotEmpty && !technicalLiteral) {
      labels[rule.stableRuleId] = label;
    }
  }
  final items = <ListaPdfChecklistItem>[];
  for (final rule in rules) {
    final label = labels[rule.stableRuleId];
    if (label == null) continue;
    final parentLabel = rule.parentRuleId == null
        ? null
        : labels[rule.parentRuleId!];
    final syntheticChild = rule.parentRuleId == null
        ? podsetnikSyntheticChildLabel(rule.stableRuleId)
        : null;
    final context = _obligationContext(
      rule: rule,
      predmet: predmet,
      iriu: visibleIriu,
      finansijskiRedovi: finansijskiRedovi,
    );
    if (syntheticChild != null) {
      items.add(ListaPdfChecklistItem(label: label, group: true));
      items.add(
        ListaPdfChecklistItem(
          label: syntheticChild,
          parentLabel: label,
          context: context,
        ),
      );
      continue;
    }
    items.add(
      ListaPdfChecklistItem(
        label: label,
        group: rule.kind == PodsetnikObligationKind.group,
        parentLabel: parentLabel,
        context: context,
      ),
    );
  }
  return List<ListaPdfChecklistItem>.unmodifiable(items);
}

List<String> _obligationContext({
  required PodsetnikObligationRule rule,
  required PredmetiData predmet,
  required List<IriuData> iriu,
  required List<ListaPdfLabelValue> finansijskiRedovi,
}) {
  List<String> articleDetails(Iterable<IriuData> rows) => rows
      .map((row) {
        final name = row.nazivPrikaz.trim();
        if (name.isEmpty) return '';
        final quantity = row.kom.trim();
        return quantity.isEmpty ? name : '$name — Kom: $quantity';
      })
      .where((detail) => detail.isNotEmpty)
      .toList(growable: false);

  List<IriuData> rowsFor(Set<String> categories) => iriu
      .where(
        (row) =>
            categories.contains(row.interniNaziv.trim().toUpperCase()) &&
            row.poslovniStatus.trim().toUpperCase() != 'NE PRIKAZUJE SE',
      )
      .toList(growable: false);

  String? financeValue(String label) => finansijskiRedovi
      .where((row) => row.label == label)
      .map((row) => row.value)
      .firstOrNull;

  switch (rule.stableRuleId) {
    case 'goods.equipment':
      return articleDetails(
        rowsFor({
          IriuK.sanduk,
          IriuK.pokrovGarnitura,
          IriuK.obelezje,
          IriuK.peskirZaKrst,
          IriuK.posmrtneParte,
          IriuK.doradaPogrebneOpreme,
          IriuK.zastitnaIDodatnaOprema,
        }),
      );
    case 'goods.photo':
      return articleDetails(rowsFor({IriuK.slika}));
    case 'goods.mourning':
      return articleDetails(rowsFor({IriuK.crnina}));
    case 'goods.flowers':
      return rowsFor({IriuK.cvece})
          .map((row) {
            final name = row.nazivPrikaz.trim();
            if (name.isEmpty) return '';
            final ribbon = row.tekstTrake?.trim() ?? '';
            return ribbon.isEmpty ? name : '$name\nTraka: $ribbon';
          })
          .where((detail) => detail.isNotEmpty)
          .toList(growable: false);
    case 'ceremony.opelo.notify_priest':
      return <String>[
        if (predmet.opeloMesto.trim().isNotEmpty)
          'Mesto opela: ${_opeloMestoLabel(predmet.opeloMesto)}',
        if (predmet.vremeOpela.trim().isNotEmpty)
          'Vreme opela: ${predmet.vremeOpela.trim()}',
      ];
    case 'ceremony.opelo.prepare_kit':
      return articleDetails(rowsFor({IriuK.kompletZaOpelo}));
    case platiJkpRacunRuleId:
      final value = financeValue('TROŠKOVI JKP');
      return value == null ? const [] : <String>['Iznos računa: $value'];
    case naplatiObavezeRuleId:
      final value = financeValue('ZA NAPLATU');
      return value == null ? const [] : <String>['Iznos za naplatu: $value'];
    case 'post.urn_ashes.arrange_placement':
      final location = predmet.grobljePolaganjaUrne.trim();
      return location.isEmpty
          ? const []
          : <String>['Groblje polaganja urne: $location'];
    case 'ceremony.international':
      return <String>[
        if (predmet.svisZemlja.trim().isNotEmpty)
          'Zemlja: ${predmet.svisZemlja.trim()}',
        if (predmet.svisGrad.trim().isNotEmpty)
          'Grad: ${predmet.svisGrad.trim()}',
      ];
    case 'ceremony.reception':
      return <String>[
        if (predmet.docekMesto.trim().isNotEmpty)
          'Mesto dočeka: ${predmet.docekMesto.trim()}',
        if (predmet.docekVreme.trim().isNotEmpty)
          'Vreme dočeka: ${predmet.docekVreme.trim()}',
      ];
    default:
      final occurrenceId = rule.portableOccurrenceId;
      if (occurrenceId != null) {
        return articleDetails(
          iriu.where((row) => row.portableOccurrenceId == occurrenceId),
        );
      }
      return const <String>[];
  }
}

List<IriuTruthRow> _buildListaIriuItems(
  PredmetIriuTruthSnapshot truthSnapshot,
) {
  return truthSnapshot.rowsVisibleToDerivative(
    excludedReasons: const <IriuDerivativeExclusion>{
      IriuDerivativeExclusion.notOperationallyActive,
    },
  );
}

ListaPdfSectionData _buildPreminuloSection(PredmetiData predmet) {
  final fields = _compactLabelValues([
    ListaPdfLabelValue('Srednje ime', predmet.srednje),
    ListaPdfLabelValue('Devojačko prezime', predmet.devojackoPrezime),
    ListaPdfLabelValue('JMBG', predmet.jmbg),
    ListaPdfLabelValue('Pol', _polLabel(predmet.pol)),
    ListaPdfLabelValue('Datum rođenja', predmet.datumRodjenja),
    ListaPdfLabelValue('Mesto rođenja', predmet.mestoRodjenja),
    ListaPdfLabelValue('Datum smrti', predmet.datumSmrti),
    ListaPdfLabelValue('Mesto smrti', predmet.mestoSmrti),
    ListaPdfLabelValue('Adresa', predmet.adresa),
    ListaPdfLabelValue('Uzrok smrti', _uzrokSmrtiLabel(predmet.uzrokSmrti)),
    ListaPdfLabelValue('Ime oca', predmet.imeOca),
    ListaPdfLabelValue('Ime majke', predmet.imeMajke),
    ListaPdfLabelValue(
      'Bračno stanje',
      _bracnoStanjeLabel(predmet.bracnoStanje),
    ),
    ListaPdfLabelValue(
      'Bračni drug',
      _joinNonEmpty([predmet.bracniDrugIme, predmet.bracniDrugPrezime]),
    ),
    ListaPdfLabelValue('Bračni drug JMBG', predmet.bracniDrugJmbg),
    ListaPdfLabelValue(
      'Bračni drug devojačko prezime',
      predmet.bracniDrugDevojacko,
    ),
    if (predmet.penzionerSrbije == 'DA')
      const ListaPdfLabelValue('Penzioner Srbije', 'DA'),
    if (predmet.vojniPenzioner == 'DA')
      const ListaPdfLabelValue('Vojni penzioner', 'DA'),
    if (predmet.vojnePocasti == 'DA')
      const ListaPdfLabelValue('Vojne počasti', 'DA'),
    if (predmet.posmrtnaPomoc == 'DA')
      const ListaPdfLabelValue('Posmrtna pomoć', 'DA'),
  ]);

  return ListaPdfSectionData(
    title: 'PREMINULO LICE: ${_upperName(_displayPreminuloName(predmet))}',
    columns: _splitIntoColumns(fields, 3),
  );
}

ListaPdfSectionData _buildPayerSection(PredmetiData predmet) {
  final samePayer = predmet.naruIstiZaJkp;
  final primaryType = _platiocNaziv(predmet.naruTip);
  final jkpType = samePayer ? primaryType : _platiocNaziv(predmet.jkpTip);

  if (samePayer) {
    return ListaPdfSectionData(
      title: 'PLATILAC: ZAJEDNIČKI PLATILAC ($primaryType)',
      panels: <ListaPdfSectionPanel>[
        ListaPdfSectionPanel(
          title: 'Roba i usluge + JKP troškovi',
          columns: _splitIntoColumns(_buildPrimaryPayerFields(predmet), 3),
        ),
      ],
    );
  }

  return ListaPdfSectionData(
    title: 'PLATILAC: ROBA I USLUGE ($primaryType) / JKP TROŠKOVI ($jkpType)',
    panels: <ListaPdfSectionPanel>[
      ListaPdfSectionPanel(
        title: 'Roba i usluge',
        columns: _splitIntoColumns(_buildPrimaryPayerFields(predmet), 2),
      ),
      ListaPdfSectionPanel(
        title: 'JKP troškovi',
        columns: _splitIntoColumns(_buildJkpPayerFields(predmet), 2),
      ),
    ],
  );
}

ListaPdfSectionData _buildCeremonySection(PredmetiData predmet) {
  final ceremonyType = _vrstaCeremonijeNaziv(
    predmet.vrstaCeremonije,
  ).toUpperCase();
  final isKremacija = _isKremacija(predmet.vrstaCeremonije);
  final mozeOpelo = _mozeOpelo(predmet.vrstaCeremonije);
  final imaLokalitetUrne = _tipPolaganjaSaLokalitetom(predmet.tipPolaganja);
  final prikaziPostojeceGrobnoMesto =
      !isKremacija &&
      predmet.grobnoMesto == 'POSTOJECE' &&
      (predmet.tipGrobnogMesta == 'GROB' ||
          predmet.tipGrobnogMesta == 'GROBNICA');
  final fields = _compactLabelValues([
    ListaPdfLabelValue('Groblje', predmet.groblje),
    ListaPdfLabelValue('Tip groblja', _tipGrobljaNaziv(predmet.tipGroblja)),
    ListaPdfLabelValue('Datum ceremonije', predmet.datumCeremonije),
    ListaPdfLabelValue('Vreme ceremonije', predmet.vremeCeremonije),
    if (!isKremacija) ...[
      ListaPdfLabelValue(
        'Grobno mesto',
        _grobnoMestoNaziv(predmet.grobnoMesto),
      ),
      ListaPdfLabelValue(
        'Tip grobnog mesta',
        _tipGrobnogMestaNaziv(predmet.tipGrobnogMesta),
      ),
    ],
    if (prikaziPostojeceGrobnoMesto) ...[
      ListaPdfLabelValue('Parcela', predmet.parcela),
      ListaPdfLabelValue('Broj groba', predmet.grobBroj),
      ListaPdfLabelValue('Red', predmet.redGrob),
      ListaPdfLabelValue('NPK', predmet.npk),
    ],
    if (isKremacija) ...[
      ListaPdfLabelValue(
        'Groblje za polaganje urne',
        predmet.grobljePolaganjaUrne,
      ),
      ListaPdfLabelValue('Šifra urne', predmet.urnaSifra),
      ListaPdfLabelValue(
        'Tip polaganja urne',
        _tipPolaganjaNaziv(predmet.tipPolaganja),
      ),
    ],
    if (imaLokalitetUrne) ...[
      ListaPdfLabelValue('Parcela', predmet.urnaParcela),
      ListaPdfLabelValue('Broj', predmet.urnaBroj),
      ListaPdfLabelValue('Red', predmet.urnaRed),
      ListaPdfLabelValue('NPK', predmet.urnaNpk),
    ],
    if (mozeOpelo)
      ListaPdfLabelValue('Opelo', predmet.opelo == 'DA' ? 'DA' : 'NE'),
    if (mozeOpelo && predmet.opelo == 'DA') ...[
      ListaPdfLabelValue('Mesto opela', _opeloMestoLabel(predmet.opeloMesto)),
      ListaPdfLabelValue('Vreme opela', predmet.vremeOpela),
    ],
    if (mozeOpelo && predmet.opelo != 'DA')
      ListaPdfLabelValue('Vreme ispraćaja', predmet.vremeIspracaja),
    if (predmet.sahranaVanSrbije) ...[
      const ListaPdfLabelValue('Sahrana van Srbije', 'DA'),
      ListaPdfLabelValue('Zemlja', predmet.svisZemlja),
      ListaPdfLabelValue('Grad', predmet.svisGrad),
    ],
    if (predmet.docekPosmrtnihOstataka) ...[
      const ListaPdfLabelValue('Doček posmrtnih ostataka', 'DA'),
      ListaPdfLabelValue('Mesto dočeka', predmet.docekMesto),
      ListaPdfLabelValue('Vreme dočeka', predmet.docekVreme),
    ],
  ]);

  return ListaPdfSectionData(
    title: 'POGREBNA CEREMONIJA: $ceremonyType',
    columns: _splitIntoColumns(fields, 3),
  );
}

List<ListaPdfLabelValue> _buildFinancialRows({
  required PredmetiData predmet,
  required FinancialTruthBasis finansijskaOsnova,
}) {
  final robaIUsluge = _safeDouble(finansijskaOsnova.robaIUsluge);
  final prikazRefundacije = predmet.penzionerSrbije == 'DA';
  final refundacijaPio = _safeDouble(predmet.refundacijaPio);
  final avans = _safeDouble(predmet.avans);
  final troskoviJkp = _safeDouble(predmet.troskoviJkp);
  final popust = _safeDouble(predmet.popust);
  final refundacijaAktivna =
      prikazRefundacije &&
      predmet.narucilacRefundira != 'DA' &&
      refundacijaPio > 0;
  final refundacijaZaObracun = refundacijaAktivna ? refundacijaPio : 0.0;
  final posleRefundacije = robaIUsluge - refundacijaZaObracun;
  final jkpObavezaPlatioca = !predmet.jkpPlacaSamostalno && troskoviJkp > 0;
  final ostatak = avans > 0 ? posleRefundacije - avans : posleRefundacije;
  final saJkp = ostatak + (jkpObavezaPlatioca ? troskoviJkp : 0.0);
  final zaNaplatu = saJkp - popust;

  final rows = <ListaPdfLabelValue>[
    ListaPdfLabelValue('ROBA I USLUGE', formatMoneyRsd(robaIUsluge)),
  ];

  if (refundacijaAktivna) {
    rows.add(
      ListaPdfLabelValue(
        'REFUNDACIJA PIO',
        _formatDeductionMoney(refundacijaPio),
      ),
    );
    rows.add(ListaPdfLabelValue('DOPLATA', formatMoneyRsd(posleRefundacije)));
  }
  if (avans > 0) {
    rows.add(ListaPdfLabelValue('AVANS', _formatDeductionMoney(avans)));
    rows.add(ListaPdfLabelValue('OSTATAK', formatMoneyRsd(ostatak)));
  }
  if (jkpObavezaPlatioca) {
    rows.add(ListaPdfLabelValue('TROŠKOVI JKP', formatMoneyRsd(troskoviJkp)));
  }
  if (popust > 0) {
    rows.add(ListaPdfLabelValue('UKUPNO', formatMoneyRsd(saJkp)));
    rows.add(ListaPdfLabelValue('POPUST', formatMoneyRsd(popust)));
  }
  rows.add(const ListaPdfLabelValue('', '', kind: ListaPdfRowKind.divider));
  rows.add(
    ListaPdfLabelValue(
      'ZA NAPLATU',
      formatMoneyRsd(zaNaplatu),
      kind: ListaPdfRowKind.emphasis,
    ),
  );

  return List<ListaPdfLabelValue>.unmodifiable(rows);
}

List<ListaPdfDocumentNote> _buildNotes(PredmetiData predmet) {
  final opstaNapomena = predmet.napomena.trim();
  if (opstaNapomena.isEmpty) return const <ListaPdfDocumentNote>[];
  return List<ListaPdfDocumentNote>.unmodifiable([
    ListaPdfDocumentNote('NAPOMENA', opstaNapomena),
  ]);
}

double _safeDouble(double? value) {
  if (value == null || value.isNaN || value.isInfinite) {
    return 0.0;
  }
  return value;
}

String _formatDeductionMoney(double value) {
  final normalized = _safeDouble(value);
  if (normalized <= 0) {
    return formatMoneyRsd(normalized);
  }
  return '-${formatMoneyRsd(normalized)}';
}

String _humanizeCode(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
    return trimmed;
  }
  final spaced = trimmed.toLowerCase().replaceAll('_', ' ');
  return toTitleCaseWords(spaced);
}

String _buildPartePreviewText(PredmetiData d) {
  final lines = <String>[];
  final normalizedTitula = normalizeText(d.titula);
  final normalizedNadimak = normalizeText(d.nadimak);
  final normalizedZanimanje = normalizeText(d.zanimanje);
  final normalizedCin = normalizeText(d.cin);
  final normalizedOzalosceni = normalizeText(d.ozaloseni);

  lines.add(d.pol == 'Z' ? 'Naša voljena' : 'Naš voljeni');

  final imeParts = <String>[];
  if (d.titulaIspred && normalizedTitula.isNotEmpty) {
    imeParts.add(normalizedTitula);
  }
  if (d.ime.isNotEmpty) imeParts.add(d.ime);
  if (d.srednjeNaParti && d.srednje.isNotEmpty) {
    imeParts.add(d.srednje);
  }
  if (d.nadimakNaParti && !d.nadimakCrtica && normalizedNadimak.isNotEmpty) {
    imeParts.add('"$normalizedNadimak"');
  }
  if (d.prezime.isNotEmpty) imeParts.add(d.prezime);
  if (d.nadimakNaParti && d.nadimakCrtica && normalizedNadimak.isNotEmpty) {
    imeParts.add('- $normalizedNadimak');
  }
  if (!d.titulaIspred && normalizedTitula.isNotEmpty) {
    imeParts.add(normalizedTitula);
  }
  if (imeParts.isNotEmpty) {
    lines.add(imeParts.join(' '));
  }

  if (d.zanimanjeNaParti && normalizedZanimanje.isNotEmpty) {
    lines.add(normalizedZanimanje);
  }
  if (d.cinNaParti && d.vojniPenzioner == 'DA' && normalizedCin.isNotEmpty) {
    lines.add(normalizedCin);
  }

  final godRodj = _extractYear(d.datumRodjenja);
  final godSmrti = _extractYear(d.datumSmrti);
  if (godRodj.isNotEmpty || godSmrti.isNotEmpty) {
    lines.add('$godRodj — $godSmrti.');
  }

  if (d.datumSmrti.isNotEmpty) {
    final glagol = d.pol == 'Z' ? 'preminula je' : 'preminuo je';
    lines.add('$glagol ${_formatParteDate(d.datumSmrti)}.');
  }

  if (d.datumCeremonije.isNotEmpty && d.groblje.isNotEmpty) {
    final vrsta = _vrstaOpisParte(d.vrstaCeremonije);
    final dan = _dayOfWeek(d.datumCeremonije);
    final datum = _formatParteDate(d.datumCeremonije);
    final vreme = formatTimeForSentence(d.vremeCeremonije);
    final groblje = toTitleCaseWords(d.groblje);
    lines.add('$vrsta je u $dan, $datum u $vreme na groblju $groblje.');
  }

  if (d.opelo == 'DA' && d.vremeOpela.isNotEmpty) {
    final vreme = formatTimeForSentence(d.vremeOpela);
    if (d.opeloMesto.isNotEmpty) {
      lines.add(
        'Opelo počinje u $vreme u ${_opeloMestoLocativ(d.opeloMesto)}.',
      );
    } else {
      lines.add('Opelo počinje u $vreme.');
    }
  } else if (d.opelo != 'DA' && d.vremeIspracaja.isNotEmpty) {
    lines.add('Ispraćaj počinje u ${formatTimeForSentence(d.vremeIspracaja)}.');
  }

  lines.add('Ožalošćeni:');
  if (normalizedOzalosceni.isNotEmpty) {
    lines.add(normalizedOzalosceni);
  }

  final joined = lines.join('\n');
  return d.pismo == 'CIRILICA' ? transliterateLatinToCyrillic(joined) : joined;
}

String _extractYear(String datum) {
  if (datum.isEmpty) return '';
  final parts = datum.split('.');
  if (parts.length >= 3 && parts[2].length == 4) return parts[2];
  if (datum.length == 4) return datum;
  return '';
}

String _formatParteDate(String datum) {
  if (datum.isEmpty) return '';
  final parts = datum.split('.');
  if (parts.length < 3) return datum;
  final day = int.tryParse(parts[0]) ?? 0;
  final month = int.tryParse(parts[1]) ?? 0;
  final year = parts[2];
  const meseci = [
    '',
    'januara',
    'februara',
    'marta',
    'aprila',
    'maja',
    'juna',
    'jula',
    'avgusta',
    'septembra',
    'oktobra',
    'novembra',
    'decembra',
  ];
  final mesec = (month >= 1 && month <= 12) ? meseci[month] : '';
  return '$day. $mesec $year. godine';
}

String _dayOfWeek(String datum) {
  if (datum.isEmpty) return '';
  final parts = datum.split('.');
  if (parts.length < 3) return '';
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return '';
  try {
    final dt = DateTime(year, month, day);
    const dani = [
      'ponedeljak',
      'utorak',
      'sreda',
      'četvrtak',
      'petak',
      'subota',
      'nedelja',
    ];
    return dani[dt.weekday - 1];
  } catch (_) {
    return '';
  }
}

String _opeloMestoLocativ(String s) {
  return switch (s.toUpperCase().trim()) {
    'KAPELA NA GROBLJU' => 'kapeli na groblju',
    'CRKVA NA GROBLJU' => 'crkvi na groblju',
    'U PORODIČNOM DOMU' => 'porodičnom domu',
    'KOD GROBNOG MESTA' => 'kod grobnog mesta',
    _ => toTitleCaseWords(s),
  };
}

String _vrstaOpisParte(String vrsta) {
  return switch (vrsta) {
    'SAHRANA' || 'SAHRANA_EKSPRES' => 'Sahrana',
    'KREMACIJA' || 'KREMACIJA_EKSPRES' => 'Kremacija',
    'SMESTAJ_URNE' => 'Smeštaj urne',
    'RASIPANJE_PEPELA' => 'Rasipanje pepela',
    _ => 'Ceremonija',
  };
}

String _parteSimbolNaziv(String simbol) {
  return switch (simbol) {
    'PRAVOSLAVNI_KRST_SVETOSAVSKI' => 'Svetosavski krst',
    'PRAVOSLAVNI_KRST_TROCKI' => 'Običan krst',
    'RIMOKATOLICKI_KRST' => 'Katolički krst',
    'POLUMESEC' => 'Polumesec',
    'DAVIDOVA_ZVEZDA' => 'Davidova zvezda',
    'SLOBODAN_IZBOR' => 'Slobodan izbor',
    'BEZ_SIMBOLA' => '',
    _ => _humanizeCode(simbol),
  };
}

List<List<ListaPdfLabelValue>> _splitIntoColumns(
  List<ListaPdfLabelValue> values,
  int columnCount,
) {
  final compact = _compactLabelValues(values);
  if (compact.isEmpty) return const <List<ListaPdfLabelValue>>[];

  final safeColumnCount = columnCount < 1 ? 1 : columnCount;
  final normalizedCount = compact.length < safeColumnCount
      ? compact.length
      : safeColumnCount;
  final perColumn = (compact.length / normalizedCount).ceil();

  final columns = <List<ListaPdfLabelValue>>[];
  for (var i = 0; i < compact.length; i += perColumn) {
    final end = (i + perColumn) > compact.length
        ? compact.length
        : i + perColumn;
    columns.add(List<ListaPdfLabelValue>.unmodifiable(compact.sublist(i, end)));
  }
  return List<List<ListaPdfLabelValue>>.unmodifiable(columns);
}

List<ListaPdfLabelValue> _compactLabelValues(List<ListaPdfLabelValue> values) {
  return values
      .where((value) => value.value.trim().isNotEmpty)
      .toList(growable: false);
}

List<ListaPdfLabelValue> _buildPrimaryPayerFields(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') {
    return _compactLabelValues([
      ListaPdfLabelValue('Naziv pravnog lica', predmet.naruPlNaziv),
      ListaPdfLabelValue('Adresa', predmet.naruPlAdresa),
      ListaPdfLabelValue('PIB', predmet.naruPlPib),
      ListaPdfLabelValue('Matični broj', predmet.naruPlMb),
      ListaPdfLabelValue('Odgovorno lice', predmet.naruPlOdgovornoLice),
      ListaPdfLabelValue('Telefon 1', predmet.naruPlTelefon1),
      ListaPdfLabelValue('Telefon 2', predmet.naruPlTelefon2),
      ListaPdfLabelValue('Email', predmet.naruPlEmail),
    ]);
  }

  return _compactLabelValues([
    ListaPdfLabelValue('Ime i prezime', _resolvePrimaryPayerName(predmet)),
    ListaPdfLabelValue('JMBG', predmet.naruJmbg),
    ListaPdfLabelValue('Broj LK / pasoša', predmet.naruBrojLk),
    ListaPdfLabelValue('Adresa', predmet.naruAdresa),
    ListaPdfLabelValue('Telefon 1', predmet.naruTelefon1),
    ListaPdfLabelValue('Telefon 2', predmet.naruTelefon2),
    ListaPdfLabelValue('Email', predmet.naruEmail),
  ]);
}

List<ListaPdfLabelValue> _buildJkpPayerFields(PredmetiData predmet) {
  if (predmet.jkpTip == 'PRAVNO_LICE') {
    return _compactLabelValues([
      ListaPdfLabelValue('Naziv pravnog lica', predmet.jkpPlNaziv),
      ListaPdfLabelValue('Adresa', predmet.jkpPlAdresa),
      ListaPdfLabelValue('PIB', predmet.jkpPlPib),
      ListaPdfLabelValue('Matični broj', predmet.jkpPlMb),
      ListaPdfLabelValue('Odgovorno lice', predmet.jkpPlOdgovornoLice),
      ListaPdfLabelValue('Telefon', predmet.jkpPlTelefon1),
      ListaPdfLabelValue('Email', predmet.jkpPlEmail),
    ]);
  }

  return _compactLabelValues([
    ListaPdfLabelValue('Ime i prezime', _resolveJkpName(predmet)),
    ListaPdfLabelValue('JMBG', predmet.jkpJmbg),
    ListaPdfLabelValue('Broj LK / pasoša', predmet.jkpBrojLk),
    ListaPdfLabelValue('Adresa', predmet.jkpAdresa),
    ListaPdfLabelValue('Telefon 1', predmet.jkpTelefon1),
    ListaPdfLabelValue('Telefon 2', predmet.jkpTelefon2),
    ListaPdfLabelValue('Email', predmet.jkpEmail),
  ]);
}

String _displayPreminuloName(PredmetiData predmet) {
  return _joinNonEmpty([predmet.ime, predmet.prezime]);
}

String _upperName(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '—' : trimmed.toUpperCase();
}

String _joinNonEmpty(List<String> parts) {
  return parts
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ');
}

String _platiocNaziv(String raw) {
  return switch (raw) {
    'PRAVNO_LICE' => 'Pravno lice',
    'FIZICKO_LICE' => 'Fizičko lice',
    _ => _humanizeCode(raw),
  };
}

String _resolvePrimaryPayerName(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') {
    return _joinNonEmpty([predmet.naruPlNaziv, predmet.naruPlOdgovornoLice]);
  }
  return _resolvePhysicalPayerName(
    fullName: predmet.naruImePrezime,
    ime: predmet.naruIme,
    prezime: predmet.naruPrezime,
  );
}

String _resolveJkpName(PredmetiData predmet) {
  if (predmet.jkpTip == 'PRAVNO_LICE') {
    return _joinNonEmpty([predmet.jkpPlNaziv, predmet.jkpPlOdgovornoLice]);
  }
  return _resolvePhysicalPayerName(
    fullName: predmet.jkpImePrezime,
    ime: predmet.jkpIme,
    prezime: predmet.jkpPrezime,
  );
}

String _resolvePhysicalPayerName({
  required String fullName,
  required String ime,
  required String prezime,
}) {
  final normalizedFullName = fullName.trim();
  if (normalizedFullName.isNotEmpty) {
    return normalizedFullName;
  }
  return _joinNonEmpty([prezime, ime]);
}

bool _isKremacija(String vrstaCeremonije) {
  return vrstaCeremonije == 'KREMACIJA' ||
      vrstaCeremonije == 'KREMACIJA_EKSPRES';
}

bool _mozeOpelo(String vrstaCeremonije) {
  return vrstaCeremonije != 'KREMACIJA_EKSPRES' &&
      vrstaCeremonije != 'SMESTAJ_URNE' &&
      vrstaCeremonije != 'RASIPANJE_PEPELA';
}

bool _tipPolaganjaSaLokalitetom(String tipPolaganja) {
  return tipPolaganja == 'GROB' ||
      tipPolaganja == 'GROBNICA' ||
      tipPolaganja == 'KOLUMBARIJUM' ||
      tipPolaganja == 'ROZARIJUM';
}

String _grobnoMestoNaziv(String raw) {
  return switch (raw) {
    'NOVO' => 'Novo',
    'POSTOJECE' => 'Postojeće',
    _ => _humanizeCode(raw),
  };
}

String _tipGrobljaNaziv(String raw) {
  return switch (raw) {
    'GRADSKO' => 'Gradsko',
    'LOKALNO' => 'Lokalno',
    _ => _humanizeCode(raw),
  };
}

String _vrstaCeremonijeNaziv(String raw) {
  return switch (raw) {
    'SAHRANA' => 'Sahrana',
    'SAHRANA_EKSPRES' => 'Sahrana ekspres',
    'KREMACIJA' => 'Kremacija',
    'KREMACIJA_EKSPRES' => 'Kremacija ekspres',
    'SMESTAJ_URNE' => 'Smeštaj urne',
    'RASIPANJE_PEPELA' => 'Rasipanje pepela',
    _ => _humanizeCode(raw),
  };
}

String _tipGrobnogMestaNaziv(String raw) {
  return switch (raw) {
    'GROB' => 'Grob',
    'GROBNICA' => 'Grobnica',
    _ => _humanizeCode(raw),
  };
}

String _tipPolaganjaNaziv(String raw) {
  return switch (raw) {
    'NAKNADNO' => 'Naknadno',
    'U_GROB' => 'U grob',
    'U_GROBNICU' => 'U grobnicu',
    'KOLUMBARIJUM' => 'Kolumbarijum',
    'ROZARIJUM' => 'Rozarijum',
    'KUCA' => 'Kuća',
    'RASIPANJE' => 'Rasipanje',
    _ => _humanizeCode(raw),
  };
}

String _polLabel(String raw) {
  return switch (raw.trim()) {
    'M' => 'Muški',
    'Z' => 'Ženski',
    _ => _humanizeCode(raw),
  };
}

String _uzrokSmrtiLabel(String raw) {
  return switch (raw.trim()) {
    'PRIRODNA' => 'Prirodna',
    'NASILNA' => 'Nasilna',
    'ZARAZNA' => 'Zarazna',
    'NEDEFINISANA' => 'Nedefinisana',
    _ => _humanizeCode(raw),
  };
}

String _bracnoStanjeLabel(String raw) {
  return switch (raw.trim()) {
    'NEOZENJEN_NEUDATA' => 'Neoženjen / neudata',
    'OZENJEN_UDATA' => 'Oženjen / udata',
    'UDOVAC_UDOVICA' => 'Udovac / udovica',
    'RAZVEDEN_RAZVEDENA' => 'Razveden / razvedena',
    _ => _humanizeCode(raw),
  };
}

String _opeloMestoLabel(String raw) {
  return switch (raw.trim()) {
    'KAPELA NA GROBLJU' => 'Kapela na groblju',
    'CRKVA NA GROBLJU' => 'Crkva na groblju',
    'U PORODIČNOM DOMU' => 'U porodičnom domu',
    'KOD GROBNOG MESTA' => 'Kod grobnog mesta',
    _ => _humanizeCode(raw),
  };
}
