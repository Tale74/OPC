import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../core_v2/rules/iriu_truth_rules.dart';
import 'predmet_decision_controls.dart';

enum PreminuloLiceSegmentMode {
  all,
  osnovno,
  cinjeniceOSmrti,
  statusi,
}

/// Segment 1 + 1a: PREMINULO LICE i RADNI STATUS.
class PreminuloLiceSegment extends StatefulWidget {
  const PreminuloLiceSegment({
    super.key,
    required this.initialData,
    required this.enabled,
    required this.onSave,
    this.mode = PreminuloLiceSegmentMode.all,
  });

  final PredmetiData initialData;
  final bool enabled;
  final void Function(PredmetiCompanion) onSave;
  final PreminuloLiceSegmentMode mode;

  @override
  State<PreminuloLiceSegment> createState() => _PreminuloLiceSegmentState();
}

class _PreminuloLiceSegmentState extends State<PreminuloLiceSegment> {
  Timer? _debounce;

  // ── Preminulo lice ────────────────────────────────────────────────────────
  late final TextEditingController _imeCtrl;
  late final TextEditingController _prezimeCtrl;
  late final TextEditingController _srednjeCtrl;
  late final TextEditingController _devojackoCtrl;
  late final TextEditingController _jmbgCtrl;
  late final TextEditingController _datumRodjenjaCtrl;
  late final TextEditingController _mestoRodjenjaCtrl;
  late final TextEditingController _datumSmrtiCtrl;
  late final TextEditingController _adresaCtrl;
  late final TextEditingController _imeOcaCtrl;
  late final TextEditingController _imeMajkeCtrl;

  String _pol = 'M';
  String _mestoSmrti = '';
  String _uzrokSmrti = '';
  String _bracnoStanje = '';

  // ── Bračni drug ───────────────────────────────────────────────────────────
  late final TextEditingController _bdImeCtrl;
  late final TextEditingController _bdPrezimeCtrl;
  late final TextEditingController _bdDevojackoCtrl;
  late final TextEditingController _bdJmbgCtrl;
  String _bdPol = 'Z';

  /// Automatski određuje pol bračnog druga prema važećem zakonodavstvu.
  /// Korisnik može ručno promeniti vrednost (za buduće zakonske izmene).
  String get _autoBdPol {
    switch (_bracnoStanje) {
      case 'OŽENJEN':
      case 'UDOVAC':
      case 'RAZVEDEN':
      case 'NEOŽENJEN':
        return 'Z';
      case 'UDATA':
      case 'UDOVICA':
      case 'RAZVEDENA':
      case 'NEUDATA':
        return 'M';
      default: // VANBRAČNA ZAJEDNICA ili prazno → suprotan od pola preminulog
        return _pol == 'M' ? 'Z' : 'M';
    }
  }

  // ── Radni status ──────────────────────────────────────────────────────────
  // Višestruki izbor: PENZIONER_SRBIJE, VOJNI_PENZIONER, INOSTRANI_PENZIONER,
  // U_RADNOM_ODNOSU, DRUGO — čuvaju se kao JSON niz u koloni radniStatus.
  Set<String> _radniStatusSet = {};
  bool _vojnePocasti = false;
  bool _posmrtnaPomoc = false;
  bool _bracniDrugOstvarujePravo = false;
  bool _bracniDrugJePenzioner = false;
  late final TextEditingController _cinCtrlRS;
  late final TextEditingController _radniStatusNapomenaCtrl;

  // ── Blur validacija ───────────────────────────────────────────────────────
  final _imeFocus = FocusNode();
  final _prezimeFocus = FocusNode();
  final _devojackoFocus = FocusNode();
  bool _imeTouched = false;
  bool _prezimeTouched = false;
  bool _devojackoNeedsAttention = false;

  static const _radniStatusOpcije = [
    ('PENZIONER_SRBIJE', 'Penzioner Republike Srbije'),
    ('VOJNI_PENZIONER', 'Vojni penzioner'),
    ('INOSTRANI_PENZIONER', 'Inostrani penzioner'),
    ('U_RADNOM_ODNOSU', 'U radnom odnosu'),
    ('DRUGO', 'Drugo'),
  ];

