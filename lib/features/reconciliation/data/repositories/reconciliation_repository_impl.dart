import 'package:drift/drift.dart' as drift;
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/errors/failure.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../../domain/entities/reconciliation_match.dart';
import '../../domain/entities/extrato_linha.dart';
import '../datasources/reconciliation_local_data_source.dart';
import '../services/transacao_matcher_service.dart';
import '../../../transacao/data/datasources/transacao_local_datasource.dart';

class ReconciliationRepositoryImpl implements ReconciliationRepository {
  final ReconciliationLocalDataSource _local;
  final TransacaoLocalDataSource _transacaoLocal;
  final TransacaoMatcherService _matcher;

  ReconciliationRepositoryImpl(
    this._local,
    this._transacaoLocal,
    this._matcher,
  );

  @override
  Future<Either<Failure, List<ExtratoLinha>>> importarExtrato({
    required String importId,
    required List<Map<String, dynamic>> linhas,
  }) async {
    try {
      final companions = linhas
          .asMap()
          .entries
          .map((e) => ExtratoLinhasTableCompanion(
                id: drift.Value(const Uuid().v4()),
                importId: drift.Value(importId),
                descricao: drift.Value(e.value['descricao'] ?? ''),
                valor: drift.Value(double.parse(e.value['valor'].toString())),
                data: drift.Value(DateTime.parse(e.value['data'].toString())),
                tipo: drift.Value(e.value['tipo'] ?? 'D'),
                nomeBancoOriginal: drift.Value(e.value['nomeBancoOriginal'] ?? ''),
              ))
          .toList();

      final result = await _local.salvarLinhasExtrato(companions);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReconciliationResultado>> fazerMatching({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final transacoes = await _transacaoLocal.listarPorPeriodo(dataInicio, dataFim);
      final linhas = await _local.obterLinhasPorPeriodo(dataInicio, dataFim);

      // Aprovações manuais sobrevivem a uma nova execução; o resto é recalculado.
      final existentes = await _local.obterMatchesPorLinhas(linhas.map((l) => l.id).toList());
      final aprovados = existentes.where((m) => m.status == 'manual_matched').toList();
      final rejeitados = existentes
          .where((m) => m.status == 'rejected')
          .map((m) => '${m.transacaoId}|${m.linhaExtratoId}')
          .toSet();
      await _local.removerMatches(
        existentes
            .where((m) => m.status != 'manual_matched' && m.status != 'rejected')
            .map((m) => m.id)
            .toList(),
      );

      final linhasUsadas = aprovados.map((m) => m.linhaExtratoId).toSet();
      final transacoesUsadas = aprovados.map((m) => m.transacaoId).whereType<String>().toSet();

      final candidatos = _matcher.encontrarMatches(
        transacoes: transacoes.where((t) => !transacoesUsadas.contains(t.id)).toList(),
        linhasExtrato: linhas.where((l) => !linhasUsadas.contains(l.id)).toList(),
      );

      // Casamento um-para-um, do mais confiável para o menos.
      final companions = <ReconciliationMatchesTableCompanion>[];
      for (final (txn, linha, confidence) in candidatos) {
        if (linhasUsadas.contains(linha.id) || transacoesUsadas.contains(txn.id)) continue;
        if (rejeitados.contains('${txn.id}|${linha.id}')) continue;
        linhasUsadas.add(linha.id);
        transacoesUsadas.add(txn.id);
        companions.add(ReconciliationMatchesTableCompanion(
          id: drift.Value(const Uuid().v4()),
          transacaoId: drift.Value(txn.id),
          linhaExtratoId: drift.Value(linha.id),
          dataReconciliacao: drift.Value(DateTime.now()),
          status: drift.Value(confidence >= 0.95 ? 'auto_matched' : 'unmatched'),
          confidence: drift.Value(confidence),
        ));
      }

      for (final linha in linhas) {
        if (linhasUsadas.contains(linha.id)) continue;
        companions.add(ReconciliationMatchesTableCompanion(
          id: drift.Value(const Uuid().v4()),
          transacaoId: const drift.Value(null),
          linhaExtratoId: drift.Value(linha.id),
          dataReconciliacao: drift.Value(DateTime.now()),
          status: const drift.Value('orphan'),
          confidence: const drift.Value(0.0),
        ));
      }

      final novos = await _local.salvarMatches(companions);

      return Right(ReconciliationResultado(
        matches: [...aprovados, ...novos],
        linhas: {for (final l in linhas) l.id: l},
        transacoes: {for (final t in transacoes) t.id: t},
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> aprovarMatch(String matchId) async {
    try {
      await _local.atualizarStatusMatch(matchId, 'manual_matched');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejeitarMatch(String matchId) async {
    try {
      await _local.atualizarStatusMatch(matchId, 'rejected');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReconciliationMatch>> criarMatchManual({
    required String transacaoId,
    required String linhaExtratoId,
  }) async {
    try {
      final daLinha = await _local.obterMatchesPorLinhas([linhaExtratoId]);
      final daTransacao = await _local.obterMatchesPorTransacao(transacaoId);

      final jaAprovado = [...daLinha, ...daTransacao].any((m) => m.status == 'manual_matched');
      if (jaAprovado) {
        return const Left(ServerFailure('Esta transação ou linha do extrato já foi vinculada.'));
      }

      // Palpites antigos (órfã, candidato, automático) deixam de valer; rejeições
      // continuam registradas para o par não voltar a ser sugerido.
      final substituidos = {...daLinha, ...daTransacao}
          .where((m) => m.status != 'rejected')
          .map((m) => m.id)
          .toList();
      await _local.removerMatches(substituidos);

      final match = ReconciliationMatch(
        id: const Uuid().v4(),
        transacaoId: transacaoId,
        linhaExtratoId: linhaExtratoId,
        dataReconciliacao: DateTime.now(),
        status: 'manual_matched',
        confidence: 1.0,
      );

      await _local.salvarMatches([
        ReconciliationMatchesTableCompanion(
          id: drift.Value(match.id),
          transacaoId: drift.Value(transacaoId),
          linhaExtratoId: drift.Value(linhaExtratoId),
          dataReconciliacao: drift.Value(match.dataReconciliacao),
          status: drift.Value(match.status),
          confidence: drift.Value(match.confidence),
        ),
      ]);
      return Right(match);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReconciliationStatus>> obterStatusPeriodo({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final matches = await _local.obterMatches(dataInicio, dataFim);

      final matched = matches.where((m) => m.isMatched).length;
      final orphans = matches.where((m) => m.isOrphan).length;
      final unmatched = matches.where((m) => m.status == 'unmatched').length;

      final status = ReconciliationStatus(
        totalTransacoes: 0, // TODO: implementar
        totalLinhasExtrato: matches.length,
        matched: matched,
        orphans: orphans,
        unmatched: unmatched,
        percentualReconciliado:
            matches.isEmpty ? 0 : (matched / matches.length) * 100,
      );

      return Right(status);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
