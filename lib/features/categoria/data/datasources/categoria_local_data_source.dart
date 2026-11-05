import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/database/sync_sql.dart';
import 'package:teofinance/core/database/tabelas_locais.dart';

/// Única classe da feature que fala com `categorias_personalizadas`
/// (tabela criada por SQL em `core/database/tabelas_locais.dart`).
class CategoriaLocalDataSource {
  CategoriaLocalDataSource(this._db)
    : _sync = SyncSql(_db, tabela: 'categorias_personalizadas', chave: 'nome');

  final AppDatabase _db;
  final SyncSql _sync;

  Future<List<String>> listar() async {
    final linhas = await _db
        .customSelect(
          'SELECT nome FROM categorias_personalizadas WHERE sync_status != ? ORDER BY nome COLLATE NOCASE',
          variables: [Variable.withInt(kSyncPendenteExclusao)],
        )
        .get();
    return linhas.map((l) => l.read<String>('nome')).toList();
  }

  Future<void> adicionar(String nome) {
    return _db.customInsert(
      'INSERT OR REPLACE INTO categorias_personalizadas (nome, sync_status) VALUES (?, ?)',
      variables: [Variable.withString(nome), Variable.withInt(kSyncPendente)],
    );
  }

  Future<void> remover(String nome) => _sync.marcarParaExcluir(nome);

  Future<List<String>> listarPendentesDeSincronizacao() =>
      _sync.chavesComStatus(kSyncPendente);

  Future<List<String>> listarPendentesDeExclusao() =>
      _sync.chavesComStatus(kSyncPendenteExclusao);

  Future<void> confirmarSincronizacao(String nome) =>
      _sync.marcarSincronizado(nome);

  Future<void> confirmarExclusao(String nome) => _sync.removerDefinitivo(nome);

  Future<void> aplicarRemoto(String nome) async {
    if (await _sync.temPendencia(nome)) return;
    await _db.customInsert(
      'INSERT OR REPLACE INTO categorias_personalizadas (nome, sync_status) VALUES (?, ?)',
      variables: [
        Variable.withString(nome),
        Variable.withInt(kSyncSincronizado),
      ],
    );
  }

  Future<void> removerAusentesNoRemoto(Set<String> nomesRemotos) =>
      _sync.removerSincronizadosAusentes(nomesRemotos);
}
