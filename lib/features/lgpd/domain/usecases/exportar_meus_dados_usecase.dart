import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';

class ExportarMeusDadosUseCase {
  ExportarMeusDadosUseCase({
    required LgpdRepository repository,
    required AuthRepository auth,
    Future<void> Function()? antesDeExportar,
  })  : _repository = repository,
        _auth = auth,
        _antesDeExportar = antesDeExportar;

  final LgpdRepository _repository;
  final AuthRepository _auth;

  /// Gancho para trazer do Firestore o que outros aparelhos gravaram antes de
  /// exportar a cópia local. Falha aqui nunca impede a exportação.
  final Future<void> Function()? _antesDeExportar;

  Future<Either<Failure, String>> call() async {
    final confirmacao = await confirmarComBiometria(_auth);
    if (confirmacao != null) return Left(confirmacao);

    try {
      await _antesDeExportar?.call();
    } catch (_) {
      // sem conexão: exporta o que está no aparelho.
    }
    return _repository.exportarDados();
  }
}

/// Segunda camada exigida por `.claude/rules/security.md` antes de uma ação
/// sensível: se o usuário ativou a biometria, ela precisa ser confirmada.
/// Devolve a falha, ou nulo quando pode prosseguir.
Future<Failure?> confirmarComBiometria(AuthRepository auth) async {
  final exige = await auth.biometriaDisponivel() && await auth.biometriaHabilitada();
  if (!exige) return null;

  final resultado = await auth.autenticarComBiometria();
  return resultado.fold((falha) => falha, (_) => null);
}
