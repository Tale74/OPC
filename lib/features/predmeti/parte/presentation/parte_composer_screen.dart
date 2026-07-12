import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../../core/utils/export_utils.dart';
import '../../data/predmeti_repository.dart';
import '../application/parte_preparation_service.dart';
import '../data/parte_media_store.dart';
import '../data/parte_preparation_repository.dart';
import '../data/parte_template_repository.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_models.dart';
import '../pdf/parte_pdf_renderer.dart';
import 'parte_template_management_dialog.dart';

class ParteComposerScreen extends StatefulWidget {
  const ParteComposerScreen({
    super.key,
    required this.predmetId,
    required this.predmetiRepository,
    required this.actor,
    required this.entitlement,
  });

  final int predmetId;
  final PredmetiRepository predmetiRepository;
  final KorisniciData actor;
  final OpcEntitlementPolicy entitlement;

  @override
  State<ParteComposerScreen> createState() => _ParteComposerScreenState();
}

class _ParteComposerScreenState extends State<ParteComposerScreen> {
  late final PartePreparationRepository _repository;
  late final ParteMediaStore _mediaStore;
  late final PartePreparationService _service;
  late final PartePdfExportService _pdfService;
  late final ParteTemplateRepository _templateRepository;

  PartePripremeData? _preparation;
  PredmetiData? _predmet;
  ParteDraft? _draft;
  ParteRenderPlan? _plan;
  bool _loading = true;
  bool _busy = false;
  bool _sourceChanged = false;
  String? _error;
  String _selectedBlockId = 'name';
  final Map<String, TextEditingController> _textControllers = {};
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _repository = PartePreparationRepository(widget.predmetiRepository.db);
    _mediaStore = ParteMediaStore();
    _service = PartePreparationService(
      repository: _repository,
      mediaStore: _mediaStore,
    );
    _pdfService = PartePdfExportService(
      renderer: PartePdfRenderer(mediaStore: _mediaStore),
      repository: _repository,
    );
    _templateRepository = ParteTemplateRepository(widget.predmetiRepository.db);
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _initialize();
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final preparation = await _repository.initializeOrResume(
        predmetId: widget.predmetId,
        actor: widget.actor,
        entitlement: widget.entitlement,
      );
      if (preparation.cleanupPending) {
        try {
          await _service.retryCleanup(preparation);
        } catch (_) {
          // Visible terminal cleanup-pending state is loaded below.
        }
      }
      await _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _reload() async {
    final preparation = await _repository.findForPredmet(widget.predmetId);
    final predmet = await widget.predmetiRepository.getPredmet(
      widget.predmetId,
    );
    if (preparation == null) throw StateError('PARTE priprema nije pronađena.');
    ParteDraft? draft;
    ParteRenderPlan? plan;
    var sourceChanged = false;
    if (PartePreparationStatus.fromDb(preparation.status) ==
        PartePreparationStatus.inProgress) {
      draft = ParteDraft.decode(preparation.draftJson);
      plan = await _service.buildPlan(preparation: preparation);
      sourceChanged = await _repository.sourceChanged(preparation.id);
    }
    if (!mounted) return;
    _replaceControllers(draft);
    setState(() {
      _preparation = preparation;
      _predmet = predmet;
      _draft = draft;
      _plan = plan;
      _sourceChanged = sourceChanged;
      _widthController.text = draft?.widthMm.toStringAsFixed(1) ?? '';
      _heightController.text = draft?.heightMm.toStringAsFixed(1) ?? '';
      _loading = false;
      _busy = false;
      _error = null;
    });
  }

