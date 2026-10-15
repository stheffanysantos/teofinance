import 'package:teofinance/core/database/app_database.dart';
import '../../domain/entities/reconciliation_match.dart';
import '../../domain/entities/extrato_linha.dart';

abstract class ReconciliationLocalDataSource {
  Future<List<ExtratoLinha>> salvarLinhasExtrato(List<ExtratoLinhasTableCompanion> linhas);
  Future<List<ReconciliationMatch>> salvarMatches(List<ReconciliationMatchesTableCompanion> matches);
  Future<List<ExtratoLinha>> obterLinhasExtrato(String importId);
  Future<List<ReconciliationMatch>> obterMatches(DateTime dataInicio, DateTime dataFim);
  Future<void> atualizarStatusMatch(String matchId, String novoStatus);
}

class ReconciliationLocalDataSourceImpl implements ReconciliationLocalDataSource {
  final AppDatabase _db;

  ReconciliationLocalDataSourceImpl(this._db);

  @override
  Future<List<ExtratoLinha>> salvarLinhasExtrato(
    List<ExtratoLinhasTableCompanion> linhas,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(_db.extratoLinhasTable, linhas);
    });

    return linhas
        .map((l) => ExtratoLinha(
              id: l.id.value,
              importId: l.importId.value,
              descricao: l.descricao.value,
              valor: l.valor.value,
              data: l.data.value,
              tipo: l.tipo.value,
              nomeBancoOriginal: l.nomeBancoOriginal.value,
            ))
        .toList();
  }

  @override
  Future<List<ReconciliationMatch>> salvarMatches(
    List<ReconciliationMatchesTableCompanion> matches,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(_db.reconciliationMatchesTable, matches);
    });

    return matches
        .map((m) => ReconciliationMatch(
              id: m.id.value,
              transacaoId: m.transacaoId.value,
              linhaExtratoId: m.linhaExtratoId.value,
              dataReconciliacao: m.dataReconciliacao.value,
              status: m.status.value,
              confidence: m.confidence.value,
            ))
        .toList();
  }

  @override
  Future<List<ExtratoLinha>> obterLinhasExtrato(String importId) async {
    final dados = await (_db.select(_db.extratoLinhasTable)
          ..where((t) => t.importId.equals(importId)))
        .get();

    return dados
        .map((d) => ExtratoLinha(
              id: d.id,
              importId: d.importId,
              descricao: d.descricao,
              valor: d.valor,
              data: d.data,
              tipo: d.tipo,
              nomeBancoOriginal: d.nomeBancoOriginal,
            ))
        .toList();
  }

  @override
  Future<List<ReconciliationMatch>> obterMatches(
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    final dados = await (_db.select(_db.reconciliationMatchesTable)
          ..where((m) =>
              m.dataReconciliacao.isBetweenValues(dataInicio, dataFim)))
        .get();

    return dados
        .map((d) => ReconciliationMatch(
              id: d.id,
              transacaoId: d.transacaoId,
              linhaExtratoId: d.linhaExtratoId,
              dataReconciliacao: d.dataReconciliacao,
              status: d.status,
              confidence: d.confidence,
            ))
        .toList();
  }

  @override
  Future<void> atualizarStatusMatch(String matchId, String novoStatus) async {
    await (_db.update(_db.reconciliationMatchesTable)
          ..where((m) => m.id.equals(matchId)))
        .write(ReconciliationMatchesTableCompanion(
          status: Value(novoStatus),
        ));
  }
}
