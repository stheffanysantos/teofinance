import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:teofinance/features/nome_feature/presentation/notifiers/nome_entidade_list_state.dart';
import 'package:teofinance/features/nome_feature/presentation/providers/nome_feature_providers.dart';

part 'nome_entidade_list_notifier.g.dart';

/// Reflete a tela/fluxo específico (lista), não a feature inteira.
@riverpod
class NomeEntidadeListNotifier extends _$NomeEntidadeListNotifier {
  @override
  NomeEntidadeListState build() {
    _carregar();
    return const NomeEntidadeListState.inicial();
  }

  Future<void> _carregar() async {
    state = const NomeEntidadeListState.carregando();
    final repository = ref.read(nomeEntidadeRepositoryProvider);
    final resultado = await repository.obterTodas();
    state = resultado.fold(
      (falha) => NomeEntidadeListState.erro(falha.mensagem),
      (itens) => itens.isEmpty
          ? const NomeEntidadeListState.vazio()
          : NomeEntidadeListState.dados(itens),
    );
  }

  Future<void> recarregar() => _carregar();
}
