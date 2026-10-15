import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart' show Failure, ServerFailure;
import '../../data/datasources/parcelamento_local_data_source.dart';
import '../../data/datasources/parcelamento_remote_data_source.dart';
import '../../data/models/parcelamento_model.dart';
import '../../domain/entities/parcelamento.dart';
import '../../domain/repositories/parcelamento_repository.dart';

class ParcelamentoRepositoryImpl implements ParcelamentoRepository {
  final ParcelamentoLocalDataSource _local;
  // TODO: Integrar com remote datasource após sync estar pronto
  // final ParcelamentoRemoteDataSource _remote;

  ParcelamentoRepositoryImpl(
    this._local,
    // ignore: unused_element
    ParcelamentoRemoteDataSource _remote,
  );

  @override
  Future<Either<Failure, Parcelamento>> criarParcelamento({
    required String transacaoId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeira,
  }) async {
    try {
      // Cria o registro de parcelamento
      final parcelamentoId = const Uuid().v4();
      final now = DateTime.now();

      final parcelamento = ParcelamentoModel(
        id: parcelamentoId,
        transacaoOriginalId: transacaoId,
        totalOriginal: totalOriginal,
        numeroParcelas: numeroParcelas,
        dataPrimeiraParc: dataPrimeira,
        updatedAt: now,
      );

      await _local.salvarParcelamento(parcelamento);

      // TODO: Criar transações-filhas no TransacaoRepository após integração

      return Right(parcelamento);
    } catch (e) {
      return Left(_tratarException(e));
    }
  }

  @override
  Future<Either<Failure, List<Parcelamento>>> listarPorUsuario(
      String userId) async {
    try {
      final parcelamentos = await _local.listarPorUsuario(userId);
      return Right(parcelamentos);
    } catch (e) {
      return Left(_tratarException(e));
    }
  }

  @override
  Future<Either<Failure, Parcelamento>> obterPorId(
      String parcelamentoId) async {
    try {
      final parcelamento = await _local.obterPorId(parcelamentoId);

      if (parcelamento == null) {
        return Left(
          ServerFailure('Parcelamento não encontrado'),
        );
      }

      return Right(parcelamento);
    } catch (e) {
      return Left(_tratarException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deletarParcelamento(
      String parcelamentoId) async {
    try {
      await _local.deletarParcelamento(parcelamentoId);
      // TODO: Deletar transações-filhas associadas
      return const Right(null);
    } catch (e) {
      return Left(_tratarException(e));
    }
  }

  Failure _tratarException(dynamic e) {
    if (e is Failure) {
      return e;
    }
    return ServerFailure(e.toString());
  }
}
