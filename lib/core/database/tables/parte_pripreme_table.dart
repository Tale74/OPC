import 'package:drift/drift.dart';

import 'predmeti_table.dart';

/// Restart-safe technical work state for one PARTE output.
///
/// This table is deliberately outside PREDMET business truth and portable
/// JSON. It owns only an unfinished/completed preparation lifecycle.
class PartePripreme extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predmetId =>
      integer().references(Predmeti, #id, onDelete: KeyAction.cascade)();
  TextColumn get predmetBroj => text()();
  TextColumn get status => text().withDefault(const Constant('IN_PROGRESS'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get sourceFingerprint => text()();
  TextColumn get templateId => text()();
  TextColumn get templateSnapshotJson => text()();
  TextColumn get draftJson => text()();
  TextColumn get photoMediaKey => text().nullable()();
  TextColumn get customSymbolMediaKey => text().nullable()();
  TextColumn get previewConfirmedFingerprint => text().nullable()();
  TextColumn get exportedRenderFingerprint => text().nullable()();
  TextColumn get exportedFilename => text().nullable()();
  TextColumn get exportedLocation => text().nullable()();
  BoolColumn get exportedSuccessfully =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get cleanupPending =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get noPhotoAccepted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get noCustomSymbolAccepted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get lowResolutionAccepted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get grammarVerified =>
      boolean().withDefault(const Constant(false))();
  TextColumn get completedAt => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {predmetId},
  ];
}
