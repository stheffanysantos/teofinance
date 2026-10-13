import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/biometria_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/cadastrar_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verificar_biometria_usecase.dart';

/// Infraestrutura de composição (DI) — nenhuma regra de negócio aqui, só
/// instancia e injeta (ver `.claude/rules/architecture.md`).
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(firebaseAuthProvider));
});

final biometriaLocalDataSourceProvider = Provider<BiometriaLocalDataSource>((ref) {
  return BiometriaLocalDataSource(LocalAuthentication(), ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(biometriaLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final cadastrarUseCaseProvider = Provider((ref) => CadastrarUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final verificarBiometriaUseCaseProvider =
    Provider((ref) => VerificarBiometriaUseCase(ref.watch(authRepositoryProvider)));
