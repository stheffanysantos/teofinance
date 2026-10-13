import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../import/presentation/screens/import_screen.dart';
import '../providers/connect_provider.dart';
import '../widgets/connect_option_card.dart';

/// Tela "Traga seus dados" — implementação fiel a Connect.dc.html.
/// Acessada a partir do botão "+" em Transações.
class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final option = ref.watch(connectOptionProvider);
    final notifier = ref.read(connectOptionProvider.notifier);
    final isOpenFinance = option == ConnectOption.openFinance;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
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
                        const SizedBox(height: 4),
                        Text(
                          'Traga seus dados',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.6, color: t.ink),
                        ),
                        Text(
                          'Escolha como adicionar suas contas. Você pode usar os dois depois.',
                          style: TextStyle(fontSize: 14, color: t.sub, height: 1.5),
                        ),
                      ],
                    ),
                    ConnectOptionCard(
                      selected: isOpenFinance,
                      onTap: () => notifier.pick(ConnectOption.openFinance),
                      iconBg: t.hero,
                      icon: Icon(Icons.account_balance_outlined, color: t.accent, size: 24),
                      title: 'Conectar via Open Finance',
                      subtitle: 'Recomendado · atualização automática',
                      subtitleColor: t.pos,
                      extra: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final bank in kSupportedBanks) _BankChip(bank: bank),
                        ],
                      ),
                      footer: _PrivacyNote(
                        text:
                            'Acesso somente leitura, regulado pelo Banco Central. Você autoriza e '
                            'revoga quando quiser. Seus dados são guardados apenas no aparelho.',
                      ),
                    ),
                    ConnectOptionCard(
                      selected: !isOpenFinance,
                      onTap: () => notifier.pick(ConnectOption.csv),
                      iconBg: t.track,
                      icon: Icon(Icons.upload_file_outlined, color: t.ink, size: 24),
                      title: 'Importar arquivo CSV/OFX',
                      subtitle: 'Extrato baixado no app do banco',
                      subtitleColor: t.sub,
                      extra: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: t.sub, width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Toque para escolher o arquivo',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.sub),
                        ),
                      ),
                      footer: _PrivacyNote(
                        text: 'O arquivo é lido e categorizado no seu celular. Nada é enviado para servidores.',
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
                    onTap: isOpenFinance
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ImportScreen()),
                            ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(
                        isOpenFinance ? 'Escolher meu banco' : 'Selecionar arquivo',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
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

class _BankChip extends StatelessWidget {
  const _BankChip({required this.bank});

  final BankLogo bank;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
      decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: Color(bank.colorValue), borderRadius: BorderRadius.circular(7)),
            alignment: Alignment.center,
            child: Text(
              bank.initial,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          Text(bank.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.ink)),
        ],
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
