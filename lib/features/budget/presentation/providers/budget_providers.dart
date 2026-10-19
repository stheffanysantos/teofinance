import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/budget/data/repositories/orcamento_repository_impl.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/budget/domain/services/calcular_envelopes.dart';
import 'package:teofinance/features/budget/domain/usecases/definir_limite_orcamento_usecase.dart';
import 'package:teofinance/features/budget/domain/usecases/excluir_limite_orcamento_usecase.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final orcamentoLocalDataSourceProvider = Provider((ref) {
  return OrcamentoLocalDataSource(ref.watch(appDatabaseProvider));
});

final orcamentoRepositoryProvider = Provider<OrcamentoRepository>((ref) {
  return OrcamentoRepositoryImpl(ref.watch(orcamentoLocalDataSourceProvider));
});

final definirLimiteOrcamentoUseCaseProvider = Provider((ref) {
  return DefinirLimiteOrcamentoUseCase(ref.watch(orcamentoRepositoryProvider));
});

final excluirLimiteOrcamentoUseCaseProvider = Provider((ref) {
  return ExcluirLimiteOrcamentoUseCase(ref.watch(orcamentoRepositoryProvider));
});

final orcamentosStreamProvider = StreamProvider<List<Orcamento>>((ref) {
  return ref.watch(orcamentoRepositoryProvider).observarTodos();
});

/// Envelopes do mês corrente: limites persistidos x despesas reais.
final resumoOrcamentoProvider = Provider<AsyncValue<ResumoOrcamento>>((ref) {
  final limites = ref.watch(orcamentosStreamProvider);
  final transacoes = ref.watch(transacoesStreamProvider);

  if (limites.hasError) return AsyncValue.error(limites.error!, limites.stackTrace!);
  if (transacoes.hasError) return AsyncValue.error(transacoes.error!, transacoes.stackTrace!);
  if (!limites.hasValue || !transacoes.hasValue) return const AsyncValue.loading();

  return AsyncValue.data(calcularEnvelopes(
    limites: limites.requireValue,
    transacoes: transacoes.requireValue,
    mes: DateTime.now(),
  ));
});

/// Cor do indicador: verde (<70%), âmbar (70–90%), vermelho (≥90%).
Color envelopeColor(AppSurfaceTokens tokens, double proporcao) {
  if (proporcao >= .9) return tokens.neg;
  if (proporcao >= .7) return AppColors.aviso;
  return tokens.pos;
}

String envelopeStatus(double proporcao, double restante) {
  final r = restante.abs().toStringAsFixed(0);
  if (restante < 0) return 'Estourou em R\$ $r';
  if (proporcao >= .9) return 'Perto do limite · restam R\$ $r';
  if (proporcao >= .7) return 'Atenção · restam R\$ $r';
  return 'Dentro do orçamento · restam R\$ $r';
}
