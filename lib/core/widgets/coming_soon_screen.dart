import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Conteúdo placeholder para abas ainda não implementadas (Contas, Trilha,
/// IA). Remover conforme cada feature for construída a partir dos
/// protótipos restantes em `teofinance_design_import/` (Transactions,
/// Connect, Budget, Goals, Trail, Quiz, Chat). A barra inferior
/// é responsabilidade do `AppShell`, não desta tela.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Text(
        '$title\nem construção',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: t.sub),
      ),
    );
  }
}
