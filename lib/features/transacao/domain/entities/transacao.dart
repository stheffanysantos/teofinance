import '../../../../core/sync/sync_status.dart';

/// Uma transação persistida (seja por importação de extrato, seja
/// cadastrada manualmente) — ver `.claude/plans/MVP.md`, item 4.
/// Pode ser uma transação normal ou uma parcela de um parcelamento
/// (ver `.claude/plans/Sprint02-Parcelamento.md`).
class Transacao {
  const Transacao({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
    // Campos de parcelamento (nulos se não é uma parcela)
    this.parcelamentoId,
    this.numeroParcela,
    this.valorParcela,
    this.ehParcela = false,
    this.statusParcela,
  });

  final String id;
  final String descricao;

  /// Vazio = sem categoria (precisa de categorização manual).
  final String categoria;
  final double valor;
  final DateTime data;

  /// Id do documento no Firestore; nulo até a primeira sincronização.
  final String? remoteId;
  final SyncStatus syncStatus;

  /// Parcelamento: campos adicionados na v5 do Drift (Sprint 02)
  final String? parcelamentoId;
  final int? numeroParcela;
  final double? valorParcela;
  final bool ehParcela;
  final String? statusParcela;

  bool get precisaCategoria => categoria.trim().isEmpty;
  bool get isReceita => valor > 0;

  /// Se é uma parcela, usa o `valorParcela` para cálculos (ex: dashboard);
  /// senão, usa o `valor` normal.
  double get valorContabilizado => ehParcela ? (valorParcela ?? valor) : valor;
}
