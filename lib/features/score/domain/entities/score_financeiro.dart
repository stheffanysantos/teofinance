enum FaixaScore {
  atencao('Atenção'),
  regular('Regular'),
  bom('Bom'),
  excelente('Excelente');

  const FaixaScore(this.rotulo);

  final String rotulo;
}

/// Uma das partes do score, com o que ela mediu para o usuário entender a nota.
class ComponenteScore {
  const ComponenteScore({
    required this.nome,
    required this.peso,
    required this.fracao,
    required this.detalhe,
  });

  final String nome;

  /// Importância relativa; os pesos dos componentes somam 100.
  final int peso;

  /// De 0.0 a 1.0, ou nulo quando ainda não há dado para medir (o componente
  /// fica fora da conta em vez de valer zero).
  final double? fracao;

  final String detalhe;

  bool get disponivel => fracao != null;
}

/// Nota de 0 a 1000 calculada só com dados do mês no aparelho.
class ScoreFinanceiro {
  const ScoreFinanceiro(this.componentes);

  static const maximo = 1000;

  final List<ComponenteScore> componentes;

  /// Média ponderada dos componentes que têm dado, levada a 0–1000. Nula quando
  /// nenhum tem — nunca se inventa uma nota.
  int? get pontos {
    final disponiveis = componentes.where((c) => c.disponivel).toList();
    if (disponiveis.isEmpty) return null;

    final pesoTotal = disponiveis.fold<int>(0, (soma, c) => soma + c.peso);
    final ponderado = disponiveis.fold<double>(0, (soma, c) => soma + c.peso * c.fracao!);
    return (ponderado / pesoTotal * maximo).round();
  }

  FaixaScore? get faixa {
    final p = pontos;
    if (p == null) return null;
    if (p < 400) return FaixaScore.atencao;
    if (p < 600) return FaixaScore.regular;
    if (p < 800) return FaixaScore.bom;
    return FaixaScore.excelente;
  }
}
