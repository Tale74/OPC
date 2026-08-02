import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../podesavanja/data/podesavanja_repository.dart';
import 'scenario_contract.dart';
import 'scenario_module_repository.dart';

/// User-facing editor for the SCENARIO module.
///
/// The screen edits the module definition only. A PREDMET receives a
/// scenario through the normal PREDMET workflow; this screen never rewrites
/// existing PREDMET or STAVKA data.
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
    _definitionsFuture = _moduleFuture.then((_) => _repository.getDefinitions());
  }

  Future<void> _izmeniPaket(
    BuildContext context,
    ScenarioModule module,
    List<IriuKatalogConfigData> katalog,
  ) async {
    final selected = _repository.readOsnovniPaket(module);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _PackageDialog(
        title: 'OSNOVNI PAKET',
        katalog: katalog,
        selected: selected,
      ),
    );
    if (result == null) return;
    await _repository.saveOsnovniPaket(result);
    _currentModule = await _repository.ensureModule();
    if (!context.mounted) return;
    _katalogFuture = widget.podesavanjaRepository.getKatalogVidljive();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Osnovni paket je sačuvan.')));
  }

  Future<void> _dodajIliIzmeniScenario(
    BuildContext context,
    List<IriuKatalogConfigData> katalog, {
    ScenarioDefinitionRecord? record,
  }) async {
    final existing = record == null
        ? null
        : _repository.definitionFromRecord(record);
    final result = await showDialog<_ScenarioDraft>(
      context: context,
      builder: (_) => _ScenarioDialog(
        katalog: katalog,
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
      jePodrazumevani: result.jePodrazumevani,
      status: 'DRAFT',
    );
    if (!context.mounted) return;
    _definitionsFuture = _repository.getDefinitions();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scenario je sačuvan u MODULIMA.')),
    );
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
                        child: ListTile(
                          leading: Icon(Icons.alt_route_outlined),
                          title: Text('SCENARIO'),
                          subtitle: Text(
                            'Ovde se definišu uslovi i STAVKE koje se nude tokom rada sa PREDMETOM.',
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
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'SCENARIJI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed: katalog.isEmpty
                                        ? null
                                        : () => _dodajIliIzmeniScenario(
                                            context,
                                            katalog,
                                          ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('DODAJ'),
                                  ),
                                ],
                              ),
                              if (definitions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Još nema sačuvanih scenarija. Dodajte prvi scenario prema pravilima firme.',
                                  ),
                                )
                              else
                                ...definitions.map(
                                  (record) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.rule_outlined),
                                    title: Text(record.naziv),
                                    subtitle: Text(
                                      record.jePodrazumevani
                                          ? 'Osnovni scenario · verzija ${record.version}'
                                          : 'Verzija ${record.version}',
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Uredi',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _dodajIliIzmeniScenario(
                                        context,
                                        katalog,
                                        record: record,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Izmena ovde ne menja postojeće PREDMETE. Scenario se primenjuje tek kada ga korisnik izabere u radu sa PREDMETOM.',
                        style: TextStyle(fontSize: 12),
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          children: widget.katalog
              .where((item) => item.vidljiv)
              .map(
                (item) => CheckboxListTile(
                  value: _selected.contains(item.interniNaziv),
                  title: Text(item.nazivPrikaz),
                  subtitle: Text(item.interniNaziv),
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

class _ScenarioDraft {
  const _ScenarioDraft({
    required this.id,
    required this.naziv,
    required this.version,
    required this.condition,
    required this.consequences,
    required this.jePodrazumevani,
  });

  final String id;
  final String naziv;
  final int version;
  final ScenarioCondition condition;
  final List<ScenarioConsequence> consequences;
  final bool jePodrazumevani;
}

class _ScenarioDialog extends StatefulWidget {
  const _ScenarioDialog({
    required this.katalog,
    this.existing,
    required this.existingVersion,
    required this.existingDefault,
  });

  final List<IriuKatalogConfigData> katalog;
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
  late Set<String> _consequenceIds;
  late bool _isDefault;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existingCriterion = _findCriterion(widget.existing?.condition);
    _idController = TextEditingController(text: widget.existing?.id ?? '');
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _valuesController = TextEditingController(
      text: existingCriterion?.values.join(', ') ?? '',
    );
    _field = existingCriterion?.field ?? ScenarioCriterionField.mestoSmrti;
    _operator = existingCriterion?.operator ?? ScenarioCriterionOperator.equals;
    _consequenceIds = {
      for (final consequence
          in widget.existing?.consequences ?? const <ScenarioConsequence>[])
        consequence.katalogCategoryInternalName,
    };
    _isDefault = widget.existingDefault;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _valuesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'NOVI SCENARIO' : 'UREDI SCENARIO'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Interna oznaka',
                helperText: 'Kratka jedinstvena oznaka, npr. BOLNICA_GRADSKO.',
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Naziv'),
            ),
            const SizedBox(height: 12),
            const Text('USLOV', style: TextStyle(fontWeight: FontWeight.w700)),
            DropdownButtonFormField<ScenarioCriterionField>(
              initialValue: _field,
              decoration: const InputDecoration(labelText: 'Podatak'),
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
              decoration: const InputDecoration(labelText: 'Poređenje'),
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
              decoration: const InputDecoration(
                labelText: 'Vrednost ili vrednosti',
                helperText: 'Više vrednosti odvojite zarezom.',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'DODATNE STAVKE',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            ...widget.katalog
                .where((item) => item.vidljiv)
                .map(
                  (item) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _consequenceIds.contains(item.interniNaziv),
                    title: Text(item.nazivPrikaz),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        _consequenceIds.add(item.interniNaziv);
                      } else {
                        _consequenceIds.remove(item.interniNaziv);
                      }
                    }),
                  ),
                ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Osnovni scenario'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ODUSTANI'),
      ),
      FilledButton(onPressed: _save, child: const Text('SAČUVAJ')),
    ],
  );

  void _save() {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final values = _valuesController.text
        .split(',')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (id.isEmpty || name.isEmpty || values.isEmpty) {
      setState(
        () => _error = 'Unesite oznaku, naziv i najmanje jednu vrednost.',
      );
      return;
    }
    Navigator.pop(
      context,
      _ScenarioDraft(
        id: id,
        naziv: name,
        version: widget.existingVersion,
        condition: ScenarioCondition.criterion(
          ScenarioCriterion(field: _field, operator: _operator, values: values),
        ),
        consequences: [
          for (final id in _consequenceIds)
            ScenarioConsequence(
              katalogCategoryInternalName: id,
              action: ScenarioConsequenceAction.recommended,
            ),
        ],
        jePodrazumevani: _isDefault,
      ),
    );
  }
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

