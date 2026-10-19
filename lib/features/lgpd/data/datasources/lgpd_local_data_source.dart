import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teofinance/core/database/app_database.dart';

/// Nome de cada tabela interna no arquivo exportado, em português e estável.
const _nomesExportados = {
  'transactions_table': 'transacoes',
  'perfil_banco_table': 'perfis_banco',
  'renda_table': 'rendas',
  'meta_table': 'metas',
  'parcelamento_table': 'parcelamentos',
  'orcamento_table': 'orcamentos',
  'conta_table': 'contas',
  'extrato_linhas_table': 'extrato_linhas',
  'reconciliation_matches_table': 'reconciliacao_vinculos',
};

/// Única classe da feature que lê/apaga as tabelas do drift e o armazenamento
/// seguro (ver `.claude/rules/architecture.md`).
class LgpdLocalDataSource {
  LgpdLocalDataSource(this._db, this._secureStorage);

  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;

  /// Todas as tabelas, linha a linha, com datas em texto ISO. Percorrer
  /// `allTables` garante que uma tabela nova entre na exportação sozinha.
  Future<Map<String, List<Map<String, dynamic>>>> exportarTudo() async {
    const serializador = ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
    final tudo = <String, List<Map<String, dynamic>>>{};

    for (final tabela in _db.allTables) {
      final linhas = await _db.select(tabela).get();
      tudo[_nomesExportados[tabela.actualTableName] ?? tabela.actualTableName] =
          linhas.map((l) => (l as DataClass).toJson(serializer: serializador)).toList();
    }
    return tudo;
  }

  /// Esvazia todas as tabelas e o armazenamento seguro (preferências, biometria).
  Future<void> apagarTudo() async {
    await _db.transaction(() async {
      for (final tabela in _db.allTables) {
        await _db.delete(tabela).go();
      }
    });
    await _secureStorage.deleteAll();
  }
}
