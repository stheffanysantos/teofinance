import 'package:flutter/material.dart';

import '../providers/trail_provider.dart';

/// Caminho em zigue-zague que liga as lições, com curvas suaves (mesma
/// construção do SVG `path` em Trail.dc.html: cada segmento é uma cúbica de
/// Bézier com pontos de controle a ±60px verticalmente do nó).
class TrailPathPainter extends CustomPainter {
  TrailPathPainter({
    required this.nodeCount,
    required this.doneCount,
    required this.trackColor,
    required this.doneColor,
    required this.scaleX,
  });

  final int nodeCount;
  final int doneCount;
  final Color trackColor;
  final Color doneColor;
  final double scaleX;

  Offset _point(int i) => Offset(kTrailNodes[i].x * scaleX, kTrailNodeStartY + i * kTrailNodeSpacingY);

  Path _buildPath(int uptoIndex) {
    final path = Path()..moveTo(_point(0).dx, _point(0).dy);
    for (var i = 1; i <= uptoIndex; i++) {
      final a = _point(i - 1);
      final b = _point(i);
      path.cubicTo(a.dx, a.dy + kTrailNodeSpacingY / 2, b.dx, b.dy - kTrailNodeSpacingY / 2, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      dashPath(_buildPath(nodeCount - 1), dashLength: 2, gapLength: 14),
      trackPaint,
    );

    if (doneCount > 0) {
      final donePaint = Paint()
        ..color = doneColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(_buildPath(doneCount - 1), donePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrailPathPainter oldDelegate) =>
      oldDelegate.doneCount != doneCount || oldDelegate.scaleX != scaleX;
}

/// Converte um path contínuo em um path tracejado (equivalente a
/// `stroke-dasharray` do SVG).
Path dashPath(Path source, {required double dashLength, required double gapLength}) {
  final dest = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var draw = true;
    while (distance < metric.length) {
      final length = draw ? dashLength : gapLength;
      final next = (distance + length).clamp(0.0, metric.length);
      if (draw) {
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
      }
      distance = next;
      draw = !draw;
    }
  }
  return dest;
}
