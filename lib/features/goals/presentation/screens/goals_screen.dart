import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../meta/domain/entities/meta.dart';
import '../../../meta/presentation/providers/meta_providers.dart';
import '../../../meta/presentation/screens/nova_meta_screen.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// Tela de Metas — implementação fiel a Goals.dc.html, agora com dados
/// reais (ver `.claude/plans/MVP.md`, item 7). Acessada a partir de
/// "Metas ativas" no Dashboard.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final metas = ref.watch(metasStreamProvider).valueOrNull ?? [];
    final total = metas.fold<double>(0, (acc, m) => acc + m.valorAtual);
    final aporteSugerido = metas.fold<double>(0, (acc, m) => acc + m.aporteMensalSugerido);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          children: [
            metas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma meta cadastrada ainda.\nToque em + para adicionar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.sub, fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 18,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${metas.length} metas ativas',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.sub),
                            ),
                            Text(
                              'Metas',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.5,
                                color: t.ink,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                'Total guardado',
                                style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13),
                              ),
                              AppAmountText(
                                'R\$ ${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              AppAmountText(
                                'R\$ ${aporteSugerido.toStringAsFixed(0)}',
                                prefix: 'Aporte sugerido este mês: ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          spacing: 12,
                          children: [
                            for (final meta in metas) _MetaCard(meta: meta),
                          ],
                        ),
                      ],
                    ),
                  ),
            Positioned(
              right: 0,
              bottom: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NovaMetaScreen()),
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: 28, color: t.accentInk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCard extends ConsumerWidget {
  const _MetaCard({required this.meta});

  final Meta meta;

  Future<void> _aportar(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final valor = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar aporte'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text.replaceAll(',', '.'));
                Navigator.of(context).pop(v);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    if (valor != null && valor > 0) {
      await ref.read(aportarMetaUseCaseProvider).call(id: meta.id, valor: valor);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = meta.progresso >= .8 ? t.pos : (isDark ? t.accent : t.hero);
    final eta = '${_meses[meta.prazo.month - 1]} ${meta.prazo.year}';

    return GestureDetector(
      onTap: () => _aportar(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    meta.nome.isNotEmpty ? meta.nome.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: t.ink),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.nome, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                      Text(
                        'Prazo estimado · $eta',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                      ),
                    ],
                  ),
                ),
                Text('${meta.percentual}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: t.ink)),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: meta.progresso,
                minHeight: 10,
                backgroundColor: t.track,
                valueColor: AlwaysStoppedAnimation(ringColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppAmountText(
                  'R\$ ${meta.valorAtual.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: t.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                AppAmountText(
                  'R\$ ${meta.valorAlvo.toStringAsFixed(0)}',
                  prefix: 'meta ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.sub,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
