import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/nome_feature/data/datasources/nome_entidade_local_data_source.dart';
import 'package:teofinance/features/nome_feature/data/datasources/nome_entidade_remote_data_source.dart';
import 'package:teofinance/features/nome_feature/data/repositories/nome_entidade_repository_impl.dart';
import 'package:teofinance/features/nome_feature/domain/repositories/nome_entidade_repository.dart';
import 'package:teofinance/features/nome_feature/domain/usecases/salvar_nome_entidade_usecase.dart';

part 'nome_feature_providers.g.dart';

/// Infraestrutura de composição — SEM regra de negócio (ver .claude/rules/architecture.md).

@riverpod
NomeEntidadeRemoteDataSource nomeEntidadeRemoteDataSource(NomeEntidadeRemoteDataSourceRef ref) {
  return NomeEntidadeRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    uid: ref.watch(currentUidProvider),
  );
}

@riverpod
NomeEntidadeLocalDataSource nomeEntidadeLocalDataSource(NomeEntidadeLocalDataSourceRef ref) {
  return NomeEntidadeLocalDataSource(db: ref.watch(appDatabaseProvider));
}

@riverpod
NomeEntidadeRepository nomeEntidadeRepository(NomeEntidadeRepositoryRef ref) {
  return NomeEntidadeRepositoryImpl(
    remote: ref.watch(nomeEntidadeRemoteDataSourceProvider),
    local: ref.watch(nomeEntidadeLocalDataSourceProvider),
  );
}

@riverpod
SalvarNomeEntidadeUseCase salvarNomeEntidadeUseCase(SalvarNomeEntidadeUseCaseRef ref) {
  return SalvarNomeEntidadeUseCase(ref.watch(nomeEntidadeRepositoryProvider));
}
