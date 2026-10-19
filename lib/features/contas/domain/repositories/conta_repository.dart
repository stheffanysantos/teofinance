import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';

abstract class ContaRepository {
  /// Todas as contas, as que vencem antes primeiro.
  Stream<List<ContaAPagar>> observarTodas();

  Future<Either<Failure, ContaAPagar>> criar({
    required String descricao,
    required double valor,
    required DateTime vencimento,
    String categoria,
    RecorrenciaConta recorrencia,
    int diasAntesLembrete,
    int? diaBase,
  });

  /// Troca os dados editáveis de uma conta ainda não paga.
  Future<Either<Failure, ContaAPagar>> atualizar(ContaAPagar conta);

  Future<Either<Failure, Unit>> excluir(String id);

  Future<Either<Failure, Unit>> marcarComoPaga({
    required String id,
    required double valorPago,
    required DateTime dataPagamento,
    String? transacaoId,
  });

  /// Usado só por `features/sync/` — ver `.claude/rules/architecture.md`.
  Future<List<ContaAPagar>> listarPendentesDeSincronizacao();

  Future<List<ContaAPagar>> listarPendentesDeExclusao();

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> confirmarExclusao(String id);

  Future<void> aplicarRemoto(ContaAPagar conta);
}
