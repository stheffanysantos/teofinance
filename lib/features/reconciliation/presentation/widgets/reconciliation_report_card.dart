import 'package:flutter/material.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../notifiers/reconciliation_notifier.dart';

/// Relatório do período: o que o usuário registrou x o que o banco registrou.
class ReconciliationReportCard extends StatelessWidget {
  const ReconciliationReportCard({required this.state, super.key});

  final ReconciliationState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final diferenca = state.diferenca;
    final bateu = diferenca.abs() < 0.005;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            'Relatório do período',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.sub),
          ),
          _Linha(rotulo: 'Você registrou', valor: formatCurrency(state.totalRegistrado), cor: t.ink),
          _Linha(rotulo: 'O banco registrou', valor: formatCurrency(state.totalBanco), cor: t.ink),
          Divider(height: 1, color: t.line),
          _Linha(
            rotulo: 'Diferença',
            valor: bateu ? formatCurrency(0) : formatCurrency(diferenca, comSinal: true),
            cor: bateu ? t.pos : t.neg,
            destaque: true,
          ),
          _Linha(rotulo: 'Seu gasto real (sua parte)', valor: formatCurrency(state.gastoReal), cor: t.ink),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.rotulo, required this.valor, required this.cor, this.destaque = false});

  final String rotulo;
  final String valor;
  final Color cor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: TextStyle(fontSize: 13, color: t.sub)),
        AppAmountText(
          valor,
          style: TextStyle(
            fontSize: destaque ? 15 : 13,
            fontWeight: destaque ? FontWeight.w800 : FontWeight.w600,
            color: cor,
          ),
        ),
      ],
    );
  }
}
