import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';

class DefinirLimiteOrcamentoUseCase {
  DefinirLimiteOrcamentoUseCase(this._repository);

  final OrcamentoRepository _repository;

  Future<Either<Failure, Orcamento>> call({
    required String categoria,
    required double limite,
  }) {
    if (categoria.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Escolha uma categoria.')));
    }
    if (limite.isNaN || limite <= 0) {
      return Future.value(const Left(ValidationFailure('O limite precisa ser maior que zero.')));
    }
    return _repository.definirLimite(categoria: categoria.trim(), limite: limite);
  }
}
