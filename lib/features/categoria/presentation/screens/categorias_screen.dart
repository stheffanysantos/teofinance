import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/categoria/presentation/providers/categoria_providers.dart';
import 'package:teofinance/features/categoria/presentation/screens/categoria_form_screen.dart';

/// Lista as categorias padrão e permite criar ou remover as suas.
class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({super.key});

  Future<void> _adicionar(
    BuildContext context,
    WidgetRef ref, {
    String? nomeAtual,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriaFormScreen(nomeAtual: nomeAtual),
      ),
    );
    ref.invalidate(categoriasPersonalizadasProvider);
  }

  Future<void> _remover(
    BuildContext context,
    WidgetRef ref,
    String nome,
  ) async {
    final confirmou = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Remover categoria?',
      mensagem:
          '"$nome" deixa de aparecer nas opções. Transações já lançadas com ela continuam como estão.',
      rotuloConfirmar: 'Remover',
      destrutivo: true,
    );
    if (!confirmou) return;
    await ref.read(removerCategoriaUseCaseProvider).call(nome);
    ref.invalidate(categoriasPersonalizadasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final proprias =
        ref.watch(categoriasPersonalizadasProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(
          'Categorias',
          style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
        ),
        actions: const [
          AppHelpButton(
            titulo: 'Como funcionam as categorias',
            paragrafos: [
              'Categorias organizam seus lançamentos (Mercado, Moradia, Lazer...) e alimentam orçamentos e relatórios.',
              'As categorias padrão ficam sempre disponíveis. Você pode criar as suas, renomear e remover as que criou.',
              'Remover uma categoria não altera transações antigas: elas mantêm o nome que tinham.',
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: t.accentInk,
        onPressed: () => _adicionar(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
          children: [
            Text(
              'Padrão',
              style: TextStyle(fontWeight: FontWeight.w700, color: t.sub),
            ),
            for (final c in kCategorias)
              ListTile(
                title: Text(c, style: TextStyle(color: t.ink)),
              ),
            const SizedBox(height: 12),
            Text(
              'Minhas categorias',
              style: TextStyle(fontWeight: FontWeight.w700, color: t.sub),
            ),
            if (proprias.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhuma ainda. Toque em + para criar.',
                  style: TextStyle(color: t.sub),
                ),
              ),
            for (final c in proprias)
              ListTile(
                title: Text(c, style: TextStyle(color: t.ink)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _adicionar(context, ref, nomeAtual: c),
                    ),
                    IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remover(context, ref, c),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
