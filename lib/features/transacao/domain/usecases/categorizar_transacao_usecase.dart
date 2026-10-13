import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/transacao_repository.dart';

class CategorizarTransacaoUseCase {
  CategorizarTransacaoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call({required String id, required String categoria}) {
    if (categoria.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Escolha uma categoria.')));
    }
    return _repository.categorizar(id: id, categoria: categoria.trim());
  }
}
