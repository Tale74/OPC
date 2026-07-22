import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../auth/domain/session_service.dart';
import '../../data/predmeti_repository.dart';
import '../../presentation/predmet_screen.dart';
import '../application/parte_preparation_service.dart';
import '../data/parte_media_store.dart';
import '../data/parte_preparation_repository.dart';
import '../domain/parte_models.dart';
import 'parte_composer_screen.dart';

class ParteModuleScreen extends StatefulWidget {
  const ParteModuleScreen({
    super.key,
    required this.predmetiRepository,
    required this.actor,
    required this.entitlement,
    required this.session,
    this.onOpenIriuParte,
  });

  final PredmetiRepository predmetiRepository;
  final KorisniciData actor;
  final OpcEntitlementPolicy entitlement;
  final SessionService session;
  final Future<void> Function(int predmetId)? onOpenIriuParte;

  @override
  State<ParteModuleScreen> createState() => _ParteModuleScreenState();
}

class _ParteModuleScreenState extends State<ParteModuleScreen> {
  late final PartePreparationRepository _preparations;
  late final PartePreparationService _preparationService;
  late Future<List<_PartePredmetItem>> _items;
  final Set<int> _locallyDeletedPreparationIds = <int>{};

  @override
  void initState() {
    super.initState();
    _preparations = PartePreparationRepository(widget.predmetiRepository.db);
    _preparationService = PartePreparationService(
      repository: _preparations,
      mediaStore: ParteMediaStore(),
    );
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

  Future<void> _openIriuParte(_PartePredmetItem item) async {
    final override = widget.onOpenIriuParte;
    if (override != null) {
      await override(item.predmet.id);
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PredmetScreen(
          predmetId: item.predmet.id,
          predmetiRepo: widget.predmetiRepository,
          session: widget.session,
          entitlementPolicy: widget.entitlement,
          openIriuParte: true,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  Future<void> _deleteCompleted(_PartePredmetItem item) async {
    final preparation = item.preparation;
    if (preparation == null ||
        PartePreparationStatus.fromDb(preparation.status) !=
            PartePreparationStatus.completed) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Obriši sačuvanu PARTE pripremu'),
        content: Text(
          'Iz OPC-a će biti nepovratno obrisana sačuvana PARTE priprema za '
          '${item.displayName} (PREDMET ${item.predmet.brojPredmeta}) i njeni '
          'isključivo app-owned privremeni mediji.\n\n'
          'PREDMET i IRiU podaci neće biti obrisani. Ranije izvezeni PDF/DOCX '
          'fajlovi van OPC-a ostaju na svom mestu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OBRIŠI PRIPREMU'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _preparationService.deleteRetainedCompleted(
        preparation: preparation,
        actor: widget.actor,
        entitlement: widget.entitlement,
      );
      if (!mounted) return;
      setState(() {
        _locallyDeletedPreparationIds.add(preparation.id);
      });
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PARTE priprema je obrisana iz OPC-a.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Brisanje pripreme nije uspelo: $error')),
      );
    }
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: ValueKey('parte-open-iriu-${item.predmet.id}'),
                        tooltip: 'Otvori Posmrtne parte u Robi i uslugama',
                        onPressed: () => _openIriuParte(item),
                        icon: const Icon(Icons.inventory_2_outlined),
                      ),
                      if (item.isCompleted &&
                          !_locallyDeletedPreparationIds.contains(
                            item.preparation!.id,
                          ))
                        PopupMenuButton<_ParteItemAction>(
                          key: ValueKey(
                            'parte-preparation-menu-${item.predmet.id}',
                          ),
                          tooltip: 'Radnje za pripremu',
                          onSelected: (action) {
                            if (action == _ParteItemAction.deleteCompleted) {
                              _deleteCompleted(item);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: _ParteItemAction.deleteCompleted,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.delete_outline),
                                title: Text('OBRIŠI SAČUVANU PRIPREMU'),
                              ),
                            ),
                          ],
                        )
                      else
                        const Icon(Icons.chevron_right),
                    ],
                  ),
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
        'PDF je izvezen – završetak nije potvrđen',
      PartePreparationStatus.inProgress => 'Priprema je u toku',
      PartePreparationStatus.cleanupPending => 'Čišćenje je na čekanju',
      PartePreparationStatus.completed =>
        'Sačuvana završena priprema – OTVORI PRIPREMU',
    };
  }

  bool get isCompleted =>
      preparation != null &&
      PartePreparationStatus.fromDb(preparation!.status) ==
          PartePreparationStatus.completed;
}

enum _ParteItemAction { deleteCompleted }
