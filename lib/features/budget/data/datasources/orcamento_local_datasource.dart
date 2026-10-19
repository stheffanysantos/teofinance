import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:uuid/uuid.dart';

/// Única classe da feature que fala com `OrcamentoTable`.
class OrcamentoLocalDataSource {
  OrcamentoLocalDataSource(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Orcamento>> observarTodos() {
    final query = _db.select(_db.orcamentoTable)..orderBy([(o) => OrderingTerm.asc(o.categoria)]);
    return query.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  Future<Orcamento> definirLimite({required String categoria, required double limite}) async {
    final existente = await (_db.select(_db.orcamentoTable)..where((o) => o.categoria.equals(categoria)))
        .getSingleOrNull();

    if (existente != null) {
      await (_db.update(_db.orcamentoTable)..where((o) => o.id.equals(existente.id))).write(
        OrcamentoTableCompanion(limite: Value(limite), updatedAt: Value(DateTime.now())),
      );
      return Orcamento(id: existente.id, categoria: categoria, limite: limite);
    }

    final id = _uuid.v4();
    await _db.into(_db.orcamentoTable).insert(
          OrcamentoTableCompanion.insert(id: id, categoria: categoria, limite: limite),
        );
    return Orcamento(id: id, categoria: categoria, limite: limite);
  }

  Future<void> excluir(String id) {
    return (_db.delete(_db.orcamentoTable)..where((o) => o.id.equals(id))).go();
  }

  Orcamento _paraEntidade(OrcamentoTableData linha) {
    return Orcamento(id: linha.id, categoria: linha.categoria, limite: linha.limite);
  }
}
