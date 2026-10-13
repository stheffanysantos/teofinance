import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/transacao_repository.dart';

class ExcluirTransacaoUseCase {
  ExcluirTransacaoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.excluir(id);
}
