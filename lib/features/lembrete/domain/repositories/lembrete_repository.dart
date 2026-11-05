import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';

abstract class LembreteRepository {
  Future<Either<Failure, List<LembretePersonalizado>>> listar();

  /// Cria (id vazio) ou atualiza.
  Future<Either<Failure, Unit>> salvar(LembretePersonalizado lembrete);

  Future<Either<Failure, Unit>> excluir(String id);

  // Usados só por `features/sync/` — ver `.claude/rules/architecture.md`.

  Future<List<LembretePersonalizado>> listarPendentesDeSincronizacao();

  Future<List<String>> listarPendentesDeExclusao();

  Future<void> confirmarSincronizacao(String id);

  Future<void> confirmarExclusao(String id);

  /// Grava o que veio do Firestore, sem sobrescrever alteração local pendente.
  Future<void> aplicarRemoto(LembretePersonalizado lembrete);

  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos);
}
