import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/meta/presentation/providers/meta_providers.dart';
import 'package:teofinance/features/reconciliation/presentation/providers/reconciliation_providers.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';
import 'package:teofinance/features/score/domain/usecases/calcular_score_financeiro_usecase.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final calcularScoreFinanceiroUseCaseProvider = Provider((ref) {
  return CalcularScoreFinanceiroUseCase(
    transacoes: ref.watch(transacaoRepositoryProvider),
    orcamentos: ref.watch(orcamentoRepositoryProvider),
    metas: ref.watch(metaRepositoryProvider),
    reconciliacao: ref.watch(reconciliationRepositoryProvider),
  );
});

/// Score do mês. Recalcula quando transações, limites, metas ou o status da
/// reconciliação mudam — por isso observa os quatro antes de calcular.
final scoreFinanceiroProvider = FutureProvider.autoDispose<ScoreFinanceiro>((ref) async {
  ref.watch(transacoesStreamProvider);
  ref.watch(orcamentosStreamProvider);
  ref.watch(metasStreamProvider);
  ref.watch(statusReconciliacaoMesProvider);

  final resultado = await ref.watch(calcularScoreFinanceiroUseCaseProvider)();
  return resultado.fold((falha) => throw StateError(falha.message), (score) => score);
});
