import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../podesavanja/data/podesavanja_repository.dart';
import '../services/iriu_display_name_resolver.dart';
import 'owner_scenario_policy_kernel.dart';
import 'scenario_contract.dart';
import 'scenario_module_repository.dart';
import 'scenario_persistence_contract.dart';
import 'scenario_runtime_reconciliation_service.dart';
import '../../data/iriu_repository.dart';
import '../../data/predmeti_repository.dart';

/// User-facing editor for the SCENARIO module.
class ScenarioModuleScreen extends StatefulWidget {
  const ScenarioModuleScreen({
    super.key,
    required this.podesavanjaRepository,
    this.predmet,
  });

  final PodesavanjaRepository podesavanjaRepository;
  final PredmetiData? predmet;

  @override
  State<ScenarioModuleScreen> createState() => _ScenarioModuleScreenState();
}

class _ScenarioModuleScreenState extends State<ScenarioModuleScreen> {
  late final ScenarioModuleRepository _repository;
  late Future<ScenarioModule> _moduleFuture;
  late Future<List<IriuKatalogConfigData>> _katalogFuture;
  late Future<List<ScenarioDefinitionRecord>> _definitionsFuture;
  late Future<List<PredmetiData>> _openPredmetiFuture;
  late final PredmetiRepository _predmetiRepository;
  ScenarioModule? _currentModule;
  int? _selectedPredmetId;

  @override
  void initState() {
    super.initState();
    _repository = ScenarioModuleRepository(widget.podesavanjaRepository.db);
    _predmetiRepository = PredmetiRepository(widget.podesavanjaRepository.db);
    _openPredmetiFuture = _predmetiRepository.getSvePredmete();
    _moduleFuture = _repository.ensureModuleAndDefaults();
    _katalogFuture = _moduleFuture.then(
      (_) => widget.podesavanjaRepository.getKatalogVidljive(),
    );
    _definitionsFuture = _moduleFuture.then(
      (_) => _repository.getDefinitions(),
    );
  }

  void _selectPredmet(int? predmetId) {
    if (_selectedPredmetId == predmetId) return;
    setState(() {
      _selectedPredmetId = predmetId;
    });
  }

  void _refreshOpenPredmeti() {
    if (!mounted) return;
    setState(() {
      _openPredmetiFuture = _predmetiRepository.getSvePredmete();
    });
  }

  void _reloadScreen() {
    if (!mounted) return;
    setState(() {
      _openPredmetiFuture = _predmetiRepository.getSvePredmete();
      _moduleFuture = _repository.ensureModuleAndDefaults();
      _katalogFuture = _moduleFuture.then(
        (_) => widget.podesavanjaRepository.getKatalogVidljive(),
      );
      _definitionsFuture = _moduleFuture.then(
        (_) => _repository.getDefinitions(),
      );
    });
  }

