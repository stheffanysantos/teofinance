import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/meta.dart';
import '../../domain/repositories/meta_repository.dart';
import '../datasources/meta_local_datasource.dart';

class MetaRepositoryImpl implements MetaRepository {
  MetaRepositoryImpl(this._local);

  final MetaLocalDataSource _local;

  @override
  Stream<List<Meta>> observarTodas() => _local.observarTodas();

  @override
  Future<Either<Failure, Meta>> criar({
    required String nome,
    required double valorAlvo,
    required DateTime prazo,
    double valorAtual = 0,
  }) async {
    try {
      return Right(
        await _local.criar(nome: nome, valorAlvo: valorAlvo, prazo: prazo, valorAtual: valorAtual),
      );
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a meta.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> aportar({required String id, required double valor}) async {
    try {
      await _local.aportar(id: id, valor: valor);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível registrar o aporte.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir a meta.'));
    }
  }

  @override
  Future<List<Meta>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<List<Meta>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> aplicarRemoto(Meta meta) => _local.aplicarRemoto(meta);
}
