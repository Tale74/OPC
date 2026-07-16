import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../data/predmeti_repository.dart';
import '../data/parte_preparation_repository.dart';
import '../domain/parte_models.dart';
import 'parte_composer_screen.dart';

class ParteModuleScreen extends StatefulWidget {
  const ParteModuleScreen({
    super.key,
    required this.predmetiRepository,
    required this.actor,
    required this.entitlement,
  });

  final PredmetiRepository predmetiRepository;
  final KorisniciData actor;
  final OpcEntitlementPolicy entitlement;

  @override
  State<ParteModuleScreen> createState() => _ParteModuleScreenState();
}

class _ParteModuleScreenState extends State<ParteModuleScreen> {
  late final PartePreparationRepository _preparations;
  late Future<List<_PartePredmetItem>> _items;

  @override
  void initState() {
    super.initState();
    _preparations = PartePreparationRepository(widget.predmetiRepository.db);
    _items = _load();
  }

  Future<List<_PartePredmetItem>> _load() async {
    final predmeti = await widget.predmetiRepository.getSvePredmete();
    final items = <_PartePredmetItem>[];
    for (final predmet in predmeti) {
      final preparation = await _preparations.findForPredmet(predmet.id);
      final activeCandidate =
          predmet.status == 'OTVOREN' && predmet.partePotrebna;
      if (!activeCandidate && preparation == null) continue;
      items.add(_PartePredmetItem(predmet: predmet, preparation: preparation));
    }
    return items;
  }

  Future<void> _refresh() async {
    setState(() => _items = _load());
    await _items;
  }

  Future<void> _open(_PartePredmetItem item) async {
    final current = await widget.predmetiRepository.getPredmet(item.predmet.id);
    final retained = await _preparations.findForPredmet(current.id);
    if ((current.status != 'OTVOREN' || !current.partePotrebna) &&
        retained == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PREDMET više nije otvoren ili PARTE više nisu potrebne.',
          ),
        ),
      );
      await _refresh();
      return;
    }
    if (!mounted) return;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ParteComposerScreen(
          predmetId: current.id,
          predmetiRepository: widget.predmetiRepository,
          actor: widget.actor,
          entitlement: widget.entitlement,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MODUL PARTE'),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Osveži listu',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<_PartePredmetItem>>(
        future: _items,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nema otvorenih PREDMETA za koje su PARTE označene kao potrebne.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            key: const Key('parte-module-predmet-list'),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  key: ValueKey('parte-preparation-${item.predmet.id}'),
                  leading: const Icon(Icons.article_outlined),
                  title: Text(item.displayName),
                  subtitle: Text(
                    'Broj PREDMETA: ${item.predmet.brojPredmeta}\n'
                    '${item.statusLabel}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PartePredmetItem {
  const _PartePredmetItem({required this.predmet, required this.preparation});

  final PredmetiData predmet;
  final PartePripremeData? preparation;

  String get displayName {
    final name = '${predmet.ime} ${predmet.prezime}'.trim();
    return name.isEmpty ? 'PREDMET ${predmet.brojPredmeta}' : name;
  }

  String get statusLabel {
    final row = preparation;
    if (row == null) return 'Priprema nije započeta';
    return switch (PartePreparationStatus.fromDb(row.status)) {
      PartePreparationStatus.inProgress when row.exportedSuccessfully =>
        'PDF je izvezen — završetak nije potvrđen',
      PartePreparationStatus.inProgress => 'Priprema je u toku',
      PartePreparationStatus.cleanupPending => 'Čišćenje je na čekanju',
      PartePreparationStatus.completed =>
        'Sačuvana završena priprema — OTVORI PRIPREMU',
    };
  }
}
