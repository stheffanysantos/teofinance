import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';

/// Botão de voltar para telas sem AppBar (mesmo visual do botão da tela
/// "Traga seus dados"). Só aparece quando há para onde voltar.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    final t = context.tokens;
    return Semantics(
      button: true,
      label: 'Voltar',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.arrow_back, size: 18, color: t.ink),
        ),
      ),
    );
  }
}
