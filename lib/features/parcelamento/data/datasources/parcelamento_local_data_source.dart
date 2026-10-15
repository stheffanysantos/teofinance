import 'package:drift/drift.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/parcelamento/data/models/parcelamento_model.dart';

abstract class ParcelamentoLocalDataSource {
  Future<void> salvarParcelamento(ParcelamentoModel parcelamento);
  Future<List<ParcelamentoModel>> listarPorUsuario(String userId);
  Future<ParcelamentoModel?> obterPorId(String parcelamentoId);
  Future<void> deletarParcelamento(String parcelamentoId);
}

class ParcelamentoLocalDataSourceImpl implements ParcelamentoLocalDataSource {
  final AppDatabase database;

  ParcelamentoLocalDataSourceImpl(this.database);

  @override
  Future<void> salvarParcelamento(ParcelamentoModel parcelamento) async {
    await database.into(database.parcelamentoTable).insert(
          parcelamento.toDriftCompanion(),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<List<ParcelamentoModel>> listarPorUsuario(String userId) async {
    // Nota: ParcelamentoTable não tem userId diretamente.
    // Precisamos buscar via FK (transacaoOriginalId) na TransactionsTable.
    // Por enquanto, retornamos todos os parcelamentos.
    // TODO: Melhorar query para filtrar por userId quando tivermos relacionamento explícito.
    final dados = await database.select(database.parcelamentoTable).get();
    return dados.map(ParcelamentoModel.fromDriftData).toList();
  }

  @override
  Future<ParcelamentoModel?> obterPorId(String parcelamentoId) async {
    final dado = await (database.select(database.parcelamentoTable)
          ..where((tbl) => tbl.id.equals(parcelamentoId)))
        .getSingleOrNull();

    return dado != null ? ParcelamentoModel.fromDriftData(dado) : null;
  }

  @override
  Future<void> deletarParcelamento(String parcelamentoId) async {
    await (database.delete(database.parcelamentoTable)
          ..where((tbl) => tbl.id.equals(parcelamentoId)))
        .go();
  }
}
