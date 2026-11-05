import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/investimento/data/repositories/investimento_repository_impl.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/domain/repositories/investimento_repository.dart';
import 'package:teofinance/features/investimento/domain/usecases/excluir_investimento_usecase.dart';
import 'package:teofinance/features/investimento/domain/usecases/salvar_investimento_usecase.dart';

final investimentoRepositoryProvider = Provider<InvestimentoRepository>((ref) {
  return InvestimentoRepositoryImpl(InvestimentoLocalDataSource(ref.watch(appDatabaseProvider)));
});

final salvarInvestimentoUseCaseProvider = Provider((ref) {
  return SalvarInvestimentoUseCase(ref.watch(investimentoRepositoryProvider));
});

final excluirInvestimentoUseCaseProvider = Provider((ref) {
  return ExcluirInvestimentoUseCase(ref.watch(investimentoRepositoryProvider));
});

/// Recarrega com `ref.invalidate` depois de salvar ou excluir.
final investimentosProvider = FutureProvider<List<Investimento>>((ref) async {
  final resultado = await ref.watch(investimentoRepositoryProvider).listar();
  return resultado.getOrElse((_) => const []);
});
