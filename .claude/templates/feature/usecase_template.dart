import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';
import 'package:teofinance/features/nome_feature/domain/repositories/nome_entidade_repository.dart';

/// Um usecase = uma intenção de negócio. Nunca um CrudUseCase<T> genérico.
class SalvarNomeEntidadeUseCase {
  SalvarNomeEntidadeUseCase(this.repository);

  final NomeEntidadeRepository repository;

  Future<Either<Failure, NomeEntidade>> call(NomeEntidade entidade) async {
    if (!entidade.valorValido) {
      return const Left(ValidationFailure('Valor deve ser diferente de zero.'));
    }
    return repository.salvar(entidade);
  }
}
