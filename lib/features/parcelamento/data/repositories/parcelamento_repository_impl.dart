import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart' show Failure, ServerFailure;
import '../../../transacao/data/datasources/transacao_local_datasource.dart';
import '../../data/datasources/parcelamento_local_data_source.dart';
import '../../data/datasources/parcelamento_remote_data_source.dart';
import '../../data/models/parcelamento_model.dart';
import '../../domain/entities/parcelamento.dart';
import '../../domain/repositories/parcelamento_repository.dart';

class ParcelamentoRepositoryImpl implements ParcelamentoRepository {
  final ParcelamentoLocalDataSource _local;
  final TransacaoLocalDataSource _transacaoLocal;
  // TODO: Integrar com remote datasource após sync estar pronto
  // final ParcelamentoRemoteDataSource _remote;

  ParcelamentoRepositoryImpl(
    this._local,
    this._transacaoLocal,
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
      // 1. Busca a transação original para obter dados
      final transacaoOriginal = await _transacaoLocal.obterPorId(transacaoId);

      if (transacaoOriginal == null) {
        return Left(
          ServerFailure('Transação original não encontrada'),
        );
      }

      // 2. Cria o registro de parcelamento
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

      // 3. Cria as N transações-filhas (uma por parcela)
      await _transacaoLocal.criarParcelas(
        parcelamentoId: parcelamentoId,
        descricaoOriginal: transacaoOriginal.descricao,
        categoria: transacaoOriginal.categoria,
        totalOriginal: transacaoOriginal.valor < 0 ? -totalOriginal : totalOriginal,
        numeroParcelas: numeroParcelas,
        dataPrimeira: dataPrimeira,
      );

      // As parcelas substituem a compra original; mantê-la contaria o valor duas vezes.
      await _transacaoLocal.excluir(transacaoId);

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
