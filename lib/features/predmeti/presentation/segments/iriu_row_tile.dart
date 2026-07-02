import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

int resolveCatalogDetailNavigationIndex({
  required int currentIndex,
  required int offset,
  required int articleCount,
}) {
  if (articleCount <= 0) return 0;
  return (currentIndex + offset).clamp(0, articleCount - 1);
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
  late final FocusNode _iznosFocusNode;
  late double _lastValidIznos;
  bool _iznosInvalid = false;

  bool _mozeIzgledatiKaoDostupanKatalog(bool? imaArtikala) {
    return imaArtikala ?? false;
  }

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  double _parsedIznos() =>
      tryParseSerbianManualAmount(_iznosCtrl.text) ?? _lastValidIznos;

  void _normalizeIznosDisplay() {
    final formatted = normalizeSerbianManualAmount(_iznosCtrl.text);
    if (formatted == null) {
      if (!_iznosInvalid && mounted) setState(() => _iznosInvalid = true);
      return;
    }
    _lastValidIznos = tryParseSerbianManualAmount(_iznosCtrl.text) ?? 0.0;
    if (formatted == _iznosCtrl.text && !_iznosInvalid) return;
    setState(() {
      _iznosInvalid = false;
      _iznosCtrl.text = formatted;
      _iznosCtrl.selection = TextSelection.collapsed(offset: formatted.length);
    });
  }

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
    _lastValidIznos = s.iznos;
    _iznosFocusNode = FocusNode();
    _iznosFocusNode.addListener(() {
      if (!_iznosFocusNode.hasFocus) _normalizeIznosDisplay();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nazivCtrl.dispose();
    _komCtrl.dispose();
    _iznosCtrl.dispose();
    _iznosFocusNode.dispose();
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
      _lastValidIznos = cena;
      _iznosInvalid = false;
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
        focusNode: _iznosFocusNode,
        enabled: fe,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: rowDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ).copyWith(errorText: _iznosInvalid ? 'Neispravan iznos' : null),
        style: TextStyle(
          fontSize: 13,
          color: aktivan ? null : cs.onSurfaceVariant,
        ),
        onChanged: (_) {
          final parsed = tryParseSerbianManualAmount(_iznosCtrl.text);
          setState(() => _iznosInvalid = parsed == null);
          if (parsed != null) {
            _lastValidIznos = parsed;
            _scheduleSave();
          } else {
            _debounce?.cancel();
          }
        },
        onEditingComplete: () {
          _normalizeIznosDisplay();
          _iznosFocusNode.unfocus();
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

  Future<Uint8List?> _photoFutureFor(KatalogPickerArticleSummary artikl) {
    if (!artikl.hasPhoto) {
      return Future<Uint8List?>.value(null);
    }
    return _photoFuturesByArticleId.putIfAbsent(
      artikl.id,
      () => widget.podesavanjaRepo.getKatalogArticlePhotoById(artikl.id),
    );
  }

  Future<void> _otvoriPregled(KatalogPickerArticleSummary artikl) async {
    final selected = await showDialog<KatalogPickerArticleSummary>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black87,
      builder: (context) => _CatalogArticleDetailViewer(
        artikli: widget.artikli,
        initialIndex: widget.artikli.indexOf(artikl),
        photoFutureFor: _photoFutureFor,
      ),
    );
    if (selected != null && mounted) {
      _izaberiArtikl(selected);
    }
  }

  void _izaberiArtikl(KatalogPickerArticleSummary artikl) {
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
    return Column(
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
    );
  }
}

class _CatalogArticleDetailViewer extends StatefulWidget {
  const _CatalogArticleDetailViewer({
    required this.artikli,
    required this.initialIndex,
    required this.photoFutureFor,
  });

  final List<KatalogPickerArticleSummary> artikli;
  final int initialIndex;
  final Future<Uint8List?> Function(KatalogPickerArticleSummary article)
  photoFutureFor;

  @override
  State<_CatalogArticleDetailViewer> createState() =>
      _CatalogArticleDetailViewerState();
}

class _CatalogArticleDetailViewerState
    extends State<_CatalogArticleDetailViewer> {
  late int _currentIndex;

  KatalogPickerArticleSummary get _article => widget.artikli[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.artikli.length - 1);
  }

  void _move(int offset) {
    final next = resolveCatalogDetailNavigationIndex(
      currentIndex: _currentIndex,
      offset: offset,
      articleCount: widget.artikli.length,
    );
    if (next != _currentIndex) {
      setState(() => _currentIndex = next);
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _move(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final isWide = size.width >= 700 || size.width > size.height;
    final margin = Theme.of(context).platform == TargetPlatform.android
        ? 8.0
        : 20.0;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Dialog(
        insetPadding: EdgeInsets.all(margin),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size.width - margin * 2,
          height: size.height - media.padding.vertical - margin * 2,
          child: isWide ? _buildWide(context) : _buildPortrait(context),
        ),
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildImageWithNavigation(context)),
        SizedBox(width: 300, child: _buildInfo(context, centered: false)),
      ],
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildImageWithNavigation(context)),
        _buildInfo(context, centered: true),
      ],
    );
  }

  Widget _buildImageWithNavigation(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<Uint8List?>(
            future: widget.photoFutureFor(_article),
            builder: (context, snapshot) {
              final bytes = snapshot.data;
              if (bytes != null) {
                return KatalogPhotoPolicy.memoryImage(
                  bytes,
                  fit: BoxFit.contain,
                  cacheWidth: KatalogPhotoPolicy.previewDecodeTarget(context),
                  cacheHeight: KatalogPhotoPolicy.previewDecodeTarget(context),
                  errorBuilder: (_, e, st) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 80),
                  ),
                );
              }
              if (_article.hasPhoto &&
                  snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 80),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _navigationButton(
            key: const Key('catalog-detail-previous'),
            icon: Icons.chevron_left,
            tooltip: 'Prethodni artikl',
            onPressed: _currentIndex > 0 ? () => _move(-1) : null,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _navigationButton(
            key: const Key('catalog-detail-next'),
            icon: Icons.chevron_right,
            tooltip: 'Sledeci artikl',
            onPressed: _currentIndex < widget.artikli.length - 1
                ? () => _move(1)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _navigationButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black54,
        shape: const CircleBorder(),
        child: IconButton(
          key: key,
          tooltip: tooltip,
          color: Colors.white,
          disabledColor: Colors.white38,
          iconSize: 36,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, {required bool centered}) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: centered
              ? BorderSide(color: cs.outlineVariant)
              : BorderSide.none,
          left: centered
              ? BorderSide.none
              : BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: centered
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Text(
                _article.naziv,
                key: const Key('catalog-detail-title'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: centered ? TextAlign.center : TextAlign.left,
              ),
              const SizedBox(height: 6),
              Text(
                '${formatMoneyNumber(_article.cena)} RSD',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: centered ? TextAlign.center : TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentIndex + 1} / ${widget.artikli.length}',
                textAlign: centered ? TextAlign.center : TextAlign.left,
              ),
              const SizedBox(height: 16),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ZATVORI'),
                  ),
                  FilledButton(
                    key: const Key('catalog-detail-select'),
                    onPressed: () => Navigator.pop(context, _article),
                    child: const Text('IZABERI'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
