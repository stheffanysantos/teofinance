import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/status/sync_status.dart';

/// Único ponto de acesso às tabelas drift para esta entidade.
class NomeEntidadeLocalDataSource {
  NomeEntidadeLocalDataSource({required this.db});

  final AppDatabase db;

  Future<List<NomeEntidadeRow>> obterTodas() => db.select(db.nomeEntidades).get();

  Future<NomeEntidadeRow?> obterPorIdLocal(int idLocal) =>
      (db.select(db.nomeEntidades)..where((t) => t.idLocal.equals(idLocal))).getSingleOrNull();

  Future<List<NomeEntidadeRow>> obterPendentes() => (db.select(db.nomeEntidades)
        ..where((t) => t.syncStatus.equalsValue(SyncStatus.pendingCreate) |
            t.syncStatus.equalsValue(SyncStatus.pendingUpdate)))
      .get();

  Future<int> inserirOuAtualizar(NomeEntidadesCompanion companion) =>
      db.into(db.nomeEntidades).insertOnConflictUpdate(companion);

  Future<void> marcarSincronizado(int idLocal, String idRemoto) =>
      (db.update(db.nomeEntidades)..where((t) => t.idLocal.equals(idLocal))).write(
        NomeEntidadesCompanion(
          idRemoto: Value(idRemoto),
          syncStatus: const Value(SyncStatus.synced),
        ),
      );

  Future<void> excluir(int idLocal) =>
      (db.delete(db.nomeEntidades)..where((t) => t.idLocal.equals(idLocal))).go();
}
