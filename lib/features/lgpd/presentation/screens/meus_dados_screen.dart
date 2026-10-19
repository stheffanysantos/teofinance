import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/features/lgpd/presentation/notifiers/meus_dados_notifier.dart';
import 'package:teofinance/features/lgpd/presentation/providers/lgpd_providers.dart';

/// Direitos do titular (LGPD): levar uma cópia dos dados e eliminá-los.
class MeusDadosScreen extends ConsumerWidget {
  const MeusDadosScreen({super.key});

  String _nomeDoArquivo() {
    final hoje = DateTime.now();
    final mes = hoje.month.toString().padLeft(2, '0');
    final dia = hoje.day.toString().padLeft(2, '0');
    return 'teofinance_meus_dados_${hoje.year}$mes$dia.json';
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final json = await ref.read(meusDadosNotifierProvider.notifier).exportar();
    if (json == null) return;

    final salvo = await FilePicker.saveFile(
      fileName: _nomeDoArquivo(),
      bytes: utf8.encode(json),
      mimeType: 'application/json',
      dialogTitle: 'Salvar meus dados',
    );
    messenger.showSnackBar(SnackBar(
      content: Text(salvo == null ? 'Exportação cancelada.' : 'Dados exportados.'),
    ));
  }

  Future<void> _excluir(BuildContext context, WidgetRef ref) async {
    final confirmou = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir minha conta?',
      mensagem: 'Apaga sua conta e todos os seus dados, na nuvem e neste aparelho. '
          'Isso não pode ser desfeito. Exporte uma cópia antes, se quiser guardá-los.',
      rotuloConfirmar: 'Continuar',
      destrutivo: true,
    );
    if (!confirmou || !context.mounted) return;

    final senha = await showDialog<String>(
      context: context,
      builder: (_) => const _PedirSenhaDialog(),
    );
    if (senha == null || !context.mounted) return;

    final apagou = await ref.read(meusDadosNotifierProvider.notifier).excluir(senha: senha);
    if (apagou && context.mounted) {
      // Sem conta, o AuthGate já leva para o login; só sai desta tela.
      Navigator.of(context).popUntil((rota) => rota.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final estado = ref.watch(meusDadosNotifierProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Privacidade e dados', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Seus dados são seus. Você pode levar uma cópia deles ou apagar tudo quando quiser.',
              style: TextStyle(fontSize: 14, color: t.sub, height: 1.4),
            ),
            const SizedBox(height: 16),
            _Cartao(
              icone: Icons.file_download_outlined,
              titulo: 'Exportar meus dados',
              descricao: 'Um arquivo JSON com transações, rendas, metas, orçamento, parcelamentos, '
                  'perfis de banco e as linhas de extrato importadas.',
              rotuloBotao: 'Exportar',
              ocupado: estado.acao == MeusDadosAcao.exportando,
              desabilitado: estado.ocupado,
              onPressed: () => _exportar(context, ref),
            ),
            const SizedBox(height: 12),
            _Cartao(
              icone: Icons.delete_forever_outlined,
              titulo: 'Excluir minha conta',
              descricao: 'Remove sua conta e todos os dados do Firebase e deste aparelho. Irreversível.',
              rotuloBotao: 'Excluir conta',
              destrutivo: true,
              ocupado: estado.acao == MeusDadosAcao.excluindo,
              desabilitado: estado.ocupado,
              onPressed: () => _excluir(context, ref),
            ),
            if (estado.erro != null) ...[
              const SizedBox(height: 16),
              Text(estado.erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.rotuloBotao,
    required this.onPressed,
    required this.ocupado,
    required this.desabilitado,
    this.destrutivo = false,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final String rotuloBotao;
  final VoidCallback onPressed;
  final bool ocupado;
  final bool desabilitado;
  final bool destrutivo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cor = destrutivo ? t.neg : t.ink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(icone, color: cor),
              Expanded(
                child: Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cor)),
              ),
            ],
          ),
          Text(descricao, style: TextStyle(fontSize: 13, color: t.sub, height: 1.4)),
          OutlinedButton(
            onPressed: desabilitado ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: cor,
              side: BorderSide(color: destrutivo ? t.neg : t.line),
            ),
            child: ocupado
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(rotuloBotao),
          ),
        ],
      ),
    );
  }
}

class _PedirSenhaDialog extends StatefulWidget {
  const _PedirSenhaDialog();

  @override
  State<_PedirSenhaDialog> createState() => _PedirSenhaDialogState();
}

class _PedirSenhaDialogState extends State<_PedirSenhaDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirme sua senha'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Senha'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Excluir tudo'),
        ),
      ],
    );
  }
}
