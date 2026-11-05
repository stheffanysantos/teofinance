import 'package:flutter/material.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/relatorio/domain/services/gastos_por_categoria.dart';

/// Ranking das categorias em que mais se gastou no mês (top 5), com barras
/// proporcionais e a fatia de cada uma no total.
String _variacao(double v) {
  final pct = v.abs().round();
  if (pct == 0) return 'Igual ao mês passado';
  return v > 0 ? '+$pct% que no mês passado' : '-$pct% que no mês passado';
}

class CategoryRankingCard extends StatelessWidget {
  const CategoryRankingCard({super.key, required this.gastos});

  final List<GastoCategoria> gastos;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final total = gastos.fold<double>(0, (a, g) => a + g.valor);
    final top = gastos.take(5).toList();
    final maior = top.isEmpty ? 1.0 : top.first.valor;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Onde você mais gasta no mês',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: t.ink,
            ),
          ),
          if (top.isEmpty)
            Text(
              'Sem despesas neste mês ainda.',
              style: TextStyle(color: t.sub, fontSize: 13),
            )
          else ...[
            for (var i = 0; i < top.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${i + 1}. ${top[i].categoria}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                          ),
                        ),
                      ),
                      AppAmountText(
                        '${formatCurrency(top[i].valor)} · ${(top[i].valor / total * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: t.sub,
                        ),
                      ),
                    ],
                  ),
                  if (top[i].variacaoPercent != null)
                    Text(
                      _variacao(top[i].variacaoPercent!),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: top[i].variacaoPercent! > 0 ? t.neg : t.pos,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: top[i].valor / maior,
                      minHeight: 8,
                      color: t.hero,
                      backgroundColor: t.track,
                    ),
                  ),
                ],
              ),
            Text(
              'Total de despesas no mês: ${formatCurrency(total)}',
              style: TextStyle(fontSize: 12, color: t.sub),
            ),
          ],
        ],
      ),
    );
  }
}
