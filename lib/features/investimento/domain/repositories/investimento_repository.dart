import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';

abstract class InvestimentoRepository {
  /// Mais recentes primeiro.
  Future<Either<Failure, List<Investimento>>> listar();

  /// Cria ou, se o id já existe, atualiza.
  Future<Either<Failure, Unit>> salvar(Investimento investimento);

  Future<Either<Failure, Unit>> excluir(String id);

  // Usados só por `features/sync/` — ver `.claude/rules/architecture.md`.

  Future<List<Investimento>> listarPendentesDeSincronizacao();

  Future<List<String>> listarPendentesDeExclusao();

  Future<void> confirmarSincronizacao(String id);

  Future<void> confirmarExclusao(String id);

  /// Grava o que veio do Firestore, sem sobrescrever alteração local pendente.
  Future<void> aplicarRemoto(Investimento investimento);

  Future<void> removerAusentesNoRemoto(Set<String> idsRemotos);
}
