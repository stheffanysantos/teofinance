import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/renda.dart';
import '../repositories/renda_repository.dart';

class CriarRendaUseCase {
  CriarRendaUseCase(this._repository);

  final RendaRepository _repository;

  Future<Either<Failure, Renda>> call({
    required String descricao,
    required double valor,
    required TipoRenda tipo,
    required DateTime dataRecebimento,
    RecorrenciaRenda? recorrencia,
  }) {
    if (descricao.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Descreva a origem da renda.')));
    }
    if (valor <= 0) {
      return Future.value(const Left(ValidationFailure('O valor precisa ser maior que zero.')));
    }
    if (tipo == TipoRenda.fixa && recorrencia == null) {
      return Future.value(
        const Left(ValidationFailure('Renda fixa precisa de uma recorrência (semanal, mensal ou anual).')),
      );
    }
    return _repository.criar(
      descricao: descricao.trim(),
      valor: valor,
      tipo: tipo,
      dataRecebimento: dataRecebimento,
      recorrencia: tipo == TipoRenda.fixa ? recorrencia : null,
    );
  }
}
