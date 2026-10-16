import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transacao_repository.dart';
import '../datasources/transacao_local_datasource.dart';

class TransacaoRepositoryImpl implements TransacaoRepository {
  TransacaoRepositoryImpl(this._local);

  final TransacaoLocalDataSource _local;

  @override
  Stream<List<Transacao>> observarTodas() => _local.observarTodas();

  @override
  Future<Either<Failure, Transacao>> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    String categoria = '',
  }) async {
    try {
      return Right(
        await _local.criar(descricao: descricao, valor: valor, data: data, categoria: categoria),
      );
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a transação.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> categorizar({required String id, required String categoria}) async {
    try {
      await _local.categorizar(id: id, categoria: categoria);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível categorizar a transação.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> definirDivisao({
    required String id,
    required double? minhaParte,
    List<String> divididoCom = const [],
  }) async {
    try {
      await _local.definirDivisao(id: id, minhaParte: minhaParte, divididoCom: divididoCom);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a divisão.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir a transação.'));
    }
  }

  @override
  Future<List<Transacao>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<List<Transacao>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> aplicarRemoto({
    required String remoteId,
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime data,
    required bool precisaCategoria,
    double? minhaParte,
    List<String> divididoCom = const [],
  }) {
    return _local.aplicarRemoto(
      remoteId: remoteId,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      data: data,
      precisaCategoria: precisaCategoria,
      minhaParte: minhaParte,
      divididoCom: divididoCom,
    );
  }
}
