import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/domain/repositories/investimento_repository.dart';

/// Cadastra um investimento novo ou, com [id], corrige um existente.
class SalvarInvestimentoUseCase {
  SalvarInvestimentoUseCase(this._repository);

  final InvestimentoRepository _repository;
  static const _uuid = Uuid();

  Future<Either<Failure, Unit>> call({
    String? id,
    required String nome,
    required TipoInvestimento tipo,
    required double valorInvestido,
    required double valorAtual,
    required DateTime dataAplicacao,
    String observacao = '',
  }) {
    if (nome.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Dê um nome ao investimento.')));
    }
    if (valorInvestido <= 0) {
      return Future.value(const Left(ValidationFailure('O valor investido deve ser maior que zero.')));
    }
    if (valorAtual < 0) {
      return Future.value(const Left(ValidationFailure('O valor atual não pode ser negativo.')));
    }
    return _repository.salvar(Investimento(
      id: id ?? _uuid.v4(),
      nome: nome.trim(),
      tipo: tipo,
      valorInvestido: valorInvestido,
      valorAtual: valorAtual,
      dataAplicacao: dataAplicacao,
      observacao: observacao.trim(),
    ));
  }
}
