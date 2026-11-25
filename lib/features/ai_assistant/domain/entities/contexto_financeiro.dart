import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';

/// Totais de um mês, para o assistente comparar com os anteriores.
class MesResumo {
  const MesResumo({
    required this.mes,
    required this.receitas,
    required this.despesas,
  });

  final DateTime mes;
  final double receitas;
  final double despesas;

  double get saldo => receitas - despesas;
}

/// Situação de um cartão: o que está em aberto e quando vence.
class CartaoResumoIa {
  const CartaoResumoIa({
    required this.nome,
    required this.faturaAberta,
    this.vencimento,
    this.vencida = false,
    this.limite,
    this.faturasPagas = 0,
  });

  final String nome;

  /// Soma das faturas ainda não pagas, o que o banco cobra.
  final double faturaAberta;

  /// Vencimento da fatura em aberto mais próxima, se houver.
  final DateTime? vencimento;
  final bool vencida;
  final double? limite;
  final int faturasPagas;
}

/// Resumo agregado que o assistente enxerga. É propositalmente um agregado —
/// nunca a lista de transações —, para que nada além do necessário chegue ao
/// motor de resposta (ver decisão 0004 em `.claude/memory/decisions.md`).
///
/// Os campos depois de [metas] são opcionais: vazios, o assistente simplesmente
/// não fala do assunto.
class ContextoFinanceiro {
  const ContextoFinanceiro({
    required this.mes,
    required this.receitas,
    required this.despesas,
    required this.gastoPorCategoria,
    required this.envelopes,
    required this.metas,
    this.hoje,
    this.historico = const [],
    this.cartoes = const [],
    this.faturasPorMes = const [],
    this.reembolsos = const {},
    this.contasAPagar = const [],
    this.investimentos = const [],
    this.parcelasFuturas = 0,
    this.valorParcelasFuturas = 0,
  });

  final DateTime mes;
  final double receitas;
  final double despesas;

  /// Só despesas, já considerando a parte do usuário nas compras divididas.
  final Map<String, double> gastoPorCategoria;
  final List<EnvelopeOrcamento> envelopes;
  final List<Meta> metas;

  /// Dia em que o resumo foi feito (para dizer "vence em 3 dias").
  final DateTime? hoje;

  /// Meses anteriores, do mais recente para o mais antigo.
  final List<MesResumo> historico;
  final List<CartaoResumoIa> cartoes;

  /// Faturas em aberto por mês de vencimento, do mais próximo ao mais distante.
  final List<MesDeFaturas> faturasPorMes;

  /// Quanto cada pessoa ainda deve ao usuário nas compras divididas.
  final Map<String, double> reembolsos;

  /// Contas a pagar em aberto, da que vence primeiro para a última.
  final List<ContaAPagar> contasAPagar;
  final List<Investimento> investimentos;

  /// Parcelas de compras parceladas que ainda vão cair (data depois de hoje).
  final int parcelasFuturas;
  final double valorParcelasFuturas;

  double get saldo => receitas - despesas;
  bool get semMovimento => receitas == 0 && despesas == 0;

  double get totalAReceber => reembolsos.values.fold(0.0, (a, b) => a + b);
  double get totalFaturasAbertas =>
      cartoes.fold(0.0, (a, c) => a + c.faturaAberta);
  double get totalInvestido =>
      investimentos.fold(0.0, (a, i) => a + i.valorInvestido);
  double get totalInvestimentosAtual =>
      investimentos.fold(0.0, (a, i) => a + i.valorAtual);

  /// Categoria com maior gasto no mês, ou nula se não há despesas.
  MapEntry<String, double>? get maiorCategoria {
    if (gastoPorCategoria.isEmpty) return null;
    return gastoPorCategoria.entries.reduce(
      (a, b) => b.value > a.value ? b : a,
    );
  }
}
