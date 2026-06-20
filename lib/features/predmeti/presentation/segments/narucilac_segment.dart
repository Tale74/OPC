import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/format/app_format.dart';
import '../../data/kontakt_lica_repository.dart';
import 'predmet_decision_controls.dart';

/// Segment 2: PLATILAC - opreme i usluga (Block A) + JKP troskova (Block B).
class NarucilacSegment extends StatefulWidget {
  const NarucilacSegment({
    super.key,
    required this.initialData,
    required this.predmetId,
    required this.kontaktRepo,
    required this.firmaPodaci,
    required this.enabled,
    required this.onSave,
  });

  final PredmetiData initialData;
  final int predmetId;
  final KontaktLicaRepository kontaktRepo;
  final FirmaPodaciData firmaPodaci;
  final bool enabled;
  final void Function(PredmetiCompanion) onSave;

  @override
  State<NarucilacSegment> createState() => _NarucilacSegmentState();
}

class _NarucilacSegmentState extends State<NarucilacSegment> {
  Timer? _debounce;

  // Block A - top level
  String _naruTip = 'FIZICKO_LICE';
  /// A1 sub-tip: 'BRACNI_DRUG' | 'DRUGO_LICE'
  String _naruFizSubTip = 'DRUGO_LICE';

  // A1 / BRACNI DRUG - extra editable fields (ime/prezime/jmbg read from widget)
  late final TextEditingController _naruBdAdresaCtrl;
  late final TextEditingController _naruBdBrojLkCtrl;
  late final TextEditingController _naruBdTelefon1Ctrl;
  late final TextEditingController _naruBdTelefon2Ctrl;
  late final TextEditingController _naruBdEmailCtrl;

  // A1 / DRUGO LICE
  late final TextEditingController _naruImeCtrl;
  late final TextEditingController _naruPrezimeCtrl;
  late final TextEditingController _naruJmbgCtrl;
  late final TextEditingController _naruAdresaCtrl;
  late final TextEditingController _naruBrojLkCtrl;
  late final TextEditingController _naruTelefon1Ctrl;
  late final TextEditingController _naruTelefon2Ctrl;
  late final TextEditingController _naruEmailCtrl;

  // A2 / PRAVNO LICE
  late final TextEditingController _naruPlNazivCtrl;
  late final TextEditingController _naruPlAdresaCtrl;
  late final TextEditingController _naruPlPibCtrl;
  late final TextEditingController _naruPlMbCtrl;
  late final TextEditingController _naruPlOdgovornoLiceCtrl;
  late final TextEditingController _naruPlTelefon1Ctrl;
  late final TextEditingController _naruPlTelefon2Ctrl;
  late final TextEditingController _naruPlEmailCtrl;

  // Cross-block
  bool _naruIstiZaJkp = false;

  // Block B - top level
  String _jkpTip = 'FIZICKO_LICE';
  /// B1 sub-tip: 'BRACNI_DRUG' | 'DRUGO_LICE'
  String _jkpFizSubTip = 'DRUGO_LICE';
  /// B2 sub-tip: 'ZASTUPNIK' | 'DRUGO_PRAVNO_LICE'
  String _jkpPravnoSubTip = 'DRUGO_PRAVNO_LICE';

  // B1 / BRACNI DRUG - extra editable fields
  late final TextEditingController _jkpBdAdresaCtrl;
  late final TextEditingController _jkpBdBrojLkCtrl;
  late final TextEditingController _jkpBdTelefon1Ctrl;
  late final TextEditingController _jkpBdTelefon2Ctrl;
  late final TextEditingController _jkpBdEmailCtrl;

  // B1 / DRUGO LICE
  late final TextEditingController _jkpImeCtrl;
  late final TextEditingController _jkpPrezimeCtrl;
  late final TextEditingController _jkpJmbgCtrl;
  late final TextEditingController _jkpAdresaCtrl;
  late final TextEditingController _jkpBrojLkCtrl;
  late final TextEditingController _jkpTelefon1Ctrl;
  late final TextEditingController _jkpTelefon2Ctrl;
  late final TextEditingController _jkpEmailCtrl;

  // B2 / DRUGO PRAVNO LICE (ZASTUPNIK reads directly from firmaPodaci)
  late final TextEditingController _jkpPlNazivCtrl;
  late final TextEditingController _jkpPlAdresaCtrl;
  late final TextEditingController _jkpPlPibCtrl;
  late final TextEditingController _jkpPlMbCtrl;
  late final TextEditingController _jkpPlOdgovornoLiceCtrl;
  late final TextEditingController _jkpPlTelefon1Ctrl;
  late final TextEditingController _jkpPlEmailCtrl;

  // Focus + validation
  final _naruImeFocus = FocusNode();
  final _naruPrezimeFocus = FocusNode();
  final _naruPlNazivFocus = FocusNode();
  final _naruTelefon1Focus = FocusNode();
  final _naruPlTelefon1Focus = FocusNode();
  bool _naruImeTouched = false;
  bool _naruPrezimeTouched = false;
  bool _naruPlNazivTouched = false;
  bool _naruTelefon1Touched = false;
  bool _naruPlTelefon1Touched = false;

  // Computed properties

  /// True ako preminulo lice ima zivog bracnog druga sa unesenim imenom.
  bool get _mozeBracniDrug {
    final bs = widget.initialData.bracnoStanje;
    return (bs == 'O\u017DENJEN' || bs == 'UDATA') &&
        widget.initialData.bracniDrugIme.isNotEmpty;
  }

