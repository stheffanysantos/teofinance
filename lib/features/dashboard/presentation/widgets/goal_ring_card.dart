import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

/// Cartão de meta com anel de progresso, usado na lista horizontal
/// "Metas ativas" do dashboard.
class GoalRingCard extends StatelessWidget {
  const GoalRingCard({
    super.key,
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.ringColor,
    required this.amountLabel,
  });

  final String title;
  final String progressLabel;
  final double progress; // 0..1
  final Color ringColor;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(76, 76),
                  painter: _RingPainter(
                    progress: progress,
                    track: t.track,
                    color: ringColor,
                  ),
                ),
                Text(
                  progressLabel,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: t.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.15, color: t.ink),
          ),
          const SizedBox(height: 3),
          AppAmountText(
            amountLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: t.sub,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.track, required this.color});

  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 7.0;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    const startAngle = -1.5708; // -90°
    canvas.drawArc(arcRect, 0, 6.2832, false, trackPaint);
    canvas.drawArc(arcRect, startAngle, 6.2832 * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
