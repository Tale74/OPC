import 'package:drift/drift.dart';

/// A supported OPC database has an object with a definition that contradicts
/// the schema expected by this application build.
///
/// Recovery deliberately stops instead of dropping tables, rewriting business
/// rows, or accepting a same-named object with different semantics.
final class OpcSchemaMismatch implements Exception {
  const OpcSchemaMismatch(this.message);

  final String message;

  @override
  String toString() => 'OPC database schema mismatch: $message';
}

final class SqliteColumnDefinition {
  const SqliteColumnDefinition({
    required this.name,
    required this.type,
    required this.notNull,
    required this.defaultSql,
    required this.primaryKeyPosition,
    this.acceptedLegacyDefaultSql = const <String?>[],
  });

  final String name;
  final String type;
  final bool notNull;
  final String? defaultSql;
  final int primaryKeyPosition;
  final List<String?> acceptedLegacyDefaultSql;
}

final class SqliteIndexDefinition {
  const SqliteIndexDefinition({
    required this.name,
    required this.table,
    required this.unique,
    required this.columns,
    required this.createSql,
    this.whereSql,
  });

  final String name;
  final String table;
  final bool unique;
  final List<String> columns;
  final String createSql;
  final String? whereSql;
}

/// Idempotent primitives used by Drift migrations and the narrow startup
/// recovery boundary. This class does not own version sequencing; Drift does.
final class OpcSchemaRecovery {
  OpcSchemaRecovery(this.database);

  final GeneratedDatabase database;

