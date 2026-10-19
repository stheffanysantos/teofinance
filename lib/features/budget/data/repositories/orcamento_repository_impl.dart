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
}
