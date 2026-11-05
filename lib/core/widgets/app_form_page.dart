import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';

/// Página padrão de cadastro/edição: AppBar com título e conteúdo rolável.
/// Cadastros usam telas inteiras (e não modais) para ficar visualmente
/// consistentes com Nova transação, Nova conta e Nova meta.
class AppFormPage extends StatelessWidget {
  const AppFormPage({required this.titulo, required this.children, this.actions, super.key});

  final String titulo;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(titulo, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: children,
          ),
        ),
      ),
    );
  }
}
