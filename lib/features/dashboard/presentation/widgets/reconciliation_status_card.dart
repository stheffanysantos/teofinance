import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Resumo de quantas linhas do extrato do mês já bateram com transações.
class ReconciliationStatusCard extends StatelessWidget {
  const ReconciliationStatusCard({
    super.key,
    required this.reconciliadas,
    required this.totalLinhas,
    required this.pendentes,
    required this.onTap,
  });

  final int reconciliadas;
  final int totalLinhas;
  final int pendentes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final temExtrato = totalLinhas > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reconciliação do mês',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
                ),
                if (temExtrato)
                  Text(
                    '$reconciliadas de $totalLinhas',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                  ),
              ],
            ),
            if (temExtrato) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: reconciliadas / totalLinhas,
                  minHeight: 6,
                  color: t.pos,
                  backgroundColor: t.line,
                ),
              ),
              Text(
                pendentes == 0
                    ? 'Tudo conferido com o extrato.'
                    : '$pendentes linha(s) do extrato ainda sem correspondência.',
                style: TextStyle(fontSize: 13, color: t.sub),
              ),
            ] else
              Text(
                'Importe um extrato para conferir com o que você registrou.',
                style: TextStyle(fontSize: 13, color: t.sub),
              ),
          ],
        ),
      ),
    );
  }
}
