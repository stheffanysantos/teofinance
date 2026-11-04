import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transacao.dart';

/// Dados de uma transação a criar; o id é gerado na camada de dados.
typedef NovaTransacao = ({String descricao, double valor, DateTime data, String categoria});

abstract class TransacaoRepository {
  /// Todas as transações, mais recentes primeiro — atualiza automaticamente
  /// quando uma importação ou cadastro manual altera a tabela local.
  Stream<List<Transacao>> observarTodas();

  Future<Either<Failure, Transacao>> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    String categoria,
  });

  /// Cria várias transações de uma vez, atomicamente (tudo ou nada) — usado pela
  /// confirmação de uma importação. Categoria vazia marca `precisaCategoria`.
  Future<Either<Failure, Unit>> criarEmLote(List<NovaTransacao> itens);

  Future<Either<Failure, Unit>> categorizar({required String id, required String categoria});

  /// [minhaParte] nulo remove a divisão.
  Future<Either<Failure, Unit>> definirDivisao({
    required String id,
    required double? minhaParte,
    List<String> divididoCom,
  });

  Future<Either<Failure, Unit>> excluir(String id);

  /// Usado só por `features/sync/` — ver `.claude/rules/architecture.md`.
  Future<List<Transacao>> listarPendentesDeSincronizacao();

  Future<List<Transacao>> listarPendentesDeExclusao();

  Future<void> confirmarExclusao(String id);

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> aplicarRemoto({
    required String remoteId,
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime data,
    required bool precisaCategoria,
    double? minhaParte,
    List<String> divididoCom,
    String? parcelamentoId,
    int? numeroParcela,
    double? valorParcela,
    bool ehParcela,
    String? statusParcela,
  });
}
