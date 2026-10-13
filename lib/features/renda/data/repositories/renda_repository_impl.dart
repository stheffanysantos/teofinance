import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/renda.dart';
import '../../domain/repositories/renda_repository.dart';
import '../datasources/renda_local_datasource.dart';

class RendaRepositoryImpl implements RendaRepository {
  RendaRepositoryImpl(this._local);

  final RendaLocalDataSource _local;

  @override
  Stream<List<Renda>> observarTodas() => _local.observarTodas();

  @override
  Future<Either<Failure, Renda>> criar({
    required String descricao,
    required double valor,
    required TipoRenda tipo,
    required DateTime dataRecebimento,
    RecorrenciaRenda? recorrencia,
  }) async {
    try {
      return Right(
        await _local.criar(
          descricao: descricao,
          valor: valor,
          tipo: tipo,
          dataRecebimento: dataRecebimento,
          recorrencia: recorrencia,
        ),
      );
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a renda.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> definirAtiva({required String id, required bool ativa}) async {
    try {
      await _local.definirAtiva(id: id, ativa: ativa);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível atualizar a renda.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir a renda.'));
    }
  }

  @override
  Future<List<Renda>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> aplicarRemoto(Renda renda) => _local.aplicarRemoto(renda);
}
