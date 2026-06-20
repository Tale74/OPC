import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../core_v2/models/iriu_truth_models.dart';
import '../../core_v2/services/financial_truth_service.dart';
import '../../core_v2/services/predmet_iriu_truth_service.dart';
import '../../data/iriu_repository.dart';
import 'predmet_decision_controls.dart';

/// Segment 6: FINANSIJSKI PREGLED.
class FinansijeSegment extends StatefulWidget {
  const FinansijeSegment({
    super.key,
    required this.initialData,
    required this.predmetId,
    required this.iriuRepo,
    required this.enabled,
    required this.onSave,
    required this.refundacijaPioIznos,
  });

  final PredmetiData initialData;
  final int predmetId;
  final IriuRepository iriuRepo;
  final bool enabled;
  final void Function(PredmetiCompanion) onSave;
  /// Iznos refundacije PIO fond-a — čita se iz AppPodesavanja.
  final double refundacijaPioIznos;

  @override
  State<FinansijeSegment> createState() => _FinansijeSegmentState();
}

class _FinansijeSegmentState extends State<FinansijeSegment> {
  static const _predmetIriuTruthService = PredmetIriuTruthService();
  static const _financialTruthService = FinancialTruthService();

  Timer? _debounce;
  String? _lastPredmetTruthSignature;
  String? _lastIriuTruthSignature;
  PredmetIriuTruthSnapshot? _cachedTruthSnapshot;
  double? _cachedRobaIUsluge;

  bool _platilaciRefundira = false;
  late final TextEditingController _avansCtrl;
  late final TextEditingController _troskoviJkpCtrl;
  bool _jkpPlacaSamostalno = false;
  late final TextEditingController _popustCtrl;
  Set<String> _nacinPlacanja = {};
  late final TextEditingController _napomenaPlacanjCtrl;

  static const _nacinOpcije = [
    ('KES', 'Gotovina'),
    ('KARTICA', 'Kartica'),
    ('PRENOS', 'Prenos'),
    ('CEKOVI', 'Čekovima'),
    ('NA_RATE', 'Na rate'),
  ];

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;

    _platilaciRefundira = d.narucilacRefundira == 'DA';
    _avansCtrl = TextEditingController(
      text: d.avans > 0 ? formatMoneyNumber(d.avans) : '',
    );
    _troskoviJkpCtrl = TextEditingController(
      text: d.troskoviJkp > 0 ? formatMoneyNumber(d.troskoviJkp) : '',
    );
    _jkpPlacaSamostalno = d.jkpPlacaSamostalno;
    _popustCtrl = TextEditingController(
      text: d.popust > 0 ? formatMoneyNumber(d.popust) : '',
    );
    _napomenaPlacanjCtrl =
        TextEditingController(text: d.napomenaPlacanja);

