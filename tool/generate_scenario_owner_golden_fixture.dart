import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _fixtureVersion = 1;

final _itemIds = <String, String>{
  'TRANSPORTNA VREĆA': 'TRANSPORTNA_VRECA',
  'IZNOŠENJE': 'IZNOSENJE',
  'ZAŠTITNA I DODATNA OPREMA': 'ZASTITNA_I_DODATNA_OPREMA',
  'PREVOZ DO HLADNJAČE': 'PREVOZ_DO_HLADNJACE',
  'HLADNJAČA': 'HLADNJACA',
  'SPREMANJE PREMINULOG LICA': 'SPREMANJE_POKOJNIKA',
  'LIMENI ULOŽAK': 'LIMENI_ULOZAK',
  'LEMOVANJE': 'LEMOVANJE',
  'PREVOZ DO GROBLJA': 'PREVOZ_DO_GROBLJA',
  'PREVOZ SPROVODA': 'PREVOZ_SPROVODA',
  'MEĐUNARODNI PREVOZ': 'MEDJUNARODNI_PREVOZ',
  'MEĐUNARODNA DOKUMENTACIJA': 'MEDJUNARODNA_DOKUMENTACIJA',
  'BALSAMOVANJE': 'BALSAMOVANJE',
  'KOMPLET ZA OPELO': 'KOMPLET_ZA_OPELO',
  'CARGO TROŠKOVI': 'CARGO_TROSKOVI',
};

final _requiredCauses = <String>{
  'PRIRODNA',
  'NASILNA',
  'ZARAZNA',
  'NEDEFINISANA',
};
final _requiredPlaces = <String>{
  'STAN',
  'DOM ZA STARE',
  'BOLNICA',
  'PRIVATNA BOLNICA',
  'ULICA / JAVNO MESTO',
  'DRUGO',
  'INFORMATIVNO',
};
final _requiredCeremonies = <String>{
  'SAHRANA',
  'SAHRANA EKSPRES',
  'KREMACIJA',
  'KREMACIJA EKSPRES',
};
final _requiredCemeteries = <String>{'GRADSKO', 'LOKALNO', 'NE PRIMENJUJE SE'};
final _requiredBurialPlaces = <String>{'GROB', 'GROBNICA', 'NE PRIMENJUJE SE'};

void main(List<String> args) {
  final options = _parseOptions(args);
  final sourcePath = options['source'];
  final outputPath = options['output'];
  if (sourcePath == null || outputPath == null) {
    stderr.writeln(
      'Usage: dart run tool/generate_scenario_owner_golden_fixture.dart '
      '--source <owner-map.md> --output <scenario_map_owner_golden.json>',
    );
    exitCode = 64;
    return;
  }

  final sourceBytes = File(sourcePath).readAsBytesSync();
  final source = utf8.decode(sourceBytes);
  final scenarios = _parse(source);
  if (scenarios.length != 1008) {
    throw StateError(
      'Expected exactly 1008 scenarios, got ${scenarios.length}.',
    );
  }

  final document = <String, Object?>{
    'formatVersion': _fixtureVersion,
    'sourceDocument': 'Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md',
    'sourceSha256': sha256.convert(sourceBytes).toString(),
    'ownerScenarioCount': scenarios.length,
    'scenarios': scenarios,
  };
  final encoded = const JsonEncoder.withIndent('  ').convert(document);
  File(outputPath).writeAsStringSync('$encoded\n', encoding: utf8);
  stdout.writeln(
    'Generated ${scenarios.length} scenarios from $sourcePath to $outputPath',
  );
}

Map<String, String> _parseOptions(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--source' || arg == '--output') {
      if (i + 1 >= args.length) throw FormatException('$arg needs a value.');
      result[arg.substring(2)] = args[++i];
    } else {
      throw FormatException('Unknown option: $arg');
    }
  }
  return result;
}

List<Map<String, Object?>> _parse(String source) {
  final lines = const LineSplitter().convert(source);
  final headings = <({int line, int number, String reference, String key})>[];
  final headingPattern = RegExp(r'^### SCENARIO (\d{4}) .+?`([^`]+)`');
  for (var i = 0; i < lines.length; i++) {
    final match = headingPattern.firstMatch(lines[i]);
    if (match == null) continue;
    headings.add((
      line: i,
      number: int.parse(match.group(1)!),
      reference: 'SCENARIO ${match.group(1)}',
      key: match.group(2)!,
    ));
  }
  final numbers = headings.map((item) => item.number).toSet();
  if (numbers.length != headings.length || numbers.length != 1008) {
    throw StateError('Scenario number collision or incomplete map.');
  }

  final result = <Map<String, Object?>>[];
  final fullKeys = <String>{};
  for (var index = 0; index < headings.length; index++) {
    final heading = headings[index];
    final end = index + 1 < headings.length
        ? headings[index + 1].line
        : lines.length;
    final block = lines.sublist(heading.line, end);
    final conditions = block.where((line) => line.startsWith('**USLOVI:**'));
    if (conditions.length != 1) {
      throw StateError(
        '${heading.reference} must have exactly one USLOVI line.',
      );
    }
    final axes = _parseConditions(conditions.single);
    final stableId = _stableId(axes);
    if (!fullKeys.add(stableId)) {
      throw StateError('Duplicate full key $stableId.');
    }
    final items = _parseItems(block, heading.reference);
    result.add({
      'reference': heading.reference,
      'number': heading.number,
      'stableId': stableId,
      'axes': axes,
      'items': items,
    });
  }
  return result;
}

