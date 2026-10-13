import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/renda_local_datasource.dart';
import '../../data/repositories/renda_repository_impl.dart';
import '../../domain/entities/renda.dart';
import '../../domain/repositories/renda_repository.dart';
import '../../domain/usecases/criar_renda_usecase.dart';
import '../../domain/usecases/excluir_renda_usecase.dart';

final rendaLocalDataSourceProvider = Provider((ref) {
  return RendaLocalDataSource(ref.watch(appDatabaseProvider));
});

final rendaRepositoryProvider = Provider<RendaRepository>((ref) {
  return RendaRepositoryImpl(ref.watch(rendaLocalDataSourceProvider));
});

final criarRendaUseCaseProvider = Provider((ref) {
  return CriarRendaUseCase(ref.watch(rendaRepositoryProvider));
});

final excluirRendaUseCaseProvider = Provider((ref) {
  return ExcluirRendaUseCase(ref.watch(rendaRepositoryProvider));
});

/// Todas as rendas cadastradas, mais recentes primeiro.
final rendasStreamProvider = StreamProvider<List<Renda>>((ref) {
  return ref.watch(rendaRepositoryProvider).observarTodas();
});
