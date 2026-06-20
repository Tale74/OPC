import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/database.dart';
import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../core/utils/json_export_import.dart';
import '../../auth/domain/session_service.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../stanje_robe/data/stanje_robe_posledice_repository.dart';
import '../data/iriu_repository.dart';
import '../data/kontakt_lica_repository.dart';
import '../data/predmeti_repository.dart';
import '../pdf/lista_pdf_export.dart';
import 'package:opc_v4/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart' as nalog_za_opremanje_pdf_export;
import '../pdf/predracun_pdf_export.dart';
import '../pdf/predmet_pdf_snapshot_export.dart';
import '../pdf/racun_pdf_export.dart';
import '../pdf/specifikacija_troskova_pdf_export.dart';
import 'segments/ceremonija_segment.dart';
import 'segments/finansije_segment.dart';
import 'segments/iriu_segment.dart';
import 'segments/narucilac_segment.dart';
import 'segments/parte_segment.dart';
import 'segments/preminulo_lice_segment.dart';

enum _PredmetLogicalSection {
  preminuloLice,
  cinjeniceOSmrti,
  statusi,
  platilac,
  ceremonija,
  parte,
  robaIUsluge,
  finansije,
  dokumenti,
  pregledIPotvrda,
}

class _PredmetSectionInfo {
  const _PredmetSectionInfo({
    required this.section,
    required this.label,
    required this.icon,
  });

  final _PredmetLogicalSection section;
  final String label;
  final IconData icon;
}

enum _SectionProgressLevel {
  notStarted,
  started,
  needsMore,
  ready,
}

class _SectionProgress {
  const _SectionProgress(this.level);

  final _SectionProgressLevel level;
}

const _predmetSectionInfos = [
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.preminuloLice,
    label: 'Preminulo lice',
    icon: Icons.person_outline,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.cinjeniceOSmrti,
    label: 'Činjenice o smrti',
    icon: Icons.fact_check_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.statusi,
    label: 'Statusi',
    icon: Icons.badge_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.platilac,
    label: 'Platilac',
    icon: Icons.payments_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.ceremonija,
    label: 'Ceremonija',
    icon: Icons.event_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.parte,
    label: 'Parte',
    icon: Icons.article_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.robaIUsluge,
    label: 'Roba i usluge',
    icon: Icons.inventory_2_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.finansije,
    label: 'Finansije',
    icon: Icons.account_balance_wallet_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.dokumenti,
    label: 'Dokumenti',
    icon: Icons.folder_outlined,
  ),
  _PredmetSectionInfo(
    section: _PredmetLogicalSection.pregledIPotvrda,
    label: 'Pregled i potvrda',
    icon: Icons.verified_outlined,
  ),
];

class PredmetScreen extends StatefulWidget {
  const PredmetScreen({
    super.key,
    required this.predmetId,
    required this.predmetiRepo,
    required this.session,
    this.openDocuments = false,
  });

  final int predmetId;
  final PredmetiRepository predmetiRepo;
  final SessionService session;
  final bool openDocuments;

  @override
  State<PredmetScreen> createState() => _PredmetScreenState();
}

class _PredmetScreenState extends State<PredmetScreen> {
  static const _entitlementPolicy = OpcEntitlementPolicy.current();
  late final IriuRepository _iriuRepo;
  late final KontaktLicaRepository _kontaktRepo;
  late final PodesavanjaRepository _podesavanjaRepo;
  late final StanjeRobePoslediceRepository _stockConsequencesRepo;

