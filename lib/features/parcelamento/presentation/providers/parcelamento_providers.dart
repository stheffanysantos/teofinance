import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/parcelamento_local_data_source.dart';
import '../../data/datasources/parcelamento_remote_data_source.dart';
import '../../data/repositories/parcelamento_repository_impl.dart';
import '../../domain/repositories/parcelamento_repository.dart';
import '../../domain/usecases/criar_parcelamento_usecase.dart';

/// Infraestrutura de composição (DI) — ver `.claude/rules/architecture.md`.
final parcelamentoLocalDataSourceProvider = Provider((ref) {
  return ParcelamentoLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final parcelamentoRemoteDataSourceProvider = Provider((ref) {
  return ParcelamentoRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final parcelamentoRepositoryProvider = Provider<ParcelamentoRepository>((ref) {
  return ParcelamentoRepositoryImpl(
    ref.watch(parcelamentoLocalDataSourceProvider),
    ref.watch(parcelamentoRemoteDataSourceProvider),
  );
});

final criarParcelamentoUsecaseProvider = Provider((ref) {
  return CriarParcelamentoUseCase(ref.watch(parcelamentoRepositoryProvider));
});
