import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/transacao_repository.dart';

class RemoverDivisaoUseCase {
  RemoverDivisaoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.definirDivisao(id: id, minhaParte: null);
  }
}
