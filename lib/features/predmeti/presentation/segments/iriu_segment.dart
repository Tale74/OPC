import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../../podesavanja/data/podesavanja_repository.dart';
import '../../../podesavanja/presentation/katalog_photo_policy.dart';
import '../../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../../stanje_robe/data/stanje_robe_posledice_repository.dart';
import '../../core_v2/models/iriu_truth_models.dart';
import '../../core_v2/services/blok2_iriu_lifecycle_service.dart';
import '../../core_v2/rules/iriu_truth_rules.dart';
import '../../core_v2/services/mesto_smrti_iriu_lifecycle_service.dart';
import '../../core_v2/services/predmet_iriu_truth_service.dart';
import '../../data/iriu_repository.dart';
import 'iriu_row_tile.dart';

bool shouldAutoAddLimeniUlozak(PredmetiData predmet) {
  return IriuTruthRules.autoManagedBlok2Categories(
    predmet: predmet,
  ).contains(IriuK.limeniUlozak);
}

bool shouldAutoAddLemovanje(PredmetiData predmet) {
  return IriuTruthRules.autoManagedBlok2Categories(
    predmet: predmet,
  ).contains(IriuK.lemovanje);
}

const String iriuStatusPreporuceno = 'PREPORUČENO';
const double _iriuNarrowLayoutBreakpoint = 640;

String? resolveIriuRuntimeStatus({
  required IriuData stavka,
  required PredmetiData predmet,
}) => null;

/// Segment 5: IRIU - izabrana roba i usluge.
class IriuSegment extends StatefulWidget {
  const IriuSegment({
    super.key,
    required this.predmetId,
    required this.predmetData,
    required this.iriuRepo,
    required this.podesavanjaRepo,
    required this.enabled,
    required this.onNapomenaSave,
    this.initialNapomena,
  });

  final int predmetId;
  final PredmetiData predmetData;
  final IriuRepository iriuRepo;
  final PodesavanjaRepository podesavanjaRepo;
  final bool enabled;
  final void Function(String) onNapomenaSave;
  final String? initialNapomena;

  @override
  State<IriuSegment> createState() => _IriuSegmentState();
}

class _IriuSegmentState extends State<IriuSegment> {
  static const _predmetIriuTruthService = PredmetIriuTruthService();
  static const _mestoSmrtiLifecycleService = MestoSmrtiIriuLifecycleService();
  static const _blok2LifecycleService = Blok2IriuLifecycleService();
  Timer? _napomenaDebounce;
  late final TextEditingController _napomenaCtrl;
  late final StanjeRobePoslediceRepository _stockConsequencesRepo;
  final Map<String, Stream<bool>> _imaArtikalaStreamsByInterniNaziv = {};
  String? _lastPredmetTruthSignature;
  String? _lastIriuTruthSignature;
  PredmetIriuTruthSnapshot? _cachedTruthSnapshot;
  Map<int, IriuTruthRow> _cachedTruthRowsById = const {};

  String _normalizedText(String value) => normalizeText(value);

  PredmetiData _withNormalizedIriuMestoSmrti(PredmetiData predmet) {
    return predmet.copyWith(
      mestoSmrti: IriuTruthRules.normalizeMestoSmrti(predmet.mestoSmrti),
    );
  }

  bool _mestoSmrtiConditionChanged({
    required PredmetiData previous,
    required PredmetiData current,
  }) {
    return previous.mestoSmrti != current.mestoSmrti;
  }

  bool _blok2ConditionInputsChanged({
    required PredmetiData previous,
    required PredmetiData current,
  }) {
    return previous.mestoSmrti != current.mestoSmrti ||
        previous.tipGroblja != current.tipGroblja ||
        previous.tipGrobnogMesta != current.tipGrobnogMesta ||
        previous.uzrokSmrti != current.uzrokSmrti ||
        previous.vrstaCeremonije != current.vrstaCeremonije;
  }

  String _predmetTruthSignature(PredmetiData predmet) {
    return [
      IriuTruthRules.normalizeMestoSmrti(predmet.mestoSmrti),
      predmet.tipGroblja,
      predmet.tipGrobnogMesta,
      predmet.uzrokSmrti,
      predmet.vrstaCeremonije,
      predmet.sahranaVanSrbije,
      predmet.docekPosmrtnihOstataka,
    ].join('|');
  }

