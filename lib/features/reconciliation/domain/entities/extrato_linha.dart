/// Uma linha do extrato bancário importado.
/// Intermediária entre importação e reconciliação.
class ExtratoLinha {
  const ExtratoLinha({
    required this.id,
    required this.importId,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.nomeBancoOriginal,
  });

  final String id;
  final String importId; // Qual importação trouxe esta linha
  final String descricao; // "SUPERMERCADO X 123"
  final double valor;
  final DateTime data;
  final String tipo; // 'D' (débito) | 'C' (crédito)
  final String nomeBancoOriginal; // Como veio do banco

  bool get isDebito => tipo == 'D';
  bool get isCredito => tipo == 'C';

  /// Converter para transação para fins de matching.
  /// Usa a lógica: débito = gasto (negativo), crédito = receita (positivo).
  double get valorAsTransacao => isDebito ? -valor : valor;
}
