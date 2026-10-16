import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/parcelamento/domain/entities/parcelamento.dart';

abstract class ParcelamentoRepository {
  /// Cria um novo parcelamento a partir de uma transação existente.
  ///
  /// Cria a transação-mãe no banco de dados, gera N transações-filhas
  /// distribuídas nos meses seguintes, e marca a transação original como "parcelada".
  Future<Either<Failure, Parcelamento>> criarParcelamento({
    required String transacaoId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeira,
  });

  /// Lista todos os parcelamentos do usuário.
  Future<Either<Failure, List<Parcelamento>>> listarPorUsuario(String userId);

  /// Obtém um parcelamento específico pelo ID.
  Future<Either<Failure, Parcelamento>> obterPorId(String parcelamentoId);

  /// Deleta um parcelamento e suas transações-filhas associadas.
  Future<Either<Failure, void>> deletarParcelamento(String parcelamentoId);
}
