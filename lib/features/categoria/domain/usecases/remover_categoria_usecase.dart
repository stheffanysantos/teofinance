import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/categoria/domain/repositories/categoria_repository.dart';

/// Remove só categorias criadas pelo usuário. Transações que já usam o nome
/// continuam com ele; a categoria só deixa de ser oferecida nos formulários.
class RemoverCategoriaUseCase {
  RemoverCategoriaUseCase(this._repository);

  final CategoriaRepository _repository;

  Future<Either<Failure, Unit>> call(String nome) {
    if (kCategoriasBase.contains(nome)) {
      return Future.value(
        const Left(
          ValidationFailure('As categorias padrão não podem ser removidas.'),
        ),
      );
    }
    return _repository.remover(nome);
  }
}
