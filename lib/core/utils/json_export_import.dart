import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show InsertMode, OrderingTerm, Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import '../database/database.dart';
import '../json_transfer/iriu_json_compat.dart';
import '../constants/iriu_constants.dart';
import '../format/app_filename_format.dart';
import '../json_transfer/predmet_json_transfer_core.dart';
import '../../features/auth/data/auth_security_repository.dart';
import '../../features/predmeti/application/full_backup_restore_coordinator.dart';
import '../../features/predmeti/data/predmeti_repository.dart';
import '../../features/predmeti/core_v2/scenario/scenario_persistence_contract.dart';
import '../../features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart';
import '../../features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart';
import '../../features/predmeti/parte/data/parte_media_store.dart';
import '../../features/predmeti/parte/domain/parte_models.dart';
import '../../features/predmeti/reminders/ceremony_notification_gateway.dart';
import '../../features/predmeti/reminders/ceremony_reminder_model.dart';
import '../../features/stanje_robe/data/stanje_robe_posledice_repository.dart';
import 'document_text_codec.dart';
import 'export_utils.dart';

const int _kSchemaVersion = 6;
const int _kBackupSchemaVersion = 9;
const int _kMaxSupportedPredmetSchemaVersion = 7;
const int _kMaxSupportedBackupSchemaVersion = 9;
const int _kPredmetSchemaVersionWithStanjeRobeConsequenceTransfer = 7;
const String _kPredmetTransferFormat = 'OPC_PREDMET';
const String _kLegacyBeleznicaTransferFormat = 'OPC_BELEZNICA';
const String _kBackupTransferFormat = 'OPC_BACKUP';
const String _kStanjeRobeConsequenceTransferBlock =
    'stanjeRobeConsequenceTransfer';
const String _kSinglePredmetScenarioCarrierBlock = 'singlePredmetScenario';
const int _kStanjeRobeConsequenceTransferSchemaVersion = 1;
const String _kStanjeRobeConsequenceTransferPolicy =
    'single_predmet_unresolved_consequence_v1';
const String _kStockBackupPolicySchema16Complete = 'schema16_stock_complete_v1';
const String _kDefaultBusinessScenarioId = 'default_funeral_ceremony_policy';
const String _kDefaultSourceIdentity = 'local_opc';

const Set<String> _kFirmaPodaciBlankTextFields = {
  'naziv',
  'adresa',
  'pib',
  'mb',
  'sifraDelatnosti',
  'telefon',
  'odgovornoLice',
  'email',
  'sajt',
  'parteDefaultTemplateId',
};

const Set<String> _kAppPodesavanjaBlankTextFields = {
  'ziroRacun',
  'nazivBanke',
  'qrPrimalacNaziv',
  'qrSvrhaPlacanja',
};

const Set<String> _kKontaktLicaBlankTextFields = {
  'imePrezime',
  'telefon',
  'email',
  'napomena',
};

const Set<String> _kIriuBlankTextFields = {'nazivPrikaz', 'kom'};

const Set<String> _kLogIzmenaBlankTextFields = {
  'staraVrednost',
  'novaVrednost',
};

const Set<String> _kPredmetBlankTextFields = {
  'ime',
  'prezime',
  'srednje',
  'devojackoPrezime',
  'jmbg',
  'mestoRodjenja',
  'mestoSmrti',
  'uzrokSmrti',
  'adresa',
  'imeOca',
  'imeMajke',
  'bracnoStanje',
  'bracniDrugIme',
  'bracniDrugPrezime',
  'bracniDrugJmbg',
  'bracniDrugDevojacko',
  'zanimanje',
  'titula',
  'cin',
  'nadimak',
  'penzionerNapomena',
  'naruIme',
  'naruPrezime',
  'naruImePrezime',
  'naruJmbg',
  'naruAdresa',
  'naruBrojLk',
  'naruTelefon1',
  'naruTelefon2',
  'naruEmail',
  'naruPlNaziv',
  'naruPlAdresa',
  'naruPlPib',
  'naruPlMb',
  'naruPlOdgovornoLice',
  'naruPlTelefon1',
  'naruPlTelefon2',
  'naruPlEmail',
  'jkpIme',
  'jkpPrezime',
  'jkpImePrezime',
  'jkpJmbg',
  'jkpAdresa',
  'jkpBrojLk',
  'jkpTelefon1',
  'jkpTelefon2',
  'jkpEmail',
  'jkpPlNaziv',
  'jkpPlAdresa',
  'jkpPlPib',
  'jkpPlMb',
  'jkpPlOdgovornoLice',
  'jkpPlTelefon1',
  'jkpPlEmail',
  'groblje',
  'grobljePolaganjaUrne',
  'opeloMesto',
  'parcela',
  'grobBroj',
  'redGrob',
  'npk',
  'grobnica',
  'urnaSifra',
  'urnaParcela',
  'urnaBroj',
  'urnaRed',
  'urnaNpk',
  'svisZemlja',
  'svisGrad',
  'docekMesto',
  'docekDatum',
  'parteIme',
  'ozaloseni',
  'napomenaPlacanja',
  'napomena',
};

const Set<String> _kPredmetRequiredTextFields = {
  'brojPredmeta',
  'status',
  'datumKreiranja',
  'businessScenarioId',
  'sourceIdentity',
  ..._kPredmetBlankTextFields,
  'pol',
  'datumRodjenja',
  'datumSmrti',
  'bracniDrugPol',
  'radniStatus',
  'penzioner',
  'penzionerSrbije',
  'vojniPenzioner',
  'vojnePocasti',
  'posmrtnaPomoc',
  'narucilacRefundira',
  'bracniDrugOstvarujePravo',
  'bracniDrugJePenzioner',
  'naruTip',
  'jkpTip',
  'tipGroblja',
  'vrstaCeremonije',
  'datumCeremonije',
  'vremeCeremonije',
  'opelo',
  'vremeOpela',
  'vremeIspracaja',
  'grobnoMesto',
  'tipGrobnogMesta',
  'tipPolaganja',
  'docekVreme',
  'simbol',
  'pismo',
  'nacinPlacanja',
};

const Set<String> _kPredmetRequiredIntFields = {
  'id',
  'verzija',
  'exportVerzija',
};

const Set<String> _kPredmetOptionalIntFields = {
  'savetnikId',
  'createdByKorisnikId',
  'lastBusinessModifiedByKorisnikId',
};

const Set<String> _kPredmetRequiredBoolFields = {
  'zanimanjeNaParti',
  'titulaIspred',
  'cinNaParti',
  'srednjeNaParti',
  'nadimakNaParti',
  'nadimakCrtica',
  'naruIstiZaJkp',
  'sahranaVanSrbije',
  'docekPosmrtnihOstataka',
  'promenaSanduka',
  'jkpPlacaSamostalno',
  'partePotrebna',
};

const Set<String> _kPredmetRequiredNumberFields = {
  'refundacijaPio',
  'avans',
  'troskoviJkp',
  'popust',
};

const Set<String> _kKnownStanjeRobeEffectStatuses = {
  'APPLIED',
  'RESTORED',
  'UNRESOLVED',
  'CLEARED',
};

const Set<String> _kKnownStanjeRobePoslediceStatuses = {
  'UNRESOLVED',
  'RESOLVED',
  'CLEARED',
  'SUPERSEDED',
};

const Set<String> _kStanjeRobeConsequenceTransferCoveredCategories = {
  'SANDUK',
  'OBELEZJE',
  'POKROV_GARNITURA',
};

const Set<String> _kStanjeRobeConsequenceTransferForbiddenItemFields = {
  'id',
  'predmetId',
  'iriuId',
  'availableQuantityAtCreation',
  'shortageQuantityAtCreation',
  'resolvedAt',
  'resolvedReason',
  'warehouseQuantity',
  'warehouseQuantities',
  'trenutnaKolicina',
  'minimalnaKolicina',
  'stanjeRobeStavkaId',
  'appliedEffectId',
  'effectId',
  'effectStatus',
};

enum _PredmetConflictChoice { keepLocal, replaceImported, cancel }

enum _BackupImportStatus {
  stockCompleteRestored,
  nonStockImportedWithoutStockRestore,
}

class _ImportBlokiranException implements Exception {
  const _ImportBlokiranException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _PredmetTransferPayload {
  const _PredmetTransferPayload({
    required this.predmet,
    required this.iriu,
    required this.kontaktLica,
    required this.stanjeRobeConsequences,
    required this.scenarioCarrier,
  });

  final PredmetiData predmet;
  final List<IriuData> iriu;
  final List<KontaktLicaData> kontaktLica;
  final List<_StanjeRobeConsequenceTransferItem> stanjeRobeConsequences;
  final SinglePredmetScenarioCarrierBlock? scenarioCarrier;
}

class _StanjeRobeConsequenceTransferItem {
  const _StanjeRobeConsequenceTransferItem({
    required this.iriuTransferIndex,
    required this.kategorija,
    required this.katalogStableArticleId,
    required this.selectedNazivSnapshot,
    required this.selectedIznosSnapshot,
    required this.consequenceType,
    required this.status,
    required this.effectQuantity,
    this.sourceLifecycleEvent,
    this.createdAt,
    this.updatedAt,
  });

  final int iriuTransferIndex;
  final String kategorija;
  final String katalogStableArticleId;
  final String selectedNazivSnapshot;
  final double selectedIznosSnapshot;
  final String consequenceType;
  final String status;
  final double effectQuantity;
  final String? sourceLifecycleEvent;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'iriuTransferIndex': iriuTransferIndex,
      'kategorija': kategorija,
      'katalogStableArticleId': katalogStableArticleId,
      'selectedNazivSnapshot': selectedNazivSnapshot,
      'selectedIznosSnapshot': selectedIznosSnapshot,
      'consequenceType': consequenceType,
      'status': status,
      'effectQuantity': effectQuantity,
      if (sourceLifecycleEvent != null)
        'sourceLifecycleEvent': sourceLifecycleEvent,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class _BackupImportResult {
  const _BackupImportResult(
    this.status, {
    this.reminderSchedulingFailures = 0,
    this.skippedOrphanReminderSettings = 0,
    this.skippedOrphanLogEntries = 0,
  });

  final _BackupImportStatus status;
  final int reminderSchedulingFailures;
  final int skippedOrphanReminderSettings;
  final int skippedOrphanLogEntries;

  String get message {
    final baseMessage = switch (status) {
      _BackupImportStatus.stockCompleteRestored =>
        'Baza uspešno uvezena sa podržanim prenosom STANJA ROBE.',
      _BackupImportStatus.nonStockImportedWithoutStockRestore =>
        'Baza uspešno uvezena. Izabrana kopija ne sadrži '
            'podržan prenos STANJA ROBE, pa stanje robe nije obnovljeno.',
    };
    final warnings = <String>[
      if (skippedOrphanReminderSettings > 0)
        'Neka zastarela podešavanja podsetnika nisu preneta '
            '(broj: $skippedOrphanReminderSettings).',
      if (skippedOrphanLogEntries > 0)
        'Neki zastareli zapisi istorije nisu preneti '
            '(broj: $skippedOrphanLogEntries).',
      if (reminderSchedulingFailures > 0)
        'Neke lokalne podsetnike treba ručno proveriti '
            '(broj: $reminderSchedulingFailures).',
    ];
    return warnings.isEmpty
        ? baseMessage
        : '$baseMessage ${warnings.join(' ')}';
  }
}

class _BackupReminderSetting {
  const _BackupReminderSetting({
    required this.predmetId,
    required this.enabled,
    required this.deliveryTimes,
  });

