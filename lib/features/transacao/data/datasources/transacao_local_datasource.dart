import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/transacao.dart';

/// Única classe da feature que fala com `TransactionsTable` (ver
/// `.claude/rules/architecture.md`).
class TransacaoLocalDataSource {
  TransacaoLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Transacao>> observarTodas() {
    final query = _db.select(_db.transactionsTable)
      ..where((t) => t.syncStatus.equalsValue(SyncStatus.pendingDelete).not())
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<Transacao> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    required String categoria,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            id: id,
            name: descricao,
            category: categoria,
            value: valor,
            occurredAt: data,
            needsCategory: Value(categoria.trim().isEmpty),
          ),
        );
    return Transacao(id: id, descricao: descricao, categoria: categoria, valor: valor, data: data);
  }

  Future<void> categorizar({required String id, required String categoria}) {
    return (_db.update(_db.transactionsTable)..where((t) => t.id.equals(id))).write(
      TransactionsTableCompanion(
        category: Value(categoria),
        needsCategory: const Value(false),
        syncStatus: Value(SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Transação já enviada ao Firestore só é marcada (`pendingDelete`) — o
  /// `features/sync/` apaga o documento remoto e depois chama
  /// [confirmarExclusao]; sem isso o próximo pull a traria de volta.
  /// Define (ou remove, com [minhaParte] nulo) a divisão da despesa.
  Future<void> definirDivisao({
    required String id,
    required double? minhaParte,
    required List<String> divididoCom,
  }) {
    return (_db.update(_db.transactionsTable)..where((t) => t.id.equals(id))).write(
      TransactionsTableCompanion(
        minhaParte: Value(minhaParte),
        divididoCom: Value(minhaParte == null ? null : jsonEncode(divididoCom)),
        syncStatus: const Value(SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> excluir(String id) async {
    final linha = await (_db.select(_db.transactionsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (linha == null) return;

    if (linha.remoteId == null) {
      await confirmarExclusao(id);
      return;
    }
    await (_db.update(_db.transactionsTable)..where((t) => t.id.equals(id))).write(
      TransactionsTableCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> confirmarExclusao(String id) {
    return (_db.delete(_db.transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Transacao>> listarPendentesDeExclusao() async {
    final linhas = await (_db.select(_db.transactionsTable)
          ..where((t) => t.syncStatus.equalsValue(SyncStatus.pendingDelete)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  /// Transações criadas/alteradas localmente que ainda não foram enviadas
  /// (ou foram alteradas após o último envio) — consumido por `features/sync/`.
  Future<List<Transacao>> listarPendentes() async {
    final linhas = await (_db.select(_db.transactionsTable)
          ..where((t) => t.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              t.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  /// Marca como enviada com sucesso ao Firestore.
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.transactionsTable)..where((t) => t.id.equals(id))).write(
      TransactionsTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  /// Aplica um documento vindo do Firestore — só sobrescreve o registro
  /// local se ele não tiver uma escrita local pendente (o Firestore é a
  /// fonte de verdade, exceto para pendências ainda não enviadas; ver
  /// `.claude/memory/decisions.md`, decisão 0001).
  Future<void> aplicarRemoto({
    required String remoteId,
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime data,
    required bool precisaCategoria,
    double? minhaParte,
    List<String> divididoCom = const [],
  }) async {
    final existente =
        await (_db.select(_db.transactionsTable)..where((t) => t.remoteId.equals(remoteId)))
            .getSingleOrNull();

    if (existente != null && existente.syncStatus != SyncStatus.synced) {
      return; // escrita local pendente vence até ser enviada.
    }

    final id = existente?.id ?? _uuid.v4();
    await _db.into(_db.transactionsTable).insertOnConflictUpdate(
          TransactionsTableCompanion.insert(
            id: id,
            remoteId: Value(remoteId),
            name: descricao,
            category: categoria,
            value: valor,
            occurredAt: data,
            needsCategory: Value(precisaCategoria),
            minhaParte: Value(minhaParte),
            divididoCom: Value(minhaParte == null ? null : jsonEncode(divididoCom)),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  /// Cria N transações-filhas para um parcelamento (Sprint 02).
  /// Cada parcela é uma transação separada com data distribuída nos meses.
  Future<List<Transacao>> criarParcelas({
    required String parcelamentoId,
    required String descricaoOriginal,
    required String categoria,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeira,
  }) async {
    final valorParcela = totalOriginal / numeroParcelas;
    final parcelas = <Transacao>[];

    for (int i = 1; i <= numeroParcelas; i++) {
      final dataVencimento = dataPrimeira.add(Duration(days: 30 * (i - 1)));
      final id = _uuid.v4();

      await _db.into(_db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: id,
              name: '$descricaoOriginal ($i/$numeroParcelas)',
              category: categoria,
              value: valorParcela,
              occurredAt: dataVencimento,
              parcelamentoId: Value(parcelamentoId),
              numeroParcela: Value(i),
              valorParcela: Value(valorParcela),
              ehParcela: const Value(true),
              statusParcela: const Value('pendente'),
              needsCategory: Value(categoria.trim().isEmpty),
            ),
          );

      parcelas.add(
        Transacao(
          id: id,
          descricao: '$descricaoOriginal ($i/$numeroParcelas)',
          categoria: categoria,
          valor: valorParcela,
          data: dataVencimento,
          syncStatus: SyncStatus.pendingCreate,
          parcelamentoId: parcelamentoId,
          numeroParcela: i,
          valorParcela: valorParcela,
          ehParcela: true,
          statusParcela: 'pendente',
        ),
      );
    }

    return parcelas;
  }

  Future<List<Transacao>> listarPorPeriodo(DateTime inicio, DateTime fim) async {
    final linhas = await (_db.select(_db.transactionsTable)
          ..where((t) => t.occurredAt.isBetweenValues(inicio, fim) &
              t.syncStatus.equalsValue(SyncStatus.pendingDelete).not()))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  /// Obtém transação por ID (usado para validações).
  Future<Transacao?> obterPorId(String id) async {
    final linha =
        await (_db.select(_db.transactionsTable)
              ..where((t) => t.id.equals(id) &
                  t.syncStatus.equalsValue(SyncStatus.pendingDelete).not()))
            .getSingleOrNull();
    return linha != null ? _paraEntidade(linha) : null;
  }

  Transacao _paraEntidade(TransactionsTableData linha) {
    return Transacao(
      id: linha.id,
      descricao: linha.name,
      categoria: linha.category,
      valor: linha.value,
      data: linha.occurredAt,
      remoteId: linha.remoteId,
      syncStatus: linha.syncStatus,
      // Campos de parcelamento (Sprint 02)
      parcelamentoId: linha.parcelamentoId,
      numeroParcela: linha.numeroParcela,
      valorParcela: linha.valorParcela,
      ehParcela: linha.ehParcela,
      statusParcela: linha.statusParcela,
      minhaParte: linha.minhaParte,
      divididoCom: linha.divididoCom == null
          ? const []
          : (jsonDecode(linha.divididoCom!) as List).cast<String>(),
    );
  }
}
