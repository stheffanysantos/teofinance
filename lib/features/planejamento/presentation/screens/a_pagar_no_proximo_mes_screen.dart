import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/planejamento/domain/services/a_pagar_no_proximo_mes.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';

String _dia(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Lista de tudo que vence no mês seguinte: faturas dos cartões (só a sua parte)
/// e contas a pagar, em ordem de data.
class APagarNoProximoMesScreen extends ConsumerWidget {
  const APagarNoProximoMesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final r = ref.watch(aPagarNoProximoMesProvider);
    final nomeDoMes = kMesesPorExtenso[r.mes - 1];

    Widget coluna(String rotulo, double valor) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12.5)),
              AppAmountText(
                formatCurrency(valor),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('A pagar em $nomeDoMes', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'O que entra aqui',
            paragrafos: [
              'Tudo o que vence no mês seguinte: as faturas dos cartões (só a sua parte, se houver divisão) e as contas a pagar em aberto, incluindo as que se repetem todo mês.',
              'Não entram gastos do dia a dia que ainda vão acontecer.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total a pagar em $nomeDoMes',
                          style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                      AppAmountText(
                        formatCurrency(r.total),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Row(children: [coluna('Cartões', r.cartoes), coluna('Contas', r.contas)]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (r.itens.isEmpty)
              Text('Nada a pagar em $nomeDoMes por enquanto.', style: TextStyle(color: t.sub)),
            for (final i in r.itens) _Item(item: i),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});

  final ItemAPagar item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cartao = item.tipo == TipoItemAPagar.cartao;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: t.card, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
      child: Row(
        spacing: 12,
        children: [
          Icon(cartao ? Icons.credit_card : Icons.receipt_long_outlined, size: 20, color: t.sub),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.descricao,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Vence em ${_dia(item.vencimento)} · ${cartao ? 'cartão' : 'conta'}',
                    style: TextStyle(color: t.sub, fontSize: 12)),
              ],
            ),
          ),
          AppAmountText(
            formatCurrency(item.valor),
            style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
        ],
      ),
    );
  }
}
