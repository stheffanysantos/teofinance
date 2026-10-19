import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transacao.dart';

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
