/// Falhas de negócio expostas pelos repositories — nenhuma exception crua de
/// Firebase/drift/local_auth deve escapar de `data/` (ver
/// `.claude/rules/architecture.md`).
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
