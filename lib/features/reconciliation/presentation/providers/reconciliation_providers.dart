import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reconciliation_local_data_source.dart';
import '../../data/repositories/reconciliation_repository_impl.dart';
import '../../data/services/transacao_matcher_service.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';
import '../../domain/usecases/aprovar_match_usecase.dart';
import '../../domain/usecases/fazer_reconciliacao_usecase.dart';
import '../../domain/usecases/obter_status_reconciliacao_usecase.dart';
import '../../domain/usecases/rejeitar_match_usecase.dart';
import '../../domain/usecases/vincular_manualmente_usecase.dart';
import '../notifiers/reconciliation_notifier.dart';

final transacaoMatcherServiceProvider = Provider(
  (ref) => TransacaoMatcherService(),
);

final reconciliationLocalDataSourceProvider = Provider((ref) {
  return ReconciliationLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final reconciliationRepositoryProvider = Provider<ReconciliationRepository>((ref) {
  return ReconciliationRepositoryImpl(
    ref.watch(reconciliationLocalDataSourceProvider),
    ref.watch(transacaoLocalDataSourceProvider),
    ref.watch(transacaoMatcherServiceProvider),
  );
});

final fazerReconciliacaoUseCaseProvider = Provider(
  (ref) => FazerReconciliacaoUseCase(ref.watch(reconciliationRepositoryProvider)),
);
final aprovarMatchUseCaseProvider = Provider(
  (ref) => AprovarMatchUseCase(ref.watch(reconciliationRepositoryProvider)),
);
final rejeitarMatchUseCaseProvider = Provider(
  (ref) => RejeitarMatchUseCase(ref.watch(reconciliationRepositoryProvider)),
);
final vincularManualmenteUseCaseProvider = Provider(
  (ref) => VincularManualmenteUseCase(ref.watch(reconciliationRepositoryProvider)),
);
final obterStatusReconciliacaoUseCaseProvider = Provider(
  (ref) => ObterStatusReconciliacaoUseCase(ref.watch(reconciliationRepositoryProvider)),
);

final reconciliationNotifierProvider =
    StateNotifierProvider<ReconciliationNotifier, ReconciliationState>((ref) {
  return ReconciliationNotifier(
    fazerReconciliacao: ref.watch(fazerReconciliacaoUseCaseProvider),
    aprovarMatch: ref.watch(aprovarMatchUseCaseProvider),
    rejeitarMatch: ref.watch(rejeitarMatchUseCaseProvider),
    vincularManualmente: ref.watch(vincularManualmenteUseCaseProvider),
  );
});

/// Status de reconciliação do mês corrente, para o card do dashboard.
final statusReconciliacaoMesProvider = FutureProvider.autoDispose<ReconciliationStatus?>((ref) async {
  final agora = DateTime.now();
  final result = await ref.watch(obterStatusReconciliacaoUseCaseProvider)(
    ObterStatusReconciliacaoParams(
      userId: ref.watch(firebaseAuthProvider).currentUser?.uid ?? '',
      dataInicio: DateTime(agora.year, agora.month),
      dataFim: DateTime(agora.year, agora.month + 1).subtract(const Duration(milliseconds: 1)),
    ),
  );
  return result.fold((_) => null, (s) => s);
});
