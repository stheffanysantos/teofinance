import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/renda_repository.dart';

class ExcluirRendaUseCase {
  ExcluirRendaUseCase(this._repository);

  final RendaRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.excluir(id);
}
