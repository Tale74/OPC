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
import '../parte/presentation/parte_module_screen.dart';

/// One operational catalog reached from the PREDMET overview.
///
/// Package/licence state is deliberately absent from this UI. Individual
/// modules still enforce their role and business prerequisites.
class ModuliScreen extends StatelessWidget {
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
    final stockAvailability = StanjeRobeOperationalAvailability(
      podesavanjaRepository: podesavanjaRepository,
      entitlementPolicy: entitlementPolicy,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('MODULI')),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _ModuleCard(
                  icon: Icons.notifications_outlined,
                  title: 'PODSETNIK',
                  subtitle: 'Rokovi i podsetnici povezani sa PREDMETIMA.',
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PodsetnikModuleScreen(
                        predmetiRepository: predmetiRepository,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                StreamBuilder<StanjeRobeOperationalStatus>(
                  stream: stockAvailability.watchStatus(),
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
                            if (session.jeAdmin) ...[
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('STANJE ROBE aktivno'),
                                subtitle: const Text(
                                  'Isključivanje ne briše postojeće podatke.',
                                ),
                                value: active,
                                onChanged: (value) => podesavanjaRepository
                                    .setStanjeRobeOperativnoOmoguceno(value),
                              ),
                              FilledButton.icon(
                                onPressed: active
                                    ? () => Navigator.push<void>(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (_) => StanjeRobeAdminScreen(
                                            session: session,
                                            podesavanjaRepository:
                                                podesavanjaRepository,
                                            stanjeRobeRepository:
                                                StanjeRobeRepository(
                                                  predmetiRepository.db,
                                                ),
                                            poslediceRepository:
                                                StanjeRobePoslediceRepository(
                                                  predmetiRepository.db,
                                                ),
                                            entitlementPolicy:
                                                entitlementPolicy,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
