import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/categoria/data/datasources/categoria_local_data_source.dart';
import 'package:teofinance/features/categoria/domain/repositories/categoria_repository.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  CategoriaRepositoryImpl(this._local);

  final CategoriaLocalDataSource _local;

  @override
  Future<Either<Failure, List<String>>> listar() async {
    try {
      return Right(await _local.listar());
    } catch (e) {
      debugPrint('CategoriaRepositoryImpl.listar falhou: ${e.runtimeType}');
      return const Left(
        CacheFailure('Não foi possível carregar as categorias.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> adicionar(String nome) async {
    try {
      await _local.adicionar(nome);
      return const Right(unit);
    } catch (e) {
      debugPrint('CategoriaRepositoryImpl.adicionar falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível salvar a categoria.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> remover(String nome) async {
    try {
      await _local.remover(nome);
      return const Right(unit);
    } catch (e) {
      debugPrint('CategoriaRepositoryImpl.remover falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível remover a categoria.'));
    }
  }

  @override
  Future<List<String>> listarPendentesDeSincronizacao() =>
      _local.listarPendentesDeSincronizacao();

  @override
  Future<List<String>> listarPendentesDeExclusao() =>
      _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarSincronizacao(String nome) =>
      _local.confirmarSincronizacao(nome);

  @override
  Future<void> confirmarExclusao(String nome) => _local.confirmarExclusao(nome);

  @override
  Future<void> aplicarRemoto(String nome) => _local.aplicarRemoto(nome);

  @override
  Future<void> removerAusentesNoRemoto(Set<String> nomesRemotos) =>
      _local.removerAusentesNoRemoto(nomesRemotos);
}
