import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';
import 'package:teofinance/features/lembrete/presentation/screens/lembrete_form_screen.dart';

/// Lembretes mensais criados pelo usuário: fatura fecha/abre/vence, melhor dia
/// para usar o cartão, ou qualquer outro.
class LembretesScreen extends ConsumerWidget {
  const LembretesScreen({super.key});

  Future<void> _editar(BuildContext context, WidgetRef ref, [LembretePersonalizado? existente]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LembreteFormScreen(existente: existente)),
    );
    ref.invalidate(lembretesPersonalizadosProvider);
  }

  Future<void> _excluir(BuildContext context, WidgetRef ref, LembretePersonalizado l) async {
    final confirmou = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir lembrete?',
      mensagem: '"${l.titulo}" não vai mais avisar.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmou) return;
    await ref.read(excluirLembreteUseCaseProvider).call(l.id);
    ref.invalidate(lembretesPersonalizadosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final lembretes = ref.watch(lembretesPersonalizadosProvider).valueOrNull ?? const <LembretePersonalizado>[];

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Meus lembretes', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funcionam os lembretes',
            paragrafos: [
              'Crie avisos que se repetem todo mês num dia fixo: quando a fatura do cartão fecha, abre ou vence, ou o melhor dia para usar o cartão.',
              'O melhor dia de compra costuma ser o dia em que a fatura fecha: a compra só entra na fatura seguinte.',
              'Em meses mais curtos, um lembrete do dia 31 dispara no último dia do mês. O horário é o mesmo dos demais avisos (Avisos > Configurar lembretes).',
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: t.accentInk,
        onPressed: () => _editar(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: lembretes.isEmpty
            ? Center(
                child: Text(
                  'Nenhum lembrete criado.\nToque em + para adicionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.sub),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                children: [
                  for (final l in lembretes)
                    ListTile(
                      onTap: () => _editar(context, ref, l),
                      title: Text(l.titulo, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                      subtitle: Text('${l.tipo.rotulo} · todo dia ${l.dia}', style: TextStyle(color: t.sub)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: l.ativo,
                            onChanged: (v) async {
                              await ref.read(salvarLembreteUseCaseProvider).call(l.copyWith(ativo: v));
                              ref.invalidate(lembretesPersonalizadosProvider);
                            },
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _excluir(context, ref, l),
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
