import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/format/app_text_format.dart';
import '../../../../core/format/app_time_format.dart';
import '../../../../core/database/database.dart';
import 'predmet_decision_controls.dart';

/// Segment 4: PARTE — simbol, pismo, atributi, tekst parte.
class ParteSegment extends StatefulWidget {
  const ParteSegment({
    super.key,
    required this.initialData,
    required this.enabled,
    required this.onSave,
  });

  final PredmetiData initialData;
  final bool enabled;
  final void Function(PredmetiCompanion) onSave;

  @override
  State<ParteSegment> createState() => _ParteSegmentState();
}

class _ParteSegmentState extends State<ParteSegment> {
  Timer? _debounce;

  String _simbol = 'PRAVOSLAVNI_KRST_SVETOSAVSKI';
  String _pismo = 'CIRILICA';

  // Atributi
  late final TextEditingController _titulaCtrl;
  bool _titulaIspred = false;
  late final TextEditingController _zanimanjeCtrl;
  bool _zanimanjeNaParti = false;
  bool _cinNaParti = false;
  bool _srednjeNaParti = false;
  late final TextEditingController _nadimakCtrl;
  bool _nadimakNaParti = false;
  // false = IZMEDJU (nadimak između imena i prezimena)
  // true  = IZA_CRTICA (nadimak iza prezimena sa crticom)
  bool _nadimakCrtica = false;

  // Parte tekst
  late final TextEditingController _ozaloseniCtrl;