  void _replaceControllers(ParteDraft? draft) {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    if (draft == null) return;
    for (final entry in draft.textByBlock.entries) {
      _textControllers[entry.key] = TextEditingController(text: entry.value);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveText() => _run(() async {
    final preparation = _preparation!;
    final draft = _draft!;
    final text = {
      for (final entry in _textControllers.entries) entry.key: entry.value.text,
    };
    await _repository.updateDraft(
      preparationId: preparation.id,
      draft: draft.copyWith(textByBlock: text),
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _applyDimensions() => _run(() async {
    final width = double.tryParse(_widthController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (width == null || height == null) {
      throw const FormatException('Unesite numeričke dimenzije.');
    }
    await _repository.updateDraft(
      preparationId: _preparation!.id,
      draft: _draft!.copyWith(widthMm: width, heightMm: height),
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _modifySelected({
    double dx = 0,
    double dy = 0,
    double fontDelta = 0,
    bool? bold,
    ParteTextAlign? alignment,
  }) => _run(() async {
    final draft = _draft!;
    final blocks = draft.blocks
        .map((block) {
          if (block.id != _selectedBlockId) return block;
          final rect =
              ParteRectMm(
                x: block.rect.x + dx,
                y: block.rect.y + dy,
                width: block.rect.width,
                height: block.rect.height,
              ).clampTo(
                pageWidth: draft.widthMm,
                pageHeight: draft.heightMm,
                margin: 5,
              );
          return block.copyWith(
            rect: rect,
            initialFontSize: (block.initialFontSize + fontDelta).clamp(
              block.minimumFontSize,
              block.maximumFontSize,
            ),
            bold: bold,
            alignment: alignment,
          );
        })
        .toList(growable: false);
    await _repository.updateDraft(
      preparationId: _preparation!.id,
      draft: draft.copyWith(blocks: blocks),
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _moveBlockByDrag(String id, double dxMm, double dyMm) async {
    _selectedBlockId = id;
    await _modifySelected(dx: dxMm, dy: dyMm);
  }

  Future<Uint8List?> _pickImageBytes(ParteMediaKind kind) async {
    if (Platform.isAndroid) {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: kind == ParteMediaKind.photo ? 95 : 100,
        maxWidth: ParteMediaStore.normalizedLongEdge.toDouble(),
        maxHeight: ParteMediaStore.normalizedLongEdge.toDouble(),
      );
      return picked?.readAsBytes();
    }
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    return picked?.files.single.bytes;
  }

  Future<void> _importMedia(ParteMediaKind kind) => _run(() async {
    final bytes = await _pickImageBytes(kind);
    if (bytes == null) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    final result = await _service.replaceMedia(
      preparation: _preparation!,
      sourceBytes: bytes,
      kind: kind,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.lowResolution
              ? 'Slika je sačuvana (${result.width}×${result.height}); proverite upozorenje o kvalitetu.'
              : 'App-owned kopija slike je bezbedno sačuvana.',
        ),
      ),
    );
  });

  Future<void> _removeMedia(ParteMediaKind kind) => _run(() async {
    await _service.removeMedia(
      preparation: _preparation!,
      kind: kind,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _acknowledge({
    bool? noPhoto,
    bool? noCustom,
    bool? lowResolution,
    bool? grammar,
  }) => _run(() async {
    await _repository.updateAcknowledgements(
      preparationId: _preparation!.id,
      actor: widget.actor,
      entitlement: widget.entitlement,
      noPhotoAccepted: noPhoto,
      noCustomSymbolAccepted: noCustom,
      lowResolutionAccepted: lowResolution,
      grammarVerified: grammar,
    );
    await _reload();
  });

  Future<void> _confirmPreview() => _run(() async {
    await _repository.confirmPreview(
      preparationId: _preparation!.id,
      plan: _plan!,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _exportPdf() => _run(() async {
    final result = await _pdfService.export(
      preparation: _preparation!,
      predmet: _predmet!,
      plan: _plan!,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
    if (!mounted) return;
    prikaziPdfExportSuccessSnackBar(
      context,
      poruka: 'PARTA PDF uspešno izvezen: ${koriceFajlLokacija(result.file)}',
      fajl: result.file,
    );
  });

  Future<void> _complete() => _run(() async {
    try {
      await _service.completeAndCleanup(
        preparation: _preparation!,
        plan: _plan!,
        actor: widget.actor,
        entitlement: widget.entitlement,
      );
    } catch (error) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Priprema je završena, ali je tehničko čišćenje ostalo na čekanju: $error',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  });

  Future<void> _refreshFromPredmet() => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ponovo sastavi iz PREDMETA'),
        content: const Text(
          'Aktuelni privremeni tekst i raspored biće zamenjeni novim početnim predlogom. PREDMET neće biti izmenjen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('PONOVO SASTAVI'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    await _repository.rebuildFromPredmet(
      preparationId: _preparation!.id,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _manageTemplates() async {
    await showDialog<void>(
      context: context,
      builder: (_) => ParteTemplateManagementDialog(
        repository: _templateRepository,
        actor: widget.actor,
        currentDraft: _draft!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('PARTE PRIPREMA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PARTE PRIPREMA')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final status = PartePreparationStatus.fromDb(_preparation!.status);
    if (status != PartePreparationStatus.inProgress) {
      return Scaffold(
        appBar: AppBar(title: const Text('PARTE PRIPREMA')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              status == PartePreparationStatus.completed
                  ? 'PRIPREMA JE ZAVRŠENA. Izvezeni PDF ostaje u KORICE.'
                  : 'PRIPREMA JE ZAVRŠENA. Tehničko čišćenje app kopija čeka ponovni pokušaj.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final isNarrow = MediaQuery.sizeOf(context).width < 760;
    final editor = _buildEditor(context);
    final preview = _buildPreviewAndActions(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('PARTE — ${_predmet!.brojPredmeta}'),
        actions: [
          if (widget.actor.uloga == 'ADMINISTRATOR')
            IconButton(
              tooltip: 'FIRMA PARTE šabloni',
              onPressed: _busy ? null : _manageTemplates,
              icon: const Icon(Icons.dashboard_customize_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: isNarrow
            ? ListView(
                padding: const EdgeInsets.all(12),
                children: [editor, const SizedBox(height: 16), preview],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 420,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [editor],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [preview],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final textIds = _draft!.blocks
        .where((block) => block.kind == ParteBlockKind.text)
        .map((block) => block.id)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_sourceChanged)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PREDMET je promenjen posle početka pripreme. Privremeni tekst nije automatski prepisan.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : _refreshFromPredmet,
                    child: const Text('PONOVO SASTAVI IZ PREDMETA'),
                  ),
                ],
              ),
            ),
          ),
        Text(
          'TEKSTUALNI BLOKOVI',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        for (final id in textIds) ...[
          TextField(
            controller: _textControllers[id],
            minLines: id == 'mourners' || id == 'ceremony' ? 2 : 1,
            maxLines: id == 'mourners' || id == 'ceremony' ? 5 : 3,
            decoration: InputDecoration(
              labelText: _blockLabel(id),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          onPressed: _busy ? null : _saveText,
          icon: const Icon(Icons.save_outlined),
          label: const Text('SAČUVAJ PRIVREMENI TEKST'),
        ),
        const SizedBox(height: 16),
        Text('FORMAT (mm)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Širina',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Visina',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy ? null : _applyDimensions,
          child: const Text('PRIMENI DIMENZIJE — MARGINA 5 mm'),
        ),
        const SizedBox(height: 16),
        Text('MEDIJI', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: _busy
                  ? null
                  : () => _importMedia(ParteMediaKind.photo),
              icon: const Icon(Icons.photo_outlined),
              label: Text(
                _preparation!.photoMediaKey == null
                    ? 'UNESI FOTOGRAFIJU'
                    : 'ZAMENI FOTOGRAFIJU',
              ),
            ),
            if (_preparation!.photoMediaKey != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _removeMedia(ParteMediaKind.photo),
                child: const Text('UKLONI FOTOGRAFIJU'),
              ),
            if (_draft!.symbolId == 'SLOBODAN_IZBOR')
              FilledButton.tonalIcon(
                onPressed: _busy
                    ? null
                    : () => _importMedia(ParteMediaKind.customSymbol),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _preparation!.customSymbolMediaKey == null
                      ? 'UNESI SLOBODAN SIMBOL'
                      : 'ZAMENI SLOBODAN SIMBOL',
                ),
              ),
            if (_preparation!.customSymbolMediaKey != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _removeMedia(ParteMediaKind.customSymbol),
                child: const Text('UKLONI SLOBODAN SIMBOL'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'PRECIZNO POMERANJE I STIL',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedBlockId,
          decoration: const InputDecoration(
            labelText: 'Blok',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _draft!.blocks
              .map(
                (block) => DropdownMenuItem(
                  value: block.id,
                  child: Text(_blockLabel(block.id)),
                ),
              )
              .toList(),
          onChanged: (value) =>
              setState(() => _selectedBlockId = value ?? _selectedBlockId),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(dx: -1),
              icon: const Icon(Icons.arrow_left),
              tooltip: 'Levo 1 mm',
            ),
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(dx: 1),
              icon: const Icon(Icons.arrow_right),
              tooltip: 'Desno 1 mm',
            ),
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(dy: -1),
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Gore 1 mm',
            ),
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(dy: 1),
              icon: const Icon(Icons.arrow_downward),
              tooltip: 'Dole 1 mm',
            ),
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(fontDelta: -0.5),
              icon: const Icon(Icons.text_decrease),
              tooltip: 'Manji font',
            ),
            IconButton.filledTonal(
              onPressed: _busy ? null : () => _modifySelected(fontDelta: 0.5),
              icon: const Icon(Icons.text_increase),
              tooltip: 'Veći font',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewAndActions(BuildContext context) {
    final plan = _plan!;
    final previewConfirmed =
        _preparation!.previewConfirmedFingerprint == plan.fingerprint;
    final exported =
        _preparation!.exportedSuccessfully &&
        _preparation!.exportedRenderFingerprint == plan.fingerprint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'FINALNI WYSIWYG PREVIEW',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(48),
          child: PartePlanPreview(
            plan: plan,
            mediaStore: _mediaStore,
            onBlockMoved: _busy ? null : _moveBlockByDrag,
          ),
        ),
        const SizedBox(height: 12),
        for (final warning in plan.warnings)
          ListTile(
            dense: true,
            leading: const Icon(
              Icons.warning_amber_outlined,
              color: Colors.orange,
            ),
            title: Text(warning),
          ),
        for (final blocker in plan.blockers)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.block_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(blocker),
          ),
        if (plan.warnings.any((value) => value.startsWith('Fotografija nije')))
          CheckboxListTile(
            value: _preparation!.noPhotoAccepted,
            onChanged: _busy
                ? null
                : (value) => _acknowledge(noPhoto: value ?? false),
            title: const Text('Potvrđujem nastavak bez fotografije'),
          ),
        if (plan.warnings.any((value) => value.startsWith('SLOBODAN IZBOR')))
          CheckboxListTile(
            value: _preparation!.noCustomSymbolAccepted,
            onChanged: _busy
                ? null
                : (value) => _acknowledge(noCustom: value ?? false),
            title: const Text(
              'Potvrđujem nastavak bez unetog slobodnog simbola',
            ),
          ),
        if (plan.warnings.any((value) => value.contains('niske rezolucije')))
          CheckboxListTile(
            value: _preparation!.lowResolutionAccepted,
            onChanged: _busy
                ? null
                : (value) => _acknowledge(lowResolution: value ?? false),
            title: const Text('Prihvatam upozorenje o kvalitetu fotografije'),
          ),
        if (plan.warnings.any((value) => value.contains('Gramatički')))
          CheckboxListTile(
            value: _preparation!.grammarVerified,
            onChanged: _busy
                ? null
                : (value) => _acknowledge(grammar: value ?? false),
            title: const Text(
              'Proverio/la sam gramatički oblik privremenog teksta',
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _busy || !plan.canConfirmPreview
                  ? null
                  : _confirmPreview,
              icon: Icon(
                previewConfirmed ? Icons.verified : Icons.preview_outlined,
              ),
              label: Text(
                previewConfirmed
                    ? 'PREVIEW POTVRĐEN'
                    : 'POTVRDI FINALNI PREVIEW',
              ),
            ),
            FilledButton.icon(
              onPressed: _busy || !previewConfirmed ? null : _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                exported ? 'PONOVO IZVEZI PARTA PDF' : 'IZVEZI PARTA PDF',
              ),
            ),
            FilledButton.icon(
              onPressed: _busy || !exported ? null : _complete,
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              icon: const Icon(Icons.task_alt_outlined),
              label: const Text('PRIPREMA ZAVRŠENA'),
            ),
          ],
        ),
      ],
    );
  }

  String _blockLabel(String id) => switch (id) {
    'intro' => 'Uvodna fraza',
    'name' => 'Ime i prezime',
    'profession' => 'Titula / zanimanje / čin',
    'years' => 'Godine života',
    'death' => 'Obaveštenje o smrti',
    'ceremony' => 'Ceremonija',
    'secondary' => 'OPELO / ISPRAĆAJ',
    'mourners' => 'Ožalošćeni',
    'photo' => 'Fotografija',
    'symbol' => 'Simbol',
    _ => id,
  };
}

class PartePlanPreview extends StatelessWidget {
  const PartePlanPreview({
    super.key,
    required this.plan,
    required this.mediaStore,
    this.onBlockMoved,
  });

  final ParteRenderPlan plan;
  final ParteMediaStore mediaStore;
  final Future<void> Function(String id, double dxMm, double dyMm)?
  onBlockMoved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: plan.widthMm / plan.heightMm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / plan.widthMm;
          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                for (final block in plan.blocks)
                  Positioned(
                    left: block.rect.x * scale,
                    top: block.rect.y * scale,
                    width: block.rect.width * scale,
                    height: block.rect.height * scale,
                    child: _DraggableParteBlock(
                      block: block,
                      scale: scale,
                      mediaStore: mediaStore,
                      onMoved: onBlockMoved,
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

class _DraggableParteBlock extends StatefulWidget {
  const _DraggableParteBlock({
    required this.block,
    required this.scale,
    required this.mediaStore,
    required this.onMoved,
  });

  final ParteRenderBlock block;
  final double scale;
  final ParteMediaStore mediaStore;
  final Future<void> Function(String id, double dxMm, double dyMm)? onMoved;

  @override
  State<_DraggableParteBlock> createState() => _DraggableParteBlockState();
}

class _DraggableParteBlockState extends State<_DraggableParteBlock> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: widget.onMoved == null
            ? null
            : (details) => setState(() => _offset += details.delta),
        onPanEnd: widget.onMoved == null
            ? null
            : (_) async {
                final delta = _offset;
                setState(() => _offset = Offset.zero);
                await widget.onMoved!(
                  widget.block.id,
                  delta.dx / widget.scale,
                  delta.dy / widget.scale,
                );
              },
        child: _content(),
      ),
    );
  }

  Widget _content() {
    final block = widget.block;
    if (block.kind == ParteBlockKind.text) {
      return Align(
        alignment: switch (block.alignment) {
          ParteTextAlign.left => Alignment.topLeft,
          ParteTextAlign.center => Alignment.topCenter,
          ParteTextAlign.right => Alignment.topRight,
        },
        child: Text(
          block.lines.join('\n'),
          maxLines: block.lines.length,
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: switch (block.alignment) {
            ParteTextAlign.left => TextAlign.left,
            ParteTextAlign.center => TextAlign.center,
            ParteTextAlign.right => TextAlign.right,
          },
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'NotoSans',
            fontSize: block.fontSize * widget.scale * 25.4 / 72,
            height: 1.22,
            fontWeight: block.bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      );
    }
    if (block.mediaKey != null) {
      return FutureBuilder<Uint8List>(
        future: widget.mediaStore.read(block.mediaKey!),
        builder: (context, snapshot) => snapshot.hasData
            ? Image.memory(snapshot.data!, fit: BoxFit.contain)
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Container(
      color: Colors.white,
      child: Image.asset(block.assetPath!, fit: BoxFit.contain),
    );
  }
}
