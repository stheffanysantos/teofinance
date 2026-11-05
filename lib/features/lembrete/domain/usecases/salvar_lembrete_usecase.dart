import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';

class SalvarLembreteUseCase {
  SalvarLembreteUseCase(this._repository);

  final LembreteRepository _repository;

  Future<Either<Failure, Unit>> call(LembretePersonalizado lembrete) {
    if (lembrete.titulo.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Dê um nome ao lembrete.')));
    }
    if (lembrete.dia < 1 || lembrete.dia > 31) {
      return Future.value(const Left(ValidationFailure('O dia deve ser de 1 a 31.')));
    }
    return _repository.salvar(lembrete.copyWith(titulo: lembrete.titulo.trim()));
  }
}