  static const _simbolOpcije = [
    ('PRAVOSLAVNI_KRST_SVETOSAVSKI', 'Svetosavski krst'),
    ('PRAVOSLAVNI_KRST_TROCKI', 'Običan krst'),
    ('RIMOKATOLICKI_KRST', 'Katolički krst'),
    ('POLUMESEC', 'Polumesec'),
    ('DAVIDOVA_ZVEZDA', 'Davidova zvezda'),
    ('BEZ_SIMBOLA', 'Bez simbola'),
    ('SLOBODAN_IZBOR', 'Slobodan izbor'),
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;

    _simbol = d.simbol.isEmpty ? 'PRAVOSLAVNI_KRST_SVETOSAVSKI' : d.simbol;
    _pismo = d.pismo.isEmpty ? 'CIRILICA' : d.pismo;

    _titulaCtrl = TextEditingController(text: d.titula);
    _titulaIspred = d.titulaIspred;
    _zanimanjeCtrl = TextEditingController(text: d.zanimanje);
    _zanimanjeNaParti = d.zanimanjeNaParti;
    _cinNaParti = d.cinNaParti;
    _srednjeNaParti = d.srednjeNaParti;
    _nadimakCtrl = TextEditingController(text: d.nadimak);
    _nadimakNaParti = d.nadimakNaParti;
    _nadimakCrtica = d.nadimakCrtica;

    _ozaloseniCtrl = TextEditingController(text: d.ozaloseni);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _titulaCtrl,
      _zanimanjeCtrl,
      _nadimakCtrl,
      _ozaloseniCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Vraća prikazni naziv simbola (tekst umesto Unicode karaktera).
  String _simbolNaziv(String simbol) => _simbolOpcije
      .firstWhere(
        (t) => t.$1 == simbol,
        orElse: () => (simbol, simbol),
      )
      .$2;

  /// Izvlači godinu iz DD.MM.YYYY formata.
  String _izvuciGodinu(String datum) {
    if (datum.isEmpty) return '';
    final parts = datum.split('.');
    if (parts.length >= 3 && parts[2].length == 4) return parts[2];
    if (datum.length == 4) return datum; // Već samo godina
    return '';
  }

  /// Generiše kompletan predlog teksta parte (za preview), po spec §8.3.
  String _generisiPreviewTekst() {
    final d = widget.initialData;
    final lines = <String>[];
    final normalizedTitula = _normalizedText(_titulaCtrl);
    final normalizedNadimak = _normalizedText(_nadimakCtrl);
    final normalizedZanimanje = _normalizedText(_zanimanjeCtrl);
    final normalizedCin = _normalizedTextValue(d.cin);
    final normalizedOzalosceni = _normalizedText(_ozaloseniCtrl);

    // Red 1: Naš voljeni / Naša voljena
    lines.add(d.pol == 'Z' ? 'Naša voljena' : 'Naš voljeni');

    // Red 2: IME blok — dinamički iz checkboxova
    final imeParts = <String>[];

    // Titula ispred
    if (_titulaIspred && normalizedTitula.isNotEmpty) {
      imeParts.add(normalizedTitula);
    }
    // Ime
    if (d.ime.isNotEmpty) imeParts.add(d.ime);
    // Srednje ime (ako na parti)
    if (_srednjeNaParti && d.srednje.isNotEmpty) {
      imeParts.add(d.srednje);
    }
    // Nadimak između (IZMEDJU — _nadimakCrtica = false)
    if (_nadimakNaParti && !_nadimakCrtica && normalizedNadimak.isNotEmpty) {
      imeParts.add('"$normalizedNadimak"');
    }
    // Prezime
    if (d.prezime.isNotEmpty) imeParts.add(d.prezime);
    // Nadimak iza prezimena sa crticom (IZA_CRTICA — _nadimakCrtica = true)
    if (_nadimakNaParti && _nadimakCrtica && normalizedNadimak.isNotEmpty) {
      imeParts.add('- $normalizedNadimak');
    }
    // Titula iza (ne ispred)
    if (!_titulaIspred && normalizedTitula.isNotEmpty) {
      imeParts.add(normalizedTitula);
    }

    if (imeParts.isNotEmpty) lines.add(imeParts.join(' '));

    // Red 3: Zanimanje (ako na parti)
    if (_zanimanjeNaParti && normalizedZanimanje.isNotEmpty) {
      lines.add(normalizedZanimanje);
    }

    // Red 4: Čin (ako na parti i vojni penzioner)
    if (_cinNaParti && d.vojniPenzioner == 'DA' && normalizedCin.isNotEmpty) {
      lines.add(normalizedCin);
    }

    // Red 5: YYYY — YYYY.
    final godRodj = _izvuciGodinu(d.datumRodjenja);
    final godSmrti = _izvuciGodinu(d.datumSmrti);
    if (godRodj.isNotEmpty || godSmrti.isNotEmpty) {
      lines.add('$godRodj — $godSmrti.');
    }

    // Red 6: preminuo/preminula je DD. meseca YYYY. godine.  [5a: bez "u"]
    if (d.datumSmrti.isNotEmpty) {
      final glagol = d.pol == 'Z' ? 'preminula je' : 'preminuo je';
      lines.add('$glagol ${_formatirajDatumParte(d.datumSmrti)}.');
    }

    // Red 7: Vrsta ceremonije, dan, datum, vreme, groblje  [5b, 5d]
    if (d.datumCeremonije.isNotEmpty && d.groblje.isNotEmpty) {
      final vrsta = _vrstaOpisParte(d.vrstaCeremonije);
      final dan = _danUNedelji(d.datumCeremonije);
      final datum = _formatirajDatumParte(d.datumCeremonije);
      final vreme = _formatirajVreme(d.vremeCeremonije);
      final groblje = _naslovSlucaj(d.groblje);
      lines.add('$vrsta je u $dan, $datum u $vreme na groblju $groblje.');
    }

    // Red 8: Opelo / Ispraćaj  [5e]
    if (d.opelo == 'DA' && d.vremeOpela.isNotEmpty) {
      final vreme = _formatirajVreme(d.vremeOpela);
      if (d.opeloMesto.isNotEmpty) {
        lines.add(
            'Opelo počinje u $vreme u ${_opeloMestoLocativ(d.opeloMesto)}.');
      } else {
        lines.add('Opelo počinje u $vreme.');
      }
    } else if (d.opelo != 'DA' && d.vremeIspracaja.isNotEmpty) {
      lines.add('Ispraćaj počinje u ${_formatirajVreme(d.vremeIspracaja)}.');
    }

    // Red 9–10: Ožalošćeni
    lines.add('Ožalošćeni:');
    if (normalizedOzalosceni.isNotEmpty) {
      lines.add(normalizedOzalosceni);
    }

    // 5c: transliteracija na ćirilicu ako je odabrano pismo CIRILICA
    return _transliteriraj(lines.join('\n'));
  }

  /// 5a/5b: datum bez prefiksa "u" — "20. marta 2026. godine"
  String _formatirajDatumParte(String datum) {
    if (datum.isEmpty) return '';
    final parts = datum.split('.');
    if (parts.length < 3) return datum;
    final d = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final g = parts[2];
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
    final mesec = (m >= 1 && m <= 12) ? meseci[m] : '';
    return '$d. $mesec $g. godine';
  }

  /// 5b: dan u nedelji iz DD.MM.YYYY — "petak"
  String _danUNedelji(String datum) {
    if (datum.isEmpty) return '';
    final parts = datum.split('.');
    if (parts.length < 3) return '';
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return '';
    try {
      final dt = DateTime(y, m, d);
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

  /// 5b/5e: format vremena "11.00" ili "11:00" → "11:00 časova"
  String _formatirajVreme(String vreme) {
    return formatTimeForSentence(vreme);
  }

  /// 5d: title case za nazive mesta — "NOVI SAD" → "Novi Sad"
  String _naslovSlucaj(String s) {
    return toTitleCaseWords(s);
  }

  /// 5e: lokativ za mesto opela; predefinisane vrednosti → srpski lokativ,
  /// slobodan unos → title case (bez promene padeža — ograničenje dokumentovano).
  String _opeloMestoLocativ(String s) {
    return switch (s.toUpperCase().trim()) {
      'KAPELA NA GROBLJU' => 'kapeli na groblju',
      'CRKVA NA GROBLJU' => 'crkvi na groblju',
      'U PORODIČNOM DOMU' => 'porodičnom domu',
      'KOD GROBNOG MESTA' => 'kod grobnog mesta',
      _ => _naslovSlucaj(s),
    };
  }

  /// 5c: Latin → Cyrillic transliteracija za srpski jezik.
  /// Primenjuje se samo ako je _pismo == 'CIRILICA'.
  /// Digrafovi (lj, nj, dž) se obrađuju pre pojedinačnih slova.
  /// Slobodan unos u ćirilici prolazi nepromenjen (nema Latin→Cyr mapiranja).
  String _transliteriraj(String text) {
    if (_pismo != 'CIRILICA') return text;
    return transliterateLatinToCyrillic(text);
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

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);

  String _normalizedTextValue(String value) => normalizeText(value);

  void _save() {
    widget.onSave(
      PredmetiCompanion(
        simbol: Value(_simbol),
        pismo: Value(_pismo),
        titula: Value(_normalizedText(_titulaCtrl)),
        titulaIspred: Value(_titulaIspred),
        zanimanje: Value(_normalizedText(_zanimanjeCtrl)),
        zanimanjeNaParti: Value(_zanimanjeNaParti),
        cinNaParti: Value(_cinNaParti),
        srednjeNaParti: Value(_srednjeNaParti),
        nadimak: Value(_normalizedText(_nadimakCtrl)),
        nadimakNaParti: Value(_nadimakNaParti),
        nadimakCrtica: Value(_nadimakCrtica),
        ozaloseni: Value(_normalizedText(_ozaloseniCtrl)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    return _withCheckboxVisibilityTheme(
      context,
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Simbol ────────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              key: ValueKey(_simbol),
              initialValue: _simbol,
              decoration: const InputDecoration(
                labelText: 'SIMBOL',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _simbolOpcije
                  .map((t) => DropdownMenuItem(
                        value: t.$1,
                        child: Text(t.$2),
                      ))
                  .toList(),
              onChanged: e
                  ? (v) => setState(() {
                        _simbol = v ?? _simbol;
                        _scheduleSave();
                      })
                  : null,
            ),
            const SizedBox(height: 12),
            // ── Pismo ─────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PISMO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'LATINICA', label: Text('LATINICA')),
                    ButtonSegment(
                        value: 'CIRILICA', label: Text('ĆIRILICA')),
                  ],
                  selected: {_pismo},
                  onSelectionChanged: e
                      ? (s) => setState(() {
                            _pismo = s.first;
                            _scheduleSave();
                          })
                      : null,
                  style: const ButtonStyle(
                      visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'UNESITE ATRIBUTE ZA PARTE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            // ── Titula ────────────────────────────────────────────────────
            _ParteFieldWithDecision(
              field: TextFormField(
                controller: _titulaCtrl,
                enabled: e,
                decoration: const InputDecoration(
                  labelText: 'TITULA',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _scheduleSave(),
              ),
              decision: PredmetBooleanDecisionTile(
                title: 'Titula ispred imena',
                value: _titulaIspred,
                enabled: e,
                compact: true,
                onChanged: (v) => setState(() {
                  _titulaIspred = v;
                  _scheduleSave();
                }),
              ),
            ),
            const SizedBox(height: 10),
            // ── Zanimanje ─────────────────────────────────────────────────
            _ParteFieldWithDecision(
              field: TextFormField(
                controller: _zanimanjeCtrl,
                enabled: e,
                decoration: const InputDecoration(
                  labelText: 'ZANIMANJE',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _scheduleSave(),
              ),
              decision: PredmetBooleanDecisionTile(
                title: 'Zanimanje na parti',
                value: _zanimanjeNaParti,
                enabled: e,
                compact: true,
                onChanged: (v) => setState(() {
                  _zanimanjeNaParti = v;
                  _scheduleSave();
                }),
              ),
            ),
            const SizedBox(height: 8),
            // ── Čin na parti (samo ako VOJNI PENZIONER = DA) ──────────────
            if (widget.initialData.vojniPenzioner == 'DA') ...[
              PredmetBooleanDecisionTile(
                title: 'Čin na parti  '
                    '(${widget.initialData.cin.isNotEmpty ? widget.initialData.cin : "uneti ČIN u RADNI STATUS"})',
                value: _cinNaParti,
                enabled: e,
                onChanged: (v) => setState(() {
                          _cinNaParti = v;
                          _scheduleSave();
                        }),
              ),
              const SizedBox(height: 4),
            ],
            // ── Srednje ime na parti ──────────────────────────────────────
            PredmetBooleanDecisionTile(
              title: 'Srednje ime / srednje slovo na parti',
              value: _srednjeNaParti,
              enabled: e,
              compact: true,
              onChanged: (v) => setState(() {
                        _srednjeNaParti = v;
                        _scheduleSave();
                      }),
            ),
            const SizedBox(height: 4),
            // ── Nadimak ───────────────────────────────────────────────────
            _ParteFieldWithDecision(
              field: TextFormField(
                controller: _nadimakCtrl,
                enabled: e,
                decoration: const InputDecoration(
                  labelText: 'NADIMAK',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _scheduleSave(),
              ),
              decision: PredmetBooleanDecisionTile(
                title: 'Nadimak na parti',
                value: _nadimakNaParti,
                enabled: e,
                compact: true,
                onChanged: (v) => setState(() {
                  _nadimakNaParti = v;
                  if (!v) _nadimakCrtica = false;
                  _scheduleSave();
                }),
              ),
            ),
            // ── Pozicija nadimka (vidljivo samo kad je nadimak na parti) ──
            if (_nadimakNaParti) ...[
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POZICIJA NADIMKA',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text(
                          'Između imena i prezimena',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(
                          'Iza prezimena sa crticom',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    selected: {_nadimakCrtica},
                    onSelectionChanged: e
                        ? (s) => setState(() {
                              _nadimakCrtica = s.first;
                              _scheduleSave();
                            })
                        : null,
                    style: const ButtonStyle(
                        visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // ── Ožalošćeni ────────────────────────────────────────────────
            TextFormField(
              controller: _ozaloseniCtrl,
              enabled: e,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'OŽALOŠĆENI',
                hintText: 'Ožalošćeni...',
                border: OutlineInputBorder(),
                isDense: true,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(_scheduleSave),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // ── Inline preview parte ──────────────────────────────────────
            Text(
              'PREVIEW PARTE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                border: Border.all(
                    color: const Color(0xFFBDBD9F), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Simbol — prikazni naziv (tekst)
                  if (_simbol != 'BEZ_SIMBOLA') ...[
                    Text(
                      '[ ${_simbolNaziv(_simbol)} ]',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Tekst parte
                  Text(
                    _generisiPreviewTekst(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
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
}

class _ParteFieldWithDecision extends StatelessWidget {
  const _ParteFieldWithDecision({
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: field),
            const SizedBox(width: 12),
            SizedBox(
              width: 300,
              child: decision,
            ),
          ],
        );
      },
    );
  }
}
