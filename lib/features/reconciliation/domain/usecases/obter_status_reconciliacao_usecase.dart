import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';

class ObterStatusReconciliacaoUseCase {
  ObterStatusReconciliacaoUseCase(this.repository);

  final ReconciliationRepository repository;

  Future<Either<Failure, ReconciliationStatus>> call(
    ObterStatusReconciliacaoParams params,
  ) async {
    if (params.dataFim.isBefore(params.dataInicio)) {
      return const Left(ValidationFailure('O fim do período deve ser depois do início.'));
    }
    return repository.obterStatusPeriodo(
      userId: params.userId,
      dataInicio: params.dataInicio,
      dataFim: params.dataFim,
    );
  }
}

class ObterStatusReconciliacaoParams {
  const ObterStatusReconciliacaoParams({
    required this.userId,
    required this.dataInicio,
    required this.dataFim,
  });

  final String userId;
  final DateTime dataInicio;
  final DateTime dataFim;
}
