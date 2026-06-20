import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../data/iriu_repository.dart';
import 'predmet_decision_controls.dart';

/// Segment 3: POGREBNA CEREMONIJA.
class CeremonijuSegment extends StatefulWidget {
  const CeremonijuSegment({
    super.key,
    required this.initialData,
    required this.predmetId,
    required this.iriuRepo,
    required this.enabled,
    required this.onSave,
  });

  final PredmetiData initialData;
  final int predmetId;
  final IriuRepository iriuRepo;
  final bool enabled;
  final void Function(PredmetiCompanion) onSave;

  @override
  State<CeremonijuSegment> createState() => _CeremonijuSegmentState();
}

class _CeremonijuSegmentState extends State<CeremonijuSegment> {
  Timer? _debounce;

  late final TextEditingController _grobljeCt;
  String _tipGroblja = 'GRADSKO';
  String _vrstaCeremonije = 'SAHRANA';

  bool _opelo = false;
  String _opeloMesto = '';
  late final TextEditingController _vremeOpelaCtrl;
  late final TextEditingController _vremeIspracajaCtrl;

  late final TextEditingController _datumCeremonijeCtrl;
  late final TextEditingController _vremeCeremonijeCtrl;

  String _grobnoMesto = 'NOVO';
  String _tipGrobnogMesta = 'GROB';
  late final TextEditingController _parcelaCtrl;
  late final TextEditingController _grobBrojCtrl;
  late final TextEditingController _redGrobCtrl;
  late final TextEditingController _npkCtrl;
  late final TextEditingController _grobnicaCtrl;

  // Kremacija
  late final TextEditingController _oznakUrneCtrl;
  String _tipPolaganja = '';
  late final TextEditingController _urnaParcelaCtrl;
  late final TextEditingController _urnaBrojCtrl;
  late final TextEditingController _urnaRedCtrl;
  late final TextEditingController _urnaNpkCtrl;

  bool _sahranaVanSrbije = false;
  late final TextEditingController _svisZemljaCtrl;
  late final TextEditingController _svisGradCtrl;

  bool _docekPosmrtnihOstataka = false;
  late final TextEditingController _docekMestoCtrl;
  late final TextEditingController _docekVremeCtrl;

  // Blur validacija
  final _datumCeremFocus = FocusNode();
  final _vremeCeremFocus = FocusNode();
  bool _datumCeremTouched = false;
  bool _vremeCeremTouched = false;

  // Vrsta ceremonije -> dostupna mesta opela
  static const _opeloMestaMap = {
    'SAHRANA': [
      'KAPELA NA GROBLJU',
      'CRKVA NA GROBLJU',
      'U PORODI\u010cNOM DOMU',
      'KOD GROBNOG MESTA',
    ],
    'SAHRANA_EKSPRES': ['KOD GROBNOG MESTA'],
    'KREMACIJA': [
      'KAPELA NA GROBLJU',
      'CRKVA NA GROBLJU',
      'U PORODI\u010cNOM DOMU',
      'KOD GROBNOG MESTA',
    ],
  };

  // Vrste ceremonije gde opelo NIJE mogu\u0107e
  static const _opelaNije = {
    'KREMACIJA_EKSPRES',
    'SMESTAJ_URNE',
    'RASIPANJE_PEPELA',
  };

  static const _vrsteCeremonije = [
    ('SAHRANA', 'Sahrana'),
    ('SAHRANA_EKSPRES', 'Sahrana ekspres'),
    ('KREMACIJA', 'Kremacija'),
    ('KREMACIJA_EKSPRES', 'Kremacija ekspres'),
    ('SMESTAJ_URNE', 'Sme\u0161taj urne'),
    ('RASIPANJE_PEPELA', 'Rasipanje pepela'),
  ];

  // TIP POLAGANJA URNE - spec 7.5
  static const _tipPolaganjaOpcije = [
    ('NAKNADNO', 'Naknadno'),
    ('GROB', 'Grob'),
    ('GROBNICA', 'Grobnica'),
    ('KOLUMBARIJUM', 'Kolumbarijum'),
    ('ROZARIJUM', 'Rozarijum'),
    ('RASIPANJE_PEPELA', 'Rasipanje pepela'),
  ];

  static const Map<String, String> _tipPolaganjaLegacyMap = {
    'U_GROB': 'GROB',
    'U_GROBNICU': 'GROBNICA',
    'RASIPANJE': 'RASIPANJE_PEPELA',
  };

