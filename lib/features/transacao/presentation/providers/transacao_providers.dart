import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/transacao_local_datasource.dart';
import '../../data/repositories/transacao_repository_impl.dart';
import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transacao_repository.dart';
import '../../domain/usecases/categorizar_transacao_usecase.dart';
import '../../domain/usecases/criar_transacao_usecase.dart';
import '../../domain/usecases/dividir_transacao_usecase.dart';
import '../../domain/usecases/excluir_transacao_usecase.dart';
import '../../domain/usecases/remover_divisao_usecase.dart';

final transacaoLocalDataSourceProvider = Provider((ref) {
  return TransacaoLocalDataSource(ref.watch(appDatabaseProvider));
});

final transacaoRepositoryProvider = Provider<TransacaoRepository>((ref) {
  return TransacaoRepositoryImpl(ref.watch(transacaoLocalDataSourceProvider));
});

final criarTransacaoUseCaseProvider = Provider((ref) {
  return CriarTransacaoUseCase(ref.watch(transacaoRepositoryProvider));
});

final categorizarTransacaoUseCaseProvider = Provider((ref) {
  return CategorizarTransacaoUseCase(ref.watch(transacaoRepositoryProvider));
});

final excluirTransacaoUseCaseProvider = Provider((ref) {
  return ExcluirTransacaoUseCase(ref.watch(transacaoRepositoryProvider));
});

final dividirTransacaoUseCaseProvider = Provider((ref) {
  return DividirTransacaoUseCase(ref.watch(transacaoRepositoryProvider));
});

final removerDivisaoUseCaseProvider = Provider((ref) {
  return RemoverDivisaoUseCase(ref.watch(transacaoRepositoryProvider));
});

/// Todas as transações, mais recentes primeiro — atualiza sozinho quando
/// uma importação ou cadastro manual muda a tabela local.
final transacoesStreamProvider = StreamProvider<List<Transacao>>((ref) {
  return ref.watch(transacaoRepositoryProvider).observarTodas();
});
