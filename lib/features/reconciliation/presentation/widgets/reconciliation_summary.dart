import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../notifiers/reconciliation_notifier.dart';

class ReconciliationSummary extends StatelessWidget {
  final ReconciliationState state;

  const ReconciliationSummary({
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final total = state.matches.length;
    final percentual = state.percentualReconciliado;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          // Título
          Text(
            'Status da Reconciliação',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t.sub,
            ),
          ),

          // Progresso em percentual
          Column(
            spacing: 8,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reconciliado',
                    style: TextStyle(fontSize: 13, color: t.sub),
                  ),
                  Text(
                    '${percentual.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentual / 100,
                  minHeight: 8,
                  backgroundColor: t.line,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentual >= 80 ? t.pos : percentual >= 50 ? AppColors.aviso : t.neg,
                  ),
                ),
              ),
            ],
          ),

          // Grid de contadores
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              _StatCard(
                label: 'Total',
                value: total.toString(),
                color: t.ink,
              ),
              _StatCard(
                label: 'Combinados',
                value: state.totalMatched.toString(),
                color: t.pos,
              ),
              _StatCard(
                label: 'Órfãos',
                value: state.totalOrphans.toString(),
                color: AppColors.aviso,
              ),
              _StatCard(
                label: 'Pendentes',
                value: state.totalUnmatched.toString(),
                color: t.neg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: t.sub,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
