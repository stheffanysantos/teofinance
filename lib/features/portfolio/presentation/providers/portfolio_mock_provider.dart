import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Carteira simulada (fictícia, para fins educativos) — ver Portfolio.dc.html.
///
/// MVP não inclui investimentos reais; esta tela faz parte da trilha de
/// educação financeira (`.claude/agents/gamification-engineer.md`), sem
/// qualquer integração com corretoras.
enum PortfolioView { pie, bars }

class PortfolioAsset {
  const PortfolioAsset({
    required this.name,
    required this.sharePercent,
    required this.value,
    required this.performancePercent,
    required this.colorValue,
  });

  final String name;
  final double sharePercent;
  final double value;
  final double performancePercent;
  final int colorValue;

  Color get color => Color(colorValue);
  bool get isPositive => performancePercent > 0;
}

const kPortfolioAssets = [
  PortfolioAsset(name: 'CDB Aurora 110% CDI', sharePercent: 45, value: 4685, performancePercent: 0.9, colorValue: 0xFF0F3D44),
  PortfolioAsset(name: 'Tesouro Selic', sharePercent: 35, value: 3644, performancePercent: 1.4, colorValue: 0xFFC6F135),
  PortfolioAsset(name: 'Fundo Multimercado', sharePercent: 20, value: 2083, performancePercent: -0.6, colorValue: 0xFF7FB5AE),
];

final portfolioViewProvider = NotifierProvider<PortfolioViewNotifier, PortfolioView>(
  PortfolioViewNotifier.new,
);

class PortfolioViewNotifier extends Notifier<PortfolioView> {
  @override
  PortfolioView build() => PortfolioView.pie;

  void setPie() => state = PortfolioView.pie;

  void setBars() => state = PortfolioView.bars;
}
