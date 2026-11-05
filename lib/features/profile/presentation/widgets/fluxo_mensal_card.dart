import 'package:flutter/material.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/relatorio/domain/services/fluxo_mensal.dart';

const _rotulosMes = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

/// Barras de receitas x despesas dos últimos meses, com a frase que resume a
/// tendência: quanto sobrou (ou faltou) no período.
class FluxoMensalCard extends StatelessWidget {
  const FluxoMensalCard({super.key, required this.meses});

  final List<FluxoMes> meses;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final maior = meses.fold<double>(
      0,
      (m, f) => [m, f.receitas, f.despesas].reduce((a, b) => a > b ? a : b),
    );
    final totalReceitas = meses.fold<double>(0, (a, f) => a + f.receitas);
    final totalDespesas = meses.fold<double>(0, (a, f) => a + f.despesas);
    final sobra = totalReceitas - totalDespesas;
    final temDados = maior > 0;

    final String resumo;
    if (!temDados) {
      resumo = 'Importe ou lance transações para ver seu fluxo mensal.';
    } else if (totalReceitas > 0) {
      final pct = (sobra / totalReceitas * 100).round();
      resumo = sobra >= 0
          ? 'Nos últimos ${meses.length} meses você guardou ${formatCurrency(sobra)} ($pct% do que recebeu).'
          : 'Nos últimos ${meses.length} meses você gastou ${formatCurrency(-sobra)} a mais do que recebeu.';
    } else {
      resumo =
          'Nos últimos ${meses.length} meses você gastou ${formatCurrency(totalDespesas)}.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: t.hero,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Receitas x despesas',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final f in meses)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 3,
                            children: [
                              _Barra(
                                fracao: temDados ? f.receitas / maior : 0,
                                cor: t.pos,
                              ),
                              _Barra(
                                fracao: temDados ? f.despesas / maior : 0,
                                cor: t.neg,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _rotulosMes[f.mes - 1],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Row(
            spacing: 14,
            children: [
              _Legenda(cor: t.pos, texto: 'Receitas'),
              _Legenda(cor: t.neg, texto: 'Despesas'),
            ],
          ),
          Text(
            resumo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.fracao, required this.cor});

  final double fracao;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: fracao.clamp(0.02, 1.0),
      child: Container(
        width: 11,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        Text(
          texto,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
