import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/biometria_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._biometria);

  final AuthRemoteDataSource _remote;
  final BiometriaLocalDataSource _biometria;

  @override
  Usuario? get usuarioAtual => _remote.usuarioAtual;

  @override
  Stream<Usuario?> watchUsuarioAtual() => _remote.watchUsuarioAtual();

  @override
  Future<Either<Failure, Usuario>> login({required String email, required String senha}) async {
    try {
      final usuario = await _remote.login(email: email, senha: senha);
      return Right(usuario);
    } on fb.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mensagemAuth(e)));
    }
  }

  @override
  Future<Either<Failure, Usuario>> cadastrar({required String email, required String senha}) async {
    try {
      final usuario = await _remote.cadastrar(email: email, senha: senha);
      return Right(usuario);
    } on fb.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mensagemAuth(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
      return const Right(unit);
    } catch (_) {
      return const Left(AuthFailure('Não foi possível sair da conta. Tente novamente.'));
    }
  }

  @override
  Future<bool> biometriaDisponivel() => _biometria.disponivel();

  @override
  Future<bool> biometriaHabilitada() => _biometria.habilitada();

  @override
  Future<Either<Failure, Unit>> definirBiometriaHabilitada(bool habilitada) async {
    try {
      await _biometria.definirHabilitada(habilitada);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a preferência de biometria.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> autenticarComBiometria() async {
    try {
      final sucesso = await _biometria.autenticar();
      if (!sucesso) {
        return const Left(AuthFailure('Confirmação biométrica não realizada.'));
      }
      return const Right(unit);
    } catch (_) {
      return const Left(AuthFailure('Não foi possível verificar a biometria.'));
    }
  }

  String _mensagemAuth(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com esse e-mail.';
      case 'weak-password':
        return 'Escolha uma senha mais forte.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Não foi possível concluir. Tente novamente.';
    }
  }
}
