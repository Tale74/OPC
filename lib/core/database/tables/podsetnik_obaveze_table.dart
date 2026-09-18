import 'package:drift/drift.dart';

import 'predmeti_table.dart';

/// PREDMET-owned completion state for PODSETNIK obligations.
///
/// Notification identifiers and other device-local delivery state deliberately
/// do not belong here.  ČITULJA retains only valid completed concrete-child
/// state when its portable occurrence is temporarily non-current; parents and
/// incomplete/invalid stale children are derived or discarded by the
/// repository.
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
