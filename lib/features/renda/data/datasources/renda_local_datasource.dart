import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/renda.dart';

/// Única classe da feature que fala com `RendaTable` (ver
/// `.claude/rules/architecture.md`).
class RendaLocalDataSource {
  RendaLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Renda>> observarTodas() {
    final query = _db.select(_db.rendaTable)
      ..orderBy([(r) => OrderingTerm.desc(r.dataRecebimento)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<Renda> criar({
    required String descricao,
    required double valor,
    required TipoRenda tipo,
    required DateTime dataRecebimento,
    RecorrenciaRenda? recorrencia,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.rendaTable).insert(
          RendaTableCompanion.insert(
            id: id,
            descricao: descricao,
            valor: valor,
            tipo: tipo.name,
            dataRecebimento: dataRecebimento,
            recorrencia: Value(recorrencia?.name),
          ),
        );
    return Renda(
      id: id,
      descricao: descricao,
      valor: valor,
      tipo: tipo,
      dataRecebimento: dataRecebimento,
      recorrencia: recorrencia,
    );
  }

  Future<void> definirAtiva({required String id, required bool ativa}) {
    return (_db.update(_db.rendaTable)..where((r) => r.id.equals(id))).write(
      RendaTableCompanion(
        ativa: Value(ativa),
        syncStatus: const Value(SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> excluir(String id) {
    return (_db.delete(_db.rendaTable)..where((r) => r.id.equals(id))).go();
  }

  Future<List<Renda>> listarPendentes() async {
    final linhas = await (_db.select(_db.rendaTable)
          ..where((r) => r.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              r.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.rendaTable)..where((r) => r.id.equals(id))).write(
      RendaTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  Future<void> aplicarRemoto(Renda renda) async {
    final existente = renda.remoteId == null
        ? null
        : await (_db.select(_db.rendaTable)..where((r) => r.remoteId.equals(renda.remoteId!)))
            .getSingleOrNull();

    if (existente != null && existente.syncStatus != SyncStatus.synced) {
      return;
    }

    final id = existente?.id ?? _uuid.v4();
    await _db.into(_db.rendaTable).insertOnConflictUpdate(
          RendaTableCompanion.insert(
            id: id,
            remoteId: Value(renda.remoteId),
            descricao: renda.descricao,
            valor: renda.valor,
            tipo: renda.tipo.name,
            dataRecebimento: renda.dataRecebimento,
            recorrencia: Value(renda.recorrencia?.name),
            ativa: Value(renda.ativa),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  Renda _paraEntidade(RendaTableData linha) {
    return Renda(
      id: linha.id,
      descricao: linha.descricao,
      valor: linha.valor,
      tipo: TipoRenda.values.byName(linha.tipo),
      dataRecebimento: linha.dataRecebimento,
      recorrencia: linha.recorrencia != null
          ? RecorrenciaRenda.values.byName(linha.recorrencia!)
          : null,
      ativa: linha.ativa,
      remoteId: linha.remoteId,
      syncStatus: linha.syncStatus,
    );
  }
}
