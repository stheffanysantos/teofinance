import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';

class LembreteRepositoryImpl implements LembreteRepository {
  LembreteRepositoryImpl(this._local);

  final LembreteLocalDataSource _local;

  @override
  Future<Either<Failure, List<LembretePersonalizado>>> listar() async {
    try {
      return Right(await _local.listar());
    } catch (e) {
      debugPrint('LembreteRepositoryImpl.listar falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível carregar os lembretes.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> salvar(LembretePersonalizado lembrete) async {
    try {
      await _local.salvar(lembrete);
      return const Right(unit);
    } catch (e) {
      debugPrint('LembreteRepositoryImpl.salvar falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível salvar o lembrete.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (e) {
      debugPrint('LembreteRepositoryImpl.excluir falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível excluir o lembrete.'));
    }
  }

  @override
  Future<List<LembretePersonalizado>> listarPendentesDeSincronizacao() => _local.listarPendentesDeSincronizacao();

  @override
  Future<List<String>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarSincronizacao(String id) => _local.confirmarSincronizacao(id);

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> aplicarRemoto(LembretePersonalizado lembrete) => _local.aplicarRemoto(lembrete);

  @override
  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos) => _local.removerAusentesNoRemoto(idsRemotos);
}
