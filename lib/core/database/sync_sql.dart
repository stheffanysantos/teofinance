import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/database/tabelas_locais.dart';

/// Operações de sincronização comuns às tabelas criadas por SQL direto
/// (`tabelas_locais.dart`). [tabela] e [chave] são constantes do código, nunca
/// entrada do usuário.
class SyncSql {
  const SyncSql(this._db, {required this.tabela, required this.chave});

  final AppDatabase _db;
  final String tabela;

  /// Coluna da chave primária (texto).
  final String chave;

  Future<List<String>> chavesComStatus(int status) async {
    final linhas = await _db
        .customSelect('SELECT $chave AS k FROM $tabela WHERE sync_status = ?', variables: [Variable.withInt(status)])
        .get();
    return linhas.map((l) => l.read<String>('k')).toList();
  }

  Future<bool> temPendencia(String valor) async {
    final linhas = await _db
        .customSelect(
          'SELECT 1 AS x FROM $tabela WHERE $chave = ? AND sync_status != ?',
          variables: [Variable.withString(valor), Variable.withInt(kSyncSincronizado)],
        )
        .get();
    return linhas.isNotEmpty;
  }

  Future<void> marcarSincronizado(String valor) => _atualizarStatus(valor, kSyncSincronizado);

  Future<void> marcarParaExcluir(String valor) => _atualizarStatus(valor, kSyncPendenteExclusao);

  Future<void> removerDefinitivo(String valor) {
    return _db.customUpdate(
      'DELETE FROM $tabela WHERE $chave = ?',
      variables: [Variable.withString(valor)],
      updates: {},
    );
  }

  /// Remove as linhas já sincronizadas que não existem mais no Firestore
  /// (apagadas em outro aparelho). Linhas pendentes nunca são tocadas.
  Future<void> removerSincronizadosAusentes(Set<String> chavesRemotas) async {
    for (final k in await chavesComStatus(kSyncSincronizado)) {
      if (!chavesRemotas.contains(k)) await removerDefinitivo(k);
    }
  }

  Future<void> _atualizarStatus(String valor, int status) {
    return _db.customUpdate(
      'UPDATE $tabela SET sync_status = ? WHERE $chave = ?',
      variables: [Variable.withInt(status), Variable.withString(valor)],
      updates: {},
    );
  }
}