  String _iriuTruthSignature(List<IriuData> stavke) {
    return stavke
        .map((s) => '${s.id}|${s.interniNaziv}|${s.redosled}|${s.iznos}')
        .join('||');
  }

  ({PredmetIriuTruthSnapshot snapshot, Map<int, IriuTruthRow> rowsById})
  _resolveTruthState(List<IriuData> stavke) {
    final predmetSignature = _predmetTruthSignature(widget.predmetData);
    final iriuSignature = _iriuTruthSignature(stavke);
    final cachedSnapshot = _cachedTruthSnapshot;

    if (cachedSnapshot != null &&
        _lastPredmetTruthSignature == predmetSignature &&
        _lastIriuTruthSignature == iriuSignature) {
      return (snapshot: cachedSnapshot, rowsById: _cachedTruthRowsById);
    }

    final snapshot = _predmetIriuTruthService.evaluate(
      predmet: widget.predmetData,
      storedRows: stavke,
    );
    final rowsById = <int, IriuTruthRow>{
      for (final row in snapshot.rows) row.storedRow.id: row,
    };

    _lastPredmetTruthSignature = predmetSignature;
    _lastIriuTruthSignature = iriuSignature;
    _cachedTruthSnapshot = snapshot;
    _cachedTruthRowsById = rowsById;

    return (snapshot: snapshot, rowsById: rowsById);
  }

  Stream<bool> _imaArtikalaStreamFor(String interniNaziv) {
    return _imaArtikalaStreamsByInterniNaziv.putIfAbsent(
      interniNaziv,
      () => widget.podesavanjaRepo.watchImaArtikalaZaKategoriju(interniNaziv),
    );
  }

  bool _isCoveredStockSelection(
    String interniNaziv,
    String? katalogStableArticleId,
  ) {
    final stableArticleId = katalogStableArticleId?.trim();
    return stableArticleId?.isNotEmpty == true &&
        StanjeRobeLifecycleService.isCoveredCategory(interniNaziv);
  }

  String _stockCategoryLabel(String kategorija) {
    return StanjeRobeLifecycleService.displayLabelForCoveredCategory(
      kategorija,
    );
  }

  Future<bool> _stanjeRobeAktivno() {
    return StanjeRobeOperationalAvailability(
      podesavanjaRepository: widget.podesavanjaRepo,
    ).isActive();
  }

  Stream<StanjeRobeOperationalStatus> _stanjeRobeStatusStream() {
    return StanjeRobeOperationalAvailability(
      podesavanjaRepository: widget.podesavanjaRepo,
    ).watchStatus();
  }

