import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../data/iriu_repository.dart';
import '../data/predmeti_repository.dart';
import '../statistika_v1/statistika_snapshot_service.dart';
import 'statistika_aggregator.dart';

class StatistikaScreen extends StatefulWidget {
  const StatistikaScreen({
    super.key,
    required this.predmetiRepo,
    required this.iriuRepo,
  });

  final PredmetiRepository predmetiRepo;
  final IriuRepository iriuRepo;

  @override
  State<StatistikaScreen> createState() => _StatistikaScreenState();
}

class _StatistikaScreenState extends State<StatistikaScreen> {
  static const _aggregator = StatistikaAggregator();
  static const _snapshotService = StatistikaSnapshotService();
  static const _strictTopKategorije = <String, String>{
    'SANDUK': 'SANDUK',
    'OBELEZJE': 'OBELEŽJE',
    'POKROV_GARNITURA': 'POKROV GARNITURA',
    'CVECE': 'CVEĆE',
    'CITULJA_POLITIKA': 'ČITULJE',
    'CITULJA_NOVOSTI': 'ČITULJE',
  };

  _StatistikaPreset _preset = _StatistikaPreset.trenutniMesec;
  DateTime? _customDateFrom;
  DateTime? _customDateTo;
  late final Future<_StatistikaSourceData> _future = _load();

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

  Future<_StatistikaSourceData> _load() async {
    final predmeti = await widget.predmetiRepo.getSvePredmete();
    final iriu = await widget.iriuRepo.getSveIriu();
    final korisnici = await widget.predmetiRepo.getSveKorisnike();
    final kategorije =
        await widget.predmetiRepo.db.select(widget.predmetiRepo.db.iriuKatalogConfig).get();

    final kataloskeKategorije = kategorije
        .where(
          (row) =>
              row.tip == 'KATALOSKA' &&
              _strictTopKategorije.containsKey(row.interniNaziv),
        )
        .fold<Map<String, String>>({}, (map, row) {
          map[row.interniNaziv] =
              _strictTopKategorije[row.interniNaziv] ?? row.nazivPrikaz;
          return map;
        });

    return _StatistikaSourceData(
      predmeti: predmeti,
      iriu: iriu,
      korisnici: korisnici,
      kataloskeKategorije: kataloskeKategorije,
    );
  }

