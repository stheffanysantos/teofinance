import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/auth/domain/entities/usuario.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';

/// Sessão fixa da demonstração: o visitante já entra logado, sem biometria.
class AuthRepositoryDemo implements AuthRepository {
  static const _usuario = Usuario(uid: 'demo', email: 'demo@teofinance.app');

  @override
  Stream<Usuario?> watchUsuarioAtual() => Stream.value(_usuario);

  @override
  Usuario? get usuarioAtual => _usuario;

  @override
  Future<Either<Failure, Usuario>> login({required String email, required String senha}) async => const Right(_usuario);

  @override
  Future<Either<Failure, Usuario>> cadastrar({required String email, required String senha}) async =>
      const Right(_usuario);

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<bool> biometriaDisponivel() async => false;

  @override
  Future<bool> biometriaHabilitada() async => false;

  @override
  Future<Either<Failure, Unit>> definirBiometriaHabilitada(bool habilitada) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> autenticarComBiometria() async => const Right(unit);
}