String _criterionFieldLabel(ScenarioCriterionField field) => switch (field) {
  ScenarioCriterionField.mestoSmrti => 'Mesto smrti',
  ScenarioCriterionField.uzrokSmrti => 'Uzrok smrti',
  ScenarioCriterionField.vrstaCeremonije => 'Vrsta ceremonije',
  ScenarioCriterionField.tipGroblja => 'Tip groblja',
  ScenarioCriterionField.grobnoMesto => 'Groblje / mesto',
  ScenarioCriterionField.tipGrobnogMesta => 'Tip grobnog mesta',
  ScenarioCriterionField.sahranaVanSrbije => 'Sahrana van Srbije',
  ScenarioCriterionField.docekPosmrtnihOstataka => 'Doček posmrtnih ostataka',
  ScenarioCriterionField.opelo => 'Opelo',
};

String _criterionOperatorLabel(ScenarioCriterionOperator operator) =>
    switch (operator) {
      ScenarioCriterionOperator.equals => 'jednako',
      ScenarioCriterionOperator.notEquals => 'nije jednako',
      ScenarioCriterionOperator.inSet => 'jedno od',
      ScenarioCriterionOperator.notInSet => 'nije nijedno od',
      ScenarioCriterionOperator.isTrue => 'da',
      ScenarioCriterionOperator.isFalse => 'ne',
    };
