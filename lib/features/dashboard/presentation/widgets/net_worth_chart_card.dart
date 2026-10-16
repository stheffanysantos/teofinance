import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

/// Cartão de patrimônio líquido com mini-gráfico de linha (6 meses).
class NetWorthChartCard extends StatelessWidget {
  const NetWorthChartCard({
    super.key,
    required this.deltaLabel,
    required this.rangeLabel,
    required this.months,
    required this.values,
  });

  final String deltaLabel;
  final String rangeLabel;
  final List<String> months;

  /// Valores normalizados 0–1 (0 = base do gráfico, 1 = topo), um por mês.
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Patrimônio líquido',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
              ),
              Text(
                deltaLabel,
                style: TextStyle(color: t.pos, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AppAmountText(rangeLabel, style: TextStyle(fontSize: 12, color: t.sub)),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _NetWorthLinePainter(
                values: values,
                lineColor: t.pos,
                gridColor: t.line,
                dotBorderColor: t.card,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < months.length; i++)
                  Text(
                    months[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == months.length - 1 ? FontWeight.w800 : FontWeight.w600,
                      color: i == months.length - 1 ? t.ink : t.sub,
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

class _NetWorthLinePainter extends CustomPainter {
  _NetWorthLinePainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.dotBorderColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color dotBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.25, 0.55, 0.85]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * (i / (values.length - 1)),
          size.height * (1 - values[i]) * 0.78 + size.height * 0.12,
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: .22), lineColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    canvas.drawCircle(points.last, 6, Paint()..color = lineColor);
    canvas.drawCircle(
      points.last,
      6,
      Paint()
        ..color = dotBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _NetWorthLinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
