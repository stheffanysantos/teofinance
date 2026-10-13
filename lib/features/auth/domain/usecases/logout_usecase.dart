import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call() => repository.logout();
}