  Future<bool> tableExists(String tableName) async {
    final row = await database
        .customSelect(
          'SELECT 1 AS present FROM sqlite_master '
          'WHERE type = ? AND name = ? LIMIT 1',
          variables: [
            const Variable<String>('table'),
            Variable<String>(tableName),
          ],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> indexExists(String indexName) async {
    final row = await database
        .customSelect(
          'SELECT 1 AS present FROM sqlite_master '
          'WHERE type = ? AND name = ? LIMIT 1',
          variables: [
            const Variable<String>('index'),
            Variable<String>(indexName),
          ],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<Map<String, SqliteColumnDefinition>> tableColumns(
    String tableName,
  ) async {
    final rows = await database
        .customSelect('PRAGMA table_info(${_quoteIdentifier(tableName)})')
        .get();
    return {
      for (final row in rows)
        row.read<String>('name'): SqliteColumnDefinition(
          name: row.read<String>('name'),
          type: row.read<String>('type'),
          notNull: row.read<int>('notnull') == 1,
          defaultSql: row.readNullable<String>('dflt_value'),
          primaryKeyPosition: row.read<int>('pk'),
        ),
    };
  }

  Future<void> ensureGeneratedColumn({
    required Migrator migrator,
    required TableInfo<Table, Object?> table,
    required GeneratedColumn column,
  }) async {
    final tableName = table.actualTableName;
    if (!await tableExists(tableName)) {
      throw OpcSchemaMismatch(
        'required table "$tableName" is missing while ensuring '
        'column "${column.$name}"',
      );
    }

    final columns = await tableColumns(tableName);
    if (!columns.containsKey(column.$name)) {
      await migrator.addColumn(table, column);
    }
    await validateGeneratedColumn(table, column);
  }

  Future<void> ensureColumn({
    required String tableName,
    required SqliteColumnDefinition expected,
    required String addColumnSql,
  }) async {
    if (!await tableExists(tableName)) {
      throw OpcSchemaMismatch(
        'required table "$tableName" is missing while ensuring '
        'column "${expected.name}"',
      );
    }
    final columns = await tableColumns(tableName);
    if (!columns.containsKey(expected.name)) {
      await database.customStatement(addColumnSql);
    }
    final actual = (await tableColumns(tableName))[expected.name];
    if (actual == null) {
      throw OpcSchemaMismatch(
        'required column "$tableName.${expected.name}" is missing after '
        'supported recovery',
      );
    }
    _validateColumn(tableName, expected, actual);
  }

  Future<void> ensureGeneratedTable({
    required Migrator migrator,
    required TableInfo<Table, Object?> table,
  }) async {
    if (!await tableExists(table.actualTableName)) {
      await migrator.createTable(table);
    }
    await validateGeneratedTable(table);
  }

  Future<void> validateGeneratedColumn(
    TableInfo<Table, Object?> table,
    GeneratedColumn column,
  ) async {
    final tableName = table.actualTableName;
    final actual = (await tableColumns(tableName))[column.$name];
    if (actual == null) {
      throw OpcSchemaMismatch(
        'required column "$tableName.${column.$name}" is missing',
      );
    }

    final expected = _generatedColumnDefinition(table, column);
    _validateColumn(tableName, expected, actual);
  }

  Future<void> validateGeneratedTable(
    TableInfo<Table, Object?> table, {
    bool rejectUnexpectedColumns = true,
    Set<String> allowedExtraColumns = const <String>{},
    Map<String, SqliteColumnDefinition> columnOverrides =
        const <String, SqliteColumnDefinition>{},
  }) async {
    final tableName = table.actualTableName;
    if (!await tableExists(tableName)) {
      throw OpcSchemaMismatch('required table "$tableName" is missing');
    }

    final actual = await tableColumns(tableName);
    final expectedNames = <String>{};
    for (final column in table.$columns) {
      expectedNames.add(column.$name);
      final found = actual[column.$name];
      if (found == null) {
        throw OpcSchemaMismatch(
          'required column "$tableName.${column.$name}" is missing',
        );
      }
      _validateColumn(
        tableName,
        columnOverrides[column.$name] ??
            _generatedColumnDefinition(table, column),
        found,
      );
    }

    if (rejectUnexpectedColumns) {
      final unexpected = actual.keys
          .toSet()
          .difference(expectedNames)
          .difference(allowedExtraColumns);
      if (unexpected.isNotEmpty) {
        throw OpcSchemaMismatch(
          'table "$tableName" contains unsupported columns: '
          '${unexpected.toList()..sort()}',
        );
      }
    }
  }

  Future<void> validateColumns(
    String tableName,
    List<SqliteColumnDefinition> expected, {
    bool rejectUnexpectedColumns = true,
  }) async {
    if (!await tableExists(tableName)) {
      throw OpcSchemaMismatch('required table "$tableName" is missing');
    }

    final actual = await tableColumns(tableName);
    final expectedNames = expected.map((column) => column.name).toSet();
    for (final column in expected) {
      final found = actual[column.name];
      if (found == null) {
        throw OpcSchemaMismatch(
          'required column "$tableName.${column.name}" is missing',
        );
      }
      _validateColumn(tableName, column, found);
    }

    if (rejectUnexpectedColumns) {
      final unexpected = actual.keys.toSet().difference(expectedNames);
      if (unexpected.isNotEmpty) {
        throw OpcSchemaMismatch(
          'table "$tableName" contains unsupported columns: '
          '${unexpected.toList()..sort()}',
        );
      }
    }
  }

  Future<void> ensureIndex(SqliteIndexDefinition expected) async {
    if (!await tableExists(expected.table)) {
      throw OpcSchemaMismatch(
        'required table "${expected.table}" is missing while ensuring '
        'index "${expected.name}"',
      );
    }
    if (!await indexExists(expected.name)) {
      await database.customStatement(expected.createSql);
    }
    await validateIndex(expected);
  }

  Future<void> validateIndex(SqliteIndexDefinition expected) async {
    final master = await database
        .customSelect(
          'SELECT type, tbl_name, sql FROM sqlite_master WHERE name = ? LIMIT 1',
          variables: [Variable<String>(expected.name)],
        )
        .getSingleOrNull();
    if (master == null) {
      throw OpcSchemaMismatch('required index "${expected.name}" is missing');
    }
    final type = master.read<String>('type');
    final table = master.read<String>('tbl_name');
    if (type != 'index' || table != expected.table) {
      throw OpcSchemaMismatch(
        'schema object "${expected.name}" is not the expected index on '
        '"${expected.table}"',
      );
    }

    final list = await database
        .customSelect('PRAGMA index_list(${_quoteIdentifier(expected.table)})')
        .get();
    final indexRow = list
        .where((row) => row.read<String>('name') == expected.name)
        .firstOrNull;
    if (indexRow == null ||
        (indexRow.read<int>('unique') == 1) != expected.unique) {
      throw OpcSchemaMismatch(
        'index "${expected.name}" has an unexpected uniqueness definition',
      );
    }

    final info = await database
        .customSelect('PRAGMA index_info(${_quoteIdentifier(expected.name)})')
        .get();
    final columns = [for (final row in info) row.read<String>('name')];
    if (!_sameList(columns, expected.columns)) {
      throw OpcSchemaMismatch(
        'index "${expected.name}" has columns $columns; expected '
        '${expected.columns}',
      );
    }

    final expectedWhere = expected.whereSql;
    final actualSql = master.readNullable<String>('sql');
    if (expectedWhere != null &&
        (actualSql == null ||
            !_normalizeSql(actualSql).contains(_normalizeSql(expectedWhere)))) {
      throw OpcSchemaMismatch(
        'index "${expected.name}" has an unexpected partial-index predicate',
      );
    }
  }

  SqliteColumnDefinition _generatedColumnDefinition(
    TableInfo<Table, Object?> table,
    GeneratedColumn column,
  ) {
    final typeContext = GenerationContext.fromDb(database);
    final type = column.type.sqlTypeName(typeContext);
    final defaultExpression = column.defaultValue;
    String? defaultSql;
    if (defaultExpression != null) {
      final defaultContext = GenerationContext.fromDb(database);
      defaultExpression.writeInto(defaultContext);
      defaultSql = defaultContext.sql;
      if (!defaultExpression.isLiteral) defaultSql = '($defaultSql)';
    }

    final primaryKey = table.$primaryKey.toList(growable: false);
    final primaryKeyPosition = primaryKey.indexOf(column) + 1;
    return SqliteColumnDefinition(
      name: column.$name,
      type: type,
      notNull: !column.$nullable,
      defaultSql: defaultSql,
      primaryKeyPosition: primaryKeyPosition,
    );
  }

  void _validateColumn(
    String tableName,
    SqliteColumnDefinition expected,
    SqliteColumnDefinition actual,
  ) {
    final differences = <String>[];
    if (actual.type.trim().toUpperCase() !=
        expected.type.trim().toUpperCase()) {
      differences.add('type=${actual.type} expected=${expected.type}');
    }
    if (actual.notNull != expected.notNull) {
      differences.add('notNull=${actual.notNull} expected=${expected.notNull}');
    }
    final acceptedDefaults = <String?>[
      expected.defaultSql,
      ...expected.acceptedLegacyDefaultSql,
    ].map(_normalizeDefault).toSet();
    if (!acceptedDefaults.contains(_normalizeDefault(actual.defaultSql))) {
      differences.add(
        'default=${actual.defaultSql} expected=${expected.defaultSql}',
      );
    }
    if (actual.primaryKeyPosition != expected.primaryKeyPosition) {
      differences.add(
        'primaryKeyPosition=${actual.primaryKeyPosition} '
        'expected=${expected.primaryKeyPosition}',
      );
    }
    if (differences.isNotEmpty) {
      throw OpcSchemaMismatch(
        'column "$tableName.${expected.name}" is malformed: '
        '${differences.join(', ')}',
      );
    }
  }

  static String _quoteIdentifier(String value) =>
      '"${value.replaceAll('"', '""')}"';

  static String? _normalizeDefault(String? value) {
    if (value == null) return null;
    var normalized = value.trim();
    while (normalized.length >= 2 &&
        normalized.startsWith('(') &&
        normalized.endsWith(')')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }
    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normalizeSql(String value) => value
      .replaceAll('"', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  static bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
