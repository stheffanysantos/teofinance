import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

/// Cartão compacto de receitas ou despesas do mês, usado em par (grid 2x1).
class IncomeExpenseStatCard extends StatelessWidget {
  const IncomeExpenseStatCard({
    super.key,
    required this.isIncome,
    required this.label,
    required this.amount,
    required this.footnote,
    this.onTap,
  });

  final bool isIncome;
  final String label;
  final String amount;
  final String footnote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tint = isIncome ? t.pos : t.neg;
    final tintBg = isIncome ? t.posBg : t.negBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: tintBg, borderRadius: BorderRadius.circular(7)),
                alignment: Alignment.center,
                child: Text(
                  isIncome ? '↓' : '↑',
                  style: TextStyle(color: tint, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: t.sub, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppAmountText(
            amount,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
              color: t.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(footnote, style: TextStyle(color: tint, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
      ),
    );
  }
}
