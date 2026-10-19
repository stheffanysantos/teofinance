import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/sync/sync_status.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:uuid/uuid.dart';

/// Única classe da feature que fala com `OrcamentoTable`.
class OrcamentoLocalDataSource {
  OrcamentoLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Orcamento>> observarTodos() {
    final query = _db.select(_db.orcamentoTable)
      ..where((o) => o.syncStatus.equalsValue(SyncStatus.pendingDelete).not())
      ..orderBy([(o) => OrderingTerm.asc(o.categoria)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<Orcamento> definirLimite({required String categoria, required double limite}) async {
    final existente = await (_db.select(_db.orcamentoTable)..where((o) => o.categoria.equals(categoria)))
        .getSingleOrNull();

    if (existente != null) {
      // Recriar uma categoria que estava marcada para exclusão volta como
      // atualização: o documento remoto ainda existe.
      final status = existente.remoteId == null ? SyncStatus.pendingCreate : SyncStatus.pendingUpdate;
      await (_db.update(_db.orcamentoTable)..where((o) => o.id.equals(existente.id))).write(
        OrcamentoTableCompanion(
          limite: Value(limite),
          syncStatus: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Orcamento(
        id: existente.id,
        categoria: categoria,
        limite: limite,
        remoteId: existente.remoteId,
      );
    }

    final id = _uuid.v4();
    await _db.into(_db.orcamentoTable).insert(
          OrcamentoTableCompanion.insert(id: id, categoria: categoria, limite: limite),
        );
    return Orcamento(id: id, categoria: categoria, limite: limite);
  }

  /// Sem `remoteId` o limite nunca chegou ao Firestore e some de vez; com
  /// `remoteId` fica marcado para o sync apagar também o documento remoto.
  Future<void> excluir(String id) async {
    final linha = await (_db.select(_db.orcamentoTable)..where((o) => o.id.equals(id))).getSingleOrNull();
    if (linha == null) return;

    if (linha.remoteId == null) {
      await (_db.delete(_db.orcamentoTable)..where((o) => o.id.equals(id))).go();
      return;
    }
    await (_db.update(_db.orcamentoTable)..where((o) => o.id.equals(id))).write(
      OrcamentoTableCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Orcamento>> listarPendentes() async {
    final linhas = await (_db.select(_db.orcamentoTable)
          ..where((o) =>
              o.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              o.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<List<Orcamento>> listarPendentesDeExclusao() async {
    final linhas = await (_db.select(_db.orcamentoTable)
          ..where((o) => o.syncStatus.equalsValue(SyncStatus.pendingDelete)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.orcamentoTable)..where((o) => o.id.equals(id))).write(
      OrcamentoTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  Future<void> confirmarExclusao(String id) {
    return (_db.delete(_db.orcamentoTable)..where((o) => o.id.equals(id))).go();
  }

  /// Aplica um documento remoto. Escrita local pendente vence até ser enviada.
  /// A categoria é única: se já existe um limite local para ela, é ele que
  /// recebe o valor remoto (ou o mantém, se estiver pendente) em vez de duplicar.
  Future<void> aplicarRemoto({
    required String remoteId,
    required String categoria,
    required double limite,
  }) async {
    final porRemoto = await (_db.select(_db.orcamentoTable)..where((o) => o.remoteId.equals(remoteId)))
        .getSingleOrNull();
    final existente = porRemoto ??
        await (_db.select(_db.orcamentoTable)..where((o) => o.categoria.equals(categoria)))
            .getSingleOrNull();

    if (existente != null && existente.syncStatus != SyncStatus.synced) return;

    if (existente == null) {
      await _db.into(_db.orcamentoTable).insert(
            OrcamentoTableCompanion.insert(
              id: _uuid.v4(),
              categoria: categoria,
              limite: limite,
              remoteId: Value(remoteId),
              syncStatus: const Value(SyncStatus.synced),
            ),
          );
      return;
    }

    await (_db.update(_db.orcamentoTable)..where((o) => o.id.equals(existente.id))).write(
      OrcamentoTableCompanion(
        remoteId: Value(remoteId),
        categoria: Value(categoria),
        limite: Value(limite),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  Orcamento _paraEntidade(OrcamentoTableData linha) {
    return Orcamento(
      id: linha.id,
      categoria: linha.categoria,
      limite: linha.limite,
      remoteId: linha.remoteId,
    );
  }
}
