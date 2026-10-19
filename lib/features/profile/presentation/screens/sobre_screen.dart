import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/lgpd/presentation/screens/meus_dados_screen.dart';
import 'package:teofinance/features/profile/presentation/providers/app_info_provider.dart';

const _nomeDoApp = 'TeoFinance';

/// Versão, o que o app promete sobre privacidade e licenças de terceiros.
class SobreScreen extends ConsumerWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final info = ref.watch(appInfoProvider);
    final versao = 'Versão ${info.version} (${info.build})';

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Sobre o app', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: Column(
                spacing: 6,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.account_balance_wallet_outlined, color: t.accent, size: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nomeDoApp,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.ink),
                  ),
                  Text(versao, style: TextStyle(fontSize: 13, color: t.sub)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Controle financeiro pensado para a sua privacidade.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
            ),
            const SizedBox(height: 10),
            const _Ponto('Seus extratos (OFX e CSV) são lidos só no seu aparelho e nunca são enviados.'),
            const _Ponto('O assistente responde no aparelho, sem enviar suas perguntas para a internet.'),
            const _Ponto('Seus lançamentos ficam na sua conta e só você os acessa.'),
            const _Ponto('Você pode exportar ou apagar todos os seus dados quando quiser.'),
            const SizedBox(height: 16),
            _Item(
              icone: Icons.shield_outlined,
              titulo: 'Privacidade e dados',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeusDadosScreen()),
              ),
            ),
            _Item(
              icone: Icons.description_outlined,
              titulo: 'Licenças de código aberto',
              onTap: () => showLicensePage(
                context: context,
                applicationName: _nomeDoApp,
                applicationVersion: info.version,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ponto extends StatelessWidget {
  const _Ponto(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: t.pos),
          Expanded(
            child: Text(texto, style: TextStyle(fontSize: 13.5, color: t.sub, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icone, required this.titulo, required this.onTap});

  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icone, color: t.ink),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, color: t.ink)),
        trailing: Icon(Icons.chevron_right, color: t.sub),
        onTap: onTap,
      ),
    );
  }
}
