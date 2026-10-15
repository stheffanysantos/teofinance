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
  Future<Either<Failure, List<ReconciliationMatch>>> fazerMatching({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      // 1. Busca transações do período
      final transacoes = await _transacaoLocal.listarPendentes();
      final transacoesFiltered = transacoes
          .where((t) =>
              t.data.isAfter(dataInicio) && t.data.isBefore(dataFim))
          .toList();

      // 2. Busca linhas do extrato (últimas importações)
      // TODO: implementar busca de últimas linhas importadas
      final linhasExtrato = <ExtratoLinha>[];

      // 3. Faz matching
      final matches = _matcher.encontrarMatches(
        transacoes: transacoesFiltered,
        linhasExtrato: linhasExtrato,
      );

      // 4. Cria registros de match
      final companions = <ReconciliationMatchesTableCompanion>[];
      final matchedIds = <String>{};

      for (final (txn, linha, confidence) in matches) {
        companions.add(ReconciliationMatchesTableCompanion(
          id: drift.Value(const Uuid().v4()),
          transacaoId: drift.Value(txn.id),
          linhaExtratoId: drift.Value(linha.id),
          dataReconciliacao: drift.Value(DateTime.now()),
          status: drift.Value(
            confidence == 1.0 ? 'auto_matched' : 'manual_matched',
          ),
          confidence: drift.Value(confidence),
        ));
        matchedIds.add(linha.id);
      }

      // 5. Identifica orphans (linhas do extrato sem correspondência)
      for (final linha in linhasExtrato) {
        if (!matchedIds.contains(linha.id)) {
          companions.add(ReconciliationMatchesTableCompanion(
            id: drift.Value(const Uuid().v4()),
            transacaoId: const drift.Value(null),
            linhaExtratoId: drift.Value(linha.id),
            dataReconciliacao: drift.Value(DateTime.now()),
            status: const drift.Value('orphan'),
            confidence: const drift.Value(0.0),
          ));
        }
      }

      // 6. Salva todos os matches
      final result = await _local.salvarMatches(companions);
      return Right(result);
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
      await _local.atualizarStatusMatch(matchId, 'unmatched');
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
      final match = ReconciliationMatch(
        id: const Uuid().v4(),
        transacaoId: transacaoId,
        linhaExtratoId: linhaExtratoId,
        dataReconciliacao: DateTime.now(),
        status: 'manual_matched',
        confidence: 1.0,
      );

      final companion = ReconciliationMatchesTableCompanion(
        id: drift.Value(match.id),
        transacaoId: drift.Value(transacaoId),
        linhaExtratoId: drift.Value(linhaExtratoId),
        dataReconciliacao: drift.Value(match.dataReconciliacao),
        status: drift.Value(match.status),
        confidence: drift.Value(match.confidence),
      );

      await _local.salvarMatches([companion]);
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
