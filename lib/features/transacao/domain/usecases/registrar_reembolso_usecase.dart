import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Marca (ou desmarca) que uma pessoa da divisão devolveu a parte dela. Não
/// mexe no saldo: ele já conta só a parte do usuário; isto só acompanha quem
/// ainda deve.
class RegistrarReembolsoUseCase {
  RegistrarReembolsoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call({
    required Transacao transacao,
    required String pessoa,
    required bool pago,
  }) {
    if (!transacao.ehDividida) {
      return Future.value(const Left(ValidationFailure('Esta compra não foi dividida.')));
    }
    if (!transacao.pessoasDaDivisao.contains(pessoa)) {
      return Future.value(const Left(ValidationFailure('Essa pessoa não está na divisão.')));
    }
    return _repository.definirDivisao(
      id: transacao.id,
      minhaParte: transacao.minhaParte!,
      divididoCom: transacao.divisaoComReembolso(pessoa, pago: pago),
    );
  }
}
