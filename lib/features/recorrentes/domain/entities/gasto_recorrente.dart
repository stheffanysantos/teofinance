enum CadenciaGasto {
  semanal('Semanal'),
  mensal('Mensal'),
  anual('Anual');

  const CadenciaGasto(this.rotulo);

  final String rotulo;
}

/// *Fixo*: cobra sempre o mesmo valor (assinatura, mensalidade). *Variável*:
/// repete no mesmo ritmo mas o valor oscila (luz, água, telefone).
enum RegularidadeGasto {
  fixo('Valor fixo'),
  variavel('Valor varia');

  const RegularidadeGasto(this.rotulo);

  final String rotulo;
}

/// Uma despesa que se repete num ritmo regular, descoberta no histórico.
class GastoRecorrente {
  const GastoRecorrente({
    required this.chave,
    required this.descricao,
    required this.cadencia,
    required this.regularidade,
    required this.valorTipico,
    required this.ultimoValor,
    required this.ultimaData,
    required this.proximaData,
    required this.ocorrencias,
    required this.ativa,
    this.variacaoDoUltimo,
  });

  /// Descrição normalizada que agrupou as cobranças.
  final String chave;

  /// Como a cobrança mais recente apareceu no extrato.
  final String descricao;

  final CadenciaGasto cadencia;
  final RegularidadeGasto regularidade;

  /// Valor usual de cada cobrança (positivo): o do período anterior ao último
  /// quando é fixo, a mediana quando varia.
  final double valorTipico;
  final double ultimoValor;
  final DateTime ultimaData;

  /// Estimativa: a última cobrança mais um período.
  final DateTime proximaData;
  final int ocorrencias;

  /// `false` quando a cobrança parou de aparecer há mais de um período e meio:
  /// pode ter sido cancelada.
  final bool ativa;

  /// Quanto o último valor mudou em relação ao usual (0.12 = subiu 12%). Só
  /// existe para gasto fixo; nulo quando o valor não mudou.
  final double? variacaoDoUltimo;

  bool get houveReajuste => variacaoDoUltimo != null;

  /// Quanto pesa por mês, para comparar cadências diferentes.
  double get valorMensalEstimado => switch (cadencia) {
        CadenciaGasto.mensal => valorTipico,
        CadenciaGasto.semanal => valorTipico * 52 / 12,
        CadenciaGasto.anual => valorTipico / 12,
      };
}
