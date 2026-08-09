import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

const _goldenPath = 'test/fixtures/scenario/scenario_map_owner_golden.json';
const _canonicalCopy =
    r'C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\opc_v4_release_copy.sqlite';

void main() {
  late List<Map<String, dynamic>> goldenScenarios;

  setUpAll(() {
    final document =
        jsonDecode(File(_goldenPath).readAsStringSync())
            as Map<String, dynamic>;
    goldenScenarios = (document['scenarios'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(goldenScenarios, hasLength(1008));
  });

  test(
    'current production path reconciles all 1008 scenarios end-to-end',
    skip: Platform.environment['OPC_RUN_FORENSIC_E2E'] == '1'
        ? null
        : 'Run explicitly with OPC_RUN_FORENSIC_E2E=1; this is a long forensic gate.',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final summary = await _runGate(db, goldenScenarios, label: 'CURRENT');
      expect(summary.mismatches, isEmpty, reason: summary.diagnostics);
      expect(summary.scenarioCount, 1008);
      expect(summary.protectiveEquipmentByCause, <String, int>{
        'PRIRODNA': 0,
        'NASILNA': 216,
        'ZARAZNA': 216,
        'NEDEFINISANA': 216,
      });
    },
  );

  test(
    'canonical user DB copy reconciles all 1008 scenarios end-to-end',
    skip: Platform.environment['OPC_RUN_FORENSIC_E2E'] == '1'
        ? null
        : 'Run explicitly with OPC_RUN_FORENSIC_E2E=1; this is a long forensic gate.',
    () async {
      final file = File(_canonicalCopy);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Forensic copy is missing: $_canonicalCopy',
      );
      final before = (await file.readAsBytes()).length;
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      final summary = await db.transaction(
        () => _runGate(db, goldenScenarios, label: 'CANONICAL_COPY'),
      );
      expect(summary.mismatches, isEmpty, reason: summary.diagnostics);
      expect(summary.scenarioCount, 1008);
      expect(before, greaterThan(0));
      expect(summary.preservedEditedDefinition, isTrue);
    },
  );
}

