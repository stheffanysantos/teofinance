import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/planejamento/domain/services/simular_parcelamento.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';

String _mesAno(int ano, int mes) {
  final nome = kMesesPorExtenso[mes - 1];
  return '${nome[0].toUpperCase()}${nome.substring(1, 3)}/$ano';
}

/// "E se eu parcelar isto?": mostra como as faturas dos próximos meses ficam,
/// antes de fazer a compra. Nada é lançado.
class SimuladorParcelamentoScreen extends ConsumerWidget {
  const SimuladorParcelamentoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
    final cartao = ref.watch(cartaoDoSimuladorProvider);
    final parcelas = ref.watch(parcelasSimuladasProvider);
    final simulacao = ref.watch(simulacaoProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Simular compra parcelada', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funciona o simulador',
            paragrafos: [
              'Informe o valor da compra, em quantas vezes e em qual cartão. O app mostra quanto cada parcela pesa na fatura de cada mês, somando o que você já tem para pagar.',
              'A primeira parcela cai na fatura em que uma compra feita hoje entraria, pelo dia de fechamento do cartão.',
              'Nada é lançado: é só uma simulação.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: cartoes.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Cadastre um cartão para simular uma compra parcelada.',
                      textAlign: TextAlign.center, style: TextStyle(color: t.sub)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor da compra (R\$)', border: OutlineInputBorder()),
                    onChanged: (v) =>
                        ref.read(valorSimuladoProvider.notifier).state = double.tryParse(v.replaceAll(',', '.')) ?? 0,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: cartao?.id,
                    decoration: const InputDecoration(labelText: 'Cartão', border: OutlineInputBorder()),
                    items: [for (final c in cartoes) DropdownMenuItem(value: c.id, child: Text(c.nome))],
                    onChanged: (id) => ref.read(cartaoSimuladoProvider.notifier).state = id,
                  ),
                  const SizedBox(height: 12),
                  Text('Parcelas: ${parcelas}x', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                  Slider(
                    value: parcelas.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '${parcelas}x',
                    onChanged: (v) => ref.read(parcelasSimuladasProvider.notifier).state = v.round(),
                  ),
                  const SizedBox(height: 8),
                  if (simulacao == null)
                    Text('Digite o valor para ver o efeito nas próximas faturas.', style: TextStyle(color: t.sub))
                  else
                    _Resultado(simulacao: simulacao),
                ],
              ),
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado({required this.simulacao});

  final SimulacaoDeParcelamento simulacao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pesado = simulacao.mesMaisPesado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cada parcela', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
              AppAmountText(
                formatCurrency(simulacao.valorDaParcela),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              if (pesado != null)
                AppAmountText(
                  formatCurrency(pesado.depois),
                  prefix: 'Fatura mais pesada: ${_mesAno(pesado.ano, pesado.mes)}, ',
                  style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 12.5),
                ),
            ],
          ),
        ),
        if (simulacao.ultrapassaLimite)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.negBg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Passa do limite do cartão: com a compra, o uso iria a ${formatCurrency(simulacao.usoDoLimiteDepois!)} '
              'de ${formatCurrency(simulacao.limite!)}.',
              style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        for (final m in simulacao.meses)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 74,
                  child: Text(_mesAno(m.ano, m.mes), style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: AppAmountText(
                    formatCurrency(m.jaComprometido),
                    prefix: 'já vence ',
                    suffix: ' + parcela ${formatCurrency(m.parcela)}',
                    style: TextStyle(color: t.sub, fontSize: 12),
                  ),
                ),
                AppAmountText(
                  formatCurrency(m.depois),
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
