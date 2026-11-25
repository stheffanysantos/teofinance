import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/planejamento/domain/services/calcular_plano.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';

/// Quanto gastar em cada categoria neste mês para ainda guardar a meta escolhida.
class PlanoDoMesScreen extends ConsumerWidget {
  const PlanoDoMesScreen({super.key});

  Future<void> _aplicar(BuildContext context, WidgetRef ref, PlanoDoMes plano) async {
    final ok = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Aplicar ao orçamento?',
      mensagem: 'Os limites de ${plano.linhas.length} categorias serão definidos com os valores do plano. '
          'Limites que você já tinha nessas categorias serão substituídos.',
      rotuloConfirmar: 'Aplicar',
    );
    if (!ok || !context.mounted) return;

    final usecase = ref.read(definirLimiteOrcamentoUseCaseProvider);
    var falhas = 0;
    for (final l in plano.linhas) {
      final r = await usecase(categoria: l.categoria, limite: l.limiteSugerido);
      if (r.isLeft()) falhas++;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          falhas == 0 ? 'Orçamento atualizado com o plano.' : 'Orçamento atualizado, mas $falhas categorias falharam.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final plano = ref.watch(planoDoMesProvider);
    final pct = ref.watch(percentualGuardarProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Plano do mês', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funciona o plano do mês',
            paragrafos: [
              'O plano parte do seu salário fixo (renda fixa cadastrada em Receitas) e separa primeiro a parte que você quer guardar.',
              'O que sobra é distribuído pelas categorias com base no que você costuma gastar (média dos últimos 3 meses), respeitando as contas fixas do mês.',
              'Se não couber, só as categorias flexíveis são reduzidas, até 40% do que você gasta hoje. Moradia, saúde, mercado, alimentação, transporte e educação não são cortadas.',
              'É uma sugestão de organização. O app não recomenda onde investir.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: plano == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Cadastre seu salário em Receitas (como renda fixa) para o app montar o plano do mês.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.sub),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _Resumo(plano: plano, pct: pct),
                  const SizedBox(height: 12),
                  _Ajuste(pct: pct, plano: plano),
                  if (!plano.viavel) ...[const SizedBox(height: 12), _Aviso(plano: plano)],
                  const SizedBox(height: 16),
                  Text('Quanto gastar em cada categoria',
                      style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  if (plano.linhas.isEmpty)
                    Text(
                      'Ainda não há histórico de gastos para sugerir limites. Depois de um mês de lançamentos o plano aparece aqui.',
                      style: TextStyle(color: t.sub, fontSize: 13),
                    ),
                  for (final l in plano.linhas) _Linha(linha: l),
                  const SizedBox(height: 16),
                  if (plano.linhas.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _aplicar(context, ref, plano),
                      icon: const Icon(Icons.check),
                      label: const Text('Aplicar ao orçamento'),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Sugestão de organização, não recomendação de investimento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.sub, fontSize: 11.5),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.plano, required this.pct});

  final PlanoDoMes plano;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    TextStyle rotulo() => TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12.5);
    const valor = TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18);

    Widget coluna(String r, double v) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(r, style: rotulo()), AppAmountText(formatCurrency(v), style: valor)],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(children: [coluna('Salário', plano.salario), coluna('Guardar (${(pct * 100).round()}%)', plano.metaGuardar)]),
          Row(
            children: [
              coluna('Para gastar', plano.disponivel),
              coluna(plano.viavel ? 'Folga' : 'Falta cobrir', plano.viavel ? plano.folga : plano.faltaCobrir),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ajuste extends ConsumerWidget {
  const _Ajuste({required this.pct, required this.plano});

  final double pct;
  final PlanoDoMes plano;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(color: t.card, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quanto guardar por mês', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
          Slider(
            value: (pct * 100).clamp(0, 50),
            min: 0,
            max: 50,
            divisions: 10,
            label: '${(pct * 100).round()}%',
            onChanged: (v) => ref.read(percentualGuardarProvider.notifier).state = v / 100,
          ),
          Text(
            'Dá para guardar até ${formatCurrency(plano.guardarPossivel)} por mês cortando o que é flexível ao máximo.',
            style: TextStyle(color: t.sub, fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.plano});

  final PlanoDoMes plano;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.negBg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        'Mesmo cortando tudo o que dá, faltam ${formatCurrency(plano.faltaCobrir)} para guardar '
        '${formatCurrency(plano.metaGuardar)}. Reduza a meta de guardar para até ${formatCurrency(plano.guardarPossivel)} '
        'ou revise as despesas essenciais.',
        style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.linha});

  final LinhaDoPlano linha;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final detalhes = [
      if (linha.mediaHistorica > 0) 'gasta em média ${formatCurrency(linha.mediaHistorica)}',
      if (linha.fixoDasContas > 0) 'contas fixas ${formatCurrency(linha.fixoDasContas)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(linha.categoria,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                    ),
                    if (linha.essencial)
                      Text('essencial', style: TextStyle(color: t.sub, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ),
                if (detalhes.isNotEmpty) Text(detalhes, style: TextStyle(color: t.sub, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppAmountText(formatCurrency(linha.limiteSugerido),
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 15)),
              if (linha.corte >= 1)
                AppAmountText(formatCurrency(linha.corte),
                    prefix: 'corta ', style: TextStyle(color: t.neg, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
