/// Tipos de investimento cadastráveis à mão.
enum TipoInvestimento {
  rendaFixa('Renda fixa'),
  tesouroDireto('Tesouro Direto'),
  cdb('CDB / LCI / LCA'),
  poupanca('Poupança'),
  acoes('Ações'),
  fiis('Fundos imobiliários'),
  fundos('Fundos de investimento'),
  previdencia('Previdência'),
  cripto('Criptomoedas'),
  outro('Outro');

  const TipoInvestimento(this.rotulo);

  final String rotulo;

  static TipoInvestimento deNome(String nome) {
    return TipoInvestimento.values.firstWhere((t) => t.name == nome, orElse: () => TipoInvestimento.outro);
  }
}

/// Um investimento registrado manualmente (o app não consulta corretoras).
class Investimento {
  const Investimento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.valorInvestido,
    required this.valorAtual,
    required this.dataAplicacao,
    this.observacao = '',
  });

  final String id;
  final String nome;
  final TipoInvestimento tipo;

  /// Quanto foi aplicado.
  final double valorInvestido;

  /// Quanto vale hoje (informado pelo usuário).
  final double valorAtual;
  final DateTime dataAplicacao;
  final String observacao;

  double get resultado => valorAtual - valorInvestido;

  /// Rentabilidade em % sobre o valor investido; 0 se nada foi investido.
  double get rentabilidadePercentual => valorInvestido == 0 ? 0 : resultado / valorInvestido * 100;
}

/// Totais da carteira.
class ResumoInvestimentos {
  const ResumoInvestimentos({required this.totalInvestido, required this.totalAtual});

  factory ResumoInvestimentos.de(List<Investimento> itens) => ResumoInvestimentos(
        totalInvestido: itens.fold(0, (a, i) => a + i.valorInvestido),
        totalAtual: itens.fold(0, (a, i) => a + i.valorAtual),
      );

  final double totalInvestido;
  final double totalAtual;

  double get resultado => totalAtual - totalInvestido;
  double get rentabilidadePercentual => totalInvestido == 0 ? 0 : resultado / totalInvestido * 100;
}
