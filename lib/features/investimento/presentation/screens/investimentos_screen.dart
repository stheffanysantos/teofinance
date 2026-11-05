import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/presentation/providers/investimento_providers.dart';
import 'package:teofinance/features/investimento/presentation/screens/investimento_form_screen.dart';

/// Carteira de investimentos cadastrados à mão, com totais e rentabilidade.
class InvestimentosScreen extends ConsumerWidget {
  const InvestimentosScreen({super.key});

  Future<void> _abrirForm(BuildContext context, WidgetRef ref, [Investimento? existente]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvestimentoFormScreen(existente: existente)),
    );
    ref.invalidate(investimentosProvider);
  }

  Future<void> _acoes(BuildContext context, WidgetRef ref, Investimento i) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () => Navigator.of(context).pop('editar'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Excluir'),
              onTap: () => Navigator.of(context).pop('excluir'),
            ),
          ],
        ),
      ),
    );
    if (acao == null || !context.mounted) return;
    if (acao == 'editar') {
      await _abrirForm(context, ref, i);
      return;
    }
    final confirmou = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir investimento?',
      mensagem: '"${i.nome}" será removido da sua carteira.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmou) return;
    await ref.read(excluirInvestimentoUseCaseProvider).call(i.id);
    ref.invalidate(investimentosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final itens = ref.watch(investimentosProvider).valueOrNull ?? const <Investimento>[];
    final resumo = ResumoInvestimentos.de(itens);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Investimentos', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funcionam os investimentos',
            paragrafos: [
              'Aqui você registra à mão o que investiu: o nome, o tipo (renda fixa, ações, FIIs...), quanto aplicou e a data.',
              'O app não consulta corretoras nem cotações. Para acompanhar a evolução, atualize o "valor atual" quando quiser (toque no item e escolha Editar).',
              'O resultado é o valor atual menos o valor investido, e a rentabilidade é esse resultado em % sobre o que foi aplicado.',
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: t.accentInk,
        onPressed: () => _abrirForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: itens.isEmpty
            ? Center(
                child: Text(
                  'Nenhum investimento cadastrado.\nToque em + para adicionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.sub),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patrimônio investido', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                        const SizedBox(height: 4),
                        AppAmountText(
                          formatCurrency(resumo.totalAtual),
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Aplicado ${formatCurrency(resumo.totalInvestido)} · '
                          '${resumo.resultado >= 0 ? '+' : ''}${resumo.rentabilidadePercentual.toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final i in itens)
                    Card(
                      color: t.card,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: t.line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => _acoes(context, ref, i),
                        title: Text(i.nome, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${i.tipo.rotulo} · aplicado ${formatCurrency(i.valorInvestido)}',
                          style: TextStyle(color: t.sub),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppAmountText(
                              formatCurrency(i.valorAtual),
                              style: TextStyle(color: t.ink, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${i.resultado >= 0 ? '+' : ''}${i.rentabilidadePercentual.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: i.resultado >= 0 ? t.pos : t.neg,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
