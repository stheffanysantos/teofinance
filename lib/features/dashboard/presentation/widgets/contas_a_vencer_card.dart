import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/contas/domain/services/resumo_contas.dart';

/// Resumo do que há para pagar. Só aparece quando existe algo atrasado ou
/// vencendo nos próximos 7 dias.
class ContasAVencerCard extends StatelessWidget {
  const ContasAVencerCard({required this.resumo, required this.onTap, super.key});

  final ResumoContas resumo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: resumo.atrasadas > 0 ? t.neg : t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text('Contas a pagar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
            if (resumo.atrasadas > 0)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${resumo.atrasadas} ${resumo.atrasadas == 1 ? 'atrasada' : 'atrasadas'}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.neg),
                    ),
                  ),
                  AppAmountText(
                    formatCurrency(resumo.valorAtrasadas),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: t.neg),
                  ),
                ],
              ),
            if (resumo.aVencerEm7Dias > 0)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${resumo.aVencerEm7Dias} a vencer em 7 dias',
                      style: TextStyle(fontSize: 13, color: t.sub),
                    ),
                  ),
                  AppAmountText(
                    formatCurrency(resumo.valorAVencerEm7Dias),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.ink),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
