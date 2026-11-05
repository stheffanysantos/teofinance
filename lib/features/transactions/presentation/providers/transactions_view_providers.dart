import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/utils/date_label.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';

export '../../../../core/utils/currency_format.dart' show formatCurrencyDelta;

const kTransactionPeriods = ['Hoje', '7 dias', 'Este mês', 'Personalizado'];

class TransactionsFilterState {
  const TransactionsFilterState({
    this.period = 'Este mês',
    this.category = 'Todas',
    this.buscando = false,
    this.query = '',
  });

  final String period;
  final String category;

  /// Campo de busca aberto.
  final bool buscando;

  /// Texto procurado na descrição e na categoria. Com texto, a busca olha todos
  /// os períodos e categorias: quem pesquisa quer achar, não filtrar o mês.
  final String query;

  bool get temBusca => query.trim().isNotEmpty;

  TransactionsFilterState copyWith({
    String? period,
    String? category,
    bool? buscando,
    String? query,
  }) {
    return TransactionsFilterState(
      period: period ?? this.period,
      category: category ?? this.category,
      buscando: buscando ?? this.buscando,
      query: query ?? this.query,
    );
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

  void selectCategory(String category) =>
      state = state.copyWith(category: category);

  /// Abre ou fecha o campo de busca; ao fechar, limpa o texto.
  void alternarBusca() => state = state.copyWith(
    buscando: !state.buscando,
    query: state.buscando ? '' : state.query,
  );

  void pesquisar(String texto) => state = state.copyWith(query: texto);

  Future<void> categorizar(String transacaoId, String categoria) {
    return ref
        .read(categorizarTransacaoUseCaseProvider)
        .call(id: transacaoId, categoria: categoria);
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
    this.divisaoLabel,
  });

  final String id;
  final String name;
  final String category;
  final String icon;
  final double value;
  final bool needsCategory;

  /// Ex.: "Dividida com Ana e Bruno · total 100.00"; nulo se não dividida.
  final String? divisaoLabel;
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

String _listaDeNomes(List<String> nomes) {
  if (nomes.length <= 1) return nomes.join();
  return '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
}

bool _dentroDoPeriodo(DateTime data, String periodo) {
  final agora = DateTime.now();
  final diferenca = DateTime(
    agora.year,
    agora.month,
    agora.day,
  ).difference(DateTime(data.year, data.month, data.day)).inDays;
  return switch (periodo) {
    'Hoje' => diferenca == 0,
    '7 dias' => diferenca >= 0 && diferenca < 7,
    'Este mês' => data.year == agora.year && data.month == agora.month,
    _ => true,
  };
}

/// Sem diferenciar maiúsculas nem acentos ("cafe" acha "Café").
bool correspondeABusca(String busca, String descricao, String categoria) {
  final q = _normalizar(busca.trim());
  if (q.isEmpty) return true;
  return _normalizar(descricao).contains(q) ||
      _normalizar(categoria).contains(q);
}

String _normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = de.indexOf(c);
    b.write(i >= 0 ? para[i] : c);
  }
  return b.toString();
}

/// Grupos filtrados e já formatados, prontos para a `TransactionsScreen`.
/// Fonte real: `transacoesStreamProvider` (Drift, cache local).
final visibleTransactionGroupsProvider = Provider<List<ResolvedTransactionGroup>>((
  ref,
) {
  final filter = ref.watch(transactionsFilterProvider);
  final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? [];

  final porData = <String, List<ResolvedTransaction>>{};
  final ordemDatas = <String>[];

  for (final transacao in transacoes) {
    final categoriaExibida = transacao.precisaCategoria
        ? 'Sem categoria'
        : transacao.categoria;
    if (filter.temBusca) {
      if (!correspondeABusca(filter.query, transacao.descricao, categoriaExibida)) {
        continue;
      }
    } else {
      if (!_dentroDoPeriodo(transacao.data, filter.period)) continue;
      if (filter.category != 'Todas' && categoriaExibida != filter.category) {
        continue;
      }
    }

    final resolved = ResolvedTransaction(
      id: transacao.id,
      name: transacao.descricao,
      category: categoriaExibida,
      icon: transacao.precisaCategoria
          ? '?'
          : transacao.categoria.isNotEmpty
          ? transacao.categoria.substring(0, 1).toUpperCase()
          : '?',
      value: transacao.valorContabilizado,
      needsCategory: transacao.precisaCategoria,
      divisaoLabel: transacao.ehDividida
          ? 'Dividida com ${_listaDeNomes(transacao.pessoasDaDivisao)} · total ${transacao.valorCobrado.abs().toStringAsFixed(2)}'
          : null,
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
        totalLabel: formatCurrencyDelta(
          porData[rotulo]!.fold(0, (acc, i) => acc + i.value),
        ),
      ),
  ];
});
