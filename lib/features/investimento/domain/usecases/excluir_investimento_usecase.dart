import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/investimento/domain/repositories/investimento_repository.dart';

class ExcluirInvestimentoUseCase {
  ExcluirInvestimentoUseCase(this._repository);

  final InvestimentoRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.excluir(id);
}