    try {
      final decoded = jsonDecode(d.nacinPlacanja);
      if (decoded is List) {
        _nacinPlacanja = Set<String>.from(decoded.cast<String>());
      }
    } catch (_) {
      _nacinPlacanja = {};
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _avansCtrl,
      _troskoviJkpCtrl,
      _popustCtrl,
      _napomenaPlacanjCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  void _save() {
    widget.onSave(
      PredmetiCompanion(
        narucilacRefundira: Value(_platilaciRefundira ? 'DA' : 'NE'),
        refundacijaPio: Value(_refundacijaPioSettingForPredmet()),
        avans: Value(parseMoneyInput(_avansCtrl.text)),
        troskoviJkp: Value(parseMoneyInput(_troskoviJkpCtrl.text)),
        jkpPlacaSamostalno: Value(_jkpPlacaSamostalno),
        popust: Value(parseMoneyInput(_popustCtrl.text)),
        nacinPlacanja: Value(jsonEncode(_nacinPlacanja.toList())),
        napomenaPlacanja: Value(_normalizedText(_napomenaPlacanjCtrl)),
      ),
    );
  }

  void _toggleNacinPlacanja(String kljuc, bool selected) {
    setState(() {
      if (selected) {
        _nacinPlacanja = {..._nacinPlacanja, kljuc};
      } else {
        _nacinPlacanja = _nacinPlacanja.where((k) => k != kljuc).toSet();
      }
    });
    _scheduleSave();
  }

  double _refundacijaPioSettingForPredmet() {
    if (widget.initialData.penzionerSrbije != 'DA') return 0.0;
    return widget.refundacijaPioIznos > 0 ? widget.refundacijaPioIznos : 0.0;
  }

  String _predmetTruthSignature(PredmetiData predmet) {
    return [
      normalizeText(predmet.mestoSmrti),
      predmet.tipGroblja,
      predmet.tipGrobnogMesta,
      predmet.uzrokSmrti,
      predmet.vrstaCeremonije,
      predmet.sahranaVanSrbije ? '1' : '0',
      predmet.docekPosmrtnihOstataka ? '1' : '0',
    ].join('|');
  }

  String _iriuTruthSignature(List<IriuData> stavke) {
    return stavke
        .map(
          (stavka) => [
            stavka.id,
            stavka.interniNaziv,
            stavka.redosled,
            stavka.iznos,
          ].join('|'),
        )
        .join('||');
  }

  double _resolveRobaIUsluge(PredmetiData predmet, List<IriuData> stavke) {
    final predmetSignature = _predmetTruthSignature(predmet);
    final iriuSignature = _iriuTruthSignature(stavke);
    final canReuse = _cachedTruthSnapshot != null &&
        _cachedRobaIUsluge != null &&
        _lastPredmetTruthSignature == predmetSignature &&
        _lastIriuTruthSignature == iriuSignature;

    if (canReuse) {
      return _cachedRobaIUsluge!;
    }

    final truthSnapshot = _predmetIriuTruthService.evaluate(
      predmet: predmet,
      storedRows: stavke,
    );
    final robaIUsluge = _financialTruthService
        .buildRobaIUsluge(truthSnapshot)
        .robaIUsluge;

    _lastPredmetTruthSignature = predmetSignature;
    _lastIriuTruthSignature = iriuSignature;
    _cachedTruthSnapshot = truthSnapshot;
    _cachedRobaIUsluge = robaIUsluge;

    return robaIUsluge;
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    final d = widget.initialData;

    // Refundacija PIO: prikazuje se kada je penzioner Srbije.
    // Čekboks PLATILAC REFUNDIRA određuje da li se iznos
    // oduzima od robe (NE → oduzima se, DA → platilac sam refundira).
    final prikazRefundacije = d.penzionerSrbije == 'DA';
    final refund = prikazRefundacije && !_platilaciRefundira
        ? _refundacijaPioSettingForPredmet()
        : 0.0;

    return _withCheckboxVisibilityTheme(
      context,
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── IRIU zbir (reaktivni) ─────────────────────────────────────
            _sectionTitle(context, 'USLOVI I KOREKCIJE'),
            const SizedBox(height: 8),
            if (prikazRefundacije) ...[
              PredmetBooleanDecisionTile(
                title: 'REFUNDACIJA PIO U KORIST PLATIOCA',
                subtitle:
                    'Platilac samostalno ostvaruje refundaciju kod PIO fonda',
                value: _platilaciRefundira,
                enabled: e,
                onChanged: (v) => setState(() {
                  _platilaciRefundira = v;
                  _scheduleSave();
                }),
              ),
              const SizedBox(height: 12),
            ],
            _FinansijeFieldWithDecision(
              field: TextFormField(
                controller: _troskoviJkpCtrl,
                enabled: e,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _moneyFieldDecoration('TROŠKOVI JKP'),
                onChanged: (_) => _scheduleSave(),
                onEditingComplete: () => _formatField(_troskoviJkpCtrl),
              ),
              decision: PredmetBooleanDecisionTile(
                title: 'TROŠKOVI JKP OBAVEZA PLATIOCA',
                value: _jkpPlacaSamostalno,
                enabled: e,
                onChanged: (v) => setState(() {
                  _jkpPlacaSamostalno = v;
                  _scheduleSave();
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _avansCtrl,
                    enabled: e,
                    textAlign: TextAlign.right,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _moneyFieldDecoration('AVANS'),
                    onChanged: (_) => _scheduleSave(),
                    onEditingComplete: () => _formatField(_avansCtrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _popustCtrl,
                    enabled: e,
                    textAlign: TextAlign.right,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _moneyFieldDecoration('POPUST'),
                    onChanged: (_) => _scheduleSave(),
                    onEditingComplete: () => _formatField(_popustCtrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            _sectionTitle(context, 'PREGLED UKUPNOG OBRAČUNA'),
            const SizedBox(height: 8),
            StreamBuilder<List<IriuData>>(
              stream: widget.iriuRepo.watchIriu(widget.predmetId),
              builder: (context, snap) {
                final stavke = snap.data ?? [];
                final robaSum = _resolveRobaIUsluge(d, stavke);
                final jkpDodatak = _jkpPlacaSamostalno
                    ? 0.0
                    : parseMoneyInput(_troskoviJkpCtrl.text);
                final avans = parseMoneyInput(_avansCtrl.text);
                final popust = parseMoneyInput(_popustCtrl.text);

                // Spec §10.1 formula:
                // ROBA
                // [– REFUNDACIJA PIO → + DOPLATA] (ako uslov za refundaciju)
                // [– AVANS → OSTATAK] (ako avans > 0)
                // [+ TROŠKOVI JKP] (ako > 0 i ne plaća samostalno)
                // [UKUPNO] (međuvrednost — prikazuje se samo ako ima popusta)
                // [– POPUST]
                // = ZA NAPLATU

                final posleRefundacije = robaSum - refund;
                final doplata = refund > 0 ? posleRefundacije : robaSum;
                final ostatak = avans > 0 ? doplata - avans : doplata;
                final saJkp = ostatak + jkpDodatak;
                final zaNaplatu = saJkp - popust;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _iznos(context, 'ROBA I USLUGE', robaSum),
                    if (refund > 0) ...[
                      _iznos(context, 'REFUNDACIJA PIO', -refund,
                          color: Colors.green.shade700),
                      _iznos(context, 'DOPLATA', posleRefundacije),
                    ],
                    if (avans > 0) ...[
                      _iznos(context, 'AVANS', -avans,
                          color: Colors.blue.shade700),
                      _iznos(context, 'OSTATAK', ostatak),
                    ],
                    if (jkpDodatak > 0)
                      _iznos(context, 'TROŠKOVI JKP', jkpDodatak),
                    if (popust > 0) ...[
                      _iznos(context, 'UKUPNO', saJkp),
                      _iznos(context, 'POPUST', -popust,
                          color: Colors.orange.shade700),
                    ],
                    const Divider(height: 12),
                    _iznos(context, 'ZA NAPLATU', zaNaplatu,
                        bold: true, large: true),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // ── Editable polja ────────────────────────────────────────────
            // ── Refundacija PIO (vidljivo samo kada uslov ispunjen) ───────
            const SizedBox(height: 16),
            // ── Način plaćanja ────────────────────────────────────────────
            _sectionTitle(context, 'NAČIN PLAĆANJA'),
            const SizedBox(height: 8),
            Text(
              'Opcije plaćanja',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _nacinOpcije.map((t) {
                final selected = _nacinPlacanja.contains(t.$1);
                return PredmetSelectionChip(
                  label: t.$2,
                  selected: selected,
                  enabled: e,
                  onSelected: (v) => _toggleNacinPlacanja(t.$1, v),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // ── Napomena plaćanja ─────────────────────────────────────────
            const Divider(),
            const SizedBox(height: 8),
            _sectionTitle(context, 'NAPOMENE'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _napomenaPlacanjCtrl,
              enabled: e,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'NAPOMENA PLAĆANJA',
                border: OutlineInputBorder(),
                isDense: true,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _scheduleSave(),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _withCheckboxVisibilityTheme(BuildContext context, Widget child) {
    final baseTheme = Theme.of(context);
    final cs = baseTheme.colorScheme;
    return Theme(
      data: baseTheme.copyWith(
        checkboxTheme: baseTheme.checkboxTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(
            color: cs.onSurfaceVariant,
            width: 1.5,
          ),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.primary;
            }
            return cs.surface;
          }),
          checkColor: WidgetStatePropertyAll(cs.onPrimary),
        ),
      ),
      child: child,
    );
  }

  void _formatField(TextEditingController ctrl) {
    if (ctrl.text.trim().isEmpty) return;
    final v = parseMoneyInput(ctrl.text);
    final f = formatMoneyNumber(v);
    if (f != ctrl.text) {
      ctrl.text = f;
      ctrl.selection = TextSelection.collapsed(offset: f.length);
    }
  }

  Widget _sectionTitle(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
    );
  }

  InputDecoration _moneyFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      suffixText: 'RSD',
      border: const OutlineInputBorder(),
      isDense: false,
      constraints: const BoxConstraints(minHeight: 64),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 18,
      ),
    );
  }

  Widget _iznos(
    BuildContext context,
    String label,
    double value, {
    bool bold = false,
    bool large = false,
    Color? color,
  }) {
    final textStyle = TextStyle(
      fontSize: large ? 16 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: textStyle),
          ),
          Text(formatMoneyRsd(value), style: textStyle),
        ],
      ),
    );
  }
}

class _FinansijeFieldWithDecision extends StatelessWidget {
  const _FinansijeFieldWithDecision({
    required this.field,
    required this.decision,
  });

  final Widget field;
  final Widget decision;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field,
              const SizedBox(height: 8),
              decision,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: field),
            const SizedBox(width: 12),
            Expanded(child: decision),
          ],
        );
      },
    );
  }
}
