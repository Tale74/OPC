import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../auth/domain/session_service.dart';
import '../../podesavanja/data/podesavanja_repository.dart';
import '../application/stanje_robe_lifecycle_service.dart';
import '../application/stanje_robe_operational_availability.dart';
import '../data/stanje_robe_posledice_repository.dart';
import '../data/stanje_robe_repository.dart';

class StanjeRobeAdminScreen extends StatelessWidget {
  const StanjeRobeAdminScreen({
    super.key,
    required this.session,
    required this.podesavanjaRepository,
    required this.stanjeRobeRepository,
    required this.poslediceRepository,
    this.entitlementPolicy = const OpcEntitlementPolicy.current(),
  });

  final SessionService session;
  final PodesavanjaRepository podesavanjaRepository;
  final StanjeRobeRepository stanjeRobeRepository;
  final StanjeRobePoslediceRepository poslediceRepository;
  final OpcEntitlementPolicy entitlementPolicy;

  @override
  Widget build(BuildContext context) {
    if (!session.jeAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('STANJE ROBE')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Samo ADMINISTRATOR može da upravlja stanjem robe.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final availability = StanjeRobeOperationalAvailability(
      podesavanjaRepository: podesavanjaRepository,
      entitlementPolicy: entitlementPolicy,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('STANJE ROBE')),
      body: SafeArea(
        child: StreamBuilder<StanjeRobeOperationalStatus>(
          stream: availability.watchStatus(),
          builder: (context, statusSnap) {
            final status =
                statusSnap.data ?? StanjeRobeOperationalStatus.notLicensed;
            final lifecycleService = StanjeRobeLifecycleService(
              db: stanjeRobeRepository.db,
              isOperationallyActive: availability.isActive,
            );
            return StreamBuilder<List<StanjeRobeStavkeData>>(
              stream: stanjeRobeRepository.watchSveStavke(),
              builder: (context, stockSnap) {
                final rows = stockSnap.data ?? const <StanjeRobeStavkeData>[];
                return StreamBuilder<
                  Map<String, List<StanjeRobePoslediceData>>
                >(
                  stream: poslediceRepository
                      .watchActiveUnresolvedByStableArticleId(),
                  builder: (context, consequenceSnap) {
                    final consequencesByArticle =
                        consequenceSnap.data ??
                        const <String, List<StanjeRobePoslediceData>>{};
                    return _StanjeRobeAdminContent(
                      rows: rows,
                      consequencesByArticle: consequencesByArticle,
                      operationalStatus: status,
                      podesavanjaRepository: podesavanjaRepository,
                      repository: stanjeRobeRepository,
                      lifecycleService: lifecycleService,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StanjeRobeAdminContent extends StatelessWidget {
  const _StanjeRobeAdminContent({
    required this.rows,
    required this.consequencesByArticle,
    required this.operationalStatus,
    required this.podesavanjaRepository,
    required this.repository,
    required this.lifecycleService,
  });

  final List<StanjeRobeStavkeData> rows;
  final Map<String, List<StanjeRobePoslediceData>> consequencesByArticle;
  final StanjeRobeOperationalStatus operationalStatus;
  final PodesavanjaRepository podesavanjaRepository;
  final StanjeRobeRepository repository;
  final StanjeRobeLifecycleService lifecycleService;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OperationalNotice(status: operationalStatus),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  _EmptyStockState(onInitialize: _initializeFromCatalog)
                else
                  FutureBuilder<Map<String, _StockArticleDisplay>>(
                    future: _loadArticleDisplayByStableId(),
                    builder: (context, displaySnap) {
                      final displayByStableId =
                          displaySnap.data ??
                          const <String, _StockArticleDisplay>{};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InitializedStockNotice(rowCount: rows.length),
                          const SizedBox(height: 12),
                          ...rows.map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _StockRowCard(
                                row: row,
                                articleDisplay:
                                    displayByStableId[row.stableArticleId],
                                unresolvedConsequences:
                                    consequencesByArticle[row
                                        .stableArticleId] ??
                                    const <StanjeRobePoslediceData>[],
                                operationalStatus: operationalStatus,
                                repository: repository,
                                lifecycleService: lifecycleService,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, _StockArticleDisplay>>
  _loadArticleDisplayByStableId() async {
    final katalog = await _loadCoveredCatalogArticles();
    final displayByStableId = <String, _StockArticleDisplay>{};
    for (final entry in katalog) {
      if (!StanjeRobeLifecycleService.isCoveredCategory(
        entry.config.interniNaziv,
      )) {
        continue;
      }
      for (final article in entry.artikli) {
        final stableArticleId = article.stableArticleId?.trim();
        if (stableArticleId == null || stableArticleId.isEmpty) continue;
        displayByStableId[stableArticleId] = _StockArticleDisplay(
          articleName: article.naziv.trim(),
          categoryLabel:
              StanjeRobeLifecycleService.displayLabelForCoveredCategory(
                article.interniNazivKategorije,
              ),
        );
      }
    }
    return displayByStableId;
  }

  Future<List<KatalogPickerEntry>> _loadCoveredCatalogArticles() {
    return podesavanjaRepository
        .getKatalogSaArtiklimaLightweightZaKategorije(const <String>{
          StanjeRobeLifecycleService.kategorijaSanduk,
          StanjeRobeLifecycleService.kategorijaObelezje,
          StanjeRobeLifecycleService.kategorijaPokrovGarnitura,
        });
  }

  Future<void> _initializeFromCatalog(BuildContext context) async {
    final katalog = await _loadCoveredCatalogArticles();
    final stableArticleIds = <String>[];
    for (final entry in katalog) {
      if (!StanjeRobeLifecycleService.isCoveredCategory(
        entry.config.interniNaziv,
      )) {
        continue;
      }
      for (final article in entry.artikli) {
        final stableArticleId = article.stableArticleId?.trim();
        if (stableArticleId != null && stableArticleId.isNotEmpty) {
          stableArticleIds.add(stableArticleId);
        }
      }
    }

    if (!context.mounted) return;
    if (stableArticleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nema katalog artikala sa stabilnim identitetom za STANJE ROBE.',
          ),
        ),
      );
      return;
    }

    final inserted = await repository.inicijalizujNedostajuceStavke(
      stableArticleIds,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inserted == 0
              ? 'Sve STANJE ROBE stavke su već inicijalizovane.'
              : 'Inicijalizovano STANJE ROBE stavki: $inserted.',
        ),
      ),
    );
  }
}

class _OperationalNotice extends StatelessWidget {
  const _OperationalNotice({required this.status});

  final StanjeRobeOperationalStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      StanjeRobeOperationalStatus.notLicensed => scheme.error,
      StanjeRobeOperationalStatus.disabled => scheme.tertiary,
      StanjeRobeOperationalStatus.active => scheme.primary,
    };
    final text = switch (status) {
      StanjeRobeOperationalStatus.notLicensed =>
        'STANJE ROBE nije dostupno za trenutni paket/licencu.',
      StanjeRobeOperationalStatus.disabled =>
        'STANJE ROBE je operativno isključeno. Podaci su sačuvani i mogu se pregledati.',
      StanjeRobeOperationalStatus.active =>
        'STANJE ROBE je operativno aktivno.',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyStockState extends StatelessWidget {
  const _EmptyStockState({required this.onInitialize});

  final Future<void> Function(BuildContext context) onInitialize;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nema evidentiranih STANJE ROBE stavki.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Modul je dostupan, ali jos nije inicijalizovan. '
              'Inicijalizujte praćenje robe iz kataloga za kategorije koje se '
              'prate kroz STANJE ROBE.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => onInitialize(context),
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Inicijalizuj stanje robe iz kataloga'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitializedStockNotice extends StatelessWidget {
  const _InitializedStockNotice({required this.rowCount});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'STANJE ROBE je inicijalizovano. Pracene stavke: $rowCount. '
          'Ako je modul operativno iskljucen, zalihe i posledice ostaju '
          'sacuvane za kasnije ponovno ukljucivanje.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _StockArticleDisplay {
  const _StockArticleDisplay({
    required this.articleName,
    required this.categoryLabel,
  });

  final String articleName;
  final String categoryLabel;
}

class _StockRowCard extends StatelessWidget {
  const _StockRowCard({
    required this.row,
    required this.articleDisplay,
    required this.unresolvedConsequences,
    required this.operationalStatus,
    required this.repository,
    required this.lifecycleService,
  });

  final StanjeRobeStavkeData row;
  final _StockArticleDisplay? articleDisplay;
  final List<StanjeRobePoslediceData> unresolvedConsequences;
  final StanjeRobeOperationalStatus operationalStatus;
  final StanjeRobeRepository repository;
  final StanjeRobeLifecycleService lifecycleService;

  bool get _belowMinimum => row.trenutnaKolicina < row.minimalnaKolicina;
  int get _unresolvedCount => unresolvedConsequences.length;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayName = articleDisplay?.articleName.trim();
    final primaryLabel = displayName == null || displayName.isEmpty
        ? row.stableArticleId
        : displayName;
    final categoryLabel = articleDisplay?.categoryLabel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryLabel == null || categoryLabel.isEmpty
                            ? 'Stable ID: ${row.stableArticleId}'
                            : 'Kategorija: $categoryLabel - Stable ID: '
                                  '${row.stableArticleId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Izmeni'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Trenutno',
                  value: _formatQuantity(row.trenutnaKolicina),
                ),
                _InfoChip(
                  label: 'Minimum',
                  value: _formatQuantity(row.minimalnaKolicina),
                ),
                _StatusChip(
                  text: row.aktivna ? 'Aktivno' : 'Neaktivno',
                  color: row.aktivna ? scheme.primary : scheme.outline,
                ),
                if (_belowMinimum)
                  _StatusChip(text: 'Ispod minimuma', color: scheme.error),
                if (_unresolvedCount > 0)
                  _StatusChip(
                    text: 'Nerazrešeno: $_unresolvedCount',
                    color: scheme.tertiary,
                  ),
              ],
            ),
            if (unresolvedConsequences.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...unresolvedConsequences.map(
                (consequence) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _ConsequenceResolutionRow(
                    consequence: consequence,
                    stockRow: row,
                    operationalStatus: operationalStatus,
                    lifecycleService: lifecycleService,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<_StockEditResult>(
      context: context,
      builder: (_) => _StockEditDialog(row: row),
    );

    if (result == null) return;
    await repository.sacuvajStanje(
      stableArticleId: row.stableArticleId,
      trenutnaKolicina: result.currentQuantity,
      minimalnaKolicina: result.minimumQuantity,
      aktivna: row.aktivna,
    );
  }
}

class _ConsequenceResolutionRow extends StatelessWidget {
  const _ConsequenceResolutionRow({
    required this.consequence,
    required this.stockRow,
    required this.operationalStatus,
    required this.lifecycleService,
  });

  final StanjeRobePoslediceData consequence;
  final StanjeRobeStavkeData stockRow;
  final StanjeRobeOperationalStatus operationalStatus;
  final StanjeRobeLifecycleService lifecycleService;

  bool get _canResolve =>
      operationalStatus == StanjeRobeOperationalStatus.active &&
      stockRow.aktivna &&
      stockRow.trenutnaKolicina >= consequence.effectQuantity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final article = consequence.selectedNazivSnapshot.trim().isNotEmpty
        ? consequence.selectedNazivSnapshot.trim()
        : consequence.katalogStableArticleId;
    final category = StanjeRobeLifecycleService.displayLabelForCoveredCategory(
      consequence.kategorija,
    );
    final reason = _disabledReason;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 520),
              child: Text(
                '$category: $article',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            _InfoChip(
              label: 'Efekat',
              value: _formatQuantity(consequence.effectQuantity),
            ),
            if (reason != null)
              Text(
                reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            FilledButton.icon(
              onPressed: _canResolve ? () => _confirmResolve(context) : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Razreši'),
            ),
          ],
        ),
      ),
    );
  }

  String? get _disabledReason {
    if (operationalStatus != StanjeRobeOperationalStatus.active) {
      return 'STANJE ROBE nije operativno aktivno.';
    }
    if (!stockRow.aktivna) {
      return 'Stavka nije aktivna.';
    }
    if (stockRow.trenutnaKolicina < consequence.effectQuantity) {
      return 'Zaliha još nije dovoljna.';
    }
    return null;
  }

  Future<void> _confirmResolve(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final article = consequence.selectedNazivSnapshot.trim().isNotEmpty
        ? consequence.selectedNazivSnapshot.trim()
        : consequence.katalogStableArticleId;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Razreši posledicu'),
        content: Text(
          'Ova akcija će smanjiti stanje robe za '
          '${_formatQuantity(consequence.effectQuantity)} i označiti '
          'posledicu kao razrešenu.\n\n'
          'Artikal: $article',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RAZREŠI'),
          ),
        ],
      ),
    );

    if (accepted != true) return;
    final result = await lifecycleService
        .resolveUnresolvedConsequenceAfterReplenishment(
          consequenceId: consequence.id,
        );
    messenger.showSnackBar(
      SnackBar(content: Text(_resolutionMessage(result.outcome))),
    );
  }

  String _resolutionMessage(StanjeRobeLifecycleOutcome outcome) {
    return switch (outcome) {
      StanjeRobeLifecycleOutcome.resolvedAfterReplenishment =>
        'Posledica je razrešena i stanje robe je smanjeno.',
      StanjeRobeLifecycleOutcome.resolutionInsufficientStock =>
        'Zaliha nije dovoljna za razrešenje.',
      StanjeRobeLifecycleOutcome.resolutionNoActiveConsequence =>
        'Posledica više nije aktivna.',
      StanjeRobeLifecycleOutcome.resolutionNoUnresolvedEffect =>
        'Nije pronađen odgovarajući nerazrešeni efekat.',
      StanjeRobeLifecycleOutcome.operationallyDisabled =>
        'STANJE ROBE nije operativno aktivno.',
      _ => 'Razrešenje nije izvršeno.',
    };
  }
}

class _StockEditDialog extends StatefulWidget {
  const _StockEditDialog({required this.row});

  final StanjeRobeStavkeData row;

  @override
  State<_StockEditDialog> createState() => _StockEditDialogState();
}

class _StockEditDialogState extends State<_StockEditDialog> {
  late final TextEditingController _currentController;
  late final TextEditingController _minimumController;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController(
      text: _formatQuantity(widget.row.trenutnaKolicina),
    );
    _minimumController = TextEditingController(
      text: _formatQuantity(widget.row.minimalnaKolicina),
    );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Izmeni stanje robe'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Trenutna količina'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minimumController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Minimalna količina'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(onPressed: _save, child: const Text('SAČUVAJ')),
      ],
    );
  }

  void _save() {
    final current = _parseQuantity(_currentController.text);
    final minimum = _parseQuantity(_minimumController.text);
    if (current == null || minimum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite ispravne nenegativne količine.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _StockEditResult(currentQuantity: current, minimumQuantity: minimum),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: scheme.surfaceContainerHighest,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color.withValues(alpha: 0.55)),
      backgroundColor: color.withValues(alpha: 0.10),
    );
  }
}

class _StockEditResult {
  const _StockEditResult({
    required this.currentQuantity,
    required this.minimumQuantity,
  });

  final double currentQuantity;
  final double minimumQuantity;
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

double? _parseQuantity(String value) {
  final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
  if (parsed == null || parsed < 0) return null;
  return parsed;
}
