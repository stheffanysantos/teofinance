import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';

class ExcluirLembreteUseCase {
  ExcluirLembreteUseCase(this._repository);

  final LembreteRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.excluir(id);
}
