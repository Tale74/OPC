import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../core/database/database.dart';
import '../../../core/format/app_date_format.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/auth_security_repository.dart';
import '../../auth/domain/session_service.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../../podesavanja/presentation/podesavanja_screen.dart';
import '../../setup/application/setup_readiness_service.dart';
import '../../stanje_robe/application/stanje_robe_lifecycle_service.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../stanje_robe/data/stanje_robe_posledice_repository.dart';
import '../data/iriu_repository.dart';
import '../data/predmeti_repository.dart';
import '../reminders/reminder_mvp_service.dart';
import 'izvestaji_screen.dart';
import 'predmet_screen.dart';

class ListaPredmetaScreen extends StatefulWidget {
  const ListaPredmetaScreen({
    super.key,
    required this.predmetiRepo,
    required this.authRepo,
    required this.podesavanjaRepo,
    required this.session,
    this.reminderService,
    this.predmetiStreamOverride,
    this.runStartupSideEffects = true,
  });

  final PredmetiRepository predmetiRepo;
  final AuthRepository authRepo;
  final PodesavanjaRepository podesavanjaRepo;
  final SessionService session;
  final ReminderMvpService? reminderService;
  final Stream<List<PredmetiData>>? predmetiStreamOverride;
  final bool runStartupSideEffects;

  @override
  State<ListaPredmetaScreen> createState() => _ListaPredmetaScreenState();
}

class _ListaPredmetaScreenState extends State<ListaPredmetaScreen> {
  static const _entitlementPolicy = OpcEntitlementPolicy.current();
  final _pretragaCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _pretraga = '';
  String _statusFilter = 'SVE';
  bool _kreiram = false;
  Map<int, String> _savetnici = {};
  final Set<String> _dismissedReminderKeys = <String>{};
  late final ReminderMvpService _reminderService =
      widget.reminderService ?? ReminderMvpService();
  late final AuthSecurityRepository _authSecurityRepo =
      AuthSecurityRepository(widget.predmetiRepo.db);
  late final SetupReadinessService _setupReadinessService =
      SetupReadinessService(authSecurityRepository: _authSecurityRepo);
  late final StanjeRobePoslediceRepository _stockConsequencesRepo =
      StanjeRobePoslediceRepository(widget.predmetiRepo.db);
  bool _startupSideEffectsRunning = false;
  bool _missingRecoveryWarningShown = false;
  SetupReadinessState _setupReadiness = const SetupReadinessState.ready();
  bool _setupReadinessLoaded = false;
  bool _setupGuidanceDismissed = false;

