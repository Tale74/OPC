import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../../podesavanja/data/podesavanja_repository.dart';
import '../../../podesavanja/presentation/katalog_photo_policy.dart';
import '../../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../core_v2/models/iriu_truth_models.dart';
import '../../data/iriu_repository.dart';

List<String> resolveIriuCatalogPickerCategoryKeys(String interniNaziv) {
  if (interniNaziv == IriuK.cituljaP || interniNaziv == IriuK.cituljaNo) {
    return const [IriuK.cituljaP, IriuK.cituljaNo];
  }
  return [interniNaziv];
}

/// Presentation-only row tile for one IRIU item.
///
/// State ownership for the surrounding segment, truth evaluation, and
/// lifecycle orchestration remains in `iriu_segment.dart`.
class IriuRowTile extends StatefulWidget {
  const IriuRowTile({
    super.key,
    required this.stavka,
    required this.iriuRepo,
    required this.podesavanjaRepo,
    required this.imaArtikalaStream,
    required this.enabled,
    required this.truthRow,
    required this.stockConsequence,
    required this.isNarrowAndroid,
    required this.preporucenoLabel,
  });

  final IriuData stavka;
  final IriuRepository iriuRepo;
  final PodesavanjaRepository podesavanjaRepo;
  final Stream<bool> imaArtikalaStream;
  final bool enabled;
  final bool isNarrowAndroid;
  final String preporucenoLabel;

  /// False when the condition for this row is no longer satisfied.
  /// The row stays visible but muted instead of being deleted.
  final IriuTruthRow? truthRow;
  final StanjeRobePoslediceData? stockConsequence;

  @override
  State<IriuRowTile> createState() => _IriuRowTileState();
}

class _IriuRowTileState extends State<IriuRowTile> {
  Timer? _debounce;
  late final TextEditingController _nazivCtrl;
  late final TextEditingController _komCtrl;
  late final TextEditingController _iznosCtrl;

  bool _mozeIzgledatiKaoDostupanKatalog(bool? imaArtikala) {
    return imaArtikala ?? false;
  }

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  double _parsedIznos() => parseMoneyInput(_iznosCtrl.text);

  bool _showSnackBarSafely(SnackBar snackBar) {
    if (!mounted) return false;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return false;
    try {
      messenger.showSnackBar(snackBar);
      return true;
    } on StateError {
      return false;
    } on FlutterError {
      return false;
    }
  }

