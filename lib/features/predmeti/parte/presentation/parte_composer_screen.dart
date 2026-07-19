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
import '../data/parte_print_profile_store.dart';
import '../data/parte_template_repository.dart';
import '../domain/parte_composer.dart';
import '../domain/parte_image_effects.dart';
import '../domain/parte_models.dart';
import '../docx/parte_docx_exporter.dart';
import '../pdf/parte_pdf_renderer.dart';
import 'parte_template_management_dialog.dart';

class ParteComposerScreen extends StatefulWidget {
  const ParteComposerScreen({
    super.key,
    required this.predmetId,
    required this.predmetiRepository,
    required this.actor,
    required this.entitlement,
    this.printProfileStore,
  });

  final int predmetId;
  final PredmetiRepository predmetiRepository;
  final KorisniciData actor;
  final OpcEntitlementPolicy entitlement;
  final PartePrintProfileStore? printProfileStore;

  @override
  State<ParteComposerScreen> createState() => _ParteComposerScreenState();
}

class _ParteComposerScreenState extends State<ParteComposerScreen> {
  late final PartePreparationRepository _repository;
  late final ParteMediaStore _mediaStore;
  late final PartePreparationService _service;
  late final PartePdfExportService _pdfService;
  late final ParteDocxExporter _docxExporter;
  late final ParteTemplateRepository _templateRepository;
  late final PartePrintProfileStore _printProfileStore;

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
  late final TextEditingController _horizontalMarginController;
  late final TextEditingController _verticalMarginController;
  late final TextEditingController _zoneWidthController;
  late final TextEditingController _zoneHeightController;
  late final TextEditingController _printHorizontalController;
  late final TextEditingController _printVerticalController;
  late final TextEditingController _fontSizeController;
  PartePrintProfile _printProfile = const PartePrintProfile();
  bool _textExpanded = true;
  bool _formatExpanded = true;

