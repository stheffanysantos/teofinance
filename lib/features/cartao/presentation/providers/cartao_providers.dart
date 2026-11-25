import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/data/repositories/cartao_repository_impl.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/repositories/cartao_repository.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/cartao/domain/usecases/pagamento_fatura_usecases.dart';
import 'package:teofinance/features/cartao/domain/usecases/salvar_cartao_usecase.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final cartaoRepositoryProvider = Provider<CartaoRepository>((ref) {
  return CartaoRepositoryImpl(CartaoLocalDataSource(ref.watch(appDatabaseProvider)));
});

final salvarCartaoUseCaseProvider = Provider(
  (ref) => SalvarCartaoUseCase(ref.watch(cartaoRepositoryProvider), ref.watch(lembreteRepositoryProvider)),
);
final excluirCartaoUseCaseProvider = Provider(
  (ref) => ExcluirCartaoUseCase(ref.watch(cartaoRepositoryProvider), ref.watch(lembreteRepositoryProvider)),
);
final registrarPagamentoFaturaUseCaseProvider =
    Provider((ref) => RegistrarPagamentoFaturaUseCase(ref.watch(cartaoRepositoryProvider)));
final desfazerPagamentoFaturaUseCaseProvider =
    Provider((ref) => DesfazerPagamentoFaturaUseCase(ref.watch(cartaoRepositoryProvider)));

/// Recarregam com `ref.invalidate` depois de salvar, excluir ou pagar.
final cartoesProvider = FutureProvider<List<Cartao>>((ref) async {
  return (await ref.watch(cartaoRepositoryProvider).listarCartoes()).getOrElse((_) => const []);
});

final pagamentosFaturaProvider = FutureProvider<List<FaturaPaga>>((ref) async {
  return (await ref.watch(cartaoRepositoryProvider).listarPagamentos()).getOrElse((_) => const []);
});

/// Total das faturas em aberto, ou nulo se não há cartão cadastrado (nesse caso
/// a Home não mostra a separação entre saldo na conta e saldo após faturas).
final faturasEmAbertoTotalProvider = Provider<double?>((ref) {
  final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
  if (cartoes.isEmpty) return null;
  return parteEmAbertoNosCartoes(
    cartoes: cartoes,
    transacoes: ref.watch(transacoesStreamProvider).valueOrNull ?? const [],
    pagamentos: ref.watch(pagamentosFaturaProvider).valueOrNull ?? const [],
  );
});

/// Faturas em aberto separadas pelo mês de vencimento, de todos os cartões.
/// Vazio se não há cartão ou fatura em aberto.
final proximasFaturasProvider = Provider<List<MesDeFaturas>>((ref) {
  final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
  if (cartoes.isEmpty) return const [];
  return projetarFaturasPorMes(
    cartoes: cartoes,
    transacoes: ref.watch(transacoesStreamProvider).valueOrNull ?? const [],
    pagamentos: ref.watch(pagamentosFaturaProvider).valueOrNull ?? const [],
    hoje: DateTime.now(),
  );
});
