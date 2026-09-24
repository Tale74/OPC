import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/format/app_date_format.dart';
import '../../data/predmeti_repository.dart';
import '../data/citulje_preparation_repository.dart';
import '../data/parte_confirmed_text_adapter.dart';
import '../domain/citulje_models.dart';
import '../pdf/citulja_pdf_export.dart';
import '../../reminders/podsetnik_eligibility.dart';
import '../../parte/application/parte_preparation_service.dart';
import '../../parte/data/parte_media_store.dart';
import '../../parte/data/parte_preparation_repository.dart';

class CituljeModuleScreen extends StatefulWidget {
  const CituljeModuleScreen({super.key, required this.predmetiRepository});

  final PredmetiRepository predmetiRepository;

  @override
  State<CituljeModuleScreen> createState() => _CituljeModuleScreenState();
}

class _CituljeModuleScreenState extends State<CituljeModuleScreen> {
  late final CituljePreparationRepository _repository;
  late final StreamSubscription<List<PredmetiData>> _predmetiSubscription;
  List<_CituljePredmetItem> _items = const [];
  int? _selectedPredmetId;
  bool _loading = true;
  bool _openingPredmet = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _repository = CituljePreparationRepository(widget.predmetiRepository.db);
    _predmetiSubscription = widget.predmetiRepository.watchSvi().listen(
      _applyPredmeti,
    );
  }

  Future<void> _applyPredmeti(List<PredmetiData> allPredmeti) async {
    final generation = ++_loadGeneration;
    final predmeti =
        allPredmeti
            .where((predmet) => isPodsetnikEligibleStatus(predmet.status))
            .toList()
          ..sort(_comparePredmeti);
    final result = <_CituljePredmetItem>[];
    for (final predmet in predmeti) {
      final preparations = await _repository.ensureCurrentForPredmet(
        predmet.id,
      );
      if (preparations.isNotEmpty) {
        result.add(_CituljePredmetItem(predmet, preparations));
      }
    }
    if (!mounted || generation != _loadGeneration) return;
    final selectedId = _selectedPredmetId;
    setState(() {
      _items = result;
      _selectedPredmetId = result.any((item) => item.predmet.id == selectedId)
          ? selectedId
          : null;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    if (mounted) setState(() => _loading = true);
    await _applyPredmeti(await widget.predmetiRepository.getSvePredmete());
  }

  Future<void> _open(_CituljePredmetItem item) async {
    final currentPredmet = await widget.predmetiRepository.getPredmet(
      item.predmet.id,
    );
    if (!mounted) return;
    if (!isPodsetnikEligibleStatus(currentPredmet.status)) {
      await _refresh();
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CituljePreparationScreen(
          predmet: currentPredmet,
          preparations: _repository,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  Future<void> _selectPredmet(int? value) async {
    if (value == null || _openingPredmet || !mounted) return;
    final item = _items.where((candidate) => candidate.predmet.id == value);
    if (item.isEmpty) return;
    setState(() {
      _selectedPredmetId = value;
      _openingPredmet = true;
    });
    try {
      await _open(item.first);
    } finally {
      if (mounted) setState(() => _openingPredmet = false);
    }
  }

  @override
  void dispose() {
    _predmetiSubscription.cancel();
    super.dispose();
  }

  static int _comparePredmeti(PredmetiData a, PredmetiData b) {
    final byCreatedAt = b.datumKreiranja.compareTo(a.datumKreiranja);
    return byCreatedAt != 0 ? byCreatedAt : b.id.compareTo(a.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MODUL ČITULJE'),
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
        : _items.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nema PREDMETA dostupnih za ČITULJE.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView(
            key: const Key('citulje-module-predmet-list'),
            padding: const EdgeInsets.all(24),
            children: [
              const Text('ČITULJE'),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const Key('citulje-predmet-selector'),
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
                          item.secondaryLabel == null
                              ? item.displayName
                              : '${item.displayName} · ${item.secondaryLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _selectPredmet,
              ),
              const SizedBox(height: 16),
              if (_selectedPredmetId == null)
                const Text('Izaberite PREDMET za pripremu ČITULJE.'),
            ],
          ),
  );
}

class _CituljePredmetItem {
  const _CituljePredmetItem(this.predmet, this.preparations);

  final PredmetiData predmet;
  final List<CituljePripremeData> preparations;

  String get displayName {
    final name = '${predmet.ime} ${predmet.prezime}'.trim();
    return name.isEmpty ? 'PREDMET' : name;
  }

  String? get secondaryLabel {
    final broj = predmet.brojPredmeta.trim();
    return broj.isEmpty ? null : 'Broj PREDMETA: $broj';
  }
}

class CituljePreparationScreen extends StatefulWidget {
  const CituljePreparationScreen({
    super.key,
    required this.predmet,
    required this.preparations,
  });

  final PredmetiData predmet;
  final CituljePreparationRepository preparations;

  @override
  State<CituljePreparationScreen> createState() =>
      _CituljePreparationScreenState();
}

class _CituljePreparationScreenState extends State<CituljePreparationScreen> {
  late Future<List<CituljePripremeData>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.preparations.listCurrentForPredmet(widget.predmet.id);
  }

  Future<void> _reload() async {
    setState(() {
      _rows = widget.preparations.listCurrentForPredmet(widget.predmet.id);
    });
    await _rows;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('ČITULJE · ${widget.predmet.brojPredmeta}'),
      actions: [
        IconButton(
          onPressed: _reload,
          tooltip: 'Osveži pripreme',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<CituljePripremeData>>(
      future: _rows,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          key: const Key('citulje-preparation-list'),
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _CituljePreparationCard(
            key: ValueKey(snapshot.data![index].portableOccurrenceId),
            initial: snapshot.data![index],
            repository: widget.preparations,
            onChanged: _reload,
          ),
        );
      },
    ),
  );
}

class _CituljePreparationCard extends StatefulWidget {
  const _CituljePreparationCard({
    super.key,
    required this.initial,
    required this.repository,
    required this.onChanged,
  });

  final CituljePripremeData initial;
  final CituljePreparationRepository repository;
  final Future<void> Function() onChanged;

  @override
  State<_CituljePreparationCard> createState() =>
      _CituljePreparationCardState();
}

class _CituljePreparationCardState extends State<_CituljePreparationCard> {
  late CituljePripremeData _row;
  late Future<String> _articleLabel;
  late final TextEditingController _date;
  late final TextEditingController _text;
  CituljeParteTextMode? _mode;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _setRow(widget.initial);
    _date = TextEditingController(text: widget.initial.publicationDate ?? '');
    _text = TextEditingController(text: widget.initial.publicationText);
  }

  void _setRow(CituljePripremeData row) {
    _row = row;
    _mode = CituljeParteTextMode.fromDb(row.parteTextMode);
    _articleLabel = widget.repository.currentCituljaDisplayValue(row);
  }

  Future<void> _pickPublicationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDateValue(_date.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date.text = formatCalendarPickerSelection(picked, trailingDot: true);
    });
  }

  @override
  void didUpdateWidget(covariant _CituljePreparationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial.updatedAt != widget.initial.updatedAt) {
      setState(() {
        _setRow(widget.initial);
        _date.text = widget.initial.publicationDate ?? '';
        _text.text = widget.initial.publicationText;
      });
    }
  }

  @override
  void dispose() {
    _date.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool allowFinalized = false,
  }) async {
    if (_busy || (_row.finalized && !allowFinalized)) return;
    setState(() => _busy = true);
    try {
      await action();
      await widget.onChanged();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ČITULJE priprema nije sačuvana: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() async {
    if (_row.finalized) {
      final saved = await widget.repository.saveHumanCorrections(
        preparationId: _row.id,
        publicationDate: _date.text,
        publicationText: _text.text,
        note: _row.note,
      );
      if (mounted) setState(() => _setRow(saved));
      return;
    }
    final mode = _mode;
    if (mode == null) {
      throw StateError('Izaberite PARTE TEKST režim.');
    }
    var saved = await widget.repository.configure(
      preparationId: _row.id,
      mode: mode,
      publicationDate: _date.text,
      publicationText: _text.text,
      note: _row.note,
    );
    if (mode == CituljeParteTextMode.da &&
        saved.state == CituljePreparationState.parteSnapshotAvailable.dbValue) {
      saved = await widget.repository.savePublicationText(
        preparationId: _row.id,
        publicationText: _text.text,
      );
    }
    if (mounted) {
      setState(() {
        _setRow(saved);
        _text.text = saved.publicationText;
      });
    }
  }, allowFinalized: true);

  Future<void> _removeFinalizedPreparation() async {
    if (_busy || !_row.finalized) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ukloniti ČITULJA pripremu?'),
        content: const Text(
          'Uklanja se samo postojeća priprema. ČITULJA IRiU stavka i PREDMET ostaju nepromenjeni.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('UKLONI'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _run(() async {
      final removed = await widget.repository.removeFinalizedPreparation(
        preparationId: _row.id,
      );
      if (!removed) {
        throw StateError('ČITULJA priprema više nije dostupna.');
      }
    }, allowFinalized: true);
  }

  Future<void> _capture() => _run(() async {
    final mode = _mode;
    if (mode == null) {
      throw StateError('Izaberite PARTE TEKST režim.');
    }
    // Persist the current form intent before the asynchronous upstream read.
    // The repository write predicate then prevents a concurrent DA→NE change
    // from accepting a stale DA capture.
    final configured = await widget.repository.configure(
      preparationId: _row.id,
      mode: mode,
      publicationDate: _date.text,
      publicationText: _text.text,
      note: _row.note,
    );
    if (mounted) {
      setState(() {
        _setRow(configured);
        _text.text = configured.publicationText;
      });
    }
    final parteRepository = PartePreparationRepository(widget.repository.db);
    final adapter = ParteConfirmedTextAdapter(
      repository: parteRepository,
      service: PartePreparationService(
        repository: parteRepository,
        mediaStore: ParteMediaStore(),
      ),
    );
    final saved = await widget.repository.captureParteSnapshot(
      preparationId: _row.id,
      adapter: adapter,
    );
    if (mounted) {
      setState(() {
        _setRow(saved);
        _text.text = saved.publicationText;
      });
    }
  });

  Future<void> _finalize() async {
    if (_busy || _row.finalized) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizuj ČITULJA pripremu?'),
        content: const Text(
          'Nakon finalizacije potvrđene PARTE iteracije više neće menjati ovu pripremu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _run(() async {
                final saved = await widget.repository.finalizePreparation(
                  preparationId: _row.id,
                  mode: _mode,
                  publicationDate: _date.text,
                  publicationText: _text.text,
                  note: _row.note,
                );
                if (mounted) setState(() => _setRow(saved));
              });
            },
            child: const Text('FINALIZUJ'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf() => izvoziCituljaPdf(
    ctx: context,
    db: widget.repository.db,
    preparationId: _row.id,
  );

  bool get _canFinalize {
    final state = _mode == CituljeParteTextMode.ne
        ? CituljePreparationState.independentText
        : CituljePreparationState.fromDb(_row.state);
    return _text.text.trim().isNotEmpty &&
        ((_mode == CituljeParteTextMode.da &&
                state == CituljePreparationState.parteSnapshotAvailable) ||
            (_mode == CituljeParteTextMode.ne &&
                state == CituljePreparationState.independentText));
  }

  @override
  Widget build(BuildContext context) {
    final locked = _row.finalized;
    final wordCount = _text.text.trim().isEmpty
        ? 0
        : _text.text.trim().split(RegExp(r'\s+')).length;
    final articleHeader = Row(
      children: [
        Expanded(
          child: FutureBuilder<String>(
            future: _articleLabel,
            builder: (context, snapshot) => Text(
              snapshot.data ?? cituljaArticleDisplayValue(_row.articleType),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        if (locked)
          const Chip(
            avatar: Icon(Icons.lock_outline, size: 16),
            label: Text('FINALIZOVANO'),
          ),
      ],
    );
    final stateLabel = Text(
      _stateLabel(_row.state),
      key: const Key('citulje-preparation-state'),
      style: Theme.of(context).textTheme.bodySmall,
    );
    final modeField = DropdownButtonFormField<CituljeParteTextMode>(
      key: const Key('citulje-parte-text-mode'),
      initialValue: _mode,
      decoration: const InputDecoration(labelText: 'PARTE TEKST'),
      items: const [
        DropdownMenuItem(value: CituljeParteTextMode.da, child: Text('DA')),
        DropdownMenuItem(value: CituljeParteTextMode.ne, child: Text('NE')),
      ],
      onChanged: locked ? null : (value) => setState(() => _mode = value),
    );
    final dateField = TextField(
      key: const Key('citulje-publication-date'),
      controller: _date,
      enabled: true,
      readOnly: true,
      onTap: _pickPublicationDate,
      decoration: const InputDecoration(
        labelText: 'Datum objavljivanja',
        suffixIcon: Icon(Icons.calendar_month_outlined),
      ),
    );
    final publicationTextField = TextField(
      key: const Key('citulje-publication-text'),
      controller: _text,
      enabled:
          locked ||
          (_mode == CituljeParteTextMode.ne ||
              _row.state ==
                  CituljePreparationState.parteSnapshotAvailable.dbValue),
      minLines: 4,
      maxLines: 8,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Tekst objave',
        helperText: 'Informativno: $wordCount reči',
      ),
    );
    final actionControls = !locked
        ? <Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('citulje-save'),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('SAČUVAJ'),
                ),
                if (_mode == CituljeParteTextMode.da)
                  OutlinedButton.icon(
                    key: const Key('citulje-capture-parte'),
                    onPressed: _busy ? null : _capture,
                    icon: const Icon(Icons.sync_outlined),
                    label: const Text('PREUZMI POTVRĐENI PARTE TEKST'),
                  ),
                OutlinedButton.icon(
                  key: const Key('citulje-finalize'),
                  onPressed: _busy || !_canFinalize ? null : _finalize,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('FINALIZUJ'),
                ),
                OutlinedButton.icon(
                  key: const Key('citulje-export-pdf'),
                  onPressed: _busy ? null : _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('IZVEZI PDF'),
                ),
              ],
            ),
          ]
        : <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'PARTE više ne menja ovu finalizovanu pripremu; dozvoljene su ručne ispravke.',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('citulje-save'),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('SAČUVAJ ISPRAVKE'),
                ),
                OutlinedButton.icon(
                  key: const Key('citulje-remove'),
                  onPressed: _busy ? null : _removeFinalizedPreparation,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('UKLONI PRIPREMU'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('citulje-export-pdf-locked'),
              onPressed: _busy ? null : _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('IZVEZI PDF'),
            ),
          ];
    final leftColumn = <Widget>[
      articleHeader,
      const SizedBox(height: 4),
      stateLabel,
      const SizedBox(height: 12),
      modeField,
      const SizedBox(height: 8),
      dateField,
    ];
    final rightColumn = <Widget>[publicationTextField, ...actionControls];
    return Card(
      key: ValueKey('citulje-card-${_row.portableOccurrenceId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: leftColumn,
            );
            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rightColumn,
            );
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                Expanded(child: right),
              ],
            );
          },
        ),
      ),
    );
  }

  String _stateLabel(String value) =>
      switch (CituljePreparationState.fromDb(value)) {
        CituljePreparationState.unconfigured => 'Stanje: nije podešeno',
        CituljePreparationState.waitingForPartePreview =>
          'Stanje: čeka potvrđeni PARTE pregled',
        CituljePreparationState.parteSnapshotAvailable =>
          'Stanje: preuzet potvrđeni PARTE tekst',
        CituljePreparationState.independentText =>
          'Stanje: nezavisni tekst ČITULJE',
      };
}
