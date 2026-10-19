import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/contas/domain/services/validar_conta.dart';

class CriarContaUseCase {
  CriarContaUseCase(this._repository);

  final ContaRepository _repository;

  Future<Either<Failure, ContaAPagar>> call({
    required String descricao,
    required double valor,
    required DateTime vencimento,
    String categoria = '',
    RecorrenciaConta recorrencia = RecorrenciaConta.nenhuma,
    int diasAntesLembrete = 1,
  }) {
    final falha = validarConta(descricao: descricao, valor: valor, diasAntesLembrete: diasAntesLembrete);
    if (falha != null) return Future.value(Left(falha));

    return _repository.criar(
      descricao: descricao.trim(),
      valor: valor,
      vencimento: vencimento,
      categoria: categoria,
      recorrencia: recorrencia,
      diasAntesLembrete: diasAntesLembrete,
    );
  }
}
