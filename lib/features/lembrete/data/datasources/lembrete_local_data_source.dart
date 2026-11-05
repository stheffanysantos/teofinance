import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/database/sync_sql.dart';
import 'package:teofinance/core/database/tabelas_locais.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:uuid/uuid.dart';

/// Única classe da feature que fala com `lembretes_personalizados`
/// (tabela criada por SQL em `core/database/tabelas_locais.dart`).
class LembreteLocalDataSource {
  LembreteLocalDataSource(this._db)
      : _sync = SyncSql(_db, tabela: 'lembretes_personalizados', chave: 'id');

  final AppDatabase _db;
  final SyncSql _sync;
  static const _uuid = Uuid();

  LembretePersonalizado _doRegistro(QueryRow l) {
    return LembretePersonalizado(
      id: l.read<String>('id'),
      titulo: l.read<String>('titulo'),
      tipo: TipoLembrete.deNome(l.read<String>('tipo')),
      dia: l.read<int>('dia'),
      ativo: l.read<int>('ativo') == 1,
    );
  }

  Future<List<LembretePersonalizado>> listar() async {
    final linhas = await _db
        .customSelect(
          'SELECT * FROM lembretes_personalizados WHERE sync_status != ? ORDER BY dia, titulo',
          variables: [Variable.withInt(kSyncPendenteExclusao)],
        )
        .get();
    return linhas.map(_doRegistro).toList();
  }

  Future<void> _gravar(LembretePersonalizado l, int status) {
    return _db.customInsert(
      'INSERT OR REPLACE INTO lembretes_personalizados (id, titulo, tipo, dia, ativo, sync_status) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(l.id.isEmpty ? _uuid.v4() : l.id),
        Variable.withString(l.titulo),
        Variable.withString(l.tipo.name),
        Variable.withInt(l.dia),
        Variable.withInt(l.ativo ? 1 : 0),
        Variable.withInt(status),
      ],
    );
  }

  Future<void> salvar(LembretePersonalizado l) => _gravar(l, kSyncPendente);

  Future<void> excluir(String id) => _sync.marcarParaExcluir(id);

  Future<List<LembretePersonalizado>> listarPendentesDeSincronizacao() async {
    final linhas = await _db
        .customSelect('SELECT * FROM lembretes_personalizados WHERE sync_status = ?', variables: [Variable.withInt(kSyncPendente)])
        .get();
    return linhas.map(_doRegistro).toList();
  }

  Future<List<String>> listarPendentesDeExclusao() => _sync.chavesComStatus(kSyncPendenteExclusao);

  Future<void> confirmarSincronizacao(String id) => _sync.marcarSincronizado(id);

  Future<void> confirmarExclusao(String id) => _sync.removerDefinitivo(id);

  Future<void> aplicarRemoto(LembretePersonalizado l) async {
    if (await _sync.temPendencia(l.id)) return;
    await _gravar(l, kSyncSincronizado);
  }

  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos) => _sync.removerSincronizadosAusentes(idsRemotos);
}
