import 'package:teofinance/core/constants/categorias.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transacao/domain/entities/transacao.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';

/// Resumo do Dashboard — saldo, receitas/despesas do mês e patrimônio
/// líquido ao longo dos últimos 6 meses, calculados a partir das
/// transações reais (ver `.claude/plans/MVP.md`, item 6).
class DashboardSummary {
  const DashboardSummary({
    required this.saldoTotal,
    required this.deltaSaldoMes,
    required this.receitasMes,
    required this.deltaReceitasPercent,
    required this.despesasMes,
    required this.despesasFootnote,
    required this.ultimasTransacoes,
  });

  final double saldoTotal;
  final double deltaSaldoMes;
  final double receitasMes;

  /// Nulo quando não há dado do mês anterior para comparar.
  final double? deltaReceitasPercent;
  final double despesasMes;
  final String despesasFootnote;

  final List<Transacao> ultimasTransacoes;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? [];
  final agora = DateTime.now();

  bool noMes(DateTime data, int ano, int mes) =>
      data.year == ano && data.month == mes;

  // O ajuste de saldo entra no saldo, mas não é receita nem despesa.
  final reais = transacoes
      .where((t) => t.categoria != kCategoriaAjusteSaldo)
      .toList();
  final transacoesEsteMes = reais.where(
    (t) => noMes(t.data, agora.year, agora.month),
  );
  final mesPassado = DateTime(agora.year, agora.month - 1);
  final transacoesMesPassado = reais.where(
    (t) => noMes(t.data, mesPassado.year, mesPassado.month),
  );

  // Receitas/despesas usam a parte do usuário (compras divididas); o saldo
  // total continua sendo o caixa real, com o valor cobrado.
  final receitasMes = transacoesEsteMes
      .where((t) => t.valorContabilizado > 0)
      .fold<double>(0, (a, t) => a + t.valorContabilizado);
  final despesasMes = transacoesEsteMes
      .where((t) => t.valorContabilizado < 0)
      .fold<double>(0, (a, t) => a + t.valorContabilizado.abs());
  final receitasMesPassado = transacoesMesPassado
      .where((t) => t.valorContabilizado > 0)
      .fold<double>(0, (a, t) => a + t.valorContabilizado);

  final saldoTotal = transacoes.fold<double>(
    0,
    (acc, t) => acc + t.valorNoSaldo,
  );
  final deltaSaldoMes = receitasMes - despesasMes;

  double? deltaReceitasPercent;
  if (receitasMesPassado > 0) {
    deltaReceitasPercent =
        (receitasMes - receitasMesPassado) / receitasMesPassado * 100;
  }

  final ultimasTransacoes = [...transacoes]
    ..sort((a, b) => b.data.compareTo(a.data));

  return DashboardSummary(
    saldoTotal: saldoTotal,
    deltaSaldoMes: deltaSaldoMes,
    receitasMes: receitasMes,
    deltaReceitasPercent: deltaReceitasPercent,
    despesasMes: despesasMes,
    despesasFootnote: despesasMes == 0
        ? 'Nenhuma despesa este mês'
        : 'Até agora este mês',
    ultimasTransacoes: ultimasTransacoes.take(5).toList(),
  );
});
