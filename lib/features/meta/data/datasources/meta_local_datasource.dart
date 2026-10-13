import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/meta.dart';

/// Única classe da feature que fala com `MetaTable` (ver
/// `.claude/rules/architecture.md`).
class MetaLocalDataSource {
  MetaLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Meta>> observarTodas() {
    final query = _db.select(_db.metaTable)..orderBy([(m) => OrderingTerm.asc(m.prazo)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<Meta> criar({
    required String nome,
    required double valorAlvo,
    required DateTime prazo,
    required double valorAtual,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.metaTable).insert(
          MetaTableCompanion.insert(
            id: id,
            nome: nome,
            valorAlvo: valorAlvo,
            prazo: prazo,
            valorAtual: Value(valorAtual),
          ),
        );
    return Meta(id: id, nome: nome, valorAtual: valorAtual, valorAlvo: valorAlvo, prazo: prazo);
  }

  Future<void> aportar({required String id, required double valor}) async {
    final atual = await (_db.select(_db.metaTable)..where((m) => m.id.equals(id))).getSingle();
    await (_db.update(_db.metaTable)..where((m) => m.id.equals(id))).write(
      MetaTableCompanion(
        valorAtual: Value(atual.valorAtual + valor),
        syncStatus: const Value(SyncStatus.pendingUpdate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> excluir(String id) {
    return (_db.delete(_db.metaTable)..where((m) => m.id.equals(id))).go();
  }

  Future<List<Meta>> listarPendentes() async {
    final linhas = await (_db.select(_db.metaTable)
          ..where((m) => m.syncStatus.equalsValue(SyncStatus.pendingCreate) |
              m.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
        .get();
    return linhas.map(_paraEntidade).toList();
  }

  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return (_db.update(_db.metaTable)..where((m) => m.id.equals(id))).write(
      MetaTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  }

  Future<void> aplicarRemoto(Meta meta) async {
    final existente = meta.remoteId == null
        ? null
        : await (_db.select(_db.metaTable)..where((m) => m.remoteId.equals(meta.remoteId!)))
            .getSingleOrNull();

    if (existente != null && existente.syncStatus != SyncStatus.synced) {
      return;
    }

    final id = existente?.id ?? _uuid.v4();
    await _db.into(_db.metaTable).insertOnConflictUpdate(
          MetaTableCompanion.insert(
            id: id,
            remoteId: Value(meta.remoteId),
            nome: meta.nome,
            valorAlvo: meta.valorAlvo,
            prazo: meta.prazo,
            valorAtual: Value(meta.valorAtual),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  Meta _paraEntidade(MetaTableData linha) {
    return Meta(
      id: linha.id,
      nome: linha.nome,
      valorAtual: linha.valorAtual,
      valorAlvo: linha.valorAlvo,
      prazo: linha.prazo,
      remoteId: linha.remoteId,
      syncStatus: linha.syncStatus,
    );
  }
}
