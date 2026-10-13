import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/meta.dart';
import '../repositories/meta_repository.dart';

class CriarMetaUseCase {
  CriarMetaUseCase(this._repository);

  final MetaRepository _repository;

  Future<Either<Failure, Meta>> call({
    required String nome,
    required double valorAlvo,
    required DateTime prazo,
    double valorAtual = 0,
  }) {
    if (nome.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Dê um nome à meta.')));
    }
    if (valorAlvo <= 0) {
      return Future.value(const Left(ValidationFailure('O valor-alvo precisa ser maior que zero.')));
    }
    if (!prazo.isAfter(DateTime.now())) {
      return Future.value(const Left(ValidationFailure('Escolha um prazo no futuro.')));
    }
    return _repository.criar(
      nome: nome.trim(),
      valorAlvo: valorAlvo,
      prazo: prazo,
      valorAtual: valorAtual,
    );
  }
}
