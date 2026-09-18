import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../auth/domain/session_service.dart';
import '../data/podsetnik_obligation_repository.dart';
import '../domain/podsetnik_obligation.dart';
import '../../predmeti/data/predmeti_repository.dart';
import '../../predmeti/reminders/ceremony_notification_gateway.dart';
import '../../predmeti/reminders/ceremony_reminder_coordinator.dart';
import '../../predmeti/reminders/ceremony_reminder_model.dart';
import '../../predmeti/reminders/ceremony_reminder_repository.dart';
import '../../predmeti/reminders/urna_ashes_reminder_model.dart';
import '../../predmeti/pdf/nalog_cvecari_pdf_export.dart';
import '../../predmeti/pdf/nalog_za_opremanje_pdf_export.dart'
    as nalog_za_opremanje_pdf_export;
import '../../predmeti/citulje/data/citulje_preparation_repository.dart';
import '../../predmeti/citulje/pdf/citulja_pdf_export.dart';

class PodsetnikModuleScreen extends StatefulWidget {
  const PodsetnikModuleScreen({
    super.key,
    required this.predmetiRepository,
    this.predmetId,
    this.session,
  });

  final PredmetiRepository predmetiRepository;
  final int? predmetId;
  final SessionService? session;

  @override
  State<PodsetnikModuleScreen> createState() => _PodsetnikModuleScreenState();
}

class _PodsetnikModuleScreenState extends State<PodsetnikModuleScreen> {
  late Stream<List<PredmetiData>> _predmetiStream;
  int? _selectedPredmetId;

  @override
  void initState() {
    super.initState();
    _selectedPredmetId = widget.predmetId;
    _predmetiStream = widget.predmetiRepository.watchPodsetnikKandidate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MODULI / PODSETNIK')),
      body: StreamBuilder<List<PredmetiData>>(
        stream: _predmetiStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final predmeti = snapshot.data!;
          final selectedId = predmeti.any((p) => p.id == _selectedPredmetId)
              ? _selectedPredmetId
              : null;
          final selected = selectedId == null
              ? null
              : predmeti.firstWhere((p) => p.id == selectedId);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'PODSETNIK',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Podešavanja podsetnika koriste činjenice iz PREDMETA i '
                'CEREMONIJE. Datum, vreme i mesto ceremonije menjaju se u '
                'PREDMETU; ovde se podešava obaveštavanje.',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                key: const Key('podsetnik-predmet-selector'),
                initialValue: selectedId,
                decoration: const InputDecoration(
                  labelText: 'PREDMET',
                  border: OutlineInputBorder(),
                ),
                items: predmeti
                    .map(
                      (predmet) => DropdownMenuItem(
                        value: predmet.id,
                        child: Text(_predmetLabel(predmet)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() {
                  _selectedPredmetId = value;
                }),
              ),
              const SizedBox(height: 20),
              if (predmeti.isEmpty)
                const Text('Nema PREDMETA dostupnih za PODSETNIK.')
              else if (selected == null)
                const Text('Izaberite PREDMET za podešavanje podsetnika.')
              else
                PodsetnikPredmetSettings(
                  key: ValueKey(selected.id),
                  predmet: selected,
                  database: widget.predmetiRepository.db,
                  session: widget.session,
                ),
            ],
          );
        },
      ),
    );
  }

  static String _predmetLabel(PredmetiData predmet) {
    final name = '${predmet.ime} ${predmet.prezime}'.trim();
    return name.isEmpty ? 'PREDMET' : name;
  }
}

class PodsetnikPredmetSettings extends StatefulWidget {
  const PodsetnikPredmetSettings({
    super.key,
    required this.predmet,
    required this.database,
    this.session,
    this.onNalogZaOpremanje,
    this.onNalogCvecari,
    this.onCituljaPdf,
  });

  final PredmetiData predmet;
  final AppDatabase database;
  final SessionService? session;
  final Future<void> Function(BuildContext context)? onNalogZaOpremanje;
  final Future<void> Function(BuildContext context)? onNalogCvecari;
  final Future<void> Function(BuildContext context, String occurrenceId)?
      onCituljaPdf;

  @override
  State<PodsetnikPredmetSettings> createState() =>
      _PodsetnikPredmetSettingsState();
}

class _PodsetnikPresentationChild {
  const _PodsetnikPresentationChild({
    required this.item,
    required this.label,
  });

