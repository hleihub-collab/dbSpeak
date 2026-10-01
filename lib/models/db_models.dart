enum DbDialect {
  postgresql('PostgreSQL', '5432'),
  mysql('MySQL', '3306'),
  sqlite('SQLite (Local)', ''),
  supabase('Supabase (Postgres)', '5432');

  final String label;
  final String defaultPort;
  const DbDialect(this.label, this.defaultPort);
}

class DbConnection {
  final String id;
  final String name;
  final DbDialect dialect;
  final String host;
  final String port;
  final String databaseName;
  final String username;
  final bool isConnected;

  const DbConnection({
    required this.id,
    required this.name,
    required this.dialect,
    required this.host,
    required this.port,
    required this.databaseName,
    required this.username,
    this.isConnected = true,
  });

  DbConnection copyWith({
    String? id,
    String? name,
    DbDialect? dialect,
    String? host,
    String? port,
    String? databaseName,
    String? username,
    bool? isConnected,
  }) {
    return DbConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      dialect: dialect ?? this.dialect,
      host: host ?? this.host,
      port: port ?? this.port,
      databaseName: databaseName ?? this.databaseName,
      username: username ?? this.username,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ColumnInfo {
  final String name;
  final String type;
  final bool isPrimaryKey;
  final bool isNullable;

  const ColumnInfo({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isNullable = true,
  });
}

class TableSchema {
  final String name;
  final int rowCount;
  final List<ColumnInfo> columns;

  const TableSchema({
    required this.name,
    required this.rowCount,
    required this.columns,
  });
}

class QueryResult {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final int executionTimeMs;

  const QueryResult({
    required this.columns,
    required this.rows,
    required this.executionTimeMs,
  });
}

class QueryRecord {
  final String id;
  final String prompt;
  final String sql;
  final String explanation;
  final QueryResult? result;
  final DateTime timestamp;
  final bool isFavorite;

  const QueryRecord({
    required this.id,
    required this.prompt,
    required this.sql,
    required this.explanation,
    this.result,
    required this.timestamp,
    this.isFavorite = false,
  });

  QueryRecord copyWith({
    String? id,
    String? prompt,
    String? sql,
    String? explanation,
    QueryResult? result,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return QueryRecord(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      sql: sql ?? this.sql,
      explanation: explanation ?? this.explanation,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
