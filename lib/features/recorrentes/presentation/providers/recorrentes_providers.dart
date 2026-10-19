import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/recorrentes/domain/usecases/listar_gastos_recorrentes_usecase.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final listarGastosRecorrentesUseCaseProvider = Provider((ref) {
  return ListarGastosRecorrentesUseCase(ref.watch(transacaoRepositoryProvider));
});

/// Recalcula quando o histórico de transações muda (importação, cadastro, edição).
final gastosRecorrentesProvider = FutureProvider.autoDispose<List<GastoRecorrente>>((ref) async {
  ref.watch(transacoesStreamProvider);

  final resultado = await ref.watch(listarGastosRecorrentesUseCaseProvider)();
  return resultado.fold((falha) => throw StateError(falha.message), (gastos) => gastos);
});