  @override
  void initState() {
    super.initState();
    if (widget.runStartupSideEffects) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_runStartupSideEffects());
      });
      unawaited(_ucitajSavetnike());
    }
  }

  Future<void> _runStartupSideEffects() async {
    if (_startupSideEffectsRunning) return;
    _startupSideEffectsRunning = true;
    try {
      await widget.predmetiRepo.osveziAutomatskeStatuse();
      if (!mounted) return;
      await _gdprCheck();
      if (!mounted) return;
      await _refreshSetupReadiness(showWarning: true);
    } finally {
      _startupSideEffectsRunning = false;
    }
  }

  Future<void> _refreshSetupReadiness({required bool showWarning}) async {
    final readiness =
        await _setupReadinessService.evaluateForSession(widget.session);
    if (!mounted) return;
    setState(() {
      _setupReadiness = readiness;
      _setupReadinessLoaded = true;
    });
    if (showWarning) {
      await _maybeShowMissingRecoveryWarning(readiness);
    }
  }

  Future<void> _maybeShowMissingRecoveryWarning(
    SetupReadinessState readiness,
  ) async {
    if (!widget.session.jeAdmin || _missingRecoveryWarningShown) return;

    final missingRecovery = readiness.isMissing(
      SetupReadinessItem.recoverySecurityCode,
    );
    if (!missingRecovery || !mounted) return;

    _missingRecoveryWarningShown = true;
    _showSnackBarSafely(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: const Text(
          'Sigurnosni kod nije podešen. Aplikacija radi, ali podesite oporavak pristupa.',
        ),
        action: SnackBarAction(
          label: 'KORISNICI',
          onPressed: _openKorisniciSetup,
        ),
      ),
      hideCurrent: true,
    );
  }

  Future<void> _openKorisniciSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PodesavanjaScreen(
          repo: widget.podesavanjaRepo,
          authRepo: widget.authRepo,
          session: widget.session,
          initialSection: OpcSettingsSection.korisnici,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshSetupReadiness(showWarning: false);
  }

  Future<void> _ucitajSavetnike() async {
    final lista = await widget.authRepo.sviKorisnici();
    if (mounted) {
      setState(() {
        _savetnici = {for (final k in lista) k.id: k.imePrezime};
      });
    }
  }

  @override
  void dispose() {
    _pretragaCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _showSnackBarSafely(SnackBar snackBar, {bool hideCurrent = false}) {
    if (!mounted) return false;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return false;
    try {
      if (hideCurrent) messenger.hideCurrentSnackBar();
      messenger.showSnackBar(snackBar);
      return true;
    } on StateError {
      return false;
    } on FlutterError {
      return false;
    }
  }

  List<PredmetiData> _filtriraj(List<PredmetiData> svi) {
    var lista = svi;
    if (_statusFilter != 'SVE') {
      lista = lista.where((p) => p.status == _statusFilter).toList();
    }
    if (_pretraga.isNotEmpty) {
      final q = _pretraga.toLowerCase();
      lista = lista
          .where(
            (p) =>
                p.prezime.toLowerCase().contains(q) ||
                p.ime.toLowerCase().contains(q) ||
                p.brojPredmeta.toLowerCase().contains(q),
          )
          .toList();
    }
    return lista;
  }

  Future<void> _noviPredmet() async {
    setState(() => _kreiram = true);
    try {
      final id = await widget.predmetiRepo.kreirajPredmet(
        savetnikId: widget.session.korisnik!.id,
      );
      await widget.predmetiRepo.inicijalizujIriu(id);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => PredmetScreen(
            predmetId: id,
            predmetiRepo: widget.predmetiRepo,
            session: widget.session,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _kreiram = false);
    }
  }

  Future<void> _otvoriPredmet(PredmetiData predmet) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PredmetScreen(
          predmetId: predmet.id,
          predmetiRepo: widget.predmetiRepo,
          session: widget.session,
        ),
      ),
    );
  }

  Future<void> _otvoriDokumente(PredmetiData predmet) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PredmetScreen(
          predmetId: predmet.id,
          predmetiRepo: widget.predmetiRepo,
          session: widget.session,
          openDocuments: true,
        ),
      ),
    );
  }

  String _stockBlockerLine(StanjeRobePoslediceData consequence) {
    final article = consequence.selectedNazivSnapshot.trim().isNotEmpty
        ? consequence.selectedNazivSnapshot.trim()
        : consequence.katalogStableArticleId;
    final categoryLabel =
        StanjeRobeLifecycleService.displayLabelForCoveredCategory(
      consequence.kategorija,
    );
    return '$categoryLabel — $article';
  }

  Future<bool> _stanjeRobeAktivno() {
    return StanjeRobeOperationalAvailability(
      podesavanjaRepository: widget.podesavanjaRepo,
      entitlementPolicy: _entitlementPolicy,
    ).isActive();
  }

  Stream<StanjeRobeOperationalStatus> _stanjeRobeStatusStream() {
    return StanjeRobeOperationalAvailability(
      podesavanjaRepository: widget.podesavanjaRepo,
      entitlementPolicy: _entitlementPolicy,
    ).watchStatus();
  }

  Future<bool> _blokirajZatvaranjeAkoImaStanjeRobePosledica(
    PredmetiData p,
  ) async {
    if (!await _stanjeRobeAktivno()) return false;
    final unresolved =
        await _stockConsequencesRepo.listActiveUnresolvedForPredmet(p.id);
    if (unresolved.isEmpty) return false;
    if (!mounted) return true;

    final blockerLines = unresolved.map(_stockBlockerLine).join('\n');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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

  Future<void> _zatvoriPredmetSaListe(PredmetiData p) async {
    if (p.ime.trim().isEmpty && p.prezime.trim().isEmpty) {
      if (!mounted) return;
      _showSnackBarSafely(
        const SnackBar(
          content: Text('Predmet mora imati bar ime ili prezime.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (await _blokirajZatvaranjeAkoImaStanjeRobePosledica(p)) {
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zatvori predmet'),
        content: Text(
          'Predmet ${p.brojPredmeta} \u0107e biti ozna\u010den kao ZATVOREN.\n'
          'Zatvaranjem se potvr\u0111uje poslovno stanje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ZATVORI'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.predmetiRepo.zatvoriPredmet(
      p.id,
      korisnikId: widget.session.korisnik!.id,
    );
  }

  Future<void> _otvoriZaIzmenuSaListe(PredmetiData p) async {
    await widget.predmetiRepo.otvoriPredmet(
      p.id,
      korisnikId: widget.session.korisnik!.id,
    );
    if (!mounted) return;
    _showSnackBarSafely(
      SnackBar(
        content: Text('Predmet ${p.brojPredmeta} je otvoren za izmenu.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _anonimizuj(PredmetiData p) async {
    if (p.status != 'ZAVRŠEN') {
      if (!mounted) return;
      _showSnackBarSafely(
        const SnackBar(
          content: Text(
            'GDPR anonimizacija je dostupna samo za predmet sa statusom ZAVRŠEN.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final izbor = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GDPR anonimizacija'),
        content: Text(
          'Anonimizovati predmet ${p.brojPredmeta}?\n\n'
          'GDPR za\u0161tita podataka o li\u010dnosti trajno uklanja za\u0161ti\u0107ene '
          'identifikacione i kontakt podatke.\n\n'
          'Imena ostaju vidljiva. Predmet ostaje u evidenciji sa statusom '
          'ANONIMIZOVAN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('OTKA\u017DI'),
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

    if (izbor == null) return;

    if (mounted) await widget.predmetiRepo.anonimizujPredmet(p.id);
  }

  Future<void> _obrisi(PredmetiData p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trajno brisanje predmeta'),
        content: Text(
          'Predmet ${p.brojPredmeta} će biti trajno obrisan.\n\n'
          'Bi\u0107e nepovratno uklonjeni i svi njegovi zavisni podaci.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRI\u0160I TRAJNO'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.predmetiRepo.obrisiPredmet(p.id);
    if (!mounted) return;
    _showSnackBarSafely(
      SnackBar(
        content: Text('Predmet ${p.brojPredmeta} je trajno obrisan.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// GDPR provera pri startu: upozorenje bez automatske anonimizacije.
  Future<void> _gdprCheck() async {
    if (!mounted) return;
    final predmeti = await widget.predmetiRepo.getZavrseneZaGdpr();
    if (!mounted) return;

    final danas = DateTime.now();
    final danasDate = DateTime(danas.year, danas.month, danas.day);

    final List<PredmetiData> dan9 = [];
    final List<PredmetiData> dan10plus = [];

    for (final p in predmeti) {
      final dostupnoOd = widget.predmetiRepo.datumDostupnostiAnonimizacije(p);
      if (dostupnoOd == null) continue;
      final daniDoDostupnosti = dostupnoOd.difference(danasDate).inDays;
      if (daniDoDostupnosti <= 0) {
        dan10plus.add(p);
      } else if (daniDoDostupnosti == 1) {
        dan9.add(p);
      }
    }

    if (dan10plus.isNotEmpty && mounted) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('GDPR \u2014 anonimizacija dostupna'),
            content: Text(
              '${dan10plus.length} predmet(a) je dostupno za GDPR anonimizaciju.\n\n'
              'GDPR za\u0161tita podataka o li\u010dnosti se pokre\u0107e ru\u010dno iz menija predmeta.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('U REDU'),
              ),
            ],
          ),
        );
      }
    }

    if (dan9.isNotEmpty && mounted) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('GDPR \u2014 Upozorenje'),
          content: Text(
            '${dan9.length} predmet(a) dostiže raniji GDPR rok sutra.\n\n'
            'GDPR zaštita podataka o ličnosti se pokreće ručno iz menija predmeta.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('RAZUMEM'),
            ),
          ],
        ),
      );
    }
  }

  void _dismissWindowsReminder(Iterable<ReminderMvpEntry> entries) {
    setState(() {
      _dismissedReminderKeys.addAll(entries.map((entry) => entry.sessionKey));
    });
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final izlaz = await _prikaziIzlazDijalog(context);
        if (izlaz == true) {
          SystemNavigator.pop();
        }
      },
      child: _buildScaffold(context),
    );
  }

  Future<bool?> _prikaziIzlazDijalog(BuildContext ctx) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Izlaz iz aplikacije'),
        content: const Text('Da li \u017Eelite da iza\u0111ete iz aplikacije?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('OSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('IZA\u0110I'),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final isWindowsDerivative = kIsWindowsBuild;
    final mozeStatistika =
        _entitlementPolicy.isModuleAvailable(OpcModule.statistika) &&
        widget.session.jeAdmin;
    final mozePodesavanja =
        _entitlementPolicy.hasVisibleSettingsSections && widget.session.jeAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPC \u2014 LISTA PREDMETA'),
        actions: [
          /*
          if (widget.session.jeAdmin && !isWindowsDerivative) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Pode\u0161avanja',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PodesavanjaScreen(repo: widget.podesavanjaRepo),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Savetnici',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => KorisniciScreen(
                    authRepo: widget.authRepo,
                    session: widget.session,
                  ),
                ),
              ),
            ),
          ],
          if (!isWindowsDerivative) IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Izve\u0161taji',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StatistikaScreen(
                  predmetiRepo: widget.predmetiRepo,
                  iriuRepo: IriuRepository(widget.predmetiRepo.db),
                ),
              ),
            ),
          ),
          */
          if (mozeStatistika)
            IconButton(
              icon: const Icon(Icons.bar_chart_outlined),
              tooltip: 'Statistika',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => StatistikaScreen(
                    predmetiRepo: widget.predmetiRepo,
                    iriuRepo: IriuRepository(widget.predmetiRepo.db),
                  ),
                ),
              ),
            ),
          if (mozePodesavanja)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Pode\u0161avanja',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PodesavanjaScreen(
                    repo: widget.podesavanjaRepo,
                    authRepo: widget.authRepo,
                    session: widget.session,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Odjava',
            onPressed: () => widget.session.odjavi(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilteri(),
          Expanded(
            child: StreamBuilder<List<PredmetiData>>(
              stream: widget.predmetiStreamOverride ?? widget.predmetiRepo.watchSvi(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final svi = snap.data ?? [];
                final lista = _filtriraj(svi);
                final dueEntries = kIsWindowsBuild
                    ? _reminderService.collectDueEntries(svi)
                    : const <ReminderMvpEntry>[];
                final visibleReminderEntries = dueEntries
                    .where(
                      (entry) => !_dismissedReminderKeys.contains(
                        entry.sessionKey,
                      ),
                    )
                    .toList();
                if (lista.isEmpty) {
                  return _buildListBody(
                    content: _buildPraznaLista(svi.isEmpty),
                    visibleReminderEntries: visibleReminderEntries,
                  );
                }
                return StreamBuilder<StanjeRobeOperationalStatus>(
                  stream: _stanjeRobeStatusStream(),
                  builder: (context, activeSnap) {
                    final stanjeRobeActive =
                        activeSnap.data == StanjeRobeOperationalStatus.active;
                    if (!stanjeRobeActive) {
                      return _buildListBody(
                        content: _buildListView(
                          lista,
                          svi.length,
                          const <int>{},
                        ),
                        visibleReminderEntries: visibleReminderEntries,
                      );
                    }
                    return StreamBuilder<Set<int>>(
                      stream: _stockConsequencesRepo
                          .watchPredmetIdsWithActiveUnresolved(),
                      builder: (context, unresolvedSnap) {
                        return _buildListBody(
                          content: _buildListView(
                            lista,
                            svi.length,
                            unresolvedSnap.data ?? const <int>{},
                          ),
                          visibleReminderEntries: visibleReminderEntries,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isWindowsDerivative
          ? null
          : FloatingActionButton.extended(
              onPressed: _kreiram ? null : _noviPredmet,
              icon: _kreiram
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('NOVI PREDMET'),
            ),
    );
  }

  Widget _buildFilteri() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _pretragaCtrl,
            decoration: InputDecoration(
              hintText: 'Pretra\u017Ei po imenu ili broju predmeta...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _pretraga.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _pretragaCtrl.clear();
                        setState(() => _pretraga = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _pretraga = v),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'SVE',
                selected: _statusFilter == 'SVE',
                onTap: () => setState(() => _statusFilter = 'SVE'),
              ),
              _FilterChip(
                label: 'OTVOREN',
                selected: _statusFilter == 'OTVOREN',
                color: Colors.teal,
                onTap: () => setState(() => _statusFilter = 'OTVOREN'),
              ),
              _FilterChip(
                label: 'ZATVOREN',
                selected: _statusFilter == 'ZATVOREN',
                color: Colors.orange,
                onTap: () => setState(() => _statusFilter = 'ZATVOREN'),
              ),
              _FilterChip(
                label: 'ZAVR\u0160EN',
                selected: _statusFilter == 'ZAVR\u0160EN',
                color: Colors.grey,
                onTap: () => setState(() => _statusFilter = 'ZAVR\u0160EN'),
              ),
              _FilterChip(
                label: 'ANONIMIZOVAN',
                selected: _statusFilter == 'ANONIMIZOVAN',
                color: Colors.deepPurple,
                onTap: () => setState(() => _statusFilter = 'ANONIMIZOVAN'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildPraznaLista(bool baza) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            baza ? Icons.folder_open_outlined : Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            baza
                ? (kIsWindowsBuild
                    ? 'Nema predmeta.'
                    : 'Nema predmeta.\nPritisnite + NOVI PREDMET.')
                : 'Nema predmeta koji odgovaraju filteru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListBody({
    required Widget content,
    required List<ReminderMvpEntry> visibleReminderEntries,
  }) {
    return Column(
      children: [
        if (_shouldShowSetupGuidance)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SetupReadinessBanner(
              onOpenSetup: _openKorisniciSetup,
              onDismiss: () => setState(() => _setupGuidanceDismissed = true),
            ),
          ),
        if (visibleReminderEntries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _WindowsReminderBanner(
              entries: visibleReminderEntries,
              onClose: () => _dismissWindowsReminder(visibleReminderEntries),
            ),
          ),
        Expanded(child: content),
      ],
    );
  }

  bool get _shouldShowSetupGuidance {
    if (!_setupReadinessLoaded || _setupGuidanceDismissed) return false;
    if (!widget.session.jeAdmin) return false;
    return _setupReadiness.isMissing(SetupReadinessItem.recoverySecurityCode);
  }

  Widget _buildListView(
    List<PredmetiData> lista,
    int ukupno,
    Set<int> unresolvedStockPredmetIds,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Prikazano ${lista.length} od $ukupno',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                return KeyEventResult.ignored;
              }
              if (!_scrollCtrl.hasClients) return KeyEventResult.ignored;
              final pos = _scrollCtrl.position;
              double? target;
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                target = (_scrollCtrl.offset + 80).clamp(0, pos.maxScrollExtent);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                target = (_scrollCtrl.offset - 80).clamp(0, pos.maxScrollExtent);
              } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
                target = (_scrollCtrl.offset + 500).clamp(0, pos.maxScrollExtent);
              } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
                target = (_scrollCtrl.offset - 500).clamp(0, pos.maxScrollExtent);
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
            child: ListView.separated(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              itemCount: lista.length,
              separatorBuilder: (context, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _PredmetListItem(
                predmet: lista[i],
                savetnikIme: _savetnici[lista[i].savetnikId] ?? '',
                hasUnresolvedStockConsequence:
                    unresolvedStockPredmetIds.contains(lista[i].id),
                onTap: () => _otvoriPredmet(lista[i]),
                onZatvori: () => _zatvoriPredmetSaListe(lista[i]),
                onOtvoriZaIzmenu: () => _otvoriZaIzmenuSaListe(lista[i]),
                onDokumenti: () => _otvoriDokumente(lista[i]),
                canAnonimizuj: lista[i].status == 'ZAVRŠEN',
                onAnonimizuj: () => _anonimizuj(lista[i]),
                onObrisi: () => _obrisi(lista[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _WindowsReminderBanner extends StatelessWidget {
  const _WindowsReminderBanner({
    required this.entries,
    required this.onClose,
  });

  final List<ReminderMvpEntry> entries;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: scheme.tertiaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.tertiary.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Podsetnik za približavanje ceremonije',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entries.length == 1
                            ? 'Postoji 1 aktivan podsetnik na listi predmeta.'
                            : 'Postoje ${entries.length} aktivna podsetnika na listi predmeta.',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Zatvori za ovu sesiju',
                  icon: Icon(
                    Icons.close,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final entry in entries) ...[
              _WindowsReminderLine(entry: entry),
              if (entry != entries.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _WindowsReminderLine extends StatelessWidget {
  const _WindowsReminderLine({required this.entry});

  final ReminderMvpEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final headline = entry.prikazImena.isNotEmpty
        ? entry.prikazImena
        : 'Predmet ${entry.brojPredmeta}';
    final details = <String>[
      'Broj ${entry.brojPredmeta}',
      entry.datumCeremonije,
      if (entry.vremeCeremonije.isNotEmpty) entry.vremeCeremonije,
    ].join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              entry.windowsLeadLabel,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.tertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PredmetStockWarningCardStyle {
  const PredmetStockWarningCardStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color iconColor;
}

PredmetStockWarningCardStyle resolvePredmetStockWarningCardStyle(
  ColorScheme scheme,
  Brightness brightness,
) {
  final isDark = brightness == Brightness.dark;
  final overlay = scheme.error.withValues(alpha: isDark ? 0.08 : 0.05);
  final base = isDark ? scheme.surfaceContainerHigh : scheme.surface;

  return PredmetStockWarningCardStyle(
    backgroundColor: Color.alphaBlend(overlay, base),
    borderColor: scheme.error.withValues(alpha: isDark ? 0.58 : 0.42),
    primaryTextColor: scheme.onSurface,
    secondaryTextColor: scheme.onSurfaceVariant,
    iconColor: scheme.onSurfaceVariant,
  );
}

class _PredmetListItem extends StatelessWidget {
  const _PredmetListItem({
    required this.predmet,
    required this.savetnikIme,
    required this.hasUnresolvedStockConsequence,
    required this.onTap,
    required this.onZatvori,
    required this.onOtvoriZaIzmenu,
    required this.onDokumenti,
    required this.canAnonimizuj,
    required this.onAnonimizuj,
    required this.onObrisi,
  });

  final PredmetiData predmet;
  final String savetnikIme;
  final bool hasUnresolvedStockConsequence;
  final VoidCallback? onTap;
  final VoidCallback onZatvori;
  final VoidCallback onOtvoriZaIzmenu;
  final VoidCallback onDokumenti;
  final bool canAnonimizuj;
  final VoidCallback onAnonimizuj;
  final VoidCallback onObrisi;

  String _formatDatumKreiranja(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final anonimizovan = predmet.status == 'ANONIMIZOVAN';
    final zavrsen = predmet.status == 'ZAVR\u0160EN' || anonimizovan;
    final prezime = predmet.prezime.trim().toLowerCase() == 'redacted'
        ? ''
        : predmet.prezime;
    final ime = predmet.ime.trim().toLowerCase() == 'redacted'
        ? ''
        : predmet.ime;
    final imePrezime = '$prezime $ime'.trim();
    final prikazIme = imePrezime.isNotEmpty ? imePrezime : '(bez imena)';
    final inicijal = prezime.isNotEmpty
        ? prezime[0]
        : (ime.isNotEmpty ? ime[0] : '?');
    final imaCeremoniju = predmet.datumCeremonije.isNotEmpty;
    final showStockWarning =
        hasUnresolvedStockConsequence && predmet.status == 'OTVOREN';
    final stockWarningStyle = showStockWarning
        ? resolvePredmetStockWarningCardStyle(scheme, theme.brightness)
        : null;

    final datumVreme = [
      if (predmet.datumCeremonije.isNotEmpty) predmet.datumCeremonije,
      if (predmet.vremeCeremonije.isNotEmpty) predmet.vremeCeremonije,
    ].join('  -  ');
    final prikazDatuma = datumVreme.isNotEmpty
        ? datumVreme
        : 'Kreiran: ${_formatDatumKreiranja(predmet.datumKreiranja)}';
    final ceremonijaMeta = [
      if (predmet.vrstaCeremonije.isNotEmpty) predmet.vrstaCeremonije,
      if (predmet.groblje.isNotEmpty) predmet.groblje,
    ].join('  -  ');

    final cardColor = switch (predmet.status) {
      'OTVOREN' => const Color(0xFFFFF3E0),
      'ZATVOREN' => const Color(0xFFFFF8E1),
      'ZAVR\u0160EN' => const Color(0xFFF1F8E9),
      _ => Colors.grey.shade200,
    };
    final primaryTextColor = stockWarningStyle?.primaryTextColor ??
        (isDarkTheme ? const Color(0xFF1F1F1F) : null);
    final mutedPrimaryTextColor = isDarkTheme
        ? stockWarningStyle?.secondaryTextColor ?? const Color(0xFF3F3F46)
        : scheme.onSurfaceVariant;
    final secondaryTextColor = isDarkTheme
        ? stockWarningStyle?.secondaryTextColor ?? const Color(0xFF52525B)
        : scheme.onSurfaceVariant;
    final avatarTextColor = zavrsen
        ? (isDarkTheme ? const Color(0xFF52525B) : Colors.grey)
        : scheme.onPrimaryContainer;
    final sekundarni = theme.textTheme.bodySmall?.copyWith(
          fontSize: 13,
          color: secondaryTextColor,
        );

    return Card(
      color: stockWarningStyle?.backgroundColor ?? cardColor,
      shape: showStockWarning
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: stockWarningStyle!.borderColor,
                width: 1.2,
              ),
            )
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: zavrsen
                              ? Colors.grey.shade300
                              : scheme.primaryContainer,
                          child: Text(
                            inicijal,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: avatarTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _StatusBadge(status: predmet.status),
                                  if (showStockWarning)
                                    const _StockWarningBadge(),
                                  if (imaCeremoniju)
                                    _TerminBadge(datum: predmet.datumCeremonije),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                prikazIme,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  height: 1.15,
                                  color: zavrsen
                                      ? mutedPrimaryTextColor
                                      : primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Broj predmeta: ${predmet.brojPredmeta}',
                                style: sekundarni?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TileActions(
                          status: predmet.status,
                          canAnonimizuj: canAnonimizuj,
                          onZatvori: onZatvori,
                          onOtvoriZaIzmenu: onOtvoriZaIzmenu,
                          onDokumenti: onDokumenti,
                          onAnonimizuj: onAnonimizuj,
                          onObrisi: onObrisi,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.event_outlined,
                      text: prikazDatuma,
                      style: sekundarni,
                    ),
                    if (ceremonijaMeta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: ceremonijaMeta,
                        style: sekundarni,
                      ),
                    ],
                    if (savetnikIme.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.person_outline,
                        text: 'Savetnik: $savetnikIme',
                        style: sekundarni,
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: zavrsen
                        ? Colors.grey.shade300
                        : scheme.primaryContainer,
                    child: Text(
                      inicijal,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: avatarTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prikazIme,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: zavrsen
                                      ? mutedPrimaryTextColor
                                      : primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Broj predmeta: ${predmet.brojPredmeta}',
                                style: sekundarni,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prikazDatuma, style: sekundarni),
                              if (ceremonijaMeta.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(ceremonijaMeta, style: sekundarni),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 150),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  _StatusBadge(status: predmet.status),
                                  if (showStockWarning)
                                    const _StockWarningBadge(),
                                  if (imaCeremoniju)
                                    _TerminBadge(datum: predmet.datumCeremonije),
                                ],
                              ),
                              if (savetnikIme.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Savetnik: $savetnikIme',
                                  style: sekundarni,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                              const SizedBox(height: 8),
                              _TileActions(
                                status: predmet.status,
                                canAnonimizuj: canAnonimizuj,
                                onZatvori: onZatvori,
                                onOtvoriZaIzmenu: onOtvoriZaIzmenu,
                                onDokumenti: onDokumenti,
                                onAnonimizuj: onAnonimizuj,
                                onObrisi: onObrisi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SetupReadinessBanner extends StatelessWidget {
  const _SetupReadinessBanner({
    required this.onOpenSetup,
    required this.onDismiss,
  });

  final VoidCallback onOpenSetup;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;
            final header = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security_outlined,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Podesite oporavak pristupa',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Aplikacija radi, ali podesite sigurnosni kod pre realnog rada.',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sakrij',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                ),
              ],
            );
            final action = FilledButton.icon(
              onPressed: onOpenSetup,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('OTVORI KORISNIKE'),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 12),
                  action,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: header),
                const SizedBox(width: 16),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkTheme
        ? style?.color ?? const Color(0xFF52525B)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 15,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _TileActions extends StatelessWidget {
  const _TileActions({
    required this.status,
    required this.canAnonimizuj,
    required this.onZatvori,
    required this.onOtvoriZaIzmenu,
    required this.onDokumenti,
    required this.onAnonimizuj,
    required this.onObrisi,
  });

  final String status;
  final bool canAnonimizuj;
  final VoidCallback onZatvori;
  final VoidCallback onOtvoriZaIzmenu;
  final VoidCallback onDokumenti;
  final VoidCallback onAnonimizuj;
  final VoidCallback onObrisi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final triggerFill = isDarkTheme
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.95)
        : scheme.surface.withValues(alpha: 0.9);
    final triggerBorder = isDarkTheme
        ? scheme.outline.withValues(alpha: 0.7)
        : scheme.outlineVariant.withValues(alpha: 0.85);
    final triggerIconColor = isDarkTheme
        ? scheme.onSurface
        : scheme.onSurfaceVariant;

    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: triggerFill,
          shape: BoxShape.circle,
          border: Border.all(color: triggerBorder),
        ),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 20,
            color: triggerIconColor,
          ),
          tooltip: 'Više opcija',
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onSelected: (v) {
            if (v == 'close') onZatvori();
            if (v == 'edit') onOtvoriZaIzmenu();
            if (v == 'docs') onDokumenti();
            if (v == 'anon') onAnonimizuj();
            if (v == 'delete') onObrisi();
          },
          itemBuilder: (_) {
            final zavrsen = status == 'ZAVR\u0160EN';
            return [
              if (status == 'OTVOREN')
                const PopupMenuItem(
                  value: 'close',
                  child: ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Zatvori predmet'),
                    dense: true,
                  ),
                ),
              if (status == 'ZATVOREN')
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Otvori za izmenu'),
                    dense: true,
                  ),
                ),
              const PopupMenuItem(
                value: 'docs',
                child: ListTile(
                  leading: Icon(Icons.folder_outlined),
                  title: Text('Dokumenti'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                enabled: false,
                child: ListTile(
                  leading: Icon(Icons.notifications_none_outlined),
                  title: Text('Podsetnik'),
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: 'anon',
                enabled: zavrsen && canAnonimizuj,
                child: const ListTile(
                  leading: Icon(Icons.person_remove_outlined),
                  title: Text('GDPR anonimizacija'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Obri\u0161i trajno',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  dense: true,
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

}

class _TerminBadge extends StatelessWidget {
  const _TerminBadge({required this.datum});

  final String datum;

  DateTime? _parse() => parseDateValue(datum);

  @override
  Widget build(BuildContext context) {
    final dt = _parse();
    if (dt == null) return const SizedBox.shrink();

    final danas = DateTime.now();
    final danasDate = DateTime(danas.year, danas.month, danas.day);
    final razlika = dt.difference(danasDate).inDays;

    final Color color;
    final String label;

    if (razlika < 0) {
      color = Colors.grey;
      label = 'PRE ${-razlika}d';
    } else if (razlika == 0) {
      color = Colors.red;
      label = 'DANAS';
    } else if (razlika == 1) {
      color = Colors.orange;
      label = 'SUTRA';
    } else if (razlika <= 7) {
      color = Colors.orange.shade700;
      label = 'ZA ${razlika}d';
    } else {
      color = Colors.teal;
      label = 'ZA ${razlika}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StockWarningBadge extends StatelessWidget {
  const _StockWarningBadge();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Text(
        'NIJE NA STANJU',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (status == 'ANONIMIZOVAN') {
      color = Colors.deepPurple;
    } else if (status == 'ZATVOREN') {
      color = Colors.orange.shade700;
    } else if (status == 'ZAVR\u0160EN') {
      color = Colors.grey;
    } else {
      color = Colors.teal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c : Theme.of(context).colorScheme.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected
                ? c
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}


