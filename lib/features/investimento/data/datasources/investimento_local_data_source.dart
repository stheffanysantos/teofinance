import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/database/sync_sql.dart';
import 'package:teofinance/core/database/tabelas_locais.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';

/// Única classe da feature que fala com `investimentos_manuais`
/// (tabela criada por SQL em `core/database/tabelas_locais.dart`).
class InvestimentoLocalDataSource {
  InvestimentoLocalDataSource(this._db)
      : _sync = SyncSql(_db, tabela: 'investimentos_manuais', chave: 'id');

  final AppDatabase _db;
  final SyncSql _sync;

  Investimento _doRegistro(QueryRow l) {
    return Investimento(
      id: l.read<String>('id'),
      nome: l.read<String>('nome'),
      tipo: TipoInvestimento.deNome(l.read<String>('tipo')),
      valorInvestido: l.read<double>('valor_investido'),
      valorAtual: l.read<double>('valor_atual'),
      dataAplicacao: DateTime.fromMillisecondsSinceEpoch(l.read<int>('data_aplicacao')),
      observacao: l.read<String>('observacao'),
    );
  }

  Future<List<Investimento>> listar() async {
    final linhas = await _db
        .customSelect(
          'SELECT * FROM investimentos_manuais WHERE sync_status != ? ORDER BY data_aplicacao DESC',
          variables: [Variable.withInt(kSyncPendenteExclusao)],
        )
        .get();
    return linhas.map(_doRegistro).toList();
  }

  Future<void> _gravar(Investimento i, int status) {
    return _db.customInsert(
      'INSERT OR REPLACE INTO investimentos_manuais '
      '(id, nome, tipo, valor_investido, valor_atual, data_aplicacao, observacao, sync_status) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(i.id),
        Variable.withString(i.nome),
        Variable.withString(i.tipo.name),
        Variable.withReal(i.valorInvestido),
        Variable.withReal(i.valorAtual),
        Variable.withInt(i.dataAplicacao.millisecondsSinceEpoch),
        Variable.withString(i.observacao),
        Variable.withInt(status),
      ],
    );
  }

  Future<void> salvar(Investimento i) => _gravar(i, kSyncPendente);

  Future<void> excluir(String id) => _sync.marcarParaExcluir(id);

  Future<List<Investimento>> listarPendentesDeSincronizacao() async {
    final linhas = await _db
        .customSelect('SELECT * FROM investimentos_manuais WHERE sync_status = ?', variables: [Variable.withInt(kSyncPendente)])
        .get();
    return linhas.map(_doRegistro).toList();
  }

  Future<List<String>> listarPendentesDeExclusao() => _sync.chavesComStatus(kSyncPendenteExclusao);

  Future<void> confirmarSincronizacao(String id) => _sync.marcarSincronizado(id);

  Future<void> confirmarExclusao(String id) => _sync.removerDefinitivo(id);

  Future<void> aplicarRemoto(Investimento i) async {
    if (await _sync.temPendencia(i.id)) return;
    await _gravar(i, kSyncSincronizado);
  }

  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos) => _sync.removerSincronizadosAusentes(idsRemotos);
}
