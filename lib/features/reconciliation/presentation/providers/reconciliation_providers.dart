import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reconciliation_local_data_source.dart';
import '../../data/repositories/reconciliation_repository_impl.dart';
import '../../data/services/transacao_matcher_service.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';
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

final reconciliationNotifierProvider =
    StateNotifierProvider<ReconciliationNotifier, ReconciliationState>((ref) {
  return ReconciliationNotifier(ref.watch(reconciliationRepositoryProvider));
});
