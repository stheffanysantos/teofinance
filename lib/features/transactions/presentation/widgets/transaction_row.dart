import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/transactions_mock_provider.dart';

/// Linha de transação com badge de categoria (ou aviso "Sem categoria" com
/// borda tracejada e ação "Categorizar", igual ao mock).
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.showTopBorder,
    required this.onCategorize,
    this.onLongPress,
  });

  final ResolvedTransaction transaction;
  final bool showTopBorder;
  final ValueChanged<String> onCategorize;
  final ValueChanged<String>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isIncome = transaction.value > 0;
    final needsCategory = transaction.needsCategory;

    final iconBg = needsCategory ? Colors.transparent : (isIncome ? t.posBg : t.track);
    final iconFg = needsCategory ? t.sub : (isIncome ? t.pos : t.ink);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress == null ? null : () => onLongPress!(transaction.id),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: showTopBorder ? Border(top: BorderSide(color: t.line)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
              border: needsCategory
                  ? Border.all(color: t.sub, width: 1.5, style: BorderStyle.solid)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              transaction.icon,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: iconFg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.ink),
                ),
                const SizedBox(height: 5),
                if (transaction.divisaoLabel != null) ...[
                  Text(
                    transaction.divisaoLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: t.sub),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: needsCategory ? Colors.transparent : t.track,
                    borderRadius: BorderRadius.circular(999),
                    border: needsCategory ? Border.all(color: t.sub) : null,
                  ),
                  child: Text(
                    transaction.category,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.sub),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrencyDelta(transaction.value),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isIncome ? t.pos : t.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (needsCategory) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => onCategorize(transaction.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Categorizar',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.accentInk),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
    );
  }
}
