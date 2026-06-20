import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_lane_diagnostics.dart';
import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../core/entitlements/opc_license_public_key_registry.dart';
import '../../../core/entitlements/opc_local_license_bootstrap_service.dart';
import '../../../core/installation/opc_installation_id_repository.dart';
import '../../../core/format/app_format.dart';
import '../../../core/utils/json_export_import.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/auth_security_repository.dart';
import '../../auth/domain/session_service.dart';
import '../../auth/presentation/korisnici_screen.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../stanje_robe/data/stanje_robe_posledice_repository.dart';
import '../../stanje_robe/data/stanje_robe_repository.dart';
import '../../stanje_robe/presentation/stanje_robe_admin_screen.dart';
import '../data/podesavanja_repository.dart';
import '../domain/nbs_ips_qr_payload_builder.dart';
import 'katalog_tab.dart';

class PodesavanjaScreen extends StatefulWidget {
  const PodesavanjaScreen({
    super.key,
    required this.repo,
    required this.authRepo,
    required this.session,
    this.prikaziOnboarding = false,
    this.initialSection,
    this.entitlementPolicy = const OpcEntitlementPolicy.current(),
  });

  final PodesavanjaRepository repo;
  final AuthRepository authRepo;
  final SessionService session;
  final bool prikaziOnboarding;
  final OpcSettingsSection? initialSection;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  State<PodesavanjaScreen> createState() => _PodesavanjaScreenState();
}

class _PodesavanjaScreenState extends State<PodesavanjaScreen> {
  bool _firmaIsDirty = false;
  bool _refIsDirty = false;
  bool _uputstvoIsDirty = false;
  bool get _isDirty => _firmaIsDirty || _refIsDirty || _uputstvoIsDirty;

  final _firmaKey = GlobalKey<_FirmaTabState>();
  final _refKey = GlobalKey<_RefundacijaTabState>();
  final _uputstvoKey = GlobalKey<_UputstvoZaPlacanjeTabState>();

