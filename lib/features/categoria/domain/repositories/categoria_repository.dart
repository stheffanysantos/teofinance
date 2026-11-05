import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';

/// Categorias criadas pelo usuário (as padrão ficam em `kCategorias`).
abstract class CategoriaRepository {
  Future<Either<Failure, List<String>>> listar();

  Future<Either<Failure, Unit>> adicionar(String nome);

  Future<Either<Failure, Unit>> remover(String nome);

  // Usados só por `features/sync/` — ver `.claude/rules/architecture.md`.

  Future<List<String>> listarPendentesDeSincronizacao();

  Future<List<String>> listarPendentesDeExclusao();

  Future<void> confirmarSincronizacao(String nome);

  Future<void> confirmarExclusao(String nome);

  /// Grava o que veio do Firestore, sem sobrescrever alteração local pendente.
  Future<void> aplicarRemoto(String nome);

  Future<void> removerAusentesNoRemoto(Set<String> nomesRemotos);
}
