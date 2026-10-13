import '../../../../core/sync/sync_status.dart';

/// Ver glossário (`.claude/memory/domain-glossary.md`): Renda Fixa tem
/// recorrência definida (salário, aluguel recebido); Renda Variável é
/// pontual (freela, venda avulsa) — nunca uma Transação (que é um
/// lançamento já ocorrido, vindo de extrato ou cadastro manual).
enum TipoRenda { fixa, variavel }

enum RecorrenciaRenda { semanal, mensal, anual }

class Renda {
  const Renda({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.dataRecebimento,
    this.recorrencia,
    this.ativa = true,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  final String id;
  final String descricao;
  final double valor;
  final TipoRenda tipo;

  /// Data do próximo recebimento esperado (fixa) ou data única (variável).
  final DateTime dataRecebimento;

  /// Só preenchido quando [tipo] é [TipoRenda.fixa].
  final RecorrenciaRenda? recorrencia;

  /// Permite pausar uma renda fixa sem apagar o histórico.
  final bool ativa;

  final String? remoteId;
  final SyncStatus syncStatus;

  bool get isFixa => tipo == TipoRenda.fixa;
}
