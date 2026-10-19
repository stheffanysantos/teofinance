import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import '../entities/reconciliation_match.dart';
import '../entities/extrato_linha.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

abstract class ReconciliationRepository {
  /// Importa as linhas do extrato CSV/OFX e as armazena para reconciliação.
  Future<Either<Failure, List<ExtratoLinha>>> importarExtrato({
    required String importId,
    required List<Map<String, dynamic>> linhas,
  });

  /// Todas as linhas de extrato já importadas (usado só para detectar
  /// duplicatas ao importar o mesmo extrato de novo).
  Future<List<ExtratoLinha>> listarLinhasImportadas();

  /// Faz matching automático entre transações e linhas do extrato.
  /// Usa algoritmo simples: valor exato + data ±2 dias = match 100%
  Future<Either<Failure, ReconciliationResultado>> fazerMatching({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  });

  /// Aprova um match (user accept the match).
  Future<Either<Failure, void>> aprovarMatch(String matchId);

  /// Rejeita um match e marca como unmatched.
  Future<Either<Failure, void>> rejeitarMatch(String matchId);

  /// Cria um match manual quando o algoritmo não consegue.
  Future<Either<Failure, ReconciliationMatch>> criarMatchManual({
    required String transacaoId,
    required String linhaExtratoId,
  });

  /// Obtém status geral da reconciliação do período.
  /// Retorna: total de transações, matches, orphans, unmatched, percentual reconciliado.
  Future<Either<Failure, ReconciliationStatus>> obterStatusPeriodo({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  });
}

/// Matches de um período junto com as entidades referenciadas, para a UI
/// exibir descrição/valor/data sem consultar o banco.
class ReconciliationResultado {
  const ReconciliationResultado({
    required this.matches,
    required this.linhas,
    required this.transacoes,
  });

  final List<ReconciliationMatch> matches;
  final Map<String, ExtratoLinha> linhas;
  final Map<String, Transacao> transacoes;
}

/// Resultado da reconciliação de um período.
class ReconciliationStatus {
  final int totalTransacoes;
  final int totalLinhasExtrato;
  final int matched;
  final int orphans;
  final int unmatched;
  final double percentualReconciliado;

  ReconciliationStatus({
    required this.totalTransacoes,
    required this.totalLinhasExtrato,
    required this.matched,
    required this.orphans,
    required this.unmatched,
    required this.percentualReconciliado,
  });
}
