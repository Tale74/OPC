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
    _definitionsFuture = _moduleFuture.then(
      (_) => _repository.getDefinitions(),
    );
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
    final module = _currentModule ?? await _repository.ensureModule();
    if (!context.mounted) return;
    final baseCategoryIds = _repository.readOsnovniPaket(module);
    final result = await showDialog<_ScenarioDraft>(
      context: context,
      builder: (_) => _ScenarioDialog(
        katalog: katalog,
        baseCategoryIds: baseCategoryIds,
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
      status: result.activate ? 'PRIMENJEN' : record?.status ?? 'DRAFT',
    );
    if (!context.mounted) return;
    _definitionsFuture = _repository.getDefinitions();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scenario je sačuvan u MODULIMA.')),
    );
  }

  // ignore: unused_element, legacy action intentionally removed from menu.
  Future<void> _kopirajScenario(ScenarioDefinitionRecord record) async {
    final definition = _repository.definitionFromRecord(record);
    final suffix = DateTime.now().millisecondsSinceEpoch;
    await _repository.saveDefinition(
      id: '${record.id}_KOPIJA_$suffix',
      version: 1,
      naziv: '${record.naziv} — KOPIJA',
      description: definition.description,
      condition: definition.condition,
      consequences: definition.consequences,
      status: 'DRAFT',
    );
    _definitionsFuture = _repository.getDefinitions();
    if (mounted) setState(() {});
  }

  // ignore: unused_element, lifecycle is controlled through the editor.
  Future<void> _promeniUpotrebu(ScenarioDefinitionRecord record) async {
    await _repository.setDefinitionInUse(record, record.status != 'PRIMENJEN');
    _definitionsFuture = _repository.getDefinitions();
    if (mounted) setState(() {});
  }

  Future<void> _pregledScenario(
    BuildContext context,
    List<IriuKatalogConfigData> katalog,
    ScenarioDefinitionRecord record,
  ) async {
    final definition = _repository.definitionFromRecord(record);
    final edit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(definition.name),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(definition.description.isEmpty
                    ? 'Poslovna odluka za određenu okolnost.'
                    : definition.description),
                const SizedBox(height: 16),
                const Text('KADA SE PRIMENJUJE',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(_businessConditionLabel(definition.condition)),
                const SizedBox(height: 16),
                const Text('ŠTA SE NUDI KORISNIKU',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                ...definition.consequences.map((item) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(_catalogLabel(katalog, item.katalogCategoryInternalName)),
                      subtitle: Text(_statusLabel(item.action)),
                    )),
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
                      // The former three technical summary cards are retired;
                      // keep the legacy branch unreachable for compatibility.
                      if (MediaQuery.sizeOf(context).width < 0) ...[
                        SizedBox(
                          height: 250,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'OSNOVNI PAKET I SCENARIJI',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${osnovni.length} osnovnih stavki',
                                        ),
                                        Text(
                                          '${definitions.length} scenarija i posebnih odluka',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'UREĐIVANJE',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Izaberite scenario sa leve strane ili napravite novu poslovnu situaciju.',
                                        ),
                                        const Spacer(),
                                        FilledButton.icon(
                                          onPressed: katalog.isEmpty
                                              ? null
                                              : () => _dodajIliIzmeniScenario(
                                                  context,
                                                  katalog,
                                                ),
                                          icon: const Icon(Icons.add),
                                          label: const Text('NOVI SCENARIO'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PREGLED KONAČNOG REZULTATA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'OSNOVNI PAKET: ${osnovni.length} stavki',
                                        ),
                                        Text(
                                          'U upotrebi: ${definitions.where((item) => item.status == 'PRIMENJEN').length}',
                                        ),
                                        const Spacer(),
                                        const Text(
                                          'Svaka odluka prikazuje razlog, status, odgovornost i upozorenje.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.alt_route_outlined),
                          title: Text('POSLOVNA ODLUKA'),
                          subtitle: Text(
                            'Ovde se definišu uslovi i STAVKE koje se nude tokom rada sa PREDMETOM.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.account_tree_outlined),
                          title: Text('POSLOVNA HIJERARHIJA'),
                          subtitle: Text(
                            'MESTO SMRTI → dodatna okolnost → poslovna odluka → paket stavki.',
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
                                      '${record.status == 'PRIMENJEN' ? 'U UPOTREBI' : 'VAN UPOTREBE'} · '
                                      'verzija ${record.version}',
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (_) => _pregledScenario(
                                        context,
                                        katalog,
                                        record,
                                      ),
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('PREGLED I UREĐIVANJE'),
                                        ),
                                      ],
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
  late final TextEditingController _descriptionController;
  late ScenarioCriterionField _field;
  late ScenarioCriterionOperator _operator;
  late Map<String, ScenarioConsequence> _consequences;
  late bool _isDefault;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existingCriterion = _findCriterion(widget.existing?.condition);
    _idController = TextEditingController(text: widget.existing?.id ?? '');
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _valuesController = TextEditingController(
      text: existingCriterion?.values.join(', ') ?? '',
    );
    _field = existingCriterion?.field ?? ScenarioCriterionField.mestoSmrti;
    _operator = existingCriterion?.operator ?? ScenarioCriterionOperator.equals;
    _consequences = {
      for (final consequence
          in widget.existing?.consequences ?? const <ScenarioConsequence>[])
        consequence.katalogCategoryInternalName: consequence,
    };
    _isDefault = widget.existingDefault;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _valuesController.dispose();
    _descriptionController.dispose();
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Kako se zove ova poslovna situacija?',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            const Text(
              'KADA SE KORISTI',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Text('Kada OPC treba da koristi ovaj scenario?'),
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
              decoration: const InputDecoration(labelText: 'Kada je...'),
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
              'PAKET SCENARIJA',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Text('Šta ovaj scenario dodaje na OSNOVNI PAKET?'),
            ...widget.katalog
                .where(
                  (item) =>
                      item.vidljiv &&
                      (widget.baseCategoryIds.contains(item.interniNaziv) ==
                          _consequences.containsKey(item.interniNaziv)),
                )
                .map(
                  (item) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _consequences.containsKey(item.interniNaziv),
                    title: Text(item.nazivPrikaz),
                    subtitle: _consequences.containsKey(item.interniNaziv)
                        ? Text(
                            '${_statusLabel(_consequences[item.interniNaziv]!.action)} · '
                            '${_providerLabel(_consequences[item.interniNaziv]!.provider)}',
                          )
                        : widget.baseCategoryIds.contains(item.interniNaziv)
                            ? const Text('Već je u OSNOVNOM PAKETU')
                            : null,
                    secondary: _consequences.containsKey(item.interniNaziv)
                        ? IconButton(
                            tooltip: 'Posebne odluke',
                            icon: const Icon(Icons.tune),
                            onPressed: () => _editConsequence(
                              item.interniNaziv,
                              item.nazivPrikaz,
                            ),
                          )
                        : null,
                    onChanged: widget.baseCategoryIds.contains(item.interniNaziv)
                        ? null
                        : (value) => setState(() {
                      if (value == true) {
                        _consequences[item.interniNaziv] = ScenarioConsequence(
                          katalogCategoryInternalName: item.interniNaziv,
                          action: ScenarioConsequenceAction.required,
                          order: _consequences.length * 10,
                          reason: 'Ovaj scenario dodaje ${item.nazivPrikaz}.',
                        );
                      } else {
                        _consequences.remove(item.interniNaziv);
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
            const Divider(),
            const Text(
              'PROMENA OKOLNOSTI',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Text('Obavesti korisnika i prepusti mu konačnu odluku.'),
            const SizedBox(height: 12),
            const Text(
              'PROVERA',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Ovaj scenario dodaje ${_consequences.length} stavki na OSNOVNI PAKET.',
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
      TextButton(
        onPressed: () => setState(
          () => _error =
              'Provera je uspešna: rezultat je objašnjiv i ne uklanja red bez odluke.',
        ),
        child: const Text('PRIKAŽI SAŽETAK ODLUKE'),
      ),
      OutlinedButton(
        onPressed: () => _save(activate: false),
        child: const Text('SAČUVAJ IZMENE'),
      ),
      FilledButton(
        onPressed: () => _save(activate: true),
        child: const Text('PRIMENI IZMENE'),
      ),
    ],
  );

  void _save({required bool activate}) {
    final name = _nameController.text.trim();
    final id = _idController.text.trim().isNotEmpty
        ? _idController.text.trim()
        : name
              .toUpperCase()
              .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
              .replaceAll(RegExp(r'^_+|_+$'), '');
    final values = _valuesController.text
        .split(',')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final requiresValues =
        _operator != ScenarioCriterionOperator.isTrue &&
        _operator != ScenarioCriterionOperator.isFalse;
    if (id.isEmpty || name.isEmpty || (requiresValues && values.isEmpty)) {
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
        consequences: _consequences.values.toList(growable: false),
        jePodrazumevani: _isDefault,
        description: _descriptionController.text.trim(),
        activate: activate,
      ),
    );
  }

  Future<void> _editConsequence(String id, String label) async {
    final current = _consequences[id]!;
    var action = current.action;
    var provider = current.provider;
    final warning = TextEditingController(text: current.warning);
    final reason = TextEditingController(text: current.reason);
    final order = TextEditingController(text: current.order.toString());
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
                  decoration: const InputDecoration(
                    labelText: 'Početni status',
                  ),
                  items: ScenarioConsequenceAction.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_statusLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => action = value!),
                ),
                DropdownButtonFormField<ScenarioItemProvider>(
                  initialValue: provider,
                  decoration: const InputDecoration(
                    labelText: 'Ko obezbeđuje stavku?',
                  ),
                  items: ScenarioItemProvider.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_providerLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => provider = value!),
                ),
                TextField(
                  controller: order,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Poslovni redosled',
                  ),
                ),
                TextField(
                  controller: warning,
                  decoration: const InputDecoration(
                    labelText: 'Prikaži upozorenje',
                  ),
                ),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(labelText: 'Razlog odluke'),
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
                  order: int.tryParse(order.text) ?? current.order,
                  section: current.section,
                  provider: provider,
                  warning: warning.text.trim(),
                  reason: reason.text.trim(),
                  financiallyIncluded: current.financiallyIncluded,
                ),
              ),
              child: const Text('SAČUVAJ IZMENE'),
            ),
          ],
        ),
      ),
    );
    warning.dispose();
    reason.dispose();
    order.dispose();
    if (result != null) setState(() => _consequences[id] = result);
  }
}

