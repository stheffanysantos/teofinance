import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/meta_repository.dart';

class AportarMetaUseCase {
  AportarMetaUseCase(this._repository);

  final MetaRepository _repository;

  Future<Either<Failure, Unit>> call({required String id, required double valor}) {
    if (valor <= 0) {
      return Future.value(const Left(ValidationFailure('O aporte precisa ser maior que zero.')));
    }
    return _repository.aportar(id: id, valor: valor);
  }
}
