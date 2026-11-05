import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/data/repositories/lembrete_repository_impl.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';
import 'package:teofinance/features/lembrete/domain/usecases/excluir_lembrete_usecase.dart';
import 'package:teofinance/features/lembrete/domain/usecases/salvar_lembrete_usecase.dart';

final lembreteRepositoryProvider = Provider<LembreteRepository>((ref) {
  return LembreteRepositoryImpl(LembreteLocalDataSource(ref.watch(appDatabaseProvider)));
});

final salvarLembreteUseCaseProvider = Provider((ref) {
  return SalvarLembreteUseCase(ref.watch(lembreteRepositoryProvider));
});

final excluirLembreteUseCaseProvider = Provider((ref) {
  return ExcluirLembreteUseCase(ref.watch(lembreteRepositoryProvider));
});

/// Recarrega com `ref.invalidate` depois de salvar, alternar ou excluir; o
/// agendamento das notificações acompanha (ver `lembretesAutomaticosProvider`).
final lembretesPersonalizadosProvider = FutureProvider<List<LembretePersonalizado>>((ref) async {
  final resultado = await ref.watch(lembreteRepositoryProvider).listar();
  return resultado.getOrElse((_) => const []);
});
