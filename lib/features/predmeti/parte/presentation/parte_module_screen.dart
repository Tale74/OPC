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
    this.onOpenPredmetParte,
  });

  final PredmetiRepository predmetiRepository;
  final KorisniciData actor;
  final OpcEntitlementPolicy entitlement;
  final SessionService session;
  final Future<void> Function(PredmetScreen destination)? onOpenPredmetParte;

  @override
  State<ParteModuleScreen> createState() => _ParteModuleScreenState();
}

class _ParteModuleScreenState extends State<ParteModuleScreen> {
  late final PartePreparationRepository _preparations;
  late final PartePreparationService _preparationService;
  List<_PartePredmetItem> _items = const [];
  final Set<int> _locallyDeletedPreparationIds = <int>{};
  int? _selectedPredmetId;
  bool _loading = true;
  bool _openingPredmet = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _preparations = PartePreparationRepository(widget.predmetiRepository.db);
    _preparationService = PartePreparationService(
      repository: _preparations,
      mediaStore: ParteMediaStore(),
    );
    _refresh();
  }

  Future<void> _refresh() async {
    final generation = ++_loadGeneration;
    if (mounted) setState(() => _loading = true);
    final predmeti = await widget.predmetiRepository.getSvePredmete();
    final preparations = await _preparations.listAll();
    final preparationByPredmet = {
      for (final preparation in preparations) preparation.predmetId: preparation,
    };
    final items = <_PartePredmetItem>[];
    for (final predmet in predmeti) {
      final preparation = preparationByPredmet[predmet.id];
      final activeCandidate =
          predmet.status == 'OTVOREN' && predmet.partePotrebna;
      if (!activeCandidate && preparation == null) continue;
      items.add(_PartePredmetItem(predmet: predmet, preparation: preparation));
    }
    if (!mounted || generation != _loadGeneration) return;
    final selected = _selectedPredmetId;
    setState(() {
      _items = items;
      _selectedPredmetId = items.any((item) => item.predmet.id == selected)
          ? selected
          : null;
      _loading = false;
    });
  }

  Future<void> _selectPredmet(int? value) async {
    if (value == null || _openingPredmet || !mounted) return;
    final matching = _items.where((item) => item.predmet.id == value);
    if (matching.isEmpty) return;
    setState(() {
      _selectedPredmetId = value;
      _openingPredmet = true;
    });
    try {
      await _open(matching.single);
    } finally {
      if (mounted) setState(() => _openingPredmet = false);
    }
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

  Future<void> _openPredmetParte(_PartePredmetItem item) async {
    final destination = PredmetScreen(
      predmetId: item.predmet.id,
      predmetiRepo: widget.predmetiRepository,
      session: widget.session,
      entitlementPolicy: widget.entitlement,
      openParte: true,
    );
    final override = widget.onOpenPredmetParte;
    if (override != null) {
      await override(destination);
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => destination,
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const Key('parte-module-predmet-list'),
              padding: const EdgeInsets.all(24),
              children: [
                const Text('PARTE'),
                const SizedBox(height: 12),
                if (_items.isEmpty)
                  const Text(
                    'Nema otvorenih PREDMETA za koje su PARTE označene kao potrebne.',
                    textAlign: TextAlign.center,
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: const Key('parte-predmet-selector'),
                    initialValue: _selectedPredmetId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'PREDMET',
                      border: OutlineInputBorder(),
                    ),
                    items: _items
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.predmet.id,
                            child: Text(
                              '${item.displayName} · ${item.predmet.brojPredmeta}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _openingPredmet ? null : _selectPredmet,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPredmetId == null)
                    const Text('Izaberite PREDMET za pripremu PARTE.'),
                  if (_selectedPredmetId != null)
                    _buildSelectedPredmetActions(
                      context,
                      _items.firstWhere(
                        (item) => item.predmet.id == _selectedPredmetId,
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Widget _buildSelectedPredmetActions(
    BuildContext context,
    _PartePredmetItem item,
  ) {
    final canDelete =
        item.isCompleted &&
        !_locallyDeletedPreparationIds.contains(item.preparation!.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(item.statusLabel),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: ValueKey('parte-open-predmet-parte-${item.predmet.id}'),
              onPressed: () => _openPredmetParte(item),
              icon: const Icon(Icons.article_outlined),
              label: const Text('OTVORI SEGMENT PARTE U PREDMETU'),
            ),
            if (canDelete)
              PopupMenuButton<_ParteItemAction>(
                key: ValueKey('parte-preparation-menu-${item.predmet.id}'),
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
              ),
          ],
        ),
      ],
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