  StatistikaDateRange _resolveRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_preset) {
      _StatistikaPreset.poslednjih7Dana => StatistikaDateRange(
          dateFrom: today.subtract(const Duration(days: 6)),
          dateTo: today,
        ),
      _StatistikaPreset.poslednjih30Dana => StatistikaDateRange(
          dateFrom: today.subtract(const Duration(days: 29)),
          dateTo: today,
        ),
      _StatistikaPreset.trenutniMesec => StatistikaDateRange(
          dateFrom: DateTime(today.year, today.month, 1),
          dateTo: today,
        ),
      _StatistikaPreset.trenutnaGodina => StatistikaDateRange(
          dateFrom: DateTime(today.year, 1, 1),
          dateTo: today,
        ),
      _StatistikaPreset.custom => StatistikaDateRange(
          dateFrom: _customDateFrom ?? today,
          dateTo: _customDateTo ?? today,
        ),
    };
  }

  Future<void> _pickCustomDate({
    required bool isFrom,
  }) async {
    final activeRange = _resolveRange();
    final initialDate = isFrom
        ? (_customDateFrom ?? activeRange.dateFrom)
        : (_customDateTo ?? activeRange.dateTo);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      if (isFrom) {
        _customDateFrom = normalized;
        final currentTo = _customDateTo ?? normalized;
        if (currentTo.isBefore(normalized)) {
          _customDateTo = normalized;
        }
      } else {
        _customDateTo = normalized;
        final currentFrom = _customDateFrom ?? normalized;
        if (normalized.isBefore(currentFrom)) {
          _customDateFrom = normalized;
        }
      }
      _preset = _StatistikaPreset.custom;
    });
  }

  String _formatDay(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}.';
  }

  String _formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integer = parts.first;
    final decimal = parts.length > 1 ? parts[1] : '00';
    final buffer = StringBuffer();

    for (var index = 0; index < integer.length; index++) {
      final reverseIndex = integer.length - index;
      buffer.write(integer[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()},$decimal RSD';
  }

  String _formatRangeLabel(StatistikaDateRange range) {
    return '${_formatDay(range.dateFrom)} - ${_formatDay(range.dateTo)}';
  }


  @override
  Widget build(BuildContext context) {
    final range = _resolveRange();
    return Scaffold(
      appBar: AppBar(
        title: const Text('STATISTIKA'),
      ),
      body: FutureBuilder<_StatistikaSourceData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Došlo je do greške pri učitavanju statistike.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final source = snapshot.data;
          if (source == null) {
            return const SizedBox.shrink();
          }

          final periodSnapshot = _snapshotService.buildPeriodSnapshot(
            predmeti: source.predmeti,
            iriu: source.iriu,
            korisnici: source.korisnici,
            kataloskeKategorije: source.kataloskeKategorije,
            dateFrom: range.dateFrom,
            dateTo: range.dateTo,
          );
          final data = _aggregator.build(
            source: periodSnapshot,
          );

          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      _FilterCard(
                        preset: _preset,
                        rangeLabel: _formatRangeLabel(range),
                        customDateFrom: _customDateFrom,
                        customDateTo: _customDateTo,
                        formatDay: _formatDay,
                        onPresetSelected: (preset) {
                          setState(() {
                            _preset = preset;
                            if (preset != _StatistikaPreset.custom) {
                              _customDateFrom = null;
                              _customDateTo = null;
                            }
                          });
                        },
                        onPickDateFrom: () => _pickCustomDate(isFrom: true),
                        onPickDateTo: () => _pickCustomDate(isFrom: false),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Jedan posmatrani period važi za sve prikazane statistike.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Theme(
                    data: _bodyTabTheme(context),
                    child: const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'PREGLED'),
                        Tab(text: 'SAVETNICI'),
                        Tab(text: 'CEREMONIJA'),
                        Tab(text: 'MESTO SMRTI'),
                        Tab(text: 'TOP ARTIKLI'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _StatistikaTabBody(
                        children: [
                          const _SectionHeading(
                            title: 'Pregled perioda',
                            subtitle:
                                'Prikaz je samo za čitanje i zasnovan isključivo na predmetima čiji datum kreiranja upada u izabrani period.',
                          ),
                          const SizedBox(height: 12),
                          _SummaryCard(
                            summary: data.summary,
                            formatMoney: _formatMoney,
                          ),
                        ],
                      ),
                      _StatistikaTabBody(
                        children: [
                          const _SectionHeading(
                            title: 'Savetnici',
                            subtitle:
                                'Presek prikazuje broj predmeta, zbir IRIU vrednosti po predmetima i prose?nu IRIU vrednost po predmetu.',
                          ),
                          const SizedBox(height: 12),
                          _BreakdownSection(
                            title: 'Po savetniku',
                            rows: data.poSavetniku,
                            formatMoney: _formatMoney,
                          ),
                        ],
                      ),
                      _StatistikaTabBody(
                        children: [
                          const _SectionHeading(
                            title: 'Ceremonija',
                            subtitle:
                                'Prikaz je podeljen na vrstu ceremonije i mesto ceremonije za isti izabrani period.',
                          ),
                          const SizedBox(height: 12),
                          _BreakdownSection(
                            title: 'Po vrsti ceremonije',
                            rows: data.poVrstiCeremonije,
                            formatMoney: _formatMoney,
                          ),
                          const SizedBox(height: 16),
                          _BreakdownSection(
                            title: 'Po mestu ceremonije',
                            rows: data.poMestuCeremonije,
                            formatMoney: _formatMoney,
                          ),
                        ],
                      ),
                      _StatistikaTabBody(
                        children: [
                          const _SectionHeading(
                            title: 'Mesto smrti',
                            subtitle:
                                'Presek je vezan za isti posmatrani period i ne uvodi dodatne filtere niti posebnu logiku.',
                          ),
                          const SizedBox(height: 12),
                          _BreakdownSection(
                            title: 'Po mestu smrti',
                            rows: data.poMestuSmrti,
                            formatMoney: _formatMoney,
                          ),
                        ],
                      ),
                      _StatistikaTabBody(
                        children: [
                          const _SectionHeading(
                            title: 'Top 10 artikala',
                            subtitle:
                                'Top lista prikazuje pojedinačne artikle unutar svake kataloške kategorije. Artikal se računa jednom po predmetu, bez uticaja kolone KOM.',
                          ),
                          const SizedBox(height: 12),
                          _TopArtikliSection(
                            sections: data.topArtikliPoKategorijama,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _StatistikaPreset {
  poslednjih7Dana,
  poslednjih30Dana,
  trenutniMesec,
  trenutnaGodina,
  custom,
}

class _StatistikaSourceData {
  const _StatistikaSourceData({
    required this.predmeti,
    required this.iriu,
    required this.korisnici,
    required this.kataloskeKategorije,
  });

  final List<PredmetiData> predmeti;
  final List<IriuData> iriu;
  final List<KorisniciData> korisnici;
  final Map<String, String> kataloskeKategorije;
}

class _StatistikaTabBody extends StatelessWidget {
  const _StatistikaTabBody({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.preset,
    required this.rangeLabel,
    required this.customDateFrom,
    required this.customDateTo,
    required this.formatDay,
    required this.onPresetSelected,
    required this.onPickDateFrom,
    required this.onPickDateTo,
  });

  final _StatistikaPreset preset;
  final String rangeLabel;
  final DateTime? customDateFrom;
  final DateTime? customDateTo;
  final String Function(DateTime value) formatDay;
  final ValueChanged<_StatistikaPreset> onPresetSelected;
  final VoidCallback onPickDateFrom;
  final VoidCallback onPickDateTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obavezan filter perioda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sav prikaz ispod koristi datum kreiranja predmeta kao jedini vremenski filter.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _StatistikaPreset.values
                  .map(
                    (item) => ChoiceChip(
                      label: Text(_presetLabel(item)),
                      selected: preset == item,
                      onSelected: (_) => onPresetSelected(item),
                    ),
                  )
                  .toList(growable: false),
            ),
            if (preset == _StatistikaPreset.custom) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: onPickDateFrom,
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(
                      customDateFrom == null
                          ? 'Datum od'
                          : 'Datum od: ${formatDay(customDateFrom!)}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onPickDateTo,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      customDateTo == null
                          ? 'Datum do'
                          : 'Datum do: ${formatDay(customDateTo!)}',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _InfoPill(
              icon: Icons.schedule_outlined,
              text: 'Aktivan period: $rangeLabel',
            ),
          ],
        ),
      ),
    );
  }

  String _presetLabel(_StatistikaPreset preset) {
    return switch (preset) {
      _StatistikaPreset.poslednjih7Dana => 'Poslednjih 7 dana',
      _StatistikaPreset.poslednjih30Dana => 'Poslednjih 30 dana',
      _StatistikaPreset.trenutniMesec => 'Tekući mesec',
      _StatistikaPreset.trenutnaGodina => 'Tekuća godina',
      _StatistikaPreset.custom => 'Ručni period',
    };
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.formatMoney,
  });

  final StatistikaSummary summary;
  final String Function(double value) formatMoney;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MetricTile(
              label: 'Broj predmeta u periodu',
              value: summary.brojPredmeta.toString(),
            ),
            const Divider(height: 24),
            _MetricTile(
              label: 'Ukupan zbir IRIU vrednosti',
              value: formatMoney(summary.ukupnaIriuVrednost),
              emphasize: true,
            ),
            const Divider(height: 24),
            _MetricTile(
              label: 'Prosečna IRIU vrednost po predmetu',
              value: formatMoney(summary.prosecnaIriuVrednostPoPredmetu),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: (emphasize ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({
    required this.title,
    required this.rows,
    required this.formatMoney,
  });

  final String title;
  final List<StatistikaBreakdownRow> rows;
  final String Function(double value) formatMoney;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                'Nema podataka za izabrani period.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _InlineMetric(
                              label: 'Predmeti',
                              value: row.brojPredmeta.toString(),
                            ),
                            _InlineMetric(
                              label: 'Zbir IRIU',
                              value: formatMoney(row.ukupnaIriuVrednost),
                            ),
                            _InlineMetric(
                              label: 'Prosek',
                              value: formatMoney(row.prosecnaIriuVrednostPoPredmetu),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TopArtikliSection extends StatelessWidget {
  const _TopArtikliSection({
    required this.sections,
  });

  final List<StatistikaTopKategorijaSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 10 pojedinačnih artikala po kategorijama',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (sections.isEmpty)
              Text(
                'Nema kataloških artikala u izabranom periodu.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.kategorijaLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (section.rows.isEmpty)
                        Text(
                          'Nema stavki u izabranom periodu.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        ...section.rows.asMap().entries.map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.value.label),
                            subtitle: Text(
                              'Predmeti: ${entry.value.brojPredmeta}',
                            ),
                            leading: CircleAvatar(
                              radius: 16,
                              child: Text('${entry.key + 1}'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
