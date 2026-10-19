import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/contas/data/repositories/conta_repository_impl.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/contas/domain/services/resumo_contas.dart';
import 'package:teofinance/features/contas/domain/usecases/criar_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/editar_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/excluir_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/marcar_conta_como_paga_usecase.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final contaLocalDataSourceProvider = Provider((ref) {
  return ContaLocalDataSource(ref.watch(appDatabaseProvider));
});

final contaRepositoryProvider = Provider<ContaRepository>((ref) {
  return ContaRepositoryImpl(ref.watch(contaLocalDataSourceProvider));
});

final criarContaUseCaseProvider = Provider((ref) => CriarContaUseCase(ref.watch(contaRepositoryProvider)));
final editarContaUseCaseProvider = Provider((ref) => EditarContaUseCase(ref.watch(contaRepositoryProvider)));
final excluirContaUseCaseProvider = Provider((ref) => ExcluirContaUseCase(ref.watch(contaRepositoryProvider)));

final marcarContaComoPagaUseCaseProvider = Provider((ref) {
  return MarcarContaComoPagaUseCase(
    contas: ref.watch(contaRepositoryProvider),
    transacoes: ref.watch(transacaoRepositoryProvider),
  );
});

/// Todas as contas, as que vencem antes primeiro.
final contasStreamProvider = StreamProvider<List<ContaAPagar>>((ref) {
  return ref.watch(contaRepositoryProvider).observarTodas();
});

/// Resumo do que há para pagar, recalculado quando as contas mudam.
final resumoContasProvider = Provider<ResumoContas?>((ref) {
  final contas = ref.watch(contasStreamProvider).valueOrNull;
  if (contas == null) return null;
  return resumirContas(contas, hoje: DateTime.now());
});
