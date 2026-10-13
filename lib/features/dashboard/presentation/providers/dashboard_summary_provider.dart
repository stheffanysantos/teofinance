import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_label.dart';
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
    required this.netWorthMonths,
    required this.netWorthValuesNormalizados,
    required this.netWorthRangeLabel,
    required this.netWorthDeltaLabel,
    required this.ultimasTransacoes,
  });

  final double saldoTotal;
  final double deltaSaldoMes;
  final double receitasMes;

  /// Nulo quando não há dado do mês anterior para comparar.
  final double? deltaReceitasPercent;
  final double despesasMes;
  final String despesasFootnote;

  final List<String> netWorthMonths;
  final List<double> netWorthValuesNormalizados;
  final String netWorthRangeLabel;
  final String netWorthDeltaLabel;

  final List<Transacao> ultimasTransacoes;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? [];
  final agora = DateTime.now();

  double saldoAte(DateTime limite) {
    return transacoes
        .where((t) => !t.data.isAfter(limite))
        .fold<double>(0, (acc, t) => acc + t.valor);
  }

  bool noMes(DateTime data, int ano, int mes) => data.year == ano && data.month == mes;

  final transacoesEsteMes = transacoes.where((t) => noMes(t.data, agora.year, agora.month));
  final mesPassado = DateTime(agora.year, agora.month - 1);
  final transacoesMesPassado = transacoes.where((t) => noMes(t.data, mesPassado.year, mesPassado.month));

  final receitasMes = transacoesEsteMes.where((t) => t.valor > 0).fold<double>(0, (a, t) => a + t.valor);
  final despesasMes = transacoesEsteMes.where((t) => t.valor < 0).fold<double>(0, (a, t) => a + t.valor.abs());
  final receitasMesPassado =
      transacoesMesPassado.where((t) => t.valor > 0).fold<double>(0, (a, t) => a + t.valor);

  final saldoTotal = transacoes.fold<double>(0, (acc, t) => acc + t.valor);
  final deltaSaldoMes = receitasMes - despesasMes;

  double? deltaReceitasPercent;
  if (receitasMesPassado > 0) {
    deltaReceitasPercent = (receitasMes - receitasMesPassado) / receitasMesPassado * 100;
  }

  // Patrimônio líquido: saldo acumulado ao fim de cada um dos últimos 6 meses.
  final pontos = <double>[];
  final rotulosMeses = <String>[];
  for (var i = 5; i >= 0; i--) {
    final mesRef = DateTime(agora.year, agora.month - i + 1, 0); // último dia do mês
    pontos.add(saldoAte(mesRef));
    rotulosMeses.add(kMesesAbreviados[mesRef.month - 1]);
  }
  final minimo = pontos.reduce((a, b) => a < b ? a : b);
  final maximo = pontos.reduce((a, b) => a > b ? a : b);
  final amplitude = (maximo - minimo).abs();
  final normalizados = pontos
      .map((v) => amplitude == 0 ? 0.5 : (v - minimo) / amplitude)
      .toList();

  final primeiro = pontos.first;
  final ultimo = pontos.last;
  final deltaNetWorth = primeiro.abs() > 0.01 ? (ultimo - primeiro) / primeiro.abs() * 100 : null;
  final netWorthDeltaLabel = deltaNetWorth == null
      ? 'em 6 meses'
      : '${deltaNetWorth >= 0 ? '+' : ''}${deltaNetWorth.toStringAsFixed(1).replaceAll('.', ',')}% em 6 meses';

  final ultimasTransacoes = [...transacoes]
    ..sort((a, b) => b.data.compareTo(a.data));

  return DashboardSummary(
    saldoTotal: saldoTotal,
    deltaSaldoMes: deltaSaldoMes,
    receitasMes: receitasMes,
    deltaReceitasPercent: deltaReceitasPercent,
    despesasMes: despesasMes,
    despesasFootnote: despesasMes == 0 ? 'Nenhuma despesa este mês' : 'Até agora este mês',
    netWorthMonths: rotulosMeses,
    netWorthValuesNormalizados: normalizados,
    netWorthRangeLabel: '${formatCurrency(primeiro)} → ${formatCurrency(ultimo)}',
    netWorthDeltaLabel: netWorthDeltaLabel,
    ultimasTransacoes: ultimasTransacoes.take(5).toList(),
  );
});