  bool _isCoveredStockSelection(String? katalogStableArticleId) {
    final stableArticleId = katalogStableArticleId?.trim();
    return stableArticleId?.isNotEmpty == true &&
        StanjeRobeLifecycleService.isCoveredCategory(
          widget.stavka.interniNaziv,
        );
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

  Future<bool> _confirmInsufficientStockSelectionIfNeeded({
    required String naziv,
    required String? katalogStableArticleId,
  }) async {
    if (!_isCoveredStockSelection(katalogStableArticleId)) {
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
          kategorija: widget.stavka.interniNaziv,
          stableArticleId: stableArticleId,
        );
    if (sufficient || !mounted) return sufficient;

    final categoryLabel = _stockCategoryLabel(widget.stavka.interniNaziv);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isNarrowAndroid =
            Theme.of(dialogContext).platform == TargetPlatform.android &&
            MediaQuery.sizeOf(dialogContext).width < 640;
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
    final s = widget.stavka;
    _nazivCtrl = TextEditingController(text: s.nazivPrikaz);
    _komCtrl = TextEditingController(text: s.kom);
    _iznosCtrl = TextEditingController(
      text: s.iznos > 0 ? formatMoneyNumber(s.iznos) : '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nazivCtrl.dispose();
    _komCtrl.dispose();
    _iznosCtrl.dispose();
    super.dispose();
  }

  Future<void> _otvoriKatalogZaStavku() async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final kategorije = resolveIriuCatalogPickerCategoryKeys(
      widget.stavka.interniNaziv,
    );
    final artikliPoKategoriji = await Future.wait(
      kategorije.map(widget.podesavanjaRepo.getArtikliZaKategorijuLightweight),
    );
    final artikli = [
      for (final artikliKategorije in artikliPoKategoriji) ...artikliKategorije,
    ];
    if (!mounted) return;

    if (artikli.isEmpty) {
      _showSnackBarSafely(
        const SnackBar(
          content: Text(
            'Nema artikala za ovu kategoriju. '
            'Dodajte ih u Podešavanja -> Katalog.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (isAndroid) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _ArtikliPicker(
          podesavanjaRepo: widget.podesavanjaRepo,
          artikli: artikli,
          onIzabrano: _primeniArtikl,
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (ctx) => _ArtikliPickerDialog(
          podesavanjaRepo: widget.podesavanjaRepo,
          artikli: artikli,
          onIzabrano: _primeniArtikl,
        ),
      );
    }
  }

  Future<void> _primeniArtikl(
    String naziv,
    double cena,
    String? katalogStableArticleId,
    String interniNazivKategorije,
  ) async {
    final accepted = await _confirmInsufficientStockSelectionIfNeeded(
      naziv: naziv,
      katalogStableArticleId: katalogStableArticleId,
    );
    if (!accepted || !mounted) return;

    setState(() {
      _nazivCtrl.text = naziv;
      _komCtrl.text = '1';
      _iznosCtrl.text = cena > 0 ? formatMoneyNumber(cena) : '';
    });
    _debounce?.cancel();
    await widget.iriuRepo.azurirajKatalogIzborStavke(
      row: widget.stavka,
      katalogStableArticleId: katalogStableArticleId,
      interniNaziv: interniNazivKategorije,
      nazivPrikaz: _normalizedText(_nazivCtrl),
      kom: _normalizedText(_komCtrl),
      iznos: _parsedIznos(),
    );
  }

  Future<void> _potvrdiObris(BuildContext context) async {
    final naziv = _normalizedText(_nazivCtrl);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši stavku'),
        content: Text(
          naziv.isNotEmpty
              ? 'Obrisati stavku "$naziv"?'
              : 'Obrisati ovu stavku?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRIŠI'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.iriuRepo.obrisiStavkuSaLifecycleMemorijom(
        predmetId: widget.stavka.predmetId,
        row: widget.stavka,
      );
    }
  }

  void _scheduleSave({
    Value<String?> katalogStableArticleId = const Value.absent(),
  }) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      widget.iriuRepo.azurirajStavku(
        widget.stavka.id,
        IriuCompanion(
          katalogStableArticleId: katalogStableArticleId,
          nazivPrikaz: Value(_normalizedText(_nazivCtrl)),
          kom: Value(_normalizedText(_komCtrl)),
          iznos: Value(_parsedIznos()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    final truthRow = widget.truthRow;
    final aktivan = truthRow?.active ?? true;
    final fe = e;
    final cs = Theme.of(context).colorScheme;
    final imaValidanIznos = _parsedIznos() > 0;
    final prikaziPreporuceno =
        truthRow?.recommended == true && !imaValidanIznos;
    final prikaziBiohazard = truthRow?.biohazard == true;
    final stockConsequence = widget.stockConsequence;
    final prikaziStanjeRobeUpozorenje = stockConsequence != null;
    final suppressedFill = cs.surfaceContainerHighest.withValues(alpha: 0.4);
    final suppressedBorder = cs.outlineVariant.withValues(alpha: 0.7);
    final katalogAvailableFill = cs.primaryContainer.withValues(alpha: 0.58);
    final katalogAvailableBorder = cs.primary.withValues(alpha: 0.4);
    final katalogUnavailableFill = cs.surfaceContainerHighest.withValues(
      alpha: 0.78,
    );
    final katalogUnavailableBorder = cs.outlineVariant;
    final deleteFill = cs.errorContainer.withValues(alpha: 0.2);
    final deleteBorder = cs.error.withValues(alpha: 0.34);
    final isNarrowAndroid = widget.isNarrowAndroid;

    InputDecoration rowDecoration({
      required EdgeInsetsGeometry contentPadding,
    }) {
      return InputDecoration(
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: aktivan ? cs.outline : suppressedBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: aktivan ? cs.primary : suppressedBorder,
          ),
        ),
        isDense: true,
        filled: !aktivan,
        fillColor: aktivan ? null : suppressedFill,
        contentPadding: contentPadding,
      );
    }

    Widget statusChip({
      required String label,
      required Color backgroundColor,
      required Color borderColor,
      required Color foregroundColor,
      bool compact = false,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: compact
              ? backgroundColor.withValues(alpha: 0.55)
              : backgroundColor,
          borderRadius: BorderRadius.circular(compact ? 999 : 6),
          border: Border.all(
            color: compact ? borderColor.withValues(alpha: 0.65) : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 9 : 10,
            fontWeight: FontWeight.w700,
            color: compact
                ? foregroundColor.withValues(alpha: 0.85)
                : foregroundColor,
            letterSpacing: compact ? 0.2 : 0,
          ),
        ),
      );
    }

    Widget quantityField({double? width}) {
      final field = TextFormField(
        controller: _komCtrl,
        enabled: fe,
        textAlign: TextAlign.center,
        decoration: rowDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
        ),
        style: TextStyle(
          fontSize: 13,
          color: aktivan ? null : cs.onSurfaceVariant,
        ),
        onChanged: (_) => _scheduleSave(),
      );
      return width == null ? field : SizedBox(width: width, child: field);
    }

    Widget amountField({double? width}) {
      final field = TextFormField(
        controller: _iznosCtrl,
        enabled: fe,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: rowDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
        style: TextStyle(
          fontSize: 13,
          color: aktivan ? null : cs.onSurfaceVariant,
        ),
        onChanged: (_) {
          setState(() {});
          _scheduleSave();
        },
        onEditingComplete: () {
          final parsed = _parsedIznos();
          final formatted = parsed > 0 ? formatMoneyNumber(parsed) : '';
          if (formatted != _iznosCtrl.text) {
            setState(() {
              _iznosCtrl.text = formatted;
              _iznosCtrl.selection = TextSelection.collapsed(
                offset: formatted.length,
              );
            });
          }
        },
      );
      return width == null ? field : SizedBox(width: width, child: field);
    }

    Widget actionButtons({bool compact = false}) {
      if (!e) return const SizedBox.shrink();
      final buttonSize = compact ? 44.0 : 40.0;
      final iconSize = compact ? 18.0 : 16.0;
      final spacing = compact ? 8.0 : 4.0;

      Widget actionShell({
        required Color color,
        required Color borderColor,
        required Widget child,
      }) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(compact ? 12 : 8),
            border: Border.all(color: borderColor),
          ),
          child: child,
        );
      }

