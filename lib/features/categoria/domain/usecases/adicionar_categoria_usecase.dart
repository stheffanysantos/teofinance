import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/categoria/domain/repositories/categoria_repository.dart';

const kTamanhoMaximoCategoria = 30;

class AdicionarCategoriaUseCase {
  AdicionarCategoriaUseCase(this._repository);

  final CategoriaRepository _repository;

  Future<Either<Failure, Unit>> call(
    String nome, {
    required List<String> existentes,
  }) {
    final limpo = nome.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (limpo.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Informe o nome da categoria.')),
      );
    }
    if (limpo.length > kTamanhoMaximoCategoria) {
      return Future.value(
        const Left(
          ValidationFailure('Use até $kTamanhoMaximoCategoria caracteres.'),
        ),
      );
    }
    final minusculo = limpo.toLowerCase();
    final jaExiste = [
      ...kCategoriasBase,
      ...existentes,
    ].any((c) => c.toLowerCase() == minusculo);
    if (jaExiste) {
      return Future.value(
        const Left(ValidationFailure('Já existe uma categoria com esse nome.')),
      );
    }
    return _repository.adicionar(limpo);
  }
}
