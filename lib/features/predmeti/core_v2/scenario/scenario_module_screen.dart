import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../podesavanja/data/podesavanja_repository.dart';
import 'scenario_contract.dart';
import 'scenario_module_repository.dart';

/// User-facing editor for the SCENARIO module.
class ScenarioModuleScreen extends StatefulWidget {
  const ScenarioModuleScreen({super.key, required this.podesavanjaRepository});

  final PodesavanjaRepository podesavanjaRepository;

  @override
  State<ScenarioModuleScreen> createState() => _ScenarioModuleScreenState();
}

class _ScenarioModuleScreenState extends State<ScenarioModuleScreen> {
  late final ScenarioModuleRepository _repository;
  late final Future<ScenarioModule> _moduleFuture;
  late Future<List<IriuKatalogConfigData>> _katalogFuture;
  late Future<List<ScenarioDefinitionRecord>> _definitionsFuture;
  ScenarioModule? _currentModule;

  @override
  void initState() {
    super.initState();
    _repository = ScenarioModuleRepository(widget.podesavanjaRepository.db);
    _moduleFuture = _repository.ensureModuleAndDefaults();
    _katalogFuture = widget.podesavanjaRepository.getKatalogVidljive();
    _definitionsFuture = _moduleFuture.then(
      (_) => _repository.getDefinitions(),
    );
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
    _currentModule = await _repository.ensureModule();
    if (!context.mounted) return;
    _katalogFuture = widget.podesavanjaRepository.getKatalogVidljive();
    setState(() {});
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
    _definitionsFuture = _repository.getDefinitions();
    setState(() {});
  }

