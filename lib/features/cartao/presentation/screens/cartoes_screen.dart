import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/cartao/presentation/screens/cartao_form_screen.dart';
import 'package:teofinance/features/cartao/presentation/screens/fatura_screen.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';

/// Lista de cartões, com acesso à fatura de cada um.
class CartoesScreen extends ConsumerWidget {
  const CartoesScreen({super.key});

  Future<void> _form(BuildContext context, WidgetRef ref, [Cartao? existente]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CartaoFormScreen(existente: existente)));
    ref.invalidate(cartoesProvider);
  }

  Future<void> _excluir(BuildContext context, WidgetRef ref, Cartao c) async {
    final ok = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir cartão?',
      mensagem: '"${c.nome}" será removido. As compras já lançadas continuam, só deixam de aparecer em uma fatura.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!ok) return;
    await ref.read(excluirCartaoUseCaseProvider).call(c.id);
    ref.invalidate(cartoesProvider);
    ref.invalidate(lembretesPersonalizadosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const <Cartao>[];
    final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? const <Transacao>[];
    final pagamentos = ref.watch(pagamentosFaturaProvider).valueOrNull ?? const <FaturaPaga>[];
    final abertoPorCartao = {
      for (final c in cartoes)
        c.id: resumirFaturas(cartao: c, transacoes: transacoes, pagamentos: pagamentos)
            .where((f) => f.emAberto)
            .fold<double>(0, (a, f) => a + f.total),
    };
    final totalAberto = abertoPorCartao.values.fold<double>(0, (a, v) => a + v);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Cartões e faturas', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funcionam cartões e faturas',
            paragrafos: [
              'Cadastre cada cartão com o dia em que a fatura fecha e o dia em que vence.',
              'Ao lançar uma compra, escolha o cartão. A fatura reúne as compras do ciclo: da data do fechamento anterior até o dia antes do fechamento atual. A compra feita no dia do fechamento entra na fatura seguinte.',
              'A fatura que vence em novembro mostra o que foi comprado em outubro. É o total que o banco vai cobrar.',
              'Ao pagar, toque em "Marcar como paga". Isso não cria nova despesa: as compras já estão nos seus gastos, então um novo lançamento contaria duas vezes.',
              'Se você importou a fatura sem escolher o cartão, abra a fatura e use "Vincular compras sem cartão".',
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: t.accentInk,
        onPressed: () => _form(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: cartoes.isEmpty
            ? Center(
                child: Text('Nenhum cartão cadastrado.\nToque em + para adicionar.',
                    textAlign: TextAlign.center, style: TextStyle(color: t.sub)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Em aberto nos cartões',
                            style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(formatCurrency(totalAberto),
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                        Text('Soma das faturas ainda não marcadas como pagas, de todos os meses.',
                            style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  for (final c in cartoes)
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text(c.nome, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        'Fecha dia ${c.diaFechamento} · vence dia ${c.diaVencimento}'
                        ' · em aberto ${formatCurrency(abertoPorCartao[c.id] ?? 0)}'
                        '${c.limite != null ? ' · limite ${formatCurrency(c.limite!)}' : ''}',
                        style: TextStyle(color: t.sub),
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FaturaScreen(cartaoId: c.id))),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) => v == 'editar' ? _form(context, ref, c) : _excluir(context, ref, c),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
