import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/transacao_repository.dart';

class EditarTransacaoUseCase {
  EditarTransacaoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String id,
    required String descricao,
    required double valor,
    required DateTime data,
    String categoria = '',
  }) {
    if (descricao.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Descreva a transação.')));
    }
    if (valor == 0) {
      return Future.value(const Left(ValidationFailure('O valor não pode ser zero.')));
    }
    return _repository.editar(
      id: id,
      descricao: descricao.trim(),
      valor: valor,
      data: data,
      categoria: categoria.trim(),
    );
  }
}
