import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Linha de transação usada em "Últimas transações" (dashboard) e na tela
/// de Transações.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.initial,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.isIncome,
    this.showTopBorder = false,
  });

  final String initial;
  final String title;
  final String subtitle;
  final String amountLabel;
  final bool isIncome;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showTopBorder ? Border(top: BorderSide(color: t.line)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isIncome ? t.posBg : t.track,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isIncome ? t.pos : t.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.ink)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: t.sub)),
              ],
            ),
          ),
          Text(
            amountLabel,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isIncome ? t.pos : t.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