  @override
  void initState() {
    super.initState();
    _repository = PartePreparationRepository(widget.predmetiRepository.db);
    _printProfileStore = widget.printProfileStore ?? PartePrintProfileStore();
    _mediaStore = ParteMediaStore();
    _service = PartePreparationService(
      repository: _repository,
      mediaStore: _mediaStore,
    );
    _pdfService = PartePdfExportService(
      renderer: PartePdfRenderer(mediaStore: _mediaStore),
      repository: _repository,
    );
    _docxExporter = ParteDocxExporter(mediaStore: _mediaStore);
    _templateRepository = ParteTemplateRepository(widget.predmetiRepository.db);
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _horizontalMarginController = TextEditingController();
    _verticalMarginController = TextEditingController();
    _zoneWidthController = TextEditingController();
    _zoneHeightController = TextEditingController();
    _printHorizontalController = TextEditingController(text: '0.0');
    _printVerticalController = TextEditingController(text: '0.0');
    _fontSizeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize();
    });
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _widthController.dispose();
    _heightController.dispose();
    _horizontalMarginController.dispose();
    _verticalMarginController.dispose();
    _zoneWidthController.dispose();
    _zoneHeightController.dispose();
    _printHorizontalController.dispose();
    _printVerticalController.dispose();
    _fontSizeController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _printProfile = await _printProfileStore.load();
      _printHorizontalController.text = _printProfile.horizontalCorrectionMm
          .toStringAsFixed(1);
      _printVerticalController.text = _printProfile.verticalCorrectionMm
          .toStringAsFixed(1);
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
    if (PartePreparationStatus.fromDb(preparation.status) !=
        PartePreparationStatus.cleanupPending) {
      draft = ParteDraft.decode(preparation.draftJson);
      plan = await _service.buildPlan(preparation: preparation);
      sourceChanged = await _repository.sourceChanged(preparation.id);
    }
    if (!mounted) return;
    _replaceControllers(draft);
    if (draft != null) {
      final selected = draft.blocks.firstWhere(
        (block) => block.id == _selectedBlockId,
        orElse: () => draft!.blocks.first,
      );
      _fontSizeController.text = selected.initialFontSize.toStringAsFixed(1);
    }
    setState(() {
      _preparation = preparation;
      _predmet = predmet;
      _draft = draft;
      _plan = plan;
      _sourceChanged = sourceChanged;
      _widthController.text = draft?.widthMm.toStringAsFixed(1) ?? '';
      _heightController.text = draft?.heightMm.toStringAsFixed(1) ?? '';
      _horizontalMarginController.text =
          draft?.horizontalMarginMm.toStringAsFixed(1) ?? '';
      _verticalMarginController.text =
          draft?.verticalMarginMm.toStringAsFixed(1) ?? '';
      _zoneWidthController.text =
          draft?.printableZoneWidthMm.toStringAsFixed(1) ?? '';
      _zoneHeightController.text =
          draft?.printableZoneHeightMm.toStringAsFixed(1) ?? '';
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
    final horizontalMargin = double.tryParse(
      _horizontalMarginController.text.replaceAll(',', '.'),
    );
    final verticalMargin = double.tryParse(
      _verticalMarginController.text.replaceAll(',', '.'),
    );
    final zoneWidth = double.tryParse(
      _zoneWidthController.text.replaceAll(',', '.'),
    );
    final zoneHeight = double.tryParse(
      _zoneHeightController.text.replaceAll(',', '.'),
    );
    if (width == null ||
        height == null ||
        horizontalMargin == null ||
        verticalMargin == null ||
        zoneWidth == null ||
        zoneHeight == null) {
      throw const FormatException(
        'Unesite numeričke dimenzije, zonu i margine.',
      );
    }
    if (horizontalMargin < 0 ||
        verticalMargin < 0 ||
        zoneWidth <= 0 ||
        zoneHeight <= 0 ||
        zoneWidth > width ||
        zoneHeight > height ||
        horizontalMargin * 2 >= zoneWidth ||
        verticalMargin * 2 >= zoneHeight) {
      throw const FormatException(
        'Zona štampe ili njene sigurne margine nisu bezbedne.',
      );
    }
    final zoneX = (width - zoneWidth) / 2;
    final zoneY = (height - zoneHeight) / 2;
    await _repository.updateDraft(
      preparationId: _preparation!.id,
      draft: _draft!.reflowTo(
        widthMm: width,
        heightMm: height,
        horizontalMarginMm: horizontalMargin,
        verticalMarginMm: verticalMargin,
        printableZoneXmm: zoneX,
        printableZoneYmm: zoneY,
        printableZoneWidthMm: zoneWidth,
        printableZoneHeightMm: zoneHeight,
      ),
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _applyPrintCorrection() => _run(() async {
    final horizontal = double.tryParse(
      _printHorizontalController.text.replaceAll(',', '.'),
    );
    final vertical = double.tryParse(
      _printVerticalController.text.replaceAll(',', '.'),
    );
    if (horizontal == null ||
        vertical == null ||
        horizontal.abs() > 25 ||
        vertical.abs() > 25) {
      throw const FormatException(
        'Korekcija štampe mora biti između −25 i +25 mm.',
      );
    }
    final profile = PartePrintProfile(
      horizontalCorrectionMm: horizontal,
      verticalCorrectionMm: vertical,
    );
    await _printProfileStore.save(profile);
    if (!mounted) return;
    setState(() {
      _printProfile = profile;
      _busy = false;
    });
  });

  Future<void> _resetPrintCorrection() => _run(() async {
    await _printProfileStore.reset();
    if (!mounted) return;
    setState(() {
      _printProfile = const PartePrintProfile();
      _printHorizontalController.text = '0.0';
      _printVerticalController.text = '0.0';
      _busy = false;
    });
  });

  Future<void> _modifySelected({
    double dx = 0,
    double dy = 0,
    double widthDelta = 0,
    double heightDelta = 0,
    double fontDelta = 0,
    double? fontSize,
    bool? bold,
    ParteTextAlign? alignment,
    String? fontFamily,
    bool? lockAspectRatio,
    double? brightness,
    double? contrast,
    double? sharpness,
    bool? grayscale,
    bool? border,
    ParteImageShape? imageShape,
  }) => _run(() async {
    final draft = _draft!;
    final blocks = draft.blocks
        .map((block) {
          if (block.id != _selectedBlockId) return block;
          var nextWidth = (block.rect.width + widthDelta)
              .clamp(5, draft.widthMm - 10)
              .toDouble();
          var nextHeight = (block.rect.height + heightDelta)
              .clamp(5, draft.heightMm - 10)
              .toDouble();
          if (block.kind != ParteBlockKind.text && block.lockAspectRatio) {
            final ratio =
                block.sourceAspectRatio ?? block.rect.width / block.rect.height;
            if (widthDelta != 0) nextHeight = nextWidth / ratio;
            if (heightDelta != 0) nextWidth = nextHeight * ratio;
          }
          var rect =
              ParteRectMm(
                x: block.rect.x + dx,
                y: block.rect.y + dy,
                width: nextWidth,
                height: nextHeight,
              ).clampTo(
                pageWidth: draft.widthMm,
                pageHeight: draft.heightMm,
                horizontalMargin: draft.horizontalMarginMm,
                verticalMargin: draft.verticalMarginMm,
                originX: draft.printableZoneXmm,
                originY: draft.printableZoneYmm,
                usableWidth: draft.printableZoneWidthMm,
                usableHeight: draft.printableZoneHeightMm,
              );
          if ((dx != 0 || dy != 0) && widthDelta == 0 && heightDelta == 0) {
            rect = _snapRect(rect, block.id, draft);
          }
          return block.copyWith(
            rect: rect,
            initialFontSize: (fontSize ?? block.initialFontSize + fontDelta)
                .clamp(block.minimumFontSize, block.maximumFontSize),
            bold: bold,
            alignment: alignment,
            fontFamily: fontFamily,
            lockAspectRatio: lockAspectRatio,
            brightness: brightness,
            contrast: contrast,
            sharpness: sharpness,
            grayscale: grayscale,
            border: border,
            imageShape: imageShape,
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

  Future<void> _applyFontSizeInput() async {
    final value = double.tryParse(
      _fontSizeController.text.trim().replaceAll(',', '.'),
    );
    final block = _draft!.blocks.firstWhere(
      (item) => item.id == _selectedBlockId,
    );
    if (value == null ||
        value < block.minimumFontSize ||
        value > block.maximumFontSize) {
      _fontSizeController.text = block.initialFontSize.toStringAsFixed(1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veličina fonta mora biti od '
              '${block.minimumFontSize.toStringAsFixed(1)} do '
              '${block.maximumFontSize.toStringAsFixed(1)} pt.',
            ),
          ),
        );
      }
      return;
    }
    await _modifySelected(fontSize: value);
  }

  Future<void> _resetSelectedSize() => _run(() async {
    final draft = _draft!;
    final template = _repository.templateSnapshot(_preparation!);
    ParteBlockSpec? reference;
    for (final block in template.blocks) {
      if (block.id == _selectedBlockId) {
        reference = block;
        break;
      }
    }
    final referenceBlock = reference;
    if (referenceBlock == null) {
      throw StateError('Šablon nema referentnu veličinu izabranog bloka.');
    }
    final blocks = draft.blocks
        .map((block) {
          if (block.id != _selectedBlockId) return block;
          return block.copyWith(
            rect:
                ParteRectMm(
                  x: block.rect.x,
                  y: block.rect.y,
                  width: referenceBlock.rect.width,
                  height: referenceBlock.rect.height,
                ).clampTo(
                  pageWidth: draft.widthMm,
                  pageHeight: draft.heightMm,
                  horizontalMargin: draft.horizontalMarginMm,
                  verticalMargin: draft.verticalMarginMm,
                  originX: draft.printableZoneXmm,
                  originY: draft.printableZoneYmm,
                  usableWidth: draft.printableZoneWidthMm,
                  usableHeight: draft.printableZoneHeightMm,
                ),
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
    if (mounted) setState(() => _selectedBlockId = id);
    await _modifySelected(dx: dxMm, dy: dyMm);
  }

  ParteRectMm _snapRect(ParteRectMm rect, String blockId, ParteDraft draft) {
    const threshold = 1.5;
    final safeLeft = draft.printableZoneXmm + draft.horizontalMarginMm;
    final safeRight =
        draft.printableZoneXmm +
        draft.printableZoneWidthMm -
        draft.horizontalMarginMm;
    final center = draft.printableZoneXmm + draft.printableZoneWidthMm / 2;
    final xTargets = <double>[
      safeLeft,
      safeRight - rect.width,
      center - rect.width / 2,
    ];
    for (final other in draft.blocks.where((item) => item.id != blockId)) {
      xTargets.addAll([
        other.rect.x,
        other.rect.right - rect.width,
        other.rect.centerX - rect.width / 2,
        other.rect.right,
        other.rect.x - rect.width,
      ]);
    }
    var x = rect.x;
    for (final target in xTargets) {
      if ((x - target).abs() <= threshold) {
        x = target;
        break;
      }
    }
    return ParteRectMm(
      x: x,
      y: rect.y,
      width: rect.width,
      height: rect.height,
    ).clampTo(
      pageWidth: draft.widthMm,
      pageHeight: draft.heightMm,
      horizontalMargin: draft.horizontalMarginMm,
      verticalMargin: draft.verticalMarginMm,
      originX: draft.printableZoneXmm,
      originY: draft.printableZoneYmm,
      usableWidth: draft.printableZoneWidthMm,
      usableHeight: draft.printableZoneHeightMm,
    );
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
    final mediaBlockId = kind == ParteMediaKind.photo ? 'photo' : 'symbol';
    final ratio = result.width / result.height;
    final normalizedBlocks = _draft!.blocks
        .map((block) {
          if (block.id != mediaBlockId) return block;
          final normalized = block.rect
              .normalizedToAspectRatio(ratio)
              .clampTo(
                pageWidth: _draft!.widthMm,
                pageHeight: _draft!.heightMm,
                horizontalMargin: _draft!.horizontalMarginMm,
                verticalMargin: _draft!.verticalMarginMm,
                originX: _draft!.printableZoneXmm,
                originY: _draft!.printableZoneYmm,
                usableWidth: _draft!.printableZoneWidthMm,
                usableHeight: _draft!.printableZoneHeightMm,
              );
          return block.copyWith(rect: normalized, sourceAspectRatio: ratio);
        })
        .toList(growable: false);
    await _repository.updateDraft(
      preparationId: _preparation!.id,
      draft: _draft!.copyWith(blocks: normalizedBlocks),
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
      horizontalCorrectionMm: _printProfile.horizontalCorrectionMm,
      verticalCorrectionMm: _printProfile.verticalCorrectionMm,
    );
    await _reload();
    if (!mounted) return;
    prikaziPdfExportSuccessSnackBar(
      context,
      poruka: 'PARTA PDF uspešno izvezen: ${koriceFajlLokacija(result.file)}',
      fajl: result.file,
    );
  });

  Future<void> _exportDocx() => _run(() async {
    final result = await _docxExporter.export(plan: _plan!, predmet: _predmet!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PARTA DOCX uspešno izvezen: ${koriceFajlLokacija(result.file)}',
        ),
      ),
    );
    setState(() => _busy = false);
  });

  Future<void> _exportCalibrationPdf() => _run(() async {
    final result = await _pdfService.exportCalibration(plan: _plan!);
    if (!mounted) return;
    prikaziPdfExportSuccessSnackBar(
      context,
      poruka: 'Kalibracioni PDF je sačuvan. Štampajte uz Actual size / 100%.',
      fajl: result.file,
    );
    setState(() => _busy = false);
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

  Future<void> _resetPreparation() => _run(() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši pripremu i počni ponovo'),
        content: const Text(
          'Privremeni tekst, raspored i app-owned kopije fotografije/simbola biće obrisani. '
          'PREDMET i već izvezeni fajlovi neće biti menjani.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRIŠI I POČNI PONOVO'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    await _service.resetAndStartAgain(
      preparation: _preparation!,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload();
  });

  Future<void> _deleteRetainedPreparation() => _run(() async {
    final deceased = '${_predmet!.ime} ${_predmet!.prezime}'.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši sačuvanu pripremu'),
        content: Text(
          'Biće obrisani samo OPC priprema i njene app-owned kopije medija za '
          'PREDMET ${_predmet!.brojPredmeta} – $deceased.\n\n'
          'PREDMET, spoljašnji originali i već izvezeni PDF/DOCX fajlovi ostaju sačuvani.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRIŠI SAČUVANU PRIPREMU'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    await _service.deleteRetainedCompleted(
      preparation: _preparation!,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    if (mounted) Navigator.pop(context, true);
  });

  Future<void> _manageTemplates() async {
    final selected = await showDialog<ParteTemplate>(
      context: context,
      builder: (_) => ParteTemplateManagementDialog(
        repository: _templateRepository,
        actor: widget.actor,
        currentDraft: _draft!,
        activeTemplateId: _preparation!.templateId,
      ),
    );
    if (selected == null) return;
    await _run(() async {
      await _repository.applyTemplate(
        preparationId: _preparation!.id,
        currentDraft: _draft!,
        template: selected,
        actor: widget.actor,
        entitlement: widget.entitlement,
      );
      await _reload();
    });
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
    if (status == PartePreparationStatus.cleanupPending) {
      return Scaffold(
        appBar: AppBar(title: const Text('PARTE PRIPREMA')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Priprema čeka bezbedan oporavak zadržanog tehničkog stanja.',
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
        title: Text('PARTE – ${_predmet!.ime} ${_predmet!.prezime}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('PREDMET ${_predmet!.brojPredmeta}'),
          ),
        ),
        actions: [
          if (widget.actor.uloga == 'ADMINISTRATOR')
            IconButton(
              tooltip: 'Šabloni PARTE',
              onPressed: _busy ? null : _manageTemplates,
              icon: const Icon(Icons.dashboard_customize_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (status == PartePreparationStatus.completed)
              const MaterialBanner(
                content: Text(
                  'SAČUVANA ZAVRŠENA PRIPREMA – možete je pregledati, urediti i ponovo izvesti. Izmene traže novu potvrdu pregleda pripreme.',
                ),
                actions: [SizedBox.shrink()],
              ),
            Expanded(
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
    final selected = _draft!.blocks.firstWhere(
      (block) => block.id == _selectedBlockId,
      orElse: () => _draft!.blocks.first,
    );
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
        ExpansionTile(
          initiallyExpanded: _textExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          onExpansionChanged: (value) => _textExpanded = value,
          title: Text(
            'TEKSTUALNI BLOKOVI',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          children: [
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
          ],
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          initiallyExpanded: _formatExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          onExpansionChanged: (value) => _formatExpanded = value,
          title: Text(
            'FORMAT I ZONA ŠTAMPE (mm)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            '${_draft!.widthMm.toStringAsFixed(1)} × ${_draft!.heightMm.toStringAsFixed(1)} mm · '
            'zona ${_draft!.printableZoneWidthMm.toStringAsFixed(1)} × ${_draft!.printableZoneHeightMm.toStringAsFixed(1)} mm · '
            'margina ${_draft!.horizontalMarginMm.toStringAsFixed(1)} × ${_draft!.verticalMarginMm.toStringAsFixed(1)} mm',
          ),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dimensionField(_widthController, 'Strana – širina'),
                _dimensionField(_heightController, 'Strana – visina'),
                _dimensionField(_zoneWidthController, 'Zona štampe – širina'),
                _dimensionField(_zoneHeightController, 'Zona štampe – visina'),
                _dimensionField(
                  _horizontalMarginController,
                  'Sigurna margina – H',
                ),
                _dimensionField(
                  _verticalMarginController,
                  'Sigurna margina – V',
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _applyDimensions,
              child: const Text('PRIMENI FORMAT I ZONU ŠTAMPE'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'KOREKCIJA PROFILA ŠTAMPAČA',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const Tooltip(
                  message:
                      'Korekcija celog PDF otiska. Ne menja blokove, šablon ni DOCX.',
                  child: Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const Text('Korekcija celog PDF otiska'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dimensionField(_printHorizontalController, 'Levo / desno'),
                _dimensionField(_printVerticalController, 'Gore / dole'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : _applyPrintCorrection,
                  child: const Text('SAČUVAJ PROFIL ŠTAMPAČA'),
                ),
                TextButton(
                  onPressed: _busy ? null : _resetPrintCorrection,
                  child: const Text('RESETUJ NA 0'),
                ),
              ],
            ),
          ],
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
          onChanged: (value) {
            final next = value ?? _selectedBlockId;
            final block = _draft!.blocks.firstWhere((item) => item.id == next);
            setState(() {
              _selectedBlockId = next;
              _fontSizeController.text = block.initialFontSize.toStringAsFixed(
                1,
              );
            });
          },
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
          ],
        ),
        const SizedBox(height: 8),
        if (selected.kind == ParteBlockKind.text) ...[
          LayoutBuilder(
            key: const Key('parte-compact-font-row'),
            builder: (context, constraints) => Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: constraints.maxWidth < 360
                      ? constraints.maxWidth
                      : constraints.maxWidth - 214,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'parte-font-${selected.id}-${selected.fontFamily}',
                    ),
                    initialValue: selected.fontFamily,
                    decoration: const InputDecoration(
                      labelText: 'Font',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ParteFontCatalog.supported
                        .map(
                          (font) => DropdownMenuItem(
                            value: font,
                            child: Text(ParteFontCatalog.displayName(font)),
                          ),
                        )
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (value) => _modifySelected(fontFamily: value),
                  ),
                ),
                SizedBox(
                  width: 104,
                  child: TextField(
                    key: const Key('parte-font-size-state'),
                    controller: _fontSizeController,
                    enabled: !_busy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Veličina',
                      suffixText: 'pt',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _applyFontSizeInput(),
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _applyFontSizeInput();
                    },
                  ),
                ),
                IconButton.filledTonal(
                  onPressed:
                      _busy ||
                          selected.initialFontSize <= selected.minimumFontSize
                      ? null
                      : () => _modifySelected(fontDelta: -0.5),
                  icon: const Icon(Icons.text_decrease),
                  tooltip: 'Manji font',
                ),
                IconButton.filledTonal(
                  onPressed:
                      _busy ||
                          selected.initialFontSize >= selected.maximumFontSize
                      ? null
                      : () => _modifySelected(fontDelta: 0.5),
                  icon: const Icon(Icons.text_increase),
                  tooltip: 'Veći font',
                ),
              ],
            ),
          ),
          if (selected.initialFontSize <= selected.minimumFontSize)
            const Text(
              'Dostignut je najmanji font. Proširite ili povisite blok.',
            )
          else if (selected.initialFontSize >= selected.maximumFontSize)
            const Text(
              'Dostignut je najveći font. Proširite blok ili smanjite sadržaj.',
            ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: _busy ? null : () => _modifySelected(widthDelta: -1),
                child: const Text('SUZI'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _modifySelected(widthDelta: 1),
                child: const Text('PROŠIRI'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _modifySelected(heightDelta: -1),
                child: const Text('SNIZI'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _modifySelected(heightDelta: 1),
                child: const Text('POVISI'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<ParteTextAlign>(
            segments: const [
              ButtonSegment(
                value: ParteTextAlign.left,
                icon: Icon(Icons.format_align_left),
              ),
              ButtonSegment(
                value: ParteTextAlign.center,
                icon: Icon(Icons.format_align_center),
              ),
              ButtonSegment(
                value: ParteTextAlign.right,
                icon: Icon(Icons.format_align_right),
              ),
            ],
            selected: {selected.alignment},
            onSelectionChanged: _busy
                ? null
                : (value) => _modifySelected(alignment: value.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Podebljano'),
            value: selected.bold,
            onChanged: _busy ? null : (value) => _modifySelected(bold: value),
          ),
        ] else ...[
          Text(
            'Veličina: ${selected.rect.width.toStringAsFixed(1)} × '
            '${selected.rect.height.toStringAsFixed(1)} mm',
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (selected.lockAspectRatio) ...[
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(widthDelta: -1),
                  child: const Text('UMANJI'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(widthDelta: 1),
                  child: const Text('POVEĆAJ'),
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(widthDelta: -1),
                  child: const Text('UŽE'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(widthDelta: 1),
                  child: const Text('ŠIRE'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(heightDelta: -1),
                  child: const Text('NIŽE'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _modifySelected(heightDelta: 1),
                  child: const Text('VIŠE'),
                ),
              ],
              OutlinedButton(
                onPressed: _busy ? null : _resetSelectedSize,
                child: const Text('VRATI VELIČINU ŠABLONA'),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Zaključaj odnos stranica'),
            value: selected.lockAspectRatio,
            onChanged: _busy
                ? null
                : (value) => _modifySelected(lockAspectRatio: value),
          ),
          if (selected.kind == ParteBlockKind.photo) ...[
            _effectSlider(
              'Svetlina',
              selected.brightness,
              0.5,
              1.5,
              (value) => _modifySelected(brightness: value),
            ),
            _effectSlider(
              'Kontrast',
              selected.contrast,
              0.5,
              1.5,
              (value) => _modifySelected(contrast: value),
            ),
            _effectSlider(
              'Oštrina',
              selected.sharpness,
              0,
              1,
              (value) => _modifySelected(sharpness: value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Crno-belo'),
              value: selected.grayscale,
              onChanged: _busy
                  ? null
                  : (value) => _modifySelected(grayscale: value),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Okvir'),
            value: selected.border,
            onChanged: _busy ? null : (value) => _modifySelected(border: value),
          ),
          DropdownButtonFormField<ParteImageShape>(
            initialValue: selected.imageShape,
            decoration: const InputDecoration(
              labelText: 'Oblik',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: ParteImageShape.rectangle,
                child: Text('Pravougaonik'),
              ),
              DropdownMenuItem(
                value: ParteImageShape.roundedRectangle,
                child: Text('Zaobljeni pravougaonik'),
              ),
              DropdownMenuItem(
                value: ParteImageShape.oval,
                child: Text('Oval'),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) => _modifySelected(imageShape: value),
          ),
        ],
        const SizedBox(height: 16),
        if (PartePreparationStatus.fromDb(_preparation!.status) ==
            PartePreparationStatus.inProgress)
          OutlinedButton.icon(
            onPressed: _busy ? null : _resetPreparation,
            icon: const Icon(Icons.restart_alt),
            label: const Text('OBRIŠI PRIPREMU I POČNI NOVU'),
          )
        else
          OutlinedButton.icon(
            onPressed: _busy ? null : _deleteRetainedPreparation,
            icon: const Icon(Icons.delete_outline),
            label: const Text('OBRIŠI SAČUVANU PRIPREMU'),
          ),
      ],
    );
  }

  Widget _dimensionField(TextEditingController controller, String label) =>
      SizedBox(
        width: 190,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: 'mm',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  Widget _effectSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Row(
    children: [
      SizedBox(width: 76, child: Text(label)),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: 20,
          onChanged: _busy ? null : onChanged,
        ),
      ),
    ],
  );

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
          'PREGLED PRIPREME',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _ParteEditorTechnicalGuide(plan: plan, profile: _printProfile),
        const SizedBox(height: 8),
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(48),
          child: PartePlanPreview(
            plan: plan,
            mediaStore: _mediaStore,
            selectedBlockId: _selectedBlockId,
            onBlockSelected: (id) => setState(() => _selectedBlockId = id),
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
                    : 'POTVRDI PREGLED PRIPREME',
              ),
            ),
            FilledButton.icon(
              onPressed: _busy || !previewConfirmed ? null : _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                exported ? 'PONOVO IZVEZI PARTA PDF' : 'IZVEZI PARTA PDF',
              ),
            ),
            OutlinedButton.icon(
              onPressed: _busy || !previewConfirmed ? null : _exportDocx,
              icon: const Icon(Icons.description_outlined),
              label: const Text('IZVEZI PARTA DOCX'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _exportCalibrationPdf,
              icon: const Icon(Icons.straighten_outlined),
              label: const Text('IZVEZI KALIBRACIONI PDF'),
            ),
            if (PartePreparationStatus.fromDb(_preparation!.status) ==
                PartePreparationStatus.inProgress)
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
    'mournersHeading' => 'Naslov Ožalošćeni',
    'photo' => 'Fotografija',
    'symbol' => 'Simbol',
    _ => id,
  };
}

class _ParteEditorTechnicalGuide extends StatelessWidget {
  const _ParteEditorTechnicalGuide({required this.plan, required this.profile});

  final ParteRenderPlan plan;
  final PartePrintProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 14,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Strana ${plan.widthMm.toStringAsFixed(1)} × '
              '${plan.heightMm.toStringAsFixed(1)} mm',
              style: textTheme.labelMedium,
            ),
            Text(
              'Zona ${plan.printableZoneWidthMm.toStringAsFixed(1)} × '
              '${plan.printableZoneHeightMm.toStringAsFixed(1)} mm',
              style: textTheme.labelMedium,
            ),
            const _ParteGuideLabel(color: Colors.orange, label: 'zona štampe'),
            const _ParteGuideLabel(
              color: Colors.redAccent,
              label: 'sigurna površina',
            ),
            const _ParteGuideLabel(
              color: Colors.blueAccent,
              label: 'pomoćne linije',
            ),
            Text(
              'PDF pomeraj: ${profile.horizontalCorrectionMm.toStringAsFixed(1)} / '
              '${profile.verticalCorrectionMm.toStringAsFixed(1)} mm',
              style: textTheme.labelMedium,
            ),
            const Tooltip(
              message:
                  'Ove oznake su samo deo editora i ne ulaze u PDF ni DOCX.',
              child: Icon(Icons.visibility_outlined, size: 18),
            ),
            Text(
              'Štampa: Actual size / 100% – bez Fit, Shrink ili Scale to page',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParteGuideLabel extends StatelessWidget {
  const _ParteGuideLabel({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 18, height: 2, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class PartePlanPreview extends StatelessWidget {
  const PartePlanPreview({
    super.key,
    required this.plan,
    required this.mediaStore,
    this.selectedBlockId,
    this.onBlockSelected,
    this.onBlockMoved,
  });

  final ParteRenderPlan plan;
  final ParteMediaStore mediaStore;
  final String? selectedBlockId;
  final ValueChanged<String>? onBlockSelected;
  final Future<void> Function(String id, double dxMm, double dyMm)?
  onBlockMoved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: plan.widthMm / plan.heightMm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / plan.widthMm;
          final safeLeft = plan.printableZoneXmm + plan.horizontalMarginMm;
          final safeRight =
              plan.printableZoneXmm +
              plan.printableZoneWidthMm -
              plan.horizontalMarginMm;
          final zoneCenter =
              plan.printableZoneXmm + plan.printableZoneWidthMm / 2;
          ParteRenderBlock? selected;
          for (final block in plan.blocks) {
            if (block.id == selectedBlockId) selected = block;
          }
          final dynamicGuides = <double>[];
          if (selected != null) {
            for (final other in plan.blocks.where(
              (block) => block.id != selectedBlockId,
            )) {
              for (final candidate in <double>[
                other.rect.x,
                other.rect.right,
                other.rect.centerX,
              ]) {
                if ((selected.rect.x - candidate).abs() < 0.01 ||
                    (selected.rect.right - candidate).abs() < 0.01 ||
                    (selected.rect.centerX - candidate).abs() < 0.01) {
                  dynamicGuides.add(candidate);
                }
              }
            }
          }
          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: plan.printableZoneXmm * scale,
                  top: plan.printableZoneYmm * scale,
                  width: plan.printableZoneWidthMm * scale,
                  height: plan.printableZoneHeightMm * scale,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left:
                      (plan.printableZoneXmm + plan.horizontalMarginMm) * scale,
                  top: (plan.printableZoneYmm + plan.verticalMarginMm) * scale,
                  width:
                      (plan.printableZoneWidthMm -
                          plan.horizontalMarginMm * 2) *
                      scale,
                  height:
                      (plan.printableZoneHeightMm - plan.verticalMarginMm * 2) *
                      scale,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final x in <double>[safeLeft, zoneCenter, safeRight])
                  Positioned(
                    key: ValueKey('parte-editor-guide-$x'),
                    left: x * scale,
                    top: plan.printableZoneYmm * scale,
                    width: 1,
                    height: plan.printableZoneHeightMm * scale,
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Colors.blueAccent.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                for (final x in dynamicGuides.toSet())
                  Positioned(
                    left: x * scale,
                    top: plan.printableZoneYmm * scale,
                    width: 1.5,
                    height: plan.printableZoneHeightMm * scale,
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Colors.green.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
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
                      selected: selectedBlockId == block.id,
                      onSelected: onBlockSelected,
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
    required this.selected,
    required this.onSelected,
    required this.onMoved,
  });

  final ParteRenderBlock block;
  final double scale;
  final ParteMediaStore mediaStore;
  final bool selected;
  final ValueChanged<String>? onSelected;
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
        onTap: () => widget.onSelected?.call(widget.block.id),
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: widget.selected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: _content(),
        ),
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
        child: Transform.scale(
          scaleX: block.horizontalScale,
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
              fontFamily: block.fontFamily,
              fontSize: block.fontSize * widget.scale * 25.4 / 72,
              height: 1.22,
              fontWeight: block.bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
    }
    if (block.mediaKey != null) {
      return FutureBuilder<Uint8List>(
        future: widget.mediaStore.read(block.mediaKey!),
        builder: (context, snapshot) => snapshot.hasData
            ? _styledImage(applyParteImageEffects(snapshot.data!, block))
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return _shapeAndBorder(Image.asset(block.assetPath!, fit: BoxFit.contain));
  }

  Widget _styledImage(Uint8List bytes) =>
      _shapeAndBorder(Image.memory(bytes, fit: BoxFit.contain));

  Widget _shapeAndBorder(Widget image) {
    final block = widget.block;
    final shaped = switch (block.imageShape) {
      ParteImageShape.rectangle => image,
      ParteImageShape.roundedRectangle => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image,
      ),
      ParteImageShape.oval => ClipOval(child: image),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        border: block.border
            ? Border.all(color: Colors.black, width: block.borderWidth)
            : null,
      ),
      child: shaped,
    );
  }
}
