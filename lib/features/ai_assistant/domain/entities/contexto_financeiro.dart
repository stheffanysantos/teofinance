import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';

/// Resumo agregado do mês que o assistente enxerga. É propositalmente um
/// agregado — nunca a lista de transações —, para que nada além do necessário
/// chegue ao motor de resposta (ver decisão 0004 em `.claude/memory/decisions.md`).
class ContextoFinanceiro {
  const ContextoFinanceiro({
    required this.mes,
    required this.receitas,
    required this.despesas,
    required this.gastoPorCategoria,
    required this.envelopes,
    required this.metas,
  });

  final DateTime mes;
  final double receitas;
  final double despesas;

  /// Só despesas, já considerando a parte do usuário nas compras divididas.
  final Map<String, double> gastoPorCategoria;
  final List<EnvelopeOrcamento> envelopes;
  final List<Meta> metas;

  double get saldo => receitas - despesas;
  bool get semMovimento => receitas == 0 && despesas == 0;

  /// Categoria com maior gasto no mês, ou nula se não há despesas.
  MapEntry<String, double>? get maiorCategoria {
    if (gastoPorCategoria.isEmpty) return null;
    return gastoPorCategoria.entries.reduce((a, b) => b.value > a.value ? b : a);
  }
}