  final int predmetId;
  final bool enabled;
  final List<String> deliveryTimes;
}

class _BackupReminderPayload {
  const _BackupReminderPayload({
    required this.settings,
    required this.skippedOrphans,
  });

  final List<_BackupReminderSetting> settings;
  final int skippedOrphans;
}

class _StockBackupPayload {
  const _StockBackupPayload({
    required this.supported,
    required this.stavke,
    required this.appliedEffects,
    required this.posledice,
  });

  final bool supported;
  final List<Map<String, dynamic>> stavke;
  final List<Map<String, dynamic>> appliedEffects;
  final List<Map<String, dynamic>> posledice;
}

// FILE NAMES

String predmetFajlNaziv(PredmetiData p) {
  return joinFilenameParts([
    p.prezime,
    p.ime,
    p.brojPredmeta,
    'v${p.verzija}',
  ], 'json');
}

String backupFajlNaziv() {
  final sada = DateTime.now();
  final dd = sada.day.toString().padLeft(2, '0');
  final mm = sada.month.toString().padLeft(2, '0');
  final yyyy = sada.year.toString();
  final hh = sada.hour.toString().padLeft(2, '0');
  final min = sada.minute.toString().padLeft(2, '0');
  return joinFilenameParts(['OPC', 'backup', '$dd$mm${yyyy}_$hh$min'], 'json');
}

// SERIALIZATION

Map<String, dynamic> _firmaPodaciToMap(FirmaPodaciData f) {
  final m = Map<String, dynamic>.from(f.toJson());
  m['logo'] = f.logo != null ? base64Encode(f.logo!) : null;
  return m;
}

Map<String, dynamic> _katalogArtikliToMap(KatalogArtikliData k) {
  final m = Map<String, dynamic>.from(k.toJson());
  m['fotografija'] = k.fotografija != null
      ? base64Encode(k.fotografija!)
      : null;
  return m;
}

Map<String, dynamic> _normalizeDocumentMap(Map<String, dynamic> value) {
  return documentTextCodec.normalizeMap(value);
}

Future<SinglePredmetScenarioCarrierBlock?> _scenarioCarrierForExport({
  required AppDatabase db,
  required int predmetId,
  required List<IriuData> iriu,
}) async {
  final snapshot = await (db.select(
    db.predmetScenarioSnapshots,
  )..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();
  if (snapshot == null) return null;

  final assignment = ScenarioAssignmentSnapshot.fromJsonMap(
    (jsonDecode(snapshot.snapshotJson) as Map).cast<String, dynamic>(),
  );
  final provenanceRows =
      await (db.select(db.iriuProvenance)..where(
            (row) => row.iriuId.isIn(iriu.map((item) => item.id).toList()),
          ))
          .get();
  final provenanceById = {for (final row in provenanceRows) row.iriuId: row};
  final complete = iriu.every((row) => provenanceById.containsKey(row.id));
  final envelope = ScenarioTransferEnvelope.create(
    assignment: assignment,
    provenanceCoverage: complete
        ? ScenarioIriuProvenanceCoverage.complete
        : ScenarioIriuProvenanceCoverage.unavailable,
    provenance: complete
        ? iriu
              .map((row) {
                final item = provenanceById[row.id]!;
                return ScenarioIriuProvenance(
                  iriuId: row.id,
                  origin: ScenarioIriuOriginKindWire.fromWireName(item.origin),
                  moduleId: item.moduleId,
                  scenarioId: item.scenarioId,
                  scenarioVersion: item.scenarioVersion,
                  ruleId: item.ruleId,
                  operationId: item.operationId,
                );
              })
              .toList(growable: false)
        : const [],
  );
  return SinglePredmetScenarioCarrierBlock.fromEnvelope(
    envelope: envelope,
    sourceIriuIds: iriu.map((row) => row.id).toList(growable: false),
  );
}

Future<String> _serijalizujPredmet(
  PredmetiData p,
  List<IriuData> iriu,
  List<KontaktLicaData> kl,
  List<StanjeRobePoslediceData> stanjeRobePosledice, {
  SinglePredmetScenarioCarrierBlock? scenarioCarrier,
}) {
  final consequenceTransferItems = _stanjeRobeConsequenceTransferItemsForExport(
    iriu: iriu,
    posledice: stanjeRobePosledice,
  );
  final hasConsequenceTransfer = consequenceTransferItems.isNotEmpty;
  final jsonTransferIncludes = <String>[
    'predmet',
    'iriu',
    'kontaktLica',
    if (hasConsequenceTransfer) _kStanjeRobeConsequenceTransferBlock,
  ];
  final map = <String, dynamic>{
    'format': _kPredmetTransferFormat,
    'schemaVersion': hasConsequenceTransfer
        ? _kPredmetSchemaVersionWithStanjeRobeConsequenceTransfer
        : _kSchemaVersion,
    'entityType': 'PREDMET',
    'documentSourceIdentity': 'PREDMET',
    'encoding': 'utf-8',
    'exportVerzija': p.exportVerzija,
    'exportDatum': DateTime.now().toIso8601String(),
    'sourceExpectations': <String, dynamic>{
      'parte': <String, dynamic>{
        'source': 'PREDMET',
        'mustRemainFaithfulDerivative': true,
        'fields': <String>['simbol', 'pismo', 'parteIme', 'ozaloseni'],
      },
      'citulje': <String, dynamic>{
        'requiresPredmetSource': true,
        'relatedDataSource': 'IRIU',
        'placeholderNarrativeAllowed': false,
      },
      'jsonTransfer': <String, dynamic>{
        'identity': 'single-PREDMET',
        'includes': [
          ...jsonTransferIncludes,
          if (scenarioCarrier != null) _kSinglePredmetScenarioCarrierBlock,
        ],
      },
    },
    'predmet': _normalizeDocumentMap(p.toJson()),
    'iriu': iriu.map((i) => _normalizeDocumentMap(i.toJson())).toList(),
    'kontaktLica': kl.map((k) => _normalizeDocumentMap(k.toJson())).toList(),
    if (hasConsequenceTransfer)
      _kStanjeRobeConsequenceTransferBlock: <String, dynamic>{
        'schemaVersion': _kStanjeRobeConsequenceTransferSchemaVersion,
        'policy': _kStanjeRobeConsequenceTransferPolicy,
        'items': consequenceTransferItems.map((item) => item.toJson()).toList(),
      },
    if (scenarioCarrier != null)
      _kSinglePredmetScenarioCarrierBlock: scenarioCarrier.toJsonMap(),
  };
  return Future.value(
    PredmetJsonTransferCore.encodeMap(
      documentTextCodec.normalizeValue(map) as Map<String, dynamic>,
    ),
  );
}

List<_StanjeRobeConsequenceTransferItem>
_stanjeRobeConsequenceTransferItemsForExport({
  required List<IriuData> iriu,
  required List<StanjeRobePoslediceData> posledice,
}) {
  final items = <_StanjeRobeConsequenceTransferItem>[];
  for (final consequence in posledice) {
    if (consequence.status != stanjeRobePosledicaStatusUnresolved ||
        consequence.consequenceType !=
            stanjeRobePosledicaTypeInsufficientStock ||
        consequence.effectQuantity != 1.0 ||
        !_kStanjeRobeConsequenceTransferCoveredCategories.contains(
          consequence.kategorija,
        )) {
      continue;
    }

    final transferIndex = iriu.indexWhere(
      (row) =>
          row.id == consequence.iriuId &&
          row.interniNaziv == consequence.kategorija &&
          _normalizeNullableStableArticleId(row.katalogStableArticleId) ==
              consequence.katalogStableArticleId.trim(),
    );
    if (transferIndex < 0) {
      continue;
    }

    final selectedNazivSnapshot = consequence.selectedNazivSnapshot.trim();
    final stableArticleId = consequence.katalogStableArticleId.trim();
    if (selectedNazivSnapshot.isEmpty || stableArticleId.isEmpty) {
      continue;
    }

    items.add(
      _StanjeRobeConsequenceTransferItem(
        iriuTransferIndex: transferIndex,
        kategorija: consequence.kategorija,
        katalogStableArticleId: stableArticleId,
        selectedNazivSnapshot: selectedNazivSnapshot,
        selectedIznosSnapshot: consequence.selectedIznosSnapshot,
        consequenceType: stanjeRobePosledicaTypeInsufficientStock,
        status: stanjeRobePosledicaStatusUnresolved,
        effectQuantity: 1.0,
        sourceLifecycleEvent: consequence.sourceLifecycleEvent.trim().isEmpty
            ? null
            : consequence.sourceLifecycleEvent.trim(),
        createdAt: consequence.createdAt.trim().isEmpty
            ? null
            : consequence.createdAt.trim(),
        updatedAt: consequence.updatedAt.trim().isEmpty
            ? null
            : consequence.updatedAt.trim(),
      ),
    );
  }
  return items;
}

Future<String> _serijalizujBackup(AppDatabase db) async {
  final predmeti = await db.select(db.predmeti).get();
  final iriu = await db.select(db.iriu).get();
  final kl = await db.select(db.kontaktLica).get();
  final korisnici = await db.select(db.korisnici).get();
  final firma = await (db.select(
    db.firmaPodaci,
  )..where((t) => t.id.equals(1))).getSingle();
  final katalog = await db.select(db.katalogArtikli).get();
  final iriuKat = await db.select(db.iriuKatalogConfig).get();
  final apPod = await (db.select(
    db.appPodesavanja,
  )..where((t) => t.id.equals(1))).getSingle();
  final predlosci = await db.select(db.predlosciDokumenata).get();
  final partePredlosci = await db.select(db.partePredlosci).get();
  final partePripreme = await db.select(db.partePripreme).get();
  final log = await db.select(db.logIzmena).get();
  final stanjeRobeStavke = await db.select(db.stanjeRobeStavke).get();
  final stanjeRobeAppliedEffects = await db
      .select(db.stanjeRobeAppliedEffects)
      .get();
  final stanjeRobePosledice = await db.select(db.stanjeRobePosledice).get();
  final scenarioSnapshots = await db.select(db.predmetScenarioSnapshots).get();
  final scenarioProvenance = await db.select(db.iriuProvenance).get();
  final scenarioModules = await db.select(db.scenarioModules).get();
  final scenarioDefinitions = await db.select(db.scenarioDefinitions).get();
  final reminderSettings = await db.customSelect('''
      SELECT predmet_id, enabled, delivery_times
      FROM ceremony_reminder_settings
      ORDER BY predmet_id
    ''').get();
  final exportedPredmetIds = predmeti.map((item) => item.id).toSet();
  final exportedIriuIds = iriu.map((item) => item.id).toSet();
  final stanjeRobeAppliedEffectsZaExport =
      _referencijalnoValidniAppliedEffectsZaBackup(
        appliedEffects: stanjeRobeAppliedEffects,
        predmeti: predmeti,
        iriu: iriu,
      );
  final iriuLifecycle = await db.customSelect('''
      SELECT id, predmet_id, interni_naziv, scope_key, decision_key, created_at
      FROM iriu_lifecycle_decisions
      ORDER BY id
    ''', readsFrom: {}).get();

  final map = <String, dynamic>{
    'format': _kBackupTransferFormat,
    'schemaVersion': _kBackupSchemaVersion,
    'exportDatum': DateTime.now().toIso8601String(),
    'entityType': 'FULL_DATABASE_BACKUP',
    'databaseIdentity': 'OPC',
    'stockBackupPolicy': _kStockBackupPolicySchema16Complete,
    'predmeti': predmeti.map((p) => p.toJson()).toList(),
    'iriu': iriu.map((i) => i.toJson()).toList(),
    'predmetScenarioSnapshots': scenarioSnapshots
        .where((row) => exportedPredmetIds.contains(row.predmetId))
        .map((row) => row.toJson())
        .toList(),
    'iriuProvenance': scenarioProvenance
        .where((row) => exportedIriuIds.contains(row.iriuId))
        .map((row) => row.toJson())
        .toList(),
    'kontaktLica': kl.map((k) => k.toJson()).toList(),
    'iriuLifecycleDecisions': iriuLifecycle.map((row) => row.data).toList(),
    'korisnici': korisnici.map((k) => k.toJson()).toList(),
    'firmaPodaci': _firmaPodaciToMap(firma),
    'katalogArtikli': katalog.map(_katalogArtikliToMap).toList(),
    'iriuKatalogConfig': iriuKat.map((k) => k.toJson()).toList(),
    'appPodesavanja': apPod.toJson(),
    'predlosciDokumenata': predlosci.map((p) => p.toJson()).toList(),
    'partePredlosci': partePredlosci.map((p) => p.toJson()).toList(),
    'partePripreme': partePripreme
        .where((row) => exportedPredmetIds.contains(row.predmetId))
        .map((row) => row.toJson())
        .toList(),
    'scenarioModules': scenarioModules.map((row) => row.toJson()).toList(),
    'scenarioDefinitions': scenarioDefinitions
        .map((row) => row.toJson())
        .toList(),
    'logIzmena': log
        .where((item) => exportedPredmetIds.contains(item.predmetId))
        .map((item) => item.toJson())
        .toList(),
    'stanjeRobeStavke': stanjeRobeStavke.map((s) => s.toJson()).toList(),
    'stanjeRobeAppliedEffects': stanjeRobeAppliedEffectsZaExport
        .map((e) => e.toJson())
        .toList(),
    'stanjeRobePosledice': stanjeRobePosledice.map((p) => p.toJson()).toList(),
    'ceremonyReminderSettings': reminderSettings
        .where(
          (row) => exportedPredmetIds.contains(row.read<int>('predmet_id')),
        )
        .map(
          (row) => <String, dynamic>{
            'predmetId': row.read<int>('predmet_id'),
            'enabled': row.read<int>('enabled') == 1,
            'deliveryTimes': jsonDecode(row.read<String>('delivery_times')),
          },
        )
        .toList(),
  };
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(documentTextCodec.normalizeValue(map));
}

List<StanjeRobeAppliedEffect> _referencijalnoValidniAppliedEffectsZaBackup({
  required List<StanjeRobeAppliedEffect> appliedEffects,
  required List<PredmetiData> predmeti,
  required List<IriuData> iriu,
}) {
  final predmetIds = predmeti.map((p) => p.id).toSet();
  final iriuPredmetIds = <int, int>{
    for (final row in iriu) row.id: row.predmetId,
  };

  return appliedEffects
      .where((effect) {
        if (!predmetIds.contains(effect.predmetId)) {
          return false;
        }

        final iriuId = effect.iriuId;
        if (iriuId == null) {
          return true;
        }

        return iriuPredmetIds[iriuId] == effect.predmetId;
      })
      .toList(growable: false);
}

// DESERIALIZATION

Map<String, dynamic> _withDecodedBlob(Map<String, dynamic> map, String key) {
  final val = map[key];
  if (val is String) {
    return {...map, key: Uint8List.fromList(base64Decode(val))};
  }
  return map;
}

Map<String, dynamic> _normalizujBackupPrazanTekst(
  Map<String, dynamic> row,
  String section,
  Iterable<String> keys,
) {
  final normalized = Map<String, dynamic>.from(row);
  for (final key in keys) {
    final value = normalized[key];
    if (value == null) {
      normalized[key] = '';
    } else if (value is! String) {
      throw _ImportBlokiranException(
        'Neispravan backup: sekcija $section, polje $key ima nevažeću vrednost.',
      );
    }
  }
  return normalized;
}

void _zahtevajBackupTekstPolja(
  Map<String, dynamic> row,
  String section,
  Iterable<String> keys,
) {
  for (final key in keys) {
    if (row[key] is! String) {
      throw _ImportBlokiranException(
        'Neispravan backup: sekcija $section, polje $key ima nevažeću vrednost.',
      );
    }
  }
}

Map<String, dynamic> _normalizujBackupPredmetMap(Map<String, dynamic> row) {
  final normalized = _normalizujBackupPrazanTekst(
    row,
    'predmeti',
    _kPredmetBlankTextFields,
  );

  normalized['businessScenarioId'] ??= _kDefaultBusinessScenarioId;
  normalized['sourceIdentity'] ??= _kDefaultSourceIdentity;
  normalized['partePotrebna'] ??= false;
  normalized['promenaSanduka'] ??= false;

  _zahtevajBackupTekstPolja(
    normalized,
    'predmeti',
    _kPredmetRequiredTextFields,
  );
  _optionalString(normalized, 'lastBusinessModifiedAt', 'predmeti');

  for (final key in _kPredmetRequiredIntFields) {
    _requiredInt(normalized, key, 'predmeti');
  }
  for (final key in _kPredmetOptionalIntFields) {
    _optionalInt(normalized, key, 'predmeti');
  }
  for (final key in _kPredmetRequiredBoolFields) {
    _requiredBool(normalized, key, 'predmeti');
  }
  for (final key in _kPredmetRequiredNumberFields) {
    _requiredFiniteNumber(normalized, key, 'predmeti');
  }

  return normalized;
}

Map<String, dynamic> _normalizujBackupAppPodesavanjaMap(
  Map<String, dynamic> row,
) {
  final normalized = _normalizujBackupPrazanTekst(
    row,
    'appPodesavanja',
    _kAppPodesavanjaBlankTextFields,
  );
  const operationalToggleKey = 'stanjeRobeOperativnoOmoguceno';
  if (!normalized.containsKey(operationalToggleKey)) {
    normalized[operationalToggleKey] = false;
  } else {
    _requiredBool(normalized, operationalToggleKey, 'appPodesavanja');
  }
  return normalized;
}

Map<String, dynamic> _normalizujBackupFirmaPodaciMap(Map<String, dynamic> row) {
  final normalized = _normalizujBackupPrazanTekst(
    row,
    'firmaPodaci',
    _kFirmaPodaciBlankTextFields,
  );
  if ((normalized['parteDefaultTemplateId'] as String).trim().isEmpty) {
    normalized['parteDefaultTemplateId'] = parteBuiltinTemplateId;
  }
  return normalized;
}

Map<String, dynamic> _normalizujBackupIriuKatalogConfigMap(
  Map<String, dynamic> row,
) {
  final normalized = Map<String, dynamic>.from(row);
  final internalName = normalized['interniNaziv'];
  final builtInBasic =
      internalName is String &&
      (<String>{
        ...IriuK.ugradjeneOsnovnePreAgencijskih,
        IriuK.agencijskeUsluge,
      }).contains(internalName);
  normalized['osnovnaUSvakomPredmetu'] ??= builtInBasic;
  normalized['cena'] ??= 0.0;
  _requiredBool(normalized, 'osnovnaUSvakomPredmetu', 'iriuKatalogConfig');
  return normalized;
}

T _procitajBackupRed<T>(
  String section,
  Map<String, dynamic> row,
  T Function(Map<String, dynamic> row) parse,
) {
  try {
    return parse(row);
  } on _ImportBlokiranException {
    rethrow;
  } catch (_) {
    throw _ImportBlokiranException(
      'Neispravan backup: sekcija $section ima nevažeću vrednost.',
    );
  }
}

Future<void> _uvoziPredmetUBazu(
  AppDatabase db,
  Map<String, dynamic> json,
) async {
  final payload = _procitajPredmetTransferPayload(json);
  await db.transaction(() async {
    final newId = await PredmetiRepository(db).uveziPredmetSaPovezanimPodacima(
      predmet: payload.predmet,
      iriu: payload.iriu,
      kontaktLica: payload.kontaktLica,
    );
    await _restoreImportedScenarioCarrier(
      db: db,
      predmetId: newId,
      importedIriu: payload.iriu,
      carrier: payload.scenarioCarrier,
    );
    await _attachImportedStanjeRobeConsequences(
      db: db,
      predmetId: newId,
      importedIriu: payload.iriu,
      consequenceItems: payload.stanjeRobeConsequences,
    );
  });
}

Future<void> _zameniPredmetUBazi({
  required AppDatabase db,
  required int lokalniPredmetId,
  required Map<String, dynamic> json,
}) async {
  final payload = _procitajPredmetTransferPayload(json);
  await db.transaction(() async {
    await PredmetiRepository(db).zameniPredmetSaPovezanimPodacima(
      lokalniPredmetId: lokalniPredmetId,
      predmet: payload.predmet,
      iriu: payload.iriu,
      kontaktLica: payload.kontaktLica,
    );
    await _restoreImportedScenarioCarrier(
      db: db,
      predmetId: lokalniPredmetId,
      importedIriu: payload.iriu,
      carrier: payload.scenarioCarrier,
    );
    await _attachImportedStanjeRobeConsequences(
      db: db,
      predmetId: lokalniPredmetId,
      importedIriu: payload.iriu,
      consequenceItems: payload.stanjeRobeConsequences,
    );
  });
}

Future<void> _restoreImportedScenarioCarrier({
  required AppDatabase db,
  required int predmetId,
  required List<IriuData> importedIriu,
  required SinglePredmetScenarioCarrierBlock? carrier,
}) async {
  if (carrier == null) return;
  final localIriu = await _listIriuForImportedPredmet(db, predmetId);
  if (localIriu.length != importedIriu.length) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer nije bezbedno mapirati SCENARIO carrier na IRIU redove.',
    );
  }
  final envelope = carrier.resolveToEnvelope(
    destinationIriuIds: localIriu.map((row) => row.id).toList(growable: false),
  );
  await db
      .into(db.predmetScenarioSnapshots)
      .insertOnConflictUpdate(
        PredmetScenarioSnapshotsCompanion.insert(
          predmetId: Value(predmetId),
          moduleId: envelope.assignment.moduleId,
          scenarioId: envelope.assignment.scenarioId,
          scenarioVersion: envelope.assignment.scenarioVersion,
          snapshotJson: jsonEncode(envelope.assignment.toJsonMap()),
          snapshotHash: envelope.assignment.snapshotHash,
          assignedAt: envelope.assignment.assignedAt,
          assignedByKorisnikId: Value(envelope.assignment.assignedByKorisnikId),
        ),
      );
  if (envelope.provenanceCoverage != ScenarioIriuProvenanceCoverage.complete) {
    return;
  }
  for (final item in envelope.provenance) {
    await db
        .into(db.iriuProvenance)
        .insertOnConflictUpdate(
          IriuProvenanceCompanion.insert(
            iriuId: Value(item.iriuId),
            origin: item.origin.wireName,
            moduleId: Value(item.moduleId),
            scenarioId: Value(item.scenarioId),
            scenarioVersion: Value(item.scenarioVersion),
            ruleId: Value(item.ruleId),
            operationId: Value(item.operationId),
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }
}

Future<void> _attachImportedStanjeRobeConsequences({
  required AppDatabase db,
  required int predmetId,
  required List<IriuData> importedIriu,
  required List<_StanjeRobeConsequenceTransferItem> consequenceItems,
}) async {
  if (consequenceItems.isEmpty) return;

  final localIriu = await _listIriuForImportedPredmet(db, predmetId);
  if (localIriu.length != importedIriu.length) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer nije bezbedno mapirati STANJE ROBE posledice na IRIU redove.',
    );
  }