  ThemeData _bodyTabTheme(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return theme.copyWith(
      tabBarTheme: theme.tabBarTheme.copyWith(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant.withValues(alpha: 0.5),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<void> _izveziBazu() async {
    await izvoziBackup(ctx: context, db: widget.repo.db);
  }

  Future<void> _uvoziBazu() async {
    await uvoziIzFajla(ctx: context, db: widget.repo.db);
  }

  Future<String?> _prikaziDijalog() {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nesačuvane promene'),
        content: const Text(
          'Postoje nesačuvane promene. '
          'Da li želite da sačuvate pre izlaska?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'ostani'),
            child: const Text('OSTANI'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'izadji'),
            child: const Text('IZAĐI BEZ ČUVANJA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'sacuvaj'),
            child: const Text('SAČUVAJ I IZAĐI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = OpcEntitlementPolicy.currentSettingsSections
        .where(widget.entitlementPolicy.isSettingsSectionVisible)
        .toList(growable: false);
    final requestedInitialIndex = widget.initialSection == null
        ? -1
        : visibleSections.indexOf(widget.initialSection!);
    final initialIndex =
        requestedInitialIndex >= 0 ? requestedInitialIndex : 0;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final action = await _prikaziDijalog();
        if (!mounted) return;
        if (action == 'sacuvaj') {
          await _firmaKey.currentState?._sacuvaj();
          await _refKey.currentState?._sacuvaj();
          await _uputstvoKey.currentState?._sacuvaj();
        }
        if (action == 'sacuvaj' || action == 'izadji') {
          setState(() {
            _firmaIsDirty = false;
            _refIsDirty = false;
            _uputstvoIsDirty = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: DefaultTabController(
        length: visibleSections.length,
        initialIndex: initialIndex,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'PODEŠAVANJA',
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_alt_outlined),
                tooltip: 'Izvoz baze',
                onPressed: _izveziBazu,
              ),
              IconButton(
                icon: const Icon(Icons.restore_outlined),
                tooltip: 'Uvoz JSON',
                onPressed: _uvoziBazu,
              ),
            ],
          ),
          body: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Theme(
                  data: _bodyTabTheme(context),
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: visibleSections.map(_buildTabForSection).toList(),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: visibleSections
                      .map((section) => _buildTabViewForSection(section))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Tab _buildTabForSection(OpcSettingsSection section) {
    return switch (section) {
      OpcSettingsSection.podaciFirme => const Tab(text: 'PODACI FIRME'),
      OpcSettingsSection.refundacijaPio =>
        const Tab(text: 'REFUNDACIJA PIO'),
      OpcSettingsSection.katalog => const Tab(text: 'KATALOG'),
      OpcSettingsSection.moduli => const Tab(text: 'MODULI'),
      OpcSettingsSection.korisnici => const Tab(text: 'KORISNICI'),
      OpcSettingsSection.uputstvoZaPlacanje =>
        const Tab(text: 'UPUTSTVO ZA PLAĆANJE'),
      OpcSettingsSection.oAplikaciji => const Tab(text: 'O APLIKACIJI'),
    };
  }

  Widget _buildTabViewForSection(OpcSettingsSection section) {
    return switch (section) {
      OpcSettingsSection.podaciFirme => _FirmaTab(
          key: _firmaKey,
          repo: widget.repo,
          prikaziOnboarding: widget.prikaziOnboarding,
          onDirtyChanged: (v) => setState(() => _firmaIsDirty = v),
        ),
      OpcSettingsSection.refundacijaPio => _RefundacijaTab(
          key: _refKey,
          repo: widget.repo,
          onDirtyChanged: (v) => setState(() => _refIsDirty = v),
        ),
      OpcSettingsSection.katalog => KatalogTab(repo: widget.repo),
      OpcSettingsSection.moduli => _ModuliTab(
          repo: widget.repo,
          session: widget.session,
          entitlementPolicy: widget.entitlementPolicy,
        ),
      OpcSettingsSection.korisnici => _KorisniciSecurityTab(
          db: widget.repo.db,
          authRepo: widget.authRepo,
          session: widget.session,
        ),
      OpcSettingsSection.uputstvoZaPlacanje => _UputstvoZaPlacanjeTab(
          key: _uputstvoKey,
          repo: widget.repo,
          onDirtyChanged: (v) => setState(() => _uputstvoIsDirty = v),
        ),
      OpcSettingsSection.oAplikaciji => _OAplikacijiTab(
          session: widget.session,
          entitlementPolicy: widget.entitlementPolicy,
        ),
    };
  }
}

// ── Tab 1: Podaci firme ───────────────────────────────────────────────────────

class _KorisniciSecurityTab extends StatelessWidget {
  const _KorisniciSecurityTab({
    required this.db,
    required this.authRepo,
    required this.session,
  });

  final AppDatabase db;
  final AuthRepository authRepo;
  final SessionService session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (session.jeAdmin)
          _RecoveryMaterialCard(
            securityRepo: AuthSecurityRepository(db),
            session: session,
          ),
        Expanded(
          child: KorisniciScreen(
            authRepo: authRepo,
            session: session,
            embedded: true,
          ),
        ),
      ],
    );
  }
}

class _ModuliTab extends StatelessWidget {
  const _ModuliTab({
    required this.repo,
    required this.session,
    required this.entitlementPolicy,
  });

  final PodesavanjaRepository repo;
  final SessionService session;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  Widget build(BuildContext context) {
    final availability = StanjeRobeOperationalAvailability(
      podesavanjaRepository: repo,
      entitlementPolicy: entitlementPolicy,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: StreamBuilder<StanjeRobeOperationalStatus>(
            stream: availability.watchStatus(),
            builder: (context, snap) {
              final status = snap.data ?? StanjeRobeOperationalStatus.notLicensed;
              final enabled = status == StanjeRobeOperationalStatus.active;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STANJE ROBE',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _StanjeRobeStatusBanner(status: status),
                      const SizedBox(height: 12),
                      if (!session.jeAdmin)
                        const Text(
                          'Samo ADMINISTRATOR može da uključi ili isključi ovaj modul.',
                        )
                      else if (status == StanjeRobeOperationalStatus.notLicensed)
                        const Text(
                          'Podešavanje nije dostupno jer trenutni paket/licenca ne dozvoljava STANJE ROBE.',
                        )
                      else
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('STANJE ROBE aktivno'),
                          subtitle: const Text(
                            'Isključivanje ne briše zalihe, primenjene efekte niti nerazrešene posledice.',
                          ),
                          value: enabled,
                          onChanged: (value) => repo
                              .setStanjeRobeOperativnoOmoguceno(value),
                        ),
                      if (session.jeAdmin &&
                          status != StanjeRobeOperationalStatus.notLicensed)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FilledButton.icon(
                            onPressed: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => StanjeRobeAdminScreen(
                                  session: session,
                                  podesavanjaRepository: repo,
                                  stanjeRobeRepository:
                                      StanjeRobeRepository(repo.db),
                                  poslediceRepository:
                                      StanjeRobePoslediceRepository(repo.db),
                                  entitlementPolicy: entitlementPolicy,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Upravljaj stanjem robe'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StanjeRobeStatusBanner extends StatelessWidget {
  const _StanjeRobeStatusBanner({required this.status});

  final StanjeRobeOperationalStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _stanjeRobeStatusColor(status, scheme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_stanjeRobeStatusIcon(status), color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _stanjeRobeStatusText(status),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _stanjeRobeStatusText(StanjeRobeOperationalStatus status) {
  return switch (status) {
    StanjeRobeOperationalStatus.notLicensed =>
      'Status: nije dostupno. Trenutni paket/licenca ne dozvoljava STANJE ROBE.',
    StanjeRobeOperationalStatus.disabled =>
      'Status: licencirano, ali operativno isključeno u podešavanjima.',
    StanjeRobeOperationalStatus.active =>
      'Status: licencirano i operativno aktivno.',
  };
}

IconData _stanjeRobeStatusIcon(StanjeRobeOperationalStatus status) {
  return switch (status) {
    StanjeRobeOperationalStatus.notLicensed => Icons.lock_outline,
    StanjeRobeOperationalStatus.disabled => Icons.pause_circle_outline,
    StanjeRobeOperationalStatus.active => Icons.check_circle_outline,
  };
}

Color _stanjeRobeStatusColor(
  StanjeRobeOperationalStatus status,
  ColorScheme scheme,
) {
  return switch (status) {
    StanjeRobeOperationalStatus.notLicensed => scheme.error,
    StanjeRobeOperationalStatus.disabled => scheme.tertiary,
    StanjeRobeOperationalStatus.active => scheme.primary,
  };
}

class _RecoveryMaterialCard extends StatefulWidget {
  const _RecoveryMaterialCard({
    required this.securityRepo,
    required this.session,
  });

  final AuthSecurityRepository securityRepo;
  final SessionService session;

  @override
  State<_RecoveryMaterialCard> createState() => _RecoveryMaterialCardState();
}

class _RecoveryMaterialCardState extends State<_RecoveryMaterialCard> {
  late Future<RecoveryMaterialStatus> _statusFuture;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _statusFuture = widget.securityRepo.getRecoveryMaterialStatus();
  }

  void _refreshStatus() {
    setState(() {
      _statusFuture = widget.securityRepo.getRecoveryMaterialStatus();
    });
  }

  Future<void> _createRecoveryMaterial() async {
    final adminId = widget.session.korisnik?.id;
    if (adminId == null || _creating) return;

    setState(() => _creating = true);
    try {
      final result = await widget.securityRepo.createInstallationRecoveryMaterial(
        actorType: 'USER',
        actorUserId: adminId,
        details: 'Initial setup from PODEŠAVANJA',
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Sigurnosni kod je uspešno podešen.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sačuvajte ovaj sigurnosni kod na bezbednom mestu. Biće prikazan samo jednom.',
              ),
              const SizedBox(height: 16),
              SelectableText(
                result.plaintext,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('U REDU'),
            ),
          ],
        ),
      );
      _refreshStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecoveryMaterialStatus>(
      future: _statusFuture,
      builder: (context, snap) {
        final status = snap.data;
        final missing = status == null || !status.exists;
        final configuredAt = status?.configuredAt.trim() ?? '';
        final configuredAtParsed = configuredAt.isEmpty
            ? null
            : DateTime.tryParse(configuredAt);
        final scheme = Theme.of(context).colorScheme;

        return Card(
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          color: missing
              ? scheme.errorContainer.withValues(alpha: 0.45)
              : scheme.primaryContainer.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      missing
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_outlined,
                      color: missing ? scheme.error : scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oporavak pristupa aplikaciji',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          if (snap.connectionState == ConnectionState.waiting)
                            const Text('Učitavanje statusa...')
                          else if (missing) ...[
                            const Text(
                              'Sigurnosni kod nije podešen.',
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Podesite ga da bi opcija Zaboravljen PIN mogla bezbedno da se koristi.',
                            ),
                          ] else ...[
                            const Text('Sigurnosni kod je podešen.'),
                            if (configuredAtParsed != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Datum podešavanja: ${formatDateUi(configuredAtParsed)}',
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (missing)
                  FilledButton.icon(
                    onPressed: _creating ? null : _createRecoveryMaterial,
                    icon: _creating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.security_outlined),
                    label: Text(
                      _creating
                          ? 'Kreiranje u toku...'
                          : 'Podesi sigurnosni kod',
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _refreshStatus,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Osveži status'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FirmaTab extends StatefulWidget {
  const _FirmaTab({
    super.key,
    required this.repo,
    this.prikaziOnboarding = false,
    this.onDirtyChanged,
  });

  final PodesavanjaRepository repo;
  final bool prikaziOnboarding;
  final ValueChanged<bool>? onDirtyChanged;

  @override
  State<_FirmaTab> createState() => _FirmaTabState();
}

class _FirmaTabState extends State<_FirmaTab> {
  bool _ucitava = true;
  bool _cuva = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nazivCtrl;
  late final TextEditingController _adresaCtrl;
  late final TextEditingController _pibCtrl;
  late final TextEditingController _mbCtrl;
  late final TextEditingController _sifraCtrl;
  late final TextEditingController _telefonCtrl;
  late final TextEditingController _odgovornoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _sajtCtrl;
  Uint8List? _logo;

  void _setDirty() {
    if (_ucitava) return;
    widget.onDirtyChanged?.call(true);
  }

  @override
  void initState() {
    super.initState();
    _nazivCtrl = TextEditingController();
    _adresaCtrl = TextEditingController();
    _pibCtrl = TextEditingController();
    _mbCtrl = TextEditingController();
    _sifraCtrl = TextEditingController();
    _telefonCtrl = TextEditingController();
    _odgovornoCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _sajtCtrl = TextEditingController();
    for (final c in [
      _nazivCtrl, _adresaCtrl, _pibCtrl, _mbCtrl, _sifraCtrl,
      _telefonCtrl, _odgovornoCtrl, _emailCtrl, _sajtCtrl,
    ]) {
      c.addListener(_setDirty);
    }
    _ucitaj();
  }

  @override
  void dispose() {
    _nazivCtrl.dispose();
    _adresaCtrl.dispose();
    _pibCtrl.dispose();
    _mbCtrl.dispose();
    _sifraCtrl.dispose();
    _telefonCtrl.dispose();
    _odgovornoCtrl.dispose();
    _emailCtrl.dispose();
    _sajtCtrl.dispose();
    super.dispose();
  }

  Future<void> _ucitaj() async {
    final firma = await widget.repo.getFirmaPodaci();
    if (!mounted) return;
    setState(() {
      _nazivCtrl.text = firma.naziv;
      _adresaCtrl.text = firma.adresa;
      _pibCtrl.text = firma.pib;
      _mbCtrl.text = firma.mb;
      _sifraCtrl.text = firma.sifraDelatnosti;
      _telefonCtrl.text = firma.telefon;
      _odgovornoCtrl.text = firma.odgovornoLice;
      _emailCtrl.text = firma.email;
      _sajtCtrl.text = firma.sajt;
      _logo = firma.logo;
      _ucitava = false;
    });
    if (widget.prikaziOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prikaziOnboardingDijalog();
      });
    }
  }

  void _prikaziOnboardingDijalog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Dobrodošli u OPC'),
        content: const SingleChildScrollView(
          child: Text(
            'Pre početka rada potrebno je podesiti:\n\n'
            '  1. Podaci firme — naziv, adresa, PIB, matični broj, telefon, logo\n'
            '  2. Uputstvo za plaćanje — tekući račun, naziv banke\n'
            '  3. Katalog — uneti artikle za kategorije: Sanduk, Obeležje,\n'
            '     Pokrov garnitura, Cveće, Komplet za opelo',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('RAZUMEM'),
          ),
        ],
      ),
    );
  }

  Future<void> _sacuvaj() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cuva = true);
    final nazivFirme = _nazivCtrl.text.trim();
    await widget.repo.saveFirmaPodaci(
      FirmaPodaciCompanion(
        naziv: Value(nazivFirme),
        adresa: Value(_adresaCtrl.text.trim()),
        pib: Value(_pibCtrl.text.trim()),
        mb: Value(_mbCtrl.text.trim()),
        sifraDelatnosti: Value(_sifraCtrl.text.trim()),
        telefon: Value(_telefonCtrl.text.trim()),
        odgovornoLice: Value(_odgovornoCtrl.text.trim()),
        email: Value(_emailCtrl.text.trim()),
        sajt: Value(_sajtCtrl.text.trim()),
        logo: Value(_logo),
      ),
    );
    await widget.repo.saveAppPodesavanja(
      AppPodesavanjaCompanion(
        qrPrimalacNaziv: Value(nazivFirme),
      ),
    );
    if (!mounted) return;
    setState(() => _cuva = false);
    widget.onDirtyChanged?.call(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Podaci firme sačuvani.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _odaberiLogo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    Uint8List? bytes = file.bytes;

    // Fallback za Windows desktop: bytes može biti null čak i sa withData:true
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes != null && bytes.isNotEmpty) {
      setState(() => _logo = bytes);
      _setDirty();
    }
  }

  void _ukloniLogo() {
    setState(() => _logo = null);
    _setDirty();
  }

  @override
  Widget build(BuildContext context) {
    if (_ucitava) {
      return const Center(child: CircularProgressIndicator());
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogoSekcija(context),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nazivCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'NAZIV FIRME',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adresaCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'ADRESA',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;

                    if (isNarrow) {
                      return Column(
                        children: [
                          TextFormField(
                            controller: _pibCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PIB',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mbCtrl,
                            decoration: const InputDecoration(
                              labelText: 'MB',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pibCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PIB',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _mbCtrl,
                            decoration: const InputDecoration(
                              labelText: 'MB',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sifraCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ŠIFRA DELATNOSTI',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'TELEFON',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odgovornoCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'ODGOVORNO LICE',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-MAIL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sajtCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'SAJT',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _cuva ? null : _sacuvaj,
                  child: _cuva
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAČUVAJ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSekcija(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;
            final preview = Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _logo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(_logo!, fit: BoxFit.contain),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logo firme',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: const Text('ODABERI'),
                      onPressed: _odaberiLogo,
                    ),
                    if (_logo != null)
                      TextButton(
                        onPressed: _ukloniLogo,
                        child: const Text('UKLONI'),
                      ),
                  ],
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  preview,
                  const SizedBox(height: 16),
                  details,
                ],
              );
            }

            return Row(
              children: [
                preview,
                const SizedBox(width: 16),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Tab 2: Refundacija PIO ────────────────────────────────────────────────────

class _RefundacijaTab extends StatefulWidget {
  const _RefundacijaTab({super.key, required this.repo, this.onDirtyChanged});

  final PodesavanjaRepository repo;
  final ValueChanged<bool>? onDirtyChanged;

  @override
  State<_RefundacijaTab> createState() => _RefundacijaTabState();
}

class _RefundacijaTabState extends State<_RefundacijaTab> {
  bool _ucitava = true;
  bool _cuva = false;

  late final TextEditingController _refundacijaCtrl;

  void _setDirty() {
    if (_ucitava) return;
    widget.onDirtyChanged?.call(true);
  }

  @override
  void initState() {
    super.initState();
    _refundacijaCtrl = TextEditingController();
    _refundacijaCtrl.addListener(_setDirty);
    _ucitaj();
  }

  @override
  void dispose() {
    _refundacijaCtrl.dispose();
    super.dispose();
  }

  Future<void> _ucitaj() async {
    final data = await widget.repo.getAppPodesavanja();
    if (!mounted) return;
    setState(() {
      _refundacijaCtrl.text = data.refundacijaPioIznos > 0
          ? formatBroj(data.refundacijaPioIznos)
          : '';
      _ucitava = false;
    });
  }

  Future<void> _sacuvaj() async {
    setState(() => _cuva = true);
    await widget.repo.saveAppPodesavanja(
      AppPodesavanjaCompanion(
        refundacijaPioIznos: Value(parsirajBroj(_refundacijaCtrl.text)),
      ),
    );
    if (!mounted) return;
    setState(() => _cuva = false);
    widget.onDirtyChanged?.call(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Iznos refundacije sačuvan.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ucitava) {
      return const Center(child: CircularProgressIndicator());
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _refundacijaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'IZNOS REFUNDACIJE PIO (RSD)',
                  hintText: '0,00',
                  suffixText: 'RSD',
                  border: OutlineInputBorder(),
                ),
                onEditingComplete: () {
                  final v = parsirajBroj(_refundacijaCtrl.text);
                  final f = v > 0 ? formatBroj(v) : '';
                  if (f != _refundacijaCtrl.text) {
                    _refundacijaCtrl.text = f;
                    _refundacijaCtrl.selection =
                        TextSelection.collapsed(offset: f.length);
                  }
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _cuva ? null : _sacuvaj,
                child: _cuva
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAČUVAJ'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pravo na refundaciju ostvaruje se pod sledećim uslovima:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const _InfoRed(
                      ikona: Icons.check_circle_outline,
                      tekst:
                          'Preminuli je penzioner Republike Srbije (PENZIONER R. SRBIJE = DA)',
                    ),
                    const SizedBox(height: 8),
                    const _InfoRed(
                      ikona: Icons.check_circle_outline,
                      tekst: 'Naručilac opreme i usluga je fizičko lice',
                    ),
                    const SizedBox(height: 8),
                    const _InfoRed(
                      ikona: Icons.check_circle_outline,
                      tekst:
                          'Platilac ne refundira samostalno (PLATILAC REFUNDIRA = NE)',
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Iznos refundacije oduzima se od ukupnog iznosa robe i usluga '
                      'pri obračunu u segmentu FINANSIJE.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
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
}

class _UputstvoZaPlacanjeTab extends StatefulWidget {
  const _UputstvoZaPlacanjeTab({
    super.key,
    required this.repo,
    this.onDirtyChanged,
  });

  final PodesavanjaRepository repo;
  final ValueChanged<bool>? onDirtyChanged;

  @override
  State<_UputstvoZaPlacanjeTab> createState() =>
      _UputstvoZaPlacanjeTabState();
}

class _UputstvoZaPlacanjeTabState extends State<_UputstvoZaPlacanjeTab> {
  bool _ucitava = true;
  bool _cuva = false;

  late final TextEditingController _ziroCtrl;
  late final TextEditingController _bankaCtrl;
  late final TextEditingController _qrNazivCtrl;
  late final TextEditingController _qrSifraCtrl;
  late final TextEditingController _qrSvrhaCtrl;

  void _setDirty() {
    if (_ucitava) return;
    widget.onDirtyChanged?.call(true);
  }

  @override
  void initState() {
    super.initState();
    _ziroCtrl = TextEditingController()..addListener(_setDirty);
    _bankaCtrl = TextEditingController()..addListener(_setDirty);
    _qrNazivCtrl = TextEditingController()..addListener(_setDirty);
    _qrSifraCtrl = TextEditingController()..addListener(_setDirty);
    _qrSvrhaCtrl = TextEditingController()..addListener(_setDirty);
    _ucitaj();
  }

  @override
  void dispose() {
    _ziroCtrl.dispose();
    _bankaCtrl.dispose();
    _qrNazivCtrl.dispose();
    _qrSifraCtrl.dispose();
    _qrSvrhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _ucitaj() async {
    final app = await widget.repo.getAppPodesavanja();
    final firma = await widget.repo.getFirmaPodaci();
    if (!mounted) return;
    setState(() {
      _ziroCtrl.text = app.ziroRacun;
      _bankaCtrl.text = app.nazivBanke;
      _qrNazivCtrl.text = firma.naziv.trim();
      _qrSifraCtrl.text = app.qrSifraPlacanja;
      _qrSvrhaCtrl.text = NbsIpsQrPayloadBuilder.obaveznaSvrhaPlacanja;
      _ucitava = false;
    });
  }

  Future<void> _sacuvaj() async {
    final nazivFirme = _qrNazivCtrl.text.trim();
    final config = AppPodesavanjaData(
      id: 1,
      ziroRacun: _ziroCtrl.text.trim(),
      nazivBanke: _bankaCtrl.text.trim(),
      qrPrimalacNaziv: nazivFirme,
      qrSifraPlacanja: _qrSifraCtrl.text.trim(),
      qrSvrhaPlacanja: NbsIpsQrPayloadBuilder.obaveznaSvrhaPlacanja,
      pozivNaBrojTip: NbsIpsQrPayloadBuilder.obavezniPozivNaBrojTip,
      refundacijaPioIznos: 0,
      stanjeRobeOperativnoOmoguceno: true,
    );
    final greska = NbsIpsQrPayloadBuilder.validateConfig(config);
    if (greska != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greska),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    setState(() => _cuva = true);
    await widget.repo.saveAppPodesavanja(
      AppPodesavanjaCompanion(
        ziroRacun: Value(_ziroCtrl.text.trim()),
        nazivBanke: Value(_bankaCtrl.text.trim()),
        qrPrimalacNaziv: Value(nazivFirme),
        qrSifraPlacanja: Value(_qrSifraCtrl.text.trim()),
        qrSvrhaPlacanja:
            const Value(NbsIpsQrPayloadBuilder.obaveznaSvrhaPlacanja),
        pozivNaBrojTip:
            const Value(NbsIpsQrPayloadBuilder.obavezniPozivNaBrojTip),
      ),
    );
    if (!mounted) return;
    setState(() => _cuva = false);
    widget.onDirtyChanged?.call(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uputstvo za plaćanje sačuvano.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ucitava) {
      return const Center(child: CircularProgressIndicator());
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Podaci sa ove strane koriste se za prikaz uputstva za plaćanje i za zaključani NBS IPS QR config model.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ziroCtrl,
                decoration: const InputDecoration(
                  labelText: 'TEKUĆI RAČUN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankaCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'NAZIV BANKE',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qrNazivCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'QR NAZIV PRIMAOCA',
                  helperText: 'Preuzima se iz PODACI FIRME',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qrSifraCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'QR ŠIFRA PLAĆANJA',
                  helperText: 'Obavezno 3 cifre, npr. 289',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qrSvrhaCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'QR SVRHA PLAĆANJA',
                  helperText: 'Zaključano: Transakcija po nalogu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'POZIV NA BROJ — TIP',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ime i prezime preminulog lica',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Za NBS IPS QR engine ovde se čuva samo config sloj. QR naziv primaoca se preuzima iz naziva firme, svrha plaćanja je zaključana na "Transakcija po nalogu", a poziv na broj koristi PREMINULO LICE. Dinamički ulaz dolazi kasnije iz konkretnog predmeta kao iznos za naplatu. RO se u ovom modelu za sada ne koristi.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _cuva ? null : _sacuvaj,
                child: _cuva
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAČUVAJ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 4: O aplikaciji ───────────────────────────────────────────────────────

class _OAplikacijiTab extends StatelessWidget {
  const _OAplikacijiTab({
    required this.session,
    required this.entitlementPolicy,
  });

  final SessionService session;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(Icons.business_center_outlined,
                        size: 64, color: colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('OPC',
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Organizator pogrebne ceremonije',
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => const _OAplikacijiDrugaStranaSheet(),
                      ),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('RAD U APLIKACIJI'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('DEVELOPER',
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              const _InfoRed(ikona: Icons.person_outline, tekst: 'Saša Andonov'),
              const SizedBox(height: 8),
              const _InfoRed(
                  ikona: Icons.email_outlined, tekst: 'sasa.andonov@gmail.com'),
              const SizedBox(height: 8),
              const _InfoRed(
                  ikona: Icons.location_on_outlined, tekst: 'Republika Srbija'),
              const SizedBox(height: 8),
              const _InfoRed(
                  ikona: Icons.code_outlined,
                  tekst: 'Flutter / Dart — Windows desktop'),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('LICENCA',
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Text(
                'Ova aplikacija je vlasništvo korisnika.\n'
                'Zabranjeno kopiranje, distribucija i modifikacija '
                'bez pisane saglasnosti developera.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('NAPOMENA',
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Text(
                'Aplikacija je u razvoju. Sve izmene i dopune se vrše '
                'po dogovoru sa korisnikom.\n\n'
                'Baza podataka se čuva lokalno na računaru korisnika.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (session.jeAdmin) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _LicenseActivationDiagnosticPanel(
                  entitlementPolicy: entitlementPolicy,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const _DatabaseLaneDiagnosticPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseActivationDiagnosticPanel extends StatefulWidget {
  const _LicenseActivationDiagnosticPanel({
    required this.entitlementPolicy,
  });

  final OpcEntitlementPolicy entitlementPolicy;

  @override
  State<_LicenseActivationDiagnosticPanel> createState() =>
      _LicenseActivationDiagnosticPanelState();
}

class _LicenseActivationDiagnosticPanelState
    extends State<_LicenseActivationDiagnosticPanel> {
  final _installationIdRepository = OpcInstallationIdRepository();
  final _bootstrapService = OpcLocalLicenseBootstrapService();
  late Future<_LicenseActivationDiagnostic> _diagnosticFuture;

  @override
  void initState() {
    super.initState();
    _diagnosticFuture = _readDiagnostic();
  }

  void _refresh() {
    setState(() {
      _diagnosticFuture = _readDiagnostic();
    });
  }

  Future<_LicenseActivationDiagnostic> _readDiagnostic() async {
    final installationId = await _readInstallationId();
    final bootstrapResult = await _readBootstrapResult();
    return _LicenseActivationDiagnostic(
      installationId: installationId,
      bootstrapResult: bootstrapResult,
      activeEntitlementDiagnostics: widget.entitlementPolicy.diagnostics,
      productionRegistryEmpty:
          OpcLicensePublicKeyRegistry.productionPublicKeysById.isEmpty,
    );
  }

  Future<String> _readInstallationId() async {
    try {
      return await _installationIdRepository
          .getOrCreateInstallationId()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return 'nije dostupno';
    }
  }

  Future<OpcLocalLicenseBootstrapResult> _readBootstrapResult() async {
    try {
      return await _bootstrapService
          .evaluateInstalledLicense()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return const OpcLocalLicenseBootstrapResult.invalid(
        safeReason: OpcLocalLicenseBootstrapSafeReason.readFailed,
      );
    }
  }

  Future<void> _copyInstallationId(String installationId) async {
    await Clipboard.setData(ClipboardData(text: installationId));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID instalacije je kopiran.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<_LicenseActivationDiagnostic>(
      future: _diagnosticFuture,
      builder: (context, snap) {
        final diagnostic = snap.data;
        final result = diagnostic?.bootstrapResult;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _licenseStatusIcon(result?.status),
                  color: _licenseStatusColor(
                    colorScheme,
                    result?.status,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LICENCA / AKTIVACIJA',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: snap.connectionState == ConnectionState.waiting
                      ? null
                      : _refresh,
                  tooltip: 'Osveži status licence',
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (snap.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator()
            else if (snap.hasError)
              Text(
                'Dijagnostika licence trenutno nije dostupna.',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              )
            else if (diagnostic != null && result != null) ...[
              _InfoRed(
                ikona: Icons.fingerprint_outlined,
                tekst: 'ID instalacije: ${diagnostic.installationId}',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _copyInstallationId(
                    diagnostic.installationId,
                  ),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Kopiraj ID instalacije'),
                ),
              ),
              const SizedBox(height: 12),
              _InfoRed(
                ikona: Icons.workspace_premium_outlined,
                tekst:
                    'Instalirana lokalna licenca - paket: '
                    '${_packageLabel(result.effectivePackage)}',
              ),
              const SizedBox(height: 8),
              _InfoRed(
                ikona: Icons.extension_outlined,
                tekst: _activeEntitlementMessage(
                  diagnostic.activeEntitlementDiagnostics,
                ),
              ),
              if (_activeModulesMessage(
                    diagnostic.activeEntitlementDiagnostics,
                  ) !=
                  null) ...[
                const SizedBox(height: 8),
                _InfoRed(
                  ikona: Icons.inventory_2_outlined,
                  tekst: _activeModulesMessage(
                    diagnostic.activeEntitlementDiagnostics,
                  )!,
                ),
              ],
              if (result.effectivePackage == OpcPackageLevel.osnovni &&
                  diagnostic.activeEntitlementDiagnostics.packageLevel !=
                      OpcPackageLevel.osnovni) ...[
                const SizedBox(height: 8),
                const _InfoRed(
                  ikona: Icons.info_outline,
                  tekst:
                      'Napomena: lokalna licenca i aktivni test/demo entitlement prikazuju se odvojeno.',
                ),
              ],
              const SizedBox(height: 8),
              _InfoRed(
                ikona: Icons.workspace_premium_outlined,
                tekst:
                    'Aktivni paket runtime-a: '
                    '${_packageLabel(diagnostic.activeEntitlementDiagnostics.packageLevel)}',
              ),
              const SizedBox(height: 8),
              _InfoRed(
                ikona: Icons.info_outline,
                tekst: _statusMessage(result),
              ),
              const SizedBox(height: 8),
              _InfoRed(
                ikona: Icons.rule_outlined,
                tekst: _reasonMessage(result),
              ),
              if (diagnostic.productionRegistryEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.secondaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    'Produkcioni javni ključ još nije dodat, pa produkciona '
                    'aktivacija još nije omogućena.',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _LicenseActivationDiagnostic {
  const _LicenseActivationDiagnostic({
    required this.installationId,
    required this.bootstrapResult,
    required this.activeEntitlementDiagnostics,
    required this.productionRegistryEmpty,
  });

  final String installationId;
  final OpcLocalLicenseBootstrapResult bootstrapResult;
  final OpcEntitlementDiagnostics activeEntitlementDiagnostics;
  final bool productionRegistryEmpty;
}

IconData _licenseStatusIcon(OpcLocalLicenseBootstrapStatus? status) {
  return switch (status) {
    OpcLocalLicenseBootstrapStatus.valid => Icons.verified_outlined,
    OpcLocalLicenseBootstrapStatus.invalid => Icons.warning_amber_rounded,
    OpcLocalLicenseBootstrapStatus.missing || null =>
      Icons.admin_panel_settings_outlined,
  };
}

Color _licenseStatusColor(
  ColorScheme colorScheme,
  OpcLocalLicenseBootstrapStatus? status,
) {
  return switch (status) {
    OpcLocalLicenseBootstrapStatus.valid => colorScheme.primary,
    OpcLocalLicenseBootstrapStatus.invalid => colorScheme.error,
    OpcLocalLicenseBootstrapStatus.missing || null => colorScheme.primary,
  };
}

String _statusMessage(OpcLocalLicenseBootstrapResult result) {
  return switch (result.status) {
    OpcLocalLicenseBootstrapStatus.missing =>
      'Licenca nije instalirana. Aplikacija radi u osnovnom režimu.',
    OpcLocalLicenseBootstrapStatus.invalid =>
      'Instalirana licenca nije važeća. Aplikacija radi u osnovnom režimu.',
    OpcLocalLicenseBootstrapStatus.valid => 'Licenca je tehnički važeća.',
  };
}

String _reasonMessage(OpcLocalLicenseBootstrapResult result) {
  return switch (result.safeReason) {
    OpcLocalLicenseBootstrapSafeReason.none =>
      'Dijagnostika licence ne prijavljuje grešku.',
    OpcLocalLicenseBootstrapSafeReason.noInstalledLicense =>
      'Nema instalirane lokalne licence.',
    OpcLocalLicenseBootstrapSafeReason.readFailed =>
      'Licencu trenutno nije moguće pročitati.',
    OpcLocalLicenseBootstrapSafeReason.parseOrVerificationFailed =>
      'Licenca nije prošla proveru formata ili potpisa.',
    OpcLocalLicenseBootstrapSafeReason.platformMismatch =>
      'Licenca nije izdata za ovu platformu.',
    OpcLocalLicenseBootstrapSafeReason.installationMismatch =>
      'Licenca nije izdata za ovu instalaciju.',
  };
}

String _activeEntitlementMessage(OpcEntitlementDiagnostics diagnostics) {
  return 'Aktivni entitlement runtime-a: '
      '${_entitlementSourceLabel(diagnostics.sourceKind)} / '
      '${_entitlementEnvironmentLabel(diagnostics.environment)}.';
}

String? _activeModulesMessage(OpcEntitlementDiagnostics diagnostics) {
  final modules = <String>[];
  if (diagnostics.packageLevel == OpcPackageLevel.potpun ||
      diagnostics.enabledAddOns.contains(OpcAddOn.stanjeRobe)) {
    modules.add('STANJE ROBE');
  }
  if (modules.isEmpty) return null;
  return 'Aktivni moduli/dodaci: ${modules.join(', ')}.';
}

String _entitlementSourceLabel(OpcEntitlementSourceKind sourceKind) {
  return switch (sourceKind) {
    OpcEntitlementSourceKind.localLicense => 'lokalna licenca',
    OpcEntitlementSourceKind.saas => 'SaaS',
    OpcEntitlementSourceKind.developerAllUnlocked => 'developer',
    OpcEntitlementSourceKind.demoTest => 'demo/test',
  };
}

String _entitlementEnvironmentLabel(OpcEntitlementEnvironment environment) {
  return switch (environment) {
    OpcEntitlementEnvironment.production => 'production',
    OpcEntitlementEnvironment.test => 'test',
    OpcEntitlementEnvironment.developer => 'developer',
  };
}

String _packageLabel(OpcPackageLevel packageLevel) {
  return switch (packageLevel) {
    OpcPackageLevel.osnovni => 'Osnovni',
    OpcPackageLevel.srednji => 'Srednji',
    OpcPackageLevel.potpun => 'Potpun',
  };
}

class _DatabaseLaneDiagnosticPanel extends StatefulWidget {
  const _DatabaseLaneDiagnosticPanel();

  @override
  State<_DatabaseLaneDiagnosticPanel> createState() =>
      _DatabaseLaneDiagnosticPanelState();
}

class _DatabaseLaneDiagnosticPanelState
    extends State<_DatabaseLaneDiagnosticPanel> {
  late Future<DatabaseLaneDiagnostic> _diagnosticFuture;

  @override
  void initState() {
    super.initState();
    _diagnosticFuture = DatabaseLaneDiagnostics.read();
  }

  void _refresh() {
    setState(() {
      _diagnosticFuture = DatabaseLaneDiagnostics.read();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<DatabaseLaneDiagnostic>(
      future: _diagnosticFuture,
      builder: (context, snap) {
        final diagnostic = snap.data;
        final alternateLanes = diagnostic?.existingAlternateLanes ??
            const <DatabaseLaneFileInfo>[];
        final hasAlternate = alternateLanes.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasAlternate
                      ? Icons.warning_amber_rounded
                      : Icons.storage_outlined,
                  color: hasAlternate ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'DIJAGNOSTIKA BAZE',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: snap.connectionState == ConnectionState.waiting
                      ? null
                      : _refresh,
                  tooltip: 'Osveži dijagnostiku baze',
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (snap.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator()
            else if (snap.hasError)
              Text(
                'Dijagnostika baze trenutno nije dostupna.',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              )
            else if (diagnostic != null) ...[
              _InfoRed(
                ikona: Icons.memory_outlined,
                tekst:
                    'BUILD_VARIANT: ${diagnostic.buildVariantLabel} (${diagnostic.buildVariant})',
              ),
              const SizedBox(height: 8),
              _InfoRed(
                ikona: Icons.radio_button_checked,
                tekst: 'Aktivna baza: ${diagnostic.activeDatabaseName}.sqlite',
              ),
              const SizedBox(height: 12),
              if (hasAlternate) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Pronađena je baza iz druge test/production lane varijante. '
                    'Aplikacija trenutno koristi aktivnu bazu '
                    '${diagnostic.activeDatabaseName}. Stara baza nije '
                    'automatski učitana, nije obrisana i nije migrirana.',
                    style: textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                ...alternateLanes.map(
                  (lane) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DatabaseLaneInfoRow(lane: lane),
                  ),
                ),
              ] else
                Text(
                  'Nisu pronađene baze iz drugih lane varijanti.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _DatabaseLaneInfoRow extends StatelessWidget {
  const _DatabaseLaneInfoRow({required this.lane});

  final DatabaseLaneFileInfo lane;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final sizeText = _formatFileSize(lane.sizeBytes);
    final modifiedText = _formatDateTime(lane.lastModified);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.sd_storage_outlined,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${lane.fileName} · $sizeText · izmenjeno: $modifiedText',
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

String _formatFileSize(int? bytes) {
  if (bytes == null) return 'nepoznata veličina';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(1)} GB';
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'nepoznato';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString().padLeft(4, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.$year. $hour:$minute';
}

class _OAplikacijiDrugaStranaSheet extends StatelessWidget {
  const _OAplikacijiDrugaStranaSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAD U APLIKACIJI',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kratak pregled namene, osnovnog toka rada i poslovnih pravila aplikacije OPC.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              const _AboutTextBlock(
                title: 'ŠTA JE OPC',
                body:
                    'OPC je radni alat za vođenje pogrebne ceremonije kroz jedan predmet kao centralno mesto unosa, pregleda i organizacije podataka. '
                    'Njegova namena nije samo čuvanje podataka, već svakodnevni operativni rad kroz konkretan predmet, od prijema informacija do završnih dokumenata.',
              ),
              const SizedBox(height: 20),
              const _AboutTextBlock(
                title: 'KAKO OPC RADI',
                body:
                    'U OPC-u se svi važni podaci vode kroz jedan predmet. '
                    'Podaci o preminulom licu, ceremoniji, robi, uslugama i finansijama objedinjeni su na jednom mestu, a potrebni dokumenti nastaju iz tog unosa. '
                    'Na taj način se smanjuje prepisivanje, olakšava provera podataka i održava doslednost tokom rada.',
              ),
              const SizedBox(height: 20),
              const _AboutTextBlock(
                title: 'SVAKODNEVNA OPERATIVNA KORIST',
                body:
                    'U svakodnevnom radu OPC pomaže da podaci budu pregledni i dostupni na jednom mestu. '
                    'Korisnik ne mora da vodi odvojene beleške za ono što je već uneseno, jer aplikacija objedinjuje radne informacije u jedinstven tok rada i olakšava snalaženje kroz predmet.',
              ),
              const SizedBox(height: 20),
              const _AboutTextBlock(
                title: 'DOKUMENTI IZ PREDMETA',
                body:
                    'Jedna od najvažnijih praktičnih koristi OPC-a je izrada dokumenata direktno iz podataka koji su već uneti u predmet. '
                    'Kada su podaci pravilno evidentirani, aplikacija iz njih formira potrebne PDF dokumente bez dodatnog ručnog prekucavanja. '
                    'Time se ubrzava rad, smanjuje mogućnost greške i olakšava arhiviranje.',
              ),
              const SizedBox(height: 20),
              const _AboutTextBlock(
                title: 'PODSETNIK I KONTROLA RADA',
                body:
                    'OPC ima i ulogu radnog podsetnika. Pregled predmeta pomaže korisniku da vidi šta je uneseno, šta je potvrđeno i šta još zahteva pažnju. '
                    'Tako aplikacija ne služi samo kao evidencija, već i kao pomoć u organizaciji rada i proveri potpunosti podataka.',
              ),
              const SizedBox(height: 20),
              const _AboutTextBlock(
                title: 'KRATKO KORISNIČKO UPUTSTVO',
                body:
                    'Rad u aplikaciji počinje otvaranjem ili izborom predmeta. '
                    'Podaci se unose u odgovarajuće segmente, a dokumenti se izrađuju iz već unetih podataka. '
                    'Zato je najvažnije da predmet bude uredno i tačno popunjen, jer se iz njega dobijaju i pregled i dokumenti potrebni za dalji rad.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutTextBlock extends StatelessWidget {
  const _AboutTextBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _InfoRed extends StatelessWidget {
  const _InfoRed({required this.ikona, required this.tekst});

  final IconData ikona;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikona,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(tekst, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