  static const _mestoSmrtiOpcije = [
    'STAN',
    'DOM ZA STARE',
    'BOLNICA',
    IriuTruthRules.mestoSmrtiUlicaJavnoMesto,
    'DRUGO',
  ];
  static const _uzrokSmrtiOpcije = [
    'PRIRODNA',
    'NASILNA',
    'ZARAZNA',
    'NEDEFINISANA',
  ];
  static const _bracnaStanjaOpcije = [
    'OŽENJEN',
    'UDATA',
    'UDOVAC',
    'UDOVICA',
    'RAZVEDEN',
    'RAZVEDENA',
    'NEOŽENJEN',
    'NEUDATA',
    'VANBRAČNA ZAJEDNICA',
  ];
  static const _saBracnimDrugom = {
    'OŽENJEN',
    'UDATA',
    'UDOVAC',
    'UDOVICA',
  };
  static const _mozePravoBD = {'OŽENJEN', 'UDATA'};

  bool get _jePenzionerSrbije =>
      _radniStatusSet.contains('PENZIONER_SRBIJE') ||
      _radniStatusSet.contains('VOJNI_PENZIONER');
  bool get _jeVojniPenzioner => _radniStatusSet.contains('VOJNI_PENZIONER');

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;

    _imeCtrl = TextEditingController(text: d.ime);
    _prezimeCtrl = TextEditingController(text: d.prezime);
    _srednjeCtrl = TextEditingController(text: d.srednje);
    _devojackoCtrl = TextEditingController(text: d.devojackoPrezime);
    _jmbgCtrl = TextEditingController(text: d.jmbg);
    _datumRodjenjaCtrl = TextEditingController(text: d.datumRodjenja);
    _mestoRodjenjaCtrl = TextEditingController(text: d.mestoRodjenja);
    _datumSmrtiCtrl = TextEditingController(text: d.datumSmrti);
    _adresaCtrl = TextEditingController(text: d.adresa);
    _imeOcaCtrl = TextEditingController(text: d.imeOca);
    _imeMajkeCtrl = TextEditingController(text: d.imeMajke);

    _bdImeCtrl = TextEditingController(text: d.bracniDrugIme);
    _bdPrezimeCtrl = TextEditingController(text: d.bracniDrugPrezime);
    _bdDevojackoCtrl = TextEditingController(text: d.bracniDrugDevojacko);
    _bdJmbgCtrl = TextEditingController(text: d.bracniDrugJmbg);

    _cinCtrlRS = TextEditingController(text: d.cin);
    _radniStatusNapomenaCtrl =
        TextEditingController(text: d.penzionerNapomena);

    _pol = d.pol.isNotEmpty ? d.pol : 'M';
    _mestoSmrti = IriuTruthRules.normalizeMestoSmrti(d.mestoSmrti);
    _uzrokSmrti = d.uzrokSmrti;
    _bracnoStanje = d.bracnoStanje;
    _bdPol = d.bracniDrugPol.isNotEmpty ? d.bracniDrugPol : _autoBdPol;
    _devojackoNeedsAttention =
        _pol == 'Z' && _devojackoCtrl.text.trim().isEmpty;

    // Učitaj radniStatus — JSON niz (novi format) ili plain string (stari format)
    // ili inferiraj iz legacy bool polja.
    final rs = d.radniStatus;
    if (rs.isNotEmpty) {
      try {
        final decoded = jsonDecode(rs);
        if (decoded is List) {
          _radniStatusSet = Set<String>.from(decoded.cast<String>());
        } else {
          _radniStatusSet = {rs}; // stari plain string
        }
      } catch (_) {
        _radniStatusSet = {rs}; // stari plain string
      }
    } else {
      // Legacy boolean polja
      if (d.vojniPenzioner == 'DA') {
        _radniStatusSet = {'PENZIONER_SRBIJE', 'VOJNI_PENZIONER'};
      } else if (d.penzionerSrbije == 'DA') {
        _radniStatusSet = {'PENZIONER_SRBIJE'};
      } else if (d.penzioner == 'DA') {
        _radniStatusSet = {'INOSTRANI_PENZIONER'};
      }
    }

    _vojnePocasti = d.vojnePocasti == 'DA';
    _posmrtnaPomoc = d.posmrtnaPomoc == 'DA';
    _bracniDrugOstvarujePravo = d.bracniDrugOstvarujePravo == 'DA';
    _bracniDrugJePenzioner = d.bracniDrugJePenzioner == 'DA';