  Future<void> _izmeniPaket(
    BuildContext context,
    ScenarioModule module,
    List<IriuKatalogConfigData> katalog,
  ) async {
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _PackageDialog(
        title: 'OSNOVNI PAKET',
        katalog: katalog,
        selected: _repository.readOsnovniPaket(module),
      ),
    );
    if (result == null) return;
    await _repository.saveOsnovniPaket(result);
    if (!context.mounted) return;
    _reloadScreen();
  }

  Future<void> _dodajIliIzmeniScenario(
    BuildContext context,
    List<IriuKatalogConfigData> katalog, {
    ScenarioDefinitionRecord? record,
  }) async {
    final existing = record == null
        ? null
        : _repository.definitionFromRecord(record);
    final module = _currentModule ?? await _repository.ensureModule();
    if (!context.mounted) return;
    final result = await showDialog<_ScenarioDraft>(
      context: context,
      builder: (_) => _ScenarioDialog(
        katalog: katalog,
        baseCategoryIds: _repository.readOsnovniPaket(module),
        existing: existing,
        existingVersion: record?.version ?? 1,
        existingDefault: record?.jePodrazumevani ?? false,
      ),
    );
    if (result == null) return;
    await _repository.saveDefinition(
      id: result.id,
      version: result.version,
      naziv: result.naziv,
      condition: result.condition,
      consequences: result.consequences,
      description: result.description,
      jePodrazumevani: result.jePodrazumevani,
      status: 'PRIMENJEN',
    );
    if (!context.mounted) return;
    _reloadScreen();
  }

  Future<void> _pregledScenario(
    BuildContext context,
    List<IriuKatalogConfigData> katalog,
    ScenarioDefinitionRecord record,
  ) async {
    final definition = _repository.definitionFromRecord(record);
    final consequences =
        definition.consequences
            .where(
              (item) => item.action != ScenarioConsequenceAction.suppressed,
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    final warnings = consequences
        .map((item) => item.warning.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final edit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                record.id.startsWith('MAP_')
                    ? _scenarioBusinessSummary(definition)
                    : definition.name,
              ),
            ),
            Chip(
              label: Text(
                record.status == 'PRIMENJEN' ? 'U UPOTREBI' : 'VAN UPOTREBE',
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: _dialogWidth(context, 640),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'USLOVI PRIMENE',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ..._conditionSections(definition.condition).expand(
                  (section) => <Widget>[
                    Text(
                      section.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ...section.lines.map(
                      (line) => Padding(
                        padding: EdgeInsets.only(
                          left: line.depth * 16.0,
                          top: 3,
                        ),
                        child: Text(line.label),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'DODATNE STAVKE SCENARIJA',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                if (consequences.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Nema stavki.'),
                  )
                else
                  ...consequences.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        item.action == ScenarioConsequenceAction.recommended
                            ? Icons.bookmark_border
                            : Icons.check_circle_outline,
                      ),
                      title: Text(
                        _catalogLabel(
                          katalog,
                          item.katalogCategoryInternalName,
                        ),
                      ),
                      subtitle: Text(
                        item.reason.trim().isEmpty
                            ? _statusLabel(item.action)
                            : '${_statusLabel(item.action)} · ${item.reason.trim()}',
                      ),
                    ),
                  ),
                if (warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'UPOZORENJE',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ...warnings.map(
                    (warning) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(warning),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ZATVORI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('UREDI'),
          ),
        ],
      ),
    );
    if (edit == true && context.mounted) {
      await _dodajIliIzmeniScenario(context, katalog, record: record);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SCENARIO')),
      body: FutureBuilder<ScenarioModule>(
        future: _moduleFuture,
        builder: (context, moduleSnapshot) {
          if (moduleSnapshot.hasError) {
            return _ScenarioErrorView(
              error: moduleSnapshot.error!,
              onRetry: _reloadScreen,
            );
          }
          if (!moduleSnapshot.hasData) {
            return const _ScenarioLoadingView();
          }
          return FutureBuilder<List<IriuKatalogConfigData>>(
            future: _katalogFuture,
            builder: (context, katalogSnapshot) {
              if (katalogSnapshot.hasError) {
                return _ScenarioErrorView(
                  error: katalogSnapshot.error!,
                  onRetry: _reloadScreen,
                );
              }
              final katalog = katalogSnapshot.data ?? const [];
              return FutureBuilder<List<ScenarioDefinitionRecord>>(
                future: _definitionsFuture,
                builder: (context, definitionSnapshot) {
                  if (definitionSnapshot.hasError) {
                    return _ScenarioErrorView(
                      error: definitionSnapshot.error!,
                      onRetry: _reloadScreen,
                    );
                  }
                  final definitions = definitionSnapshot.data ?? const [];
                  final ownerDefinitionCount = definitions
                      .where((record) => record.id.startsWith('MAP_'))
                      .length;
                  if (ownerDefinitionCount < 1008) {
                    return _ScenarioErrorView(
                      error: StateError(
                        'Učitano je $ownerDefinitionCount od 1008 scenario definicija.',
                      ),
                      onRetry: _reloadScreen,
                    );
                  }
                  final module = _currentModule ?? moduleSnapshot.data!;
                  final osnovni = _repository.readOsnovniPaket(module);
                  return FutureBuilder<List<PredmetiData>>(
                    future: _openPredmetiFuture,
                    builder: (context, predmetSnapshot) {
                      final openPredmeti = (predmetSnapshot.data ?? const [])
                          .where((item) => item.status == 'OTVOREN')
                          .toList(growable: false);
                      final selected = _selectedPredmetId == null
                          ? null
                          : openPredmeti
                                .where((item) => item.id == _selectedPredmetId)
                                .firstOrNull;
                      if (_selectedPredmetId != null && selected == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && _selectedPredmetId != null) {
                            _selectPredmet(null);
                          }
                        });
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Card(
                              key: ValueKey('scenario-module-description'),
                              child: ListTile(
                                title: Text(
                                  'SCENARIO definiše osnovni i primenjeni paket robe i usluga za buduće PREDMETE.',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              key: const ValueKey(
                                'scenario-card-osnovni-paket',
                              ),
                              child: ListTile(
                                title: const Text('OSNOVNI PAKET'),
                                subtitle: Text(
                                  osnovni.isEmpty
                                      ? 'Nije izabrana nijedna STAVKA.'
                                      : '${osnovni.length} STAVKI iz KATALOGA · za nove PREDMETE',
                                ),
                                trailing: FilledButton(
                                  onPressed: katalog.isEmpty
                                      ? null
                                      : () => _izmeniPaket(
                                          context,
                                          module,
                                          katalog,
                                        ),
                                  child: const Text('UREDI'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              key: const ValueKey('scenario-card-scenariji'),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  8,
                                  8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('SCENARIJI'),
                                      subtitle: Text(
                                        'Pregled i uređivanje SCENARIO politike za buduće PREDMETE.',
                                      ),
                                    ),
                                    _ScenarioPolicyTree(
                                      definitions: definitions,
                                      katalog: katalog,
                                      onPreview: (record) => _pregledScenario(
                                        context,
                                        katalog,
                                        record,
                                      ),
                                      onEdit: (record) =>
                                          _dodajIliIzmeniScenario(
                                            context,
                                            katalog,
                                            record: record,
                                          ),
                                      onAdd: null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            /*
                            if (false)
                              const Card(
                              key: ValueKey('scenario-module-description'),
                              child: ListTile(
                                title: Text(
                                  'Modul SCENARIO uređuje listu osnovnih i dodatnih stavki robe i usluga za automatski pregled i obračun prema mestu smrti i drugim uslovima.',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (false)
                              Card(
                                child: ListTile(
                                title: const Text('OSNOVNI PAKET'),
                                subtitle: Text(
                                  osnovni.isEmpty
                                      ? 'Nije izabrana nijedna STAVKA.'
                                      : '${osnovni.length} STAVKI iz KATALOGA',
                                ),
                                trailing: FilledButton(
                                  onPressed: katalog.isEmpty
                                      ? null
                                      : () => _izmeniPaket(
                                          context,
                                          module,
                                          katalog,
                                        ),
                                  child: const Text('UREDI'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                             if (false)
                              Card(
                                child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  8,
                                  8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _ScenarioPolicyTree(
                                      definitions: definitions,
                                      katalog: katalog,
                                      onPreview: (record) => _pregledScenario(
                                        context,
                                        katalog,
                                        record,
                                      ),
                                      onEdit: (record) =>
                                          _dodajIliIzmeniScenario(
                                            context,
                                            katalog,
                                            record: record,
                                          ),
                                      onAdd: katalog.isEmpty
                                          ? null
                                          : () => _dodajIliIzmeniScenario(
                                              context,
                                              katalog,
                                            ),
                                    ),
                               if (definitions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Nema sačuvanih scenarija.'),
                                )
                              else
                                ...definitions.map(
                                  (record) => ListTile(
                                    key: ValueKey('scenario-row-${record.id}'),
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.rule_outlined),
                                    title: Text(record.naziv),
                                    subtitle: Text(
                                      record.status == 'PRIMENJEN'
                                          ? 'U UPOTREBI'
                                          : 'VAN UPOTREBE',
                                    ),
                                    trailing: Wrap(
                                      spacing: 4,
                                      children: [
                                        TextButton(
                                          key: ValueKey(
                                            'scenario-preview-${record.id}',
                                          ),
                                          onPressed: () => _pregledScenario(
                                            context,
                                            katalog,
                                            record,
                                          ),
                                          child: const Text('PREGLED'),
                                        ),
                                        TextButton(
                                          key: ValueKey(
                                            'scenario-edit-${record.id}',
                                          ),
                                          onPressed: () =>
                                              _dodajIliIzmeniScenario(
                                                context,
                                                katalog,
                                                record: record,
                                              ),
                                          child: const Text('UREDI'),
                                        ),
                                      ],
                                    ),
                                  ),
                                   ),
                            const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: OutlinedButton.icon(
                                  onPressed: katalog.isEmpty
                                      ? null
                                      : () => _dodajIliIzmeniScenario(
                                          context,
                                          katalog,
                                        ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('DODAJ NOVI SCENARIO'),
                                ),
                              ),
                                   const SizedBox(height: 12),
                                ],
                              ),
                            ),
                           ),
                           */
                            const SizedBox(height: 12),
                            Card(
                              key: const ValueKey('scenario-card-new-scenario'),
                              child: ListTile(
                                title: const Text('NOVI SCENARIO'),
                                subtitle: const Text(
                                  'Kreirajte novu SCENARIO definiciju za buduće PREDMETE.',
                                ),
                                trailing: FilledButton.icon(
                                  onPressed: katalog.isEmpty
                                      ? null
                                      : () => _dodajIliIzmeniScenario(
                                          context,
                                          katalog,
                                        ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('DODAJ NOVI SCENARIO'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _OpenPredmetSelector(
                              predmeti: openPredmeti,
                              selectedPredmetId: selected?.id,
                              onSelected: _selectPredmet,
                              onRefresh: _refreshOpenPredmeti,
                            ),
                            const SizedBox(height: 12),
                            if (selected != null)
                              _SelectedPredmetScenarioView(
                                predmet: selected,
                                db: widget.podesavanjaRepository.db,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OpenPredmetSelector extends StatelessWidget {
  const _OpenPredmetSelector({
    required this.predmeti,
    required this.selectedPredmetId,
    required this.onSelected,
    required this.onRefresh,
  });

  final List<PredmetiData> predmeti;
  final int? selectedPredmetId;
  final ValueChanged<int?> onSelected;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('scenario-open-predmet-selector'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'OTVORENI PREDMETI',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  key: const ValueKey('scenario-open-predmet-refresh'),
                  tooltip: 'OSVEŽI OTVORENE PREDMETE',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Izaberite jedan PREDMET za pregled njegovog SCENARIO stanja.',
            ),
            if (predmeti.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Nema otvorenih PREDMETA.'),
              )
            else
              ...predmeti.map(
                (predmet) => CheckboxListTile(
                  key: ValueKey('scenario-open-predmet-${predmet.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: selectedPredmetId == predmet.id,
                  onChanged: (checked) =>
                      onSelected(checked == true ? predmet.id : null),
                  title: Text(_openPredmetDisplayName(predmet)),
                  subtitle: Text('PREDMET ${predmet.brojPredmeta}'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _openPredmetDisplayName(PredmetiData predmet) {
  final fullName = '${predmet.ime.trim()} ${predmet.prezime.trim()}'.trim();
  return fullName.isEmpty ? 'Bez unetog imena i prezimena' : fullName;
}

class _SelectedPredmetScenarioView extends StatefulWidget {
  const _SelectedPredmetScenarioView({required this.predmet, required this.db});

  final PredmetiData predmet;
  final AppDatabase db;

  @override
  State<_SelectedPredmetScenarioView> createState() =>
      _SelectedPredmetScenarioViewState();
}

class _SelectedPredmetScenarioViewState
    extends State<_SelectedPredmetScenarioView> {
  late Future<_SelectedScenarioData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  @override
  void didUpdateWidget(_SelectedPredmetScenarioView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.predmet.id != widget.predmet.id) {
      _dataFuture = _load();
    }
  }

  Future<_SelectedScenarioData> _load() async {
    // The production MODULI -> SCENARIO hand-off must reconcile before the
    // view reads persisted rows. Earlier E2E tests called the repository
    // directly and therefore bypassed this real runtime boundary.
    await ScenarioRuntimeReconciliationService(
      widget.db,
    ).reconcileOpenPredmet(widget.predmet);
    final snapshotRow =
        await (widget.db.select(widget.db.predmetScenarioSnapshots)
              ..where((item) => item.predmetId.equals(widget.predmet.id)))
            .getSingleOrNull();
    final snapshot = snapshotRow == null
        ? null
        : ScenarioAssignmentSnapshot.fromJsonMap(
            jsonDecode(snapshotRow.snapshotJson) as Map<String, dynamic>,
          );
    final rows = await IriuRepository(widget.db).getIriu(widget.predmet.id);
    final provenance = await (widget.db.select(
      widget.db.iriuProvenance,
    )..where((item) => item.moduleId.equals('scenario'))).get();
    final provenanceById = {
      for (final item in provenance) item.iriuId: item.origin,
    };
    final scenarioOwnedIds = provenanceById.entries
        .where((entry) => entry.value == 'SCENARIO_PAKET')
        .map((entry) => entry.key)
        .toSet();
    final osnovniOwnedIds = provenanceById.entries
        .where((entry) => entry.value == 'OSNOVNI_PAKET')
        .map((entry) => entry.key)
        .toSet();
    final snapshotOsnovni = snapshot?.osnovniPaket.toSet() ?? const <String>{};
    final knownProvenanceIds = provenanceById.keys.toSet();
    return _SelectedScenarioData(
      snapshot: snapshot,
      osnovniRows: rows
          .where(
            (row) =>
                osnovniOwnedIds.contains(row.id) ||
                (!knownProvenanceIds.contains(row.id) &&
                    snapshotOsnovni.contains(row.interniNaziv)),
          )
          .toList(growable: false),
      scenarioRows: rows
          .where((row) => scenarioOwnedIds.contains(row.id))
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SelectedScenarioData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            key: const ValueKey('scenario-selected-predmet-view'),
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(_openPredmetDisplayName(widget.predmet)),
              subtitle: const Text('SCENARIO stanje nije moguće učitati.'),
            ),
          );
        }
        final data = snapshot.data;
        return Card(
          key: const ValueKey('scenario-selected-predmet-view'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.assignment_turned_in_outlined),
                  title: Text(_openPredmetDisplayName(widget.predmet)),
                  subtitle: Text(
                    'PREDMET ${widget.predmet.brojPredmeta} · OTVOREN',
                  ),
                ),
                const Divider(),
                const Text(
                  'PRIMENJENO NA PREDMET',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (data == null)
                  const LinearProgressIndicator()
                else ...[
                  const Text(
                    'OSNOVNI PAKET',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  if (data.osnovniRows.isEmpty)
                    const Text('Nema zabeleženih stavki OSNOVNOG PAKETA.')
                  else
                    for (final row in data.osnovniRows)
                      ListTile(
                        key: ValueKey('scenario-selected-osnovni-${row.id}'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(row.nazivPrikaz),
                        subtitle: Text(row.poslovniStatus),
                      ),
                  const SizedBox(height: 10),
                  const Text(
                    'PRIMENJENI SCENARIO PAKET',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.snapshot == null
                        ? 'SCENARIO paket nije primenjen.'
                        : _scenarioBusinessSummary(data.snapshot!.scenario),
                  ),
                  const SizedBox(height: 4),
                  if (data.scenarioRows.isEmpty)
                    const Text(
                      'Nema dodatnih stavki primenjenog SCENARIO paketa.',
                    )
                  else
                    for (final row in data.scenarioRows)
                      ListTile(
                        key: ValueKey('scenario-selected-item-${row.id}'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(row.nazivPrikaz),
                        subtitle: Text(row.poslovniStatus),
                      ),
                ],
                if (data != null) const SizedBox(height: 10),
                if (data != null)
                  const Text(
                    'Korekcije ovog PREDMETA obavljaju se kroz IRiU stavke.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                /*
                const Text(
                  'TRENUTNI USLOVI I IZVEDENI SCENARIO',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  derived.isComplete
                      ? derived.key!.businessSummary
                      : 'Poslovni uslovi još nisu kompletni.',
                ),
                const SizedBox(height: 14),
                const Text(
                  'PRIMENJENI SCENARIO SNAPSHOT',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  data?.snapshot == null
                      ? 'Nije formiran; prikazan je samo trenutno izvedeni scenario.'
                      : _scenarioBusinessSummary(data!.snapshot!.scenario),
                ),
                if (data?.scenarioRows.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'DODATE STAVKE SCENARIJA',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  for (final row in data!.scenarioRows)
                    ListTile(
                      key: ValueKey('scenario-selected-item-${row.id}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(row.nazivPrikaz),
                      subtitle: Text(row.poslovniStatus),
                    ),
                ],
                if (relevantRecord != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const ValueKey('scenario-selected-edit'),
                    onPressed: () => widget.onEdit(relevantRecord),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('UREDI RELEVANTNI SCENARIO'),
                  ),
                ],
                */
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectedScenarioData {
  const _SelectedScenarioData({
    required this.snapshot,
    required this.osnovniRows,
    required this.scenarioRows,
  });

  final ScenarioAssignmentSnapshot? snapshot;
  final List<IriuData> osnovniRows;
  final List<IriuData> scenarioRows;
}

class _ScenarioLoadingView extends StatelessWidget {
  const _ScenarioLoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Učitavanje SCENARIO modula...'),
      ],
    ),
  );
}

class _ScenarioErrorView extends StatelessWidget {
  const _ScenarioErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'SCENARIO nije moguće učitati.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  error is TimeoutException
                      ? 'Učitavanje je isteklo. Proverite bazu i pokušajte ponovo.'
                      : 'Baza, KATALOG ili scenario definicije nisu spremne.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('PONOVI UČITAVANJE'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ScenarioPolicyTree extends StatefulWidget {
  const _ScenarioPolicyTree({
    required this.definitions,
    required this.katalog,
    required this.onPreview,
    required this.onEdit,
    required this.onAdd,
  });

  final List<ScenarioDefinitionRecord> definitions;
  final List<IriuKatalogConfigData> katalog;
  final ValueChanged<ScenarioDefinitionRecord> onPreview;
  final ValueChanged<ScenarioDefinitionRecord> onEdit;
  final VoidCallback? onAdd;

  @override
  State<_ScenarioPolicyTree> createState() => _ScenarioPolicyTreeState();
}

class _ScenarioPolicyTreeState extends State<_ScenarioPolicyTree> {
  String _cause = 'PRIRODNA';
  String _place = 'STAN';
  String _ceremony = 'SAHRANA';
  String _cemetery = 'GRADSKO';
  String _burial = 'GROB';
  String _opelo = 'NE';
  bool _international = false;
  bool _docek = false;

  bool get _cremation => _ceremony.startsWith('KREMACIJA');

  ScenarioDefinitionRecord? get _selectedRecord {
    final id = [
      'MAP',
      _slug(_cause),
      _docek ? 'INFORMATIVNO' : _slug(_place),
      _slug(_ceremony),
      _cremation ? 'NE_PRIMENJUJE_SE' : _slug(_cemetery),
      _cremation ? 'NE_PRIMENJUJE_SE' : _slug(_burial),
      _slug(_opelo),
      _international ? 'DA' : 'NE',
      _docek ? 'DA' : 'NE',
    ].join('_');
    for (final record in widget.definitions) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedRecord;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'POSTOJEĆI SCENARIJI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pronađite potpunu poslovnu kombinaciju',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final fieldWidth = width >= 720
                        ? (width - 16) / 3
                        : width >= 460
                        ? (width - 8) / 2
                        : width;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _businessFilter(
                          fieldWidth,
                          'UZROK SMRTI',
                          _cause,
                          const [
                            'PRIRODNA',
                            'NASILNA',
                            'ZARAZNA',
                            'NEDEFINISANA',
                          ],
                          (value) => setState(() => _cause = value),
                        ),
                        _businessFilter(
                          fieldWidth,
                          'MESTO SMRTI',
                          _place,
                          const [
                            'STAN',
                            'DOM ZA STARE',
                            'BOLNICA',
                            'PRIVATNA BOLNICA',
                            'ULICA / JAVNO MESTO',
                            'DRUGO',
                          ],
                          (value) => setState(() => _place = value),
                        ),
                        _businessFilter(
                          fieldWidth,
                          'VRSTA CEREMONIJE',
                          _ceremony,
                          const [
                            'SAHRANA',
                            'SAHRANA EKSPRES',
                            'KREMACIJA',
                            'KREMACIJA EKSPRES',
                          ],
                          (value) => setState(() {
                            _ceremony = value;
                            if (_cremation) {
                              _international = false;
                            }
                          }),
                        ),
                        if (!_cremation && !_docek)
                          _businessFilter(
                            fieldWidth,
                            'TIP GROBLJA',
                            _cemetery,
                            const ['GRADSKO', 'LOKALNO'],
                            (value) => setState(() => _cemetery = value),
                          ),
                        if (!_cremation && !_docek)
                          _businessFilter(
                            fieldWidth,
                            'GROBNO MESTO',
                            _burial,
                            const ['GROB', 'GROBNICA'],
                            (value) => setState(() => _burial = value),
                          ),
                        _businessFilter(
                          fieldWidth,
                          'OPELO',
                          _opelo,
                          const ['NE', 'DA'],
                          (value) => setState(() => _opelo = value),
                        ),
                        _businessFilter(
                          fieldWidth,
                          'SAHRANA VAN SRBIJE',
                          _international ? 'DA' : 'NE',
                          const ['NE', 'DA'],
                          (value) => setState(() {
                            _international = value == 'DA';
                            if (_international && _cremation) {
                              _international = false;
                            }
                          }),
                        ),
                        _businessFilter(
                          fieldWidth,
                          'DOČEK POSMRTNIH OSTATAKA',
                          _docek ? 'DA' : 'NE',
                          const ['NE', 'DA'],
                          (value) => setState(() {
                            _docek = value == 'DA';
                            if (_docek) _international = false;
                          }),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (selected == null)
                  const Text('Scenario sa ovim uslovima još nije formiran.')
                else
                  _ScenarioResultCard(
                    record: selected,
                    katalog: widget.katalog,
                    onPreview: widget.onPreview,
                    onEdit: widget.onEdit,
                  ),
              ],
            ),
          ),
        ),
        if (widget.onAdd != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
              label: const Text('DODAJ NOVI SCENARIO'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _businessFilter(
    double width,
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) => SizedBox(
    width: width,
    child: DropdownButtonFormField<String>(
      initialValue: values.contains(value) ? value : values.first,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}

class _ScenarioResultCard extends StatelessWidget {
  const _ScenarioResultCard({
    required this.record,
    required this.katalog,
    required this.onPreview,
    required this.onEdit,
  });

  final ScenarioDefinitionRecord record;
  final List<IriuKatalogConfigData> katalog;
  final ValueChanged<ScenarioDefinitionRecord> onPreview;
  final ValueChanged<ScenarioDefinitionRecord> onEdit;

  @override
  Widget build(BuildContext context) {
    final definition = scenarioDefinitionFromJsonMap({
      'id': record.id,
      'name': record.naziv,
      'condition': jsonDecode(record.conditionJson),
      'consequences': jsonDecode(record.consequencesJson),
    });
    final summary = _scenarioBusinessSummary(definition);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        title: Text(record.id.startsWith('MAP_') ? summary : record.naziv),
        subtitle: Text('${definition.consequences.length} dodatnih stavki'),
        trailing: Wrap(
          spacing: 4,
          children: [
            TextButton(
              key: ValueKey('scenario-preview-${record.id}'),
              onPressed: () => onPreview(record),
              child: const Text('PREGLED'),
            ),
            TextButton(
              key: ValueKey('scenario-edit-${record.id}'),
              onPressed: () => onEdit(record),
              child: const Text('UREDI'),
            ),
          ],
        ),
      ),
    );
  }
}

class PredmetAppliedScenarioCard extends StatelessWidget {
  const PredmetAppliedScenarioCard({
    super.key,
    required this.predmet,
    this.snapshotFuture,
  });

  final PredmetiData predmet;
  final Future<ScenarioAssignmentSnapshot?>? snapshotFuture;

  @override
  Widget build(BuildContext context) {
    final predmetIdentity = predmet.brojPredmeta.trim().isEmpty
        ? predmet.id.toString()
        : predmet.brojPredmeta.trim();
    return FutureBuilder<ScenarioAssignmentSnapshot?>(
      future: snapshotFuture,
      builder: (context, snapshot) {
        final applied = snapshot.data;
        final result = const OwnerScenarioPolicyKernel().evaluate(predmet);
        final summary = applied == null
            ? (result.isComplete
                  ? result.key!.businessSummary
                  : 'Poslovni uslovi još nisu kompletni.')
            : '${_scenarioBusinessSummary(applied.scenario)} · PRIMENJENI SCENARIO';
        return Card(
          key: ValueKey('predmet-applied-scenario-${predmet.id}'),
          child: ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: Text('Scenario za PREDMET $predmetIdentity'),
            subtitle: Text(summary),
          ),
        );
      },
    );
  }
}

String _scenarioBusinessSummary(ScenarioDefinition definition) {
  final values = <ScenarioCriterionField, String>{};
  void collect(ScenarioCondition condition) {
    final criterion = condition.criterion;
    if (criterion != null) {
      values[criterion.field] = switch (criterion.operator) {
        ScenarioCriterionOperator.isTrue => 'DA',
        ScenarioCriterionOperator.isFalse => 'NE',
        _ => criterion.values.join(', '),
      };
    }
    for (final child in condition.children) {
      collect(child);
    }
  }

  collect(definition.condition);
  final ordered = <String?>[
    values[ScenarioCriterionField.uzrokSmrti],
    values[ScenarioCriterionField.mestoSmrti],
    values[ScenarioCriterionField.vrstaCeremonije],
    values[ScenarioCriterionField.tipGroblja],
    values[ScenarioCriterionField.tipGrobnogMesta],
    values[ScenarioCriterionField.opelo] == null
        ? null
        : 'OPELO ${values[ScenarioCriterionField.opelo]}',
    values[ScenarioCriterionField.sahranaVanSrbije] == null
        ? null
        : 'VAN SRBIJE ${values[ScenarioCriterionField.sahranaVanSrbije]}',
    values[ScenarioCriterionField.docekPosmrtnihOstataka] == null
        ? null
        : 'DOČEK ${values[ScenarioCriterionField.docekPosmrtnihOstataka]}',
  ].whereType<String>().where((value) => value.isNotEmpty).toList();
  return ordered.isEmpty ? 'Potpuna poslovna kombinacija' : ordered.join(' · ');
}

/*
class _ScenarioPolicyTree extends StatelessWidget {
    final byId = <String, ScenarioDefinitionRecord>{
      for (final definition in definitions) definition.id: definition,
    };
    final placeRecords = _placeIds
        .map((id) => byId[id])
        .whereType<ScenarioDefinitionRecord>()
        .toList(growable: false);
    final conditionRecords = _conditionIds
        .map((id) => byId[id])
        .whereType<ScenarioDefinitionRecord>()
        .toList(growable: false);
    final packageRecords = _packageIds
        .map((id) => byId[id])
        .whereType<ScenarioDefinitionRecord>()
        .toList(growable: false);
    final known = {..._placeIds, ..._conditionIds, ..._packageIds};
    final otherRecords = definitions
        .where(
          (record) =>
              !known.contains(record.id) && !record.id.startsWith('MAP_'),
        )
        .toList(growable: false);
    final ownerMapRecords = definitions
        .where((record) => record.id.startsWith('MAP_'))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'SCENARIJI PO MESTU SMRTI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (definitions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nema sačuvanih scenarija.'),
          )
        else
          Card(
            key: const ValueKey('scenario-tree-place-root'),
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              initiallyExpanded: true,
              title: const Text('MESTO SMRTI'),
              children: [
                for (final record in placeRecords)
                  _ScenarioPolicyBranch(
                    record: record,
                    katalog: katalog,
                    onPreview: onPreview,
                    onEdit: onEdit,
                  ),
                if (placeRecords.isEmpty)
                  const ListTile(title: Text('Nema definisanih mesta smrti.')),
                if (conditionRecords.isNotEmpty)
                  _ScenarioPolicyGroup(
                    key: const ValueKey('scenario-tree-conditions'),
                    title: 'DODATNI USLOVI',
                    records: conditionRecords,
                    katalog: katalog,
                    onPreview: onPreview,
                    onEdit: onEdit,
                  ),
                if (packageRecords.isNotEmpty)
                  _ScenarioPolicyGroup(
                    key: const ValueKey('scenario-tree-packages'),
                    title: 'DODATNI PAKETI',
                    records: packageRecords,
                    katalog: katalog,
                    onPreview: onPreview,
                    onEdit: onEdit,
                  ),
                if (otherRecords.isNotEmpty)
                  _ScenarioPolicyGroup(
                    title: 'OSTALI DEFINISANI USLOVI',
                    records: otherRecords,
                    katalog: katalog,
                    onPreview: onPreview,
                    onEdit: onEdit,
                  ),
                if (ownerMapRecords.isNotEmpty)
                  _OwnerMapFinder(
                    records: ownerMapRecords,
                    katalog: katalog,
                    onPreview: onPreview,
                    onEdit: onEdit,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('DODAJ NOVI SCENARIO'),
          ),
        ),
      ],
    );
  }
}
*/

class _OwnerMapFinder extends StatefulWidget {
  const _OwnerMapFinder({
    required this.records,
    required this.katalog,
    required this.onPreview,
    required this.onEdit,
  });

  final List<ScenarioDefinitionRecord> records;
  final List<IriuKatalogConfigData> katalog;
  final ValueChanged<ScenarioDefinitionRecord> onPreview;
  final ValueChanged<ScenarioDefinitionRecord> onEdit;

  @override
  State<_OwnerMapFinder> createState() => _OwnerMapFinderState();
}

class _OwnerMapFinderState extends State<_OwnerMapFinder> {
  String _cause = 'PRIRODNA';
  String _place = 'STAN';
  String _ceremony = 'SAHRANA';
  String _cemetery = 'GRADSKO';
  String _burial = 'GROB';
  String _opelo = 'NE';
  bool _international = false;
  bool _docek = false;

  bool get _cremation => _ceremony.startsWith('KREMACIJA');

  ScenarioDefinitionRecord? get _selectedRecord {
    final place = _docek ? 'INFORMATIVNO' : _slug(_place);
    final cemetery = _cremation ? 'NE_PRIMENJUJE_SE' : _slug(_cemetery);
    final burial = _cremation ? 'NE_PRIMENJUJE_SE' : _slug(_burial);
    final id = [
      'MAP',
      _slug(_cause),
      place,
      _slug(_ceremony),
      cemetery,
      burial,
      _slug(_opelo),
      _international ? 'DA' : 'NE',
      _docek ? 'DA' : 'NE',
    ].join('_');
    for (final record in widget.records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final record = _selectedRecord;
    return Card(
      key: const ValueKey('scenario-owner-map-finder'),
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text('PRONAĐI POTPUNU POSLOVNU POLITIKU'),
        subtitle: Text('${widget.records.length} dozvoljenih kombinacija'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final fieldWidth = width >= 720
                  ? (width - 16) / 3
                  : width >= 460
                  ? (width - 8) / 2
                  : width;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filter(
                    width: fieldWidth,
                    label: 'UZROK SMRTI',
                    value: _cause,
                    values: const [
                      'PRIRODNA',
                      'NASILNA',
                      'ZARAZNA',
                      'NEDEFINISANA',
                    ],
                    onChanged: (value) => setState(() => _cause = value),
                  ),
                  _filter(
                    width: fieldWidth,
                    label: 'VRSTA CEREMONIJE',
                    value: _ceremony,
                    values: const [
                      'SAHRANA',
                      'SAHRANA EKSPRES',
                      'KREMACIJA',
                      'KREMACIJA EKSPRES',
                    ],
                    onChanged: (value) => setState(() {
                      _ceremony = value;
                      if (_cremation) {
                        _cemetery = 'GRADSKO';
                        _burial = 'GROB';
                        _international = false;
                      }
                    }),
                  ),
                  _filter(
                    width: fieldWidth,
                    label: 'OPELO',
                    value: _opelo,
                    values: const ['NE', 'DA'],
                    onChanged: (value) => setState(() => _opelo = value),
                  ),
                  _filter(
                    width: fieldWidth,
                    label: 'DOČEK POSMRTNIH OSTATAKA',
                    value: _docek ? 'DA' : 'NE',
                    values: const ['NE', 'DA'],
                    onChanged: (value) => setState(() {
                      _docek = value == 'DA';
                      if (_docek) _international = false;
                    }),
                  ),
                  if (!_docek)
                    _filter(
                      width: fieldWidth,
                      label: 'MESTO SMRTI',
                      value: _place,
                      values: const [
                        'STAN',
                        'DOM ZA STARE',
                        'BOLNICA',
                        'PRIVATNA BOLNICA',
                        'ULICA / JAVNO MESTO',
                        'DRUGO',
                      ],
                      onChanged: (value) => setState(() => _place = value),
                    ),
                  if (!_docek && !_cremation)
                    _filter(
                      width: fieldWidth,
                      label: 'TIP GROBLJA',
                      value: _cemetery,
                      values: const ['GRADSKO', 'LOKALNO'],
                      onChanged: (value) => setState(() => _cemetery = value),
                    ),
                  if (!_docek && !_cremation)
                    _filter(
                      width: fieldWidth,
                      label: 'TIP GROBNOG MESTA',
                      value: _burial,
                      values: const ['GROB', 'GROBNICA'],
                      onChanged: (value) => setState(() => _burial = value),
                    ),
                  if (!_cremation)
                    _filter(
                      width: fieldWidth,
                      label: 'SAHRANA VAN SRBIJE',
                      value: _international ? 'DA' : 'NE',
                      values: const ['NE', 'DA'],
                      onChanged: (value) =>
                          setState(() => _international = value == 'DA'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (record == null)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.error_outline),
              title: Text('Izabrana kombinacija nije dostupna.'),
              subtitle: Text('Proverite uslove prema poslovnoj mapi.'),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(record.naziv),
              subtitle: Text(_scenarioStatusLabel(record)),
              trailing: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () => widget.onPreview(record),
                    child: const Text('PREGLED'),
                  ),
                  FilledButton(
                    onPressed: () => widget.onEdit(record),
                    child: const Text('UREDI'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filter({
    required double width,
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) => SizedBox(
    width: width,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}

String _slug(String value) => value
    .trim()
    .toUpperCase()
    .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

String _scenarioStatusLabel(ScenarioDefinitionRecord record) =>
    record.status == 'PRIMENJEN' ? 'U UPOTREBI' : 'VAN UPOTREBE';

class _ConditionLine {
  const _ConditionLine(this.depth, this.label);

  final int depth;
  final String label;
}

class _ConditionSection {
  const _ConditionSection(this.title, this.lines);

  final String title;
  final List<_ConditionLine> lines;
}

List<_ConditionSection> _conditionSections(ScenarioCondition condition) {
  final place = _conditionLinesWhere(
    condition,
    (criterion) => criterion.field == ScenarioCriterionField.mestoSmrti,
  );
  final exclusions = _conditionLinesWhere(condition, _isExclusion);
  final additional = _conditionLinesWhere(
    condition,
    (criterion) =>
        criterion.field != ScenarioCriterionField.mestoSmrti &&
        !_isExclusion(criterion),
  );
  return [
    if (place.isNotEmpty) _ConditionSection('MESTO SMRTI', place),
    if (additional.isNotEmpty) _ConditionSection('DODATNI USLOVI', additional),
    if (exclusions.isNotEmpty) _ConditionSection('ISKLJUČENJA', exclusions),
  ];
}

bool _isExclusion(ScenarioCriterion criterion) =>
    criterion.operator == ScenarioCriterionOperator.notEquals ||
    criterion.operator == ScenarioCriterionOperator.notInSet ||
    criterion.operator == ScenarioCriterionOperator.isFalse;

List<_ConditionLine> _conditionLinesWhere(
  ScenarioCondition condition,
  bool Function(ScenarioCriterion criterion) include, [
  int depth = 0,
]) {
  if (condition.kind == ScenarioConditionKind.criterion) {
    final criterion = condition.criterion;
    return criterion == null || !include(criterion)
        ? const <_ConditionLine>[]
        : <_ConditionLine>[_ConditionLine(depth, _criterionLabel(criterion))];
  }

  final childLines = <_ConditionLine>[];
  for (final child in condition.children) {
    childLines.addAll(_conditionLinesWhere(child, include, depth + 1));
  }
  if (childLines.isEmpty) return const <_ConditionLine>[];

  final groupLabel = condition.kind == ScenarioConditionKind.all
      ? 'SVE'
      : 'BILO KOJI';
  return [
    if (condition.children.length > 1) _ConditionLine(depth, groupLabel),
    ...childLines,
  ];
}

String _criterionLabel(ScenarioCriterion criterion) {
  final field = _criterionFieldLabel(criterion.field);
  final values = criterion.values.join(', ');
  return switch (criterion.operator) {
    ScenarioCriterionOperator.equals || ScenarioCriterionOperator.isTrue =>
      '$field: ${values.isEmpty ? 'DA' : values}',
    ScenarioCriterionOperator.isFalse || ScenarioCriterionOperator.notEquals =>
      '$field: nije ${values.isEmpty ? 'DA' : values}',
    ScenarioCriterionOperator.inSet => '$field: jedno od $values',
    ScenarioCriterionOperator.notInSet => '$field: nije jedno od $values',
  };
}

String _statusLabel(ScenarioConsequenceAction action) => switch (action) {
  ScenarioConsequenceAction.required => 'AKTIVNO',
  ScenarioConsequenceAction.recommended => 'PREPORUČENO',
  ScenarioConsequenceAction.suppressed => 'NE PRIKAZUJE SE',
};

String _criterionFieldLabel(ScenarioCriterionField field) => switch (field) {
  ScenarioCriterionField.mestoSmrti => 'MESTO SMRTI',
  ScenarioCriterionField.uzrokSmrti => 'UZROK SMRTI',
  ScenarioCriterionField.vrstaCeremonije => 'VRSTA CEREMONIJE',
  ScenarioCriterionField.tipGroblja => 'TIP GROBLJA',
  ScenarioCriterionField.grobnoMesto => 'GROBNO MESTO',
  ScenarioCriterionField.tipGrobnogMesta => 'TIP GROBNOG MESTA',
  ScenarioCriterionField.sahranaVanSrbije => 'SAHRANA VAN SRBIJE',
  ScenarioCriterionField.docekPosmrtnihOstataka => 'DOČEK POSMRTNIH OSTATAKA',
  ScenarioCriterionField.opelo => 'OPELO',
};

String _criterionOperatorLabel(ScenarioCriterionOperator operator) =>
    switch (operator) {
      ScenarioCriterionOperator.equals => '=',
      ScenarioCriterionOperator.notEquals => '≠',
      ScenarioCriterionOperator.inSet => 'jedno od',
      ScenarioCriterionOperator.notInSet => 'nije jedno od',
      ScenarioCriterionOperator.isTrue => '=',
      ScenarioCriterionOperator.isFalse => '≠',
    };

String _catalogLabel(List<IriuKatalogConfigData> katalog, String internalName) {
  for (final item in katalog) {
    if (item.interniNaziv == internalName &&
        item.nazivPrikaz.trim().isNotEmpty) {
      return item.nazivPrikaz;
    }
  }
  return unresolvedIriuCatalogItemLabel;
}

double _dialogWidth(BuildContext context, double maximum) =>
    (MediaQuery.sizeOf(context).width - 48).clamp(280.0, maximum).toDouble();

class _PackageDialog extends StatefulWidget {
  const _PackageDialog({
    required this.title,
    required this.katalog,
    required this.selected,
  });

  final String title;
  final List<IriuKatalogConfigData> katalog;
  final Set<String> selected;

  @override
  State<_PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<_PackageDialog> {
  late final Set<String> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: _dialogWidth(context, 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.title == 'OSNOVNI PAKET') ...[
                const Text(
                  'Izmene OSNOVNOG PAKETA primenjuju se samo na nove PREDMETE. Postojeći PREDMETI ostaju nepromenjeni.',
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'STAVKE U OSNOVNOM PAKETU',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              ...widget.katalog
                  .where(
                    (item) =>
                        item.vidljiv && _selected.contains(item.interniNaziv),
                  )
                  .map(
                    (item) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: true,
                      title: Text(item.nazivPrikaz),
                      onChanged: (value) => setState(() {
                        if (value != true) _selected.remove(item.interniNaziv);
                      }),
                    ),
                  ),
              const Divider(),
              const Text(
                'DOSTUPNE KATALOG STAVKE',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              ...widget.katalog
                  .where(
                    (item) =>
                        item.vidljiv && !_selected.contains(item.interniNaziv),
                  )
                  .map(
                    (item) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: false,
                      title: Text(item.nazivPrikaz),
                      onChanged: (value) => setState(() {
                        if (value == true) _selected.add(item.interniNaziv);
                      }),
                    ),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('SAČUVAJ'),
        ),
      ],
    );
  }
}

class _ScenarioDraft {
  const _ScenarioDraft({
    required this.id,
    required this.naziv,
    required this.version,
    required this.condition,
    required this.consequences,
    required this.jePodrazumevani,
    required this.description,
    required this.activate,
  });

  final String id;
  final String naziv;
  final int version;
  final ScenarioCondition condition;
  final List<ScenarioConsequence> consequences;
  final bool jePodrazumevani;
  final String description;
  final bool activate;
}

class _ScenarioDialog extends StatefulWidget {
  const _ScenarioDialog({
    required this.katalog,
    required this.baseCategoryIds,
    this.existing,
    required this.existingVersion,
    required this.existingDefault,
  });

  final List<IriuKatalogConfigData> katalog;
  final Set<String> baseCategoryIds;
  final ScenarioDefinition? existing;
  final int existingVersion;
  final bool existingDefault;

  @override
  State<_ScenarioDialog> createState() => _ScenarioDialogState();
}

class _ScenarioDialogState extends State<_ScenarioDialog> {
  late ScenarioCondition _condition;
  late Map<String, ScenarioConsequence> _consequences;
  String? _error;

  @override
  void initState() {
    super.initState();
    _condition =
        widget.existing?.condition ??
        const ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: [''],
          ),
        );
    _consequences = {
      for (final item
          in widget.existing?.consequences ?? const <ScenarioConsequence>[])
        if (item.action != ScenarioConsequenceAction.suppressed)
          item.katalogCategoryInternalName: item,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.katalog
        .where(
          (item) =>
              item.vidljiv && _consequences.containsKey(item.interniNaziv),
        )
        .toList(growable: false);
    final available = widget.katalog
        .where(
          (item) =>
              item.vidljiv &&
              !widget.baseCategoryIds.contains(item.interniNaziv) &&
              !_consequences.containsKey(item.interniNaziv),
        )
        .toList(growable: false);
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'DODAJ NOVI SCENARIO' : 'UREDI SCENARIO',
      ),
      content: SizedBox(
        width: _dialogWidth(context, 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.existing == null)
                const _WizardProgress()
              else
                Text(
                  widget.existing!.id.startsWith('MAP_')
                      ? _scenarioBusinessSummary(widget.existing!)
                      : widget.existing!.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 12),
              Text(
                widget.existing == null ? 'USLOVI' : 'USLOVI PRIMENE',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (widget.existing == null)
                _BusinessConditionPicker(
                  onChanged: (condition) =>
                      setState(() => _condition = condition),
                )
              else
                _BusinessConditionSummary(condition: _condition),
              const SizedBox(height: 16),
              const Text(
                'DODATNE STAVKE SCENARIJA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'OSNOVNI PAKET se primenjuje automatski iz SCENARIO politike.',
              ),
              if (selected.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Nema izabranih stavki.'),
                )
              else
                ...selected.map(
                  (item) => CheckboxListTile(
                    key: ValueKey('scenario-selected-${item.interniNaziv}'),
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    title: Text(item.nazivPrikaz),
                    subtitle: Text(
                      _statusLabel(_consequences[item.interniNaziv]!.action),
                    ),
                    secondary: TextButton(
                      onPressed: () => _editConsequenceBusiness(
                        item.interniNaziv,
                        item.nazivPrikaz,
                      ),
                      child: const Text('UREDI'),
                    ),
                    onChanged: (_) =>
                        setState(() => _consequences.remove(item.interniNaziv)),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'DOSTUPNE STAVKE',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              ...available.map(
                (item) => CheckboxListTile(
                  key: ValueKey('scenario-available-${item.interniNaziv}'),
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text(item.nazivPrikaz),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _consequences[item.interniNaziv] = ScenarioConsequence(
                        katalogCategoryInternalName: item.interniNaziv,
                        action: ScenarioConsequenceAction.required,
                        order: _consequences.length * 10,
                        reason: '',
                      );
                    }
                  }),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            widget.existing == null
                ? 'SAČUVAJ NOVI SCENARIO'
                : 'SAČUVAJ IZMENE',
          ),
        ),
      ],
    );
  }

  Future<void> _editConsequenceBusiness(String id, String label) async {
    final current = _consequences[id]!;
    var action = current.action == ScenarioConsequenceAction.recommended
        ? ScenarioConsequenceAction.recommended
        : ScenarioConsequenceAction.required;
    final warning = TextEditingController(text: current.warning);
    final reason = TextEditingController(text: current.reason);
    final result = await showDialog<ScenarioConsequence>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: _dialogWidth(context, 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _FieldCaption('STATUS'),
                DropdownButtonFormField<ScenarioConsequenceAction>(
                  initialValue: action,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      const [
                            ScenarioConsequenceAction.required,
                            ScenarioConsequenceAction.recommended,
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_statusLabel(value)),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setDialogState(() => action = value!),
                ),
                const SizedBox(height: 12),
                const _FieldCaption('RAZLOG'),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                const _FieldCaption('UPOZORENJE'),
                TextField(
                  controller: warning,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ODUSTANI'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                ScenarioConsequence(
                  katalogCategoryInternalName: id,
                  action: action,
                  order: current.order,
                  section: current.section,
                  provider: current.provider,
                  warning: warning.text.trim(),
                  reason: reason.text.trim(),
                  financiallyIncluded: current.financiallyIncluded,
                ),
              ),
              child: const Text('SAČUVAJ'),
            ),
          ],
        ),
      ),
    );
    warning.dispose();
    reason.dispose();
    if (result != null) setState(() => _consequences[id] = result);
  }

  void _save() {
    final existing = widget.existing;
    final identity = _generatedScenarioIdentity(_condition);
    final name = existing?.name ?? identity.$2;
    final id = existing?.id ?? identity.$1;
    if (id.isEmpty || name.isEmpty || !_conditionIsComplete(_condition)) {
      setState(() => _error = 'Unesite uslov i vrednost.');
      return;
    }
    Navigator.pop(
      context,
      _ScenarioDraft(
        id: id,
        naziv: name,
        version: widget.existingVersion,
        condition: _condition,
        consequences: _consequences.values.toList(growable: false),
        jePodrazumevani: widget.existingDefault,
        description: existing?.description ?? '',
        activate: true,
      ),
    );
  }
}

class _WizardProgress extends StatelessWidget {
  const _WizardProgress();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      Chip(label: Text('1 USLOVI')),
      Chip(label: Text('2 STAVKE')),
      Chip(label: Text('3 PREGLED')),
      Chip(label: Text('4 ČUVANJE')),
    ],
  );
}

(String, String) _generatedScenarioIdentity(ScenarioCondition condition) {
  final values = <String>[];
  void collect(ScenarioCondition item) {
    final criterion = item.criterion;
    if (criterion != null) values.addAll(criterion.values);
    for (final child in item.children) {
      collect(child);
    }
  }

  collect(condition);
  final suffix = values
      .join('_')
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9ČĆŽŠĐ]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final safe = suffix.isEmpty ? 'USLOVI' : suffix;
  return ('CUSTOM_$safe', 'SCENARIO — $safe');
}

class _BusinessConditionSummary extends StatelessWidget {
  const _BusinessConditionSummary({required this.condition});

  final ScenarioCondition condition;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 8),
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'IZABRANI POSLOVNI USLOVI',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ..._conditionSections(condition).expand(
            (section) => <Widget>[
              Text(
                section.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              ...section.lines.map(
                (line) => Padding(
                  padding: EdgeInsets.only(left: line.depth * 12.0, top: 3),
                  child: Text(line.label),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    ),
  );
}

class _BusinessConditionPicker extends StatefulWidget {
  const _BusinessConditionPicker({required this.onChanged});

  final ValueChanged<ScenarioCondition> onChanged;

  @override
  State<_BusinessConditionPicker> createState() =>
      _BusinessConditionPickerState();
}

class _BusinessConditionPickerState extends State<_BusinessConditionPicker> {
  String _cause = 'PRIRODNA';
  String _place = 'STAN';
  String _ceremony = 'SAHRANA';
  String _cemetery = 'GRADSKO';
  String _burial = 'GROB';
  String _opelo = 'NE';
  bool _international = false;
  bool _docek = false;

  bool get _cremation => _ceremony.startsWith('KREMACIJA');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _emit() {
    final criteria = <ScenarioCondition>[
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.uzrokSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: [_cause],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.vrstaCeremonije,
          operator: ScenarioCriterionOperator.equals,
          values: [_ceremony],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.opelo,
          operator: ScenarioCriterionOperator.equals,
          values: [_opelo],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.sahranaVanSrbije,
          operator: _international
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.docekPosmrtnihOstataka,
          operator: _docek
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
    ];
    if (!_docek) {
      criteria.add(
        ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: [_place],
          ),
        ),
      );
      if (!_cremation) {
        criteria
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGroblja,
                operator: ScenarioCriterionOperator.equals,
                values: [_cemetery],
              ),
            ),
          )
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGrobnogMesta,
                operator: ScenarioCriterionOperator.equals,
                values: [_burial],
              ),
            ),
          );
      }
    }
    widget.onChanged(ScenarioCondition.all(criteria));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final fieldWidth = width >= 720
          ? (width - 16) / 3
          : width >= 460
          ? (width - 8) / 2
          : width;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _businessField(
            width: fieldWidth,
            label: 'UZROK SMRTI',
            value: _cause,
            values: const ['PRIRODNA', 'NASILNA', 'ZARAZNA', 'NEDEFINISANA'],
            onChanged: (value) {
              setState(() => _cause = value);
              _emit();
            },
          ),
          _businessField(
            width: fieldWidth,
            label: 'VRSTA CEREMONIJE',
            value: _ceremony,
            values: const [
              'SAHRANA',
              'SAHRANA EKSPRES',
              'KREMACIJA',
              'KREMACIJA EKSPRES',
            ],
            onChanged: (value) {
              setState(() {
                _ceremony = value;
                if (_cremation) _international = false;
              });
              _emit();
            },
          ),
          _businessField(
            width: fieldWidth,
            label: 'OPELO',
            value: _opelo,
            values: const ['NE', 'DA'],
            onChanged: (value) {
              setState(() => _opelo = value);
              _emit();
            },
          ),
          _businessField(
            width: fieldWidth,
            label: 'DOČEK POSMRTNIH OSTATAKA',
            value: _docek ? 'DA' : 'NE',
            values: const ['NE', 'DA'],
            onChanged: (value) {
              setState(() {
                _docek = value == 'DA';
                if (_docek) _international = false;
              });
              _emit();
            },
          ),
          if (!_docek)
            _businessField(
              width: fieldWidth,
              label: 'MESTO SMRTI',
              value: _place,
              values: const [
                'STAN',
                'DOM ZA STARE',
                'BOLNICA',
                'PRIVATNA BOLNICA',
                'ULICA / JAVNO MESTO',
                'DRUGO',
              ],
              onChanged: (value) {
                setState(() => _place = value);
                _emit();
              },
            ),
          if (!_docek && !_cremation)
            _businessField(
              width: fieldWidth,
              label: 'TIP GROBLJA',
              value: _cemetery,
              values: const ['GRADSKO', 'LOKALNO'],
              onChanged: (value) {
                setState(() => _cemetery = value);
                _emit();
              },
            ),
          if (!_docek && !_cremation)
            _businessField(
              width: fieldWidth,
              label: 'TIP GROBNOG MESTA',
              value: _burial,
              values: const ['GROB', 'GROBNICA'],
              onChanged: (value) {
                setState(() => _burial = value);
                _emit();
              },
            ),
          if (!_cremation)
            _businessField(
              width: fieldWidth,
              label: 'SAHRANA VAN SRBIJE',
              value: _international ? 'DA' : 'NE',
              values: const ['NE', 'DA'],
              onChanged: (value) {
                setState(() => _international = value == 'DA');
                _emit();
              },
            ),
        ],
      );
    },
  );
}

Widget _businessField({
  required double width,
  required String label,
  required String value,
  required List<String> values,
  required ValueChanged<String> onChanged,
}) => SizedBox(
  width: width,
  child: DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    items: values
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(growable: false),
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
  ),
);

// Retained only to read/maintain legacy serialized conditions; new UI uses
// the business-condition picker above and never exposes this editor.
// ignore: unused_element
class _ConditionHierarchyEditor extends StatelessWidget {
  const _ConditionHierarchyEditor({
    required this.condition,
    required this.onChanged,
  });

  final ScenarioCondition condition;
  final ValueChanged<ScenarioCondition> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: _buildNode(
      context,
      condition,
      depth: 0,
      isRoot: true,
      onChanged: onChanged,
    ),
  );

  Widget _buildNode(
    BuildContext context,
    ScenarioCondition node, {
    required int depth,
    required bool isRoot,
    required ValueChanged<ScenarioCondition> onChanged,
    VoidCallback? onRemove,
  }) {
    if (node.kind == ScenarioConditionKind.criterion) {
      final criterion = node.criterion;
      if (criterion == null) return const SizedBox.shrink();
      return _HierarchyCard(
        depth: depth,
        role: _conditionRole(depth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _criterionLabel(criterion),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final edited = await _editCriterion(
                      context,
                      criterion,
                      title: 'UREDI ${_conditionRole(depth)}',
                    );
                    if (edited != null) {
                      onChanged(ScenarioCondition.criterion(edited));
                    }
                  },
                  child: const Text('UREDI'),
                ),
                if (!isRoot && onRemove != null)
                  IconButton(
                    tooltip: 'Ukloni uslov',
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _addChildCriterion(context, node, onChanged),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('DODAJ NIŽI USLOV'),
              ),
            ),
          ],
        ),
      );
    }

    final children = node.children;
    return _HierarchyCard(
      depth: depth,
      role: _conditionRole(depth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _FieldCaption('ODNOS U GRUPI'),
              const SizedBox(width: 12),
              DropdownButton<ScenarioConditionKind>(
                value: node.kind,
                items: const [
                  DropdownMenuItem(
                    value: ScenarioConditionKind.all,
                    child: Text('SVE'),
                  ),
                  DropdownMenuItem(
                    value: ScenarioConditionKind.any,
                    child: Text('BILO KOJI'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null || value == node.kind) return;
                  onChanged(
                    value == ScenarioConditionKind.all
                        ? ScenarioCondition.all(children)
                        : ScenarioCondition.any(children),
                  );
                },
              ),
              const Spacer(),
              if (!isRoot && onRemove != null)
                IconButton(
                  tooltip: 'Ukloni grupu',
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
            ],
          ),
          if (children.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Nema definisanih poduslova.'),
            )
          else
            for (var index = 0; index < children.length; index++)
              _buildNode(
                context,
                children[index],
                depth: depth + 1,
                isRoot: false,
                onChanged: (updated) {
                  final next = [...children]..[index] = updated;
                  onChanged(
                    node.kind == ScenarioConditionKind.all
                        ? ScenarioCondition.all(next)
                        : ScenarioCondition.any(next),
                  );
                },
                onRemove: () {
                  final next = [...children]..removeAt(index);
                  if (next.isEmpty) {
                    onRemove?.call();
                  } else if (next.length == 1 && !isRoot) {
                    onChanged(next.single);
                  } else {
                    onChanged(
                      node.kind == ScenarioConditionKind.all
                          ? ScenarioCondition.all(next)
                          : ScenarioCondition.any(next),
                    );
                  }
                },
              ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _addChildCriterion(context, node, onChanged),
              icon: const Icon(Icons.add),
              label: const Text('DODAJ NIŽI USLOV'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addChildCriterion(
    BuildContext context,
    ScenarioCondition parent,
    ValueChanged<ScenarioCondition> onChanged,
  ) async {
    final criterion = await _editCriterion(
      context,
      const ScenarioCriterion(
        field: ScenarioCriterionField.mestoSmrti,
        operator: ScenarioCriterionOperator.equals,
      ),
      title: 'DODAJ NIŽI USLOV',
    );
    if (criterion == null) return;
    final child = ScenarioCondition.criterion(criterion);
    if (parent.kind == ScenarioConditionKind.criterion) {
      onChanged(ScenarioCondition.all([parent, child]));
    } else {
      final children = [...parent.children, child];
      onChanged(
        parent.kind == ScenarioConditionKind.all
            ? ScenarioCondition.all(children)
            : ScenarioCondition.any(children),
      );
    }
  }

  Future<ScenarioCriterion?> _editCriterion(
    BuildContext context,
    ScenarioCriterion current, {
    required String title,
  }) => showDialog<ScenarioCriterion>(
    context: context,
    builder: (_) => _CriterionDialog(initial: current, title: title),
  );
}

class _HierarchyCard extends StatelessWidget {
  const _HierarchyCard({
    required this.depth,
    required this.role,
    required this.child,
  });

  final int depth;
  final String role;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.only(left: depth * 12.0, bottom: 8),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            role,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    ),
  );
}

String _conditionRole(int depth) => switch (depth) {
  0 => 'VIŠI USLOV',
  1 => 'USLOV',
  _ => 'NIŽI USLOV',
};

bool _conditionIsComplete(ScenarioCondition condition) {
  if (condition.kind == ScenarioConditionKind.criterion) {
    final criterion = condition.criterion;
    if (criterion == null) return false;
    final requiresValues =
        criterion.operator != ScenarioCriterionOperator.isTrue &&
        criterion.operator != ScenarioCriterionOperator.isFalse;
    return !requiresValues ||
        criterion.values.any((value) => value.trim().isNotEmpty);
  }
  return condition.children.isNotEmpty &&
      condition.children.every(_conditionIsComplete);
}

// Legacy renderer retained for serialized compatibility; the hierarchy editor above is authoritative.
// ignore: unused_element
class _ConditionTreeEditor extends StatelessWidget {
  const _ConditionTreeEditor({
    required this.condition,
    required this.onChanged,
  });

  final ScenarioCondition condition;
  final ValueChanged<ScenarioCondition> onChanged;

  @override
  Widget build(BuildContext context) => _buildNode(context, condition, 0);

  Widget _buildNode(BuildContext context, ScenarioCondition node, int depth) {
    if (node.kind == ScenarioConditionKind.criterion) {
      final criterion = node.criterion;
      if (criterion == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(left: depth * 12.0, top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(_criterionLabel(criterion))),
            TextButton(
              onPressed: () async {
                final edited = await _editCriterion(context, criterion);
                if (edited != null) {
                  onChanged(ScenarioCondition.criterion(edited));
                }
              },
              child: const Text('UREDI'),
            ),
          ],
        ),
      );
    }

    final title = node.kind == ScenarioConditionKind.all ? 'SVE' : 'BILO KOJI';
    return Padding(
      padding: EdgeInsets.only(left: depth * 12.0, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          for (var index = 0; index < node.children.length; index++)
            _ConditionTreeEditor(
              condition: node.children[index],
              onChanged: (updated) {
                final children = [...node.children];
                children[index] = updated;
                onChanged(
                  node.kind == ScenarioConditionKind.all
                      ? ScenarioCondition.all(children)
                      : ScenarioCondition.any(children),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<ScenarioCriterion?> _editCriterion(
    BuildContext context,
    ScenarioCriterion current,
  ) {
    return showDialog<ScenarioCriterion>(
      context: context,
      builder: (_) => _CriterionDialog(initial: current),
    );
  }
}

// Legacy field renderer retained for serialized compatibility; the criterion dialog above is authoritative.
// ignore: unused_element
class _CriterionEditorFields extends StatelessWidget {
  const _CriterionEditorFields({
    required this.field,
    required this.operator,
    required this.valuesController,
    required this.onFieldChanged,
    required this.onOperatorChanged,
  });

  final ScenarioCriterionField field;
  final ScenarioCriterionOperator operator;
  final TextEditingController valuesController;
  final ValueChanged<ScenarioCriterionField> onFieldChanged;
  final ValueChanged<ScenarioCriterionOperator> onOperatorChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _FieldCaption('USLOV'),
      DropdownButtonFormField<ScenarioCriterionField>(
        initialValue: field,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Izaberite uslov',
        ),
        items: ScenarioCriterionField.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_criterionFieldLabel(value)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onFieldChanged(value);
        },
      ),
      const SizedBox(height: 12),
      const _FieldCaption('ODNOS'),
      DropdownButtonFormField<ScenarioCriterionOperator>(
        initialValue: operator,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Izaberite odnos',
        ),
        items: ScenarioCriterionOperator.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_criterionOperatorLabel(value)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onOperatorChanged(value);
        },
      ),
      const SizedBox(height: 12),
      const _FieldCaption('VREDNOST'),
      TextField(
        controller: valuesController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Unesite jednu ili više vrednosti',
        ),
      ),
    ],
  );
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _CriterionDialog extends StatefulWidget {
  const _CriterionDialog({required this.initial, this.title = 'USLOV'});

  final ScenarioCriterion initial;
  final String title;

  @override
  State<_CriterionDialog> createState() => _CriterionDialogState();
}

class _CriterionDialogState extends State<_CriterionDialog> {
  late final TextEditingController _values;
  late ScenarioCriterionField _field;
  late ScenarioCriterionOperator _operator;

  @override
  void initState() {
    super.initState();
    _values = TextEditingController(text: widget.initial.values.join(', '));
    _field = widget.initial.field;
    _operator = widget.initial.operator;
  }

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: _dialogWidth(context, 440),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _FieldCaption('USLOV'),
            DropdownButtonFormField<ScenarioCriterionField>(
              initialValue: _field,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Izaberite uslov',
              ),
              items: ScenarioCriterionField.values
                  .map(
                    (field) => DropdownMenuItem(
                      value: field,
                      child: Text(_criterionFieldLabel(field)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _field = value!),
            ),
            const SizedBox(height: 12),
            const _FieldCaption('ODNOS'),
            DropdownButtonFormField<ScenarioCriterionOperator>(
              initialValue: _operator,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Izaberite odnos',
              ),
              items: ScenarioCriterionOperator.values
                  .map(
                    (operator) => DropdownMenuItem(
                      value: operator,
                      child: Text(_criterionOperatorLabel(operator)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _operator = value!),
            ),
            const SizedBox(height: 12),
            const _FieldCaption('VREDNOST'),
            TextField(
              controller: _values,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Unesite jednu ili više vrednosti',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ODUSTANI'),
      ),
      FilledButton(
        onPressed: () {
          final values = _values.text
              .split(',')
              .map((value) => value.trim().toUpperCase())
              .where((value) => value.isNotEmpty)
              .toList(growable: false);
          final requiresValues =
              _operator != ScenarioCriterionOperator.isTrue &&
              _operator != ScenarioCriterionOperator.isFalse;
          if (requiresValues && values.isEmpty) return;
          Navigator.pop(
            context,
            ScenarioCriterion(
              field: _field,
              operator: _operator,
              values: values,
            ),
          );
        },
        child: const Text('SAČUVAJ'),
      ),
    ],
  );
}

// ignore: unused_element
ScenarioCriterion? _findCriterion(ScenarioCondition? condition) {
  if (condition == null) return null;
  if (condition.kind == ScenarioConditionKind.criterion) {
    return condition.criterion;
  }
  for (final child in condition.children) {
    final found = _findCriterion(child);
    if (found != null) return found;
  }
  return null;
}
