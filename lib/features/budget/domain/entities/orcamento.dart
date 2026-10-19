/// Limite mensal definido pelo usuário para uma categoria.
class Orcamento {
  const Orcamento({required this.id, required this.categoria, required this.limite, this.remoteId});

  final String id;

  /// Id do documento no Firestore; nulo até a primeira sincronização.
  final String? remoteId;
  final String categoria;
  final double limite;
}

/// Um envelope do mês: o limite da categoria e quanto já foi gasto nela.
class EnvelopeOrcamento {
  const EnvelopeOrcamento({
    required this.orcamento,
    required this.gasto,
  });

  final Orcamento orcamento;
  final double gasto;

  String get categoria => orcamento.categoria;
  double get limite => orcamento.limite;
  double get restante => limite - gasto;
  double get proporcao => gasto / limite;
  bool get estourado => gasto > limite;
}

/// Todos os envelopes do mês e os totais.
class ResumoOrcamento {
  const ResumoOrcamento(this.envelopes);

  final List<EnvelopeOrcamento> envelopes;

  double get totalGasto => envelopes.fold(0.0, (soma, e) => soma + e.gasto);
  double get totalLimite => envelopes.fold(0.0, (soma, e) => soma + e.limite);
  double get totalRestante => totalLimite - totalGasto;
  double get proporcao => totalLimite == 0 ? 0 : totalGasto / totalLimite;
}
