import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class CadastrarUseCase {
  CadastrarUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Usuario>> call({required String email, required String senha}) async {
    if (!email.contains('@')) {
      return const Left(ValidationFailure('Informe um e-mail válido.'));
    }
    if (senha.length < 6) {
      return const Left(ValidationFailure('A senha precisa ter pelo menos 6 caracteres.'));
    }
    return repository.cadastrar(email: email.trim(), senha: senha);
  }
}
