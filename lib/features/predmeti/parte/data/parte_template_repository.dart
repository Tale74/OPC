import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../application/parte_authorization.dart';
import '../domain/parte_models.dart';

enum ParteTemplateImportConflict { replace, importAsCopy, cancel }

class ParteTemplateResolution {
  const ParteTemplateResolution({
    required this.template,
    required this.fallbackUsed,
  });

  final ParteTemplate template;
  final bool fallbackUsed;
}

class ParteTemplateRepository {
  const ParteTemplateRepository(
    this._db, {
    this.authorization = const ParteAuthorization(),
  });

  static const String transferFormat = 'OPC_PARTE_TEMPLATE';
  static const int transferSchemaVersion = 3;
  static const int maxImportBytes = 512 * 1024;

  final AppDatabase _db;
  final ParteAuthorization authorization;

  Future<ParteTemplateResolution> resolveActiveTemplate() async {
    final firma = await (_db.select(
      _db.firmaPodaci,
    )..where((row) => row.id.equals(1))).getSingle();
    final selected = firma.parteDefaultTemplateId.trim();
    if (selected.isEmpty || selected == parteBuiltinTemplateId) {
      return const ParteTemplateResolution(
        template: ParteTemplate.builtInStandard,
        fallbackUsed: false,
      );
    }
    final row = await (_db.select(
      _db.partePredlosci,
    )..where((item) => item.id.equals(selected))).getSingleOrNull();
    if (row == null) {
      return const ParteTemplateResolution(
        template: ParteTemplate.builtInStandard,
        fallbackUsed: true,
      );
    }
    try {
      return ParteTemplateResolution(
        template: _fromRow(row),
        fallbackUsed: false,
      );
    } on FormatException {
      return const ParteTemplateResolution(
        template: ParteTemplate.builtInStandard,
        fallbackUsed: true,
      );
    }
  }

  Future<List<ParteTemplate>> listTemplates() async {
    final rows = await (_db.select(
      _db.partePredlosci,
    )..orderBy([(row) => OrderingTerm.asc(row.naziv)])).get();
    final templates = <ParteTemplate>[ParteTemplate.builtInStandard];
    for (final row in rows) {
      try {
        templates.add(_fromRow(row));
      } on FormatException {
        // Invalid optional templates are skipped; built-in fallback remains.
      }
    }
    return templates;
  }

  Future<void> setDefault({
    required String templateId,
    required KorisniciData actor,
  }) async {
    authorization.requireTemplateAdministration(actor);
    if (templateId != parteBuiltinTemplateId) {
      final exists = await (_db.select(
        _db.partePredlosci,
      )..where((row) => row.id.equals(templateId))).getSingleOrNull();
      if (exists == null) {
        throw StateError('Izabrani PARTE šablon ne postoji.');
      }
    }
    await (_db.update(_db.firmaPodaci)..where((row) => row.id.equals(1))).write(
      FirmaPodaciCompanion(parteDefaultTemplateId: Value(templateId)),
    );
  }

