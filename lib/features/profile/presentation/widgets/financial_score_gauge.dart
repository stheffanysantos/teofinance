import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Arco de progresso do score financeiro (0–1000), com rótulo de faixa
/// ("Bom", "Ótimo"...) e variação do mês. Espelha o cartão hero de
/// Profile.dc.html.
class FinancialScoreGauge extends StatelessWidget {
  const FinancialScoreGauge({
    super.key,
    required this.score,
    required this.maxScore,
    required this.label,
    required this.deltaThisMonth,
  });

  final int score;
  final int maxScore;
  final String label;
  final int deltaThisMonth;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final progress = (score / maxScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: t.hero,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Score financeiro',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .8),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 220,
            height: 124,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  size: const Size(220, 121),
                  painter: _GaugeArcPainter(progress: progress),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _endLabel('0'),
                _endLabel('$maxScore'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lima,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Bom',
                  style: TextStyle(
                    color: Color(0xFF1B2300),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+ $deltaThisMonth pontos este mês',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
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

  Widget _endLabel(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .7),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      );
}

class _GaugeArcPainter extends CustomPainter {
  _GaugeArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 0, size.width - 20, size.height * 1.6);
    const startAngle = 3.1416; // 180°
    const sweepTotal = 3.1416; // 180°

    final track = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = AppColors.lima
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal, false, track);
    canvas.drawArc(rect, startAngle, sweepTotal * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