  static final Set<String> _tipPolaganjaDozvoljeneVrednosti =
      _tipPolaganjaOpcije.map((opcija) => opcija.$1).toSet();

  // Tipovi polaganja koji zahtevaju parcela/broj/red/npk
  static const _saLokalitetom = {
    'GROB',
    'GROBNICA',
    'KOLUMBARIJUM',
    'ROZARIJUM',
  };

  static const Map<String, String> _iriuNazivi = {
    IriuK.hladnjaca: 'Hladnja\u010da',
    IriuK.prevozDoHladnjace: 'Prevoz do hladnja\u010de',
    IriuK.limeniUlozak: 'Limeni ulo\u017eak',
    IriuK.lemovanje: 'Lemovanje',
    IriuK.transportnaVreca: 'Transportna vre\u0107a',
    IriuK.balsamovanje: 'Balsamovanje',
    IriuK.kompletZaOpelo: 'Komplet za opelo',
    IriuK.medjunarodniPrevoz: 'Me\u0111unarodni prevoz',
    IriuK.medjunarodnaDocumentacija: 'Me\u0111unarodna dokumentacija',
    IriuK.cargoTroskovi: 'Cargo tro\u0161kovi',
  };

  bool get _jeKremacija =>
      _vrstaCeremonije == 'KREMACIJA' ||
      _vrstaCeremonije == 'KREMACIJA_EKSPRES';
  bool get _mozeOpelo => !_opelaNije.contains(_vrstaCeremonije);

  List<String> get _dostupnaMestaOpela =>
      _opeloMestaMap[_vrstaCeremonije] ?? [];

  String _normalizeTipPolaganjaValue(String value) {
    final normalized = _tipPolaganjaLegacyMap[value] ?? value;
    return _tipPolaganjaDozvoljeneVrednosti.contains(normalized)
        ? normalized
        : '';
  }

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;

    _grobljeCt = TextEditingController(text: d.groblje);
    _tipGroblja = d.tipGroblja.isEmpty ? 'GRADSKO' : d.tipGroblja;
    _vrstaCeremonije =
        d.vrstaCeremonije.isEmpty ? 'SAHRANA' : d.vrstaCeremonije;

    _opelo = d.opelo == 'DA';
    _opeloMesto = d.opeloMesto;
    _vremeOpelaCtrl = TextEditingController(text: d.vremeOpela);
    _vremeIspracajaCtrl = TextEditingController(text: d.vremeIspracaja);

    _datumCeremonijeCtrl = TextEditingController(
      text: normalizeCeremonyDateInput(d.datumCeremonije),
    );
    _vremeCeremonijeCtrl = TextEditingController(text: d.vremeCeremonije);

    _grobnoMesto = d.grobnoMesto.isEmpty ? 'NOVO' : d.grobnoMesto;
    _tipGrobnogMesta =
        d.tipGrobnogMesta.isEmpty ? 'GROB' : d.tipGrobnogMesta;
    _parcelaCtrl = TextEditingController(text: d.parcela);
    _grobBrojCtrl = TextEditingController(text: d.grobBroj);
    _redGrobCtrl = TextEditingController(text: d.redGrob);
    _npkCtrl = TextEditingController(text: d.npk);
    _grobnicaCtrl = TextEditingController(text: d.grobnica);

    _oznakUrneCtrl = TextEditingController(text: d.urnaSifra);
    _tipPolaganja = _normalizeTipPolaganjaValue(d.tipPolaganja);
    _urnaParcelaCtrl = TextEditingController(text: d.urnaParcela);
    _urnaBrojCtrl = TextEditingController(text: d.urnaBroj);
    _urnaRedCtrl = TextEditingController(text: d.urnaRed);
    _urnaNpkCtrl = TextEditingController(text: d.urnaNpk);

    _sahranaVanSrbije = d.sahranaVanSrbije;
    _svisZemljaCtrl = TextEditingController(text: d.svisZemlja);
    _svisGradCtrl = TextEditingController(text: d.svisGrad);

    _docekPosmrtnihOstataka = d.docekPosmrtnihOstataka;
    _docekMestoCtrl = TextEditingController(text: d.docekMesto);
    _docekVremeCtrl = TextEditingController(text: d.docekVreme);

