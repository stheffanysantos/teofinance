import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/cartao/presentation/screens/fatura_screen.dart';

const _mesesNoGrafico = 6;

String _mesCurto(int mes) {
  final nome = kMesesPorExtenso[mes - 1];
  return '${nome[0].toUpperCase()}${nome.substring(1, 3)}';
}

String _data(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// "Próximos meses": quanto vence de fatura em cada mês, somando todos os
/// cartões, com a divisão por cartão dentro de cada mês. Parcelas futuras já
/// aparecem no mês em que caem. Some se não há fatura em aberto.
class ProximasFaturasSecao extends ConsumerWidget {
  const ProximasFaturasSecao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meses = ref.watch(proximasFaturasProvider);
    if (meses.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;
    final maior = meses.map((m) => m.total).reduce((a, b) => a > b ? a : b);

    // Material (e não Container colorido): os ListTile precisam de um Material
    // por trás para o toque aparecer.
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Material(
        color: t.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: t.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximos meses',
                          style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Faturas por mês de vencimento, somando todos os cartões.',
                          style: TextStyle(color: t.sub, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total a vencer', style: TextStyle(color: t.sub, fontSize: 11)),
                      AppAmountText(
                        formatCurrency(meses.fold(0.0, (a, m) => a + m.total)),
                        style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Grafico(meses: meses.take(_mesesNoGrafico).toList()),
              const SizedBox(height: 6),
              Divider(height: 1, color: t.line),
              for (final mes in meses) _MesTile(mes: mes, maior: maior),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grafico extends StatelessWidget {
  const _Grafico({required this.meses});

  final List<MesDeFaturas> meses;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final maior = meses.map((m) => m.total).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          for (final m in meses)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 4,
                children: [
                  AppAmountText(
                    'R\$ ${m.total.round()}',
                    style: TextStyle(
                      color: t.sub,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    height: maior <= 0 ? 6 : 6 + 80 * (m.total / maior),
                    decoration: BoxDecoration(
                      color: m.vencida ? t.neg : (m.total == maior ? t.hero : t.hero.withValues(alpha: .35)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Text(
                    _mesCurto(m.mes),
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MesTile extends StatelessWidget {
  const _MesTile({required this.mes, required this.maior});

  final MesDeFaturas mes;
  final double maior;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final nome = kMesesPorExtenso[mes.mes - 1];
    final titulo = '${nome[0].toUpperCase()}${nome.substring(1)} de ${mes.ano}';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (mes.vencida ? t.neg : t.hero).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _mesCurto(mes.mes),
            style: TextStyle(color: mes.vencida ? t.neg : t.hero, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          titulo,
          style: TextStyle(
            color: t.ink,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              mes.vencida
                  ? 'Vencida · ${mes.faturas.length == 1 ? '1 cartão' : '${mes.faturas.length} cartões'}'
                  : 'Vence a partir de ${_data(mes.primeiroVencimento)} · ${mes.faturas.length == 1 ? '1 cartão' : '${mes.faturas.length} cartões'}',
              style: TextStyle(color: mes.vencida ? t.neg : t.sub, fontSize: 12),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maior <= 0 ? 0 : (mes.total / maior).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: t.track,
                color: mes.vencida ? t.neg : t.hero,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppAmountText(
              formatCurrency(mes.total),
              style: TextStyle(
                color: t.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            if (mes.temDivisao)
              AppAmountText(
                formatCurrency(mes.minhaParte),
                prefix: 'sua parte ',
                style: TextStyle(color: t.sub, fontSize: 11),
              ),
          ],
        ),
        children: [
          for (final f in mes.faturas)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 8),
              leading: Icon(Icons.credit_card, size: 18, color: t.sub),
              title: Text(
                f.cartao.nome,
                style: TextStyle(color: t.ink, fontSize: 13.5),
              ),
              subtitle: Text(
                'Vence em ${_data(f.vencimento)}${f.vencida ? ' (vencida)' : ''}',
                style: TextStyle(
                  color: f.vencida ? t.neg : t.sub,
                  fontSize: 11.5,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppAmountText(
                    formatCurrency(f.total),
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
                  ),
                  if (f.temDivisao)
                    AppAmountText(
                      formatCurrency(f.minhaParte),
                      prefix: 'sua parte ',
                      style: TextStyle(color: t.sub, fontSize: 11),
                    ),
                ],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FaturaScreen(
                    cartaoId: f.cartao.id,
                    faturaInicial: (ano: mes.ano, mes: mes.mes),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
