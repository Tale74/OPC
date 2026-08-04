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
          width: _dialogWidth(context, 640),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'POSLOVNA HIJERARHIJA',
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
                              const SizedBox(height: 8),
                              _ScenarioPolicyTree(
                                definitions: definitions,
                                katalog: katalog,
                                onPreview: (record) =>
                                    _pregledScenario(context, katalog, record),
                                onEdit: (record) => _dodajIliIzmeniScenario(
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
                              /*
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
*/
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

class _ScenarioPolicyTree extends StatelessWidget {
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

  static const _placeIds = <String>[
    'STAN',
    'DOM_ZA_STARE',
    'PRIVATNA_BOLNICA',
    'DRUGO',
    'ULICA_JAVNO_MESTO',
    'BOLNICA',
  ];

  static const _conditionIds = <String>[
    'BIOHAZARD',
    'LIMENI_ULOZAK',
    'LEMOVANJE',
    'LOKALNO_GROBLJE',
    'OPELO',
  ];

  static const _packageIds = <String>[
    'SAHRANA_VAN_SRBIJE',
    'DOCEK_POSMRTNIH_OSTATAKA',
  ];

  @override
  Widget build(BuildContext context) {
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
        .where((record) => !known.contains(record.id))
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
            child: Text('Nema saÄuvanih scenarija.'),
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

class _ScenarioPolicyBranch extends StatelessWidget {
  const _ScenarioPolicyBranch({
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
  Widget build(BuildContext context) => ExpansionTile(
    key: ValueKey('scenario-branch-${record.id}'),
    initiallyExpanded: true,
    title: Text(record.naziv),
    subtitle: Text(_scenarioStatusLabel(record)),
    children: [
      _ScenarioPolicyRecordRow(
        record: record,
        katalog: katalog,
        onPreview: onPreview,
        onEdit: onEdit,
      ),
    ],
  );
}

class _ScenarioPolicyGroup extends StatelessWidget {
  const _ScenarioPolicyGroup({
    super.key,
    required this.title,
    required this.records,
    required this.katalog,
    required this.onPreview,
    required this.onEdit,
  });

  final String title;
  final List<ScenarioDefinitionRecord> records;
  final List<IriuKatalogConfigData> katalog;
  final ValueChanged<ScenarioDefinitionRecord> onPreview;
  final ValueChanged<ScenarioDefinitionRecord> onEdit;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ExpansionTile(
      initiallyExpanded: true,
      title: Text(title),
      children: [
        for (final record in records)
          _ScenarioPolicyRecordRow(
            record: record,
            katalog: katalog,
            onPreview: onPreview,
            onEdit: onEdit,
          ),
      ],
    ),
  );
}

class _ScenarioPolicyRecordRow extends StatelessWidget {
  const _ScenarioPolicyRecordRow({
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
  Widget build(BuildContext context) => Padding(
    key: ValueKey('scenario-row-${record.id}'),
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_tree_outlined),
          title: Text(record.naziv),
          subtitle: Text(_scenarioStatusLabel(record)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
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
      ],
    ),
  );
}

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
  late ScenarioCondition _condition;
  late Map<String, ScenarioConsequence> _consequences;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.existing?.id ?? '');
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
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
    _idController.dispose();
    _nameController.dispose();
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
        width: _dialogWidth(context, 560),
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
                'POSLOVNA HIJERARHIJA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              _ConditionHierarchyEditor(
                condition: _condition,
                onChanged: (condition) =>
                    setState(() => _condition = condition),
              ),
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
    final name = existing?.name ?? _nameController.text.trim();
    final id =
        existing?.id ??
        (_idController.text.trim().isNotEmpty
            ? _idController.text.trim()
            : name
                  .toUpperCase()
                  .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
                  .replaceAll(RegExp(r'^_+|_+$'), ''));
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
                label: const Text('DODAJ PODUSLOV'),
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
              label: const Text('DODAJ PODUSLOV'),
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
      title: 'DODAJ PODUSLOV',
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
  0 => 'NADUSLOV',
  1 => 'USLOV',
  _ => 'PODUSLOV',
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