  Future<void> _pregledScenario(
    BuildContext context,
    List<IriuKatalogConfigData> katalog,
    ScenarioDefinitionRecord record,
  ) async {
    final definition = _repository.definitionFromRecord(record);
    final consequences = definition.consequences
        .where((item) => item.action != ScenarioConsequenceAction.suppressed)
        .toList(growable: false);
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
            Expanded(child: Text(definition.name)),
            Chip(
              label: Text(
                record.status == 'PRIMENJEN' ? 'U UPOTREBI' : 'VAN UPOTREBE',
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'USLOV',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                ..._conditionLines(definition.condition).map(
                  (line) => Padding(
                    padding: EdgeInsets.only(left: line.depth * 16.0, top: 2),
                    child: Text(line.label),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'STAVKE',
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
          if (!moduleSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return FutureBuilder<List<IriuKatalogConfigData>>(
            future: _katalogFuture,
            builder: (context, katalogSnapshot) {
              final katalog = katalogSnapshot.data ?? const [];
              return FutureBuilder<List<ScenarioDefinitionRecord>>(
                future: _definitionsFuture,
                builder: (context, definitionSnapshot) {
                  final definitions = definitionSnapshot.data ?? const [];
                  final module = _currentModule ?? moduleSnapshot.data!;
                  final osnovni = _repository.readOsnovniPaket(module);
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Card(
                        key: ValueKey('scenario-module-description'),
                        child: ListTile(
                          title: Text(
                            'Modul SCENARIO uređuje listu osnovnih i dodatnih stavki robe i usluga za automatski pregled i obračun prema mestu smrti i drugim uslovima.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                : () => _izmeniPaket(context, module, katalog),
                            child: const Text('UREDI'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'SCENARIJI',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              if (definitions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Nema sačuvanih scenarija.'),
                                )
                              else
                                ...definitions.map(
                                  (record) => ListTile(
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
                                          onPressed: () => _pregledScenario(
                                            context,
                                            katalog,
                                            record,
                                          ),
                                          child: const Text('PREGLED'),
                                        ),
                                        TextButton(
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
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _ConditionLine {
  const _ConditionLine(this.depth, this.label);

  final int depth;
  final String label;
}

List<_ConditionLine> _conditionLines(
  ScenarioCondition condition, [
  int depth = 0,
]) {
  switch (condition.kind) {
    case ScenarioConditionKind.criterion:
      final criterion = condition.criterion;
      return criterion == null
          ? const <_ConditionLine>[]
          : <_ConditionLine>[_ConditionLine(depth, _criterionLabel(criterion))];
    case ScenarioConditionKind.all:
      return <_ConditionLine>[
        if (condition.children.length > 1) _ConditionLine(depth, 'SVE'),
        for (final child in condition.children)
          ..._conditionLines(child, depth + 1),
      ];
    case ScenarioConditionKind.any:
      return <_ConditionLine>[
        if (condition.children.length > 1) _ConditionLine(depth, 'BILO KOJI'),
        for (final child in condition.children)
          ..._conditionLines(child, depth + 1),
      ];
  }
}

String _criterionLabel(ScenarioCriterion criterion) {
  final field = _criterionFieldLabel(criterion.field);
  final operator = _criterionOperatorLabel(criterion.operator);
  final values = criterion.values.join(', ');
  return '$field $operator${values.isEmpty ? '' : ': $values'}';
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
  return 'Dodatna stavka';
}

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
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: widget.katalog
                .where((item) => item.vidljiv)
                .map(
                  (item) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selected.contains(item.interniNaziv),
                    title: Text(item.nazivPrikaz),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        _selected.add(item.interniNaziv);
                      } else {
                        _selected.remove(item.interniNaziv);
                      }
                    }),
                  ),
                )
                .toList(),
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
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _valuesController;
  late ScenarioCriterionField _field;
  late ScenarioCriterionOperator _operator;
  ScenarioCondition? _editableCompoundCondition;
  late Map<String, ScenarioConsequence> _consequences;
  String? _error;

  @override
  void initState() {
    super.initState();
    final criterion = _findCriterion(widget.existing?.condition);
    _editableCompoundCondition =
        widget.existing?.condition != null &&
            widget.existing!.condition.kind != ScenarioConditionKind.criterion
        ? widget.existing!.condition
        : null;
    _idController = TextEditingController(text: widget.existing?.id ?? '');
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _valuesController = TextEditingController(
      text: criterion?.values.join(', ') ?? '',
    );
    _field = criterion?.field ?? ScenarioCriterionField.mestoSmrti;
    _operator = criterion?.operator ?? ScenarioCriterionOperator.equals;
    _consequences = {
      for (final item
          in widget.existing?.consequences ?? const <ScenarioConsequence>[])
        if (item.action != ScenarioConsequenceAction.suppressed)
          item.katalogCategoryInternalName: item,
    };
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _valuesController.dispose();
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
      title: Text(widget.existing == null ? 'NOVI SCENARIO' : 'UREDI SCENARIO'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.existing == null) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'NAZIV'),
                ),
                const SizedBox(height: 8),
              ] else
                Text(
                  widget.existing!.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 12),
              const Text(
                'USLOV',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_editableCompoundCondition != null)
                _ConditionTreeEditor(
                  condition: _editableCompoundCondition!,
                  onChanged: (condition) =>
                      setState(() => _editableCompoundCondition = condition),
                )
              else ...[
                DropdownButtonFormField<ScenarioCriterionField>(
                  initialValue: _field,
                  decoration: const InputDecoration(labelText: 'USLOV'),
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
                DropdownButtonFormField<ScenarioCriterionOperator>(
                  initialValue: _operator,
                  decoration: const InputDecoration(labelText: 'OPERATOR'),
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
                TextField(
                  controller: _valuesController,
                  decoration: const InputDecoration(labelText: 'VREDNOST'),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'STAVKE SCENARIJA',
                style: TextStyle(fontWeight: FontWeight.w700),
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
        FilledButton(onPressed: _save, child: const Text('SAČUVAJ IZMENE')),
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
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ScenarioConsequenceAction>(
                  initialValue: action,
                  decoration: const InputDecoration(labelText: 'STATUS'),
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
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(labelText: 'RAZLOG'),
                ),
                TextField(
                  controller: warning,
                  decoration: const InputDecoration(labelText: 'UPOZORENJE'),
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
    final name = existing?.name ?? _nameController.text.trim();
    final id =
        existing?.id ??
        (_idController.text.trim().isNotEmpty
            ? _idController.text.trim()
            : name
                  .toUpperCase()
                  .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
                  .replaceAll(RegExp(r'^_+|_+$'), ''));
    final values = _valuesController.text
        .split(',')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final requiresValues =
        _operator != ScenarioCriterionOperator.isTrue &&
        _operator != ScenarioCriterionOperator.isFalse;
    if (id.isEmpty || name.isEmpty || (requiresValues && values.isEmpty)) {
      setState(() => _error = 'Unesite uslov i vrednost.');
      return;
    }
    Navigator.pop(
      context,
      _ScenarioDraft(
        id: id,
        naziv: name,
        version: widget.existingVersion,
        condition:
            _editableCompoundCondition ??
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: _field,
                operator: _operator,
                values: values,
              ),
            ),
        consequences: _consequences.values.toList(growable: false),
        jePodrazumevani: widget.existingDefault,
        description: existing?.description ?? '',
        activate: true,
      ),
    );
  }
}

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

class _CriterionDialog extends StatefulWidget {
  const _CriterionDialog({required this.initial});

  final ScenarioCriterion initial;

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
    title: const Text('USLOV'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<ScenarioCriterionField>(
          initialValue: _field,
          decoration: const InputDecoration(labelText: 'POLJE'),
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
        DropdownButtonFormField<ScenarioCriterionOperator>(
          initialValue: _operator,
          decoration: const InputDecoration(labelText: 'OPERATOR'),
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
        TextField(
          controller: _values,
          decoration: const InputDecoration(labelText: 'VREDNOST'),
        ),
      ],
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
