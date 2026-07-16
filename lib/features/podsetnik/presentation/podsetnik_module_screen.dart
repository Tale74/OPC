import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../predmeti/data/predmeti_repository.dart';
import '../../predmeti/reminders/ceremony_notification_gateway.dart';
import '../../predmeti/reminders/ceremony_reminder_coordinator.dart';
import '../../predmeti/reminders/ceremony_reminder_model.dart';
import '../../predmeti/reminders/ceremony_reminder_repository.dart';

class PodsetnikModuleScreen extends StatefulWidget {
  const PodsetnikModuleScreen({
    super.key,
    required this.predmetiRepository,
    this.predmetId,
  });

  final PredmetiRepository predmetiRepository;
  final int? predmetId;

  @override
  State<PodsetnikModuleScreen> createState() => _PodsetnikModuleScreenState();
}

class _PodsetnikModuleScreenState extends State<PodsetnikModuleScreen> {
  late Future<List<PredmetiData>> _predmetiFuture;
  int? _selectedPredmetId;

  @override
  void initState() {
    super.initState();
    _selectedPredmetId = widget.predmetId;
    _predmetiFuture = widget.predmetiRepository.getPodsetnikKandidate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MODULI / PODSETNIK')),
      body: FutureBuilder<List<PredmetiData>>(
        future: _predmetiFuture,
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
  });

  final PredmetiData predmet;
  final AppDatabase database;

  @override
  State<PodsetnikPredmetSettings> createState() =>
      _PodsetnikPredmetSettingsState();
}

class _PodsetnikPredmetSettingsState extends State<PodsetnikPredmetSettings> {
  late final CeremonyReminderRepository _repository;
  late final CeremonyReminderCoordinator _coordinator;
  CeremonyReminderConfig? _config;

  @override
  void initState() {
    super.initState();
    _repository = CeremonyReminderRepository(widget.database);
    _coordinator = CeremonyReminderCoordinator(
      repository: _repository,
      gateway: AndroidCeremonyNotificationGateway(),
    );
    _load();
  }

  Future<void> _load() async {
    final stored = await _repository.getForPredmet(widget.predmet.id);
    if (mounted) setState(() => _config = stored.config);
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
      ceremonyType: widget.predmet.vrstaCeremonije,
      deceasedFirstName: widget.predmet.ime,
      deceasedLastName: widget.predmet.prezime,
      ceremonyDate: widget.predmet.datumCeremonije,
      ceremonyTime: widget.predmet.vremeCeremonije,
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
  Widget build(BuildContext context) {
    final config = _config;
    if (config == null) return const LinearProgressIndicator();
    final ceremony = [
      widget.predmet.vrstaCeremonije,
      widget.predmet.datumCeremonije,
      widget.predmet.vremeCeremonije,
      widget.predmet.groblje,
    ].where((value) => value.trim().isNotEmpty).join(' · ');
    return Card(
      key: const Key('podsetnik-module-settings'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Činjenice CEREMONIJE',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              ceremony.isEmpty
                  ? 'Ceremonija još nema datum i vreme.'
                  : ceremony,
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
    );
  }
}
