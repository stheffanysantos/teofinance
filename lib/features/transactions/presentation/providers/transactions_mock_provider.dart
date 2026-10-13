import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_label.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';

export '../../../../core/utils/currency_format.dart' show formatCurrencyDelta;

const kTransactionPeriods = ['Hoje', '7 dias', 'Este mês', 'Personalizado'];

class TransactionsFilterState {
  const TransactionsFilterState({this.period = 'Este mês', this.category = 'Todas'});

  final String period;
  final String category;

  TransactionsFilterState copyWith({String? period, String? category}) {
    return TransactionsFilterState(period: period ?? this.period, category: category ?? this.category);
  }
}

final transactionsFilterProvider =
    NotifierProvider<TransactionsFilterNotifier, TransactionsFilterState>(
      TransactionsFilterNotifier.new,
    );

class TransactionsFilterNotifier extends Notifier<TransactionsFilterState> {
  @override
  TransactionsFilterState build() => const TransactionsFilterState();

  void selectPeriod(String period) => state = state.copyWith(period: period);

  void selectCategory(String category) => state = state.copyWith(category: category);

  Future<void> categorizar(String transacaoId, String categoria) {
    return ref.read(categorizarTransacaoUseCaseProvider).call(id: transacaoId, categoria: categoria);
  }
}

/// Item já resolvido, pronto para a UI (`TransactionRow`) consumir.
class ResolvedTransaction {
  const ResolvedTransaction({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.value,
    required this.needsCategory,
  });

  final String id;
  final String name;
  final String category;
  final String icon;
  final double value;
  final bool needsCategory;
}

class ResolvedTransactionGroup {
  const ResolvedTransactionGroup({
    required this.date,
    required this.items,
    required this.totalLabel,
  });

  final String date;
  final List<ResolvedTransaction> items;
  final String totalLabel;
}

bool _dentroDoPeriodo(DateTime data, String periodo) {
  final agora = DateTime.now();
  final diferenca = DateTime(agora.year, agora.month, agora.day)
      .difference(DateTime(data.year, data.month, data.day))
      .inDays;
  return switch (periodo) {
    'Hoje' => diferenca == 0,
    '7 dias' => diferenca >= 0 && diferenca < 7,
    'Este mês' => data.year == agora.year && data.month == agora.month,
    _ => true,
  };
}

/// Grupos filtrados e já formatados, prontos para a `TransactionsScreen`.
/// Fonte real: `transacoesStreamProvider` (Drift, cache local).
final visibleTransactionGroupsProvider = Provider<List<ResolvedTransactionGroup>>((ref) {
  final filter = ref.watch(transactionsFilterProvider);
  final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? [];

  final porData = <String, List<ResolvedTransaction>>{};
  final ordemDatas = <String>[];

  for (final transacao in transacoes) {
    if (!_dentroDoPeriodo(transacao.data, filter.period)) continue;
    final categoriaExibida = transacao.precisaCategoria ? 'Sem categoria' : transacao.categoria;
    if (filter.category != 'Todas' && categoriaExibida != filter.category) continue;

    final resolved = ResolvedTransaction(
      id: transacao.id,
      name: transacao.descricao,
      category: categoriaExibida,
      icon: transacao.precisaCategoria
          ? '?'
          : transacao.categoria.isNotEmpty
              ? transacao.categoria.substring(0, 1).toUpperCase()
              : '?',
      value: transacao.valor,
      needsCategory: transacao.precisaCategoria,
    );

    final rotulo = rotuloDataRelativa(transacao.data);
    if (!porData.containsKey(rotulo)) ordemDatas.add(rotulo);
    porData.putIfAbsent(rotulo, () => []).add(resolved);
  }

  return [
    for (final rotulo in ordemDatas)
      ResolvedTransactionGroup(
        date: rotulo,
        items: porData[rotulo]!,
        totalLabel: formatCurrencyDelta(porData[rotulo]!.fold(0, (acc, i) => acc + i.value)),
      ),
  ];
});