  final repository = StanjeRobePoslediceRepository(db);
  for (final item in consequenceItems) {
    final localRow = localIriu[item.iriuTransferIndex];
    _validateStanjeRobeConsequenceAgainstIriu(
      item: item,
      iriuRow: localRow,
      section: _kStanjeRobeConsequenceTransferBlock,
    );
    await repository.insertImportedUnresolved(
      predmetId: predmetId,
      iriuId: localRow.id,
      kategorija: item.kategorija,
      katalogStableArticleId: item.katalogStableArticleId,
      selectedNazivSnapshot: item.selectedNazivSnapshot,
      selectedIznosSnapshot: item.selectedIznosSnapshot,
      effectQuantity: item.effectQuantity,
      sourceLifecycleEvent:
          item.sourceLifecycleEvent ??
          stanjeRobePosledicaEventSinglePredmetJsonImport,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}

Future<List<IriuData>> _listIriuForImportedPredmet(
  AppDatabase db,
  int predmetId,
) {
  return (db.select(db.iriu)
        ..where((i) => i.predmetId.equals(predmetId))
        ..orderBy([(i) => OrderingTerm.asc(i.id)]))
      .get();
}

Future<_BackupImportResult> _uvoziBackupUBazu(
  AppDatabase db,
  Map<String, dynamic> json,
) async {
  final stockPayload = await _procitajStanjeRobeBackupPayload(db, json);
  final reminderPayload = _procitajBackupReminderSettings(json);
  final backupPredmetIds = _requiredMapList(
    json,
    'predmeti',
  ).map((row) => row['id']).whereType<int>().toSet();
  final hasScenarioState =
      json['scenarioModules'] is List || json['scenarioDefinitions'] is List;
  var skippedOrphanLogEntries = 0;

  await db.transaction(() async {
    await db.delete(db.stanjeRobePosledice).go();
    await db.delete(db.stanjeRobeAppliedEffects).go();
    await db.delete(db.stanjeRobeStavke).go();
    await db.customStatement('DELETE FROM iriu_lifecycle_decisions');
    await db.delete(db.logIzmena).go();
    await db.customStatement('DELETE FROM ceremony_reminder_settings');
    await db.delete(db.partePripreme).go();
    await db.delete(db.kontaktLica).go();
    await db.delete(db.predmetScenarioSnapshots).go();
    await db.delete(db.iriuProvenance).go();
    await db.delete(db.iriu).go();
    await db.delete(db.predmeti).go();
    await db.delete(db.korisnici).go();
    await db.delete(db.firmaPodaci).go();
    await db.delete(db.katalogArtikli).go();
    await db.delete(db.iriuKatalogConfig).go();
    await db.delete(db.appPodesavanja).go();
    await db.delete(db.predlosciDokumenata).go();
    await db.delete(db.partePredlosci).go();
    if (hasScenarioState) {
      await db.delete(db.scenarioDefinitions).go();
      await db.delete(db.scenarioModules).go();
    }

    for (final k in _requiredMapList(json, 'korisnici')) {
      _zahtevajBackupTekstPolja(k, 'korisnici', const [
        'imePrezime',
        'uloga',
        'pinHash',
        'datumKreiranja',
      ]);
      await db
          .into(db.korisnici)
          .insert(
            _procitajBackupRed(
              'korisnici',
              k,
              (row) => KorisniciData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    final firmMap = _withDecodedBlob(
      _normalizujBackupFirmaPodaciMap(
        (json['firmaPodaci'] as Map).cast<String, dynamic>(),
      ),
      'logo',
    );
    await db
        .into(db.firmaPodaci)
        .insert(
          _procitajBackupRed(
            'firmaPodaci',
            firmMap,
            (row) => FirmaPodaciData.fromJson(row),
          ).toCompanion(true),
          mode: InsertMode.insertOrReplace,
        );

    for (final k in _requiredMapList(json, 'katalogArtikli')) {
      _zahtevajBackupTekstPolja(k, 'katalogArtikli', const [
        'interniNazivKategorije',
        'naziv',
      ]);
      final m = _withDecodedBlob(k, 'fotografija');
      await db
          .into(db.katalogArtikli)
          .insert(
            _procitajBackupRed(
              'katalogArtikli',
              m,
              (row) => KatalogArtikliData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final k in _requiredMapList(json, 'iriuKatalogConfig')) {
      final normalizedKatalogConfig = _normalizujBackupIriuKatalogConfigMap(k);
      _zahtevajBackupTekstPolja(
        normalizedKatalogConfig,
        'iriuKatalogConfig',
        const ['interniNaziv', 'nazivPrikaz', 'tip'],
      );
      await db
          .into(db.iriuKatalogConfig)
          .insert(
            _procitajBackupRed(
              'iriuKatalogConfig',
              normalizedKatalogConfig,
              (row) => IriuKatalogConfigData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    final appPodesavanjaMap = _normalizujBackupAppPodesavanjaMap(
      (json['appPodesavanja'] as Map).cast<String, dynamic>(),
    );
    _zahtevajBackupTekstPolja(appPodesavanjaMap, 'appPodesavanja', const [
      'qrSifraPlacanja',
      'pozivNaBrojTip',
    ]);
    await db
        .into(db.appPodesavanja)
        .insert(
          _procitajBackupRed(
            'appPodesavanja',
            appPodesavanjaMap,
            (row) => AppPodesavanjaData.fromJson(row),
          ).toCompanion(true),
          mode: InsertMode.insertOrReplace,
        );

    for (final p in _requiredMapList(json, 'predlosciDokumenata')) {
      _zahtevajBackupTekstPolja(p, 'predlosciDokumenata', const [
        'naziv',
        'segmenti',
        'format',
      ]);
      await db
          .into(db.predlosciDokumenata)
          .insert(
            _procitajBackupRed(
              'predlosciDokumenata',
              p,
              (row) => PredlosciDokumenataData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final p in _optionalMapList(json, 'partePredlosci')) {
      try {
        _zahtevajBackupTekstPolja(p, 'partePredlosci', const [
          'id',
          'naziv',
          'configJson',
          'createdAt',
          'updatedAt',
        ]);
        final row = PartePredlosciData.fromJson(p);
        final config =
            (jsonDecode(row.configJson) as Map).cast<String, dynamic>()
              ..['id'] = row.id
              ..['name'] = row.naziv;
        ParteTemplate.fromJson(config);
        await db
            .into(db.partePredlosci)
            .insert(row.toCompanion(true), mode: InsertMode.insertOrReplace);
      } catch (_) {
        // Optional invalid FIRMA templates do not invalidate an otherwise
        // valid legacy backup. The built-in default remains available.
      }
    }

    final importedFirma = await (db.select(
      db.firmaPodaci,
    )..where((row) => row.id.equals(1))).getSingle();
    if (importedFirma.parteDefaultTemplateId != parteBuiltinTemplateId) {
      final selected =
          await (db.select(db.partePredlosci)..where(
                (row) => row.id.equals(importedFirma.parteDefaultTemplateId),
              ))
              .getSingleOrNull();
      if (selected == null) {
        await (db.update(
          db.firmaPodaci,
        )..where((row) => row.id.equals(1))).write(
          const FirmaPodaciCompanion(
            parteDefaultTemplateId: Value(parteBuiltinTemplateId),
          ),
        );
      }
    }

    if (hasScenarioState) {
      for (final module in _optionalMapList(json, 'scenarioModules')) {
        await db.into(db.scenarioModules).insert(
              _procitajBackupRed(
                'scenarioModules',
                module,
                (row) => ScenarioModule.fromJson(row),
              ).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final definition in _optionalMapList(json, 'scenarioDefinitions')) {
        await db.into(db.scenarioDefinitions).insert(
              _procitajBackupRed(
                'scenarioDefinitions',
                definition,
                (row) => ScenarioDefinitionRecord.fromJson(row),
              ).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
    }

    for (final p in _requiredMapList(json, 'predmeti')) {
      final normalizedPredmet = _normalizujBackupPredmetMap(p);
      await db
          .into(db.predmeti)
          .insert(
            _procitajBackupRed(
              'predmeti',
              normalizedPredmet,
              (row) => PredmetiData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final reminder in reminderPayload.settings) {
      await db.customStatement(
        'INSERT INTO ceremony_reminder_settings '
        '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
        'updated_at) VALUES (?, ?, ?, ?, ?)',
        [
          reminder.predmetId,
          reminder.enabled ? 1 : 0,
          jsonEncode(reminder.deliveryTimes),
          '[]',
          DateTime.now().toIso8601String(),
        ],
      );
    }

    for (final i in _requiredMapList(json, 'iriu')) {
      final normalizedIriu = _normalizujBackupPrazanTekst(
        i,
        'iriu',
        _kIriuBlankTextFields,
      );
      _zahtevajBackupTekstPolja(normalizedIriu, 'iriu', const ['interniNaziv']);
      await db
          .into(db.iriu)
          .insert(
            _procitajBackupRed(
              'iriu',
              normalizedIriu,
              (row) => iriuDataFromCompatibleJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final k in _requiredMapList(json, 'kontaktLica')) {
      final normalizedKontakt = _normalizujBackupPrazanTekst(
        k,
        'kontaktLica',
        _kKontaktLicaBlankTextFields,
      );
      _zahtevajBackupTekstPolja(normalizedKontakt, 'kontaktLica', const [
        'blok',
      ]);
      await db
          .into(db.kontaktLica)
          .insert(
            _procitajBackupRed(
              'kontaktLica',
              normalizedKontakt,
              (row) => KontaktLicaData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final snapshot in _optionalMapList(json, 'predmetScenarioSnapshots')) {
      await db
          .into(db.predmetScenarioSnapshots)
          .insert(
            _procitajBackupRed(
              'predmetScenarioSnapshots',
              snapshot,
              (row) => PredmetScenarioSnapshot.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }
    for (final provenance in _optionalMapList(json, 'iriuProvenance')) {
      await db
          .into(db.iriuProvenance)
          .insert(
            _procitajBackupRed(
              'iriuProvenance',
              provenance,
              (row) => IriuProvenanceData.fromJson(row),
            ).toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    for (final d
        in (json['iriuLifecycleDecisions'] as List? ?? const [])
            .cast<Map<String, dynamic>>()) {
      await db.customStatement(
        '''
          INSERT OR REPLACE INTO iriu_lifecycle_decisions (
            id,
            predmet_id,
            interni_naziv,
            scope_key,
            decision_key,
            created_at
          ) VALUES (?, ?, ?, ?, ?, ?)
        ''',
        [
          d['id'],
          d['predmet_id'],
          d['interni_naziv'],
          d['scope_key'],
          d['decision_key'],
          d['created_at'],
        ],
      );
    }

    for (final l in _requiredMapList(json, 'logIzmena')) {
      final normalizedLog = _normalizujBackupPrazanTekst(
        l,
        'logIzmena',
        _kLogIzmenaBlankTextFields,
      );
      _zahtevajBackupTekstPolja(normalizedLog, 'logIzmena', const [
        'datumVreme',
        'polje',
      ]);
      final parsedLog = _procitajBackupRed(
        'logIzmena',
        normalizedLog,
        (row) => LogIzmenaData.fromJson(row),
      );
      if (!backupPredmetIds.contains(parsedLog.predmetId)) {
        skippedOrphanLogEntries++;
        continue;
      }
      await db
          .into(db.logIzmena)
          .insert(
            parsedLog.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }

    if (stockPayload.supported) {
      for (final s in stockPayload.stavke) {
        await db
            .into(db.stanjeRobeStavke)
            .insert(
              StanjeRobeStavkeData.fromJson(s).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final e in stockPayload.appliedEffects) {
        await db
            .into(db.stanjeRobeAppliedEffects)
            .insert(
              StanjeRobeAppliedEffect.fromJson(e).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final p in stockPayload.posledice) {
        await db
            .into(db.stanjeRobePosledice)
            .insert(
              StanjeRobePoslediceData.fromJson(p).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
    }

    for (final preparation in _optionalMapList(json, 'partePripreme')) {
      final parsed = _procitajBackupRed(
        'partePripreme',
        preparation,
        (row) => PartePripremeData.fromJson(row),
      );
      if (!backupPredmetIds.contains(parsed.predmetId)) continue;
      await db.into(db.partePripreme).insert(
            parsed.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
    }
    await db.deduplicateCituljeCatalogAndRemapReferences();
    await db.backfillMissingKatalogStableArticleIds();
    await db.canonicalizeSeedCatalogStableArticleIds();
    await AuthSecurityRepository(db).writeAuthAuditEvent(
      eventType: 'full_backup_restore',
      actorType: 'SYSTEM',
      result: 'SUCCESS',
      details: 'Full backup restored; installation security state preserved.',
      installContext: 'local_installation',
    );
  });
  return _BackupImportResult(
    stockPayload.supported
        ? _BackupImportStatus.stockCompleteRestored
        : _BackupImportStatus.nonStockImportedWithoutStockRestore,
    skippedOrphanReminderSettings: reminderPayload.skippedOrphans,
    skippedOrphanLogEntries: skippedOrphanLogEntries,
  );
}

_BackupReminderPayload _procitajBackupReminderSettings(
  Map<String, dynamic> json,
) {
  final schemaVersion = json['schemaVersion'];
  final raw = json['ceremonyReminderSettings'];
  if (raw == null && (schemaVersion is! int || schemaVersion < 8)) {
    return const _BackupReminderPayload(settings: [], skippedOrphans: 0);
  }
  if (raw is! List) {
    throw const _ImportBlokiranException(
      'Neispravan backup: nedostaje podrzana sekcija lokalnih podsetnika.',
    );
  }

  final predmetIds = _requiredMapList(
    json,
    'predmeti',
  ).map((row) => row['id']).whereType<int>().toSet();
  final seen = <int>{};
  final result = <_BackupReminderSetting>[];
  var skippedOrphans = 0;
  for (final item in raw) {
    if (item is! Map) {
      throw const _ImportBlokiranException(
        'Neispravan backup: sekcija lokalnih podsetnika ima nevazeci red.',
      );
    }
    final row = item.cast<String, dynamic>();
    final predmetId = row['predmetId'];
    final enabled = row['enabled'];
    final deliveryTimes = row['deliveryTimes'];
    if (predmetId is! int ||
        enabled is! bool ||
        deliveryTimes is! List ||
        deliveryTimes.any((value) => value is! String) ||
        !seen.add(predmetId) ||
        row.containsKey('scheduledNotificationIds')) {
      throw const _ImportBlokiranException(
        'Neispravan backup: sekcija lokalnih podsetnika nije bezbedna.',
      );
    }
    final normalized = CeremonyReminderConfig(
      enabled: enabled,
      deliveryTimes: deliveryTimes.cast<String>(),
    ).normalizedDeliveryTimes;
    if (!predmetIds.contains(predmetId)) {
      skippedOrphans++;
      continue;
    }
    result.add(
      _BackupReminderSetting(
        predmetId: predmetId,
        enabled: enabled,
        deliveryTimes: normalized,
      ),
    );
  }
  return _BackupReminderPayload(
    settings: result,
    skippedOrphans: skippedOrphans,
  );
}

Future<_BackupImportResult> _uvoziBackupSaLifecycleKoordinacijom({
  required AppDatabase db,
  required Map<String, dynamic> json,
  CeremonyNotificationGateway? notificationGateway,
  ParteMediaStore? mediaStore,
}) async {
  final outcome = await FullBackupRestoreCoordinator(
    db: db,
    notificationGateway:
        notificationGateway ?? AndroidCeremonyNotificationGateway(),
    mediaStore: mediaStore,
  ).restore(databaseRestore: () => _uvoziBackupUBazu(db, json));
  return _BackupImportResult(
    outcome.result.status,
    reminderSchedulingFailures: outcome.reminderSchedulingFailures,
    skippedOrphanReminderSettings: outcome.result.skippedOrphanReminderSettings,
    skippedOrphanLogEntries: outcome.result.skippedOrphanLogEntries,
  );
}

Future<_StockBackupPayload> _procitajStanjeRobeBackupPayload(
  AppDatabase db,
  Map<String, dynamic> json,
) async {
  final hasStockLikePayload = _backupImaStanjeRobePayload(json);
  final hasSupportedStockPayload = _backupImaPodrzanStanjeRobePrenos(json);

  if (hasStockLikePayload && !hasSupportedStockPayload) {
    throw const _ImportBlokiranException(
      'Uvoz kompletne rezervne kopije je blokiran jer kopija sadrzi '
      'STANJE ROBE podatke, ali nema podrzan stockBackupPolicy ili '
      'potpune podrzane STANJE ROBE sekcije. Lokalni podaci nisu promenjeni.',
    );
  }

  final postojiLokalnoStanjeRobe = await _postojiLokalnoStanjeRobe(db);
  if (!hasSupportedStockPayload) {
    if (postojiLokalnoStanjeRobe) {
      throw const _ImportBlokiranException(
        'Uvoz kompletne rezervne kopije je blokiran jer u lokalnoj bazi '
        'postoje podaci STANJA ROBE, a izabrana kopija nema podrzan prenos '
        'STANJA ROBE. Ovo sprecava mesanje starog lokalnog stanja robe sa '
        'uvezenim poslovnim podacima.',
      );
    }
    return const _StockBackupPayload(
      supported: false,
      stavke: [],
      appliedEffects: [],
      posledice: [],
    );
  }

  final payload = _procitajIPotvrdiStanjeRobeBackupPayload(json);
  _validirajStanjeRobePayload(
    payload,
    predmeti: _requiredMapList(json, 'predmeti'),
    iriu: _requiredMapList(json, 'iriu'),
  );
  return payload;
}

Future<bool> _postojiLokalnoStanjeRobe(AppDatabase db) async {
  final row = await db
      .customSelect(
        '''
      SELECT
        (
          EXISTS(SELECT 1 FROM stanje_robe_stavke LIMIT 1)
          OR EXISTS(SELECT 1 FROM stanje_robe_applied_effects LIMIT 1)
          OR EXISTS(SELECT 1 FROM stanje_robe_posledice LIMIT 1)
        )
        AS postoji_stanje_robe
    ''',
        readsFrom: {
          db.stanjeRobeStavke,
          db.stanjeRobeAppliedEffects,
          db.stanjeRobePosledice,
        },
      )
      .getSingle();

  final value = row.read<int>('postoji_stanje_robe');
  return value != 0;
}

bool _backupImaPodrzanStanjeRobePrenos(Map<String, dynamic> json) {
  return json['stockBackupPolicy'] == _kStockBackupPolicySchema16Complete &&
      json['stanjeRobeStavke'] is List &&
      json['stanjeRobeAppliedEffects'] is List &&
      json['stanjeRobePosledice'] is List;
}

bool _backupImaStanjeRobePayload(Map<String, dynamic> json) {
  return json.containsKey('stockBackupPolicy') ||
      json.containsKey('stanjeRobeStavke') ||
      json.containsKey('stanjeRobeAppliedEffects') ||
      json.containsKey('stanjeRobePosledice');
}

_StockBackupPayload _procitajIPotvrdiStanjeRobeBackupPayload(
  Map<String, dynamic> json,
) {
  return _StockBackupPayload(
    supported: true,
    stavke: _requiredMapList(json, 'stanjeRobeStavke'),
    appliedEffects: _requiredMapList(json, 'stanjeRobeAppliedEffects'),
    posledice: _requiredMapList(json, 'stanjeRobePosledice'),
  );
}

List<Map<String, dynamic>> _requiredMapList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw _ImportBlokiranException(
      'Uvoz je blokiran jer backup sekcija $key nije lista.',
    );
  }
  return value
      .map((item) {
        if (item is! Map) {
          throw _ImportBlokiranException(
            'Uvoz je blokiran jer backup sekcija $key sadrzi neispravan red.',
          );
        }
        return item.cast<String, dynamic>();
      })
      .toList(growable: false);
}

List<Map<String, dynamic>> _optionalMapList(
  Map<String, dynamic> json,
  String key,
) {
  if (!json.containsKey(key)) return const <Map<String, dynamic>>[];
  return _requiredMapList(json, key);
}

void _validirajStanjeRobePayload(
  _StockBackupPayload payload, {
  required List<Map<String, dynamic>> predmeti,
  required List<Map<String, dynamic>> iriu,
}) {
  final predmetIds = <int>{};
  for (final p in predmeti) {
    predmetIds.add(_requiredInt(p, 'id', 'predmeti'));
  }

  final iriuPredmetIds = <int, int>{};
  for (final i in iriu) {
    final id = _requiredInt(i, 'id', 'iriu');
    final predmetId = _requiredInt(i, 'predmetId', 'iriu');
    iriuPredmetIds[id] = predmetId;
  }

  final stableArticleIds = <String>{};
  for (final row in payload.stavke) {
    _requiredInt(row, 'id', 'stanjeRobeStavke');
    final stableArticleId = _requiredNonEmptyString(
      row,
      'stableArticleId',
      'stanjeRobeStavke',
    );
    if (!stableArticleIds.add(stableArticleId)) {
      throw _ImportBlokiranException(
        'Uvoz je blokiran jer backup ima dupliran stableArticleId '
        'u STANJU ROBE: $stableArticleId.',
      );
    }
    _requiredFiniteNumber(row, 'trenutnaKolicina', 'stanjeRobeStavke');
    _requiredFiniteNumber(row, 'minimalnaKolicina', 'stanjeRobeStavke');
    _requiredBool(row, 'aktivna', 'stanjeRobeStavke');
    _requiredString(row, 'datumKreiranja', 'stanjeRobeStavke');
    _requiredString(row, 'datumAzuriranja', 'stanjeRobeStavke');
  }

  final currentEffectKeys = <String>{};
  for (final row in payload.appliedEffects) {
    _requiredInt(row, 'id', 'stanjeRobeAppliedEffects');
    final predmetId = _requiredInt(
      row,
      'predmetId',
      'stanjeRobeAppliedEffects',
    );
    if (!predmetIds.contains(predmetId)) {
      throw const _ImportBlokiranException(
        'Uvoz je blokiran jer applied effect referencira nepostojeci PREDMET.',
      );
    }

    final iriuId = _optionalInt(row, 'iriuId', 'stanjeRobeAppliedEffects');
    if (iriuId != null) {
      final iriuPredmetId = iriuPredmetIds[iriuId];
      if (iriuPredmetId == null || iriuPredmetId != predmetId) {
        throw const _ImportBlokiranException(
          'Uvoz je blokiran jer applied effect referencira nepostojeci '
          'ili pogresan IRIU red.',
        );
      }
    }

    final kategorija = _requiredNonEmptyString(
      row,
      'kategorija',
      'stanjeRobeAppliedEffects',
    );
    _requiredNonEmptyString(row, 'stableArticleId', 'stanjeRobeAppliedEffects');
    _requiredFiniteNumber(row, 'effectQuantity', 'stanjeRobeAppliedEffects');
    final status = _requiredNonEmptyString(
      row,
      'effectStatus',
      'stanjeRobeAppliedEffects',
    );
    if (!_kKnownStanjeRobeEffectStatuses.contains(status)) {
      throw _ImportBlokiranException(
        'Uvoz je blokiran jer applied effect ima nepoznat status: $status.',
      );
    }
    _requiredString(row, 'effectReason', 'stanjeRobeAppliedEffects');
    _requiredString(row, 'datumKreiranja', 'stanjeRobeAppliedEffects');
    _requiredString(row, 'datumAzuriranja', 'stanjeRobeAppliedEffects');

    if (status == 'APPLIED' || status == 'UNRESOLVED') {
      final currentKey = '$predmetId|${iriuId ?? ''}|$kategorija';
      if (!currentEffectKeys.add(currentKey)) {
        throw const _ImportBlokiranException(
          'Uvoz je blokiran jer backup ima dupliran current applied effect.',
        );
      }
    }
  }

  final activeConsequenceKeys = <String>{};
  for (final row in payload.posledice) {
    _requiredInt(row, 'id', 'stanjeRobePosledice');
    final predmetId = _requiredInt(row, 'predmetId', 'stanjeRobePosledice');
    if (!predmetIds.contains(predmetId)) {
      throw const _ImportBlokiranException(
        'Uvoz je blokiran jer posledica referencira nepostojeci PREDMET.',
      );
    }

    final iriuId = _requiredInt(row, 'iriuId', 'stanjeRobePosledice');
    final iriuPredmetId = iriuPredmetIds[iriuId];
    if (iriuPredmetId == null || iriuPredmetId != predmetId) {
      throw const _ImportBlokiranException(
        'Uvoz je blokiran jer posledica referencira nepostojeci '
        'ili pogresan IRIU red.',
      );
    }

    final kategorija = _requiredNonEmptyString(
      row,
      'kategorija',
      'stanjeRobePosledice',
    );
    _requiredNonEmptyString(
      row,
      'katalogStableArticleId',
      'stanjeRobePosledice',
    );
    _requiredString(row, 'selectedNazivSnapshot', 'stanjeRobePosledice');
    _requiredFiniteNumber(row, 'selectedIznosSnapshot', 'stanjeRobePosledice');
    _requiredString(row, 'consequenceType', 'stanjeRobePosledice');
    final status = _requiredNonEmptyString(
      row,
      'status',
      'stanjeRobePosledice',
    );
    if (!_kKnownStanjeRobePoslediceStatuses.contains(status)) {
      throw _ImportBlokiranException(
        'Uvoz je blokiran jer posledica ima nepoznat status: $status.',
      );
    }
    _requiredString(row, 'createdAt', 'stanjeRobePosledice');
    _requiredString(row, 'updatedAt', 'stanjeRobePosledice');
    _optionalString(row, 'resolvedAt', 'stanjeRobePosledice');
    _optionalString(row, 'resolvedReason', 'stanjeRobePosledice');
    _requiredString(row, 'sourceLifecycleEvent', 'stanjeRobePosledice');
    _requiredFiniteNumber(row, 'effectQuantity', 'stanjeRobePosledice');
    _optionalFiniteNumber(
      row,
      'availableQuantityAtCreation',
      'stanjeRobePosledice',
    );
    _optionalFiniteNumber(
      row,
      'shortageQuantityAtCreation',
      'stanjeRobePosledice',
    );

    if (status == 'UNRESOLVED') {
      final activeKey = '$predmetId|$iriuId|$kategorija';
      if (!activeConsequenceKeys.add(activeKey)) {
        throw const _ImportBlokiranException(
          'Uvoz je blokiran jer backup ima dupliranu aktivnu posledicu.',
        );
      }
    }
  }
}

int _requiredInt(Map<String, dynamic> row, String key, String section) {
  final value = row[key];
  if (value is int) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije ceo broj.',
  );
}

int? _optionalInt(Map<String, dynamic> row, String key, String section) {
  final value = row[key];
  if (value == null) return null;
  if (value is int) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije ceo broj.',
  );
}

String _requiredString(Map<String, dynamic> row, String key, String section) {
  final value = row[key];
  if (value is String) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije tekst.',
  );
}

String _requiredNonEmptyString(
  Map<String, dynamic> row,
  String key,
  String section,
) {
  final value = _requiredString(row, key, section).trim();
  if (value.isNotEmpty) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key ne sme biti prazan.',
  );
}

String? _optionalString(Map<String, dynamic> row, String key, String section) {
  final value = row[key];
  if (value == null) return null;
  if (value is String) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije tekst.',
  );
}

String? _optionalTrimmedNonEmptyString(
  Map<String, dynamic> row,
  String key,
  String section,
) {
  final value = _optionalString(row, key, section)?.trim();
  return value == null || value.isEmpty ? null : value;
}

bool _requiredBool(Map<String, dynamic> row, String key, String section) {
  final value = row[key];
  if (value is bool) return value;
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije bool vrednost.',
  );
}

double _requiredFiniteNumber(
  Map<String, dynamic> row,
  String key,
  String section,
) {
  final value = row[key];
  if (value is num && value.isFinite) return value.toDouble();
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije validan broj.',
  );
}

double? _optionalFiniteNumber(
  Map<String, dynamic> row,
  String key,
  String section,
) {
  final value = row[key];
  if (value == null) return null;
  if (value is num && value.isFinite) return value.toDouble();
  throw _ImportBlokiranException(
    'Uvoz je blokiran jer $section.$key nije validan broj.',
  );
}

// I/O HELPERS

void _prikaziSnackBar(BuildContext ctx, String poruka, {bool greska = false}) {
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(poruka),
      duration: const Duration(seconds: 5),
      backgroundColor: greska ? Theme.of(ctx).colorScheme.error : Colors.green,
    ),
  );
}

Future<void> _sacuvajFajl(String jsonStr, String naziv) async {
  final dir = await getKoriceDir();
  final fajl = File('${dir.path}${Platform.pathSeparator}$naziv');
  await fajl.writeAsString(jsonStr, encoding: utf8);
}

Future<String> _privremeniJsonFajl(String jsonStr, String naziv) async {
  final dir = await getApplicationDocumentsDirectory();
  final fajl = File('${dir.path}${Platform.pathSeparator}$naziv');
  await fajl.writeAsString(jsonStr, encoding: utf8, flush: true);
  return fajl.path;
}

Future<Map<String, dynamic>> _dekodirajJsonMapuIzStringa(String jsonStr) async {
  return documentTextCodec.normalizeValue(jsonDecode(jsonStr))
      as Map<String, dynamic>;
}

Map<String, dynamic> _normalizujPredmetJsonZaImport(
  Map<String, dynamic> predmetMap,
  Map<String, dynamic> rootJson,
) {
  final normalized = Map<String, dynamic>.from(predmetMap);
  final exportVerzija = rootJson['exportVerzija'];
  if (exportVerzija is int) {
    normalized['exportVerzija'] = exportVerzija;
  } else {
    normalized.putIfAbsent('exportVerzija', () => 0);
  }
  normalized.putIfAbsent(
    'businessScenarioId',
    () => _kDefaultBusinessScenarioId,
  );
  normalized.putIfAbsent('sourceIdentity', () => _kDefaultSourceIdentity);
  normalized.putIfAbsent('createdByKorisnikId', () => null);
  normalized.putIfAbsent('lastBusinessModifiedByKorisnikId', () => null);
  normalized.putIfAbsent('lastBusinessModifiedAt', () => null);
  normalized.putIfAbsent('docekDatum', () => '');
  normalized.putIfAbsent('grobljePolaganjaUrne', () => '');
  normalized.putIfAbsent('promenaSanduka', () => false);
  return documentTextCodec.normalizeMap(normalized);
}

void _zahtevajPodrzanuJsonSchemaVerziju(Map<String, dynamic> json) {
  final schemaVersion = json['schemaVersion'];
  final maxSupported = json['format'] == _kBackupTransferFormat
      ? _kMaxSupportedBackupSchemaVersion
      : _kMaxSupportedPredmetSchemaVersion;
  if (schemaVersion is! int || schemaVersion <= maxSupported) {
    return;
  }

  throw const _ImportBlokiranException(
    'JSON je napravljen u novijoj verziji OPC aplikacije i ne moze se '
    'bezbedno uvesti u ovu verziju aplikacije.',
  );
}

_PredmetTransferPayload _procitajPredmetTransferPayload(
  Map<String, dynamic> json,
) {
  _zahtevajPodrzanuJsonSchemaVerziju(json);

  final predmetMap = _normalizujPredmetJsonZaImport(
    (json['predmet'] as Map).cast<String, dynamic>(),
    json,
  );
  final iriuList = ((json['iriu'] as List?) ?? const <dynamic>[])
      .map(
        (item) =>
            iriuDataFromCompatibleJson((item as Map).cast<String, dynamic>()),
      )
      .toList(growable: false);
  final klList = ((json['kontaktLica'] as List?) ?? const <dynamic>[])
      .map(
        (item) =>
            KontaktLicaData.fromJson((item as Map).cast<String, dynamic>()),
      )
      .toList(growable: false);
  final stanjeRobeConsequences = _procitajStanjeRobeConsequenceTransferItems(
    json,
    iriuList,
  );
  final rawScenarioCarrier = json[_kSinglePredmetScenarioCarrierBlock];
  final scenarioCarrier = rawScenarioCarrier == null
      ? null
      : SinglePredmetScenarioCarrierBlock.fromJsonMap(
          (rawScenarioCarrier as Map).cast<String, dynamic>(),
        );
  return _PredmetTransferPayload(
    predmet: PredmetiData.fromJson(predmetMap),
    iriu: iriuList,
    kontaktLica: klList,
    stanjeRobeConsequences: stanjeRobeConsequences,
    scenarioCarrier: scenarioCarrier,
  );
}

List<_StanjeRobeConsequenceTransferItem>
_procitajStanjeRobeConsequenceTransferItems(
  Map<String, dynamic> json,
  List<IriuData> iriuList,
) {
  final rawBlock = json[_kStanjeRobeConsequenceTransferBlock];
  if (rawBlock == null) return const [];
  if (rawBlock is! Map) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer STANJE ROBE consequence transfer nije validan blok.',
    );
  }

  final block = rawBlock.cast<String, dynamic>();
  final schemaVersion = _requiredInt(
    block,
    'schemaVersion',
    _kStanjeRobeConsequenceTransferBlock,
  );
  if (schemaVersion > _kStanjeRobeConsequenceTransferSchemaVersion) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer STANJE ROBE consequence transfer ima noviju nepodrzanu semu.',
    );
  }
  if (schemaVersion != _kStanjeRobeConsequenceTransferSchemaVersion) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer STANJE ROBE consequence transfer ima nepoznatu semu.',
    );
  }

  final policy = _requiredNonEmptyString(
    block,
    'policy',
    _kStanjeRobeConsequenceTransferBlock,
  );
  if (policy != _kStanjeRobeConsequenceTransferPolicy) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer STANJE ROBE consequence transfer ima nepodrzanu politiku.',
    );
  }

  final rawItems = block['items'];
  if (rawItems is! List) {
    throw const _ImportBlokiranException(
      'Uvoz je blokiran jer STANJE ROBE consequence transfer nema validnu listu stavki.',
    );
  }

  return rawItems
      .map((rawItem) {
        if (rawItem is! Map) {
          throw const _ImportBlokiranException(
            'Uvoz je blokiran jer STANJE ROBE consequence transfer stavka nije validna.',
          );
        }
        final itemMap = rawItem.cast<String, dynamic>();
        _rejectForbiddenStanjeRobeConsequenceFields(itemMap);

        final iriuTransferIndex = _requiredInt(
          itemMap,
          'iriuTransferIndex',
          _kStanjeRobeConsequenceTransferBlock,
        );
        if (iriuTransferIndex < 0 || iriuTransferIndex >= iriuList.length) {
          throw const _ImportBlokiranException(
            'Uvoz je blokiran jer STANJE ROBE posledica pokazuje na nepostojeci IRIU red.',
          );
        }

        final kategorija = _requiredNonEmptyString(
          itemMap,
          'kategorija',
          _kStanjeRobeConsequenceTransferBlock,
        );
        if (!_kStanjeRobeConsequenceTransferCoveredCategories.contains(
          kategorija,
        )) {
          throw const _ImportBlokiranException(
            'Uvoz je blokiran jer STANJE ROBE posledica nije za podrzanu kategoriju.',
          );
        }

        final item = _StanjeRobeConsequenceTransferItem(
          iriuTransferIndex: iriuTransferIndex,
          kategorija: kategorija,
          katalogStableArticleId: _requiredNonEmptyString(
            itemMap,
            'katalogStableArticleId',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          selectedNazivSnapshot: _requiredNonEmptyString(
            itemMap,
            'selectedNazivSnapshot',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          selectedIznosSnapshot:
              _optionalFiniteNumber(
                itemMap,
                'selectedIznosSnapshot',
                _kStanjeRobeConsequenceTransferBlock,
              ) ??
              0.0,
          consequenceType: _requiredNonEmptyString(
            itemMap,
            'consequenceType',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          status: _requiredNonEmptyString(
            itemMap,
            'status',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          effectQuantity: _requiredFiniteNumber(
            itemMap,
            'effectQuantity',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          sourceLifecycleEvent: _optionalTrimmedNonEmptyString(
            itemMap,
            'sourceLifecycleEvent',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          createdAt: _optionalTrimmedNonEmptyString(
            itemMap,
            'createdAt',
            _kStanjeRobeConsequenceTransferBlock,
          ),
          updatedAt: _optionalTrimmedNonEmptyString(
            itemMap,
            'updatedAt',
            _kStanjeRobeConsequenceTransferBlock,
          ),
        );

        if (item.consequenceType != stanjeRobePosledicaTypeInsufficientStock ||
            item.status != stanjeRobePosledicaStatusUnresolved ||
            item.effectQuantity != 1.0) {
          throw const _ImportBlokiranException(
            'Uvoz je blokiran jer STANJE ROBE posledica nije aktivna insufficient-stock posledica jedinicne kolicine.',
          );
        }

        _validateStanjeRobeConsequenceAgainstIriu(
          item: item,
          iriuRow: iriuList[iriuTransferIndex],
          section: _kStanjeRobeConsequenceTransferBlock,
        );
        return item;
      })
      .toList(growable: false);
}

void _rejectForbiddenStanjeRobeConsequenceFields(Map<String, dynamic> itemMap) {
  for (final field in _kStanjeRobeConsequenceTransferForbiddenItemFields) {
    if (itemMap.containsKey(field)) {
      throw _ImportBlokiranException(
        'Uvoz je blokiran jer STANJE ROBE consequence transfer sadrzi zabranjeno polje: $field.',
      );
    }
  }
}

void _validateStanjeRobeConsequenceAgainstIriu({
  required _StanjeRobeConsequenceTransferItem item,
  required IriuData iriuRow,
  required String section,
}) {
  if (iriuRow.interniNaziv != item.kategorija) {
    throw _ImportBlokiranException(
      'Uvoz je blokiran jer $section kategorija ne odgovara IRIU redu.',
    );
  }
  if (_normalizeNullableStableArticleId(iriuRow.katalogStableArticleId) !=
      item.katalogStableArticleId.trim()) {
    throw _ImportBlokiranException(
      'Uvoz je blokiran jer $section katalogStableArticleId ne odgovara IRIU redu.',
    );
  }
}

String? _normalizeNullableStableArticleId(String? stableArticleId) {
  final normalized = stableArticleId?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String _formatMetadataValue(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? '—' : text;
}

Widget _buildConflictField(String label, Object? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(_formatMetadataValue(value), softWrap: true),
        ),
      ],
    ),
  );
}

Widget _buildConflictSection(String title, PredmetiData predmet) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      _buildConflictField(
        'PREMINULO LICE',
        '${predmet.prezime} ${predmet.ime}'.trim(),
      ),
      _buildConflictField('brojPredmeta', predmet.brojPredmeta),
      _buildConflictField('verzija', predmet.verzija),
      _buildConflictField('exportVerzija', predmet.exportVerzija),
      _buildConflictField(
        'lastBusinessModifiedByKorisnikId',
        predmet.lastBusinessModifiedByKorisnikId,
      ),
      _buildConflictField(
        'lastBusinessModifiedAt',
        predmet.lastBusinessModifiedAt,
      ),
      _buildConflictField('businessScenarioId', predmet.businessScenarioId),
      _buildConflictField('sourceIdentity', predmet.sourceIdentity),
      _buildConflictField('datumKreiranja', predmet.datumKreiranja),
      _buildConflictField('savetnikId', predmet.savetnikId),
    ],
  );
}

Future<_PredmetConflictChoice?> _prikaziPredmetConflictDialog({
  required BuildContext ctx,
  required PredmetiData lokalni,
  required PredmetiData uvozni,
}) {
  final media = MediaQuery.of(ctx);
  final narrowAndroid =
      Theme.of(ctx).platform == TargetPlatform.android &&
      media.size.width < 600;
  return showDialog<_PredmetConflictChoice>(
    context: ctx,
    builder: (dlgCtx) => AlertDialog(
      insetPadding: narrowAndroid
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      scrollable: narrowAndroid,
      title: const Text('Konflikt pri uvozu PREDMETA'),
      content: SizedBox(
        width: narrowAndroid ? double.maxFinite : 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PREDMET sa brojem ${uvozni.brojPredmeta} već postoji lokalno. '
                'Izaberite da li želite da zadržite lokalni PREDMET, zamenite ga uvoznim ili odustanete od uvoza.',
              ),
              const SizedBox(height: 16),
              _buildConflictSection('Lokalni PREDMET', lokalni),
              const Divider(height: 24),
              _buildConflictSection('Uvozni PREDMET', uvozni),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dlgCtx, _PredmetConflictChoice.cancel),
          child: const Text('Odustani'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(dlgCtx, _PredmetConflictChoice.keepLocal),
          child: const Text('Zadrži lokalni'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dlgCtx, _PredmetConflictChoice.replaceImported),
          child: const Text('Zameni uvoznim'),
        ),
      ],
    ),
  );
}

Future<Map<String, dynamic>?> _ucitajJsonMapuIzRezultata(
  FilePickerResult result, {
  required bool preferDiskPath,
}) async {
  if (result.files.isEmpty) return null;

  final file = result.files.first;

  if (preferDiskPath) {
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      final jsonStr = await File(path).readAsString(encoding: utf8);
      return _dekodirajJsonMapuIzStringa(jsonStr);
    }
  }

  final bytes = file.bytes;
  if (bytes != null) {
    final jsonStr = utf8.decode(bytes);
    return _dekodirajJsonMapuIzStringa(jsonStr);
  }

  final path = file.path;
  if (path != null && path.isNotEmpty) {
    final jsonStr = await File(path).readAsString(encoding: utf8);
    return _dekodirajJsonMapuIzStringa(jsonStr);
  }

  throw const FileSystemException(
    'Izabrani JSON fajl nije dostupan za \u010Ditanje.',
  );
}

void _prikaziSnackBarSaAkcijom(
  BuildContext ctx,
  String poruka, {
  required String actionLabel,
  required Future<void> Function() onAction,
  bool greska = false,
}) {
  if (!ctx.mounted) return;
  final messenger = ScaffoldMessenger.of(ctx);
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(poruka),
      duration: const Duration(seconds: 5),
      backgroundColor: greska ? Theme.of(ctx).colorScheme.error : Colors.green,
      action: SnackBarAction(
        label: actionLabel,
        textColor: Colors.white,
        onPressed: () async {
          try {
            await onAction();
          } catch (e) {
            if (!ctx.mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text('Greska pri deljenju fajla: $e'),
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
            );
          }
        },
      ),
    ),
  );
  Future<void>.delayed(const Duration(seconds: 5), controller.close);
}

Future<Map<String, dynamic>?> _izaberiJsonMapu({
  bool preferDiskPath = false,
}) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: !preferDiskPath,
  );
  if (result == null || result.files.isEmpty) return null;
  return _ucitajJsonMapuIzRezultata(result, preferDiskPath: preferDiskPath);
}

// PUBLIC API

@visibleForTesting
Future<String> serializePredmetJsonForTest({
  required AppDatabase db,
  required int predmetId,
}) async {
  final predmet = await (db.select(
    db.predmeti,
  )..where((r) => r.id.equals(predmetId))).getSingle();
  final iriuList = await (db.select(
    db.iriu,
  )..where((i) => i.predmetId.equals(predmetId))).get();
  final klList = await (db.select(
    db.kontaktLica,
  )..where((k) => k.predmetId.equals(predmetId))).get();
  final stanjeRobePosledice = await StanjeRobePoslediceRepository(
    db,
  ).listActiveUnresolvedForPredmet(predmetId);

  return _serijalizujPredmet(
    predmet,
    iriuList,
    klList,
    stanjeRobePosledice,
    scenarioCarrier: await _scenarioCarrierForExport(
      db: db,
      predmetId: predmetId,
      iriu: iriuList,
    ),
  );
}

@visibleForTesting
Future<void> importPredmetJsonMapForTest({
  required AppDatabase db,
  required Map<String, dynamic> json,
  int? replaceLocalPredmetId,
}) {
  if (replaceLocalPredmetId != null) {
    return _zameniPredmetUBazi(
      db: db,
      lokalniPredmetId: replaceLocalPredmetId,
      json: json,
    );
  }
  return _uvoziPredmetUBazu(db, json);
}

@visibleForTesting
Future<String> serializeBackupJsonForTest({required AppDatabase db}) {
  return _serijalizujBackup(db);
}

@visibleForTesting
Future<String?> importBackupJsonMapForTest({
  required AppDatabase db,
  required Map<String, dynamic> json,
  CeremonyNotificationGateway? notificationGateway,
  ParteMediaStore? mediaStore,
  bool coordinateExternalState = false,
}) async {
  _zahtevajPodrzanuJsonSchemaVerziju(json);
  if (coordinateExternalState) {
    final result = await _uvoziBackupSaLifecycleKoordinacijom(
      db: db,
      json: json,
      notificationGateway: notificationGateway,
      mediaStore: mediaStore,
    );
    return result.message;
  }
  await _uvoziBackupUBazu(db, json);
  return null;
}

/// Legacy entrypoint za izvoz jednog PREDMETA kao JSON transfera.
///
/// UI trenutno i dalje koristi naziv "BELE\u017dNICA", ali format i identitet
/// izvoza pripadaju jednom PREDMETU i njegovim povezanim podacima.
Future<void> izvoziBeleznica({
  required BuildContext ctx,
  required AppDatabase db,
  required int predmetId,
}) async {
  try {
    final p = await (db.select(
      db.predmeti,
    )..where((r) => r.id.equals(predmetId))).getSingle();
    final novaVerzija = p.exportVerzija + 1;
    await (db.update(db.predmeti)..where((r) => r.id.equals(predmetId))).write(
      PredmetiCompanion(exportVerzija: Value(novaVerzija)),
    );

    final pFresh = await (db.select(
      db.predmeti,
    )..where((r) => r.id.equals(predmetId))).getSingle();
    final iriuList = await (db.select(
      db.iriu,
    )..where((i) => i.predmetId.equals(predmetId))).get();
    final klList = await (db.select(
      db.kontaktLica,
    )..where((k) => k.predmetId.equals(predmetId))).get();
    final stanjeRobePosledice = await StanjeRobePoslediceRepository(
      db,
    ).listActiveUnresolvedForPredmet(predmetId);

    final jsonStr = await _serijalizujPredmet(
      pFresh,
      iriuList,
      klList,
      stanjeRobePosledice,
      scenarioCarrier: await _scenarioCarrierForExport(
        db: db,
        predmetId: predmetId,
        iriu: iriuList,
      ),
    );
    final naziv = predmetFajlNaziv(pFresh);

    if (Platform.isAndroid) {
      final fajl = await sacuvajKoriceDokumentFajlDetalji(
        naziv,
        Uint8List.fromList(utf8.encode(jsonStr)),
        mimeType: 'application/json',
      );
      if (!ctx.mounted) return;
      _prikaziSnackBarSaAkcijom(
        ctx,
        'Izvezeno: ${koriceFajlLokacija(fajl)}',
        actionLabel: 'PODELI',
        onAction: () async {
          final path = await _privremeniJsonFajl(jsonStr, naziv);
          if (!ctx.mounted) return;
          await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
        },
      );
    } else {
      await _sacuvajFajl(jsonStr, naziv);
      if (!ctx.mounted) return;
      _prikaziSnackBar(ctx, 'Izvezeno: KORICE/$naziv');
    }
  } catch (e) {
    if (!ctx.mounted) return;
    _prikaziSnackBar(ctx, 'Gre\u0161ka pri izvozu: $e', greska: true);
  }
}

Future<void> izvoziPredmetJson({
  required BuildContext ctx,
  required AppDatabase db,
  required int predmetId,
}) async {
  await izvoziBeleznica(ctx: ctx, db: db, predmetId: predmetId);
}

/// Format 2 - izvoz cele baze.
Future<void> izvoziBackup({
  required BuildContext ctx,
  required AppDatabase db,
}) async {
  try {
    final jsonStr = await _serijalizujBackup(db);
    final naziv = backupFajlNaziv();

    if (Platform.isAndroid) {
      final fajl = await sacuvajKoriceDokumentFajlDetalji(
        naziv,
        Uint8List.fromList(utf8.encode(jsonStr)),
        mimeType: 'application/json',
      );
      if (!ctx.mounted) return;
      _prikaziSnackBar(ctx, 'Backup sa\u010Duvan: ${koriceFajlLokacija(fajl)}');
    } else {
      await _sacuvajFajl(jsonStr, naziv);
      if (!ctx.mounted) return;
      _prikaziSnackBar(ctx, 'Backup sa\u010Duvan: KORICE/$naziv');
    }
  } catch (e) {
    if (!ctx.mounted) return;
    _prikaziSnackBar(ctx, 'Gre\u0161ka pri backupu: $e', greska: true);
  }
}

/// Uvoz iz JSON fajla - detektuje format automatski
/// (OPC_PREDMET, legacy OPC_BELEZNICA ili OPC_BACKUP).
Future<void> uveziPredmetIzJson({
  required BuildContext ctx,
  required AppDatabase db,
}) async {
  await uvoziIzFajla(ctx: ctx, db: db, allowBackupImport: false);
}

Future<void> uvoziIzFajla({
  required BuildContext ctx,
  required AppDatabase db,
  bool allowBackupImport = true,
}) async {
  try {
    final json = await _izaberiJsonMapu(preferDiskPath: Platform.isAndroid);
    if (json == null) return;
    final format = json['format'] as String?;

    if (format == _kPredmetTransferFormat ||
        format == _kLegacyBeleznicaTransferFormat) {
      final payload = _procitajPredmetTransferPayload(json);
      final uvozniPredmet = payload.predmet;
      final brojPredmeta = uvozniPredmet.brojPredmeta.trim();

      if (brojPredmeta.isNotEmpty) {
        final existing = await (db.select(
          db.predmeti,
        )..where((t) => t.brojPredmeta.equals(brojPredmeta))).get();

        if (existing.isNotEmpty) {
          if (existing.length > 1) {
            if (!ctx.mounted) return;
            _prikaziSnackBar(
              ctx,
              'Postoji više lokalnih PREDMETA sa istim brojem predmeta. '
              'Uvoz je zaustavljen jer zamena nije bezbedna.',
              greska: true,
            );
            return;
          }
          final existingP = existing.first;
          if (!ctx.mounted) return;
          final izbor = await _prikaziPredmetConflictDialog(
            ctx: ctx,
            lokalni: existingP,
            uvozni: uvozniPredmet,
          );
          if (izbor == _PredmetConflictChoice.cancel || izbor == null) return;
          if (izbor == _PredmetConflictChoice.keepLocal) {
            if (!ctx.mounted) return;
            _prikaziSnackBar(ctx, 'Zadržan je lokalni PREDMET.');
            return;
          }

          await _zameniPredmetUBazi(
            db: db,
            lokalniPredmetId: existingP.id,
            json: json,
          );
          if (!ctx.mounted) return;
          _prikaziSnackBar(
            ctx,
            'PREDMET je uspešno zamenjen uvoznim podacima.',
          );
          return;
        }
      }

      await _uvoziPredmetUBazu(db, json);
      if (!ctx.mounted) return;
      _prikaziSnackBar(ctx, 'PREDMET uspešno uvezen kao novi lokalni predmet.');
    } else if (format == _kBackupTransferFormat && allowBackupImport) {
      _zahtevajPodrzanuJsonSchemaVerziju(json);

      if (!ctx.mounted) return;
      final potvrda = await showDialog<bool>(
        context: ctx,
        builder: (dlgCtx) => AlertDialog(
          title: const Text('Uvoz cele baze'),
          content: const Text(
            'Ovo \u0107e ZAMENITI sve postoje\u0107e podatke podacima iz fajla.\n\n'
            'Ova akcija je nepovratna. Da li ste sigurni?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx, false),
              child: const Text('ODUSTANI'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dlgCtx).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dlgCtx, true),
              child: const Text('ZAMENI SVE'),
            ),
          ],
        ),
      );
      if (potvrda != true) return;
      final importResult = await _uvoziBackupSaLifecycleKoordinacijom(
        db: db,
        json: json,
      );
      if (!ctx.mounted) return;
      _prikaziSnackBar(ctx, importResult.message);
    } else {
      if (!ctx.mounted) return;
      _prikaziSnackBar(
        ctx,
        allowBackupImport
            ? 'Nepoznat format JSON fajla.'
            : 'Izabrani fajl nije JSON jednog predmeta.',
        greska: true,
      );
    }
  } catch (e) {
    if (!ctx.mounted) return;
    _prikaziSnackBar(ctx, 'Gre\u0161ka pri uvozu: $e', greska: true);
  }
}