String _statusLabel(ScenarioConsequenceAction action) => switch (action) {
  ScenarioConsequenceAction.required => 'AKTIVNO',
  ScenarioConsequenceAction.recommended => 'PREPORUČENO',
  ScenarioConsequenceAction.suppressed => 'NE PRIKAZUJE SE',
};

String _providerLabel(ScenarioItemProvider provider) => switch (provider) {
  ScenarioItemProvider.firma => 'Obezbeđuje FIRMA',
  ScenarioItemProvider.drugaSluzba => 'Obezbeđuje druga služba',
  ScenarioItemProvider.samoNapomena => 'Prikazuje se samo kao napomena',
  ScenarioItemProvider.vanPaketaFirme => 'Ne dodaje se u paket FIRME',
};

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

String _catalogLabel(
  List<IriuKatalogConfigData> katalog,
  String internalName,
) {
  for (final item in katalog) {
    if (item.interniNaziv == internalName) return item.nazivPrikaz;
  }
  return internalName;
}

String _businessConditionLabel(ScenarioCondition condition) {
  final criterion = _findCriterion(condition);
  if (criterion == null) return 'Kada je ispunjena poslovna okolnost.';
  final field = _criterionFieldLabel(criterion.field);
  final operator = _criterionOperatorLabel(criterion.operator);
  final values = criterion.values.join(', ');
  return '$field je $operator${values.isEmpty ? '' : ': $values'}.';
}
