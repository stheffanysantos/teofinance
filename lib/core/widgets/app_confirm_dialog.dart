import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';

/// Confirmação obrigatória antes de qualquer ação destrutiva (excluir transação,
/// conta, limite…) — ver `.claude/rules/material3.md`. Devolve `true` só se o
/// usuário confirmar; tocar fora ou cancelar devolve `false`.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.titulo,
    required this.mensagem,
    this.rotuloConfirmar = 'Confirmar',
    this.destrutivo = false,
    super.key,
  });

  final String titulo;
  final String mensagem;
  final String rotuloConfirmar;

  /// Pinta o botão de confirmação com a cor de despesa/erro.
  final bool destrutivo;

  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Confirmar',
    bool destrutivo = false,
  }) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        titulo: titulo,
        mensagem: mensagem,
        rotuloConfirmar: rotuloConfirmar,
        destrutivo: destrutivo,
      ),
    );
    return confirmou ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destrutivo ? TextButton.styleFrom(foregroundColor: t.neg) : null,
          child: Text(rotuloConfirmar),
        ),
      ],
    );
  }
}
