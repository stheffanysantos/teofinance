import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';

class RejeitarMatchUseCase {
  RejeitarMatchUseCase(this.repository);

  final ReconciliationRepository repository;

  Future<Either<Failure, void>> call(String matchId) async {
    if (matchId.isEmpty) {
      return const Left(ValidationFailure('Match inválido.'));
    }
    return repository.rejeitarMatch(matchId);
  }
}
