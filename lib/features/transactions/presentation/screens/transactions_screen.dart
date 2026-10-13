import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/categorias.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../connect/presentation/screens/connect_screen.dart';
import '../../../transacao/presentation/screens/nova_transacao_screen.dart';
import '../providers/transactions_mock_provider.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/transaction_row.dart';

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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5, color: t.ink),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ConnectScreen()),
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.card,
                            border: Border.all(color: t.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.search, size: 18, color: t.ink),
                        ),
                      ],
                    ),
                  ],
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
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kCategoriasBase.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final category = kCategoriasBase[i];
                        return AppFilterChip(
                          label: category,
                          selected: filter.category == category,
                          onTap: () => filterNotifier.selectCategory(category),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                group.date,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.sub),
                              ),
                              Text(
                                group.totalLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.sub,
                                  fontFeatures: const [FontFeature.tabularFigures()],
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
                                    onCategorize: (id) => _escolherCategoria(context, filterNotifier, id),
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

  Future<void> _escolherCategoria(
    BuildContext context,
    TransactionsFilterNotifier notifier,
    String transacaoId,
  ) async {
    final categorias = kCategorias;
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final t = context.tokens;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Categorizar como',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: t.ink),
                ),
              ),
              for (final categoria in categorias)
                ListTile(
                  title: Text(categoria),
                  onTap: () => Navigator.of(context).pop(categoria),
                ),
            ],
          ),
        );
      },
    );
    if (escolhida != null) {
      await notifier.categorizar(transacaoId, escolhida);
    }
  }
}
