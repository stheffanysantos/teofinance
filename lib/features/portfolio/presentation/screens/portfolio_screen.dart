import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/portfolio_mock_provider.dart';
import '../widgets/allocation_donut_painter.dart';

/// Tela de Carteira Simulada — implementação fiel a Portfolio.dc.html.
/// Acessada a partir da Trilha (gamificação/educação financeira).
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final view = ref.watch(portfolioViewProvider);
    final notifier = ref.read(portfolioViewProvider.notifier);
    final isPie = view == PortfolioView.pie;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 18,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aprenda sem risco', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.sub)),
                      Text(
                        'Carteira simulada',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5, color: t.ink),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      'FICTÍCIA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.accentInk),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text('Valor simulado', style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 13)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'R\$ 10.412',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          ',30',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .6),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF7BE3AB), borderRadius: BorderRadius.circular(6)),
                          child: const Text(
                            '+ 4,12%',
                            style: TextStyle(color: Color(0xFF06281A), fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        Text(
                          'em 30 dias · começou com R\$ 10.000',
                          style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Alocação', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ViewToggleChip(label: 'Pizza', selected: isPie, onTap: notifier.setPie),
                              _ViewToggleChip(label: 'Barras', selected: !isPie, onTap: notifier.setBars),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isPie)
                      Row(
                        spacing: 20,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(150, 150),
                                  painter: AllocationDonutPainter(assets: kPortfolioAssets),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${kPortfolioAssets.length} ativos',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.sub),
                                    ),
                                    Text(
                                      '100%',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.ink),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: 12,
                              children: [
                                for (final asset in kPortfolioAssets)
                                  Row(
                                    spacing: 8,
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: asset.color, borderRadius: BorderRadius.circular(4))),
                                      Expanded(
                                        child: Text(
                                          asset.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.ink),
                                        ),
                                      ),
                                      Text(
                                        '${asset.sharePercent.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: t.sub,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        spacing: 14,
                        children: [
                          for (final asset in kPortfolioAssets)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(asset.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: t.ink)),
                                    Text('${asset.sharePercent.toStringAsFixed(0)}%', style: TextStyle(color: t.sub)),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: asset.sharePercent / 100,
                                    minHeight: 14,
                                    backgroundColor: t.track,
                                    valueColor: AlwaysStoppedAnimation(asset.color),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text('Desempenho · 30 dias', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink)),
                  Container(
                    decoration: BoxDecoration(
                      color: t.card,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < kPortfolioAssets.length; i++)
                          _PerformanceRow(asset: kPortfolioAssets[i], showTopBorder: i > 0),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'Simulação para fins educativos. Rentabilidade passada não garante resultado futuro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: t.sub, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  const _ViewToggleChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? t.card : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? t.ink : t.sub),
        ),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.asset, required this.showTopBorder});

  final PortfolioAsset asset;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final perfColor = asset.isPositive ? t.pos : t.neg;
    final perfBg = asset.isPositive ? t.posBg : t.negBg;
    final sign = asset.isPositive ? '+ ' : '− ';
    final perfLabel = '$sign${asset.performancePercent.abs().toStringAsFixed(1).replaceAll('.', ',')}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showTopBorder ? Border(top: BorderSide(color: t.line)) : null,
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Container(width: 14, height: 14, decoration: BoxDecoration(color: asset.color, borderRadius: BorderRadius.circular(4))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.ink)),
                Text(
                  'R\$ ${asset.value.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: t.sub, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: perfBg, borderRadius: BorderRadius.circular(8)),
            child: Text(
              perfLabel,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: perfColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