      if (compact) {
        ButtonStyle actionStyle({
          required Color foregroundColor,
          required Color backgroundColor,
          required Color borderColor,
        }) {
          return OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            side: BorderSide(color: borderColor),
            minimumSize: Size.fromHeight(buttonSize),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: StreamBuilder<bool>(
                stream: widget.imaArtikalaStream,
                builder: (context, snap) {
                  final katalogDostupan = _mozeIzgledatiKaoDostupanKatalog(
                    snap.data,
                  );
                  final iconColor = katalogDostupan
                      ? cs.primary
                      : cs.onSurfaceVariant;
                  final containerColor = katalogDostupan
                      ? katalogAvailableFill
                      : katalogUnavailableFill;
                  final borderColor = katalogDostupan
                      ? katalogAvailableBorder
                      : katalogUnavailableBorder;

                  return Tooltip(
                    message: 'Izaberi iz kataloga',
                    child: OutlinedButton.icon(
                      style: actionStyle(
                        foregroundColor: iconColor,
                        backgroundColor: containerColor,
                        borderColor: borderColor,
                      ),
                      icon: Icon(
                        katalogDostupan
                            ? Icons.library_books_outlined
                            : Icons.library_books,
                        size: iconSize,
                      ),
                      label: const Text('Katalog'),
                      onPressed: _otvoriKatalogZaStavku,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Tooltip(
                message: 'Obriši stavku',
                child: OutlinedButton.icon(
                  style: actionStyle(
                    foregroundColor: cs.error,
                    backgroundColor: deleteFill,
                    borderColor: deleteBorder,
                  ),
                  icon: Icon(Icons.delete_outline, size: iconSize),
                  label: const Text('Obriši'),
                  onPressed: () => _potvrdiObris(context),
                ),
              ),
            ),
          ],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: StreamBuilder<bool>(
              stream: widget.imaArtikalaStream,
              builder: (context, snap) {
                final katalogDostupan = _mozeIzgledatiKaoDostupanKatalog(
                  snap.data,
                );
                final iconColor = katalogDostupan
                    ? cs.primary
                    : cs.onSurfaceVariant;
                final containerColor = katalogDostupan
                    ? katalogAvailableFill
                    : katalogUnavailableFill;
                final borderColor = katalogDostupan
                    ? katalogAvailableBorder
                    : katalogUnavailableBorder;

                return actionShell(
                  color: containerColor,
                  borderColor: borderColor,
                  child: IconButton(
                    icon: Icon(
                      katalogDostupan
                          ? Icons.library_books_outlined
                          : Icons.library_books,
                      size: iconSize,
                    ),
                    color: iconColor,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: buttonSize,
                      height: buttonSize,
                    ),
                    tooltip: 'Izaberi iz kataloga',
                    onPressed: _otvoriKatalogZaStavku,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: spacing),
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: actionShell(
              color: deleteFill,
              borderColor: deleteBorder,
              child: IconButton(
                icon: Icon(Icons.delete_outline, size: iconSize),
                color: cs.error,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: buttonSize,
                  height: buttonSize,
                ),
                tooltip: 'Obriši stavku',
                onPressed: () => _potvrdiObris(context),
              ),
            ),
          ),
        ],
      );
    }

    Widget labeledField(String label, Widget field) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          field,
        ],
      );
    }

    final statusChips = [
      if (prikaziPreporuceno)
        statusChip(
          label: widget.preporucenoLabel,
          backgroundColor: cs.tertiaryContainer.withValues(alpha: 0.9),
          borderColor: cs.tertiary.withValues(alpha: 0.35),
          foregroundColor: cs.onTertiaryContainer,
          compact: isNarrowAndroid,
        ),
      if (prikaziBiohazard)
        statusChip(
          label: 'ZARAZNA BOLEST',
          backgroundColor: cs.errorContainer.withValues(alpha: 0.9),
          borderColor: cs.error.withValues(alpha: 0.35),
          foregroundColor: cs.onErrorContainer,
          compact: isNarrowAndroid,
        ),
      if (prikaziStanjeRobeUpozorenje)
        statusChip(
          label: 'NIJE NA STANJU',
          backgroundColor: cs.errorContainer.withValues(alpha: 0.95),
          borderColor: cs.error.withValues(alpha: 0.45),
          foregroundColor: cs.onErrorContainer,
          compact: isNarrowAndroid,
        ),
    ];

    final stockWarningText = stockConsequence == null
        ? ''
        : 'Artikal nije na stanju. '
              'Zatvaranje je blokirano dok se problem ne reši.';

    final nazivField = TextFormField(
      controller: _nazivCtrl,
      enabled: fe,
      decoration: rowDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      style: TextStyle(
        fontSize: 13,
        color: aktivan ? null : cs.onSurfaceVariant,
      ),
      onChanged: (_) => _scheduleSave(),
    );

    final row = isNarrowAndroid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: labeledField('NAZIV', nazivField))],
              ),
              if (statusChips.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: statusChips),
              ],
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: labeledField('KOM', quantityField())),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: labeledField('IZNOS (RSD)', amountField()),
                  ),
                ],
              ),
              if (e) ...[
                const SizedBox(height: 10),
                actionButtons(compact: true),
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(child: nazivField),
                    if (statusChips.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: statusChips),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              quantityField(width: 70),
              const SizedBox(width: 8),
              amountField(width: 120),
              if (e) ...[const SizedBox(width: 8), actionButtons()],
            ],
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(isNarrowAndroid ? 10 : 6),
      decoration: BoxDecoration(
        color: prikaziStanjeRobeUpozorenje
            ? cs.errorContainer.withValues(alpha: 0.18)
            : aktivan
            ? cs.surface
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(isNarrowAndroid ? 10 : 6),
        border: Border.all(
          color: prikaziStanjeRobeUpozorenje
              ? cs.error.withValues(alpha: 0.55)
              : aktivan
              ? cs.outlineVariant
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          if (prikaziStanjeRobeUpozorenje) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_outlined, size: 18, color: cs.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    stockWarningText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtikliPickerContent extends StatefulWidget {
  const _ArtikliPickerContent({
    required this.podesavanjaRepo,
    required this.artikli,
    required this.onIzabrano,
    required this.onZatvori,
    required this.crossAxisCount,
    required this.childAspectRatio,
    this.scrollCtrl,
    this.showDragHandle = false,
    this.showHeader = true,
    this.showCancelAction = true,
  });

  final PodesavanjaRepository podesavanjaRepo;
  final List<KatalogPickerArticleSummary> artikli;
  final void Function(
    String naziv,
    double cena,
    String? katalogStableArticleId,
    String interniNazivKategorije,
  )
  onIzabrano;
  final VoidCallback onZatvori;
  final int crossAxisCount;
  final double childAspectRatio;
  final ScrollController? scrollCtrl;
  final bool showDragHandle;
  final bool showHeader;
  final bool showCancelAction;

  @override
  State<_ArtikliPickerContent> createState() => _ArtikliPickerContentState();
}

class _ArtikliPickerContentState extends State<_ArtikliPickerContent> {
  final Map<int, Future<Uint8List?>> _photoFuturesByArticleId = {};
  KatalogPickerArticleSummary? _pregledArtikla;

  Future<Uint8List?> _photoFutureFor(KatalogPickerArticleSummary artikl) {
    if (!artikl.hasPhoto) {
      return Future<Uint8List?>.value(null);
    }
    return _photoFuturesByArticleId.putIfAbsent(
      artikl.id,
      () => widget.podesavanjaRepo.getKatalogArticlePhotoById(artikl.id),
    );
  }

  void _otvoriPregled(KatalogPickerArticleSummary artikl) {
    setState(() => _pregledArtikla = artikl);
  }

  void _zatvoriPregled() {
    setState(() => _pregledArtikla = null);
  }

  void _izaberiArtikl(KatalogPickerArticleSummary artikl) {
    _zatvoriPregled();
    widget.onZatvori();
    widget.onIzabrano(
      artikl.naziv,
      artikl.cena,
      artikl.stableArticleId,
      artikl.interniNazivKategorije,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showDragHandle)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withAlpha(76),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            if (widget.showHeader) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Izaberi artikl',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: GridView.builder(
                controller: widget.scrollCtrl,
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: widget.childAspectRatio,
                ),
                itemCount: widget.artikli.length,
                itemBuilder: (_, i) {
                  final a = widget.artikli[i];
                  return _ArtiklKartica(
                    photoFuture: _photoFutureFor(a),
                    artikl: a,
                    onIzabrano: () => _izaberiArtikl(a),
                    onPregledaj: () => _otvoriPregled(a),
                  );
                },
              ),
            ),
            if (widget.showCancelAction)
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: widget.onZatvori,
                  child: const Text('ODUSTANI'),
                ),
              ),
          ],
        ),
        if (_pregledArtikla != null)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, viewportConstraints) {
                final viewportWidth = viewportConstraints.maxWidth;
                final viewportHeight = viewportConstraints.maxHeight;
                final shortOrWidePreview =
                    viewportWidth >= 720 || viewportWidth > viewportHeight;
                final dialogHorizontalMargin = shortOrWidePreview ? 20.0 : 8.0;
                final dialogMaxWidth =
                    (viewportWidth - (dialogHorizontalMargin * 2))
                        .clamp(280.0, shortOrWidePreview ? 920.0 : 640.0)
                        .toDouble();
                final dialogMaxHeight =
                    viewportHeight * (shortOrWidePreview ? 0.88 : 0.84);
                final previewHasPhoto = _pregledArtikla!.hasPhoto;

                Widget previewImage({
                  required EdgeInsetsGeometry padding,
                  bool compactNoPhoto = false,
                }) {
                  return Padding(
                    padding: padding,
                    child: FutureBuilder<Uint8List?>(
                      future: _photoFutureFor(_pregledArtikla!),
                      builder: (context, snapshot) {
                        final bytes = snapshot.data;
                        if (bytes != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: KatalogPhotoPolicy.memoryImage(
                              bytes,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                              cacheWidth:
                                  KatalogPhotoPolicy.previewDecodeTarget(
                                    context,
                                  ),
                              cacheHeight:
                                  KatalogPhotoPolicy.previewDecodeTarget(
                                    context,
                                  ),
                              errorBuilder: (_, e, st) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 80,
                                ),
                              ),
                            ),
                          );
                        }
                        if (_pregledArtikla!.hasPhoto &&
                            snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        final noPhotoIconSize = compactNoPhoto ? 36.0 : 80.0;
                        final noPhotoContent = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: noPhotoIconSize,
                              color: cs.onSurfaceVariant,
                            ),
                            if (compactNoPhoto) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Nema fotografije',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        );
                        if (compactNoPhoto) {
                          return Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withValues(
                                  alpha: 0.55,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: noPhotoContent,
                              ),
                            ),
                          );
                        }
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                          ),
                        );
                      },
                    ),
                  );
                }

                Widget previewMeta({
                  required EdgeInsetsGeometry padding,
                  required Alignment actionsAlignment,
                  required TextAlign textAlign,
                }) {
                  return SingleChildScrollView(
                    padding: padding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _pregledArtikla!.naziv,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: textAlign,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatMoneyNumber(_pregledArtikla!.cena)} RSD',
                          style: TextStyle(color: cs.onSurfaceVariant),
                          textAlign: textAlign,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: actionsAlignment,
                          child: OverflowBar(
                            alignment: MainAxisAlignment.end,
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: _zatvoriPregled,
                                child: const Text('ZATVORI'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    _izaberiArtikl(_pregledArtikla!),
                                child: const Text('IZABERI'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: dialogMaxWidth,
                        maxHeight: dialogMaxHeight,
                      ),
                      child: Material(
                        color:
                            Theme.of(context).dialogTheme.backgroundColor ??
                            Theme.of(context).colorScheme.surface,
                        elevation: 24,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final useWideLayout =
                                shortOrWidePreview &&
                                constraints.maxWidth >= 560 &&
                                constraints.maxHeight <= 560;

                            if (useWideLayout) {
                              final sidePanelWidth =
                                  (constraints.maxWidth * 0.34)
                                      .clamp(220.0, 300.0)
                                      .toDouble();
                              if (!previewHasPhoto) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 104,
                                      ),
                                      child: previewImage(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          12,
                                          12,
                                          8,
                                        ),
                                        compactNoPhoto: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: cs.outlineVariant,
                                            ),
                                          ),
                                        ),
                                        child: previewMeta(
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            12,
                                            16,
                                            14,
                                          ),
                                          actionsAlignment:
                                              Alignment.centerRight,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: previewImage(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        8,
                                        12,
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: sidePanelWidth,
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: cs.outlineVariant,
                                          ),
                                        ),
                                      ),
                                      child: previewMeta(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          16,
                                          12,
                                          16,
                                        ),
                                        actionsAlignment: Alignment.centerRight,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            final metadataMaxHeight =
                                constraints.maxHeight * 0.32;
                            if (!previewHasPhoto) {
                              final noPhotoMaxHeight =
                                  (constraints.maxHeight * 0.28)
                                      .clamp(88.0, 128.0)
                                      .toDouble();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: noPhotoMaxHeight,
                                    ),
                                    child: previewImage(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        8,
                                      ),
                                      compactNoPhoto: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: cs.outlineVariant,
                                          ),
                                        ),
                                      ),
                                      child: previewMeta(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          10,
                                          12,
                                          14,
                                        ),
                                        actionsAlignment: Alignment.centerRight,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: previewImage(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      12,
                                      8,
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: cs.outlineVariant),
                                    ),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: metadataMaxHeight,
                                    ),
                                    child: previewMeta(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        10,
                                        12,
                                        14,
                                      ),
                                      actionsAlignment: Alignment.centerRight,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ArtiklKartica extends StatelessWidget {
  const _ArtiklKartica({
    required this.artikl,
    required this.photoFuture,
    required this.onIzabrano,
    required this.onPregledaj,
  });

  final KatalogPickerArticleSummary artikl;
  final Future<Uint8List?> photoFuture;
  final VoidCallback onIzabrano;
  final VoidCallback onPregledaj;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onPregledaj,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FutureBuilder<Uint8List?>(
                    future: photoFuture,
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      if (bytes != null) {
                        return KatalogPhotoPolicy.memoryImage(
                          bytes,
                          fit: BoxFit.cover,
                          cacheWidth:
                              KatalogPhotoPolicy.gridThumbnailDecodeTarget(
                                context,
                              ),
                          cacheHeight:
                              KatalogPhotoPolicy.gridThumbnailDecodeTarget(
                                context,
                              ),
                          errorBuilder: (_, e, st) =>
                              const Icon(Icons.broken_image_outlined, size: 40),
                        );
                      }
                      if (artikl.hasPhoto &&
                          snapshot.connectionState != ConnectionState.done) {
                        return Container(
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Container(
                        color: cs.surfaceContainerHighest,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              artikl.naziv,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '${formatMoneyNumber(artikl.cena)} RSD',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 0),
                minimumSize: const Size.fromHeight(28),
                textStyle: const TextStyle(fontSize: 12),
              ),
              onPressed: onIzabrano,
              child: const Text('IZABERI'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtikliPicker extends StatelessWidget {
  const _ArtikliPicker({
    required this.podesavanjaRepo,
    required this.artikli,
    required this.onIzabrano,
  });

  final PodesavanjaRepository podesavanjaRepo;
  final List<KatalogPickerArticleSummary> artikli;
  final void Function(
    String naziv,
    double cena,
    String? katalogStableArticleId,
    String interniNazivKategorije,
  )
  onIzabrano;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return SafeArea(
          child: OrientationBuilder(
            builder: (ctx, orientation) {
              final landscape = orientation == Orientation.landscape;
              return _ArtikliPickerContent(
                podesavanjaRepo: podesavanjaRepo,
                artikli: artikli,
                onIzabrano: onIzabrano,
                onZatvori: () => Navigator.pop(context),
                crossAxisCount: landscape ? 3 : 2,
                childAspectRatio: landscape ? 0.95 : 0.9,
                scrollCtrl: scrollCtrl,
                showDragHandle: true,
                showHeader: true,
                showCancelAction: true,
              );
            },
          ),
        );
      },
    );
  }
}

class _ArtikliPickerDialog extends StatelessWidget {
  const _ArtikliPickerDialog({
    required this.podesavanjaRepo,
    required this.artikli,
    required this.onIzabrano,
  });

  final PodesavanjaRepository podesavanjaRepo;
  final List<KatalogPickerArticleSummary> artikli;
  final void Function(
    String naziv,
    double cena,
    String? katalogStableArticleId,
    String interniNazivKategorije,
  )
  onIzabrano;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 360,
          maxWidth: 680,
          maxHeight: screenH * 0.86,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.library_books_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Izaberi artikl',
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
            const Divider(height: 1),
            Flexible(
              child: _ArtikliPickerContent(
                podesavanjaRepo: podesavanjaRepo,
                artikli: artikli,
                onIzabrano: onIzabrano,
                onZatvori: () => Navigator.pop(context),
                crossAxisCount: 3,
                childAspectRatio: 1.08,
                showHeader: false,
                showCancelAction: false,
              ),
            ),
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
        ),
      ),
    );
  }
}
