import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../import/presentation/screens/import_screen.dart';

/// Tela "Traga seus dados": a entrada para importar o extrato do banco.
/// Acessada a partir do botão "+" em Transações. A importação é sempre manual
/// (OFX ou CSV baixado no app do banco) — ver decisão 0003 em
/// `.claude/memory/decisions.md`.
class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: t.card,
                          border: Border.all(color: t.line),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_back, size: 18, color: t.ink),
                      ),
                    ),
                    Text(
                      'Traga seus dados',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.6, color: t.ink),
                    ),
                    Text(
                      'Importe o extrato que você baixa no app do banco. Funciona com qualquer banco.',
                      style: TextStyle(fontSize: 14, color: t.sub, height: 1.5),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: t.card,
                        border: Border.all(color: t.hero, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 14,
                        children: [
                          Row(
                            spacing: 14,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: Icon(Icons.upload_file_outlined, color: t.ink, size: 24),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Importar arquivo OFX ou CSV',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink),
                                    ),
                                    Text(
                                      'Extrato baixado no app do banco',
                                      style: TextStyle(fontSize: 13, color: t.sub),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const _PrivacyNote(
                            text: 'O arquivo é lido e categorizado no seu celular. Nada é enviado para servidores.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
              child: Column(
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ImportScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text(
                        'Selecionar arquivo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(Icons.lock_outline, size: 11, color: t.pos),
                      Text(
                        'Processado no aparelho',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.sub),
                      ),
                    ],
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

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.lock_outline, size: 13, color: t.pos),
        ),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12.5, color: t.sub, height: 1.45)),
        ),
      ],
    );
  }
}
