import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/domain/repositories/investimento_repository.dart';

class InvestimentoRepositoryImpl implements InvestimentoRepository {
  InvestimentoRepositoryImpl(this._local);

  final InvestimentoLocalDataSource _local;

  @override
  Future<Either<Failure, List<Investimento>>> listar() async {
    try {
      return Right(await _local.listar());
    } catch (e) {
      debugPrint('InvestimentoRepositoryImpl.listar falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível carregar os investimentos.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> salvar(Investimento investimento) async {
    try {
      await _local.salvar(investimento);
      return const Right(unit);
    } catch (e) {
      debugPrint('InvestimentoRepositoryImpl.salvar falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível salvar o investimento.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (e) {
      debugPrint('InvestimentoRepositoryImpl.excluir falhou: ${e.runtimeType}');
      return const Left(CacheFailure('Não foi possível excluir o investimento.'));
    }
  }

  @override
  Future<List<Investimento>> listarPendentesDeSincronizacao() => _local.listarPendentesDeSincronizacao();

  @override
  Future<List<String>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarSincronizacao(String id) => _local.confirmarSincronizacao(id);

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> aplicarRemoto(Investimento investimento) => _local.aplicarRemoto(investimento);

  @override
  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos) => _local.removerAusentesNoRemoto(idsRemotos);
}
