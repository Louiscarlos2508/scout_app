// Stub file for non-web platforms
// This file is used when dart.library.io is available (mobile/desktop)
// It provides a dummy WasmDatabase class to satisfy the import

import 'package:drift/drift.dart';

/// Stub class for non-web platforms
class WasmDatabase {
  static Future<WasmDatabaseResult> open({
    required String databaseName,
    required Uri sqlite3Uri,
    required Uri driftWorkerUri,
  }) {
    throw UnsupportedError('WasmDatabase is only available on web');
  }
}

/// Stub result class
class WasmDatabaseResult {
  QueryExecutor get resolvedExecutor {
    throw UnsupportedError('WasmDatabase is only available on web');
  }
}
