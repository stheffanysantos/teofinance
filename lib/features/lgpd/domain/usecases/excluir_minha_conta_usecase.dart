import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';

class ExcluirMinhaContaUseCase {
  ExcluirMinhaContaUseCase({required LgpdRepository repository, required AuthRepository auth})
      : _repository = repository,
        _auth = auth;

  final LgpdRepository _repository;
  final AuthRepository _auth;

  Future<Either<Failure, Unit>> call({required String senha}) async {
    if (senha.isEmpty) {
      return const Left(ValidationFailure('Digite sua senha para confirmar.'));
    }

    final confirmacao = await confirmarComBiometria(_auth);
    if (confirmacao != null) return Left(confirmacao);

    return _repository.excluirTodosOsDados(senha: senha);
  }
}