  Future<ParteTemplate> createUserTemplate({
    required KorisniciData actor,
    required String name,
    required ParteTemplate technicalSource,
  }) async {
    authorization.requireTemplateAdministration(actor);
    final cleanName = name.trim();
    if (cleanName.isEmpty || cleanName.length > 80) {
      throw const FormatException('Naziv šablona nije ispravan.');
    }
    final id = _newId();
    final template = ParteTemplate(
      id: id,
      name: cleanName,
      widthMm: technicalSource.widthMm,
      heightMm: technicalSource.heightMm,
      horizontalMarginMm: technicalSource.horizontalMarginMm,
      verticalMarginMm: technicalSource.verticalMarginMm,
      printableZoneXmm: technicalSource.printableZoneXmm,
      printableZoneYmm: technicalSource.printableZoneYmm,
      printableZoneWidthMm: technicalSource.printableZoneWidthMm,
      printableZoneHeightMm: technicalSource.printableZoneHeightMm,
      blocks: technicalSource.blocks,
    );
    _validateContentFree(template);
    final now = DateTime.now().toIso8601String();
    await _db
        .into(_db.partePredlosci)
        .insert(
          PartePredlosciCompanion.insert(
            id: id,
            naziv: cleanName,
            configJson: jsonEncode(template.toJson(includeIdentity: false)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return template;
  }

  Future<ParteTemplate> duplicate({
    required KorisniciData actor,
    required ParteTemplate source,
    required String name,
  }) => createUserTemplate(actor: actor, name: name, technicalSource: source);

  Future<void> rename({
    required KorisniciData actor,
    required String id,
    required String newName,
  }) async {
    authorization.requireTemplateAdministration(actor);
    if (id == parteBuiltinTemplateId) {
      throw StateError('Ugrađeni šablon je nepromenljiv.');
    }
    final cleanName = newName.trim();
    if (cleanName.isEmpty || cleanName.length > 80) {
      throw const FormatException('Naziv šablona nije ispravan.');
    }
    await (_db.update(
      _db.partePredlosci,
    )..where((row) => row.id.equals(id))).write(
      PartePredlosciCompanion(
        naziv: Value(cleanName),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> updateTechnicalLayout({
    required KorisniciData actor,
    required String id,
    required ParteTemplate technicalSource,
  }) async {
    authorization.requireTemplateAdministration(actor);
    if (id == parteBuiltinTemplateId) {
      throw StateError('Ugrađeni šablon je nepromenljiv.');
    }
    final existing = await (_db.select(
      _db.partePredlosci,
    )..where((row) => row.id.equals(id))).getSingle();
    final replacement = ParteTemplate(
      id: id,
      name: existing.naziv,
      widthMm: technicalSource.widthMm,
      heightMm: technicalSource.heightMm,
      horizontalMarginMm: technicalSource.horizontalMarginMm,
      verticalMarginMm: technicalSource.verticalMarginMm,
      printableZoneXmm: technicalSource.printableZoneXmm,
      printableZoneYmm: technicalSource.printableZoneYmm,
      printableZoneWidthMm: technicalSource.printableZoneWidthMm,
      printableZoneHeightMm: technicalSource.printableZoneHeightMm,
      blocks: technicalSource.blocks,
    );
    _validateContentFree(replacement);
    await (_db.update(
      _db.partePredlosci,
    )..where((row) => row.id.equals(id))).write(
      PartePredlosciCompanion(
        configJson: Value(
          jsonEncode(replacement.toJson(includeIdentity: false)),
        ),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> delete({
    required KorisniciData actor,
    required String id,
    String replacementTemplateId = parteBuiltinTemplateId,
  }) async {
    authorization.requireTemplateAdministration(actor);
    if (id == parteBuiltinTemplateId) {
      throw StateError('Ugrađeni šablon ne može biti obrisan.');
    }
    await _db.transaction(() async {
      final firma = await (_db.select(
        _db.firmaPodaci,
      )..where((row) => row.id.equals(1))).getSingle();
      if (firma.parteDefaultTemplateId == id) {
        if (replacementTemplateId != parteBuiltinTemplateId) {
          final replacement =
              await (_db.select(_db.partePredlosci)
                    ..where((row) => row.id.equals(replacementTemplateId)))
                  .getSingleOrNull();
          if (replacement == null || replacement.id == id) {
            throw StateError('Izaberite važeći zamenski podrazumevani šablon.');
          }
        }
        await (_db.update(
          _db.firmaPodaci,
        )..where((row) => row.id.equals(1))).write(
          FirmaPodaciCompanion(
            parteDefaultTemplateId: Value(replacementTemplateId),
          ),
        );
      }
      await (_db.delete(
        _db.partePredlosci,
      )..where((row) => row.id.equals(id))).go();
    });
  }

  String exportTemplate(ParteTemplate template) {
    if (template.builtIn) {
      throw StateError('Ugrađeni šablon se prvo duplira u korisnički.');
    }
    _validateContentFree(template);
    return const JsonEncoder.withIndent('  ').convert({
      'format': transferFormat,
      'schemaVersion': transferSchemaVersion,
      'template': template.toJson(),
    });
  }

  Future<ParteTemplate?> importTemplate({
    required KorisniciData actor,
    required List<int> bytes,
    required ParteTemplateImportConflict conflict,
  }) async {
    authorization.requireTemplateAdministration(actor);
    if (bytes.isEmpty || bytes.length > maxImportBytes) {
      throw const FormatException('PARTE šablon je prazan ili prevelik.');
    }
    final root = jsonDecode(utf8.decode(bytes));
    final sourceVersion = root is Map ? root['schemaVersion'] as int? : null;
    if (root is! Map ||
        root['format'] != transferFormat ||
        sourceVersion == null ||
        sourceVersion < 1 ||
        sourceVersion > transferSchemaVersion) {
      throw const FormatException('PARTE šablon format nije podržan.');
    }
    final rawTemplate = root['template'];
    if (rawTemplate is! Map) {
      throw const FormatException('PARTE šablon nedostaje.');
    }
    final imported = ParteTemplate.fromJson(
      rawTemplate.cast<String, dynamic>(),
    );
    _validateContentFree(imported);
    final existing = await (_db.select(
      _db.partePredlosci,
    )..where((row) => row.id.equals(imported.id))).getSingleOrNull();
    if (existing != null && conflict == ParteTemplateImportConflict.cancel) {
      return null;
    }
    final target =
        existing != null && conflict == ParteTemplateImportConflict.importAsCopy
        ? ParteTemplate(
            id: _newId(),
            name: '${imported.name} — kopija',
            widthMm: imported.widthMm,
            heightMm: imported.heightMm,
            horizontalMarginMm: imported.horizontalMarginMm,
            verticalMarginMm: imported.verticalMarginMm,
            printableZoneXmm: imported.printableZoneXmm,
            printableZoneYmm: imported.printableZoneYmm,
            printableZoneWidthMm: imported.printableZoneWidthMm,
            printableZoneHeightMm: imported.printableZoneHeightMm,
            blocks: imported.blocks,
          )
        : imported;
    final now = DateTime.now().toIso8601String();
    await _db.transaction(() async {
      await _db
          .into(_db.partePredlosci)
          .insert(
            PartePredlosciCompanion.insert(
              id: target.id,
              naziv: target.name,
              configJson: jsonEncode(target.toJson(includeIdentity: false)),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
    return target;
  }

  ParteTemplate _fromRow(PartePredlosciData row) {
    final config = (jsonDecode(row.configJson) as Map).cast<String, dynamic>()
      ..['id'] = row.id
      ..['name'] = row.naziv;
    final template = ParteTemplate.fromJson(config);
    _validateContentFree(template);
    return template;
  }

  void _validateContentFree(ParteTemplate template) {
    if (!template.isValidLandscape ||
        template.id.trim().isEmpty ||
        template.name.trim().isEmpty) {
      throw const FormatException('PARTE šablon nije tehnički validan.');
    }
    final encoded = jsonEncode(template.toJson()).toLowerCase();
    const forbidden = [
      'textbyblock',
      'photomediakey',
      'customsymbolmediakey',
      'predmetid',
      'predmetbroj',
      'externalpath',
      '..\\',
      '../',
    ];
    if (forbidden.any(encoded.contains)) {
      throw const FormatException('Šablon sadrži sadržaj ili putanju.');
    }
  }

  String _newId() {
    final random = Random.secure();
    final suffix = List.generate(
      8,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return 'parte_template_${DateTime.now().microsecondsSinceEpoch}_$suffix';
  }
}
