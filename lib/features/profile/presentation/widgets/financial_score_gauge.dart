import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../score/domain/entities/score_financeiro.dart';

/// Arco do score financeiro (0–1000) com a faixa da nota. Mostra "—" quando
/// ainda não há dado para calcular: nunca exibe uma nota inventada. Tocar abre
/// a explicação de como a nota é composta.
class FinancialScoreGauge extends StatelessWidget {
  const FinancialScoreGauge({
    super.key,
    required this.score,
    required this.onTap,
    this.carregando = false,
  });

  /// Nulo enquanto carrega ou se o cálculo falhou.
  final ScoreFinanceiro? score;
  final bool carregando;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pontos = score?.pontos;
    final faixa = score?.faixa;
    final progress = pontos == null ? 0.0 : (pontos / ScoreFinanceiro.maximo).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Score financeiro',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.info_outline, size: 16, color: Colors.white.withValues(alpha: .7)),
              ],
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
                      carregando ? '…' : (pontos?.toString() ?? '—'),
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
                children: [_endLabel('0'), _endLabel('${ScoreFinanceiro.maximo}')],
              ),
            ),
            const SizedBox(height: 8),
            if (faixa != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.lima, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  faixa.rotulo,
                  style: const TextStyle(color: Color(0xFF1B2300), fontWeight: FontWeight.w800, fontSize: 12),
                ),
              )
            else if (!carregando)
              Text(
                score == null
                    ? 'Não foi possível calcular agora.'
                    : 'Registre transações, defina limites ou crie metas para ver sua nota.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: .8), fontWeight: FontWeight.w600, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _endLabel(String text) => Text(
        text,
        style: TextStyle(color: Colors.white.withValues(alpha: .7), fontWeight: FontWeight.w600, fontSize: 11),
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
    if (progress > 0) canvas.drawArc(rect, startAngle, sweepTotal * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) => oldDelegate.progress != progress;
}
