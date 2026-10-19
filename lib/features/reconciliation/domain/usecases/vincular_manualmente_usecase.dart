import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/reconciliation/domain/entities/reconciliation_match.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';

class VincularManualmenteUseCase {
  VincularManualmenteUseCase(this.repository);

  final ReconciliationRepository repository;

  Future<Either<Failure, ReconciliationMatch>> call(
    VincularManualmenteParams params,
  ) async {
    if (params.transacaoId.isEmpty || params.linhaExtratoId.isEmpty) {
      return const Left(ValidationFailure('Escolha uma transação e uma linha do extrato.'));
    }
    return repository.criarMatchManual(
      transacaoId: params.transacaoId,
      linhaExtratoId: params.linhaExtratoId,
    );
  }
}

class VincularManualmenteParams {
  const VincularManualmenteParams({
    required this.transacaoId,
    required this.linhaExtratoId,
  });

  final String transacaoId;
  final String linhaExtratoId;
}