  // Block A - computed field values for save
  String get _cNaruIme {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugIme;
    }
    return _normalizedText(_naruImeCtrl);
  }

  String get _cNaruPrezime {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugPrezime;
    }
    return _normalizedText(_naruPrezimeCtrl);
  }

  String get _cNaruJmbg {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugJmbg;
    }
    return _normalizedText(_naruJmbgCtrl);
  }

  String get _cNaruAdresa {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_naruBdAdresaCtrl);
    }
    return _normalizedText(_naruAdresaCtrl);
  }

  String get _cNaruBrojLk {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_naruBdBrojLkCtrl);
    }
    return _normalizedText(_naruBrojLkCtrl);
  }

  String get _cNaruTelefon1 {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_naruBdTelefon1Ctrl);
    }
    return _normalizedText(_naruTelefon1Ctrl);
  }

  String get _cNaruTelefon2 {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_naruBdTelefon2Ctrl);
    }
    return _normalizedText(_naruTelefon2Ctrl);
  }

  String get _cNaruEmail {
    if (_naruTip == 'FIZICKO_LICE' && _naruFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_naruBdEmailCtrl);
    }
    return _normalizedText(_naruEmailCtrl);
  }

  // Block B - computed field values for save (or copy from A if isti)
  String get _cJkpIme {
    if (_naruIstiZaJkp) return _cNaruIme;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugIme;
    }
    return _normalizedText(_jkpImeCtrl);
  }

  String get _cJkpPrezime {
    if (_naruIstiZaJkp) return _cNaruPrezime;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugPrezime;
    }
    return _normalizedText(_jkpPrezimeCtrl);
  }

  String get _cJkpJmbg {
    if (_naruIstiZaJkp) return _cNaruJmbg;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return widget.initialData.bracniDrugJmbg;
    }
    return _normalizedText(_jkpJmbgCtrl);
  }

  String get _cJkpAdresa {
    if (_naruIstiZaJkp) return _cNaruAdresa;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_jkpBdAdresaCtrl);
    }
    return _normalizedText(_jkpAdresaCtrl);
  }

  String get _cJkpBrojLk {
    if (_naruIstiZaJkp) return _cNaruBrojLk;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_jkpBdBrojLkCtrl);
    }
    return _normalizedText(_jkpBrojLkCtrl);
  }

  String get _cJkpTelefon1 {
    if (_naruIstiZaJkp) return _cNaruTelefon1;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_jkpBdTelefon1Ctrl);
    }
    return _normalizedText(_jkpTelefon1Ctrl);
  }

  String get _cJkpTelefon2 {
    if (_naruIstiZaJkp) return _cNaruTelefon2;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_jkpBdTelefon2Ctrl);
    }
    return _normalizedText(_jkpTelefon2Ctrl);
  }

  String get _cJkpEmail {
    if (_naruIstiZaJkp) return _cNaruEmail;
    if (_jkpTip == 'FIZICKO_LICE' && _jkpFizSubTip == 'BRACNI_DRUG') {
      return _normalizedText(_jkpBdEmailCtrl);
    }
    return _normalizedText(_jkpEmailCtrl);
  }

  String get _cJkpPlNaziv {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlNazivCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.naziv;
    }
    return _normalizedText(_jkpPlNazivCtrl);
  }

  String get _cJkpPlAdresa {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlAdresaCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.adresa;
    }
    return _normalizedText(_jkpPlAdresaCtrl);
  }

  String get _cJkpPlPib {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlPibCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.pib;
    }
    return _normalizedText(_jkpPlPibCtrl);
  }

  String get _cJkpPlMb {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlMbCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.mb;
    }
    return _normalizedText(_jkpPlMbCtrl);
  }

  String get _cJkpPlOdgovornoLice {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlOdgovornoLiceCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.odgovornoLice;
    }
    return _normalizedText(_jkpPlOdgovornoLiceCtrl);
  }

  String get _cJkpPlTelefon1 {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlTelefon1Ctrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.telefon;
    }
    return _normalizedText(_jkpPlTelefon1Ctrl);
  }

  String get _cJkpPlEmail {
    if (_naruIstiZaJkp) return _normalizedText(_naruPlEmailCtrl);
    if (_jkpTip == 'PRAVNO_LICE' && _jkpPravnoSubTip == 'ZASTUPNIK') {
      return widget.firmaPodaci.email;
    }
    return _normalizedText(_jkpPlEmailCtrl);
  }

  // Lifecycle

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    final f = widget.firmaPodaci;

    _naruTip = d.naruTip.isEmpty ? 'FIZICKO_LICE' : d.naruTip;

    // Infer A1 sub-tip from saved data
    if (_mozeBracniDrug &&
        d.naruIme.isNotEmpty &&
        d.naruIme == d.bracniDrugIme &&
        d.naruPrezime == d.bracniDrugPrezime) {
      _naruFizSubTip = 'BRACNI_DRUG';
    }

    // A1 BRACNI DRUG extra fields (mapped to naru_* extra columns)
    final isBd = _naruFizSubTip == 'BRACNI_DRUG';
    _naruBdAdresaCtrl = TextEditingController(text: isBd ? d.naruAdresa : '');
    _naruBdBrojLkCtrl = TextEditingController(text: isBd ? d.naruBrojLk : '');
    _naruBdTelefon1Ctrl =
        TextEditingController(text: isBd ? d.naruTelefon1 : '');
    _naruBdTelefon2Ctrl =
        TextEditingController(text: isBd ? d.naruTelefon2 : '');
    _naruBdEmailCtrl = TextEditingController(text: isBd ? d.naruEmail : '');

    // A1 DRUGO LICE
    _naruImeCtrl = TextEditingController(text: isBd ? '' : d.naruIme);
    _naruPrezimeCtrl =
        TextEditingController(text: isBd ? '' : d.naruPrezime);
    _naruJmbgCtrl = TextEditingController(text: isBd ? '' : d.naruJmbg);
    _naruAdresaCtrl = TextEditingController(text: isBd ? '' : d.naruAdresa);
    _naruBrojLkCtrl = TextEditingController(text: isBd ? '' : d.naruBrojLk);
    _naruTelefon1Ctrl =
        TextEditingController(text: isBd ? '' : d.naruTelefon1);
    _naruTelefon2Ctrl =
        TextEditingController(text: isBd ? '' : d.naruTelefon2);
    _naruEmailCtrl = TextEditingController(text: isBd ? '' : d.naruEmail);

    // A2 PRAVNO LICE
    _naruPlNazivCtrl = TextEditingController(text: d.naruPlNaziv);
    _naruPlAdresaCtrl = TextEditingController(text: d.naruPlAdresa);
    _naruPlPibCtrl = TextEditingController(text: d.naruPlPib);
    _naruPlMbCtrl = TextEditingController(text: d.naruPlMb);
    _naruPlOdgovornoLiceCtrl =
        TextEditingController(text: d.naruPlOdgovornoLice);
    _naruPlTelefon1Ctrl = TextEditingController(text: d.naruPlTelefon1);
    _naruPlTelefon2Ctrl = TextEditingController(text: d.naruPlTelefon2);
    _naruPlEmailCtrl = TextEditingController(text: d.naruPlEmail);

    _naruIstiZaJkp = d.naruIstiZaJkp;
    _jkpTip = d.jkpTip.isEmpty ? 'FIZICKO_LICE' : d.jkpTip;

    // Infer B1 sub-tip
    if (_mozeBracniDrug &&
        d.jkpIme.isNotEmpty &&
        d.jkpIme == d.bracniDrugIme &&
        d.jkpPrezime == d.bracniDrugPrezime) {
      _jkpFizSubTip = 'BRACNI_DRUG';
    }

    // Infer B2 sub-tip (ZASTUPNIK if firma data matches)
    if (f.naziv.isNotEmpty &&
        d.jkpPlNaziv == f.naziv &&
        d.jkpPlPib == f.pib) {
      _jkpPravnoSubTip = 'ZASTUPNIK';
    }

    final isJkpBd = _jkpFizSubTip == 'BRACNI_DRUG';
    final isZastupnik = _jkpPravnoSubTip == 'ZASTUPNIK';

    // B1 BRACNI DRUG extra fields
    _jkpBdAdresaCtrl =
        TextEditingController(text: isJkpBd ? d.jkpAdresa : '');
    _jkpBdBrojLkCtrl =
        TextEditingController(text: isJkpBd ? d.jkpBrojLk : '');
    _jkpBdTelefon1Ctrl =
        TextEditingController(text: isJkpBd ? d.jkpTelefon1 : '');
    _jkpBdTelefon2Ctrl =
        TextEditingController(text: isJkpBd ? d.jkpTelefon2 : '');
    _jkpBdEmailCtrl = TextEditingController(text: isJkpBd ? d.jkpEmail : '');

    // B1 DRUGO LICE
    _jkpImeCtrl = TextEditingController(text: isJkpBd ? '' : d.jkpIme);
    _jkpPrezimeCtrl =
        TextEditingController(text: isJkpBd ? '' : d.jkpPrezime);
    _jkpJmbgCtrl = TextEditingController(text: isJkpBd ? '' : d.jkpJmbg);
    _jkpAdresaCtrl = TextEditingController(text: isJkpBd ? '' : d.jkpAdresa);
    _jkpBrojLkCtrl = TextEditingController(text: isJkpBd ? '' : d.jkpBrojLk);
    _jkpTelefon1Ctrl =
        TextEditingController(text: isJkpBd ? '' : d.jkpTelefon1);
    _jkpTelefon2Ctrl =
        TextEditingController(text: isJkpBd ? '' : d.jkpTelefon2);
    _jkpEmailCtrl = TextEditingController(text: isJkpBd ? '' : d.jkpEmail);

    // B2 DRUGO PRAVNO LICE
    _jkpPlNazivCtrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlNaziv);
    _jkpPlAdresaCtrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlAdresa);
    _jkpPlPibCtrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlPib);
    _jkpPlMbCtrl = TextEditingController(text: isZastupnik ? '' : d.jkpPlMb);
    _jkpPlOdgovornoLiceCtrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlOdgovornoLice);
    _jkpPlTelefon1Ctrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlTelefon1);
    _jkpPlEmailCtrl =
        TextEditingController(text: isZastupnik ? '' : d.jkpPlEmail);

    // Blur validation listeners
    _naruImeFocus.addListener(() {
      if (!_naruImeFocus.hasFocus) setState(() => _naruImeTouched = true);
    });
    _naruPrezimeFocus.addListener(() {
      if (!_naruPrezimeFocus.hasFocus) {
        setState(() => _naruPrezimeTouched = true);
      }
    });
    _naruPlNazivFocus.addListener(() {
      if (!_naruPlNazivFocus.hasFocus) {
        setState(() => _naruPlNazivTouched = true);
      }
    });
    _naruTelefon1Focus.addListener(() {
      if (!_naruTelefon1Focus.hasFocus) {
        setState(() => _naruTelefon1Touched = true);
      }
    });
    _naruPlTelefon1Focus.addListener(() {
      if (!_naruPlTelefon1Focus.hasFocus) {
        setState(() => _naruPlTelefon1Touched = true);
      }
    });
  }

  @override
  void didUpdateWidget(NarucilacSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    final od = oldWidget.initialData;
    final nd = widget.initialData;
    // Reset sub-tip if bracni drug is no longer available
    if (!_mozeBracniDrug) {
      if (_naruFizSubTip == 'BRACNI_DRUG') {
        setState(() => _naruFizSubTip = 'DRUGO_LICE');
      }
      if (_jkpFizSubTip == 'BRACNI_DRUG') {
        setState(() => _jkpFizSubTip = 'DRUGO_LICE');
      }
    }
    // Re-save if bracniDrug data changed while in BD mode
    if (od.bracniDrugIme != nd.bracniDrugIme ||
        od.bracniDrugPrezime != nd.bracniDrugPrezime ||
        od.bracniDrugJmbg != nd.bracniDrugJmbg) {
      if (_naruFizSubTip == 'BRACNI_DRUG' || _jkpFizSubTip == 'BRACNI_DRUG') {
        _scheduleSave();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _naruBdAdresaCtrl, _naruBdBrojLkCtrl, _naruBdTelefon1Ctrl,
      _naruBdTelefon2Ctrl, _naruBdEmailCtrl,
      _naruImeCtrl, _naruPrezimeCtrl, _naruJmbgCtrl, _naruAdresaCtrl,
      _naruBrojLkCtrl, _naruTelefon1Ctrl, _naruTelefon2Ctrl, _naruEmailCtrl,
      _naruPlNazivCtrl, _naruPlAdresaCtrl, _naruPlPibCtrl, _naruPlMbCtrl,
      _naruPlOdgovornoLiceCtrl, _naruPlTelefon1Ctrl, _naruPlTelefon2Ctrl,
      _naruPlEmailCtrl,
      _jkpBdAdresaCtrl, _jkpBdBrojLkCtrl, _jkpBdTelefon1Ctrl,
      _jkpBdTelefon2Ctrl, _jkpBdEmailCtrl,
      _jkpImeCtrl, _jkpPrezimeCtrl, _jkpJmbgCtrl, _jkpAdresaCtrl,
      _jkpBrojLkCtrl, _jkpTelefon1Ctrl, _jkpTelefon2Ctrl, _jkpEmailCtrl,
      _jkpPlNazivCtrl, _jkpPlAdresaCtrl, _jkpPlPibCtrl, _jkpPlMbCtrl,
      _jkpPlOdgovornoLiceCtrl, _jkpPlTelefon1Ctrl, _jkpPlEmailCtrl,
    ]) {
      c.dispose();
    }
    for (final f in [
      _naruImeFocus, _naruPrezimeFocus, _naruPlNazivFocus,
      _naruTelefon1Focus, _naruPlTelefon1Focus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // Save

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
    // Osvezava read-only JKP mirror kada se menjaju Block A polja
    if (_naruIstiZaJkp && mounted) setState(() {});
  }

  void _save() {
    final jkpTipSave = _naruIstiZaJkp ? _naruTip : _jkpTip;
    widget.onSave(
      PredmetiCompanion(
        // Block A
        naruTip: Value(_naruTip),
        naruIme: Value(_cNaruIme),
        naruPrezime: Value(_cNaruPrezime),
        naruImePrezime:
            Value('$_cNaruPrezime $_cNaruIme'.trim()),
        naruJmbg: Value(_cNaruJmbg),
        naruAdresa: Value(_cNaruAdresa),
        naruBrojLk: Value(_cNaruBrojLk),
        naruTelefon1: Value(_cNaruTelefon1),
        naruTelefon2: Value(_cNaruTelefon2),
        naruEmail: Value(_cNaruEmail),
        naruPlNaziv: Value(_normalizedText(_naruPlNazivCtrl)),
        naruPlAdresa: Value(_normalizedText(_naruPlAdresaCtrl)),
        naruPlPib: Value(_normalizedText(_naruPlPibCtrl)),
        naruPlMb: Value(_normalizedText(_naruPlMbCtrl)),
        naruPlOdgovornoLice: Value(_normalizedText(_naruPlOdgovornoLiceCtrl)),
        naruPlTelefon1: Value(_normalizedText(_naruPlTelefon1Ctrl)),
        naruPlTelefon2: Value(_normalizedText(_naruPlTelefon2Ctrl)),
        naruPlEmail: Value(_normalizedText(_naruPlEmailCtrl)),
        naruIstiZaJkp: Value(_naruIstiZaJkp),
        // Block B (or copy of A when isti = DA)
        jkpTip: Value(jkpTipSave),
        jkpIme: Value(_cJkpIme),
        jkpPrezime: Value(_cJkpPrezime),
        jkpImePrezime: Value('$_cJkpPrezime $_cJkpIme'.trim()),
        jkpJmbg: Value(_cJkpJmbg),
        jkpAdresa: Value(_cJkpAdresa),
        jkpBrojLk: Value(_cJkpBrojLk),
        jkpTelefon1: Value(_cJkpTelefon1),
        jkpTelefon2: Value(_cJkpTelefon2),
        jkpEmail: Value(_cJkpEmail),
        jkpPlNaziv: Value(_cJkpPlNaziv),
        jkpPlAdresa: Value(_cJkpPlAdresa),
        jkpPlPib: Value(_cJkpPlPib),
        jkpPlMb: Value(_cJkpPlMb),
        jkpPlOdgovornoLice: Value(_cJkpPlOdgovornoLice),
        jkpPlTelefon1: Value(_cJkpPlTelefon1),
        jkpPlEmail: Value(_cJkpPlEmail),
      ),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BLOCK A - PLATILAC OPREME I USLUGA
            _blockHeader(context, 'PLATILAC ROBE I USLUGA'),
            const SizedBox(height: 12),
            _tipSelector(_naruTip, e, (v) => setState(() {
                  _naruTip = v;
                  _scheduleSave();
                })),
            const SizedBox(height: 12),

            if (_naruTip == 'FIZICKO_LICE') ...[
              // Sub-selector (only when bracni drug is available)
              if (_mozeBracniDrug) ...[
                _subSelector(
                  current: _naruFizSubTip,
                  enabled: e,
                  options: const [
                    ('BRACNI_DRUG', 'BRA\u010CNI DRUG'),
                    ('DRUGO_LICE', 'DRUGO LICE'),
                  ],
                  onChanged: (v) => setState(() {
                    _naruFizSubTip = v;
                    _scheduleSave();
                  }),
                ),
                const SizedBox(height: 12),
              ] else ...[
                _NapomenaBracniDrug(
                    bracnoStanje: widget.initialData.bracnoStanje),
                const SizedBox(height: 8),
              ],

              // A1 / BRACNI DRUG
              if (_naruFizSubTip == 'BRACNI_DRUG' && _mozeBracniDrug) ...[
                _roFull(context, 'IME',
                    widget.initialData.bracniDrugIme),
                const SizedBox(height: 12),
                _roFull(context, 'PREZIME',
                    widget.initialData.bracniDrugPrezime),
                const SizedBox(height: 12),
                _roFull(context, 'JMBG',
                    widget.initialData.bracniDrugJmbg),
                const SizedBox(height: 12),
                _fFull('ADRESA', _naruBdAdresaCtrl, e, caps: true),
                const SizedBox(height: 12),
                _row([
                  _f('BROJ LK / PASO\u0160', _naruBdBrojLkCtrl, e),
                  _f('TELEFON 1', _naruBdTelefon1Ctrl, e,
                      keyboard: TextInputType.phone,
                      focusNode: _naruTelefon1Focus,
                      errorText: _naruTelefon1Touched &&
                              _naruBdTelefon1Ctrl.text.isEmpty
                          ? 'Obavezan kontakt'
                          : null),
                ]),
                const SizedBox(height: 12),
                _row([
                  _f('TELEFON 2', _naruBdTelefon2Ctrl, e,
                      keyboard: TextInputType.phone),
                  _f('E-MAIL', _naruBdEmailCtrl, e,
                      keyboard: TextInputType.emailAddress),
                ]),
              ]
              // A1 / DRUGO LICE
              else ...[
                _row([
                  _f('IME', _naruImeCtrl, e,
                      caps: true,
                      focusNode: _naruImeFocus,
                      errorText: (_naruImeTouched || _naruPrezimeTouched) &&
                              _naruImeCtrl.text.isEmpty &&
                              _naruPrezimeCtrl.text.isEmpty
                          ? 'Obavezno'
                          : null),
                  _f('PREZIME', _naruPrezimeCtrl, e,
                      caps: true,
                      focusNode: _naruPrezimeFocus,
                      errorText: (_naruImeTouched || _naruPrezimeTouched) &&
                              _naruImeCtrl.text.isEmpty &&
                              _naruPrezimeCtrl.text.isEmpty
                          ? 'Obavezno'
                          : null),
                ]),
                const SizedBox(height: 12),
                _row([
                  _f('JMBG', _naruJmbgCtrl, e,
                      keyboard: TextInputType.number),
                  _f('BROJ LK / PASO\u0160', _naruBrojLkCtrl, e),
                ]),
                const SizedBox(height: 12),
                _fFull('ADRESA', _naruAdresaCtrl, e, caps: true),
                const SizedBox(height: 12),
                _row([
                  _f('TELEFON 1', _naruTelefon1Ctrl, e,
                      keyboard: TextInputType.phone,
                      focusNode: _naruTelefon1Focus,
                      errorText: _naruTelefon1Touched &&
                              _naruTelefon1Ctrl.text.isEmpty
                          ? 'Obavezan kontakt'
                          : null),
                  _f('TELEFON 2', _naruTelefon2Ctrl, e,
                      keyboard: TextInputType.phone),
                ]),
                const SizedBox(height: 12),
                _fFull('E-MAIL', _naruEmailCtrl, e,
                    keyboard: TextInputType.emailAddress),
              ],
            ]
            // A2 - PRAVNO LICE
            else ...[
              _fFull('NAZIV PRAVNOG LICA', _naruPlNazivCtrl, e,
                  caps: true,
                  focusNode: _naruPlNazivFocus,
                  errorText: _naruPlNazivTouched &&
                          _naruPlNazivCtrl.text.isEmpty
                      ? 'Obavezno'
                      : null),
              const SizedBox(height: 12),
              _fFull('ADRESA', _naruPlAdresaCtrl, e, caps: true),
              const SizedBox(height: 12),
              _row([
                _f('PIB', _naruPlPibCtrl, e),
                _f('MATI\u010CNI BROJ', _naruPlMbCtrl, e),
              ]),
              const SizedBox(height: 12),
              _fFull('ODGOVORNO LICE', _naruPlOdgovornoLiceCtrl, e,
                  caps: true),
              const SizedBox(height: 12),
              _row([
                _f('TELEFON 1', _naruPlTelefon1Ctrl, e,
                    keyboard: TextInputType.phone,
                    focusNode: _naruPlTelefon1Focus,
                    errorText: _naruPlTelefon1Touched &&
                            _naruPlTelefon1Ctrl.text.isEmpty
                        ? 'Obavezan kontakt'
                        : null),
                _f('TELEFON 2', _naruPlTelefon2Ctrl, e,
                    keyboard: TextInputType.phone),
              ]),
              const SizedBox(height: 12),
              _fFull('E-MAIL', _naruPlEmailCtrl, e,
                  keyboard: TextInputType.emailAddress),
            ],

            const SizedBox(height: 8),
            _KontaktBlok(
              predmetId: widget.predmetId,
              blok: 'NARU_OPREMA',
              kontaktRepo: widget.kontaktRepo,
              enabled: e,
            ),

            const SizedBox(height: 4),
            const Divider(),

            // CROSS-BLOCK: Isti platilac za JKP troskove
            Builder(
              builder: (context) {
                return PredmetBooleanDecisionTile(
                  title: 'Isti platilac za JKP tro\u0161kove',
                  value: _naruIstiZaJkp,
                  enabled: e,
                  onChanged: (checked) {
                          setState(() => _naruIstiZaJkp = checked);
                          if (!checked) {
                            // Clear all jkp_* columns on uncheck
                            widget.onSave(const PredmetiCompanion(
                              jkpTip: Value('FIZICKO_LICE'),
                              jkpIme: Value(''),
                              jkpPrezime: Value(''),
                              jkpImePrezime: Value(''),
                              jkpJmbg: Value(''),
                              jkpAdresa: Value(''),
                              jkpBrojLk: Value(''),
                              jkpTelefon1: Value(''),
                              jkpTelefon2: Value(''),
                              jkpEmail: Value(''),
                              jkpPlNaziv: Value(''),
                              jkpPlAdresa: Value(''),
                              jkpPlPib: Value(''),
                              jkpPlMb: Value(''),
                              jkpPlOdgovornoLice: Value(''),
                              jkpPlTelefon1: Value(''),
                              jkpPlEmail: Value(''),
                              naruIstiZaJkp: Value(false),
                            ));
                          } else {
                            _scheduleSave();
                          }
                        },
                );
              },
            ),

            // BLOCK B - PLATILAC JKP TROSKOVA (uvek vidljiv)
            const SizedBox(height: 8),
            _blockHeader(context, 'PLATILAC JKP TRO\u0160KOVA'),
            const SizedBox(height: 12),
            if (_naruIstiZaJkp) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Podaci preuzeti iz PLATILAC ROBE I USLUGA',
                  style: TextStyle(
                    fontSize: 12,
                    color: _preuzetoSupportingColor(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (_naruTip == 'FIZICKO_LICE') ...[
                _row([
                  _roPreuExp(context, 'IME', _cJkpIme),
                  _roPreuExp(context, 'PREZIME', _cJkpPrezime),
                ]),
                const SizedBox(height: 12),
                _row([
                  _roPreuExp(context, 'JMBG', _cJkpJmbg),
                  _roPreuExp(context, 'BROJ LK / PASO\u0160', _cJkpBrojLk),
                ]),
                const SizedBox(height: 12),
                _roPreuFull(context, 'ADRESA', _cJkpAdresa),
                const SizedBox(height: 12),
                _row([
                  _roPreuExp(context, 'TELEFON 1', _cJkpTelefon1),
                  _roPreuExp(context, 'TELEFON 2', _cJkpTelefon2),
                ]),
                const SizedBox(height: 12),
                _roPreuFull(context, 'E-MAIL', _cJkpEmail),
              ] else ...[
                _roPreuFull(context, 'NAZIV', _cJkpPlNaziv),
                const SizedBox(height: 12),
                _roPreuFull(context, 'ADRESA', _cJkpPlAdresa),
                const SizedBox(height: 12),
                _row([
                  _roPreuExp(context, 'PIB', _cJkpPlPib),
                  _roPreuExp(context, 'MATI\u010CNI BROJ', _cJkpPlMb),
                ]),
                const SizedBox(height: 12),
                _roPreuFull(context, 'ODGOVORNO LICE', _cJkpPlOdgovornoLice),
                const SizedBox(height: 12),
                _row([
                  _roPreuExp(context, 'TELEFON', _cJkpPlTelefon1),
                  _roPreuExp(context, 'E-MAIL', _cJkpPlEmail),
                ]),
              ],
              const SizedBox(height: 8),
              _KontaktBlok(
                predmetId: widget.predmetId,
                blok: 'NARU_JKP',
                kontaktRepo: widget.kontaktRepo,
                enabled: e,
              ),
            ] else ...[
              _tipSelector(_jkpTip, e, (v) => setState(() {
                    _jkpTip = v;
                    _scheduleSave();
                  })),
              const SizedBox(height: 12),

              if (_jkpTip == 'FIZICKO_LICE') ...[
                if (_mozeBracniDrug) ...[
                  _subSelector(
                    current: _jkpFizSubTip,
                    enabled: e,
                    options: const [
                      ('BRACNI_DRUG', 'BRA\u010CNI DRUG'),
                      ('DRUGO_LICE', 'DRUGO LICE'),
                    ],
                    onChanged: (v) => setState(() {
                      _jkpFizSubTip = v;
                      _scheduleSave();
                    }),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  _NapomenaBracniDrug(
                      bracnoStanje: widget.initialData.bracnoStanje),
                  const SizedBox(height: 8),
                ],

                // B1 / BRACNI DRUG
                if (_jkpFizSubTip == 'BRACNI_DRUG' && _mozeBracniDrug) ...[
                  _roFull(context, 'IME',
                      widget.initialData.bracniDrugIme),
                  const SizedBox(height: 12),
                  _roFull(context, 'PREZIME',
                      widget.initialData.bracniDrugPrezime),
                  const SizedBox(height: 12),
                  _roFull(context, 'JMBG',
                      widget.initialData.bracniDrugJmbg),
                  const SizedBox(height: 12),
                  _fFull('ADRESA', _jkpBdAdresaCtrl, e, caps: true),
                  const SizedBox(height: 12),
                  _row([
                    _f('BROJ LK / PASO\u0160', _jkpBdBrojLkCtrl, e),
                    _f('TELEFON 1', _jkpBdTelefon1Ctrl, e,
                        keyboard: TextInputType.phone),
                  ]),
                  const SizedBox(height: 12),
                  _row([
                    _f('TELEFON 2', _jkpBdTelefon2Ctrl, e,
                        keyboard: TextInputType.phone),
                    _f('E-MAIL', _jkpBdEmailCtrl, e,
                        keyboard: TextInputType.emailAddress),
                  ]),
                ]
                // B1 / DRUGO LICE
                else ...[
                  _row([
                    _f('IME', _jkpImeCtrl, e, caps: true),
                    _f('PREZIME', _jkpPrezimeCtrl, e, caps: true),
                  ]),
                  const SizedBox(height: 12),
                  _row([
                    _f('JMBG', _jkpJmbgCtrl, e,
                        keyboard: TextInputType.number),
                    _f('BROJ LK / PASO\u0160', _jkpBrojLkCtrl, e),
                  ]),
                  const SizedBox(height: 12),
                  _fFull('ADRESA', _jkpAdresaCtrl, e, caps: true),
                  const SizedBox(height: 12),
                  _row([
                    _f('TELEFON 1', _jkpTelefon1Ctrl, e,
                        keyboard: TextInputType.phone),
                    _f('TELEFON 2', _jkpTelefon2Ctrl, e,
                        keyboard: TextInputType.phone),
                  ]),
                  const SizedBox(height: 12),
                  _fFull('E-MAIL', _jkpEmailCtrl, e,
                      keyboard: TextInputType.emailAddress),
                ],
              ]
              // B2 - PRAVNO LICE
              else ...[
                _subSelector(
                  current: _jkpPravnoSubTip,
                  enabled: e,
                  options: const [
                    ('ZASTUPNIK', 'ZASTUPNIK'),
                    ('DRUGO_PRAVNO_LICE', 'DRUGO PRAVNO LICE'),
                  ],
                  onChanged: (v) => setState(() {
                    _jkpPravnoSubTip = v;
                    _scheduleSave();
                  }),
                ),
                const SizedBox(height: 12),

                if (_jkpPravnoSubTip == 'ZASTUPNIK') ...[
                  _zastupnikNote(context),
                  const SizedBox(height: 12),
                  _roFull(context, 'NAZIV', widget.firmaPodaci.naziv),
                  const SizedBox(height: 12),
                  _roFull(context, 'ADRESA', widget.firmaPodaci.adresa),
                  const SizedBox(height: 12),
                  _row([
                    _roExp(context, 'PIB', widget.firmaPodaci.pib),
                    _roExp(context, 'MATI\u010CNI BROJ', widget.firmaPodaci.mb),
                  ]),
                  const SizedBox(height: 12),
                  _roFull(context, 'ODGOVORNO LICE',
                      widget.firmaPodaci.odgovornoLice),
                  const SizedBox(height: 12),
                  _row([
                    _roExp(context, 'TELEFON', widget.firmaPodaci.telefon),
                    _roExp(context, 'E-MAIL', widget.firmaPodaci.email),
                  ]),
                ]
                else ...[
                  _fFull('NAZIV PRAVNOG LICA', _jkpPlNazivCtrl, e,
                      caps: true),
                  const SizedBox(height: 12),
                  _fFull('ADRESA', _jkpPlAdresaCtrl, e, caps: true),
                  const SizedBox(height: 12),
                  _row([
                    _f('PIB', _jkpPlPibCtrl, e),
                    _f('MATI\u010CNI BROJ', _jkpPlMbCtrl, e),
                  ]),
                  const SizedBox(height: 12),
                  _fFull('ODGOVORNO LICE', _jkpPlOdgovornoLiceCtrl, e,
                      caps: true),
                  const SizedBox(height: 12),
                  _row([
                    _f('TELEFON 1', _jkpPlTelefon1Ctrl, e,
                        keyboard: TextInputType.phone),
                    _f('E-MAIL', _jkpPlEmailCtrl, e,
                        keyboard: TextInputType.emailAddress),
                  ]),
                ],
              ],

              const SizedBox(height: 8),
              _KontaktBlok(
                predmetId: widget.predmetId,
                blok: 'NARU_JKP',
                kontaktRepo: widget.kontaktRepo,
                enabled: e,
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _blockHeader(BuildContext context, String title) => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _zastupnikNote(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Podaci iz Pode\u0161avanja',
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );

  Widget _tipSelector(
          String value, bool enabled, ValueChanged<String> onChanged) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(
                value: 'FIZICKO_LICE', label: Text('FIZI\u010CKO LICE')),
            ButtonSegment(
                value: 'PRAVNO_LICE', label: Text('PRAVNO LICE')),
          ],
          selected: {value},
          onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      );

  Widget _subSelector({
    required String current,
    required bool enabled,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
  }) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          segments: options
              .map((o) => ButtonSegment(value: o.$1, label: Text(o.$2)))
              .toList(),
          selected: {current},
          onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      );

  Widget _roPreuFull(BuildContext context, String label, String value) =>
      _isProtectedFieldLabel(label) && _isRedactedValue(value)
          ? PredmetRedactedField(
              labelText: label,
              fillColor: _preuzetoFieldFillColor(context),
            )
          :
      TextFormField(
        key: ValueKey('preu_$label:$value'),
        initialValue: value.isEmpty ? '\u2014' : value,
        readOnly: true,
        style: _readOnlyFieldTextStyle(
          context,
          color: _preuzetoFieldTextColor(context),
        ),
        decoration: _readOnlyDecoration(
          context,
          label,
          fillColor: _preuzetoFieldFillColor(context),
          labelColor: _preuzetoFieldLabelColor(context),
        ),
      );

  Widget _roPreuExp(BuildContext context, String label, String value) =>
      Expanded(child: _roPreuFull(context, label, value));

  /// Full-width read-only field.
  Widget _roFull(BuildContext context, String label, String value) =>
      _isProtectedFieldLabel(label) && _isRedactedValue(value)
          ? PredmetRedactedField(
              labelText: label,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            )
          :
      TextFormField(
        initialValue: value.isEmpty ? '\u2014' : value,
        readOnly: true,
        style: _readOnlyFieldTextStyle(context),
        decoration: _readOnlyDecoration(
          context,
          label,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );

  /// Expanded read-only field (for use inside _row).
  Widget _roExp(BuildContext context, String label, String value) =>
      Expanded(child: _roFull(context, label, value));

  InputDecoration _readOnlyDecoration(
    BuildContext context,
    String label, {
    required Color fillColor,
    Color? labelColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final effectiveLabelColor = labelColor ?? scheme.onSurfaceVariant;

    return InputDecoration(
      labelText: label,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      isDense: true,
      filled: true,
      fillColor: fillColor,
      labelStyle: TextStyle(color: effectiveLabelColor),
      floatingLabelStyle: TextStyle(color: effectiveLabelColor),
    );
  }

  TextStyle _readOnlyFieldTextStyle(
    BuildContext context, {
    Color? color,
  }) => TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );

  Color _preuzetoFieldTextColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onSurface;
    }

    return Theme.of(context).colorScheme.onSurface;
  }

  Color _preuzetoFieldLabelColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context)
          .colorScheme
          .onSurfaceVariant
          .withValues(alpha: 0.92);
    }

    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _preuzetoSupportingColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context)
          .colorScheme
          .onSurfaceVariant
          .withValues(alpha: 0.92);
    }

    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _preuzetoFieldFillColor(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (theme.brightness == Brightness.dark) {
      return Color.alphaBlend(
        scheme.tertiary.withValues(alpha: 0.16),
        scheme.surfaceContainerHigh,
      );
    }

    return const Color(0xFFFFF9C4);
  }

  Widget _f(
    String label,
    TextEditingController ctrl,
    bool enabled, {
    TextInputType keyboard = TextInputType.text,
    bool caps = false,
    String? errorText,
    FocusNode? focusNode,
  }) =>
      Expanded(
        child: _isProtectedFieldLabel(label)
            ? PredmetProtectedTextField(
                labelText: label,
                controller: ctrl,
                enabled: enabled,
                keyboardType: keyboard,
                focusNode: focusNode,
                textCapitalization:
                    caps ? TextCapitalization.characters : TextCapitalization.none,
                errorText: errorText,
                onChanged: (_) => _scheduleSave(),
              )
            : TextFormField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: keyboard,
          focusNode: focusNode,
          textCapitalization:
              caps ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            errorText: errorText,
          ),
          onChanged: (_) => _scheduleSave(),
        ),
      );

  Widget _fFull(
    String label,
    TextEditingController ctrl,
    bool enabled, {
    TextInputType keyboard = TextInputType.text,
    bool caps = false,
    String? errorText,
    FocusNode? focusNode,
  }) =>
      _isProtectedFieldLabel(label)
          ? PredmetProtectedTextField(
              labelText: label,
              controller: ctrl,
              enabled: enabled,
              keyboardType: keyboard,
              focusNode: focusNode,
              textCapitalization:
                  caps ? TextCapitalization.characters : TextCapitalization.none,
              errorText: errorText,
              onChanged: (_) => _scheduleSave(),
            )
          : TextFormField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: keyboard,
        focusNode: focusNode,
        textCapitalization:
            caps ? TextCapitalization.characters : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          errorText: errorText,
        ),
        onChanged: (_) => _scheduleSave(),
      );

  bool _isProtectedFieldLabel(String label) {
    final normalized = label.toUpperCase();
    return normalized.contains('JMBG') ||
        normalized.contains('BROJ LK') ||
        normalized.contains('PASO') ||
        normalized.contains('ADRESA') ||
        normalized.contains('TELEFON') ||
        normalized.contains('E-MAIL');
  }

  bool _isRedactedValue(String value) =>
      value.trim().toLowerCase() == 'redacted';

  Widget _row(List<Widget> children) => LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final wideChildren = children
              .map<Widget>((w) => w is Expanded ? w : Expanded(child: w))
              .toList();
          final narrowChildren = children
              .map<Widget>(_unwrapFlexChild)
              .expand((w) => [w, const SizedBox(height: 12)])
              .toList()
            ..removeLast();

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: narrowChildren,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: wideChildren
                .expand((w) => [w, const SizedBox(width: 12)])
                .toList()
              ..removeLast(),
          );
        },
      );

  Widget _unwrapFlexChild(Widget widget) {
    if (widget is Expanded) return widget.child;
    if (widget is Flexible) return widget.child;
    return widget;
  }

  String _normalizedText(TextEditingController ctrl) =>
      normalizeText(ctrl.text);
}


