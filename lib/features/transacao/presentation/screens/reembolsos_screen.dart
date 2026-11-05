import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Quem ainda deve a sua parte das compras divididas, agrupado por pessoa.
class ReembolsosScreen extends ConsumerWidget {
  const ReembolsosScreen({super.key});

  Future<void> _marcar(WidgetRef ref, Transacao t, String pessoa) {
    return ref.read(registrarReembolsoUseCaseProvider).call(transacao: t, pessoa: pessoa, pago: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final todas = ref.watch(transacoesStreamProvider).valueOrNull ?? const <Transacao>[];
    final divididas = todas.where((x) => x.ehDividida && x.valor < 0).toList()
      ..sort((a, b) => b.data.compareTo(a.data));

    // pessoa → compras em que ela ainda não pagou
    final pendentes = <String, List<Transacao>>{};
    for (final x in divididas) {
      for (final p in x.pessoasPendentes) {
        pendentes.putIfAbsent(p, () => []).add(x);
      }
    }
    final total = pendentes.values.expand((l) => l).fold<double>(0, (a, x) => a + x.parteDeCadaPessoa);
    final pessoas = pendentes.keys.toList()..sort();

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Reembolsos a receber', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funcionam os reembolsos',
            paragrafos: [
              'Quando você divide uma compra ("Dividir com amigos"), o saldo do app já conta só a sua parte.',
              'Aqui você acompanha quem ainda precisa devolver a parte dele. Toque em "Recebi" quando a pessoa pagar.',
              'Marcar como recebido não altera o seu saldo nem as suas despesas: é só um controle de quem deve.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total a receber', style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(formatCurrency(total), style: TextStyle(color: t.accent, fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (pessoas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  divididas.isEmpty
                      ? 'Nenhuma compra dividida ainda. Segure uma despesa em Transações e escolha "Dividir com amigos".'
                      : 'Tudo recebido. Ninguém te deve nada.',
                  style: TextStyle(color: t.sub),
                ),
              ),
            for (final pessoa in pessoas) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$pessoa deve ${formatCurrency(pendentes[pessoa]!.fold<double>(0, (a, x) => a + x.parteDeCadaPessoa))}',
                      style: TextStyle(fontWeight: FontWeight.w800, color: t.ink, fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      for (final x in pendentes[pessoa]!) {
                        await _marcar(ref, x, pessoa);
                      }
                    },
                    child: const Text('Recebi tudo'),
                  ),
                ],
              ),
              for (final x in pendentes[pessoa]!)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(x.descricao, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.ink)),
                  subtitle: Text(
                    '${x.data.day.toString().padLeft(2, '0')}/${x.data.month.toString().padLeft(2, '0')} · compra de ${formatCurrency(x.valorCobrado.abs())}',
                    style: TextStyle(color: t.sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatCurrency(x.parteDeCadaPessoa), style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                      TextButton(onPressed: () => _marcar(ref, x, pessoa), child: const Text('Recebi')),
                    ],
                  ),
                ),
              Divider(color: t.line),
            ],
          ],
        ),
      ),
    );
  }
}