  Future<bool> _confirmInsufficientStockSelectionIfNeeded({
    required String interniNaziv,
    required String naziv,
    required String? katalogStableArticleId,
  }) async {
    if (!_isCoveredStockSelection(interniNaziv, katalogStableArticleId)) {
      return true;
    }
    if (!await _stanjeRobeAktivno()) {
      return true;
    }

    final stableArticleId = katalogStableArticleId!.trim();
    final sufficient =
        await StanjeRobeLifecycleService(
          db: widget.iriuRepo.db,
          isOperationallyActive: _stanjeRobeAktivno,
        ).hasSufficientStockForCoveredSelection(
          kategorija: interniNaziv,
          stableArticleId: stableArticleId,
        );
    if (sufficient || !mounted) return sufficient;

    final categoryLabel = _stockCategoryLabel(interniNaziv);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isNarrowAndroid =
            Theme.of(dialogContext).platform == TargetPlatform.android &&
            MediaQuery.sizeOf(dialogContext).width <
                _iriuNarrowLayoutBreakpoint;
        return AlertDialog(
          insetPadding: isNarrowAndroid
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
              : null,
          scrollable: isNarrowAndroid,
          actionsOverflowDirection: VerticalDirection.down,
          title: const Text('Artikal nije na stanju'),
          content: Text(
            'Izabrani artikal nije na stanju: $categoryLabel — $naziv.\n\n'
            'Predmet ne može biti zatvoren dok se zaliha ne dopuni '
            'ili artikal ne zameni dostupnim artiklom iz iste kategorije.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('ODUSTANI'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('IZABERI UZ UPOZORENJE'),
            ),
          ],
        );
      },
    );
    return accepted == true;
  }

  @override
  void initState() {
    super.initState();
    _stockConsequencesRepo = StanjeRobePoslediceRepository(widget.iriuRepo.db);
    _napomenaCtrl = TextEditingController(text: widget.initialNapomena ?? '');
    unawaited(_runMestoSmrtiLifecycleSync(widget.predmetData));
    unawaited(_runBlok2LifecycleSync(widget.predmetData));
  }

  @override
  void dispose() {
    _napomenaDebounce?.cancel();
    _napomenaCtrl.dispose();
    super.dispose();
  }

  // Skupovi za uslove mestoSmrti
  @override
  void didUpdateWidget(IriuSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = _withNormalizedIriuMestoSmrti(oldWidget.predmetData);
    final cur = _withNormalizedIriuMestoSmrti(widget.predmetData);
    final promenjeniMestoSmrtiUslovi = _mestoSmrtiConditionChanged(
      previous: old,
      current: cur,
    );
    final promenjeniBlok2Uslovi = _blok2ConditionInputsChanged(
      previous: old,
      current: cur,
    );

    if (promenjeniMestoSmrtiUslovi) {
      unawaited(
        _resolveConditionChangeConflicts(
          previousPredmet: old,
          currentPredmet: cur,
        ),
      );
    }
    if (promenjeniBlok2Uslovi) {
      unawaited(
        _resolveBlok2ConditionChangeConflicts(
          previousPredmet: old,
          currentPredmet: cur,
        ),
      );
    }
    if (!old.sahranaVanSrbije && cur.sahranaVanSrbije) _autoInsertVanSrbije();
    if (!old.docekPosmrtnihOstataka && cur.docekPosmrtnihOstataka) {
      _predloziStavke([IriuK.cargoTroskovi]);
    }
    if (old.tipGrobnogMesta != cur.tipGrobnogMesta) {
      _onTipGrobnogMestaChanged(cur);
    }
    if (old.opelo != cur.opelo && cur.opelo == 'DA') {
      _predloziStavke([IriuK.kompletZaOpelo]);
    }
  }

  Future<void> _resolveConditionChangeConflicts({
    required PredmetiData previousPredmet,
    required PredmetiData currentPredmet,
  }) async {
    final storedRows = await widget.iriuRepo.getIriu(widget.predmetId);
    if (!mounted) return;
    final dismissedCategories = await widget.iriuRepo
        .getDismissedMestoSmrtiCategories(widget.predmetId);
    final plan = _mestoSmrtiLifecycleService.planForConditionChange(
      previousPredmet: previousPredmet,
      currentPredmet: currentPredmet,
      storedRows: storedRows,
      dismissedCategories: dismissedCategories,
    );

    for (final conflict in plan.conflicts) {
      if (!mounted) return;
      final decision = await _showConditionConflictDialog(conflict.row);
      if (!mounted) return;
      if (decision == _ConditionConflictDecision.remove &&
          conflict.row.manualDeletionAllowed) {
        await widget.iriuRepo.obrisiStavkuSaLifecycleMemorijom(
          predmetId: widget.predmetId,
          row: conflict.row.storedRow,
          rememberManualDeletion: false,
        );
      }
    }

    await widget.iriuRepo.syncMestoSmrtiManagedRows(
      predmetId: widget.predmetId,
      predmet: currentPredmet,
      lifecycleService: _mestoSmrtiLifecycleService,
    );
  }

  Future<_ConditionConflictDecision?> _showConditionConflictDialog(
    IriuTruthRow row,
  ) {
    final naziv = normalizeText(row.storedRow.nazivPrikaz).isNotEmpty
        ? normalizeText(row.storedRow.nazivPrikaz)
        : resolveDisplayLabel(
            internalName: row.storedRow.interniNaziv,
            fallbackDisplayLabels: IriuK.naziviPrikaz,
          );
    return showDialog<_ConditionConflictDecision>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uslov se promenio'),
        content: Text(
          'Stavka "$naziv" više ne odgovara trenutnim uslovima predmeta.\n\n'
          'Možete da je zadržite kao red koji se ne prikazuje i odlučite kasnije, '
          'ili da je sada uklonite.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, _ConditionConflictDecision.keep),
            child: const Text('ZADRŽI'),
          ),
          FilledButton(
            onPressed: row.manualDeletionAllowed
                ? () => Navigator.pop(ctx, _ConditionConflictDecision.remove)
                : null,
            child: const Text('UKLONI'),
          ),
        ],
      ),
    );
  }

  Future<void> _runMestoSmrtiLifecycleSync(PredmetiData predmet) {
    return widget.iriuRepo.syncMestoSmrtiManagedRows(
      predmetId: widget.predmetId,
      predmet: predmet.copyWith(
        mestoSmrti: IriuTruthRules.normalizeMestoSmrti(predmet.mestoSmrti),
      ),
      lifecycleService: _mestoSmrtiLifecycleService,
    );
  }

  Future<void> _resolveBlok2ConditionChangeConflicts({
    required PredmetiData previousPredmet,
    required PredmetiData currentPredmet,
  }) async {
    final storedRows = await widget.iriuRepo.getIriu(widget.predmetId);
    if (!mounted) return;
    final dismissedCategories = await widget.iriuRepo
        .getDismissedBlok2Categories(widget.predmetId);
    final plan = _blok2LifecycleService.planForConditionChange(
      previousPredmet: previousPredmet,
      currentPredmet: currentPredmet,
      storedRows: storedRows,
      dismissedCategories: dismissedCategories,
    );

    for (final conflict in plan.conflicts) {
      if (!mounted) return;
      final decision = await _showConditionConflictDialog(conflict.row);
      if (!mounted) return;
      if (decision == _ConditionConflictDecision.remove &&
          conflict.row.manualDeletionAllowed) {
        await widget.iriuRepo.obrisiStavkuSaLifecycleMemorijom(
          predmetId: widget.predmetId,
          row: conflict.row.storedRow,
          rememberManualDeletion: false,
        );
      }
    }

    for (final internalName in plan.additionsRequiringConfirmation) {
      if (!mounted) return;
      final decision = await _showConditionAdditionDialog(internalName);
      if (!mounted) return;
      if (decision == _ConditionAdditionDecision.add) {
        await _dodajUpravljanuBlok2Stavku(internalName);
      } else {
        await widget.iriuRepo.rememberBlok2ManagedDismissal(
          predmetId: widget.predmetId,
          interniNaziv: internalName,
        );
      }
    }
  }

  Future<void> _runBlok2LifecycleSync(PredmetiData predmet) {
    return widget.iriuRepo.syncBlok2ManagedRows(
      predmetId: widget.predmetId,
      predmet: predmet.copyWith(
        mestoSmrti: IriuTruthRules.normalizeMestoSmrti(predmet.mestoSmrti),
      ),
      lifecycleService: _blok2LifecycleService,
    );
  }

  Future<_ConditionAdditionDecision?> _showConditionAdditionDialog(
    String internalName,
  ) {
    final label = resolveDisplayLabel(
      internalName: internalName,
      fallbackDisplayLabels: IriuK.naziviPrikaz,
    );
    return showDialog<_ConditionAdditionDecision>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('POTVRDA IRiU DODAVANJA'),
        content: Text(
          'Promena uslova predmeta sada zahteva stavku "$label". '
          'Možete da je dodate u IRiU ili da je ne dodate sada.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_ConditionAdditionDecision.skip),
            child: const Text('NE DODAJ'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_ConditionAdditionDecision.add),
            child: const Text('DODAJ'),
          ),
        ],
      ),
    );
  }

  Future<void> _dodajUpravljanuBlok2Stavku(String internalName) async {
    final red = await widget.iriuRepo.redosledPosleKategorije(
      widget.predmetId,
      internalName,
    );
    await widget.iriuRepo.dodajStavku(
      predmetId: widget.predmetId,
      interniNaziv: internalName,
      nazivPrikaz: resolveDisplayLabel(
        internalName: internalName,
        fallbackDisplayLabels: IriuK.naziviPrikaz,
      ),
      redosled: red,
    );
  }

  /// Opšti helper - predlaže listu stavki po internom nazivu (idempotentno).
  Future<void> _predloziStavke(List<String> intNazivi) async {
    for (final n in intNazivi) {
      final red = await widget.iriuRepo.sledeciredosled(widget.predmetId);
      await widget.iriuRepo.predloziAkoNema(
        predmetId: widget.predmetId,
        interniNaziv: n,
        nazivPrikaz: resolveDisplayLabel(
          internalName: n,
          fallbackDisplayLabels: IriuK.naziviPrikaz,
        ),
        redosled: red,
      );
    }
  }

  Future<void> _autoInsertVanSrbije() => _predloziStavke([
    IriuK.medjunarodniPrevoz,
    IriuK.medjunarodnaDocumentacija,
    IriuK.balsamovanje,
  ]);

  Future<void> _onTipGrobnogMestaChanged(PredmetiData _) async {}

  // Dodaj iz kataloga

  Future<void> _dodajIzKataloga() async {
    final katalog = await widget.podesavanjaRepo
        .getKatalogSaArtiklimaLightweight();
    if (!mounted) return;

    final vanSrbije =
        widget.predmetData.sahranaVanSrbije ||
        widget.predmetData.docekPosmrtnihOstataka;

    _KatalogPickerDialog buildPicker({
      ScrollController? scrollController,
      bool asBottomSheet = false,
    }) {
      return _KatalogPickerDialog(
        podesavanjaRepo: widget.podesavanjaRepo,
        katalog: katalog,
        vanSrbije: vanSrbije,
        scrollController: scrollController,
        asBottomSheet: asBottomSheet,
        onIzabrano: (interniNaziv, naziv, iznos, katalogStableArticleId) async {
          final accepted = await _confirmInsufficientStockSelectionIfNeeded(
            interniNaziv: interniNaziv,
            naziv: naziv,
            katalogStableArticleId: katalogStableArticleId,
          );
          if (!accepted || !mounted) return;

          final red = await widget.iriuRepo.redosledPosleKategorije(
            widget.predmetId,
            interniNaziv,
          );
          await widget.iriuRepo.dodajStavku(
            predmetId: widget.predmetId,
            interniNaziv: interniNaziv,
            nazivPrikaz: naziv,
            katalogStableArticleId: katalogStableArticleId,
            iznos: iznos,
            redosled: red,
          );
        },
      );
    }

    final isNarrowAndroid =
        Theme.of(context).platform == TargetPlatform.android &&
        MediaQuery.sizeOf(context).width < _iriuNarrowLayoutBreakpoint;

    if (isNarrowAndroid) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.96,
          expand: false,
          builder: (sheetContext, scrollController) => SafeArea(
            top: false,
            child: buildPicker(
              scrollController: scrollController,
              asBottomSheet: true,
            ),
          ),
        ),
      );
      return;
    }

    await showDialog<void>(context: context, builder: (ctx) => buildPicker());
  }

  // Ručno dodaj stavku

  Future<void> _dodajRucno() async {
    if (kIsWindowsBuild) return;
    final result = await showDialog<_RucnoResult>(
      context: context,
      builder: (ctx) => const _RucnoDialog(),
    );
    if (result == null || !mounted) return;

    String interniNaziv;
    if (result.tip == 'KATALOSKA') {
      interniNaziv = 'KORISNIK_${DateTime.now().millisecondsSinceEpoch}';
      await widget.podesavanjaRepo.dodajKorisnickaKategoriju(
        interniNaziv: interniNaziv,
        nazivPrikaz: result.naziv,
        tip: 'KATALOSKA',
      );
    } else {
      interniNaziv = 'RUCNO_${DateTime.now().millisecondsSinceEpoch}';
    }

    final red = await widget.iriuRepo.sledeciredosled(widget.predmetId);
    await widget.iriuRepo.dodajStavku(
      predmetId: widget.predmetId,
      interniNaziv: interniNaziv,
      nazivPrikaz: result.naziv,
      redosled: red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowAndroid =
            Theme.of(context).platform == TargetPlatform.android &&
            constraints.maxWidth < _iriuNarrowLayoutBreakpoint;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zaglavlje tabele
                if (!isNarrowAndroid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'NAZIV',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            'KOM',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: Text(
                            'IZNOS (RSD)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (e) const SizedBox(width: 80),
                      ],
                    ),
                  ),
                if (!isNarrowAndroid) const Divider(height: 1),
                // Lista stavki
                StreamBuilder<StanjeRobeOperationalStatus>(
                  stream: _stanjeRobeStatusStream(),
                  builder: (context, activeSnap) {
                    final stanjeRobeActive =
                        activeSnap.data == StanjeRobeOperationalStatus.active;
                    return StreamBuilder<List<StanjeRobePoslediceData>>(
                      stream: stanjeRobeActive
                          ? _stockConsequencesRepo
                                .watchActiveUnresolvedForPredmet(
                                  widget.predmetId,
                                )
                          : Stream<List<StanjeRobePoslediceData>>.value(
                              const <StanjeRobePoslediceData>[],
                            ),
                      builder: (context, consequenceSnap) {
                        final consequencesByIriuId =
                            <int, StanjeRobePoslediceData>{
                              for (final consequence
                                  in consequenceSnap.data ??
                                      const <StanjeRobePoslediceData>[])
                                consequence.iriuId: consequence,
                            };
                        return StreamBuilder<List<IriuData>>(
                          stream: widget.iriuRepo.watchIriu(widget.predmetId),
                          builder: (context, snap) {
                            final stavke = snap.data ?? [];
                            final truthState = _resolveTruthState(stavke);
                            final truthRowsById = truthState.rowsById;
                            if (stavke.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  'DODAJTE KATEGORIJE - iz kataloga ili ručnim unosom',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: stavke
                                  .map(
                                    (s) => IriuRowTile(
                                      key: ValueKey(
                                        '${s.id}:${s.interniNaziv}:${s.redosled}',
                                      ),
                                      stavka: s,
                                      iriuRepo: widget.iriuRepo,
                                      podesavanjaRepo: widget.podesavanjaRepo,
                                      imaArtikalaStream: _imaArtikalaStreamFor(
                                        s.interniNaziv,
                                      ),
                                      enabled: e,
                                      truthRow: truthRowsById[s.id],
                                      stockConsequence:
                                          consequencesByIriuId[s.id],
                                      isNarrowAndroid: isNarrowAndroid,
                                      preporucenoLabel: iriuStatusPreporuceno,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                // Dugmad za dodavanje
                if (e)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: isNarrowAndroid
                        ? Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  icon: const Icon(
                                    Icons.library_books_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('IZ KATALOGA'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  onPressed: _dodajIzKataloga,
                                ),
                              ),
                              if (!kIsWindowsBuild) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('RUČNO'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    onPressed: _dodajRucno,
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.library_books_outlined,
                                  size: 16,
                                ),
                                label: const Text('IZ KATALOGA'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: _dodajIzKataloga,
                              ),
                              if (!kIsWindowsBuild)
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('RUČNO'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: _dodajRucno,
                                ),
                            ],
                          ),
                  ),
                const Divider(),
                // Napomena
                const SizedBox(height: 4),
                TextFormField(
                  controller: _napomenaCtrl,
                  enabled: e,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'NAPOMENA',
                    border: OutlineInputBorder(),
                    isDense: true,
                    alignLabelWithHint: true,
                  ),
                  onChanged: (v) {
                    _napomenaDebounce?.cancel();
                    _napomenaDebounce = Timer(
                      const Duration(milliseconds: 800),
                      () => widget.onNapomenaSave(_normalizedText(v)),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _ConditionConflictDecision { keep, remove }

enum _ConditionAdditionDecision { skip, add }

// Katalog picker dijalog

typedef _KatalogEntry = ({
  IriuKatalogConfigData config,
  List<KatalogPickerArticleSummary> artikli,
});

/// Hardcoded međunarodne usluge - prikazuju se samo kada je sahranaVanSrbije
/// ili docekPosmrtnihOstataka aktivan na predmetu.
const _internationalItems = [
  ('MEDJUNARODNI_PREVOZ', 'Međunarodni prevoz'),
  ('MEDJUNARODNA_DOKUMENTACIJA', 'Međunarodna dokumentacija'),
  ('BALSAMOVANJE', 'Balsamovanje'),
  ('CARGO_TROSKOVI', 'Cargo troškovi'),
];

class _KatalogPickerDialog extends StatefulWidget {
  const _KatalogPickerDialog({
    required this.podesavanjaRepo,
    required this.katalog,
    required this.vanSrbije,
    required this.onIzabrano,
    this.scrollController,
    this.asBottomSheet = false,
  });

  final PodesavanjaRepository podesavanjaRepo;
  final List<_KatalogEntry> katalog;
  final bool vanSrbije;
  final ScrollController? scrollController;
  final bool asBottomSheet;
  final Future<void> Function(
    String interniNaziv,
    String naziv,
    double iznos,
    String? katalogStableArticleId,
  )
  onIzabrano;

  @override
  State<_KatalogPickerDialog> createState() => _KatalogPickerDialogState();
}

class _KatalogPickerDialogState extends State<_KatalogPickerDialog> {
  final _searchCtrl = TextEditingController();
  final Map<int, Future<Uint8List?>> _photoFuturesByArticleId = {};
  String _pretraga = '';
  String? _expandovanaKat; // interniNaziv proširene kategorije

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _odgovaraPretrazi(String tekst) {
    if (_pretraga.isEmpty) return true;
    return tekst.toLowerCase().contains(_pretraga.toLowerCase());
  }

  Future<Uint8List?> _photoFutureFor(KatalogPickerArticleSummary artikl) {
    if (!artikl.hasPhoto) {
      return Future<Uint8List?>.value(null);
    }
    return _photoFuturesByArticleId.putIfAbsent(
      artikl.id,
      () => widget.podesavanjaRepo.getKatalogArticlePhotoById(artikl.id),
    );
  }

  Future<void> _izaberi(
    BuildContext ctx,
    String interniNaziv,
    String naziv,
    double iznos,
    String? katalogStableArticleId,
  ) async {
    Navigator.pop(ctx);
    await widget.onIzabrano(interniNaziv, naziv, iznos, katalogStableArticleId);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Filtrirane kategorije
    final vidljive = widget.katalog.where((e) {
      if (_pretraga.isEmpty) return true;
      if (_odgovaraPretrazi(e.config.nazivPrikaz)) return true;
      if (e.config.tip == 'KATALOSKA') {
        return e.artikli.any((a) => _odgovaraPretrazi(a.naziv));
      }
      return false;
    }).toList();

    // Međunarodne stavke (samo kada je vanSrbije)
    final internationalVisible =
        widget.vanSrbije &&
        (_pretraga.isEmpty ||
            _internationalItems.any((i) => _odgovaraPretrazi(i.$2)));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.asBottomSheet)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        // Naslov
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            children: [
              const Icon(Icons.library_books_outlined),
              const SizedBox(width: 8),
              Text(
                'Izbor iz kataloga',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        // Pretraga
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            autofocus: !widget.asBottomSheet,
            decoration: InputDecoration(
              hintText: 'Pretraži katalog...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _pretraga.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchCtrl.clear();
                          _pretraga = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (v) => setState(() => _pretraga = v),
          ),
        ),
        const Divider(height: 1),
        // Lista kategorija
        Flexible(
          child: ListView(
            controller: widget.scrollController,
            shrinkWrap: !widget.asBottomSheet,
            children: [
              // Standardne kategorije iz baze
              ...vidljive.map((entry) {
                final kat = entry.config;
                final artikli = entry.artikli;
                final jeKataloska = kat.tip == 'KATALOSKA';
                final jeProsirena = _expandovanaKat == kat.interniNaziv;

                if (!jeKataloska) {
                  // FIKSNA - direktno biranje
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.add_circle_outline, size: 20),
                    title: Text(
                      kat.nazivPrikaz,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Text(
                      'FIKSNA',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => _izaberi(
                      context,
                      kat.interniNaziv,
                      kat.nazivPrikaz,
                      0.0,
                      null,
                    ),
                  );
                }

                // KATALOŠKA - proširiva lista artikala
                final filtArtikli = _pretraga.isEmpty
                    ? artikli
                    : artikli.where((a) => _odgovaraPretrazi(a.naziv)).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Naslov kategorije
                    InkWell(
                      onTap: () => setState(() {
                        _expandovanaKat = jeProsirena ? null : kat.interniNaziv;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              jeProsirena
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kat.nazivPrikaz,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            Text(
                              '${filtArtikli.length} art.',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Artikli (prikazuju se ako je prošireno ili postoji pretraga)
                    if (jeProsirena || _pretraga.isNotEmpty)
                      ...filtArtikli.map(
                        (a) => InkWell(
                          onTap: () => _izaberi(
                            context,
                            kat.interniNaziv,
                            a.naziv,
                            a.cena,
                            a.stableArticleId,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: Row(
                              children: [
                                if (a.hasPhoto)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: FutureBuilder<Uint8List?>(
                                        future: _photoFutureFor(a),
                                        builder: (context, snapshot) {
                                          final bytes = snapshot.data;
                                          if (bytes != null) {
                                            return KatalogPhotoPolicy.memoryImage(
                                              bytes,
                                              width: 56,
                                              height: 42,
                                              fit: BoxFit.cover,
                                              cacheWidth: KatalogPhotoPolicy
                                                  .smallThumbnailDecodeTarget,
                                              cacheHeight: KatalogPhotoPolicy
                                                  .smallThumbnailDecodeTarget,
                                              errorBuilder: (ctx, e, st) =>
                                                  const SizedBox(
                                                    width: 56,
                                                    height: 42,
                                                  ),
                                            );
                                          }
                                          return SizedBox(
                                            width: 56,
                                            height: 42,
                                            child:
                                                snapshot.connectionState !=
                                                        ConnectionState.done &&
                                                    a.hasPhoto
                                                ? const Center(
                                                    child: SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 68),
                                Expanded(
                                  child: Text(
                                    a.naziv,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '${formatMoneyNumber(a.cena)} RSD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (filtArtikli.isEmpty &&
                        (jeProsirena || _pretraga.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 4, 16, 8),
                        child: Text(
                          'Nema artikala. Dodajte ih u Podešavanja -> Katalog.',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const Divider(height: 1, indent: 16),
                  ],
                );
              }),
              // Međunarodne usluge - prikazuju se samo za vanSrbije
              if (internationalVisible) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Text(
                    'MEĐUNARODNE USLUGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ..._internationalItems
                    .where((i) => _pretraga.isEmpty || _odgovaraPretrazi(i.$2))
                    .map(
                      (i) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.flight_outlined, size: 20),
                        title: Text(i.$2, style: const TextStyle(fontSize: 13)),
                        trailing: Text(
                          'FIKSNA',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => _izaberi(context, i.$1, i.$2, 0.0, null),
                      ),
                    ),
              ],
            ],
          ),
        ),
        // Footer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ZATVORI'),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.asBottomSheet) {
      return Material(color: cs.surface, child: content);
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 480,
          maxWidth: 640,
          maxHeight: 620,
        ),
        child: content,
      ),
    );
  }
}

// Ručno dijalog

class _RucnoResult {
  _RucnoResult({required this.naziv, required this.tip});
  final String naziv;
  final String tip; // FIKSNA ili KATALOSKA
}

class _RucnoDialog extends StatefulWidget {
  const _RucnoDialog();

  @override
  State<_RucnoDialog> createState() => _RucnoDialogState();
}

class _RucnoDialogState extends State<_RucnoDialog> {
  final _nazivCtrl = TextEditingController();
  String _tip = 'FIKSNA';
  bool _greskaNaziv = false;

  @override
  void dispose() {
    _nazivCtrl.dispose();
    super.dispose();
  }

  void _potvrdi() {
    final naziv = normalizeText(_nazivCtrl.text);
    if (naziv.isEmpty) {
      setState(() => _greskaNaziv = true);
      return;
    }
    Navigator.pop(context, _RucnoResult(naziv: naziv, tip: _tip));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj stavku ručno'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nazivCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Naziv stavke',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _greskaNaziv ? 'Naziv je obavezan' : null,
              ),
              onChanged: (_) {
                if (_greskaNaziv) setState(() => _greskaNaziv = false);
              },
              onSubmitted: (_) => _potvrdi(),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip stavke:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'FIKSNA',
                  label: Text('FIKSNA'),
                  icon: Icon(Icons.edit_outlined, size: 16),
                ),
                ButtonSegment<String>(
                  value: 'KATALOSKA',
                  label: Text('KATALOŠKA'),
                  icon: Icon(Icons.library_books_outlined, size: 16),
                ),
              ],
              selected: {_tip},
              onSelectionChanged: (sel) => setState(() => _tip = sel.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 4),
            Text(
              _tip == 'FIKSNA'
                  ? 'Cena se unosi ručno po predmetu'
                  : 'Artikli se biraju iz kataloga (unosite ih u Podešavanja)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(onPressed: _potvrdi, child: const Text('DODAJ')),
      ],
    );
  }
}
