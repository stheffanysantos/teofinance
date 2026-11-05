/// Cartão de crédito cadastrado à mão. Define o ciclo da fatura: ela fecha no
/// [diaFechamento] e vence no [diaVencimento] (1–31; em meses curtos vale o
/// último dia).
class Cartao {
  const Cartao({
    required this.id,
    required this.nome,
    required this.diaFechamento,
    required this.diaVencimento,
    this.limite,
  });

  /// Vazio enquanto não foi salvo; o repositório gera um id.
  final String id;
  final String nome;
  final int diaFechamento;
  final int diaVencimento;
  final double? limite;

  Cartao copyWith({String? nome, int? diaFechamento, int? diaVencimento, double? limite}) {
    return Cartao(
      id: id,
      nome: nome ?? this.nome,
      diaFechamento: diaFechamento ?? this.diaFechamento,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      limite: limite ?? this.limite,
    );
  }
}

/// Pagamento registrado de uma fatura. [mes] e [ano] são os do vencimento.
class FaturaPaga {
  const FaturaPaga({
    required this.cartaoId,
    required this.ano,
    required this.mes,
    required this.valor,
    required this.dataPagamento,
  });

  final String cartaoId;
  final int ano;
  final int mes;
  final double valor;
  final DateTime dataPagamento;

  String get id => idFatura(cartaoId, ano, mes);
}

String idFatura(String cartaoId, int ano, int mes) => '$cartaoId|$ano-$mes';