class _KontaktBlok extends StatelessWidget {
  const _KontaktBlok({
    required this.predmetId,
    required this.blok,
    required this.kontaktRepo,
    required this.enabled,
  });

  final int predmetId;
  final String blok;
  final KontaktLicaRepository kontaktRepo;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KontaktLicaData>>(
      stream: kontaktRepo
          .watchKontakti(predmetId)
          .map((list) => list.where((k) => k.blok == blok).toList()),
      builder: (context, snap) {
        final lista = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (lista.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'KONTAKT LICA',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              ...lista.map(
                (k) => _KontaktRow(
                  key: ValueKey(k.id),
                  kontakt: k,
                  kontaktRepo: kontaktRepo,
                  enabled: enabled,
                ),
              ),
            ],
            if (enabled)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('DODATNI KONTAKT PODACI'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => kontaktRepo.dodaj(
                      predmetId: predmetId,
                      blok: blok,
                      redosled: lista.length,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KontaktRow extends StatefulWidget {
  const _KontaktRow({
    super.key,
    required this.kontakt,
    required this.kontaktRepo,
    required this.enabled,
  });

  final KontaktLicaData kontakt;
  final KontaktLicaRepository kontaktRepo;
  final bool enabled;

  @override
  State<_KontaktRow> createState() => _KontaktRowState();
}

class _KontaktRowState extends State<_KontaktRow> {
  Timer? _debounce;
  late final TextEditingController _imeCtrl;
  late final TextEditingController _prezimeCtrl;
  late final TextEditingController _telefonCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final k = widget.kontakt;
    final parts = k.imePrezime.trim().split(' ');
    _imeCtrl = TextEditingController(
        text: parts.isNotEmpty ? parts.first : '');
    _prezimeCtrl = TextEditingController(
        text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _telefonCtrl = TextEditingController(text: k.telefon);
    _emailCtrl = TextEditingController(text: k.email);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_imeCtrl, _prezimeCtrl, _telefonCtrl, _emailCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      widget.kontaktRepo.azuriraj(
        widget.kontakt.id,
        KontaktLicaCompanion(
          imePrezime: Value(
              '${normalizeText(_imeCtrl.text)} ${normalizeText(_prezimeCtrl.text)}'
                  .trim()),
          telefon: Value(normalizeText(_telefonCtrl.text)),
          email: Value(normalizeText(_emailCtrl.text)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enabled;
    final imeField = TextFormField(
      controller: _imeCtrl,
      enabled: e,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'IME',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => _scheduleSave(),
    );
    final prezimeField = TextFormField(
      controller: _prezimeCtrl,
      enabled: e,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'PREZIME',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => _scheduleSave(),
    );
    final telefonField = PredmetProtectedTextField(
      labelText: 'TELEFON',
      controller: _telefonCtrl,
      enabled: e,
      keyboardType: TextInputType.phone,
      onChanged: (_) => _scheduleSave(),
    );
    final emailField = PredmetProtectedTextField(
      labelText: 'E-MAIL',
      controller: _emailCtrl,
      enabled: e,
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => _scheduleSave(),
    );
    final deleteButton = IconButton(
      icon: const Icon(Icons.delete_outline, size: 18),
      color: Theme.of(context).colorScheme.error,
      tooltip: 'Obri\u0161i kontakt',
      onPressed: e ? () => widget.kontaktRepo.obrisi(widget.kontakt.id) : null,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                imeField,
                const SizedBox(height: 8),
                prezimeField,
                const SizedBox(height: 8),
                telefonField,
                const SizedBox(height: 8),
                emailField,
                if (e)
                  Align(
                    alignment: Alignment.centerRight,
                    child: deleteButton,
                  ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: imeField),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: prezimeField),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: telefonField),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: emailField),
              if (e) ...[
                const SizedBox(width: 4),
                deleteButton,
              ],
            ],
          );
        },
      ),
    );
  }
}


class _NapomenaBracniDrug extends StatelessWidget {
  const _NapomenaBracniDrug({required this.bracnoStanje});

  final String bracnoStanje;

  String? get _tekst {
    switch (bracnoStanje) {
      case 'UDOVAC':
      case 'UDOVICA':
        return 'Preminulo lice je udovac/udovica \u2014 bra\u010Dni drug nije u \u017Eivotu.';
      case 'RAZVEDEN':
      case 'RAZVEDENA':
        return 'Preminulo lice je razvedeno \u2014 bra\u010Dni drug nije primenljiv.';
      case 'NEO\u017DENJEN':
      case 'NEUDATA':
        return 'Preminulo lice nije bilo u braku \u2014 bra\u010Dni drug nije primenljiv.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _tekst;
    if (t == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
