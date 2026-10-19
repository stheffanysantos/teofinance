import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';

class FazerReconciliacaoUseCase {
  FazerReconciliacaoUseCase(this.repository);

  final ReconciliationRepository repository;

  Future<Either<Failure, ReconciliationResultado>> call(
    FazerReconciliacaoParams params,
  ) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('Usuário não identificado.'));
    }
    if (params.dataFim.isBefore(params.dataInicio)) {
      return const Left(ValidationFailure('O fim do período deve ser depois do início.'));
    }

    return repository.fazerMatching(
      userId: params.userId,
      dataInicio: params.dataInicio,
      dataFim: params.dataFim,
    );
  }
}

class FazerReconciliacaoParams {
  const FazerReconciliacaoParams({
    required this.userId,
    required this.dataInicio,
    required this.dataFim,
  });

  final String userId;
  final DateTime dataInicio;
  final DateTime dataFim;
}