    // Blur validacija - prikazuje gre\u0161ku samo nakon napu\u0161tanja polja
    _datumCeremFocus.addListener(() {
      if (!_datumCeremFocus.hasFocus) setState(() => _datumCeremTouched = true);
    });
    _vremeCeremFocus.addListener(() {
      if (!_vremeCeremFocus.hasFocus) setState(() => _vremeCeremTouched = true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _grobljeCt, _datumCeremonijeCtrl, _vremeCeremonijeCtrl,
      _vremeOpelaCtrl, _vremeIspracajaCtrl,
      _parcelaCtrl, _grobBrojCtrl, _redGrobCtrl, _npkCtrl, _grobnicaCtrl,
      _oznakUrneCtrl, _urnaParcelaCtrl, _urnaBrojCtrl, _urnaRedCtrl,
      _urnaNpkCtrl,
      _svisZemljaCtrl, _svisGradCtrl, _docekMestoCtrl, _docekVremeCtrl,
    ]) {
      c.dispose();
    }
    _datumCeremFocus.dispose();
    _vremeCeremFocus.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  void _save() {
    widget.onSave(
      PredmetiCompanion(
        groblje: Value(_normalizedText(_grobljeCt)),
        tipGroblja: Value(_tipGroblja),
        vrstaCeremonije: Value(_vrstaCeremonije),
        datumCeremonije: Value(
          normalizeCeremonyDateInput(_datumCeremonijeCtrl.text),
        ),
        vremeCeremonije: Value(_normalizedTime(_vremeCeremonijeCtrl)),
        opelo: Value(_opelo ? 'DA' : 'NE'),
        opeloMesto: Value(_opeloMesto),
        vremeOpela: Value(_normalizedTime(_vremeOpelaCtrl)),
        vremeIspracaja: Value(_normalizedTime(_vremeIspracajaCtrl)),
        grobnoMesto: Value(_grobnoMesto),
        tipGrobnogMesta: Value(_tipGrobnogMesta),
        parcela: Value(_normalizedText(_parcelaCtrl)),
        grobBroj: Value(_normalizedText(_grobBrojCtrl)),
        redGrob: Value(_normalizedText(_redGrobCtrl)),
        npk: Value(_normalizedText(_npkCtrl)),
        grobnica: Value(_normalizedText(_grobnicaCtrl)),
        urnaSifra: Value(_normalizedText(_oznakUrneCtrl)),
        tipPolaganja: Value(_tipPolaganja),
        urnaParcela: Value(_normalizedText(_urnaParcelaCtrl)),
        urnaBroj: Value(_normalizedText(_urnaBrojCtrl)),
        urnaRed: Value(_normalizedText(_urnaRedCtrl)),
        urnaNpk: Value(_normalizedText(_urnaNpkCtrl)),
        sahranaVanSrbije: Value(_sahranaVanSrbije),
        svisZemlja: Value(_normalizedText(_svisZemljaCtrl)),
        svisGrad: Value(_normalizedText(_svisGradCtrl)),
        docekPosmrtnihOstataka: Value(_docekPosmrtnihOstataka),
        docekMesto: Value(_normalizedText(_docekMestoCtrl)),
        docekVreme: Value(_normalizedTime(_docekVremeCtrl)),
      ),
    );
  }

  Future<void> _predloziIriu(List<String> stavke) async {
    int red = await widget.iriuRepo.sledeciredosled(widget.predmetId);
    for (final naziv in stavke) {
      await widget.iriuRepo.predloziAkoNema(
        predmetId: widget.predmetId,
        interniNaziv: naziv,
        nazivPrikaz: _iriuNazivi[naziv] ?? naziv,
        redosled: red++,
      );
    }
  }

  String _pomerVreme(String vreme, int minuta) {
    return offsetNormalizedTime(vreme, -minuta);
  }

  void _onVremeCeremonijeChanged(String v) {
    final normalized = normalizeTimeInput(v);
    if (normalized.isNotEmpty) {
      final vremeOpela = _pomerVreme(normalized, 30);
      final vremeIspracaja = _pomerVreme(normalized, 60);
      if (vremeOpela.isNotEmpty && _opelo) {
        _vremeOpelaCtrl.text = vremeOpela;
      }
      if (vremeIspracaja.isNotEmpty && !_opelo) {
        _vremeIspracajaCtrl.text = vremeIspracaja;
      }
    }
    _scheduleSave();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    final isNarrowAndroid = _isNarrowAndroid(context);
    return _withCheckboxVisibilityTheme(
      context,
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Groblje + tip
              if (isNarrowAndroid) ...[
                TextFormField(
                  controller: _grobljeCt,
                  enabled: e,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'GROBLJE',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _scheduleSave(),
                ),
                const SizedBox(height: 12),
                _segButton(
                  'TIP GROBLJA',
                  const [
                    ButtonSegment(value: 'GRADSKO', label: Text('GRADSKO')),
                    ButtonSegment(value: 'LOKALNO', label: Text('LOKALNO')),
                  ],
                  _tipGroblja,
                  e,
                  (v) {
                    _tipGroblja = v;
                    _scheduleSave();
                  },
                ),
              ] else ...[
                _row([
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _grobljeCt,
                      enabled: e,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'GROBLJE',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: _segButton(
                      'TIP GROBLJA',
                      const [
                        ButtonSegment(value: 'GRADSKO', label: Text('GRADSKO')),
                        ButtonSegment(value: 'LOKALNO', label: Text('LOKALNO')),
                      ],
                      _tipGroblja,
                      e,
                      (v) {
                        _tipGroblja = v;
                        _scheduleSave();
                      },
                    ),
                  ),
                ]),
              ],
            const SizedBox(height: 12),
            // Vrsta ceremonije
            DropdownButtonFormField<String>(
              key: ValueKey(_vrstaCeremonije),
              initialValue: _vrstaCeremonije,
              decoration: const InputDecoration(
                labelText: 'VRSTA CEREMONIJE',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _vrsteCeremonije
                  .map((t) => DropdownMenuItem(
                        value: t.$1,
                        child: Text(t.$2),
                      ))
                  .toList(),
              onChanged: e
                  ? (v) {
                      final nova = v ?? _vrstaCeremonije;
                      setState(() {
                        _vrstaCeremonije = nova;
                        // Ako prelazimo na vrstu gde opelo nije mogu\u0107e
                        if (_opelaNije.contains(nova)) {
                          _opelo = false;
                          _opeloMesto = '';
                        }
                        // Ako trenutno mesto opela nije u novoj listi
                        final mesta = _opeloMestaMap[nova] ?? [];
                        if (_opeloMesto.isNotEmpty &&
                            !mesta.contains(_opeloMesto)) {
                          _opeloMesto = '';
                        }
                      });
                      _scheduleSave();
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            // Grobno mesto (sahrana)
            if (_vrstaCeremonije.startsWith('SAHRANA')) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'GROBNO MESTO',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              _row([
                Expanded(
                  child: _segButton('', [
                    const ButtonSegment(value: 'NOVO', label: Text('NOVO')),
                    const ButtonSegment(
                        value: 'POSTOJECE', label: Text('POSTOJE\u0106E')),
                  ], _grobnoMesto, e, (v) {
                    _grobnoMesto = v;
                    _scheduleSave();
                  }),
                ),
                Expanded(
                  child: _segButton('', [
                    const ButtonSegment(
                        value: 'GROB', label: Text('GROB')),
                    const ButtonSegment(
                        value: 'GROBNICA', label: Text('GROBNICA')),
                  ], _tipGrobnogMesta, e, (v) {
                    _tipGrobnogMesta = v;
                    _scheduleSave();
                  }),
                ),
              ]),
              const SizedBox(height: 12),
              if (_grobnoMesto != 'NOVO' &&
                  (_tipGrobnogMesta == 'GROB' ||
                      _tipGrobnogMesta == 'GROBNICA')) ...[
                /* if (false && isNarrowAndroid) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('${_vrstaCeremonije}_opelo_$_opeloMesto'),
                    initialValue: _opeloMesto.isEmpty
                        ? null
                        : (_dostupnaMestaOpela.contains(_opeloMesto)
                            ? _opeloMesto
                            : null),
                    decoration: const InputDecoration(
                      labelText: 'MESTO OPELA',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: const Text('- odaberite -'),
                    items: _dostupnaMestaOpela
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: e
                        ? (v) => setState(() {
                              _opeloMesto = v ?? '';
                              _scheduleSave();
                            })
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _vremeOpelaCtrl,
                    enabled: e,
                    decoration: const InputDecoration(
                      labelText: 'VREME OPELA',
                      hintText: 'HH:MM',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ] else */
                _row([
                  Expanded(
                    child: TextFormField(
                      controller: _parcelaCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'PARCELA',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _grobBrojCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'BROJ GROBA',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _redGrobCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'RED',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _npkCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'NPK',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 4),
            ],
            // Kremacija
            if (_jeKremacija) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'KREMACIJA',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _oznakUrneCtrl,
                enabled: e,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'OZNAKA URNE',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _scheduleSave(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_tipPolaganja),
                initialValue: _tipPolaganja.isEmpty ? null : _tipPolaganja,
                decoration: const InputDecoration(
                  labelText: 'TIP POLAGANJA URNE',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                hint: const Text('- odaberite -'),
                items: _tipPolaganjaOpcije
                    .map((t) => DropdownMenuItem(
                          value: t.$1,
                          child: Text(t.$2),
                        ))
                    .toList(),
                onChanged: e
                    ? (v) => setState(() {
                          _tipPolaganja =
                              _normalizeTipPolaganjaValue(v ?? '');
                          _scheduleSave();
                        })
                    : null,
              ),
              if (_saLokalitetom.contains(_tipPolaganja)) ...[
                const SizedBox(height: 12),
                _row([
                  Expanded(
                    child: TextFormField(
                      controller: _urnaParcelaCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'PARCELA',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _urnaBrojCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'BROJ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _urnaRedCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'RED',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _urnaNpkCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'NPK',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 4),
            ],
            // Opelo
            const Divider(),
            const SizedBox(height: 8),
            _row([
              Expanded(
                child: TextFormField(
                  controller: _datumCeremonijeCtrl,
                  enabled: e,
                  focusNode: _datumCeremFocus,
                  decoration: InputDecoration(
                    labelText: 'DATUM CEREMONIJE',
                    hintText: 'npr. 17.04.2026.',
                    helperText: 'Prihva\u0107eno: 17.4.2026. ili 17.04.2026.',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    errorText: _datumCeremTouched &&
                            _datumCeremonijeCtrl.text.isEmpty
                        ? 'Obavezno'
                        : null,
                  ),
                  onChanged: (_) => _scheduleSave(),
                  onEditingComplete: () {
                    final p =
                        normalizeCeremonyDateInput(_datumCeremonijeCtrl.text);
                    if (p != _datumCeremonijeCtrl.text) {
                      _datumCeremonijeCtrl.text = p;
                      _datumCeremonijeCtrl.selection =
                          TextSelection.collapsed(offset: p.length);
                    }
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _vremeCeremonijeCtrl,
                  enabled: e,
                  focusNode: _vremeCeremFocus,
                  decoration: InputDecoration(
                    labelText: 'VREME CEREMONIJE',
                    hintText: 'HH:MM',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    errorText: _vremeCeremTouched &&
                            _vremeCeremonijeCtrl.text.isEmpty
                        ? 'Obavezno'
                        : null,
                  ),
                  onChanged: _onVremeCeremonijeChanged,
                  onEditingComplete: () {
                    final normalized =
                        normalizeTimeInput(_vremeCeremonijeCtrl.text);
                    if (normalized != _vremeCeremonijeCtrl.text) {
                      _vremeCeremonijeCtrl.text = normalized;
                      _vremeCeremonijeCtrl.selection =
                          TextSelection.collapsed(offset: normalized.length);
                    }
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            const Divider(),
            if (_mozeOpelo) ...[
              PredmetBooleanDecisionTile(
                title: 'Opelo',
                value: _opelo,
                enabled: e,
                onChanged: (v) {
                        setState(() => _opelo = v);
                        if (v) {
                          _predloziIriu([IriuK.kompletZaOpelo]);
                          final pomereno =
                              _pomerVreme(_vremeCeremonijeCtrl.text, 30);
                          if (pomereno.isNotEmpty) {
                            _vremeOpelaCtrl.text = pomereno;
                          }
                          // Inicijalizuj mesto opela na prvu opciju ako prazno
                          if (_opeloMesto.isEmpty &&
                              _dostupnaMestaOpela.isNotEmpty) {
                            setState(() {
                              _opeloMesto = _dostupnaMestaOpela.first;
                            });
                          }
                        }
                        _scheduleSave();
                      },
              ),
              if (_opelo) ...[
                const SizedBox(height: 8),
                if (isNarrowAndroid) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('${_vrstaCeremonije}_opelo_$_opeloMesto'),
                    initialValue: _opeloMesto.isEmpty
                        ? null
                        : (_dostupnaMestaOpela.contains(_opeloMesto)
                            ? _opeloMesto
                            : null),
                    decoration: const InputDecoration(
                      labelText: 'MESTO OPELA',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: const Text('- odaberite -'),
                    items: _dostupnaMestaOpela
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: e
                        ? (v) => setState(() {
                              _opeloMesto = v ?? '';
                              _scheduleSave();
                            })
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _vremeOpelaCtrl,
                    enabled: e,
                    decoration: const InputDecoration(
                      labelText: 'VREME OPELA',
                      hintText: 'HH:MM',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ] else
                _row([
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('${_vrstaCeremonije}_opelo_$_opeloMesto'),
                      initialValue: _opeloMesto.isEmpty
                          ? null
                          : (_dostupnaMestaOpela.contains(_opeloMesto)
                              ? _opeloMesto
                              : null),
                      decoration: const InputDecoration(
                        labelText: 'MESTO OPELA',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      hint: const Text('- odaberite -'),
                      items: _dostupnaMestaOpela
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: e
                          ? (v) => setState(() {
                                _opeloMesto = v ?? '';
                                _scheduleSave();
                              })
                          : null,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _vremeOpelaCtrl,
                      enabled: e,
                      decoration: const InputDecoration(
                        labelText: 'VREME OPELA',
                        hintText: 'HH:MM',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vreme opela se ra\u010duna automatski, ali ga mo\u017eete ru\u010dno izmeniti.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            if (!_opelo && _mozeOpelo) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _vremeIspracajaCtrl,
                enabled: e,
                decoration: const InputDecoration(
                  labelText: 'VREME ISPRA\u0106AJA',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _scheduleSave(),
              ),
              const SizedBox(height: 12),
            ],
            // Datum i vreme ceremonije (na kraju)
            const SizedBox(height: 8),

            _decisionTile(
              title: 'Sahrana van Srbije',
              value: _sahranaVanSrbije,
              enabled: e,
              onChanged: (v) {
                setState(() => _sahranaVanSrbije = v);
                if (v) {
                  _predloziIriu([
                    IriuK.medjunarodniPrevoz,
                    IriuK.medjunarodnaDocumentacija,
                    IriuK.balsamovanje,
                  ]);
                }
                _scheduleSave();
              },
            ),
            if (_sahranaVanSrbije) ...[
              _row([
                Expanded(
                  child: TextFormField(
                    controller: _svisZemljaCtrl,
                    enabled: e,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'ZEMLJA',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _svisGradCtrl,
                    enabled: e,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'GRAD',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
            ],
            _decisionTile(
              title: 'Do\u010dek posmrtnih ostataka',
              value: _docekPosmrtnihOstataka,
              enabled: e,
              onChanged: (v) {
                setState(() => _docekPosmrtnihOstataka = v);
                if (v) {
                  _predloziIriu([IriuK.cargoTroskovi]);
                }
                _scheduleSave();
              },
            ),
            if (_docekPosmrtnihOstataka) ...[
              _row([
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _docekMestoCtrl,
                    enabled: e,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'MESTO DO\u010cEKA',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _docekVremeCtrl,
                    enabled: e,
                    decoration: const InputDecoration(
                      labelText: 'VREME DO\u010cEKA',
                      hintText: 'HH:MM',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ),
              ]),
            ],
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

  Widget _row(List<Widget> children) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map<Widget>((w) => w is Expanded ? w : Expanded(child: w))
            .expand((w) => [w, const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      );

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  String _normalizedTime(TextEditingController ctrl) =>
      normalizeTimeInput(ctrl.text);

  bool _isNarrowAndroid(BuildContext context) {
    final media = MediaQuery.of(context);
    return Theme.of(context).platform == TargetPlatform.android &&
        media.size.width < 600;
  }

  Widget _decisionTile({
    required String title,
    String? subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = value ? scheme.primary : scheme.outlineVariant;
    final background = value
        ? scheme.primaryContainer.withValues(alpha: 0.35)
        : scheme.surfaceContainerLow;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? () => onChanged(!value) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: enabled
                                        ? scheme.onSurfaceVariant
                                        : scheme.onSurface.withValues(
                                            alpha: 0.45,
                                          ),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper: labeled SegmentedButton
  Widget _segButton(
    String label,
    List<ButtonSegment<String>> segments,
    String selected,
    bool enabled,
    ValueChanged<String> onChanged,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          if (_isNarrowAndroid(context))
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: segments.map((segment) {
                final isSelected = selected == segment.value;
                final labelWidget = segment.label;
                final labelText = labelWidget is Text
                    ? (labelWidget.data ?? '')
                    : segment.value;
                return PredmetSelectionChip(
                  label: labelText,
                  selected: isSelected,
                  enabled: enabled,
                  onSelected: (_) => setState(() => onChanged(segment.value)),
                );
              }).toList(),
            )
          else
            SegmentedButton<String>(
              segments: segments,
              selected: {selected},
              onSelectionChanged: enabled
                  ? (s) => setState(() => onChanged(s.first))
                  : null,
              style:
                  const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
        ],
      );
}
