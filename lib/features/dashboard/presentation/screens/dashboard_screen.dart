import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_label.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../budget/presentation/screens/budget_screen.dart';
import '../../../contas/presentation/providers/conta_providers.dart';
import '../../../contas/presentation/screens/contas_screen.dart';
import '../../../goals/presentation/screens/goals_screen.dart';
import '../../../meta/presentation/providers/meta_providers.dart';
import '../../../reconciliation/presentation/providers/reconciliation_providers.dart';
import '../../../reconciliation/presentation/screens/reconciliation_screen.dart';
import '../providers/dashboard_mock_provider.dart';
import '../providers/dashboard_summary_provider.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/contas_a_vencer_card.dart';
import '../widgets/goal_ring_card.dart';
import '../widgets/income_expense_stat_card.dart';
import '../widgets/net_worth_chart_card.dart';
import '../widgets/reconciliation_status_card.dart';
import '../widgets/transaction_list_tile.dart';

/// Tela inicial — implementação fiel a Dashboard.dc.html.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final summary = ref.watch(dashboardSummaryProvider);
    final metas = ref.watch(metasStreamProvider).valueOrNull ?? [];
    final reconciliacao = ref.watch(statusReconciliacaoMesProvider).valueOrNull;
    final contasResumo = ref.watch(resumoContasProvider);
    final saldoFormatado = formatCurrency(summary.saldoTotal).split(',');

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            _TopBar(t: t),
                    BalanceHeroCard(
                      integerPart: saldoFormatado.first,
                      centsPart: saldoFormatado.length > 1 ? saldoFormatado[1] : '00',
                      deltaLabel: formatCurrency(summary.deltaSaldoMes, comSinal: true),
                    ),
                    NetWorthChartCard(
                      deltaLabel: summary.netWorthDeltaLabel,
                      rangeLabel: summary.netWorthRangeLabel,
                      months: summary.netWorthMonths,
                      values: summary.netWorthValuesNormalizados,
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: IncomeExpenseStatCard(
                            isIncome: true,
                            label: 'Receitas',
                            amount: formatCurrency(summary.receitasMes),
                            footnote: summary.deltaReceitasPercent == null
                                ? 'Receitas deste mês'
                                : '${summary.deltaReceitasPercent! >= 0 ? '+' : ''}'
                                    '${summary.deltaReceitasPercent!.toStringAsFixed(0)}% vs. mês passado',
                          ),
                        ),
                        Expanded(
                          child: IncomeExpenseStatCard(
                            isIncome: false,
                            label: 'Despesas',
                            amount: formatCurrency(summary.despesasMes),
                            footnote: summary.despesasFootnote,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BudgetScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (contasResumo != null && contasResumo.temAlgoUrgente)
                      ContasAVencerCard(
                        resumo: contasResumo,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContasScreen()),
                        ),
                      ),
                    ReconciliationStatusCard(
                      reconciliadas: reconciliacao?.matched ?? 0,
                      totalLinhas: reconciliacao?.totalLinhasExtrato ?? 0,
                      pendentes: (reconciliacao?.orphans ?? 0) + (reconciliacao?.unmatched ?? 0),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReconciliationScreen()),
                      ).then((_) => ref.invalidate(statusReconciliacaoMesProvider)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const GoalsScreen()),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Metas ativas',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
                              ),
                              Text(
                                '${metas.length} de ${metas.length}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                              ),
                            ],
                          ),
                        ),
                        if (metas.isEmpty)
                          Text(
                            'Nenhuma meta cadastrada ainda. Toque aqui para criar uma.',
                            style: TextStyle(fontSize: 13, color: t.sub),
                          )
                        else
                          SizedBox(
                            height: 192,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: metas.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final meta = metas[index];
                                final ringColorKey = meta.progresso >= .8 ? 'pos' : 'accent';
                                return GoalRingCard(
                                  title: meta.nome,
                                  progressLabel: '${meta.percentual}%',
                                  progress: meta.progresso,
                                  ringColor: goalRingColor(t, ringColorKey),
                                  amountLabel:
                                      'R\$ ${meta.valorAtual.toStringAsFixed(0)} / ${meta.valorAlvo.toStringAsFixed(0)}',
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Últimas transações',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
                            ),
                            GestureDetector(
                              onTap: () => ref.read(currentTabProvider.notifier).state = AppTab.contas,
                              child: Text(
                                'Ver todas',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                              ),
                            ),
                          ],
                        ),
                        if (summary.ultimasTransacoes.isEmpty)
                          Text(
                            'Nenhuma transação ainda. Importe um extrato ou cadastre uma em Contas.',
                            style: TextStyle(fontSize: 13, color: t.sub),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: t.card,
                              border: Border.all(color: t.line),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < summary.ultimasTransacoes.length; i++)
                                  TransactionListTile(
                                    initial: summary.ultimasTransacoes[i].descricao.isNotEmpty
                                        ? summary.ultimasTransacoes[i].descricao.substring(0, 1).toUpperCase()
                                        : '?',
                                    title: summary.ultimasTransacoes[i].descricao,
                                    subtitle:
                                        '${summary.ultimasTransacoes[i].precisaCategoria ? 'Sem categoria' : summary.ultimasTransacoes[i].categoria} · '
                                        '${rotuloDataRelativa(summary.ultimasTransacoes[i].data)}',
                                    amountLabel: formatCurrencyDelta(summary.ultimasTransacoes[i].valor),
                                    isIncome: summary.ultimasTransacoes[i].valor > 0,
                                    showTopBorder: i > 0,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}

const _mesesCompletos = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.t});

  final AppSurfaceTokens t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioAtualProvider).valueOrNull;
    final saudacao = usuario?.email != null ? 'Olá, ${usuario!.email!.split('@').first}' : 'Olá';
    final mes = _mesesCompletos[DateTime.now().month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(saudacao, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.sub)),
            Text(
              mes,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.3, color: t.ink),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 7,
                children: [
                  Transform.rotate(
                    angle: 0.785398,
                    child: Container(width: 8, height: 8, color: t.accentInk),
                  ),
                  Text(
                    '7 dias',
                    style: TextStyle(color: t.accentInk, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.card,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 20, color: t.ink),
                  Positioned(
                    top: 2,
                    right: 3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: t.neg,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.card, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
