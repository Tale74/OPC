import 'package:flutter/material.dart';

import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../auth/domain/session_service.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../../podsetnik/presentation/podsetnik_module_screen.dart';
import '../../stanje_robe/application/stanje_robe_operational_availability.dart';
import '../../stanje_robe/data/stanje_robe_posledice_repository.dart';
import '../../stanje_robe/data/stanje_robe_repository.dart';
import '../../stanje_robe/presentation/stanje_robe_admin_screen.dart';
import '../data/predmeti_repository.dart';
import '../core_v2/scenario/scenario_module_screen.dart';
import '../parte/presentation/parte_module_screen.dart';
import '../citulje/presentation/citulje_module_screen.dart';

/// One operational catalog reached from the PREDMET overview.
///
/// Package/licence state is deliberately absent from this UI. Individual
/// modules still enforce their role and business prerequisites.
class ModuliScreen extends StatelessWidget {
  static const double _wideLayoutBreakpoint = 680;
  static const double _moduleGap = 12;

  const ModuliScreen({
    super.key,
    required this.predmetiRepository,
    required this.podesavanjaRepository,
    required this.session,
    required this.entitlementPolicy,
  });

  final PredmetiRepository predmetiRepository;
  final PodesavanjaRepository podesavanjaRepository;
  final SessionService session;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  Widget build(BuildContext context) {
    final actor = session.korisnik;
    return Scaffold(
      appBar: AppBar(title: const Text('MODULI')),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    constraints.maxWidth >= _wideLayoutBreakpoint;
                final itemWidth = wide
                    ? (constraints.maxWidth - _moduleGap) / 2
                    : constraints.maxWidth;
                final modules = <Widget>[
                  _ModuleCard(
                    key: const Key('moduli-scenario-card'),
                    icon: Icons.alt_route_outlined,
                    title: 'SCENARIO',
                    subtitle:
                        'Uslovi, osnovni paket i dodatne STAVKE za buduće PREDMETE.',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ScenarioModuleScreen(
                          podesavanjaRepository: podesavanjaRepository,
                        ),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    key: const Key('moduli-podsetnik-card'),
                    icon: Icons.notifications_outlined,
                    title: 'PODSETNIK',
                    subtitle: 'Rokovi i podsetnici povezani sa PREDMETIMA.',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PodsetnikModuleScreen(
                          predmetiRepository: predmetiRepository,
                          session: session,
                        ),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    key: const Key('moduli-parte-card'),
                    icon: Icons.article_outlined,
                    title: 'PARTE',
                    subtitle:
                        'Priprema, pregled i ponovni izvoz sačuvanih PARTI.',
                    enabled: actor != null,
                    onTap: actor == null
                        ? null
                        : () => Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ParteModuleScreen(
                                predmetiRepository: predmetiRepository,
                                actor: actor,
                                entitlement: entitlementPolicy,
                                session: session,
                              ),
                            ),
                          ),
                  ),
                  _ModuleCard(
                    key: const Key('moduli-citulje-card'),
                    icon: Icons.newspaper_outlined,
                    title: 'ČITULJE',
                    subtitle:
                        'Priprema ČITULJA POLITIKA i NOVOSTI za PREDMETE.',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CituljeModuleScreen(
                          predmetiRepository: predmetiRepository,
                        ),
                      ),
                    ),
                  ),
                  _StanjeRobeModuleCard(
                    key: const Key('moduli-stanje-robe-card'),
                    session: session,
                    podesavanjaRepository: podesavanjaRepository,
                    stanjeRobeRepository: StanjeRobeRepository(
                      predmetiRepository.db,
                    ),
                    poslediceRepository: StanjeRobePoslediceRepository(
                      predmetiRepository.db,
                    ),
                    entitlementPolicy: entitlementPolicy,
                  ),
                ];
                return Wrap(
                  spacing: wide ? _moduleGap : 0,
                  runSpacing: _moduleGap,
                  children: [
                    for (final module in modules)
                      SizedBox(width: itemWidth, child: module),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StanjeRobeModuleCard extends StatefulWidget {
  const _StanjeRobeModuleCard({
    super.key,
    required this.session,
    required this.podesavanjaRepository,
    required this.stanjeRobeRepository,
    required this.poslediceRepository,
    required this.entitlementPolicy,
  });

  final SessionService session;
  final PodesavanjaRepository podesavanjaRepository;
  final StanjeRobeRepository stanjeRobeRepository;
  final StanjeRobePoslediceRepository poslediceRepository;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  State<_StanjeRobeModuleCard> createState() => _StanjeRobeModuleCardState();
}

class _StanjeRobeModuleCardState extends State<_StanjeRobeModuleCard> {
  late final Stream<StanjeRobeOperationalStatus> _statusStream;

  @override
  void initState() {
    super.initState();
    _statusStream = StanjeRobeOperationalAvailability(
      podesavanjaRepository: widget.podesavanjaRepository,
      entitlementPolicy: widget.entitlementPolicy,
    ).watchStatus();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<
    StanjeRobeOperationalStatus
  >(
    stream: _statusStream,
    builder: (context, snapshot) {
      final status =
          snapshot.data ?? StanjeRobeOperationalStatus.disabled;
      final active = status == StanjeRobeOperationalStatus.active;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.inventory_2_outlined),
                title: Text('STANJE ROBE'),
                subtitle: Text(
                  'Operativno vođenje zaliha i posledica po PREDMETU.',
                ),
              ),
              Text(
                active
                    ? 'Status: operativno aktivno.'
                    : 'Status: operativno isključeno.',
              ),
              if (widget.session.jeAdmin) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('STANJE ROBE aktivno'),
                  subtitle: const Text(
                    'Isključivanje ne briše postojeće podatke.',
                  ),
                  value: active,
                  onChanged: (value) => widget.podesavanjaRepository
                      .setStanjeRobeOperativnoOmoguceno(value),
                ),
                FilledButton.icon(
                  onPressed: active
                      ? () => Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => StanjeRobeAdminScreen(
                              session: widget.session,
                              podesavanjaRepository:
                                  widget.podesavanjaRepository,
                              stanjeRobeRepository:
                                  widget.stanjeRobeRepository,
                              poslediceRepository: widget.poslediceRepository,
                              entitlementPolicy: widget.entitlementPolicy,
                            ),
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Upravljaj stanjem robe'),
                ),
              ] else
                const Text(
                  'Samo ADMINISTRATOR može da uključi ili isključi ovaj modul.',
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    ),
  );
}
