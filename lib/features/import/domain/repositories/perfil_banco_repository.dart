import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/perfil_banco.dart';

abstract class PerfilBancoRepository {
  Future<Either<Failure, List<PerfilBanco>>> listarTodos();

  /// Primeiro perfil salvo cuja assinatura de cabeçalho bate com
  /// [assinaturaCabecalho] (ver `BankProfileMatcher`).
  Future<PerfilBanco?> buscarCompativel(List<String> assinaturaCabecalho);

  Future<Either<Failure, PerfilBanco>> salvar(PerfilBanco perfil);

  Future<Either<Failure, Unit>> excluir(String id);

  /// Usado só por `features/sync/`.
  Future<List<PerfilBanco>> listarPendentesDeSincronizacao();

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> aplicarRemoto(PerfilBanco perfil);
}
