import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';

/// Direitos do titular previstos na LGPD: acesso (exportar) e eliminação
/// (excluir) de todos os dados do usuário — ver `.claude/rules/security.md`.
abstract class LgpdRepository {
  /// Todos os dados pessoais guardados para o usuário, como JSON legível.
  Future<Either<Failure, String>> exportarDados();

  /// Apaga os dados no Firestore, a conta no Firebase Authentication e a cópia
  /// local. A [senha] reautentica o usuário: sem ela o Firebase recusa apagar
  /// a conta de uma sessão antiga.
  Future<Either<Failure, Unit>> excluirTodosOsDados({required String senha});
}
