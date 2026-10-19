import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';

class OrcamentoRepositoryImpl implements OrcamentoRepository {
  OrcamentoRepositoryImpl(this._local);

  final OrcamentoLocalDataSource _local;

  @override
  Stream<List<Orcamento>> observarTodos() => _local.observarTodos();

  @override
  Future<Either<Failure, Orcamento>> definirLimite({
    required String categoria,
    required double limite,
  }) async {
    try {
      return Right(await _local.definirLimite(categoria: categoria, limite: limite));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar o limite.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir o limite.'));
    }
  }

  @override
  Future<List<Orcamento>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<List<Orcamento>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> aplicarRemoto({
    required String remoteId,
    required String categoria,
    required double limite,
  }) {
    return _local.aplicarRemoto(remoteId: remoteId, categoria: categoria, limite: limite);
  }
}