Map<String, String> _parseConditions(String line) {
  var remaining = line.substring('**USLOVI:**'.length).trim();
  if (remaining.endsWith('.')) {
    remaining = remaining.substring(0, remaining.length - 1);
  }
  final fields = <String, String>{};
  for (final part in remaining.split('; ')) {
    final separator = part.indexOf(': ');
    if (separator <= 0) throw FormatException('Unknown condition: $part');
    final label = part.substring(0, separator).trim();
    var value = part.substring(separator + 2).trim();
    if (label == 'MESTO SMRTI' && value.startsWith('NE UČESTVUJE')) {
      value = 'INFORMATIVNO';
    }
    fields[label] = value;
  }
  const labels = [
    'UZROK SMRTI',
    'MESTO SMRTI',
    'VRSTA CEREMONIJE',
    'TIP GROBLJA',
    'GROBNO MESTO',
    'OPELO',
    'SAHRANA VAN SRBIJE',
    'DOČEK POSMRTNIH OSTATAKA',
  ];
  if (fields.length != labels.length ||
      !fields.keys.toSet().containsAll(labels)) {
    throw FormatException('Unknown or missing condition axis: $fields');
  }
  _expect(_requiredCauses, fields['UZROK SMRTI']!, 'UZROK SMRTI');
  _expect(_requiredPlaces, fields['MESTO SMRTI']!, 'MESTO SMRTI');
  _expect(_requiredCeremonies, fields['VRSTA CEREMONIJE']!, 'VRSTA CEREMONIJE');
  _expect(_requiredCemeteries, fields['TIP GROBLJA']!, 'TIP GROBLJA');
  _expect(_requiredBurialPlaces, fields['GROBNO MESTO']!, 'GROBNO MESTO');
  _expect({'DA', 'NE'}, fields['OPELO']!, 'OPELO');
  _expect({'DA', 'NE'}, fields['SAHRANA VAN SRBIJE']!, 'SAHRANA VAN SRBIJE');
  _expect(
    {'DA', 'NE'},
    fields['DOČEK POSMRTNIH OSTATAKA']!,
    'DOČEK POSMRTNIH OSTATAKA',
  );
  return <String, String>{
    'cause': fields['UZROK SMRTI']!,
    'place': fields['MESTO SMRTI']!,
    'ceremony': fields['VRSTA CEREMONIJE']!,
    'cemeteryType': fields['TIP GROBLJA']!,
    'burialPlace': fields['GROBNO MESTO']!,
    'opelo': fields['OPELO']!,
    'international': fields['SAHRANA VAN SRBIJE']!,
    'docek': fields['DOČEK POSMRTNIH OSTATAKA']!,
  };
}

List<Map<String, Object?>> _parseItems(List<String> block, String reference) {
  final marker = block.indexWhere((line) => line == '**SCENARIO STAVKE:**');
  if (marker < 0) {
    throw StateError('$reference has no SCENARIO STAVKE block.');
  }
  final items = <Map<String, Object?>>[];
  for (var i = marker + 1; i < block.length; i++) {
    final line = block[i].trim();
    if (line.startsWith('**UNUTRAŠNJI') ||
        line == '---' ||
        line.startsWith('### ')) {
      break;
    }
    if (!line.startsWith('- ')) {
      continue;
    }
    final decorated = line.substring(2).trim();
    final biohazard = decorated.contains('**(BIOHAZARD)**');
    final recommended = decorated.contains('**(PREPORUČENO)**');
    final displayName = decorated
        .replaceAll(' **(BIOHAZARD)**', '')
        .replaceAll(' **(PREPORUČENO)**', '')
        .trim();
    final id = _itemIds[displayName];
    if (id == null) {
      throw StateError('$reference has unknown item "$displayName".');
    }
    items.add({
      'stableId': id,
      'status': recommended ? 'RECOMMENDED' : 'REQUIRED',
      'biohazard': biohazard,
    });
  }
  if (items.isEmpty) throw StateError('$reference has no scenario items.');
  final ids = items.map((item) => item['stableId']).toSet();
  if (ids.length != items.length) {
    throw StateError('$reference has duplicate items.');
  }
  return items;
}

String _stableId(Map<String, String> axes) {
  String slug(String value) => value
      .toUpperCase()
      .replaceAll('Č', 'C')
      .replaceAll('Ć', 'C')
      .replaceAll('Š', 'S')
      .replaceAll('Ž', 'Z')
      .replaceAll('Đ', 'DJ')
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return [
    'MAP',
    slug(axes['cause']!),
    slug(axes['place']!),
    slug(axes['ceremony']!),
    slug(axes['cemeteryType']!),
    slug(axes['burialPlace']!),
    axes['opelo']!,
    axes['international']!,
    axes['docek']!,
  ].join('_');
}

void _expect(Set<String> allowed, String value, String axis) {
  if (!allowed.contains(value)) {
    throw FormatException('Unknown $axis value: $value');
  }
}
