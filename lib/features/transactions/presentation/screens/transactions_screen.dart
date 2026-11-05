import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categoria/presentation/providers/categoria_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../connect/presentation/screens/connect_screen.dart';
import '../../../parcelamento/presentation/screens/parcelar_transacao_screen.dart';
import '../../../reconciliation/presentation/screens/reconciliation_screen.dart';
import '../../../transacao/presentation/screens/nova_transacao_screen.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';
import '../../../transacao/presentation/screens/dividir_transacao_screen.dart';
import '../providers/transactions_view_providers.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/transaction_row.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';

/// Tela de Transações — implementação fiel a Transactions.dc.html: filtros
/// de período/categoria em pílula, grupos por data, categorização manual
/// de lançamentos sem categoria.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final filter = ref.watch(transactionsFilterProvider);
    final filterNotifier = ref.read(transactionsFilterProvider.notifier);
    final groups = ref.watch(visibleTransactionGroupsProvider);
    final categoriasFiltro = ref.watch(categoriasFiltroProvider);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 14,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transações',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5,
                            color: t.ink,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ConnectScreen(),
                                ),
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: t.card,
                                  border: Border.all(color: t.line),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.add, size: 20, color: t.ink),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReconciliationScreen(),
                                ),
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: t.card,
                                  border: Border.all(color: t.line),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.fact_check_outlined,
                                  size: 18,
                                  color: t.ink,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: filterNotifier.alternarBusca,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: filter.buscando ? t.hero : t.card,
                                  border: Border.all(color: t.line),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  filter.buscando ? Icons.close : Icons.search,
                                  size: 18,
                                  color: filter.buscando ? t.accent : t.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (filter.buscando)
                      TextField(
                        autofocus: true,
                        onChanged: filterNotifier.pesquisar,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Buscar por descrição ou categoria',
                          helperText: filter.temBusca
                              ? 'Buscando em todos os períodos'
                              : null,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: t.card.withValues(alpha: 0.35),
                        ),
                      ),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kTransactionPeriods.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final period = kTransactionPeriods[i];
                          return AppFilterChip(
                            label: period,
                            selected: filter.period == period,
                            outlinedWhenUnselected: true,
                            onTap: () => filterNotifier.selectPeriod(period),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: t.line)),
                      ),
                      child: SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoriasFiltro.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final category = categoriasFiltro[i];
                            return AppFilterChip(
                              label: category,
                              selected: filter.category == category,
                              onTap: () =>
                                  filterNotifier.selectCategory(category),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: groups.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma transação nesta categoria.',
                          style: TextStyle(color: t.sub, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        itemCount: groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    group.date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: t.sub,
                                    ),
                                  ),
                                  AppAmountText(
                                    group.totalLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: t.sub,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: t.card,
                                  border: Border.all(color: t.line),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    for (var i = 0; i < group.items.length; i++)
                                      TransactionRow(
                                        transaction: group.items[i],
                                        showTopBorder: i > 0,
                                        onCategorize: (id) =>
                                            _escolherCategoria(
                                              context,
                                              filterNotifier,
                                              id,
                                              categoriasFiltro.skip(1).toList(),
                                            ),
                                        onLongPress: (id) =>
                                            _abrirAcoes(context, ref, id),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: t.accent,
              foregroundColor: t.accentInk,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NovaTransacaoScreen()),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirAcoes(
    BuildContext context,
    WidgetRef ref,
    String transacaoId,
  ) async {
    final transacoes = ref.read(transacoesStreamProvider).valueOrNull ?? [];
    final transacao = transacoes.where((x) => x.id == transacaoId).firstOrNull;
    if (transacao == null) return;

    final ehDespesa = transacao.valor < 0;
    final podeParcelar =
        !transacao.ehParcela && !transacao.ehDividida && ehDespesa;
    // Parcela e compra dividida têm valores derivados; editar o valor ali
    // deixaria o parcelamento/divisão inconsistente.
    final podeEditar = !transacao.ehParcela && !transacao.ehDividida;

    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (podeEditar)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar'),
                onTap: () => Navigator.of(context).pop('editar'),
              ),
            if (podeParcelar)
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Parcelar compra'),
                onTap: () => Navigator.of(context).pop('parcelar'),
              ),
            if (ehDespesa)
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(
                  transacao.ehDividida
                      ? 'Editar divisão'
                      : 'Dividir com amigos',
                ),
                onTap: () => Navigator.of(context).pop('dividir'),
              ),
            if (transacao.ehDividida)
              ListTile(
                leading: const Icon(Icons.group_off_outlined),
                title: const Text('Remover divisão'),
                onTap: () => Navigator.of(context).pop('remover'),
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

    switch (acao) {
      case 'editar':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NovaTransacaoScreen(transacao: transacao),
          ),
        );
      case 'excluir':
        final confirmou = await AppConfirmDialog.mostrar(
          context,
          titulo: 'Excluir transação?',
          mensagem:
              '"${transacao.descricao}" será removida. Essa ação não pode ser desfeita.',
          rotuloConfirmar: 'Excluir',
          destrutivo: true,
        );
        if (confirmou) {
          await ref.read(excluirTransacaoUseCaseProvider).call(transacao.id);
        }
      case 'parcelar':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ParcelarTransacaoScreen(transacao: transacao),
          ),
        );
      case 'dividir':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DividirTransacaoScreen(transacao: transacao),
          ),
        );
      case 'remover':
        await ref.read(removerDivisaoUseCaseProvider).call(transacao.id);
    }
  }

  Future<void> _escolherCategoria(
    BuildContext context,
    TransactionsFilterNotifier notifier,
    String transacaoId,
    List<String> categorias,
  ) async {
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final t = context.tokens;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Categorizar como',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: t.ink,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final categoria in categorias)
                        ListTile(
                          title: Text(categoria),
                          onTap: () => Navigator.of(context).pop(categoria),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (escolhida != null) {
      await notifier.categorizar(transacaoId, escolhida);
    }
  }
}
