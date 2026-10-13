import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/perfil_banco.dart';
import '../../domain/repositories/perfil_banco_repository.dart';
import '../datasources/perfil_banco_local_datasource.dart';
import '../services/bank_profile_matcher.dart';

class PerfilBancoRepositoryImpl implements PerfilBancoRepository {
  PerfilBancoRepositoryImpl(this._local, this._matcher);

  final PerfilBancoLocalDataSource _local;
  final BankProfileMatcher _matcher;

  @override
  Future<Either<Failure, List<PerfilBanco>>> listarTodos() async {
    try {
      return Right(await _local.listarTodos());
    } catch (_) {
      return const Left(CacheFailure('Não foi possível carregar os perfis salvos.'));
    }
  }

  @override
  Future<PerfilBanco?> buscarCompativel(List<String> assinaturaCabecalho) async {
    final perfis = await _local.listarTodos();
    return _matcher.encontrarCompativel(perfis, assinaturaCabecalho);
  }

  @override
  Future<Either<Failure, PerfilBanco>> salvar(PerfilBanco perfil) async {
    try {
      return Right(await _local.salvar(perfil));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar o perfil.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir o perfil.'));
    }
  }

  @override
  Future<List<PerfilBanco>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> aplicarRemoto(PerfilBanco perfil) => _local.aplicarRemoto(perfil);
}
