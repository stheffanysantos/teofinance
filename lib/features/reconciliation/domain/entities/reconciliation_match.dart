/// Match entre uma transação do usuário e uma linha do extrato.
class ReconciliationMatch {
  const ReconciliationMatch({
    required this.id,
    this.transacaoId,
    required this.linhaExtratoId,
    required this.dataReconciliacao,
    required this.status,
    required this.confidence,
  });

  final String id;
  // Nulo para orphans (linhas que só existem no extrato)
  final String? transacaoId;
  final String linhaExtratoId;
  final DateTime dataReconciliacao;
  // 'auto_matched' | 'manual_matched' | 'unmatched' | 'orphan'
  final String status;
  // 0.0–1.0 (1.0 = match perfeito)
  final double confidence;

  bool get isMatched => status.contains('matched');
  bool get isOrphan => status == 'orphan';
  bool get isAutoMatched => status == 'auto_matched';
}
