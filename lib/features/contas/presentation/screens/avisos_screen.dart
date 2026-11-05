import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/planejar_lembrete_extrato.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/contas/presentation/providers/lembretes_providers.dart';
import 'package:teofinance/features/contas/presentation/screens/notificacoes_screen.dart';

/// Central de avisos (o sino da Home): o que pede atenção agora — contas
/// atrasadas ou vencendo e o próximo lembrete do extrato.
class AvisosScreen extends ConsumerWidget {
  const AvisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final contas =
        ref.watch(contasStreamProvider).valueOrNull ?? const <ContaAPagar>[];
    final config = ref.watch(configLembretesProvider);
    final hoje = DateTime.now();

    final pendentes =
        contas.where((c) => !c.paga && c.diasParaVencer(hoje) <= 7).toList()
          ..sort((a, b) => a.vencimento.compareTo(b.vencimento));
    final proximoExtrato = config.extratoAtivo
        ? planejarLembretesExtrato(
            agora: hoje,
            dia: config.extratoDia,
            hora: config.hora,
          ).firstOrNull
        : null;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(
          'Avisos',
          style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Configurar lembretes',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (pendentes.isEmpty && proximoExtrato == null)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none, size: 40, color: t.sub),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum aviso por enquanto',
                      style: TextStyle(
                        color: t.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contas vencendo e lembretes aparecem aqui.',
                      style: TextStyle(color: t.sub, fontSize: 13),
                    ),
                  ],
                ),
              ),
            for (final c in pendentes)
              _AvisoTile(
                icone: Icons.receipt_long_outlined,
                cor: c.diasParaVencer(hoje) < 0 ? t.neg : t.ink,
                titulo: c.descricao,
                detalhe:
                    '${_quando(c.diasParaVencer(hoje))} · ${formatCurrency(c.valor)}',
              ),
            if (proximoExtrato != null)
              _AvisoTile(
                icone: Icons.fact_check_outlined,
                cor: t.ink,
                titulo: 'Enviar o extrato do mês anterior',
                detalhe:
                    'Próximo aviso em ${proximoExtrato.quando.day.toString().padLeft(2, '0')}/'
                    '${proximoExtrato.quando.month.toString().padLeft(2, '0')}',
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
              ),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Configurar lembretes'),
            ),
            const SizedBox(height: 12),
            Text(
              'Dia do extrato: ${config.extratoAtivo ? 'todo dia ${config.extratoDia}' : 'desligado'}. '
              'Você muda isso em Configurar lembretes.',
              style: TextStyle(fontSize: 12.5, color: t.sub, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  static String _quando(int dias) {
    if (dias < 0) return 'Atrasada há ${-dias} ${dias == -1 ? 'dia' : 'dias'}';
    return switch (dias) {
      0 => 'Vence hoje',
      1 => 'Vence amanhã',
      _ => 'Vence em $dias dias',
    };
  }
}

class _AvisoTile extends StatelessWidget {
  const _AvisoTile({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.detalhe,
  });

  final IconData icone;
  final Color cor;
  final String titulo;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(icone, color: cor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  detalhe,
                  style: TextStyle(
                    color: cor == t.neg ? t.neg : t.sub,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
