import 'package:drift/drift.dart';

import 'predmeti_table.dart';

/// Transferable preparation state for one concrete ČITULJA IRiU occurrence.
///
/// The portable occurrence identity is the relationship key. The local row
/// id is only a database implementation detail and is never the business
/// identity of the article.
class CituljePripreme extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  TextColumn get portableOccurrenceId =>
      text().named('portable_occurrence_id')();
  TextColumn get articleType => text().named('article_type')();
  TextColumn get parteTextMode =>
      text().named('parte_text_mode').nullable()();
  TextColumn get publicationDate =>
      text().named('publication_date').nullable()();
  TextColumn get publicationText =>
      text().named('publication_text').withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get state =>
      text().withDefault(const Constant('UNCONFIGURED'))();
  BoolColumn get finalized =>
      boolean().withDefault(const Constant(false))();
  TextColumn get finalizedAt =>
      text().named('finalized_at').nullable()();
  TextColumn get parteSnapshotFingerprint =>
      text().named('parte_snapshot_fingerprint').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {predmetId, portableOccurrenceId},
  ];
}
