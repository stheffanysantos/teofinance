import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/database/sync_sql.dart';
import 'package:teofinance/core/database/tabelas_locais.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:uuid/uuid.dart';

/// Única classe da feature que fala com `cartoes` e `faturas_pagas`
/// (tabelas criadas por SQL em `core/database/tabelas_locais.dart`).
class CartaoLocalDataSource {
  CartaoLocalDataSource(this._db)
      : _syncCartoes = SyncSql(_db, tabela: 'cartoes', chave: 'id'),
        _syncPagamentos = SyncSql(_db, tabela: 'faturas_pagas', chave: 'id');

  final AppDatabase _db;
  final SyncSql _syncCartoes;
  final SyncSql _syncPagamentos;
  static const _uuid = Uuid();

  // ------------------------------------------------------------- cartões

  Cartao _cartao(QueryRow l) => Cartao(
        id: l.read<String>('id'),
        nome: l.read<String>('nome'),
        diaFechamento: l.read<int>('dia_fechamento'),
        diaVencimento: l.read<int>('dia_vencimento'),
        limite: l.read<double?>('limite'),
      );

  Future<List<Cartao>> listarCartoes() async {
    final linhas = await _db
        .customSelect('SELECT * FROM cartoes WHERE sync_status != ? ORDER BY nome COLLATE NOCASE',
            variables: [Variable.withInt(kSyncPendenteExclusao)])
        .get();
    return linhas.map(_cartao).toList();
  }

  Future<void> _gravarCartao(Cartao c, int status) {
    return _db.customInsert(
      'INSERT OR REPLACE INTO cartoes (id, nome, dia_fechamento, dia_vencimento, limite, sync_status) VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(c.id.isEmpty ? _uuid.v4() : c.id),
        Variable.withString(c.nome),
        Variable.withInt(c.diaFechamento),
        Variable.withInt(c.diaVencimento),
        c.limite == null ? const Variable<double>(null) : Variable.withReal(c.limite!),
        Variable.withInt(status),
      ],
    );
  }

  Future<void> salvarCartao(Cartao c) => _gravarCartao(c, kSyncPendente);

  Future<void> excluirCartao(String id) => _syncCartoes.marcarParaExcluir(id);

  Future<List<Cartao>> cartoesPendentes() async {
    final linhas = await _db
        .customSelect('SELECT * FROM cartoes WHERE sync_status = ?', variables: [Variable.withInt(kSyncPendente)])
        .get();
    return linhas.map(_cartao).toList();
  }

  Future<List<String>> cartoesPendentesDeExclusao() => _syncCartoes.chavesComStatus(kSyncPendenteExclusao);
  Future<void> confirmarCartao(String id) => _syncCartoes.marcarSincronizado(id);
  Future<void> confirmarExclusaoCartao(String id) => _syncCartoes.removerDefinitivo(id);

  Future<void> aplicarCartaoRemoto(Cartao c) async {
    if (await _syncCartoes.temPendencia(c.id)) return;
    await _gravarCartao(c, kSyncSincronizado);
  }

  Future<void> removerCartoesAusentes(Set<String> ids) => _syncCartoes.removerSincronizadosAusentes(ids);

  // ---------------------------------------------------------- pagamentos

  FaturaPaga _pagamento(QueryRow l) => FaturaPaga(
        cartaoId: l.read<String>('cartao_id'),
        ano: l.read<int>('ano'),
        mes: l.read<int>('mes'),
        valor: l.read<double>('valor'),
        dataPagamento: DateTime.fromMillisecondsSinceEpoch(l.read<int>('data_pagamento')),
      );

  Future<List<FaturaPaga>> listarPagamentos() async {
    final linhas = await _db
        .customSelect('SELECT * FROM faturas_pagas WHERE sync_status != ?',
            variables: [Variable.withInt(kSyncPendenteExclusao)])
        .get();
    return linhas.map(_pagamento).toList();
  }

  Future<void> _gravarPagamento(FaturaPaga p, int status) {
    return _db.customInsert(
      'INSERT OR REPLACE INTO faturas_pagas (id, cartao_id, ano, mes, valor, data_pagamento, sync_status) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(p.id),
        Variable.withString(p.cartaoId),
        Variable.withInt(p.ano),
        Variable.withInt(p.mes),
        Variable.withReal(p.valor),
        Variable.withInt(p.dataPagamento.millisecondsSinceEpoch),
        Variable.withInt(status),
      ],
    );
  }

  Future<void> registrarPagamento(FaturaPaga p) => _gravarPagamento(p, kSyncPendente);

  Future<void> desfazerPagamento(String id) => _syncPagamentos.marcarParaExcluir(id);

  Future<List<FaturaPaga>> pagamentosPendentes() async {
    final linhas = await _db
        .customSelect('SELECT * FROM faturas_pagas WHERE sync_status = ?', variables: [Variable.withInt(kSyncPendente)])
        .get();
    return linhas.map(_pagamento).toList();
  }

  Future<List<String>> pagamentosPendentesDeExclusao() => _syncPagamentos.chavesComStatus(kSyncPendenteExclusao);
  Future<void> confirmarPagamento(String id) => _syncPagamentos.marcarSincronizado(id);
  Future<void> confirmarExclusaoPagamento(String id) => _syncPagamentos.removerDefinitivo(id);

  Future<void> aplicarPagamentoRemoto(FaturaPaga p) async {
    if (await _syncPagamentos.temPendencia(p.id)) return;
    await _gravarPagamento(p, kSyncSincronizado);
  }

  Future<void> removerPagamentosAusentes(Set<String> ids) => _syncPagamentos.removerSincronizadosAusentes(ids);
}
