import 'package:flutter/material.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';

/// Transação que o usuário registrou mas não apareceu no extrato do banco.
class SemExtratoCard extends StatelessWidget {
  const SemExtratoCard({required this.transacao, super.key});

  final Transacao transacao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final d = transacao.data;
    final data = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: AppColors.aviso.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  transacao.descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.ink),
                ),
                Text('$data · não encontrada no extrato', style: TextStyle(fontSize: 11, color: t.sub)),
              ],
            ),
          ),
          AppAmountText(
            formatCurrency(transacao.valorCobrado),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: transacao.valorCobrado < 0 ? t.neg : t.pos,
            ),
          ),
        ],
      ),
    );
  }
}
