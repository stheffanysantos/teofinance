import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/portfolio_mock_provider.dart';

/// Gráfico de rosca (donut) da alocação de ativos, equivalente ao SVG de
/// círculos concêntricos com `stroke-dasharray` do Portfolio.dc.html.
class AllocationDonutPainter extends CustomPainter {
  AllocationDonutPainter({required this.assets});

  final List<PortfolioAsset> assets;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 11;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var cumulative = 0.0;
    for (final asset in assets) {
      final paint = Paint()
        ..color = asset.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22;
      final startAngle = -math.pi / 2 + (cumulative / 100) * 2 * math.pi;
      final sweepAngle = (asset.sharePercent / 100) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      cumulative += asset.sharePercent;
    }
  }

  @override
  bool shouldRepaint(covariant AllocationDonutPainter oldDelegate) => oldDelegate.assets != assets;
}