  bool _ucitava = true;
  bool _cuvaPoslovnuVerziju = false;
  bool _dozvoliJedanIzlaz = false;
  bool _imaNesacuvanihIzmena = false;
  bool _cekaPrviEksplicitniSave = false;
  String? _saveBaselineSnapshot;
  PredmetiData? _predmet;
  double _refundacijaPioIznos = 0.0;
  FirmaPodaciData? _firmaPodaci;
  _PredmetLogicalSection? _selectedSection;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.openDocuments) {
      _selectedSection = _PredmetLogicalSection.dokumenti;
    }
    _iriuRepo = IriuRepository(widget.predmetiRepo.db);
    _kontaktRepo = KontaktLicaRepository(widget.predmetiRepo.db);
    _podesavanjaRepo = PodesavanjaRepository(widget.predmetiRepo.db);
    _stockConsequencesRepo =
        StanjeRobePoslediceRepository(widget.predmetiRepo.db);
    _ucitaj();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _ucitaj() async {
    await widget.predmetiRepo.osveziAutomatskiStatusPredmeta(widget.predmetId);
    final results = await Future.wait([
      widget.predmetiRepo.getPredmet(widget.predmetId),
      _podesavanjaRepo.getAppPodesavanja(),
      _podesavanjaRepo.getFirmaPodaci(),
      widget.predmetiRepo.procitajPoslednjiSaveCommitSnapshot(widget.predmetId),
    ]);
    if (!mounted) return;
    final predmet = results[0] as PredmetiData;
    final poslednjiSaveSnapshot = results[3] as String?;
    final baselineSnapshot =
        poslednjiSaveSnapshot ?? widget.predmetiRepo.snapshotZaSaveCommit(predmet);
    final cekaPrviEksplicitniSave = poslednjiSaveSnapshot == null;
    setState(() {
      _predmet = predmet;
      _refundacijaPioIznos =
          (results[1] as AppPodesavanjaData).refundacijaPioIznos;
      _firmaPodaci = results[2] as FirmaPodaciData;
      _saveBaselineSnapshot = baselineSnapshot;
      _cekaPrviEksplicitniSave = cekaPrviEksplicitniSave;
      _imaNesacuvanihIzmena =
          cekaPrviEksplicitniSave ||
          widget.predmetiRepo.snapshotZaSaveCommit(predmet) != baselineSnapshot;
      _ucitava = false;
    });
  }

  bool get _otvoren => _predmet?.status == 'OTVOREN';
  bool get _zatvoren => _predmet?.status == 'ZATVOREN';
  bool get _zavrsen => _predmet?.status == 'ZAVRŠEN';
  bool get _anonimizovan => _predmet?.status == 'ANONIMIZOVAN';
  bool get _mozeAnonimizacija => _zavrsen;
  bool get _imaMinimumIdentiteta {
    final p = _predmet;
    if (p == null) return true;
    return p.ime.trim().isNotEmpty || p.prezime.trim().isNotEmpty;
  }
  bool get _trebaPotvrdaZaIzlazIzOtvorenogPredmeta =>
      _predmet != null && _otvoren && _imaMinimumIdentiteta && !_anonimizovan;
  bool get _mozeDirektanIzlaz =>
      _dozvoliJedanIzlaz || _anonimizovan || (!_otvoren && _imaMinimumIdentiteta);

  String _predmetHeader(PredmetiData predmet) {
    final identitet = _predmetIdentity(predmet);
    if (identitet.isEmpty) return 'Predmet: novi predmet';
    return 'Predmet: $identitet';
  }

  String _predmetIdentity(PredmetiData predmet) {
    final prezime = predmet.prezime.trim().toLowerCase() == 'redacted'
        ? ''
        : predmet.prezime;
    final ime = predmet.ime.trim().toLowerCase() == 'redacted'
        ? ''
        : predmet.ime;
    return '$prezime $ime'.trim();
  }

  bool _hasAnyText(Iterable<String> values) {
    return values.any((value) => value.trim().isNotEmpty);
  }

  _SectionProgress _progress({
    required bool started,
    required bool ready,
  }) {
    if (ready) return const _SectionProgress(_SectionProgressLevel.ready);
    if (started) return const _SectionProgress(_SectionProgressLevel.needsMore);
    return const _SectionProgress(_SectionProgressLevel.notStarted);
  }

  _SectionProgress _sectionProgress(
    _PredmetLogicalSection section,
    PredmetiData p,
  ) {
    switch (section) {
      case _PredmetLogicalSection.preminuloLice:
        final started = _hasAnyText([
          p.ime,
          p.prezime,
          p.srednje,
          p.jmbg,
          p.datumRodjenja,
          p.adresa,
        ]);
        return _progress(
          started: started,
          ready: p.ime.trim().isNotEmpty || p.prezime.trim().isNotEmpty,
        );
      case _PredmetLogicalSection.cinjeniceOSmrti:
        final started = _hasAnyText([p.datumSmrti, p.mestoSmrti, p.uzrokSmrti]);
        return _progress(
          started: started,
          ready: p.datumSmrti.trim().isNotEmpty &&
              p.mestoSmrti.trim().isNotEmpty,
        );
      case _PredmetLogicalSection.statusi:
        final started = _hasAnyText([
          p.bracnoStanje,
          p.radniStatus,
          p.bracniDrugIme,
          p.bracniDrugPrezime,
        ]);
        return _progress(started: started, ready: started);
      case _PredmetLogicalSection.platilac:
        final started = _hasAnyText([
          p.naruIme,
          p.naruPrezime,
          p.naruPlNaziv,
          p.jkpIme,
          p.jkpPrezime,
          p.jkpPlNaziv,
        ]);
        return _progress(started: started, ready: started);
      case _PredmetLogicalSection.ceremonija:
        final started = _hasAnyText([
              p.datumCeremonije,
              p.vremeCeremonije,
              p.groblje,
            ]) ||
            p.sahranaVanSrbije ||
            p.docekPosmrtnihOstataka;
        return _progress(
          started: started,
          ready: p.datumCeremonije.trim().isNotEmpty ||
              p.groblje.trim().isNotEmpty,
        );
      case _PredmetLogicalSection.parte:
        final started = _hasAnyText([p.parteIme, p.ozaloseni]);
        return _progress(started: started, ready: started);
      case _PredmetLogicalSection.robaIUsluge:
        return const _SectionProgress(
          _SectionProgressLevel.started,
        );
      case _PredmetLogicalSection.finansije:
        return const _SectionProgress(
          _SectionProgressLevel.started,
        );
      case _PredmetLogicalSection.dokumenti:
        return const _SectionProgress(
          _SectionProgressLevel.started,
        );
      case _PredmetLogicalSection.pregledIPotvrda:
        return _SectionProgress(
          _imaNesacuvanihIzmena
              ? _SectionProgressLevel.needsMore
              : _SectionProgressLevel.ready,
        );
    }
  }

  _PredmetLogicalSection _recommendedSection(PredmetiData p) {
    for (final info in _predmetSectionInfos) {
      final progress = _sectionProgress(info.section, p);
      if (progress.level == _SectionProgressLevel.notStarted ||
          progress.level == _SectionProgressLevel.needsMore) {
        return info.section;
      }
    }
    return _PredmetLogicalSection.pregledIPotvrda;
  }

  _PredmetSectionInfo _sectionInfo(_PredmetLogicalSection section) {
    return _predmetSectionInfos.firstWhere((info) => info.section == section);
  }

  void _selectSection(_PredmetLogicalSection section) {
    setState(() => _selectedSection = section);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(0);
      }
    });
  }

  void _returnToHub() {
    setState(() => _selectedSection = null);
  }

  bool _handleNarrowSectionBack(bool isNarrowAndroid) {
    if (!isNarrowAndroid || _selectedSection == null) return false;
    _returnToHub();
    return true;
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

  bool _isNarrowAndroidDialog(BuildContext context) {
    final media = MediaQuery.of(context);
    return Theme.of(context).platform == TargetPlatform.android &&
        media.size.width < 600;
  }

  AlertDialog _buildHeightFitDialog({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
  }) {
    final isNarrowAndroid = _isNarrowAndroidDialog(context);
    return AlertDialog(
      insetPadding: isNarrowAndroid
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : null,
      scrollable: isNarrowAndroid,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowAlignment: OverflowBarAlignment.end,
      title: title,
      content: content,
      actions: actions,
    );
  }

  PredmetiData _applyAutosaveCompanion(
    PredmetiData current,
    PredmetiCompanion companion,
  ) {
    return current.copyWithCompanion(companion);
  }

  bool _hasUnsavedChanges(PredmetiData predmet, {String? baselineSnapshot}) {
    final snapshot = widget.predmetiRepo.snapshotZaSaveCommit(predmet);
    return _cekaPrviEksplicitniSave || snapshot != baselineSnapshot;
  }


  Future<void> _onSave(PredmetiCompanion companion) async {
    final current = _predmet;
    if (current == null) return;
    final sledeceIme = companion.ime.present ? companion.ime.value : current.ime;
    final sledecePrezime = companion.prezime.present
        ? companion.prezime.value
        : current.prezime;
    final diraIdentitet = companion.ime.present || companion.prezime.present;
    if (diraIdentitet &&
        sledeceIme.trim().isEmpty &&
        sledecePrezime.trim().isEmpty) {
      if (mounted) {
        _showSnackBarSafely(
          const SnackBar(
            content: Text('Predmet mora imati bar ime ili prezime.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final updated = _applyAutosaveCompanion(current, companion);
    await widget.predmetiRepo.azurirajPredmet(widget.predmetId, companion);
    if (!mounted) return;
    final imaNesacuvanihIzmena = _hasUnsavedChanges(
      updated,
      baselineSnapshot: _saveBaselineSnapshot,
    );
    if (updated == current && _imaNesacuvanihIzmena == imaNesacuvanihIzmena) {
      return;
    }
    setState(() {
      _predmet = updated;
      _imaNesacuvanihIzmena = imaNesacuvanihIzmena;
    });
  }

  Future<void> _sacuvajPredmet() async {
    if (_cuvaPoslovnuVerziju) return;
    if (!_imaMinimumIdentiteta) {
      if (mounted) {
        _showSnackBarSafely(
          const SnackBar(
            content: Text('Predmet mora imati bar ime ili prezime.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    if (!_imaNesacuvanihIzmena) {
      if (mounted) {
        _showSnackBarSafely(
          const SnackBar(
            content: Text('Nema novih izmena za čuvanje.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _cuvaPoslovnuVerziju = true);
    final ishod = await widget.predmetiRepo.sacuvajPredmet(
      widget.predmetId,
      korisnikId: widget.session.korisnik!.id,
      fallbackSnapshot: _saveBaselineSnapshot,
    );
    final data = await widget.predmetiRepo.getPredmet(widget.predmetId);
    final baselineSnapshot = widget.predmetiRepo.snapshotZaSaveCommit(data);
    final imaNesacuvanihIzmena = _hasUnsavedChanges(
      data,
      baselineSnapshot: baselineSnapshot,
    );
    if (!mounted) return;
    setState(() {
      _predmet = data;
      _saveBaselineSnapshot = baselineSnapshot;
      _imaNesacuvanihIzmena = imaNesacuvanihIzmena;
      _cekaPrviEksplicitniSave = false;
      _cuvaPoslovnuVerziju = false;
    });
    _showSnackBarSafely(
      SnackBar(
        content: Text(
          ishod == SacuvajPredmetIshod.prviSave
              ? 'Radno stanje predmeta je sačuvano.'
              : ishod == SacuvajPredmetIshod.novoSacuvano
              ? 'Izmene su sačuvane u otvorenom predmetu.'
              : 'Nema novih izmena za čuvanje.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _stockCategoryLabel(String kategorija) {
    return StanjeRobeLifecycleService.displayLabelForCoveredCategory(kategorija);
  }

  String _stockBlockerLine(StanjeRobePoslediceData consequence) {
    final article = consequence.selectedNazivSnapshot.trim().isNotEmpty
        ? consequence.selectedNazivSnapshot.trim()
        : consequence.katalogStableArticleId;
    return '${_stockCategoryLabel(consequence.kategorija)} — $article';
  }

  Future<bool> _stanjeRobeAktivno() {
    return StanjeRobeOperationalAvailability(
      podesavanjaRepository: _podesavanjaRepo,
      entitlementPolicy: _entitlementPolicy,
    ).isActive();
  }

  Future<bool> _blokirajZatvaranjeAkoImaStanjeRobePosledica() async {
    if (!await _stanjeRobeAktivno()) return false;
    final unresolved = await _stockConsequencesRepo
        .listActiveUnresolvedForPredmet(widget.predmetId);
    if (unresolved.isEmpty) return false;
    if (!mounted) return true;

    final blockerLines = unresolved.map(_stockBlockerLine).join('\n');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _buildHeightFitDialog(
        context: dialogContext,
        title: const Text('Predmet ne može biti zatvoren'),
        content: Text(
          'STANJE ROBE ima nerazrešenu posledicu za:\n\n'
          '$blockerLines\n\n'
          'Zatvaranje je blokirano dok ADMINISTRATOR ne dopuni zalihu, '
          'dok se artikal ne zameni dostupnim artiklom iz iste kategorije '
          'ili dok se izabrani red ne ukloni.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('U REDU'),
          ),
        ],
      ),
    );
    return true;
  }

  Future<bool> _zatvori() async {
    if (!_imaMinimumIdentiteta) {
      if (mounted) {
        _showSnackBarSafely(
          const SnackBar(
            content: Text('Predmet mora imati bar ime ili prezime.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
    if (await _blokirajZatvaranjeAkoImaStanjeRobePosledica()) {
      return false;
    }
    if (!mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _buildHeightFitDialog(
        context: dialogContext,
        title: const Text('Zatvori predmet'),
        content: const Text(
          'Predmet će biti označen kao ZATVOREN.\n'
          'Zatvaranjem se potvrđuje poslovno stanje.\n'
          'Sva polja će biti zaključana za izmene.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ZATVORI'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return false;
    }
    await widget.predmetiRepo.zatvoriPredmet(
      widget.predmetId,
      korisnikId: widget.session.korisnik!.id,
    );
    await _ucitaj();
    if (!mounted) return false;
    _showSnackBarSafely(
      const SnackBar(
        content: Text(
          'Predmet je zatvoren. Verzija je ažurirana ako je poslovno stanje promenjeno.',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
    return true;
  }

  Future<String?> _potvrdiIzlazakIzOtvorenogPredmeta() {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _buildHeightFitDialog(
        context: ctx,
        title: const Text('Izlazak iz otvorenog predmeta'),
        content: const Text(
          'Predmet je sačuvan kao radno stanje, ali poslovna verzija nastaje tek zatvaranjem predmeta.\n\n'
          'Možete nastaviti izmenu, izaći i ostaviti predmet otvoren, ili zatvoriti predmet i potvrditi poslovno stanje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'stay'),
            child: const Text('OSTANI'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'leave'),
            child: const Text('IZAĐI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'close'),
            child: const Text('ZATVORI PREDMET'),
          ),
        ],
      ),
    );
  }

  Future<void> _izadjiBezZatvaranjaPredmeta() async {
    if (!mounted) return;
    setState(() => _dozvoliJedanIzlaz = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  Future<void> _obradiPokusanIzlazaIzPredmeta() async {
    if (_dozvoliJedanIzlaz) {
      if (mounted) {
        setState(() => _dozvoliJedanIzlaz = false);
      }
      return;
    }
    if (!_imaMinimumIdentiteta && !_anonimizovan) {
      await _resiNevalidanIzlaz();
      return;
    }
    if (!_trebaPotvrdaZaIzlazIzOtvorenogPredmeta) {
      return;
    }
    final akcija = await _potvrdiIzlazakIzOtvorenogPredmeta();
    if (!mounted) return;
    if (akcija == 'leave') {
      await _izadjiBezZatvaranjaPredmeta();
      return;
    }
    if (akcija == 'close') {
      final zatvoren = await _zatvori();
      if (!mounted || !zatvoren) return;
      await _izadjiBezZatvaranjaPredmeta();
    }
  }

  Future<void> _otkljucajZaIzmenu() async {
    await widget.predmetiRepo.otvoriPredmet(
      widget.predmetId,
      korisnikId: widget.session.korisnik!.id,
    );
    await _ucitaj();
    if (mounted) {
      _showSnackBarSafely(
        const SnackBar(
          content: Text(
            'Predmet je otvoren za izmenu. Nova poslovna verzija nastaje tek nakon zatvaranja.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _anonimizuj() async {
    final p = _predmet;
    if (p == null) return;
    if (!_mozeAnonimizacija) {
      if (mounted) {
        _showSnackBarSafely(
          const SnackBar(
            content: Text(
              'GDPR anonimizacija je dostupna samo za predmet sa statusom ZAVRŠEN.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    // true → izvezi pa anonimizuj, false → samo anonimizuj, null → odustani
    final izbor = await showDialog<bool?>(
      context: context,
      builder: (ctx) => _buildHeightFitDialog(
        context: ctx,
        title: const Text('GDPR anonimizacija'),
        content: const Text(
          'GDPR za\u0161tita podataka o li\u010dnosti trajno uklanja za\u0161ti\u0107ene '
          'identifikacione i kontakt podatke.\n\n'
          'Imena ostaju vidljiva. Predmet ostaje u evidenciji sa statusom '
          'ANONIMIZOVAN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('OTKAŽI'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ANONIMIZUJ'),
          ),
        ],
      ),
    );
    if (izbor == null || !mounted) return;
    await widget.predmetiRepo.anonimizujPredmet(widget.predmetId);
    await _ucitaj();
    if (mounted) {
      _showSnackBarSafely(
        const SnackBar(
          content: Text('Predmet je anonimizovan.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool?> _potvrdiBrisanje(BuildContext ctx) {
    final p = _predmet;
    if (p == null) return Future.value(false);
    return showDialog<bool>(
      context: ctx,
      builder: (dialogContext) => _buildHeightFitDialog(
        context: dialogContext,
        title: const Text('Trajno brisanje predmeta'),
        content: Text(
          'Predmet ${p.brojPredmeta} će biti trajno obrisan.\n\n'
          'Biće nepovratno uklonjeni i svi njegovi zavisni podaci.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OBRIŠI TRAJNO'),
          ),
        ],
      ),
    );
  }

  Future<void> _obrisiPredmet({bool popAfterDelete = true}) async {
    final ok = await _potvrdiBrisanje(context);
    if (ok != true || !mounted) return;
    await widget.predmetiRepo.obrisiPredmet(widget.predmetId);
    if (!mounted) return;
    _showSnackBarSafely(
      const SnackBar(
        content: Text('Predmet je trajno obrisan.'),
        duration: Duration(seconds: 2),
      ),
    );
    if (popAfterDelete) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _izveziPredmetJson() async {
    await izvoziPredmetJson(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
    if (!mounted) return;
    await _ucitaj();
  }

  Future<void> _izveziPredmetPdfSnapshot() async {
    await izvoziPredmetPdfSnapshot(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _izveziListaPdf() async {
    await izvoziListaPdf(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _izveziNalogZaOpremanjePdf() async {
    await nalog_za_opremanje_pdf_export.izvoziNalogZaOpremanjePdf(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _izveziPredracunPdf() async {
    await izvoziPredracunPdf(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _izveziSpecifikacijaTroskovaPdf() async {
    await izvoziSpecifikacijaTroskovaPdf(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _izveziRacunPdf() async {
    await izvoziRacunPdf(
      ctx: context,
      db: widget.predmetiRepo.db,
      predmetId: widget.predmetId,
    );
  }

  Future<void> _resiNevalidanIzlaz() async {
    final akcija = await showDialog<String>(
      context: context,
      builder: (ctx) => _buildHeightFitDialog(
        context: ctx,
        title: const Text('Predmet nije validan'),
        content: const Text(
          'Predmet nema ni ime ni prezime preminulog lica.\n\n'
          'Takav predmet ne može ostati u bazi. Vratite se i dopunite podatke ili ga trajno obrišite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'stay'),
            child: const Text('OSTANI'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: const Text('OBRIŠI PREDMET'),
          ),
        ],
      ),
    );
    if (akcija == 'delete' && mounted) {
      await _obrisiPredmet();
    }
  }

  Widget _buildKeyboardScrollFocus({required Widget child}) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final pos = _scrollCtrl.hasClients ? _scrollCtrl.position : null;
        if (pos == null) return KeyEventResult.ignored;
        double? target;
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          target = (_scrollCtrl.offset + 80).clamp(0, pos.maxScrollExtent);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          target = (_scrollCtrl.offset - 80).clamp(0, pos.maxScrollExtent);
        } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
          target = (_scrollCtrl.offset + 400).clamp(0, pos.maxScrollExtent);
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
          target = (_scrollCtrl.offset - 400).clamp(0, pos.maxScrollExtent);
        } else if (event.logicalKey == LogicalKeyboardKey.home) {
          target = 0;
        } else if (event.logicalKey == LogicalKeyboardKey.end) {
          target = pos.maxScrollExtent;
        }
        if (target != null) {
          _scrollCtrl.animateTo(
            target,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
          );
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  Widget _buildPredmetWorkspace({
    required PredmetiData predmet,
    required bool isNarrowAndroid,
    required bool showSpecifikacijaTroskovaPdf,
    required bool showPredracunPdf,
    required bool showListaPdf,
    required bool showNalogZaOpremanjePdf,
    required bool showPredmetPdfSnapshot,
    required bool showJsonTransfer,
    required bool showRacunPdf,
  }) {
    final documentVisibility = _DocumentActionVisibility(
      showSpecifikacijaTroskovaPdf: showSpecifikacijaTroskovaPdf,
      showPredracunPdf: showPredracunPdf,
      showListaPdf: showListaPdf,
      showNalogZaOpremanjePdf: showNalogZaOpremanjePdf,
      showPredmetPdfSnapshot: showPredmetPdfSnapshot,
      showJsonTransfer: showJsonTransfer,
      showRacunPdf: showRacunPdf,
    );
    return Column(
      children: [
        if (_zavrsen)
          MaterialBanner(
            backgroundColor: Colors.blueGrey.shade50,
            leading: Icon(
              Icons.lock_clock_outlined,
              color: Colors.blueGrey.shade700,
            ),
            content: Text(
              'Predmet je automatski prešao u status ZAVRŠEN i zaključan je za izmene.',
              style: TextStyle(
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: const [SizedBox.shrink()],
          ),
        Expanded(
          child: isNarrowAndroid
              ? _buildNarrowWorkspace(
                  predmet: predmet,
                  documentVisibility: documentVisibility,
                )
              : _buildWideWorkspace(
                  predmet: predmet,
                  documentVisibility: documentVisibility,
                ),
        ),
        if (isNarrowAndroid) _buildNarrowPrimaryActionBar(),
      ],
    );
  }

  Widget _buildNarrowPrimaryActionBar() {
    if (_anonimizovan || (!_otvoren && !_zatvoren)) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;
    final statusText = _imaNesacuvanihIzmena
        ? 'Radno stanje: nesačuvane izmene'
        : 'Radno stanje: sačuvano';
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    return Material(
      color: cs.surface,
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_otvoren) ...[
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _cuvaPoslovnuVerziju
                            ? null
                            : _sacuvajPredmet,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _cuvaPoslovnuVerziju ? 'ČUVA...' : 'SAČUVAJ',
                        ),
                        style: buttonStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _zatvori,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('ZATVORI'),
                        style: buttonStyle.copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.orange),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                OutlinedButton.icon(
                  onPressed: _otkljucajZaIzmenu,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('IZMENI'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowWorkspace({
    required PredmetiData predmet,
    required _DocumentActionVisibility documentVisibility,
  }) {
    final selected = _selectedSection;
    if (selected == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PredmetOrientationHeader(text: _predmetHeader(predmet)),
            const SizedBox(height: 12),
            for (final info in _predmetSectionInfos) ...[
              _PredmetHubCard(
                info: info,
                index: _predmetSectionInfos.indexOf(info) + 1,
                recommended: info.section == _recommendedSection(predmet),
                onTap: () => _selectSection(info.section),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    final info = _sectionInfo(selected);
    return _buildKeyboardScrollFocus(
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PredmetOrientationHeader(text: _predmetHeader(predmet)),
            const SizedBox(height: 12),
            _SectionHeader(title: info.label.toUpperCase()),
            _buildSectionContent(
              section: selected,
              predmet: predmet,
              documentVisibility: documentVisibility,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildWideWorkspace({
    required PredmetiData predmet,
    required _DocumentActionVisibility documentVisibility,
  }) {
    final selected =
        _selectedSection ?? _PredmetLogicalSection.preminuloLice;
    final info = _sectionInfo(selected);
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _PredmetOrientationHeader(text: _predmetHeader(predmet)),
                const SizedBox(height: 12),
                for (final item in _predmetSectionInfos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _PredmetSidebarTile(
                      info: item,
                      index: _predmetSectionInfos.indexOf(item) + 1,
                      selected: item.section == selected,
                      onTap: () => _selectSection(item.section),
                    ),
                  ),
              ],
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _buildKeyboardScrollFocus(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(title: info.label.toUpperCase()),
                  _buildSectionContent(
                    section: selected,
                    predmet: predmet,
                    documentVisibility: documentVisibility,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContent({
    required _PredmetLogicalSection section,
    required PredmetiData predmet,
    required _DocumentActionVisibility documentVisibility,
  }) {
    switch (section) {
      case _PredmetLogicalSection.preminuloLice:
        return PreminuloLiceSegment(
          initialData: predmet,
          enabled: _otvoren,
          onSave: _onSave,
          mode: PreminuloLiceSegmentMode.osnovno,
        );
      case _PredmetLogicalSection.cinjeniceOSmrti:
        return PreminuloLiceSegment(
          initialData: predmet,
          enabled: _otvoren,
          onSave: _onSave,
          mode: PreminuloLiceSegmentMode.cinjeniceOSmrti,
        );
      case _PredmetLogicalSection.statusi:
        return PreminuloLiceSegment(
          initialData: predmet,
          enabled: _otvoren,
          onSave: _onSave,
          mode: PreminuloLiceSegmentMode.statusi,
        );
      case _PredmetLogicalSection.platilac:
        return NarucilacSegment(
          initialData: predmet,
          predmetId: widget.predmetId,
          kontaktRepo: _kontaktRepo,
          firmaPodaci: _firmaPodaci!,
          enabled: _otvoren,
          onSave: _onSave,
        );
      case _PredmetLogicalSection.ceremonija:
        return CeremonijuSegment(
          initialData: predmet,
          predmetId: widget.predmetId,
          iriuRepo: _iriuRepo,
          enabled: _otvoren,
          onSave: _onSave,
        );
      case _PredmetLogicalSection.parte:
        return ParteSegment(
          initialData: predmet,
          enabled: _otvoren,
          onSave: _onSave,
        );
      case _PredmetLogicalSection.robaIUsluge:
        return IriuSegment(
          predmetId: widget.predmetId,
          predmetData: predmet,
          iriuRepo: _iriuRepo,
          podesavanjaRepo: _podesavanjaRepo,
          enabled: _otvoren,
          onNapomenaSave: (napomena) => _onSave(
            PredmetiCompanion(napomena: Value(napomena)),
          ),
          initialNapomena: predmet.napomena,
        );
      case _PredmetLogicalSection.finansije:
        return FinansijeSegment(
          initialData: predmet,
          predmetId: widget.predmetId,
          iriuRepo: _iriuRepo,
          enabled: _otvoren,
          onSave: _onSave,
          refundacijaPioIznos: _refundacijaPioIznos,
        );
      case _PredmetLogicalSection.dokumenti:
        return _buildDocumentsSection(documentVisibility);
      case _PredmetLogicalSection.pregledIPotvrda:
        return _buildReviewSection(predmet);
    }
  }

  Widget _buildDocumentsSection(_DocumentActionVisibility visibility) {
    final actions = <Widget>[
      if (visibility.showSpecifikacijaTroskovaPdf)
        _DocumentActionButton(
          icon: Icons.request_quote_outlined,
          label: 'SPECIFIKACIJA TROŠKOVA PDF',
          onPressed: _izveziSpecifikacijaTroskovaPdf,
        ),
      if (visibility.showPredracunPdf)
        _DocumentActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'PREDRAČUN PDF',
          onPressed: _izveziPredracunPdf,
        ),
      if (visibility.showListaPdf)
        _DocumentActionButton(
          icon: Icons.description_outlined,
          label: 'LISTA PDF',
          onPressed: _izveziListaPdf,
        ),
      if (visibility.showNalogZaOpremanjePdf)
        _DocumentActionButton(
          icon: Icons.assignment_outlined,
          label: 'NALOG ZA OPREMANJE PDF',
          onPressed: _izveziNalogZaOpremanjePdf,
        ),
      if (visibility.showPredmetPdfSnapshot)
        _DocumentActionButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'PREDMET PDF snapshot',
          onPressed: _izveziPredmetPdfSnapshot,
        ),
      if (visibility.showJsonTransfer)
        _DocumentActionButton(
          icon: Icons.upload_file_outlined,
          label: 'Izvezi JSON',
          onPressed: _izveziPredmetJson,
        ),
      if (visibility.showRacunPdf)
        _DocumentActionButton(
          icon: Icons.receipt_outlined,
          label: 'RAČUN PDF',
          onPressed: _izveziRacunPdf,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(PredmetiData predmet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReviewRow(label: 'Status', value: predmet.status),
            _ReviewRow(label: 'Verzija predmeta', value: 'v${predmet.verzija}'),
            _ReviewRow(
              label: 'Radno stanje',
              value: _imaNesacuvanihIzmena ? 'Nesačuvano' : 'Sačuvano',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_otvoren)
                  FilledButton.icon(
                    onPressed:
                        _cuvaPoslovnuVerziju ? null : _sacuvajPredmet,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_cuvaPoslovnuVerziju ? 'ČUVA...' : 'SAČUVAJ'),
                  ),
                if (_otvoren)
                  FilledButton.icon(
                    onPressed: _zatvori,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('ZATVORI'),
                  ),
                if (_zatvoren)
                  OutlinedButton.icon(
                    onPressed: _otkljucajZaIzmenu,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('IZMENI'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ucitava || _predmet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PREDMET')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final p = _predmet!;
    final imePrezime = _predmetIdentity(p);
    final appBarIdentity =
        imePrezime.isNotEmpty ? imePrezime : 'Predmet: novi predmet';

    const headerTextStyle = TextStyle(
      fontSize: 13,
      height: 1.0,
      fontWeight: FontWeight.w500,
    );
    final isNarrowAndroid =
        Theme.of(context).platform == TargetPlatform.android &&
        MediaQuery.of(context).size.width < 600;
    final showSpecifikacijaTroskovaPdf = _entitlementPolicy
        .isDocumentActionVisible(OpcDocumentAction.specifikacijaTroskovaPdf);
    final showPredracunPdf =
        _entitlementPolicy.isDocumentActionVisible(OpcDocumentAction.predracunPdf);
    final showListaPdf =
        _entitlementPolicy.isDocumentActionVisible(OpcDocumentAction.listaPdf);
    final showNalogZaOpremanjePdf = _entitlementPolicy
        .isDocumentActionVisible(OpcDocumentAction.nalogZaOpremanjePdf);
    final showPredmetPdfSnapshot = _entitlementPolicy
        .isDocumentActionVisible(OpcDocumentAction.predmetPdfSnapshot);
    final showJsonTransfer =
        _entitlementPolicy.isDocumentActionVisible(OpcDocumentAction.jsonTransfer);
    final showRacunPdf =
        _entitlementPolicy.isDocumentActionVisible(OpcDocumentAction.racunPdf);
    final primaryHeaderTextStyle = headerTextStyle.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: isNarrowAndroid ? 14 : headerTextStyle.fontSize,
    );
    final headerActionPadding = EdgeInsets.symmetric(
      horizontal: isNarrowAndroid ? 12 : 16,
      vertical: 8,
    );

    return PopScope(
      canPop: !(isNarrowAndroid && _selectedSection != null) &&
          _mozeDirektanIzlaz,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_handleNarrowSectionBack(isNarrowAndroid)) return;
        await _obradiPokusanIzlazaIzPredmeta();
      },
      child: Scaffold(
      appBar: AppBar(
        titleSpacing: isNarrowAndroid ? 12 : null,
        toolbarHeight: isNarrowAndroid ? 84 : null,
        title: isNarrowAndroid
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appBarIdentity,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: primaryHeaderTextStyle,
                  ),
                  const SizedBox(height: 6),
                  _StatusChip(status: p.status),
                ],
              )
            : Text(
                appBarIdentity,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: primaryHeaderTextStyle,
              ),
        actions: [
          if (!isNarrowAndroid) ...[
            _StatusChip(status: p.status),
            const SizedBox(width: 4),
          ],
          if (!_anonimizovan) ...[
            if (_otvoren)
              if (!isNarrowAndroid) ...[
                FilledButton(
                  onPressed: _cuvaPoslovnuVerziju ? null : _sacuvajPredmet,
                  style: FilledButton.styleFrom(
                    padding: headerActionPadding,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(_cuvaPoslovnuVerziju ? 'ČUVA...' : 'SAČUVAJ'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _zatvori,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: headerActionPadding,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('ZATVORI'),
                ),
              ]
            else if (_zatvoren && !isNarrowAndroid)
              OutlinedButton(
                onPressed: _otkljucajZaIzmenu,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: headerActionPadding,
                ),
                child: const Text('IZMENI'),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'save') _sacuvajPredmet();
                if (v == 'close') _zatvori();
                if (v == 'edit') _otkljucajZaIzmenu();
                if (v == 'anon') _anonimizuj();
                if (v == 'delete') _obrisiPredmet();
              },
              itemBuilder: (_) => [
                if (!_anonimizovan)
                  PopupMenuItem(
                    value: 'anon',
                    enabled: _mozeAnonimizacija,
                    child: const ListTile(
                      leading: Icon(Icons.person_remove_outlined),
                      title: Text('GDPR anonimizacija'),
                      dense: true,
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Obriši predmet trajno',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
          if (_anonimizovan)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') _obrisiPredmet();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Obriši predmet trajno',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    dense: true,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildPredmetWorkspace(
        predmet: p,
        isNarrowAndroid: isNarrowAndroid,
        showSpecifikacijaTroskovaPdf: showSpecifikacijaTroskovaPdf,
        showPredracunPdf: showPredracunPdf,
        showListaPdf: showListaPdf,
        showNalogZaOpremanjePdf: showNalogZaOpremanjePdf,
        showPredmetPdfSnapshot: showPredmetPdfSnapshot,
        showJsonTransfer: showJsonTransfer,
        showRacunPdf: showRacunPdf,
      ),
    ));
  }
}


class _DocumentActionVisibility {
  const _DocumentActionVisibility({
    required this.showSpecifikacijaTroskovaPdf,
    required this.showPredracunPdf,
    required this.showListaPdf,
    required this.showNalogZaOpremanjePdf,
    required this.showPredmetPdfSnapshot,
    required this.showJsonTransfer,
    required this.showRacunPdf,
  });

  final bool showSpecifikacijaTroskovaPdf;
  final bool showPredracunPdf;
  final bool showListaPdf;
  final bool showNalogZaOpremanjePdf;
  final bool showPredmetPdfSnapshot;
  final bool showJsonTransfer;
  final bool showRacunPdf;
}

class _PredmetOrientationHeader extends StatelessWidget {
  const _PredmetOrientationHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _PredmetHubCard extends StatelessWidget {
  const _PredmetHubCard({
    required this.info,
    required this.index,
    required this.recommended,
    required this.onTap,
  });

  final _PredmetSectionInfo info;
  final int index;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: recommended ? cs.primaryContainer.withValues(alpha: 0.38) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(info.icon, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredmetSidebarTile extends StatelessWidget {
  const _PredmetSidebarTile({
    required this.info,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final _PredmetSectionInfo info;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: CircleAvatar(
        radius: 14,
        child: Text(
          '$index',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
      title: Text(info.label),
      onTap: onTap,
      dense: true,
    );
  }
}

class _DocumentActionButton extends StatelessWidget {
  const _DocumentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Section header
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 8),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}



// Status chip
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'ZATVOREN' => Colors.orange.shade200,
      'ZAVRŠEN' => Colors.grey.shade300,
      _ => Colors.teal.shade200,
    };
    final textColor = switch (status) {
      'ZATVOREN' => Colors.orange.shade900,
      'ZAVRŠEN' => Colors.grey.shade700,
      _ => Colors.teal.shade900,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}



