import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/contas/domain/services/validar_conta.dart';

class EditarContaUseCase {
  EditarContaUseCase(this._repository);

  final ContaRepository _repository;

  Future<Either<Failure, ContaAPagar>> call(ContaAPagar conta) {
    final falha = validarConta(
      descricao: conta.descricao,
      valor: conta.valor,
      diasAntesLembrete: conta.diasAntesLembrete,
    );
    if (falha != null) return Future.value(Left(falha));

    return _repository.atualizar(conta.copyWith(descricao: conta.descricao.trim()));
  }
}