    // Blur validacija — prikazuje grešku samo nakon napuštanja polja
    _imeFocus.addListener(() {
      if (!_imeFocus.hasFocus) setState(() => _imeTouched = true);
    });
    _prezimeFocus.addListener(() {
      if (!_prezimeFocus.hasFocus) setState(() => _prezimeTouched = true);
    });
    _devojackoFocus.addListener(() {
      if (!_devojackoFocus.hasFocus) {
        setState(() {
          _devojackoNeedsAttention = _devojackoCtrl.text.trim().isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _imeCtrl, _prezimeCtrl, _srednjeCtrl, _devojackoCtrl, _jmbgCtrl,
      _datumRodjenjaCtrl, _mestoRodjenjaCtrl, _datumSmrtiCtrl, _adresaCtrl,
      _imeOcaCtrl, _imeMajkeCtrl,
      _bdImeCtrl, _bdPrezimeCtrl, _bdDevojackoCtrl, _bdJmbgCtrl,
      _cinCtrlRS, _radniStatusNapomenaCtrl,
    ]) {
      c.dispose();
    }
    _imeFocus.dispose();
    _prezimeFocus.dispose();
    _devojackoFocus.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  void _save() {
    // Izračunaj legacy boolean polja iz radniStatusSet
    final jePenzioner = _jePenzionerSrbije ||
        _radniStatusSet.contains('INOSTRANI_PENZIONER');
    final jePenzionerSrbije = _jePenzionerSrbije;
    final jeVojniPenzioner = _jeVojniPenzioner;

    widget.onSave(
      PredmetiCompanion(
        ime: Value(_normalizedText(_imeCtrl)),
        prezime: Value(_normalizedText(_prezimeCtrl)),
        srednje: Value(_normalizedText(_srednjeCtrl)),
        devojackoPrezime: Value(_normalizedText(_devojackoCtrl)),
        jmbg: Value(_normalizedText(_jmbgCtrl)),
        pol: Value(_pol),
        datumRodjenja: Value(parseDateInput(_datumRodjenjaCtrl.text)),
        mestoRodjenja: Value(_normalizedText(_mestoRodjenjaCtrl)),
        datumSmrti: Value(parseDateInput(_datumSmrtiCtrl.text)),
        mestoSmrti: Value(IriuTruthRules.normalizeMestoSmrti(_mestoSmrti)),
        uzrokSmrti: Value(_uzrokSmrti),
        adresa: Value(_normalizedText(_adresaCtrl)),
        imeOca: Value(_normalizedText(_imeOcaCtrl)),
        imeMajke: Value(_normalizedText(_imeMajkeCtrl)),
        bracnoStanje: Value(_bracnoStanje),
        bracniDrugIme: Value(_normalizedText(_bdImeCtrl)),
        bracniDrugPrezime: Value(_normalizedText(_bdPrezimeCtrl)),
        bracniDrugPol: Value(_bdPol),
        bracniDrugDevojacko: Value(_normalizedText(_bdDevojackoCtrl)),
        bracniDrugJmbg: Value(_normalizedText(_bdJmbgCtrl)),
        // RADNI STATUS — čuva se kao JSON niz
        radniStatus: Value(jsonEncode(_radniStatusSet.toList())),
        // Legacy bool polja (za finansije i ostale segmente)
        penzioner: Value(jePenzioner ? 'DA' : 'NE'),
        penzionerSrbije: Value(jePenzionerSrbije ? 'DA' : 'NE'),
        vojniPenzioner: Value(jeVojniPenzioner ? 'DA' : 'NE'),
        vojnePocasti: Value(_vojnePocasti ? 'DA' : 'NE'),
        posmrtnaPomoc: Value(_posmrtnaPomoc ? 'DA' : 'NE'),
        cin: Value(_normalizedText(_cinCtrlRS)),
        bracniDrugOstvarujePravo:
            Value(_bracniDrugOstvarujePravo ? 'DA' : 'NE'),
        bracniDrugJePenzioner:
            Value(_bracniDrugJePenzioner ? 'DA' : 'NE'),
        penzionerNapomena:
            Value(_normalizedText(_radniStatusNapomenaCtrl)),
      ),
    );
  }

  bool get _imaBracnogDruga => _saBracnimDrugom.contains(_bracnoStanje);
  bool get _mozeOstvaritPravoBD => _mozePravoBD.contains(_bracnoStanje);

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    final showOsnovno =
        widget.mode == PreminuloLiceSegmentMode.all ||
        widget.mode == PreminuloLiceSegmentMode.osnovno;
    final showCinjenice =
        widget.mode == PreminuloLiceSegmentMode.all ||
        widget.mode == PreminuloLiceSegmentMode.cinjeniceOSmrti;
    final showStatusi =
        widget.mode == PreminuloLiceSegmentMode.all ||
        widget.mode == PreminuloLiceSegmentMode.statusi;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showOsnovno) ...[
              // ── LIČNI PODACI ─────────────────────────────────────────────
              _sectionLabel(
                context,
                'LIČNI PODACI',
                'Unesite podatke o preminulom licu',
              ),
              const SizedBox(height: 12),
              _row([
                _field('IME', _imeCtrl, e, caps: true,
                    focusNode: _imeFocus,
                    errorText: (_imeTouched || _prezimeTouched) &&
                            _imeCtrl.text.isEmpty && _prezimeCtrl.text.isEmpty
                        ? 'Bar ime ili prezime'
                        : null),
                _field('SREDNJE IME / SLOVO', _srednjeCtrl, e, caps: true),
              ]),
              const SizedBox(height: 12),
              _row([
                _field('PREZIME', _prezimeCtrl, e, caps: true,
                    focusNode: _prezimeFocus,
                    errorText: (_imeTouched || _prezimeTouched) &&
                            _imeCtrl.text.isEmpty && _prezimeCtrl.text.isEmpty
                        ? 'Bar ime ili prezime'
                        : null),
                if (_pol == 'Z')
                  _field(
                    'DEVOJAČKO PREZIME',
                    _devojackoCtrl,
                    e,
                    caps: true,
                    focusNode: _devojackoFocus,
                    emphasize: _devojackoNeedsAttention,
                  )
                else
                  const Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: 12),
              _row([
                _field('JMBG', _jmbgCtrl, e,
                    keyboard: TextInputType.number, protected: true),
                _polSelector(e),
              ]),
              const SizedBox(height: 12),
              _row([
                _datumField('DATUM ROĐENJA', _datumRodjenjaCtrl, e,
                    protected: true),
                _field('MESTO ROĐENJA', _mestoRodjenjaCtrl, e,
                    caps: true, protected: true),
              ]),
              const SizedBox(height: 12),
              _field('ADRESA PREBIVALIŠTA', _adresaCtrl, e,
                  caps: true, protected: true),
              const SizedBox(height: 12),
              _row([
                _field('IME OCA', _imeOcaCtrl, e, caps: true),
                _field('IME MAJKE', _imeMajkeCtrl, e, caps: true),
              ]),
            ],
            if (showCinjenice) ...[
              if (showOsnovno) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 4),
              ],
              _sectionLabel(context, 'ČINJENICE O SMRTI'),
              const SizedBox(height: 12),
              _row([
                _datumField('DATUM SMRTI', _datumSmrtiCtrl, e),
                _mestoSmrtiDropdown(e),
              ]),
              const SizedBox(height: 12),
              _uzrokSmrtiDropdown(e),
            ],
            if (showStatusi) ...[
              if (showOsnovno || showCinjenice) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 4),
              ],
              // ── BRAČNI STATUS ───────────────────────────────────────────
              _sectionLabel(context, 'BRAČNI STATUS'),
              const SizedBox(height: 12),
              _bracnoStanjeDropdown(e),
              if (_imaBracnogDruga) ...[
                const SizedBox(height: 12),
                _row([
                  _field('IME BRAČNOG DRUGA', _bdImeCtrl, e, caps: true),
                  _field('PREZIME BRAČNOG DRUGA', _bdPrezimeCtrl, e,
                      caps: true),
                ]),
                const SizedBox(height: 12),
                _row([
                  _polSelectorBD(e),
                  if (_bdPol == 'Z')
                    _field('DEVOJAČKO PREZIME BD', _bdDevojackoCtrl, e,
                        caps: true)
                  else
                    const Expanded(child: SizedBox()),
                ]),
                const SizedBox(height: 12),
                _field('JMBG BRAČNOG DRUGA', _bdJmbgCtrl, e,
                    keyboard: TextInputType.number, protected: true),
              ],
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 4),
              // ── RADNI STATUS ─────────────────────────────────────────────
              _sectionLabel(
                context,
                'RADNI STATUS',
                'Izaberite radni status preminulog lica',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _radniStatusOpcije.map((t) {
                  final selected = _radniStatusSet.contains(t.$1);
                  return PredmetSelectionChip(
                    label: t.$2,
                    selected: selected,
                    enabled: e,
                    onSelected: (v) => setState(() {
                              if (v) {
                                _radniStatusSet = {..._radniStatusSet, t.$1};
                              } else {
                                _radniStatusSet = _radniStatusSet
                                    .where((k) => k != t.$1)
                                    .toSet();
                              }
                              // Resetuj zavisna polja ako više nisu relevantna
                              if (!_jePenzionerSrbije) {
                                _vojnePocasti = false;
                                _posmrtnaPomoc = false;
                                _bracniDrugOstvarujePravo = false;
                                _bracniDrugJePenzioner = false;
                              }
                              if (!_jeVojniPenzioner) {
                                _vojnePocasti = false;
                                _posmrtnaPomoc = false;
                              }
                              _scheduleSave();
                            }),
                  );
                }).toList(),
              ),
              // ── Polja za penzionera R. Srbije i vojnog penzionera ───────
              if (_jePenzionerSrbije) ...[
                const SizedBox(height: 12),
                if (_jeVojniPenzioner) ...[
                  _field('ČIN', _cinCtrlRS, e, caps: true),
                  const SizedBox(height: 8),
                  _checkRow('Vojne počasti', _vojnePocasti, e,
                      (v) => setState(() {
                            _vojnePocasti = v;
                            _scheduleSave();
                          })),
                  _checkRow('Posmrtna pomoć', _posmrtnaPomoc, e,
                      (v) => setState(() {
                            _posmrtnaPomoc = v;
                            _scheduleSave();
                          })),
                  const SizedBox(height: 4),
                ],
                if (_mozeOstvaritPravoBD) ...[
                  const SizedBox(height: 4),
                  _checkRow(
                      'Pravo na porodičnu penziju',
                      _bracniDrugOstvarujePravo,
                      e,
                      (v) => setState(() {
                            _bracniDrugOstvarujePravo = v;
                            if (!v) _bracniDrugJePenzioner = false;
                            _scheduleSave();
                          })),
                  if (_bracniDrugOstvarujePravo)
                    _checkRow(
                        'Bračni drug je penzioner',
                        _bracniDrugJePenzioner,
                        e,
                        (v) => setState(() {
                              _bracniDrugJePenzioner = v;
                              _scheduleSave();
                            })),
                ],
                const SizedBox(height: 8),
              ],
              if (_radniStatusSet.isNotEmpty) ...[
                const SizedBox(height: 8),
                _field('NAPOMENA (radni status)', _radniStatusNapomenaCtrl, e,
                    maxLines: 2),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool enabled, {
    TextInputType keyboard = TextInputType.text,
    bool caps = false,
    String? hint,
    int maxLines = 1,
    String? errorText,
    FocusNode? focusNode,
    bool emphasize = false,
    bool protected = false,
  }) =>
      Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          final highlightBorder = OutlineInputBorder(
            borderSide: BorderSide(
              color: cs.tertiary,
              width: 1.6,
            ),
          );
          if (protected) {
            return PredmetProtectedTextField(
              labelText: label,
              controller: ctrl,
              enabled: enabled,
              keyboardType: keyboard,
              maxLines: maxLines,
              focusNode: focusNode,
              textCapitalization:
                  caps ? TextCapitalization.characters : TextCapitalization.none,
              hintText: hint,
              errorText: errorText,
              onChanged: (_) => _scheduleSave(),
            );
          }

          return TextFormField(
            controller: ctrl,
            enabled: enabled,
            keyboardType: keyboard,
            maxLines: maxLines,
            focusNode: focusNode,
            textCapitalization:
                caps ? TextCapitalization.characters : TextCapitalization.none,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
              isDense: true,
              errorText: errorText,
              filled: emphasize,
              fillColor:
                  emphasize ? cs.tertiaryContainer.withAlpha(110) : null,
              enabledBorder: emphasize ? highlightBorder : null,
              focusedBorder: emphasize
                  ? highlightBorder.copyWith(
                      borderSide: BorderSide(
                        color: cs.tertiary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            onChanged: (_) => _scheduleSave(),
          );
        },
      );

  Widget _datumField(
    String label,
    TextEditingController ctrl,
    bool enabled,
    {bool protected = false}
  ) =>
      Expanded(
        child: protected
            ? PredmetProtectedTextField(
                labelText: label,
                controller: ctrl,
                enabled: enabled,
                keyboardType: TextInputType.datetime,
                hintText: 'DD.MM.YYYY',
                onChanged: (_) => _scheduleSave(),
              )
            : TextFormField(
          controller: ctrl,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'DD.MM.YYYY',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => _scheduleSave(),
          onEditingComplete: () {
            final parsed = parseDateInput(ctrl.text);
            if (parsed != ctrl.text) {
              ctrl.text = parsed;
              ctrl.selection =
                  TextSelection.collapsed(offset: parsed.length);
            }
          },
        ),
      );

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  Widget _row(List<Widget> children) => LayoutBuilder(
        builder: (context, constraints) {
          final normalizedChildren = children
              .map<Widget>((w) => w is Expanded ? w.child : w)
              .toList(growable: false);

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: normalizedChildren
                  .expand((w) => [w, const SizedBox(height: 12)])
                  .toList()
                ..removeLast(),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: normalizedChildren
                .map<Widget>((w) => Expanded(child: w))
                .expand((w) => [w, const SizedBox(width: 12)])
                .toList()
              ..removeLast(),
          );
        },
      );

  Widget _polSelector(bool enabled) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POL',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'M', label: Text('M')),
                ButtonSegment(value: 'Z', label: Text('Ž')),
              ],
              selected: {_pol},
              onSelectionChanged: enabled
                  ? (s) => setState(() {
                        final prethodniPol = _pol;
                        _pol = s.first;
                        if (_bracnoStanje == 'VANBRAČNA ZAJEDNICA' ||
                            _bracnoStanje.isEmpty) {
                          _bdPol = _autoBdPol;
                        }
                        if (_pol == 'Z' && prethodniPol != 'Z') {
                          _devojackoNeedsAttention =
                              _devojackoCtrl.text.trim().isEmpty;
                        } else if (_pol != 'Z') {
                          _devojackoNeedsAttention = false;
                        }
                        _scheduleSave();
                      })
                  : null,
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      );

  Widget _polSelectorBD(bool enabled) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POL BRAČNOG DRUGA',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'M', label: Text('M')),
                ButtonSegment(value: 'Z', label: Text('Ž')),
              ],
              selected: {_bdPol},
              onSelectionChanged: enabled
                  ? (s) => setState(() {
                        _bdPol = s.first;
                        _scheduleSave();
                      })
                  : null,
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      );

  /// Sub-sekcija naslov.
  Widget _sectionLabel(BuildContext context, String title, [String hint = '']) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      );

  Widget _mestoSmrtiDropdown(bool enabled) => Expanded(
        child: DropdownButtonFormField<String>(
          key: ValueKey('mestoSmrti:$_mestoSmrti'),
          initialValue: _mestoSmrti.isEmpty ? null : _mestoSmrti,
          decoration: const InputDecoration(
            labelText: 'MESTO SMRTI',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _mestoSmrtiOpcije
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: enabled
              ? (v) => setState(() {
                    _mestoSmrti = IriuTruthRules.normalizeMestoSmrti(v ?? '');
                    _scheduleSave();
                  })
              : null,
        ),
      );

  Widget _uzrokSmrtiDropdown(bool enabled) => DropdownButtonFormField<String>(
        key: ValueKey('uzrokSmrti:$_uzrokSmrti'),
        initialValue: _uzrokSmrti.isEmpty ? null : _uzrokSmrti,
        decoration: const InputDecoration(
          labelText: 'UZROK SMRTI',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _uzrokSmrtiOpcije
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: enabled
            ? (v) => setState(() {
                  _uzrokSmrti = v ?? '';
                  _scheduleSave();
                })
            : null,
      );

  Widget _bracnoStanjeDropdown(bool enabled) => DropdownButtonFormField<String>(
        key: ValueKey('bracnoStanje:$_bracnoStanje'),
        initialValue: _bracnoStanje.isEmpty ? null : _bracnoStanje,
        decoration: const InputDecoration(
          labelText: 'BRAČNO STANJE',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _bracnaStanjaOpcije
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: enabled
            ? (v) => setState(() {
                  _bracnoStanje = v ?? '';
                  _bdPol = _autoBdPol;
                  _scheduleSave();
                })
            : null,
      );

  Widget _checkRow(
    String label,
    bool value,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) =>
      PredmetBooleanDecisionTile(
        title: label,
        value: value,
        enabled: enabled,
        onChanged: onChanged,
      );
}
