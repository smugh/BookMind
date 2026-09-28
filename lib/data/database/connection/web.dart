import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection(
    LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: 'bookmind',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
