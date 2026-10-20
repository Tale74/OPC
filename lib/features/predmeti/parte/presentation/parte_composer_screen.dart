import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/help/opc_help.dart';
import '../../../../core/database/database.dart';
import '../../../../core/entitlements/opc_entitlement_policy.dart';
import '../../../../core/utils/export_utils.dart';
import '../../../../core/widgets/manual_entry_affordance.dart';
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

typedef ParteRectPreviewCallback = void Function(String id, ParteRectMm? rect);
typedef ParteRectCommitCallback =
    Future<void> Function(String id, ParteRectMm rect, {required bool moved});

enum _ParteResizeHandle { nw, ne, sw, se }

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
  bool _textExpanded = false;
  bool _formatExpanded = false;
  bool _mediaExpanded = false;
  bool _precisionExpanded = false;
  int? _textControllerPreparationId;
  final Map<String, ParteRectMm> _gesturePreviewRects = {};
  final Map<String, double> _effectPreviewValues = {};
  String? _activeEffectKey;
  String? _activeEffectBlockId;
  double? _activeEffectStartValue;
  bool _effectGestureCancelled = false;

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
      final preparation = await _repository.initializeOrResume(
        predmetId: widget.predmetId,
        actor: widget.actor,
        entitlement: widget.entitlement,
      );
      await _loadPrintProfileForTemplate(preparation.templateId);
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

  Future<void> _loadPrintProfileForTemplate(String templateId) async {
    final profile = await _printProfileStore.loadForTemplate(templateId);
    _printProfile = profile;
    _printHorizontalController.text = profile.horizontalCorrectionMm
        .toStringAsFixed(1);
    _printVerticalController.text = profile.verticalCorrectionMm
        .toStringAsFixed(1);
  }

  Future<void> _reload({
    bool verifySourceChange = true,
    bool preserveTextControllers = true,
  }) async {
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
      plan = await _service.buildPlan(
        preparation: preparation,
        predmet: predmet,
      );
      if (verifySourceChange) {
        sourceChanged = await _repository.sourceChanged(preparation.id);
      }
    }
    if (!mounted) return;
    _replaceControllers(
      draft,
      preparationId: preparation.id,
      preserveExistingText: preserveTextControllers,
    );
    if (draft != null) {
      final selected = draft.blocks.firstWhere(
        (block) => block.id == _selectedBlockId,
        orElse: () => draft!.blocks.first,
      );
      _fontSizeController.text = _displayFontSize(
        selected,
        plan,
      ).toStringAsFixed(1);
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

  void _replaceControllers(
    ParteDraft? draft, {
    required int preparationId,
    required bool preserveExistingText,
  }) {
    final canPreserve =
        preserveExistingText && _textControllerPreparationId == preparationId;
    final activeIds = draft?.textByBlock.keys.toSet() ?? const <String>{};
    for (final id in _textControllers.keys.toList()) {
      if (!canPreserve || !activeIds.contains(id)) {
        _textControllers.remove(id)?.dispose();
      }
    }
    if (draft != null) {
      for (final entry in draft.textByBlock.entries) {
        _textControllers.putIfAbsent(
          entry.key,
          () => TextEditingController(text: entry.value),
        );
      }
    }
    _textControllerPreparationId = preparationId;
  }

  double _displayFontSize(ParteBlockSpec block, [ParteRenderPlan? plan]) {
    final renderedPlan = plan ?? _plan;
    final rendered = renderedPlan?.blocks
        .where(
          (item) => item.id == block.id && item.kind == ParteBlockKind.text,
        )
        .firstOrNull;
    return rendered?.fontSize ?? block.initialFontSize;
  }

  void _selectBlock(String id) {
    if (_draft == null) return;
    final block = _draft!.blocks.firstWhere(
      (item) => item.id == id,
      orElse: () => _draft!.blocks.first,
    );
    setState(() {
      _selectedBlockId = block.id;
      _fontSizeController.text = _displayFontSize(block).toStringAsFixed(1);
    });
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
    await _reload(verifySourceChange: false);
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
    await _reload(verifySourceChange: false);
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
        horizontal.abs() > PartePrintProfile.maxAbsCorrectionMm ||
        vertical.abs() > PartePrintProfile.maxAbsCorrectionMm) {
      throw FormatException(
        'Korekcija štampe mora biti između '
        '−${PartePrintProfile.maxAbsCorrectionMm.toStringAsFixed(0)} i '
        '+${PartePrintProfile.maxAbsCorrectionMm.toStringAsFixed(0)} mm.',
      );
    }
    final profile = PartePrintProfile(
      horizontalCorrectionMm: horizontal,
      verticalCorrectionMm: vertical,
    );
    await _printProfileStore.saveForTemplate(_preparation!.templateId, profile);
    if (!mounted) return;
    setState(() {
      _printProfile = profile;
      _busy = false;
    });
  });

  Future<void> _resetPrintCorrection() => _run(() async {
    await _printProfileStore.resetForTemplate(_preparation!.templateId);
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
    bool skipHorizontalDragSnap = false,
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
          if ((dx != 0 || dy != 0) &&
              widthDelta == 0 &&
              heightDelta == 0 &&
              !(skipHorizontalDragSnap && dx != 0 && dy == 0)) {
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
    await _reload(verifySourceChange: false);
  });

  String _effectKey(String blockId, String property) => '$blockId.$property';

  void _startEffectSlider(String property, double value) {
    final blockId = _selectedBlockId;
    final key = _effectKey(blockId, property);
    setState(() {
      _activeEffectKey = key;
      _activeEffectBlockId = blockId;
      _activeEffectStartValue = value;
      _effectGestureCancelled = false;
      _effectPreviewValues[key] = value;
    });
  }

  void _updateEffectSlider(String property, double value) {
    final blockId = _activeEffectBlockId ?? _selectedBlockId;
    final key = _effectKey(blockId, property);
    setState(() {
      _activeEffectKey = key;
      _effectPreviewValues[key] = value;
    });
  }

  void _cancelEffectSlider(PointerCancelEvent _) {
    _effectGestureCancelled = true;
    final key = _activeEffectKey;
    if (key == null || !mounted) return;
    setState(() {
      _effectPreviewValues.remove(key);
      _activeEffectKey = null;
      _activeEffectBlockId = null;
      _activeEffectStartValue = null;
    });
  }

  void _endEffectSlider(String property, double value) {
    final blockId = _activeEffectBlockId ?? _selectedBlockId;
    final key = _effectKey(blockId, property);
    final start = _activeEffectStartValue;
    scheduleMicrotask(() async {
      if (!mounted) return;
      final cancelled = _effectGestureCancelled;
      setState(() {
        _activeEffectKey = null;
        _activeEffectBlockId = null;
        _activeEffectStartValue = null;
        _effectGestureCancelled = false;
      });
      if (cancelled || start == null || start == value) {
        setState(() => _effectPreviewValues.remove(key));
        return;
      }
      if (_selectedBlockId != blockId) {
        setState(() => _effectPreviewValues.remove(key));
        return;
      }
      try {
        switch (property) {
          case 'brightness':
            await _modifySelected(brightness: value);
          case 'contrast':
            await _modifySelected(contrast: value);
          case 'sharpness':
            await _modifySelected(sharpness: value);
        }
      } finally {
        if (mounted) {
          setState(() => _effectPreviewValues.remove(key));
        }
      }
    });
  }

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

  Future<void> _adjustSelectedFontSize(double delta) async {
    final block = _draft!.blocks.firstWhere(
      (item) => item.id == _selectedBlockId,
    );
    final before = _displayFontSize(block);
    final requested = (block.initialFontSize + delta)
        .clamp(block.minimumFontSize, block.maximumFontSize)
        .toDouble();
    if (requested == block.initialFontSize) return;

    await _modifySelected(fontSize: requested);
    if (!mounted || _draft == null) return;
    final updated = _draft!.blocks.firstWhere(
      (item) => item.id == _selectedBlockId,
    );
    final after = _displayFontSize(updated);
    if ((after - before).abs() < 0.01) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Veličina prikazanog teksta nije promenjena jer je ograničena '
              'prostorom bloka. Proširite DIMENZIJE ili skratite tekst.',
            ),
          ),
        );
    }
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
    await _reload(verifySourceChange: false);
  });

  void _previewBlockRect(String id, ParteRectMm? rect) {
    if (!mounted) return;
    setState(() {
      if (rect == null) {
        _gesturePreviewRects.remove(id);
      } else {
        _gesturePreviewRects[id] = rect;
      }
      _selectedBlockId = id;
    });
  }

  Future<void> _commitBlockRect(
    String id,
    ParteRectMm rect, {
    required bool moved,
  }) async {
    final draft = _draft!;
    final original = draft.blocks.firstWhere((block) => block.id == id).rect;
    final finalRect = moved ? _snapRect(rect, id, draft) : rect;
    if (_sameRect(original, finalRect)) {
      _previewBlockRect(id, null);
      return;
    }
    await _run(() async {
      try {
        final blocks = draft.blocks
            .map(
              (block) =>
                  block.id == id ? block.copyWith(rect: finalRect) : block,
            )
            .toList(growable: false);
        await _repository.updateDraft(
          preparationId: _preparation!.id,
          draft: draft.copyWith(blocks: blocks),
          actor: widget.actor,
          entitlement: widget.entitlement,
        );
        await _reload(verifySourceChange: false);
      } finally {
        _previewBlockRect(id, null);
      }
    });
  }

  bool _sameRect(ParteRectMm a, ParteRectMm b) =>
      a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height;

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
    await _reload(verifySourceChange: false);
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
    await _reload(verifySourceChange: false);
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
    await _reload(verifySourceChange: false);
  });

  Future<void> _confirmPreview() => _run(() async {
    await _repository.confirmPreview(
      preparationId: _preparation!.id,
      plan: _plan!,
      actor: widget.actor,
      entitlement: widget.entitlement,
    );
    await _reload(verifySourceChange: false);
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
    await _reload(verifySourceChange: false);
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
      poruka:
          'Kalibracioni PDF je sačuvan. Štampajte u stvarnoj veličini (Actual size / 100%).',
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
    await _reload(verifySourceChange: false, preserveTextControllers: false);
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
    await _reload(verifySourceChange: false, preserveTextControllers: false);
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
          'PREDMET i IRiU podaci ostaju netaknuti. Spoljašnji originali i već '
          'izvezeni PDF/DOCX fajlovi ostaju sačuvani. Brisanje pripreme iz '
          'OPC-a je nepovratno.',
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
      await _loadPrintProfileForTemplate(selected.id);
      await _reload(verifySourceChange: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const OpcHelpTitle(
            title: Text('PARTE PRIPREMA'),
            chapterId: 'parte.preparation',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const OpcHelpTitle(
            title: Text('PARTE PRIPREMA'),
            chapterId: 'parte.preparation',
          ),
        ),
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
        appBar: AppBar(
          title: const OpcHelpTitle(
            title: Text('PARTE PRIPREMA'),
            chapterId: 'parte.preparation',
          ),
        ),
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
        title: OpcHelpTitle(
          title: Text('PARTE – ${_predmet!.ime} ${_predmet!.prezime}'),
          chapterId: 'parte.preparation',
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
        _buildDisclosureCard(
          key: const Key('parte-text-blocks-disclosure'),
          title: 'TEKSTUALNI BLOKOVI',
          icon: Icons.article_outlined,
          initiallyExpanded: _textExpanded,
          onExpansionChanged: (value) => _textExpanded = value,
          childrenTopPadding: 10,
          children: [
            for (final id in textIds) ...[
              ManualEntryAffordance(
                controller: _textControllers[id]!,
                enabled: true,
                child: TextField(
                  key: ValueKey('parte-text-$id'),
                  controller: _textControllers[id],
                  minLines: id == 'mourners' || id == 'ceremony' ? 2 : 1,
                  maxLines: id == 'mourners' || id == 'ceremony' ? 5 : 3,
                  decoration: InputDecoration(
                    labelText: _blockLabel(id),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              key: const Key('parte-save-text'),
              onPressed: _busy ? null : _saveText,
              icon: const Icon(Icons.save_outlined),
              label: const Text('SAČUVAJ PRIVREMENI TEKST'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDisclosureCard(
          key: const Key('parte-format-disclosure'),
          title: 'FORMAT I ZONA ŠTAMPE',
          icon: Icons.print_outlined,
          initiallyExpanded: _formatExpanded,
          onExpansionChanged: (value) => _formatExpanded = value,
          // InputDecoration's floating label extends above its field outline;
          // keep it clear of the clipped disclosure-card child boundary.
          childrenTopPadding: 18,
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
            Text(
              'PROFIL ŠTAMPAČA ZA AKTIVNI ŠABLON',
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
                  child: const Text('SAČUVAJ PROFIL ZA ŠABLON'),
                ),
                TextButton(
                  onPressed: _busy ? null : _resetPrintCorrection,
                  child: const Text('RESETUJ PROFIL'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDisclosureCard(
          key: const Key('parte-media-disclosure'),
          title: 'MEDIJI',
          icon: Icons.perm_media_outlined,
          initiallyExpanded: _mediaExpanded,
          onExpansionChanged: (value) => _mediaExpanded = value,
          children: [
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
          ],
        ),
        const SizedBox(height: 12),
        _buildDisclosureCard(
          key: const Key('parte-precision-disclosure'),
          title: 'PRECIZNO POMERANJE I STIL',
          icon: Icons.tune,
          initiallyExpanded: _precisionExpanded,
          onExpansionChanged: (value) => _precisionExpanded = value,
          children: [
            _precisionControlGroup(
              'BLOK',
              DropdownButtonFormField<String>(
                isExpanded: true,
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
                  final block = _draft!.blocks.firstWhere(
                    (item) => item.id == next,
                  );
                  _selectBlock(block.id);
                },
              ),
            ),
            _precisionControlGroup(
              'POLOŽAJ · 1 mm',
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  IconButton.filledTonal(
                    key: const Key('parte-position-left'),
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(
                            dx: -1,
                            skipHorizontalDragSnap: true,
                          ),
                    icon: const Icon(Icons.arrow_left),
                    tooltip: 'Levo 1 mm',
                  ),
                  IconButton.filledTonal(
                    key: const Key('parte-position-right'),
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(
                            dx: 1,
                            skipHorizontalDragSnap: true,
                          ),
                    icon: const Icon(Icons.arrow_right),
                    tooltip: 'Desno 1 mm',
                  ),
                  IconButton.filledTonal(
                    key: const Key('parte-position-up'),
                    onPressed: _busy ? null : () => _modifySelected(dy: -1),
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: 'Gore 1 mm',
                  ),
                  IconButton.filledTonal(
                    key: const Key('parte-position-down'),
                    onPressed: _busy ? null : () => _modifySelected(dy: 1),
                    icon: const Icon(Icons.arrow_downward),
                    tooltip: 'Dole 1 mm',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (selected.kind == ParteBlockKind.text) ...[
              _precisionSectionTitle('TEKST'),
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
                      width: 184,
                      child: ManualEntryAffordance(
                        controller: _fontSizeController,
                        enabled: !_busy,
                        child: TextField(
                          key: const Key('parte-font-size-state'),
                          controller: _fontSizeController,
                          enabled: !_busy,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Veličina',
                            suffixText: 'pt',
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 96,
                              maxWidth: 96,
                              minHeight: 48,
                              maxHeight: 48,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: const Key('parte-font-size-increment'),
                                  constraints: const BoxConstraints.tightFor(
                                    width: 48,
                                    height: 48,
                                  ),
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Uvećaj font za 0,5 pt',
                                  onPressed:
                                      _busy ||
                                          selected.initialFontSize >=
                                              selected.maximumFontSize
                                      ? null
                                      : () => _adjustSelectedFontSize(0.5),
                                  icon: const Icon(Icons.keyboard_arrow_up),
                                ),
                                IconButton(
                                  key: const Key('parte-font-size-decrement'),
                                  constraints: const BoxConstraints.tightFor(
                                    width: 48,
                                    height: 48,
                                  ),
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Smanji font za 0,5 pt',
                                  onPressed:
                                      _busy ||
                                          selected.initialFontSize <=
                                              selected.minimumFontSize
                                      ? null
                                      : () => _adjustSelectedFontSize(-0.5),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                ),
                              ],
                            ),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _applyFontSizeInput(),
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            _applyFontSizeInput();
                          },
                        ),
                      ),
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
              _precisionSectionTitle('DIMENZIJE'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _dimensionActionButton(
                    key: const Key('parte-dimension-width-decrease'),
                    icon: _dimensionArrow(horizontal: true, outward: false),
                    tooltip: 'Suzi blok za 1 mm',
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(widthDelta: -1),
                  ),
                  _dimensionActionButton(
                    key: const Key('parte-dimension-width-increase'),
                    icon: _dimensionArrow(horizontal: true, outward: true),
                    tooltip: 'Proširi blok za 1 mm',
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(widthDelta: 1),
                  ),
                  _dimensionActionButton(
                    key: const Key('parte-dimension-height-decrease'),
                    icon: _dimensionArrow(horizontal: false, outward: false),
                    tooltip: 'Snizi blok za 1 mm',
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(heightDelta: -1),
                  ),
                  _dimensionActionButton(
                    key: const Key('parte-dimension-height-increase'),
                    icon: _dimensionArrow(horizontal: false, outward: true),
                    tooltip: 'Povisi blok za 1 mm',
                    onPressed: _busy
                        ? null
                        : () => _modifySelected(heightDelta: 1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _precisionSectionTitle('PORAVNANJE I STIL'),
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
                onChanged: _busy
                    ? null
                    : (value) => _modifySelected(bold: value),
              ),
            ] else ...[
              _precisionSectionTitle('DIMENZIJE'),
              Text(
                'Veličina: ${selected.rect.width.toStringAsFixed(1)} × '
                '${selected.rect.height.toStringAsFixed(1)} mm',
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (selected.lockAspectRatio) ...[
                    _dimensionActionButton(
                      key: const Key('parte-dimension-size-decrease'),
                      icon: const Icon(Icons.remove),
                      tooltip: 'Umanji blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(widthDelta: -1),
                    ),
                    _dimensionActionButton(
                      key: const Key('parte-dimension-size-increase'),
                      icon: const Icon(Icons.add),
                      tooltip: 'Povećaj blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(widthDelta: 1),
                    ),
                  ] else ...[
                    _dimensionActionButton(
                      key: const Key('parte-dimension-width-decrease'),
                      icon: _dimensionArrow(horizontal: true, outward: false),
                      tooltip: 'Suzi blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(widthDelta: -1),
                    ),
                    _dimensionActionButton(
                      key: const Key('parte-dimension-width-increase'),
                      icon: _dimensionArrow(horizontal: true, outward: true),
                      tooltip: 'Proširi blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(widthDelta: 1),
                    ),
                    _dimensionActionButton(
                      key: const Key('parte-dimension-height-decrease'),
                      icon: _dimensionArrow(horizontal: false, outward: false),
                      tooltip: 'Snizi blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(heightDelta: -1),
                    ),
                    _dimensionActionButton(
                      key: const Key('parte-dimension-height-increase'),
                      icon: _dimensionArrow(horizontal: false, outward: true),
                      tooltip: 'Povisi blok za 1 mm',
                      onPressed: _busy
                          ? null
                          : () => _modifySelected(heightDelta: 1),
                    ),
                  ],
                  _dimensionActionButton(
                    key: const Key('parte-dimension-size-reset'),
                    icon: const Icon(Icons.restart_alt),
                    tooltip: 'Vrati veličinu iz šablona',
                    onPressed: _busy ? null : _resetSelectedSize,
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
                _precisionSectionTitle('IZGLED SLIKE'),
                _effectSlider(
                  'brightness',
                  'Svetlina',
                  selected.brightness,
                  0.5,
                  1.5,
                ),
                _effectSlider(
                  'contrast',
                  'Kontrast',
                  selected.contrast,
                  0.5,
                  1.5,
                ),
                _effectSlider('sharpness', 'Oštrina', selected.sharpness, 0, 1),
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
                onChanged: _busy
                    ? null
                    : (value) => _modifySelected(border: value),
              ),
              DropdownButtonFormField<ParteImageShape>(
                isExpanded: true,
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
          ],
        ),
        const SizedBox(height: 16),
        Card(
          key: const Key('parte-secondary-danger-actions'),
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OSTALE RADNJE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclosureCard({
    required Key key,
    required String title,
    required IconData icon,
    required bool initiallyExpanded,
    required ValueChanged<bool> onExpansionChanged,
    double childrenTopPadding = 0,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: key,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.fromLTRB(16, childrenTopPadding, 16, 16),
        onExpansionChanged: onExpansionChanged,
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        children: children,
      ),
    );
  }

  Widget _dimensionField(TextEditingController controller, String label) =>
      SizedBox(
        width: 190,
        child: ManualEntryAffordance(
          controller: controller,
          enabled: true,
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
        ),
      );

  Widget _dimensionActionButton({
    required Key key,
    required Widget icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) => IconButton.filledTonal(
    key: key,
    onPressed: onPressed,
    icon: icon,
    tooltip: tooltip,
  );

  Widget _dimensionArrow({required bool horizontal, required bool outward}) =>
      RotatedBox(
        quarterTurns: horizontal ? 1 : 0,
        child: Icon(outward ? Icons.unfold_more : Icons.unfold_less),
      );

  Widget _precisionSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );

  Widget _precisionControlGroup(String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );

  Widget _effectSlider(
    String property,
    String label,
    double value,
    double min,
    double max,
  ) {
    final key = _effectKey(_selectedBlockId, property);
    return Row(
      children: [
        SizedBox(width: 76, child: Text(label)),
        Expanded(
          child: Listener(
            onPointerCancel: _cancelEffectSlider,
            child: Slider(
              key: ValueKey('parte-effect-slider-$property'),
              value: (_effectPreviewValues[key] ?? value).clamp(min, max),
              min: min,
              max: max,
              divisions: 20,
              onChangeStart: _busy
                  ? null
                  : (next) => _startEffectSlider(property, next),
              onChanged: _busy
                  ? null
                  : (next) => _updateEffectSlider(property, next),
              onChangeEnd: _busy
                  ? null
                  : (next) => _endEffectSlider(property, next),
            ),
          ),
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
          'PREGLED PRIPREME',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _PartePreviewTechnicalGuide(profile: _printProfile),
        const SizedBox(height: 8),
        ParteEditorViewport(
          plan: plan,
          mediaStore: _mediaStore,
          selectedBlockId: _selectedBlockId,
          previewRects: _gesturePreviewRects,
          effectOverrides: _effectPreviewValues,
          lockAspectRatios: {
            for (final block in _draft!.blocks)
              block.id:
                  block.kind != ParteBlockKind.text && block.lockAspectRatio,
          },
          onBlockSelected: _selectBlock,
          onBlockRectPreview: _busy ? null : _previewBlockRect,
          onBlockRectCommitted: _busy ? null : _commitBlockRect,
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
                onPressed: _busy || !previewConfirmed ? null : _complete,
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

class _PartePreviewTechnicalGuide extends StatelessWidget {
  const _PartePreviewTechnicalGuide({required this.profile});

  final PartePrintProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      key: const Key('parte-preview-technical-guide'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('POMOĆ ZA PREGLED I ŠTAMPU', style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Obojene pomoćne linije pripadaju samo editoru i ne ulaze u PDF ni DOCX.',
              style: textTheme.bodySmall,
            ),
            Text(
              'Profil aktivnog šablona pomera ceo PDF otisak: '
              '${profile.horizontalCorrectionMm.toStringAsFixed(1)} mm levo/desno i '
              '${profile.verticalCorrectionMm.toStringAsFixed(1)} mm gore/dole.',
              style: textTheme.bodySmall,
            ),
            Text(
              'Štampajte u stvarnoj veličini (Actual size / 100%). Ne koristite Fit, Shrink ni Scale to page.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Session-only viewport controls. The transform deliberately stays outside
/// [ParteRenderPlan], so zoom and pan can never affect PDF/DOCX geometry.
class ParteEditorViewport extends StatefulWidget {
  const ParteEditorViewport({
    super.key,
    required this.plan,
    required this.mediaStore,
    this.selectedBlockId,
    this.previewRects = const <String, ParteRectMm>{},
    this.effectOverrides = const <String, double>{},
    this.lockAspectRatios = const <String, bool>{},
    this.onBlockSelected,
    this.onBlockRectPreview,
    this.onBlockRectCommitted,
    this.onBlockMoved,
  });

  final ParteRenderPlan plan;
  final ParteMediaStore mediaStore;
  final String? selectedBlockId;
  final Map<String, ParteRectMm> previewRects;
  final Map<String, double> effectOverrides;
  final Map<String, bool> lockAspectRatios;
  final ValueChanged<String>? onBlockSelected;
  final ParteRectPreviewCallback? onBlockRectPreview;
  final ParteRectCommitCallback? onBlockRectCommitted;
  final Future<void> Function(String id, double dxMm, double dyMm)?
  onBlockMoved;

  @override
  State<ParteEditorViewport> createState() => _ParteEditorViewportState();
}

class _ParteEditorViewportState extends State<ParteEditorViewport> {
  static const double _minimumScale = 0.5;
  static const double _maximumScale = 4;
  static const double _scaleStep = 0.25;

  final TransformationController _controller = TransformationController();
  bool _moveViewport = false;

  double get _scale =>
      _controller.value.getColumn(0).length.clamp(_minimumScale, _maximumScale);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setScale(double value) {
    final next = value.clamp(_minimumScale, _maximumScale);
    final translation = _controller.value.getTranslation();
    _controller.value = Matrix4.diagonal3Values(next, next, 1)
      ..setTranslationRaw(translation.x, translation.y, 0);
    setState(() {});
  }

  void _fit() {
    _controller.value = Matrix4.identity();
    setState(() {});
  }

  void _center() {
    _controller.value = Matrix4.diagonal3Values(_scale, _scale, 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_scale * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          key: const Key('parte-viewport-controls'),
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton.outlined(
              key: const Key('parte-viewport-zoom-out'),
              tooltip: 'Umanji prikaz',
              onPressed: _scale <= _minimumScale
                  ? null
                  : () => _setScale(_scale - _scaleStep),
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 62,
              child: Text(
                '$percentage%',
                key: const Key('parte-viewport-zoom-value'),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton.outlined(
              key: const Key('parte-viewport-zoom-in'),
              tooltip: 'Uvećaj prikaz',
              onPressed: _scale >= _maximumScale
                  ? null
                  : () => _setScale(_scale + _scaleStep),
              icon: const Icon(Icons.add),
            ),
            OutlinedButton(
              key: const Key('parte-viewport-fit'),
              onPressed: _fit,
              child: const Text('UKLOPI'),
            ),
            OutlinedButton(
              key: const Key('parte-viewport-center'),
              onPressed: _center,
              child: const Text('CENTRIRAJ'),
            ),
            FilterChip(
              key: const Key('parte-viewport-pan-mode'),
              selected: _moveViewport,
              avatar: const Icon(Icons.pan_tool_outlined, size: 18),
              label: const Text('POMERI PRIKAZ'),
              tooltip: _moveViewport
                  ? 'Pomeranje prikaza je uključeno'
                  : 'Uključi pomeranje i pinch zoom prikaza',
              onSelected: (selected) => setState(() {
                _moveViewport = selected;
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InteractiveViewer(
          key: const Key('parte-editor-interactive-viewer'),
          transformationController: _controller,
          minScale: _minimumScale,
          maxScale: _maximumScale,
          boundaryMargin: const EdgeInsets.all(48),
          panEnabled: _moveViewport,
          scaleEnabled: _moveViewport,
          onInteractionUpdate: (_) => setState(() {}),
          child: PartePlanPreview(
            plan: widget.plan,
            mediaStore: widget.mediaStore,
            selectedBlockId: widget.selectedBlockId,
            previewRects: widget.previewRects,
            effectOverrides: widget.effectOverrides,
            lockAspectRatios: widget.lockAspectRatios,
            viewportScale: _scale,
            onBlockSelected: widget.onBlockSelected,
            onBlockRectPreview: _moveViewport
                ? null
                : widget.onBlockRectPreview,
            onBlockRectCommitted: _moveViewport
                ? null
                : widget.onBlockRectCommitted,
            onBlockMoved: _moveViewport ? null : widget.onBlockMoved,
          ),
        ),
      ],
    );
  }
}

class PartePlanPreview extends StatelessWidget {
  const PartePlanPreview({
    super.key,
    required this.plan,
    required this.mediaStore,
    this.selectedBlockId,
    this.previewRects = const <String, ParteRectMm>{},
    this.effectOverrides = const <String, double>{},
    this.lockAspectRatios = const <String, bool>{},
    this.viewportScale = 1,
    this.onBlockSelected,
    this.onBlockRectPreview,
    this.onBlockRectCommitted,
    this.onBlockMoved,
  });

  final ParteRenderPlan plan;
  final ParteMediaStore mediaStore;
  final String? selectedBlockId;
  final Map<String, ParteRectMm> previewRects;
  final Map<String, double> effectOverrides;
  final Map<String, bool> lockAspectRatios;
  final double viewportScale;
  final ValueChanged<String>? onBlockSelected;
  final ParteRectPreviewCallback? onBlockRectPreview;
  final ParteRectCommitCallback? onBlockRectCommitted;
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
                  Builder(
                    builder: (context) {
                      final selectedBlock = selectedBlockId == block.id;
                      final rect = previewRects[block.id] ?? block.rect;
                      final handlePadding =
                          selectedBlock &&
                              onBlockRectPreview != null &&
                              viewportScale > 0
                          ? 24 / viewportScale
                          : 0.0;
                      final safeLeft =
                          plan.printableZoneXmm + plan.horizontalMarginMm;
                      final safeTop =
                          plan.printableZoneYmm + plan.verticalMarginMm;
                      final safeRight =
                          plan.printableZoneXmm +
                          plan.printableZoneWidthMm -
                          plan.horizontalMarginMm;
                      final safeBottom =
                          plan.printableZoneYmm +
                          plan.printableZoneHeightMm -
                          plan.verticalMarginMm;
                      return Positioned(
                        left: rect.x * scale - handlePadding,
                        top: rect.y * scale - handlePadding,
                        width: rect.width * scale + handlePadding * 2,
                        height: rect.height * scale + handlePadding * 2,
                        child: _DraggableParteBlock(
                          block: block,
                          rect: rect,
                          scale: scale,
                          viewportScale: viewportScale,
                          handlePadding: handlePadding,
                          safeBounds: Rect.fromLTRB(
                            safeLeft,
                            safeTop,
                            safeRight,
                            safeBottom,
                          ),
                          mediaStore: mediaStore,
                          selected: selectedBlock,
                          onSelected: onBlockSelected,
                          onPreview: onBlockRectPreview,
                          onCommit: onBlockRectCommitted,
                          onLegacyMoved: onBlockMoved,
                          effectOverrides: effectOverrides,
                          lockAspectRatio: lockAspectRatios[block.id] ?? true,
                        ),
                      );
                    },
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
    required this.rect,
    required this.scale,
    required this.viewportScale,
    required this.handlePadding,
    required this.safeBounds,
    required this.mediaStore,
    required this.selected,
    required this.onSelected,
    required this.onPreview,
    required this.onCommit,
    required this.onLegacyMoved,
    required this.effectOverrides,
    required this.lockAspectRatio,
  });

  final ParteRenderBlock block;
  final ParteRectMm rect;
  final double scale;
  final double viewportScale;
  final double handlePadding;
  final Rect safeBounds;
  final ParteMediaStore mediaStore;
  final bool selected;
  final ValueChanged<String>? onSelected;
  final ParteRectPreviewCallback? onPreview;
  final ParteRectCommitCallback? onCommit;
  final Future<void> Function(String id, double dxMm, double dyMm)?
  onLegacyMoved;
  final Map<String, double> effectOverrides;
  final bool lockAspectRatio;

  @override
  State<_DraggableParteBlock> createState() => _DraggableParteBlockState();
}

class _DraggableParteBlockState extends State<_DraggableParteBlock> {
  _ParteResizeHandle? _activeHandle;
  ParteRectMm? _startRect;
  ParteRectMm? _previewRect;
  Offset? _startPointer;
  bool _moving = false;
  Offset _legacyOffset = Offset.zero;
  String? _mediaReadKey;
  Future<Uint8List>? _mediaBytesFuture;

  List<(_ParteResizeHandle, Offset)> _handleCenters() {
    final left = widget.handlePadding;
    final top = widget.handlePadding;
    final right = left + widget.rect.width * widget.scale;
    final bottom = top + widget.rect.height * widget.scale;
    return [
      (_ParteResizeHandle.nw, Offset(left, top)),
      (_ParteResizeHandle.ne, Offset(right, top)),
      (_ParteResizeHandle.sw, Offset(left, bottom)),
      (_ParteResizeHandle.se, Offset(right, bottom)),
    ];
  }

  _ParteResizeHandle? _hitHandle(Offset position) {
    if (!widget.selected || widget.handlePadding == 0) return null;
    final halfTarget = 24 / widget.viewportScale;
    _ParteResizeHandle? nearest;
    var nearestDistance = double.infinity;
    for (final (handle, center) in _handleCenters()) {
      final delta = position - center;
      if (delta.dx.abs() > halfTarget || delta.dy.abs() > halfTarget) continue;
      final distance = delta.distanceSquared;
      if (distance < nearestDistance) {
        nearest = handle;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  void _startGesture(DragStartDetails details) {
    widget.onSelected?.call(widget.block.id);
    _startRect = widget.rect;
    _previewRect = widget.rect;
    final selectionRelayoutPadding = widget.selected
        ? Offset.zero
        : Offset(24 / widget.viewportScale, 24 / widget.viewportScale);
    _startPointer = details.localPosition + selectionRelayoutPadding;
    _activeHandle = _hitHandle(details.localPosition);
    _moving = _activeHandle == null;
  }

  void _updateGesture(DragUpdateDetails details) {
    _updateGestureAt(details.localPosition);
  }

  void _updateGestureAt(Offset localPosition) {
    final start = _startRect;
    final pointer = _startPointer;
    if (start == null || pointer == null || widget.scale <= 0) return;
    final delta = localPosition - pointer;
    final dxMm = delta.dx / widget.scale;
    final dyMm = delta.dy / widget.scale;
    final next = _moving
        ? _moveRect(start, dxMm, dyMm)
        : _resizeRect(start, _activeHandle!, dxMm, dyMm);
    _previewRect = next;
    widget.onPreview?.call(widget.block.id, next);
  }

  ParteRectMm _moveRect(ParteRectMm start, double dx, double dy) {
    final x = (start.x + dx)
        .clamp(widget.safeBounds.left, widget.safeBounds.right - start.width)
        .toDouble();
    final y = (start.y + dy)
        .clamp(widget.safeBounds.top, widget.safeBounds.bottom - start.height)
        .toDouble();
    return ParteRectMm(x: x, y: y, width: start.width, height: start.height);
  }

  ParteRectMm _resizeRect(
    ParteRectMm start,
    _ParteResizeHandle handle,
    double dx,
    double dy,
  ) {
    const minimumMm = 5.0;
    final movesLeft =
        handle == _ParteResizeHandle.nw || handle == _ParteResizeHandle.sw;
    final movesTop =
        handle == _ParteResizeHandle.nw || handle == _ParteResizeHandle.ne;
    final fixedX = movesLeft ? start.right : start.x;
    final fixedY = movesTop ? start.bottom : start.y;
    final maxWidth = movesLeft
        ? fixedX - widget.safeBounds.left
        : widget.safeBounds.right - fixedX;
    final maxHeight = movesTop
        ? fixedY - widget.safeBounds.top
        : widget.safeBounds.bottom - fixedY;
    if (maxWidth < minimumMm || maxHeight < minimumMm) {
      return _previewRect ?? start;
    }

    var width = start.width + (movesLeft ? -dx : dx);
    var height = start.height + (movesTop ? -dy : dy);
    final ratio = widget.block.sourceAspectRatio ?? start.width / start.height;
    if (widget.lockAspectRatio && ratio.isFinite && ratio > 0) {
      final widthChange = (movesLeft ? -dx : dx) / start.width;
      final heightChange = (movesTop ? -dy : dy) / start.height;
      final widthDriven = widthChange.abs() >= heightChange.abs();
      var scale = 1 + (widthDriven ? widthChange : heightChange);
      final minScale = math.max(
        minimumMm / start.width,
        minimumMm / start.height,
      );
      final maxScale = math.min(
        maxWidth / start.width,
        maxHeight / start.height,
      );
      if (maxScale < minScale) return _previewRect ?? start;
      scale = scale.clamp(minScale, maxScale).toDouble();
      width = start.width * scale;
      height = width / ratio;
      if (height > maxHeight) {
        height = maxHeight;
        width = height * ratio;
      }
    } else {
      width = width.clamp(minimumMm, maxWidth).toDouble();
      height = height.clamp(minimumMm, maxHeight).toDouble();
    }
    final left = movesLeft ? fixedX - width : fixedX;
    final top = movesTop ? fixedY - height : fixedY;
    return ParteRectMm(x: left, y: top, width: width, height: height);
  }

  void _finishGesture() {
    final start = _startRect;
    final result = _previewRect;
    if (start == null || result == null) return;
    _startRect = null;
    _startPointer = null;
    _activeHandle = null;
    _previewRect = null;
    if (_sameRect(start, result)) {
      widget.onPreview?.call(widget.block.id, null);
      return;
    }
    unawaited(widget.onCommit?.call(widget.block.id, result, moved: _moving));
  }

  void _cancelGesture() {
    if (_startRect == null) return;
    _startRect = null;
    _startPointer = null;
    _activeHandle = null;
    _previewRect = null;
    widget.onPreview?.call(widget.block.id, null);
  }

  bool _sameRect(ParteRectMm a, ParteRectMm b) =>
      a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height;

  @override
  Widget build(BuildContext context) {
    final pad = widget.handlePadding;
    final target = widget.viewportScale > 0 ? 48 / widget.viewportScale : 48.0;
    final visualSize = widget.viewportScale > 0
        ? 12 / widget.viewportScale
        : 12.0;
    return Transform.translate(
      offset: _legacyOffset,
      child: GestureDetector(
        key: ValueKey('parte-preview-block-${widget.block.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelected?.call(widget.block.id),
        onPanStart: widget.onCommit == null || !widget.selected
            ? null
            : _startGesture,
        onPanUpdate: widget.onCommit == null
            ? widget.onLegacyMoved == null
                  ? null
                  : (details) => setState(() {
                      _legacyOffset += details.delta;
                    })
            : !widget.selected
            ? null
            : (details) => setState(() => _updateGesture(details)),
        onPanEnd: widget.onCommit == null
            ? widget.onLegacyMoved == null
                  ? null
                  : (_) {
                      final delta = _legacyOffset;
                      setState(() => _legacyOffset = Offset.zero);
                      unawaited(
                        widget.onLegacyMoved!(
                          widget.block.id,
                          delta.dx / widget.scale,
                          delta.dy / widget.scale,
                        ),
                      );
                    }
            : !widget.selected
            ? null
            : (_) => _finishGesture(),
        onPanCancel: widget.onCommit == null || !widget.selected
            ? null
            : _cancelGesture,
        child: RawGestureDetector(
          // Register direct manipulation for unselected blocks too. This lets
          // a user's first grab both select and move the block; otherwise the
          // surrounding vertical page scroll wins the initial diagonal drag.
          gestures: widget.onCommit != null
              ? <Type, GestureRecognizerFactory>{
                  _ParteDirectManipulationGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        _ParteDirectManipulationGestureRecognizer
                      >(
                        () => _ParteDirectManipulationGestureRecognizer(
                          debugOwner: this,
                        ),
                        (recognizer) {
                          recognizer.shouldStart = _ownsPointerDown;
                          recognizer.onStart = _startPointerGesture;
                          recognizer.onUpdate = _updatePointerGesture;
                          recognizer.onEnd = _finishGesture;
                          recognizer.onCancel = _cancelGesture;
                        },
                      ),
                }
              : const <Type, GestureRecognizerFactory>{},
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: pad,
                top: pad,
                width: widget.rect.width * widget.scale,
                height: widget.rect.height * widget.scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: widget.selected
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: _content(),
                ),
              ),
              if (widget.selected && widget.onCommit != null)
                for (final entry in _handleCenters())
                  Positioned(
                    left: entry.$2.dx - target / 2,
                    top: entry.$2.dy - target / 2,
                    width: target,
                    height: target,
                    child: SizedBox(
                      key: ValueKey(
                        'parte-resize-hit-${widget.block.id}-${entry.$1.name}',
                      ),
                      width: target,
                      height: target,
                      child: Center(
                        child: Container(
                          width: visualSize,
                          height: visualSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  bool _ownsPointerDown(Offset localPosition) {
    if (widget.onCommit == null) return false;
    if (widget.selected && _hitHandle(localPosition) != null) return true;
    final pad = widget.handlePadding;
    return Rect.fromLTWH(
      pad,
      pad,
      widget.rect.width * widget.scale,
      widget.rect.height * widget.scale,
    ).contains(localPosition);
  }

  void _startPointerGesture(PointerDownEvent event) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;
    final globalPosition = event.position;
    final localPosition = renderObject.globalToLocal(globalPosition);
    _startGesture(
      DragStartDetails(
        globalPosition: globalPosition,
        localPosition: localPosition,
      ),
    );
  }

  void _updatePointerGesture(PointerMoveEvent event) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !mounted) {
      return;
    }
    _updateGestureAt(renderObject.globalToLocal(event.position));
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
      if (_mediaReadKey != block.mediaKey) {
        _mediaReadKey = block.mediaKey;
        _mediaBytesFuture = widget.mediaStore.read(block.mediaKey!);
      }
      return FutureBuilder<Uint8List>(
        future: _mediaBytesFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? _ParteAsyncEffectPreview(
                source: snapshot.data!,
                block: block,
                brightness: widget.effectOverrides['${block.id}.brightness'],
                contrast: widget.effectOverrides['${block.id}.contrast'],
                sharpness: widget.effectOverrides['${block.id}.sharpness'],
                buildImage: _styledImage,
              )
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

class _ParteDirectManipulationGestureRecognizer
    extends OneSequenceGestureRecognizer {
  _ParteDirectManipulationGestureRecognizer({super.debugOwner});

  bool Function(Offset localPosition)? shouldStart;
  ValueChanged<PointerDownEvent>? onStart;
  ValueChanged<PointerMoveEvent>? onUpdate;
  VoidCallback? onEnd;
  VoidCallback? onCancel;

  int? _activePointer;
  PointerDownEvent? _downEvent;
  bool _accepted = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      shouldStart?.call(event.localPosition) == true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _activePointer = event.pointer;
    _downEvent = event;
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  void acceptGesture(int pointer) {
    if (pointer != _activePointer) return;
    _accepted = true;
    final downEvent = _downEvent;
    if (downEvent != null) onStart?.call(downEvent);
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer != _activePointer) return;
    if (_accepted) onCancel?.call();
    _clearPointer();
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_accepted || event.pointer != _activePointer) return;
    if (event is PointerMoveEvent) {
      onUpdate?.call(event);
    } else if (event is PointerUpEvent) {
      stopTrackingPointer(event.pointer);
      onEnd?.call();
      _clearPointer();
    } else if (event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
      onCancel?.call();
      _clearPointer();
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'parteDirectManipulation';

  void _clearPointer() {
    _activePointer = null;
    _downEvent = null;
    _accepted = false;
  }
}

class _ParteAsyncEffectPreview extends StatefulWidget {
  const _ParteAsyncEffectPreview({
    required this.source,
    required this.block,
    required this.buildImage,
    this.brightness,
    this.contrast,
    this.sharpness,
  });

  final Uint8List source;
  final ParteRenderBlock block;
  final double? brightness;
  final double? contrast;
  final double? sharpness;
  final Widget Function(Uint8List) buildImage;

  @override
  State<_ParteAsyncEffectPreview> createState() =>
      _ParteAsyncEffectPreviewState();
}

class _ParteAsyncEffectPreviewState extends State<_ParteAsyncEffectPreview> {
  static const _previewDebounce = Duration(milliseconds: 80);

  Timer? _debounce;
  late Future<Uint8List> _preview;
  bool _processing = false;
  int _requestRevision = 0;

  double get _brightness => widget.brightness ?? widget.block.brightness;
  double get _contrast => widget.contrast ?? widget.block.contrast;
  double get _sharpness => widget.sharpness ?? widget.block.sharpness;

  @override
  void initState() {
    super.initState();
    _preview = Future.value(widget.source);
    _schedulePreview();
  }

  @override
  void didUpdateWidget(covariant _ParteAsyncEffectPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousBrightness =
        oldWidget.brightness ?? oldWidget.block.brightness;
    final previousContrast = oldWidget.contrast ?? oldWidget.block.contrast;
    final previousSharpness = oldWidget.sharpness ?? oldWidget.block.sharpness;
    if (!identical(oldWidget.source, widget.source) ||
        previousBrightness != _brightness ||
        previousContrast != _contrast ||
        previousSharpness != _sharpness ||
        oldWidget.block.grayscale != widget.block.grayscale) {
      _schedulePreview();
    }
  }

  void _schedulePreview() {
    _debounce?.cancel();
    final revision = ++_requestRevision;
    if (_brightness == 1 &&
        _contrast == 1 &&
        _sharpness == 0 &&
        !widget.block.grayscale) {
      _preview = Future.value(widget.source);
      return;
    }
    _debounce = Timer(_previewDebounce, () {
      if (!mounted || _processing || revision != _requestRevision) return;
      _startPreview(revision);
    });
  }

  void _startPreview(int revision) {
    _processing = true;
    final future = compute<Map<String, Object>, Uint8List>(
      applyParteImageEffectsRequest,
      <String, Object>{
        'source': Uint8List.fromList(widget.source),
        'brightness': _brightness,
        'contrast': _contrast,
        'sharpness': _sharpness,
        'grayscale': widget.block.grayscale,
      },
      debugLabel: 'PARTE photo effect preview',
    );
    setState(() => _preview = future);
    unawaited(_finishPreview(future, revision));
  }

  Future<void> _finishPreview(Future<Uint8List> future, int revision) async {
    try {
      await future;
    } catch (_) {
      // FutureBuilder keeps the source image as the safe preview fallback.
    } finally {
      if (mounted) {
        _processing = false;
        if (revision != _requestRevision) _schedulePreview();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _preview,
    initialData: widget.source,
    builder: (context, snapshot) => widget.buildImage(
      snapshot.hasError ? widget.source : snapshot.data ?? widget.source,
    ),
  );
}
