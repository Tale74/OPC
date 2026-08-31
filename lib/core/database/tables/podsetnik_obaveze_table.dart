import 'package:drift/drift.dart';

import 'predmeti_table.dart';

/// PREDMET-owned business completion/history for PODSETNIK obligations.
///
/// Notification identifiers and other device-local delivery state deliberately
/// do not belong here.  Rows are retained when a rule becomes irrelevant so
/// that historical completion is preserved without making the row active.
class PodsetnikObaveze extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  TextColumn get stableRuleId => text().named('stable_rule_id')();
  TextColumn get phase => text().withDefault(const Constant('PRE_CEREMONY'))();
  TextColumn get kind => text().withDefault(const Constant('ATOMIC'))();
  TextColumn get parentRuleId => text().named('parent_rule_id').nullable()();
  TextColumn get sourceFingerprint =>
      text().named('source_fingerprint').withDefault(const Constant(''))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get completedAt => text().named('completed_at').nullable()();
  TextColumn get updatedAt =>
      text().named('updated_at').withDefault(const Constant(''))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {predmetId, stableRuleId},
  ];
}
