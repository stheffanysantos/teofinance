import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/extrato_linha.dart';
import '../../domain/entities/reconciliation_match.dart';

class OrphanCard extends StatelessWidget {
  final ReconciliationMatch match;
  final ExtratoLinha? linha;

  const OrphanCard({required this.match, this.linha, super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = linha;
    final data = l == null
        ? ''
        : '${l.data.day.toString().padLeft(2, '0')}/${l.data.month.toString().padLeft(2, '0')}/${l.data.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: AppColors.aviso.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.help_outline, color: AppColors.aviso),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l?.descricao ?? 'Linha do extrato',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.ink),
                ),
                Text(
                  'Sem lançamento correspondente${data.isEmpty ? '' : ' · $data'}',
                  style: TextStyle(fontSize: 11, color: t.sub),
                ),
              ],
            ),
          ),
          if (l != null)
            Text(
              l.valorAsTransacao.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: l.valorAsTransacao < 0 ? t.neg : t.pos,
              ),
            ),
        ],
      ),
    );
  }
}
