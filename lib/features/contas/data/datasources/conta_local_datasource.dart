import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/sync/sync_status.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:uuid/uuid.dart';

/// Única classe da feature que fala com `ContaTable`.
class ContaLocalDataSource {
  ContaLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<ContaAPagar>> observarTodas() {
    final query = _db.select(_db.contaTable)
      ..where((c) => c.syncStatus.equalsValue(SyncStatus.pendingDelete).not())
      ..orderBy([(c) => OrderingTerm.asc(c.vencimento)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<ContaAPagar> criar({
    required String descricao,
    required double valor,
    required DateTime vencimento,
    required String categoria,
    required RecorrenciaConta recorrencia,
    required int diasAntesLembrete,
    int? diaBase,
  }) async {
    final id = _uuid.v4();
    final dia = soDia(vencimento);
    await _db.into(_db.contaTable).insert(
          ContaTableCompanion.insert(
            id: id,
            descricao: descricao,
            valor: valor,
            vencimento: dia,
            diaBase: diaBase ?? dia.day,
            categoria: Value(categoria),
            recorrencia: Value(recorrencia.name),
            diasAntesLembrete: Value(diasAntesLembrete),
          ),
        );
    return ContaAPagar(
      id: id,
      descricao: descricao,
      valor: valor,
      vencimento: dia,
      diaBase: diaBase ?? dia.day,
      categoria: categoria,
      recorrencia: recorrencia,
      diasAntesLembrete: diasAntesLembrete,
    );
  }

  Future<ContaAPagar?> obter(String id) async {
    final linha = await (_db.select(_db.contaTable)..where((c) => c.id.equals(id))).getSingleOrNull();
    return linha == null ? null : _paraEntidade(linha);
  }

  Future<void> atualizar(ContaAPagar conta) {
    return (_db.update(_db.contaTable)..where((c) => c.id.equals(conta.id))).write(
      ContaTableCompanion(
        descricao: Value(conta.descricao),
        categoria: Value(conta.categoria),
        valor: Value(conta.valor),
        vencimento: Value(soDia(conta.vencimento)),
        diaBase: Value(conta.diaBase),
        recorrencia: Value(conta.recorrencia.name),
        diasAntesLembrete: Value(conta.diasAntesLembrete),
        syncStatus: Value(conta.remoteId == null ? SyncStatus.pendingCreate : SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> marcarComoPaga({
    required String id,
    required double valorPago,
    required DateTime dataPagamento,
    String? transacaoId,
  }) async {
    final linha = await (_db.select(_db.contaTable)..where((c) => c.id.equals(id))).getSingle();
    await (_db.update(_db.contaTable)..where((c) => c.id.equals(id))).write(
      ContaTableCompanion(
        paga: const Value(true),
        valorPago: Value(valorPago),
        dataPagamento: Value(dataPagamento),
        transacaoId: Value(transacaoId),
        syncStatus: Value(linha.remoteId == null ? SyncStatus.pendingCreate : SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Sem `remoteId` a conta nunca chegou ao Firestore e some de vez; com
  /// `remoteId` fica marcada para o sync apagar o documento remoto (senão o
  /// próximo pull a traria de volta).
  Future<void> excluir(String id) async {
    final linha = await (_db.select(_db.contaTable)..where((c) => c.id.equals(id))).getSingleOrNull();
    if (linha == null) return;

    if (linha.remoteId == null) {
      await (_db.delete(_db.contaTable)..where((c) => c.id.equals(id))).go();
      return;
    }
    await (_db.update(_db.contaTable)..where((c) => c.id.equals(id))).write(
      ContaTableCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ContaAPagar>> listarPendentes() async {
    final linhas = await (_db.select(_db.contaTable)
          ..where((c) =>
              c.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              c.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<List<ContaAPagar>> listarPendentesDeExclusao() async {
    final linhas = await (_db.select(_db.contaTable)
          ..where((c) => c.syncStatus.equalsValue(SyncStatus.pendingDelete)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.contaTable)..where((c) => c.id.equals(id))).write(
      ContaTableCompanion(remoteId: Value(remoteId), syncStatus: const Value(SyncStatus.synced)),
    );
  }

  Future<void> confirmarExclusao(String id) {
    return (_db.delete(_db.contaTable)..where((c) => c.id.equals(id))).go();
  }

  /// Aplica um documento remoto. Escrita local pendente vence até ser enviada.
  Future<void> aplicarRemoto(ContaAPagar conta) async {
    final porRemoto = conta.remoteId == null
        ? null
        : await (_db.select(_db.contaTable)..where((c) => c.remoteId.equals(conta.remoteId!)))
            .getSingleOrNull();

    if (porRemoto != null && porRemoto.syncStatus != SyncStatus.synced) return;

    await _db.into(_db.contaTable).insertOnConflictUpdate(
          ContaTableCompanion.insert(
            id: porRemoto?.id ?? _uuid.v4(),
            remoteId: Value(conta.remoteId),
            descricao: conta.descricao,
            categoria: Value(conta.categoria),
            valor: conta.valor,
            vencimento: soDia(conta.vencimento),
            diaBase: conta.diaBase,
            recorrencia: Value(conta.recorrencia.name),
            paga: Value(conta.paga),
            dataPagamento: Value(conta.dataPagamento),
            valorPago: Value(conta.valorPago),
            diasAntesLembrete: Value(conta.diasAntesLembrete),
            transacaoId: Value(conta.transacaoId),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  ContaAPagar _paraEntidade(ContaTableData l) {
    return ContaAPagar(
      id: l.id,
      remoteId: l.remoteId,
      descricao: l.descricao,
      categoria: l.categoria,
      valor: l.valor,
      vencimento: l.vencimento,
      diaBase: l.diaBase,
      recorrencia: RecorrenciaConta.values.asNameMap()[l.recorrencia] ?? RecorrenciaConta.nenhuma,
      paga: l.paga,
      dataPagamento: l.dataPagamento,
      valorPago: l.valorPago,
      diasAntesLembrete: l.diasAntesLembrete,
      transacaoId: l.transacaoId,
      syncStatus: l.syncStatus,
    );
  }
}
