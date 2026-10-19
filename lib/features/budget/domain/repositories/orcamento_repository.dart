import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';

abstract class OrcamentoRepository {
  Stream<List<Orcamento>> observarTodos();

  /// Cria o limite da [categoria] ou, se já existir, troca o valor.
  Future<Either<Failure, Orcamento>> definirLimite({
    required String categoria,
    required double limite,
  });

  Future<Either<Failure, Unit>> excluir(String id);

  /// Usado só por `features/sync/` — ver `.claude/rules/architecture.md`.
  Future<List<Orcamento>> listarPendentesDeSincronizacao();

  Future<List<Orcamento>> listarPendentesDeExclusao();

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> confirmarExclusao(String id);

  Future<void> aplicarRemoto({
    required String remoteId,
    required String categoria,
    required double limite,
  });
}
