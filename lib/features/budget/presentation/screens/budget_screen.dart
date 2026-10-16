import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/budget_mock_provider.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

/// Tela de Orçamento (envelopes por categoria) — implementação fiel a
/// Budget.dc.html. Acessada a partir do cartão "Despesas" do Dashboard.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final budget = ref.watch(budgetProvider);
    final notifier = ref.read(budgetProvider.notifier);
    final totalPct = (budget.totalSpent / budget.totalLimit * 100).round();
    final totalLeft = budget.totalLimit - budget.totalSpent;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 18,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Envelopes · Outubro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.sub)),
                      Text(
                        'Orçamento',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5, color: t.ink),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: notifier.addHealthEnvelope,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Icon(Icons.add, size: 24, color: t.accentInk),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total gasto', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                        AppAmountText(
                          'R\$ ${budget.totalLimit.toStringAsFixed(0)}',
                          prefix: 'Limite ',
                          style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13),
                        ),
                      ],
                    ),
                    AppAmountText(
                      'R\$ ${budget.totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: (totalPct / 100).clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: .18),
                        valueColor: AlwaysStoppedAnimation(t.accent),
                      ),
                    ),
                    AppAmountText(
                      'R\$ ${totalLeft.toStringAsFixed(0)}',
                      prefix: 'Restam ',
                      suffix: ' · 18 dias até o fim do mês',
                      style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 12,
                children: [
                  for (final envelope in budget.envelopes) _EnvelopeCard(envelope: envelope),
                ],
              ),
              GestureDetector(
                onTap: notifier.addHealthEnvelope,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: t.sub, width: 1.5, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text('+', style: TextStyle(fontSize: 20, color: t.sub)),
                      Text('Nova categoria', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.sub)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvelopeCard extends StatelessWidget {
  const _EnvelopeCard({required this.envelope});

  final BudgetEnvelope envelope;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ratio = envelope.ratio.clamp(0.0, 1.0);
    final color = envelopeColor(t, envelope.ratio);
    final remaining = envelope.limit - envelope.spent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(envelope.icon, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(envelope.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                    Text(
                      envelopeStatus(envelope.ratio, remaining),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppAmountText(
                    'R\$ ${envelope.spent.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: t.ink),
                  ),
                  AppAmountText(
                    'R\$ ${envelope.limit.toStringAsFixed(0)}',
                    prefix: 'de ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                  ),
                ],
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: t.track,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
