import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/sync/sync_pausa.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../contas/presentation/providers/conta_providers.dart';
import '../../../import/presentation/providers/import_providers.dart';
import '../../../meta/presentation/providers/meta_providers.dart';
import '../../../parcelamento/presentation/providers/parcelamento_providers.dart';
import '../../../renda/presentation/providers/renda_providers.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';
import '../../data/sync_engine.dart';

/// `null` enquanto deslogado — a sincronização não roda sem um usuário.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final usuario = ref.watch(usuarioAtualProvider).valueOrNull;
  if (usuario == null) return null;

  return SyncEngine(
    firestore: ref.watch(firestoreProvider),
    uid: usuario.uid,
    transacaoRepository: ref.watch(transacaoRepositoryProvider),
    perfilBancoRepository: ref.watch(perfilBancoRepositoryProvider),
    rendaRepository: ref.watch(rendaRepositoryProvider),
    metaRepository: ref.watch(metaRepositoryProvider),
    parcelamentoRepository: ref.watch(parcelamentoRepositoryProvider),
    orcamentoRepository: ref.watch(orcamentoRepositoryProvider),
    contaRepository: ref.watch(contaRepositoryProvider),
    pausado: () => syncPausado(ref.read(secureStorageProvider)),
  );
});

/// Estado da sincronização para exibir na UI (ex.: Perfil).
enum SyncExecutionState { ocioso, sincronizando, concluida, falhou }

class SyncUiState {
  const SyncUiState({this.estado = SyncExecutionState.ocioso, this.ultimaExecucao});

  final SyncExecutionState estado;
  final DateTime? ultimaExecucao;

  SyncUiState copyWith({SyncExecutionState? estado, DateTime? ultimaExecucao}) {
    return SyncUiState(
      estado: estado ?? this.estado,
      ultimaExecucao: ultimaExecucao ?? this.ultimaExecucao,
    );
  }
}

final syncUiStateProvider = NotifierProvider<SyncUiStateNotifier, SyncUiState>(
  SyncUiStateNotifier.new,
);

class SyncUiStateNotifier extends Notifier<SyncUiState> {
  @override
  SyncUiState build() => const SyncUiState();

  Future<void> sincronizarAgora() async {
    final engine = ref.read(syncEngineProvider);
    if (engine == null || state.estado == SyncExecutionState.sincronizando) return;

    state = state.copyWith(estado: SyncExecutionState.sincronizando);
    try {
      await engine.sincronizarTudo();
      state = state.copyWith(estado: SyncExecutionState.concluida, ultimaExecucao: DateTime.now());
    } catch (_) {
      state = state.copyWith(estado: SyncExecutionState.falhou);
    }
  }
}
