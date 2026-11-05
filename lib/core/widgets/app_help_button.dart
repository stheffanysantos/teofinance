import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';

/// Botão "?" que abre um texto de ajuda explicando a tela. Cada parágrafo de
/// [paragrafos] vira um bloco; use [topicos] para itens curtos em lista.
class AppHelpButton extends StatelessWidget {
  const AppHelpButton({required this.titulo, required this.paragrafos, super.key});

  final String titulo;
  final List<String> paragrafos;

  void _abrir(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final t = context.tokens;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.ink)),
                const SizedBox(height: 12),
                for (final p in paragrafos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(p, style: TextStyle(fontSize: 14, height: 1.45, color: t.ink)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ajuda',
      icon: const Icon(Icons.help_outline),
      onPressed: () => _abrir(context),
    );
  }
}
