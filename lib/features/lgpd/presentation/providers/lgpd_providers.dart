import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/auth/presentation/providers/auth_providers.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_conta_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_local_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_remote_data_source.dart';
import 'package:teofinance/features/lgpd/data/repositories/lgpd_repository_impl.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';
import 'package:teofinance/features/lgpd/domain/usecases/excluir_minha_conta_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';
import 'package:teofinance/features/lgpd/presentation/notifiers/meus_dados_notifier.dart';
import 'package:teofinance/features/sync/presentation/providers/sync_providers.dart';

final lgpdRepositoryProvider = Provider<LgpdRepository>((ref) {
  return LgpdRepositoryImpl(
    LgpdLocalDataSource(ref.watch(appDatabaseProvider), ref.watch(secureStorageProvider)),
    LgpdRemoteDataSource(ref.watch(firestoreProvider)),
    LgpdContaFirebaseDataSource(ref.watch(firebaseAuthProvider)),
  );
});

final exportarMeusDadosUseCaseProvider = Provider((ref) {
  return ExportarMeusDadosUseCase(
    repository: ref.watch(lgpdRepositoryProvider),
    auth: ref.watch(authRepositoryProvider),
    antesDeExportar: () async => ref.read(syncEngineProvider)?.sincronizarTudo(),
  );
});

final excluirMinhaContaUseCaseProvider = Provider((ref) {
  return ExcluirMinhaContaUseCase(
    repository: ref.watch(lgpdRepositoryProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

final meusDadosNotifierProvider =
    StateNotifierProvider.autoDispose<MeusDadosNotifier, MeusDadosState>((ref) {
  return MeusDadosNotifier(
    exportar: ref.watch(exportarMeusDadosUseCaseProvider),
    excluir: ref.watch(excluirMinhaContaUseCaseProvider),
  );
});