Future<_GateSummary> _runGate(
  AppDatabase db,
  List<Map<String, dynamic>> scenarios, {
  required String label,
}) async {
  final predmeti = PredmetiRepository(db);
  final scenarioRepository = ScenarioModuleRepository(db);
  final iriu = IriuRepository(db);
  final module = await scenarioRepository.ensureModuleAndDefaults();
  final active = await scenarioRepository.getActiveDefinitions();
  expect(active, hasLength(1008));
  final activeById = {for (final record in active) record.id: record};
  final editedReferenceId = label == 'CANONICAL_COPY'
      ? scenarios.cast<Map<String, dynamic>>().firstWhere((expected) {
              final definition = activeById[expected['stableId'] as String]!;
              final expectedIds = (expected['items'] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map((item) => item['stableId'] as String)
                  .toList();
              return !_sameList(
                definition.consequences
                    .map((item) => item.katalogCategoryInternalName)
                    .toList(),
                expectedIds,
              );
            })['stableId']
            as String?
      : null;
  final editedBefore = editedReferenceId != null;
  final osnovniPaket = scenarioRepository.readOsnovniPaket(module);
  final mismatches = <String>[];
  final protectiveEquipmentByCause = <String, int>{
    for (final cause in const [
      'PRIRODNA',
      'NASILNA',
      'ZARAZNA',
      'NEDEFINISANA',
    ])
      cause: 0,
  };

  for (final expected in scenarios) {
    final axes = (expected['axes'] as Map<String, dynamic>);
    final predmetId = await predmeti.kreirajPredmet(savetnikId: 1);
    await predmeti.azurirajPredmet(predmetId, _companionFor(axes));
    await predmeti.inicijalizujIriu(predmetId);
    final result = await iriu.syncScenarioRows(
      predmetId: predmetId,
      predmet: await predmeti.getPredmet(predmetId),
      scenarios: active,
      osnovniPaket: osnovniPaket,
    );

    final expectedId = expected['stableId'] as String;
    final actualId = result.matchedScenarioIds.singleOrNull;
    final rows = await iriu.getIriu(predmetId);
    final provenance =
        await (db.select(db.iriuProvenance)..where(
              (row) => row.iriuId.isIn(rows.map((item) => item.id).toList()),
            ))
            .get();
    final provenanceById = {for (final row in provenance) row.iriuId: row};
    final scenarioRows =
        rows
            .where((row) => provenanceById[row.id]?.origin == 'SCENARIO_PAKET')
            .toList()
          ..sort(
            (left, right) =>
                left.poslovniRedosled.compareTo(right.poslovniRedosled),
          );
    final expectedItems = label == 'CANONICAL_COPY'
        ? activeById[expectedId]!.consequences
              .map(
                (item) => <String, dynamic>{
                  'stableId': item.katalogCategoryInternalName,
                  'status': item.action.name == 'required'
                      ? 'REQUIRED'
                      : 'RECOMMENDED',
                },
              )
              .toList()
        : (expected['items'] as List<dynamic>).cast<Map<String, dynamic>>();
    final actualNames = scenarioRows.map((row) => row.interniNaziv).toList();
    final expectedNames = expectedItems
        .map((item) => item['stableId'] as String)
        .toList();
    final actualStatuses = scenarioRows
        .map((row) => row.poslovniStatus)
        .toList();
    final expectedStatuses = expectedItems
        .map((item) => item['status'] == 'REQUIRED' ? 'AKTIVNO' : 'PREPORUČENO')
        .toList();
    final snapshot = await (db.select(
      db.predmetScenarioSnapshots,
    )..where((row) => row.predmetId.equals(predmetId))).getSingleOrNull();
    final actualSnapshotId = snapshot?.scenarioId;
    final hasProtective = actualNames.contains('ZASTITNA_I_DODATNA_OPREMA');
    if (hasProtective) {
      protectiveEquipmentByCause[axes['cause'] as String] =
          protectiveEquipmentByCause[axes['cause'] as String]! + 1;
    }
    if (actualId != expectedId ||
        actualSnapshotId != expectedId ||
        !_sameList(actualNames, expectedNames) ||
        !_sameList(actualStatuses, expectedStatuses)) {
      mismatches.add(
        '$label ${expected['reference']} expected=$expectedId actual=$actualId '
        'snapshot=$actualSnapshotId names=$actualNames expectedNames=$expectedNames '
        'statuses=$actualStatuses expectedStatuses=$expectedStatuses',
      );
    }
    if (label == 'CANONICAL_COPY') {
      // Keep the user-data copy bounded: only the just-created forensic
      // PREDMET is removed after its persisted evidence has been checked.
      await predmeti.obrisiPredmet(predmetId);
    }
  }
  var preservedEditedDefinition = editedBefore;
  if (editedReferenceId != null) {
    final after = (await scenarioRepository.getActiveDefinitions()).singleWhere(
      (record) => record.id == editedReferenceId,
    );
    preservedEditedDefinition =
        preservedEditedDefinition &&
        after.consequences
                .map((item) => item.katalogCategoryInternalName)
                .join('|') ==
            activeById[editedReferenceId]!.consequences
                .map((item) => item.katalogCategoryInternalName)
                .join('|');
  }
  return _GateSummary(
    scenarioCount: scenarios.length,
    mismatches: mismatches,
    protectiveEquipmentByCause: protectiveEquipmentByCause,
    preservedEditedDefinition: preservedEditedDefinition,
  );
}

PredmetiCompanion _companionFor(Map<String, dynamic> axes) {
  final ceremony = axes['ceremony'] as String;
  final docek = axes['docek'] == 'DA';
  return PredmetiCompanion(
    ime: const Value('Forensic'),
    prezime: const Value('Scenario'),
    uzrokSmrti: Value(axes['cause'] as String),
    mestoSmrti: Value(docek ? '' : axes['place'] as String),
    vrstaCeremonije: Value(ceremony),
    tipGroblja: Value(axes['cemeteryType'] as String),
    tipGrobnogMesta: Value(axes['burialPlace'] as String),
    opelo: Value(axes['opelo'] as String),
    sahranaVanSrbije: Value(axes['international'] == 'DA'),
    docekPosmrtnihOstataka: Value(docek),
  );
}

bool _sameList(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

class _GateSummary {
  const _GateSummary({
    required this.scenarioCount,
    required this.mismatches,
    required this.protectiveEquipmentByCause,
    required this.preservedEditedDefinition,
  });

  final int scenarioCount;
  final List<String> mismatches;
  final Map<String, int> protectiveEquipmentByCause;
  final bool preservedEditedDefinition;

  String get diagnostics => mismatches.take(20).join('\n');
}
