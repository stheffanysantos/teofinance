import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/meta_local_datasource.dart';
import '../../data/repositories/meta_repository_impl.dart';
import '../../domain/entities/meta.dart';
import '../../domain/repositories/meta_repository.dart';
import '../../domain/usecases/aportar_meta_usecase.dart';
import '../../domain/usecases/criar_meta_usecase.dart';
import '../../domain/usecases/excluir_meta_usecase.dart';

final metaLocalDataSourceProvider = Provider((ref) {
  return MetaLocalDataSource(ref.watch(appDatabaseProvider));
});

final metaRepositoryProvider = Provider<MetaRepository>((ref) {
  return MetaRepositoryImpl(ref.watch(metaLocalDataSourceProvider));
});

final criarMetaUseCaseProvider = Provider((ref) {
  return CriarMetaUseCase(ref.watch(metaRepositoryProvider));
});

final aportarMetaUseCaseProvider = Provider((ref) {
  return AportarMetaUseCase(ref.watch(metaRepositoryProvider));
});

final excluirMetaUseCaseProvider = Provider((ref) {
  return ExcluirMetaUseCase(ref.watch(metaRepositoryProvider));
});

/// Todas as metas, prazo mais próximo primeiro.
final metasStreamProvider = StreamProvider<List<Meta>>((ref) {
  return ref.watch(metaRepositoryProvider).observarTodas();
});
