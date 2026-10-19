import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';

class ExcluirLimiteOrcamentoUseCase {
  ExcluirLimiteOrcamentoUseCase(this._repository);

  final OrcamentoRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    if (id.isEmpty) {
      return Future.value(const Left(ValidationFailure('Limite inválido.')));
    }
    return _repository.excluir(id);
  }
}
