import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/contas/presentation/screens/conta_form_screen.dart';
import 'package:teofinance/features/contas/presentation/widgets/pagar_conta_sheet.dart';

String _data(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Contas a pagar: atrasadas, a vencer e pagas.
class ContasScreen extends ConsumerWidget {
  const ContasScreen({super.key});

  Future<void> _abrirForm(BuildContext context, {ContaAPagar? conta}) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContaFormScreen(existente: conta)));
  }

  Future<void> _pagar(BuildContext context, ContaAPagar conta) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PagarContaSheet(conta: conta),
    );
  }

  Future<void> _excluir(BuildContext context, WidgetRef ref, ContaAPagar conta) async {
    final ok = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir conta?',
      mensagem: '"${conta.descricao}" será removida. Despesas já registradas não são afetadas.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (ok) await ref.read(excluirContaUseCaseProvider)(conta.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final contas = ref.watch(contasStreamProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Contas a pagar', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        onPressed: () => _abrirForm(context),
        child: Icon(Icons.add, color: t.accentInk),
      ),
      body: SafeArea(
        child: contas.when(
          loading: () => Center(child: CircularProgressIndicator(color: t.pos)),
          error: (_, _) => Center(child: Text('Não foi possível carregar as contas.', style: TextStyle(color: t.sub))),
          data: (lista) {
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    'Nenhuma conta cadastrada.\nToque em + para adicionar uma e receber lembretes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.sub, fontSize: 14),
                  ),
                ),
              );
            }

            final hoje = DateTime.now();
            final atrasadas = lista.where((c) => c.statusEm(hoje) == StatusConta.atrasada).toList();
            final abertas = lista.where((c) => !c.paga && c.statusEm(hoje) != StatusConta.atrasada).toList();
            final pagas = lista.where((c) => c.paga).toList().reversed.take(20).toList();

            Widget secao(String titulo, List<ContaAPagar> itens) {
              if (itens.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '$titulo (${itens.length})',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
                    ),
                  ),
                  for (final c in itens)
                    _ContaCard(
                      conta: c,
                      hoje: hoje,
                      onPagar: c.paga ? null : () => _pagar(context, c),
                      onEditar: c.paga ? null : () => _abrirForm(context, conta: c),
                      onExcluir: () => _excluir(context, ref, c),
                    ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
              children: [secao('Atrasadas', atrasadas), secao('A vencer', abertas), secao('Pagas', pagas)],
            );
          },
        ),
      ),
    );
  }
}

class _ContaCard extends StatelessWidget {
  const _ContaCard({
    required this.conta,
    required this.hoje,
    required this.onExcluir,
    this.onPagar,
    this.onEditar,
  });

  final ContaAPagar conta;
  final DateTime hoje;
  final VoidCallback? onPagar;
  final VoidCallback? onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final status = conta.statusEm(hoje);
    final dias = conta.diasParaVencer(hoje);

    final (texto, cor) = switch (status) {
      StatusConta.paga => ('Paga em ${_data(conta.dataPagamento ?? conta.vencimento)}', t.pos),
      StatusConta.atrasada => ('Atrasada há ${-dias} ${dias == -1 ? 'dia' : 'dias'}', t.neg),
      StatusConta.venceHoje => ('Vence hoje', t.neg),
      StatusConta.aVencer => ('Vence ${_data(conta.vencimento)} · em $dias ${dias == 1 ? 'dia' : 'dias'}', t.sub),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  conta.descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
                ),
              ),
              AppAmountText(
                formatCurrency(conta.paga ? (conta.valorPago ?? conta.valor) : conta.valor),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.ink),
              ),
            ],
          ),
          Text(
            conta.recorrencia == RecorrenciaConta.nenhuma ? texto : '$texto · ${conta.recorrencia.rotulo.toLowerCase()}',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: cor),
          ),
          Row(
            spacing: 8,
            children: [
              if (onPagar != null) Expanded(child: FilledButton(onPressed: onPagar, child: const Text('Pagar'))),
              if (onEditar != null)
                IconButton(onPressed: onEditar, icon: Icon(Icons.edit_outlined, color: t.ink), tooltip: 'Editar'),
              IconButton(onPressed: onExcluir, icon: Icon(Icons.delete_outline, color: t.neg), tooltip: 'Excluir'),
            ],
          ),
        ],
      ),
    );
  }
}
