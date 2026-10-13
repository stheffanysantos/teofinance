import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/meta_repository.dart';

class ExcluirMetaUseCase {
  ExcluirMetaUseCase(this._repository);

  final MetaRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.excluir(id);
}