  final PodsetnikObligation item;
  final String label;
}

class _PodsetnikPresentationParent {
  const _PodsetnikPresentationParent({
    required this.item,
    required this.children,
  });

  final PodsetnikObligation item;
  final List<_PodsetnikPresentationChild> children;
}

class _PodsetnikPredmetSettingsState extends State<PodsetnikPredmetSettings> {
  static const double _wideLayoutBreakpoint = 680;
  static const double _checklistColumnGap = 12;
  static const _syntheticChildLabels = <String, String>{
    'ceremony.parte': 'Spremiti parte',
    'goods.equipment': 'Spremiti opremu',
    'goods.flowers': 'Poručiti cveće',
    'goods.photo': 'Spremiti sliku',
    'goods.mourning': 'Spremiti crninu',
  };

  late CeremonyReminderRepository _repository;
  late CeremonyReminderCoordinator _coordinator;
  CeremonyReminderConfig? _config;
  late PodsetnikObligationRepository _obligationRepository;
  List<PodsetnikObligation> _obligations = const [];
  String? _selectedParentRuleId;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _repository = CeremonyReminderRepository(widget.database);
    _obligationRepository = PodsetnikObligationRepository(widget.database);
    _noteController = TextEditingController(text: widget.predmet.napomena);
    _coordinator = CeremonyReminderCoordinator(
      repository: _repository,
      gateway: AndroidCeremonyNotificationGateway(),
    );
    _load();
    _loadObligations();
  }

  @override
  void didUpdateWidget(covariant PodsetnikPredmetSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    final databaseChanged = !identical(oldWidget.database, widget.database);
    final predmetChanged = oldWidget.predmet.id != widget.predmet.id;
    if (!databaseChanged && !predmetChanged) return;

    if (databaseChanged) {
      _repository = CeremonyReminderRepository(widget.database);
      _obligationRepository = PodsetnikObligationRepository(widget.database);
      _coordinator = CeremonyReminderCoordinator(
        repository: _repository,
        gateway: AndroidCeremonyNotificationGateway(),
      );
    }
    _selectedParentRuleId = null;
    _obligations = const [];
    _load();
    _loadObligations();
  }

  Future<void> _load() async {
    final stored = await _repository.getForPredmet(widget.predmet.id);
    if (mounted) setState(() => _config = stored.config);
  }

  Future<void> _loadObligations() async {
    final obligations = await _obligationRepository.reconcileForPredmet(
      widget.predmet.id,
    );
    if (!mounted) return;
    final roots = obligations.where(
      (item) => item.relevant && item.rule.parentRuleId == null,
    );
    final selected = roots.any(
      (item) => item.rule.stableRuleId == _selectedParentRuleId,
    );
    setState(() {
      _obligations = obligations;
      if (!selected) _selectedParentRuleId = null;
    });
  }

  Future<void> _setCompletion(String ruleId, bool completed) async {
    await _obligationRepository.setAtomicCompletion(
      predmetId: widget.predmet.id,
      stableRuleId: ruleId,
      completed: completed,
    );
    await _rescheduleCurrentReminders();
    await _loadObligations();
  }

  Future<void> _setParentCompletion(String parentRuleId, bool completed) async {
    await _obligationRepository.setParentCompletion(
      predmetId: widget.predmet.id,
      parentRuleId: parentRuleId,
      completed: completed,
    );
    await _rescheduleCurrentReminders();
    await _loadObligations();
  }

  Future<void> _rescheduleCurrentReminders() {
    return _coordinator.reschedule(
      predmetId: widget.predmet.id,
      predmetStatus: widget.predmet.status,
      ceremonyType: widget.predmet.vrstaCeremonije,
      deceasedFirstName: widget.predmet.ime,
      deceasedLastName: widget.predmet.prezime,
      ceremonyDate: widget.predmet.datumCeremonije,
      ceremonyTime: widget.predmet.vremeCeremonije,
      ceremonyLocation: widget.predmet.groblje,
      urnPlacementType: widget.predmet.tipPolaganja,
      urnCemetery: widget.predmet.grobljePolaganjaUrne,
      ceremonyAt: parseCeremonyReminderDateTime(
        widget.predmet.datumCeremonije,
        widget.predmet.vremeCeremonije,
      ),
    );
  }

  List<_PodsetnikPresentationParent> _presentationParents(
    List<PodsetnikObligation> roots,
  ) {
    return roots.map((parent) {
      final children = _obligations
          .where(
            (item) =>
                item.relevant &&
                item.rule.parentRuleId == parent.rule.stableRuleId,
          )
          .map(
            (item) => _PodsetnikPresentationChild(
              item: item,
              label: _label(item),
            ),
          )
          .toList(growable: false);
      if (children.isNotEmpty) {
        return _PodsetnikPresentationParent(
          item: parent,
          children: children,
        );
      }
      final syntheticChildLabel = _syntheticChildLabels[parent.rule.stableRuleId];
      if (syntheticChildLabel != null) {
        return _PodsetnikPresentationParent(
          item: parent,
          children: [
            _PodsetnikPresentationChild(
              item: parent,
              label: syntheticChildLabel,
            ),
          ],
        );
      }
      return _PodsetnikPresentationParent(
        item: parent,
        children: const [],
      );
    }).toList(growable: false);
  }

  Future<void> _addManualObligation() async {
    final actorRole = widget.session?.korisnik?.uloga;
    if (actorRole == null) return;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('POSEBNE OBAVEZE'),
        content: TextField(
          key: const Key('podsetnik-manual-text'),
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Tekst obaveze',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            key: const Key('podsetnik-manual-confirm'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty || !mounted) return;
    await _obligationRepository.addManualObligation(
      predmetId: widget.predmet.id,
      text: text,
      actorRole: actorRole,
    );
    await _loadObligations();
  }

  String _label(PodsetnikObligation item) => switch (item.rule.stableRuleId) {
    'ceremony.opelo' => 'OPELO',
    'ceremony.opelo.notify_priest' => 'Obavestiti sveštenika',
    'ceremony.opelo.prepare_kit' => 'Spremiti komplet za opelo',
    'social.pio_refund' => 'REFUNDACIJA PIO',
    'social.pio_refund.submit_claim' => 'Podneti zahtev PIO',
    'social.family_pension' => 'PORODIČNA PENZIJA',
    'social.family_pension.submit_claim' => 'Podneti zahtev za porodičnu penziju',
    'social.death_assistance' => 'POSMRTNA POMOĆ',
    'social.death_assistance.submit_claim' => 'Podneti zahtev za posmrtnu pomoć',
    'military.honors' => 'VOJNE POČASTI',
    'military.honors.notify_authority' => 'Obavestiti nadležnu službu',
    'ceremony.parte' => 'PARTE',
    'goods.equipment' => 'OPREMA',
    'goods.photo' => 'SLIKA',
    'goods.mourning' => 'CRNINA',
    'goods.flowers' => 'CVEĆE',
    'ceremony.international' => 'Spremiti međunarodna dokumenta',
    'ceremony.reception' => 'Preuzeti posmrtne ostatke',
    'goods.stock' => 'Razreši stanje robe',
    'post.urn_ashes' => urnaAshesParentLabel(widget.predmet.tipPolaganja),
    'post.urn_ashes.arrange_placement' =>
      widget.predmet.tipPolaganja.trim().toUpperCase() == 'RASIPANJE_PEPELA'
          ? 'Zakazati rasipanje pepela'
          : 'Zakazati polaganje urne',
    _ => podsetnikObligationDisplayLabel(item.rule),
  };

  Future<void> _exportCituljaPdf(String occurrenceId) async {
    final callback = widget.onCituljaPdf;
    if (callback != null) {
      await callback(context, occurrenceId);
      return;
    }
    final repository = CituljePreparationRepository(widget.database);
    final rows = await repository.ensureCurrentForPredmet(widget.predmet.id);
    final matching = rows
        .where((row) => row.portableOccurrenceId == occurrenceId)
        .toList(growable: false);
    final preparation = matching.isEmpty ? null : matching.first;
    if (preparation == null) {
      throw StateError('ČITULJA priprema nije pronađena.');
    }
    if (!mounted) return;
    await izvoziCituljaPdf(
      ctx: context,
      db: widget.database,
      preparationId: preparation.id,
    );
  }

  Widget _buildParentRow(PodsetnikObligation item) {
    final selected = item.rule.stableRuleId == _selectedParentRuleId;
    final scheme = Theme.of(context).colorScheme;
    final onChanged = item.isGroup
        ? (bool value) => _setParentCompletion(
              item.rule.stableRuleId,
              value,
            )
        : (bool value) => _setCompletion(item.rule.stableRuleId, value);
    return Material(
      key: ValueKey(
        'podsetnik-parent-surface-${item.rule.stableRuleId}',
      ),
      color: selected
          ? scheme.secondaryContainer
          : Colors.transparent,
      child: Row(
        key: ValueKey('podsetnik-parent-${item.rule.stableRuleId}'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey(
                'podsetnik-parent-label-${item.rule.stableRuleId}',
              ),
              onTap: () => setState(
                () => _selectedParentRuleId == item.rule.stableRuleId
                    ? _selectedParentRuleId = null
                    : _selectedParentRuleId = item.rule.stableRuleId,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(_label(item).toUpperCase())),
                    Icon(
                      selected
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      semanticLabel: selected
                          ? 'Izabrana obaveza'
                          : 'Prikaži podređene obaveze',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Checkbox(
            key: ValueKey(
              'podsetnik-parent-checkbox-${item.rule.stableRuleId}',
            ),
            value: item.completed,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return item.completed ? Colors.green : scheme.error;
            }),
            checkColor: Colors.white,
            onChanged: (value) => onChanged(value ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildObligationActions(PodsetnikObligation item) {
    if (item.rule.portableOccurrenceId != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 28, bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: ValueKey(
              'podsetnik-citulja-pdf-${item.rule.stableRuleId}',
            ),
            onPressed: () => _exportCituljaPdf(
              item.rule.portableOccurrenceId!,
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Čitulja PDF'),
          ),
        ),
      );
    }
    if (item.rule.stableRuleId == 'goods.equipment') {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          key: const Key('podsetnik-nalog-opremanje'),
          onPressed: () => (widget.onNalogZaOpremanje ??
                  (context) => nalog_za_opremanje_pdf_export
                      .izvoziNalogZaOpremanjePdf(
                        ctx: context,
                        db: widget.database,
                        predmetId: widget.predmet.id,
                      ))
              .call(context),
          child: const Text('Nalog za opremanje'),
        ),
      );
    }
    if (item.rule.stableRuleId == 'goods.flowers') {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          key: const Key('podsetnik-nalog-cvecari'),
          onPressed: () => (widget.onNalogCvecari ??
                  (context) => izvoziNalogCvecariPdf(
                        ctx: context,
                        db: widget.database,
                        predmetId: widget.predmet.id,
                      ))
              .call(context),
          child: const Text('Nalog cvećari'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildChildUnit(_PodsetnikPresentationChild child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: CheckboxListTile(
              key: ValueKey(
                'podsetnik-child-${child.item.rule.stableRuleId}',
              ),
              contentPadding: EdgeInsets.zero,
              title: Text(child.label),
              value: child.item.completed,
              onChanged: (value) => _setCompletion(
                child.item.rule.stableRuleId,
                value ?? false,
              ),
            ),
          ),
          _buildObligationActions(child.item),
        ],
      );

  Widget _buildChecklist(BuildContext context) {
    final roots = _obligations
        .where((item) => item.relevant && item.rule.parentRuleId == null)
        .toList(growable: false);
    final parents = _presentationParents(roots);
    _PodsetnikPresentationParent? selectedParent;
    for (final parent in parents) {
      if (parent.item.rule.stableRuleId == _selectedParentRuleId) {
        selectedParent = parent;
        break;
      }
    }
    final children = selectedParent?.children ?? const <_PodsetnikPresentationChild>[];
    final childPane = children.isEmpty
        ? const SizedBox.shrink()
        : Material(
            key: const Key('podsetnik-selected-parent-children'),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in children) _buildChildUnit(child),
              ],
            ),
          );
    Widget buildParentPane({required bool inlineSelectedChild}) => Column(
          key: const Key('podsetnik-parent-obligations'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final parent in parents) ...[
              _buildParentRow(parent.item),
              if (inlineSelectedChild &&
                  parent.item.rule.stableRuleId == _selectedParentRuleId &&
                  children.isNotEmpty)
                childPane,
            ],
          ],
        );
    final parentPane = buildParentPane(inlineSelectedChild: false);
    final narrowParentPane = buildParentPane(inlineSelectedChild: true);

    return Column(
      key: const Key('podsetnik-obaveze-checklist'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.session?.korisnik?.uloga == 'SAVETNIK' ||
            widget.session?.korisnik?.uloga == 'ADMINISTRATOR')
          OutlinedButton.icon(
            key: const Key('podsetnik-add-manual-obligation'),
            onPressed: _addManualObligation,
            icon: const Icon(Icons.add_task_outlined),
            label: const Text('Dodaj posebnu obavezu'),
          ),
        if (_obligations.isEmpty)
          const Text('Nema trenutno relevantnih obaveza.'),
        if (_obligations.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.hasBoundedWidth &&
                  constraints.maxWidth >= _wideLayoutBreakpoint;
              if (!isWide) {
                return narrowParentPane;
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: parentPane),
                  const SizedBox(width: _checklistColumnGap),
                  Expanded(child: childPane),
                ],
              );
            },
          ),
      ],
    );
  }

  Future<void> _save(
    CeremonyReminderConfig config, {
    bool requestPermission = false,
  }) async {
    await _repository.saveConfig(widget.predmet.id, config);
    if (!mounted) return;
    setState(() => _config = config);
    await _coordinator.reschedule(
      predmetId: widget.predmet.id,
      predmetStatus: widget.predmet.status,
      ceremonyType: widget.predmet.vrstaCeremonije,
      deceasedFirstName: widget.predmet.ime,
      deceasedLastName: widget.predmet.prezime,
      ceremonyDate: widget.predmet.datumCeremonije,
      ceremonyTime: widget.predmet.vremeCeremonije,
      ceremonyLocation: widget.predmet.groblje,
      urnPlacementType: widget.predmet.tipPolaganja,
      urnCemetery: widget.predmet.grobljePolaganjaUrne,
      ceremonyAt: parseCeremonyReminderDateTime(
        widget.predmet.datumCeremonije,
        widget.predmet.vremeCeremonije,
      ),
      requestPermission: requestPermission,
    );
  }

  Future<void> _addTime() async {
    final config = _config!;
    final initial = config.normalizedDeliveryTimes.first.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(initial[0]),
        minute: int.parse(initial[1]),
      ),
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    await _save(
      config.copyWith(
        deliveryTimes: {...config.normalizedDeliveryTimes, value}.toList(),
      ),
      requestPermission: true,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (config == null) return const LinearProgressIndicator();
    final ceremonyHeader = [
      widget.predmet.vrstaCeremonije.trim(),
      widget.predmet.datumCeremonije.trim(),
      widget.predmet.vremeCeremonije.trim(),
      widget.predmet.groblje.trim().isEmpty
          ? 'Groblje nije uneto'
          : widget.predmet.groblje.trim(),
    ].join(' – ');
    return Card(
      key: const Key('podsetnik-module-settings'),
      child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              'ČINJENICE CEREMONIJE',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              ceremonyHeader,
              key: const Key('podsetnik-ceremony-header'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Divider(height: 28),
            Text(
              'OBAVEZE I NAPOMENE',
              key: const Key('podsetnik-obaveze-heading'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildChecklist(context),
            const SizedBox(height: 12),
            TextField(
              key: const Key('podsetnik-general-note'),
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Napomena',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => (widget.database.update(
                widget.database.predmeti,
              )..where((row) => row.id.equals(widget.predmet.id))).write(
                PredmetiCompanion(napomena: Value(value)),
              ),
            ),
            const Divider(height: 28),
            SwitchListTile(
              key: const Key('podsetnik-reminders-enabled'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Podsetnici za ceremoniju'),
              value: config.enabled,
              onChanged: (value) => _save(
                config.copyWith(enabled: value),
                requestPermission: value,
              ),
            ),
            if (config.enabled)
              Wrap(
                key: const Key('podsetnik-reminder-delivery-times'),
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final value in config.normalizedDeliveryTimes)
                    InputChip(
                      label: Text(value),
                      onDeleted: config.normalizedDeliveryTimes.length > 1
                          ? () => _save(
                              config.copyWith(
                                deliveryTimes: config.normalizedDeliveryTimes
                                    .where((item) => item != value)
                                    .toList(),
                              ),
                            )
                          : null,
                    ),
                  IconButton.filledTonal(
                    key: const Key('podsetnik-reminder-add-time'),
                    tooltip: 'Dodaj vreme podsetnika',
                    onPressed: _addTime,
                    icon: const Icon(Icons.add_alarm_outlined),
                  ),
                ],
              ),
              ],
            ),
          ),
      ),
    );
  }
}
