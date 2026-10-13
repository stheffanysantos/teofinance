import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Cartão hero com o saldo total, selo "processado no aparelho" (privacidade
/// da IA local) e variação frente ao mês anterior.
class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.integerPart,
    required this.centsPart,
    required this.deltaLabel,
  });

  final String integerPart;
  final String centsPart;
  final String deltaLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.hero,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 12, color: t.accent),
                    const SizedBox(width: 6),
                    const Text(
                      'Processado no aparelho',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                integerPart,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ',$centsPart',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .6),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.posOnHero,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deltaLabel,
                  style: const TextStyle(
                    color: Color(0xFF06281A),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'vs. mês passado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
