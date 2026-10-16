import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/renda.dart';
import '../providers/renda_providers.dart';
import 'nova_renda_screen.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

/// Lista de rendas fixas e variáveis cadastradas — acessada a partir do
/// Perfil ("Minhas rendas").
class RendaScreen extends ConsumerWidget {
  const RendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final rendas = ref.watch(rendasStreamProvider).valueOrNull ?? [];
    final fixas = rendas.where((r) => r.isFixa).toList();
    final variaveis = rendas.where((r) => !r.isFixa).toList();

    final totalMensalFixo = fixas
        .where((r) => r.ativa && r.recorrencia == RecorrenciaRenda.mensal)
        .fold<double>(0, (acc, r) => acc + r.valor);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Minhas rendas', style: TextStyle(color: t.ink)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: t.accentInk,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NovaRendaScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: rendas.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma renda cadastrada ainda.\nToque em + para adicionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.sub, fontSize: 14),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text('Renda fixa mensal', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                        AppAmountText(
                          'R\$ ${totalMensalFixo.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (fixas.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('Fixas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                    const SizedBox(height: 8),
                    for (final renda in fixas) _RendaCard(renda: renda),
                  ],
                  if (variaveis.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('Variáveis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                    const SizedBox(height: 8),
                    for (final renda in variaveis) _RendaCard(renda: renda),
                  ],
                ],
              ),
      ),
    );
  }
}

class _RendaCard extends ConsumerWidget {
  const _RendaCard({required this.renda});

  final Renda renda;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  renda.descricao,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: renda.ativa ? t.ink : t.sub,
                    decoration: renda.ativa ? null : TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  renda.isFixa
                      ? _rotuloRecorrencia(renda.recorrencia!)
                      : '${renda.dataRecebimento.day.toString().padLeft(2, '0')}/'
                          '${renda.dataRecebimento.month.toString().padLeft(2, '0')}/${renda.dataRecebimento.year}',
                  style: TextStyle(fontSize: 12, color: t.sub),
                ),
              ],
            ),
          ),
          AppAmountText(
            'R\$ ${renda.valor.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: t.pos),
          ),
          if (renda.isFixa)
            Switch(
              value: renda.ativa,
              activeTrackColor: t.pos,
              onChanged: (v) => ref
                  .read(rendaRepositoryProvider)
                  .definirAtiva(id: renda.id, ativa: v),
            ),
        ],
      ),
    );
  }

  String _rotuloRecorrencia(RecorrenciaRenda recorrencia) => switch (recorrencia) {
        RecorrenciaRenda.semanal => 'Semanal',
        RecorrenciaRenda.mensal => 'Mensal',
        RecorrenciaRenda.anual => 'Anual',
      };
}
