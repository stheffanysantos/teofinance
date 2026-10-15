import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/parcelamento.dart';
import '../repositories/parcelamento_repository.dart';

class CriarParcelamentoUseCase {
  CriarParcelamentoUseCase(this.repository);

  final ParcelamentoRepository repository;

  Future<Either<Failure, Parcelamento>> call(
    CriarParcelamentoParams params,
  ) async {
    // Validações
    if (params.numeroParcelas < 2 || params.numeroParcelas > 12) {
      return Left(
        ValidationFailure('Número de parcelas deve estar entre 2 e 12'),
      );
    }

    if (params.totalOriginal <= 0) {
      return Left(ValidationFailure('Valor total deve ser positivo'));
    }

    return repository.criarParcelamento(
      transacaoId: params.transacaoId,
      totalOriginal: params.totalOriginal,
      numeroParcelas: params.numeroParcelas,
      dataPrimeira: params.dataPrimeira,
    );
  }
}

class CriarParcelamentoParams {
  final String transacaoId;
  final double totalOriginal;
  final int numeroParcelas;
  final DateTime dataPrimeira;

  CriarParcelamentoParams({
    required this.transacaoId,
    required this.totalOriginal,
    required this.numeroParcelas,
    required this.dataPrimeira,
  });
}
