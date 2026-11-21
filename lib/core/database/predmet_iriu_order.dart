import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// Portable category order for the basic package and optional local occurrence
/// order for the SCENARIO partition. SQLite IDs are never stored in the lists.
class PredmetIriuOrder {
  const PredmetIriuOrder({required this.basic, this.scenario = const []});

  factory PredmetIriuOrder.fromJson(Object? raw) {
    if (raw is! Map<String, dynamic> || raw['version'] != 1 ||
        raw.length != 3) {
      throw const FormatException('Nepodržan format IRiU redosleda.');
    }
    List<String> parse(Object? list) {
      if (list is! List || list.any((entry) =>
          entry is! String || entry.isEmpty || entry != entry.trim())) {
        throw const FormatException('Neispravan IRiU redosled.');
      }
      final values = list.cast<String>();
      if (values.toSet().length != values.length) {
        throw const FormatException('Duplikat u IRiU redosledu.');
      }
      return List.unmodifiable(values);
    }

    return PredmetIriuOrder(
      basic: parse(raw['basic']),
      scenario: parse(raw['scenario']),
    );
  }

  final List<String> basic;
  final List<String> scenario;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'basic': basic,
    'scenario': scenario,
  };
}

const predmetIriuOrderCreateSql =
    'CREATE TABLE IF NOT EXISTS predmet_iriu_order ('
    'predmet_id INTEGER PRIMARY KEY REFERENCES predmeti(id) ON DELETE CASCADE, '
    'payload TEXT NOT NULL)';

Future<void> createPredmetIriuOrderTable(AppDatabase db) =>
    db.customStatement(predmetIriuOrderCreateSql);

Future<PredmetIriuOrder?> readPredmetIriuOrder(
  AppDatabase db, int predmetId,
) async {
  final row = await db.customSelect(
    'SELECT payload FROM predmet_iriu_order WHERE predmet_id = ?',
    variables: [Variable.withInt(predmetId)],
  ).getSingleOrNull();
  return row == null
      ? null
      : PredmetIriuOrder.fromJson(jsonDecode(row.read<String>('payload')));
}

Future<void> savePredmetIriuOrder(
  AppDatabase db, int predmetId, PredmetIriuOrder order,
) => db.customStatement(
  'INSERT INTO predmet_iriu_order(predmet_id, payload) VALUES(?, ?) '
  'ON CONFLICT(predmet_id) DO UPDATE SET payload = excluded.payload',
  [predmetId, jsonEncode(order.toJson())],
);

Future<void> deletePredmetIriuOrder(AppDatabase db, int predmetId) =>
    db.customStatement(
      'DELETE FROM predmet_iriu_order WHERE predmet_id = ?', [predmetId],
    );

Future<PredmetIriuOrder?> exportPredmetIriuOrder(
  AppDatabase db, int predmetId,
) async {
  final order = await readPredmetIriuOrder(db, predmetId);
  if (order == null || order.scenario.isEmpty) return order;
  final rows = await db.customSelect(
    'SELECT i.portable_occurrence_id FROM iriu i JOIN iriu_provenance p '
    'ON p.iriu_id = i.id WHERE i.predmet_id = ? AND p.origin = ?',
    variables: [
      Variable.withInt(predmetId),
      Variable.withString('SCENARIO_PAKET'),
    ],
  ).get();
  final ids = rows.map((row) => row.readNullable<String>('portable_occurrence_id')).toSet();
  return PredmetIriuOrder(
    basic: order.basic,
    scenario: order.scenario.where(ids.contains).toList(growable: false),
  );
}

Future<void> restorePredmetIriuOrder(
  AppDatabase db, int predmetId, PredmetIriuOrder? order,
) async {
  if (order == null) {
    await deletePredmetIriuOrder(db, predmetId);
    return;
  }
  final cases = await (db.select(db.predmeti)
      ..where((row) => row.id.equals(predmetId))).get();
  if (cases.isEmpty) {
    throw const FormatException('IRiU redosled upućuje na nepostojeći PREDMET.');
  }
  if (order.scenario.isNotEmpty) {
    final rows = await db.customSelect(
      'SELECT i.portable_occurrence_id FROM iriu i JOIN iriu_provenance p '
      'ON p.iriu_id = i.id WHERE i.predmet_id = ? AND p.origin = ?',
      variables: [
        Variable.withInt(predmetId),
        Variable.withString('SCENARIO_PAKET'),
      ],
    ).get();
    final ids = rows.map((row) => row.readNullable<String>('portable_occurrence_id')).toSet();
    if (!ids.containsAll(order.scenario)) {
      throw const FormatException('IRiU redosled ima nepoznatu SCENARIO stavku.');
    }
  }
  await savePredmetIriuOrder(db, predmetId, order);
}

