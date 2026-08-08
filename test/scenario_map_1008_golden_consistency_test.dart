import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/owner_scenario_policy_kernel.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_contract.dart';
import 'package:opc_v4/features/predmeti/core_v2/scenario/scenario_module_repository.dart';

import 'test_bootstrap.dart';

void main() {
  late Map<String, dynamic> golden;

  setUpAll(() {
    golden =
        jsonDecode(
              File(
                'test/fixtures/scenario/scenario_map_owner_golden.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  test(
    'golden fixture has independent provenance and structural integrity',
    () {
      expect(golden['formatVersion'], 1);
      expect(
        golden['sourceDocument'],
        'Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md',
      );
      expect(golden['sourceSha256'], _ownerMapSha256);
      expect(golden['ownerScenarioCount'], 1008);
      final scenarios = golden['scenarios'] as List<dynamic>;
      expect(scenarios, hasLength(1008));

      final numbers = <int>{};
      final keys = <String>{};
      for (final raw in scenarios) {
        final scenario = raw as Map<String, dynamic>;
        final number = scenario['number'] as int;
        final stableId = scenario['stableId'] as String;
        expect(numbers.add(number), isTrue, reason: 'duplicate number $number');
        expect(keys.add(stableId), isTrue, reason: 'duplicate key $stableId');
        expect(
          scenario['reference'],
          'SCENARIO ${number.toString().padLeft(4, '0')}',
        );
        final axes = scenario['axes'] as Map<String, dynamic>;
        expect(axes.keys, containsAll(_axisNames));
        final items = scenario['items'] as List<dynamic>;
        final itemIds = <String>{};
        for (final item in items.cast<Map<String, dynamic>>()) {
          expect(_knownItemIds, contains(item['stableId']));
          expect({'REQUIRED', 'RECOMMENDED'}, contains(item['status']));
          expect(item['biohazard'], isA<bool>());
          expect(itemIds.add(item['stableId'] as String), isTrue);
        }
      }
      expect(numbers, hasLength(1008));
      expect(keys, hasLength(1008));
    },
  );

  test('all 1008 owner records exactly match the independent golden oracle', () {
    final scenarios = golden['scenarios'] as List<dynamic>;
    final mismatches = <String>[];
    final actualKeys = <String>{};
    var missingItems = 0;
    var extraItems = 0;
    var orderMismatches = 0;
    var statusMismatches = 0;
    var unresolvedIds = 0;

    for (final raw in scenarios.cast<Map<String, dynamic>>()) {
      final axes = raw['axes'] as Map<String, dynamic>;
      final key = _keyFromAxes(axes);
      final actual = const OwnerScenarioPolicyKernel().definitionForKey(key);
      actualKeys.add(actual.id);
      final expectedId = raw['stableId'] as String;
      final expectedItems = (raw['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (item) => _GoldenItem(
              stableId: item['stableId'] as String,
              status: item['status'] as String,
              biohazard: item['biohazard'] as bool,
            ),
          )
          .toList(growable: false);
      final actualItems = actual.consequences
          .map(
            (item) => _GoldenItem(
              stableId: item.katalogCategoryInternalName,
              status: item.action == ScenarioConsequenceAction.recommended
                  ? 'RECOMMENDED'
                  : 'REQUIRED',
              biohazard: item.warning.trim().isNotEmpty,
            ),
          )
          .toList(growable: false);
      unresolvedIds += actualItems
          .where((item) => !_knownItemIds.contains(item.stableId))
          .length;
      final expectedIds = expectedItems.map((item) => item.stableId).toList();
      final actualIds = actualItems.map((item) => item.stableId).toList();
      final missing = expectedIds
          .where((id) => !actualIds.contains(id))
          .toList();
      final extra = actualIds.where((id) => !expectedIds.contains(id)).toList();
      final orderMismatch = !_sameList(expectedIds, actualIds);
      final statusMismatch =
          expectedItems.length == actualItems.length &&
          expectedItems.asMap().entries.any(
            (entry) =>
                entry.value.status != actualItems[entry.key].status ||
                entry.value.biohazard != actualItems[entry.key].biohazard,
          );
      if (actual.id != expectedId ||
          missing.isNotEmpty ||
          extra.isNotEmpty ||
          orderMismatch ||
          statusMismatch) {
        if (missing.isNotEmpty) {
          missingItems += missing.length;
        }
        if (extra.isNotEmpty) {
          extraItems += extra.length;
        }
        if (orderMismatch) orderMismatches++;
        if (statusMismatch) {
          statusMismatches++;
        }
        mismatches.add(
          '${raw['reference']} $expectedId\n'
          '  expected=${jsonEncode(expectedItems)}\n'
          '  actual=${jsonEncode(actualItems)}\n'
          '  missing=$missing extra=$extra orderMismatch=$orderMismatch '
          'statusMismatch=$statusMismatch',
        );
      }
    }

    expect(
      mismatches,
      isEmpty,
      reason:
          'golden mismatch count=${mismatches.length}; missing=$missingItems '
          'extra=$extraItems order=$orderMismatches status=$statusMismatches\n'
          '${mismatches.take(20).join('\n')}',
    );
    expect(actualKeys, hasLength(1008));
    expect(unresolvedIds, 0);
  });

  test('seeded MAP definitions match the same golden oracle', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = ScenarioModuleRepository(
      db,
      loadAsset: (_) => File('assets/scenario_defaults.json').readAsString(),
    );
    await repository.ensureModuleAndDefaults();
    final records = await repository.getDefinitions();
    final mapRecords = records.where((record) => record.id.startsWith('MAP_'));
    expect(mapRecords, hasLength(1008));
    final expectedById = <String, Map<String, dynamic>>{
      for (final raw
          in (golden['scenarios'] as List<dynamic>)
              .cast<Map<String, dynamic>>())
        raw['stableId'] as String: raw,
    };
    for (final record in mapRecords) {
      final expected = expectedById[record.id];
      expect(expected, isNotNull, reason: 'unexpected seeded id ${record.id}');
      final actual = repository.definitionFromRecord(record);
      final expectedItems = (expected!['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(actual.consequences, hasLength(expectedItems.length));
      for (var i = 0; i < expectedItems.length; i++) {
        final item = actual.consequences[i];
        final raw = expectedItems[i];
        expect(item.katalogCategoryInternalName, raw['stableId']);
        expect(
          item.action == ScenarioConsequenceAction.recommended
              ? 'RECOMMENDED'
              : 'REQUIRED',
          raw['status'],
        );
        expect(item.warning.trim().isNotEmpty, raw['biohazard']);
      }
    }
  });

  test('golden global invariants cover owner restrictions', () {
    final scenarios = golden['scenarios'] as List<dynamic>;
    for (final raw in scenarios.cast<Map<String, dynamic>>()) {
      final axes = raw['axes'] as Map<String, dynamic>;
      final ceremony = axes['ceremony'];
      final international = axes['international'];
      final docek = axes['docek'];
      if ((ceremony as String).startsWith('KREMACIJA')) {
        expect(axes['cemeteryType'], 'NE PRIMENJUJE SE');
        expect(axes['burialPlace'], 'NE PRIMENJUJE SE');
        expect(international, 'NE');
      }
      if (docek == 'DA') expect(axes['place'], 'INFORMATIVNO');
      final items = (raw['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final ids = items.map((item) => item['stableId']).toList();
      expect(ids.toSet(), hasLength(ids.length));
      if (axes['opelo'] == 'DA') {
        expect(ids.last, IriuK.kompletZaOpelo);
      } else {
        expect(ids, isNot(contains(IriuK.kompletZaOpelo)));
      }
      if (international == 'DA') {
        expect(ids, contains(IriuK.medjunarodniPrevoz));
        expect(ids, isNot(contains(IriuK.prevozDoGroblja)));
      }
      final needsProtective = axes['cause'] != 'PRIRODNA';
      final iznosenjeIndex = ids.indexOf(IriuK.iznosenje);
      final protectiveIndex = ids.indexOf(IriuK.zastitnaIDodatnaOprema);
      if (needsProtective && iznosenjeIndex >= 0) {
        expect(protectiveIndex, iznosenjeIndex + 1);
      }
    }
  });
}

const _ownerMapSha256 =
    '663f104f01c8abfabaf5dedf8c82185af03fdef31b403dfb7d4e2efbf0e061e4';

const _axisNames = <String>{
  'cause',
  'place',
  'ceremony',
  'cemeteryType',
  'burialPlace',
  'opelo',
  'international',
  'docek',
};

const _knownItemIds = <String>{
  IriuK.transportnaVreca,
  IriuK.iznosenje,
  IriuK.zastitnaIDodatnaOprema,
  IriuK.prevozDoHladnjace,
  IriuK.hladnjaca,
  IriuK.spremaanjePokojnika,
  IriuK.limeniUlozak,
  IriuK.lemovanje,
  IriuK.prevozDoGroblja,
  IriuK.prevozSprovoda,
  IriuK.medjunarodniPrevoz,
  IriuK.medjunarodnaDocumentacija,
  IriuK.balsamovanje,
  IriuK.kompletZaOpelo,
  IriuK.cargoTroskovi,
};

OwnerScenarioKey _keyFromAxes(Map<String, dynamic> axes) => OwnerScenarioKey(
  cause: axes['cause'] as String,
  place: axes['place'] == 'INFORMATIVNO' ? null : axes['place'] as String,
  ceremony: axes['ceremony'] as String,
  cemeteryType: axes['cemeteryType'] as String,
  burialPlace: axes['burialPlace'] as String,
  opelo: axes['opelo'] as String,
  international: axes['international'] == 'DA',
  docek: axes['docek'] == 'DA',
);

bool _sameList(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

class _GoldenItem {
  const _GoldenItem({
    required this.stableId,
    required this.status,
    required this.biohazard,
  });

  final String stableId;
  final String status;
  final bool biohazard;

  Map<String, Object> toJson() => {
    'stableId': stableId,
    'status': status,
    'biohazard': biohazard,
  };

  @override
  String toString() => jsonEncode(toJson());
}
