import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/format/app_filename_format.dart';
import '../../../../core/utils/export_utils.dart';
import '../data/parte_template_repository.dart';
import '../domain/parte_models.dart';

class ParteTemplateManagementDialog extends StatefulWidget {
  const ParteTemplateManagementDialog({
    super.key,
    required this.repository,
    required this.actor,
    required this.currentDraft,
  });

  final ParteTemplateRepository repository;
  final KorisniciData actor;
  final ParteDraft currentDraft;

  @override
  State<ParteTemplateManagementDialog> createState() =>
      _ParteTemplateManagementDialogState();
}

class _ParteTemplateManagementDialogState
    extends State<ParteTemplateManagementDialog> {
  List<ParteTemplate> _templates = const [];
  String? _selectedId;
  String _defaultId = parteBuiltinTemplateId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final templates = await widget.repository.listTemplates();
    final resolution = await widget.repository.resolveActiveTemplate();
    if (!mounted) return;
    setState(() {
      _templates = templates;
      _defaultId = resolution.template.id;
      _selectedId ??= templates.first.id;
      if (!templates.any((template) => template.id == _selectedId)) {
        _selectedId = templates.first.id;
      }
      _loading = false;
    });
  }

  ParteTemplate get _selected =>
      _templates.firstWhere((template) => template.id == _selectedId);

  ParteTemplate get _currentTechnical => ParteTemplate(
    id: 'technical_source',
    name: 'technical_source',
    widthMm: widget.currentDraft.widthMm,
    heightMm: widget.currentDraft.heightMm,
    marginMm: 5,
    blocks: widget.currentDraft.blocks,
  );

  Future<String?> _askName(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'NAZIV ŠABLONA',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('SAČUVAJ'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveCurrentAsNew() async {
    final name = await _askName('Novi FIRMA PARTE šablon');
    if (name == null || name.isEmpty) return;
    await _run(() async {
      final created = await widget.repository.createUserTemplate(
        actor: widget.actor,
        name: name,
        technicalSource: _currentTechnical,
      );
      _selectedId = created.id;
    });
  }

  Future<void> _duplicate() async {
    final name = await _askName(
      'Dupliraj šablon',
      initial: '${_selected.name} — kopija',
    );
    if (name == null || name.isEmpty) return;
    await _run(() async {
      final created = await widget.repository.duplicate(
        actor: widget.actor,
        source: _selected,
        name: name,
      );
      _selectedId = created.id;
    });
  }

  Future<void> _rename() async {
    final name = await _askName('Preimenuj šablon', initial: _selected.name);
    if (name == null || name.isEmpty) return;
    await _run(
      () => widget.repository.rename(
        actor: widget.actor,
        id: _selected.id,
        newName: name,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši korisnički šablon'),
        content: Text(
          'Obrisati „${_selected.name}“? Ako je podrazumevan, ugrađeni standard postaje vidljivi fallback.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRIŠI'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      () => widget.repository.delete(actor: widget.actor, id: _selected.id),
    );
  }

  Future<void> _export() async {
    await _run(() async {
      final source = widget.repository.exportTemplate(_selected);
      final filename = joinFilenameParts([
        'OPC',
        'PARTE',
        'SABLON',
        _selected.name,
      ], 'json');
      final file = await sacuvajKoriceDokumentFajlDetalji(
        filename,
        Uint8List.fromList(utf8.encode(source)),
        mimeType: 'application/json',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Šablon izvezen: ${koriceFajlLokacija(file)}')),
      );
    });
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = picked?.files.single.bytes;
    if (bytes == null) return;
    if (!mounted) return;
    final conflict = await showDialog<ParteTemplateImportConflict>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uvoz FIRMA PARTE šablona'),
        content: const Text(
          'Ako identitet šablona već postoji, izaberite pravilo konflikta.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, ParteTemplateImportConflict.cancel),
            child: const Text('ODUSTANI'),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(ctx, ParteTemplateImportConflict.importAsCopy),
            child: const Text('UVEZI KAO KOPIJU'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, ParteTemplateImportConflict.replace),
            child: const Text('ZAMENI'),
          ),
        ],
      ),
    );
    if (conflict == null || conflict == ParteTemplateImportConflict.cancel) {
      return;
    }
    await _run(() async {
      final imported = await widget.repository.importTemplate(
        actor: widget.actor,
        bytes: bytes,
        conflict: conflict,
      );
      if (imported != null) _selectedId = imported.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('FIRMA PARTE ŠABLONI'),
      content: SizedBox(
        width: 620,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedId,
                      decoration: const InputDecoration(
                        labelText: 'ŠABLON',
                        border: OutlineInputBorder(),
                      ),
                      items: _templates
                          .map(
                            (template) => DropdownMenuItem(
                              value: template.id,
                              child: Text(
                                '${template.name}${template.id == _defaultId ? ' — PODRAZUMEVAN' : ''}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedId = value),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selected.builtIn
                          ? 'Ugrađeni šablon je nepromenljiv. Može se duplirati.'
                          : 'Korisnički šablon sadrži samo tehnički raspored i stil.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => _run(
                            () => widget.repository.setDefault(
                              templateId: _selected.id,
                              actor: widget.actor,
                            ),
                          ),
                          child: const Text('POSTAVI KAO PODRAZUMEVAN'),
                        ),
                        OutlinedButton(
                          onPressed: _duplicate,
                          child: const Text('DUPLIRAJ'),
                        ),
                        FilledButton.tonal(
                          onPressed: _saveCurrentAsNew,
                          child: const Text(
                            'SAČUVAJ TRENUTNI RASPORED KAO NOVI',
                          ),
                        ),
                        if (!_selected.builtIn) ...[
                          OutlinedButton(
                            onPressed: _rename,
                            child: const Text('PREIMENUJ'),
                          ),
                          OutlinedButton(
                            onPressed: () => _run(
                              () => widget.repository.updateTechnicalLayout(
                                actor: widget.actor,
                                id: _selected.id,
                                technicalSource: _currentTechnical,
                              ),
                            ),
                            child: const Text('PRIMENI TRENUTNI RASPORED'),
                          ),
                          OutlinedButton(
                            onPressed: _export,
                            child: const Text('IZVEZI'),
                          ),
                          OutlinedButton(
                            onPressed: _delete,
                            child: const Text('OBRIŠI'),
                          ),
                        ],
                        OutlinedButton(
                          onPressed: _import,
                          child: const Text('UVEZI'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ZATVORI'),
        ),
      ],
    );
  }
}
