import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';

class ExcluirContaUseCase {
  ExcluirContaUseCase(this._repository);

  final ContaRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    if (id.isEmpty) return Future.value(const Left(ValidationFailure('Conta inválida.')));
    return _repository.excluir(id);
  }
}
