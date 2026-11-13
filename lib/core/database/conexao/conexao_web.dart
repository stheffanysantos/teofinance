import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Conexão na web: SQLite em WebAssembly, guardado no próprio navegador
/// (OPFS/IndexedDB). `sqlite3.wasm` e `drift_worker.js` ficam em `web/`.
QueryExecutor abrirConexao() {
  return LazyDatabase(() async {
    final resultado = await WasmDatabase.open(
      databaseName: 'teofinance_demo',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return resultado.resolvedExecutor;
  });
}
