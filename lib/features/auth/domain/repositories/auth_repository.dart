import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/usuario.dart';

/// Contrato abstrato — SEM implementação. Ver
/// `data/repositories/auth_repository_impl.dart`.
abstract class AuthRepository {
  /// Emite o usuário atual (ou `null` quando deslogado) a cada mudança de
  /// sessão do Firebase Authentication.
  Stream<Usuario?> watchUsuarioAtual();

  Usuario? get usuarioAtual;

  Future<Either<Failure, Usuario>> login({required String email, required String senha});

  Future<Either<Failure, Usuario>> cadastrar({required String email, required String senha});

  Future<Either<Failure, Unit>> logout();

  /// Sensor de biometria disponível neste aparelho (não é a preferência do
  /// usuário — ver [biometriaHabilitada]).
  Future<bool> biometriaDisponivel();

  Future<bool> biometriaHabilitada();

  Future<Either<Failure, Unit>> definirBiometriaHabilitada(bool habilitada);

  /// Solicita a confirmação biométrica (Face ID/digital) ao sistema.
  Future<Either<Failure, Unit>> autenticarComBiometria();
}
