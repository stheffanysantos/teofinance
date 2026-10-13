import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Decide se a tela de desbloqueio biométrico deve ser exibida, e dispara a
/// checagem com o sistema operacional quando necessário.
class VerificarBiometriaUseCase {
  VerificarBiometriaUseCase(this.repository);

  final AuthRepository repository;

  Future<bool> precisaDesbloquear() async {
    final disponivel = await repository.biometriaDisponivel();
    final habilitada = await repository.biometriaHabilitada();
    return disponivel && habilitada;
  }

  Future<Either<Failure, Unit>> autenticar() => repository.autenticarComBiometria();
}
