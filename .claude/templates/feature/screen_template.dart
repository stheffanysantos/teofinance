import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/widgets/app_empty_state.dart';
import 'package:teofinance/core/widgets/app_error_state.dart';
import 'package:teofinance/core/widgets/app_loading_indicator.dart';
import 'package:teofinance/features/nome_feature/presentation/notifiers/nome_entidade_list_notifier.dart';
import 'package:teofinance/features/nome_feature/presentation/widgets/nome_entidade_card.dart';

class NomeEntidadeListScreen extends ConsumerWidget {
  const NomeEntidadeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nomeEntidadeListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nome Entidade')),
      body: state.when(
        inicial: () => const SizedBox.shrink(),
        carregando: () => const AppLoadingIndicator(),
        erro: (mensagem) => AppErrorState(
          mensagem: mensagem,
          onTentarNovamente: () =>
              ref.read(nomeEntidadeListNotifierProvider.notifier).recarregar(),
        ),
        vazio: () => const AppEmptyState(mensagem: 'Nenhum item ainda.'),
        dados: (itens) => ListView.builder(
          itemCount: itens.length,
          itemBuilder: (context, index) => NomeEntidadeCard(entidade: itens[index]),
        ),
      ),
    );
  }
}
