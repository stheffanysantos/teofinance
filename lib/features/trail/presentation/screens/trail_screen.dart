import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../portfolio/presentation/screens/portfolio_screen.dart';
import '../providers/trail_provider.dart';
import '../widgets/lesson_sheet.dart';
import '../widgets/trail_node_circle.dart';
import '../widgets/trail_path_painter.dart';
import 'quiz_screen.dart';

/// Tela de Trilha — implementação fiel a Trail.dc.html: streak + XP no
/// topo, unidade em destaque, caminho de lições em zigue-zague e um cartão
/// flutuante para iniciar a lição atual.
class TrailScreen extends ConsumerWidget {
  const TrailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final trail = ref.watch(trailProvider);
    final notifier = ref.read(trailProvider.notifier);

    final doneCount = kTrailNodes.where((n) => n.status == TrailNodeStatus.done).length;
    final currentIndex = kTrailNodes.indexWhere((n) => n.status == TrailNodeStatus.current);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Transform.rotate(
                            angle: 0.785398,
                            child: Container(width: 9, height: 9, color: t.accentInk),
                          ),
                          Text(
                            '${trail.streakDays} dias',
                            style: TextStyle(color: t.accentInk, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PortfolioScreen()),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: t.card,
                              border: Border.all(color: t.line),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.pie_chart_outline, size: 18, color: t.ink),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: t.card,
                            border: Border.all(color: t.line),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle)),
                              Text(
                                '${trail.xp} XP',
                                style: TextStyle(
                                  color: t.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 18,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UNIDADE 2',
                              style: TextStyle(color: Colors.white.withValues(alpha: .75), fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            const Text(
                              'Primeiros investimentos',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: kTrailCanvasWidth,
                          height: kTrailCanvasHeight,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CustomPaint(
                                    size: Size(kTrailCanvasWidth, kTrailCanvasHeight),
                                    painter: TrailPathPainter(
                                      nodeCount: kTrailNodes.length,
                                      doneCount: currentIndex >= 0 ? currentIndex + 1 : doneCount,
                                      trackColor: t.track,
                                      doneColor: t.hero,
                                      scaleX: 1,
                                    ),
                                  ),
                                  for (var i = 0; i < kTrailNodes.length; i++)
                                    Positioned(
                                      left: kTrailNodes[i].x - 45,
                                      top: kTrailNodeStartY + i * kTrailNodeSpacingY -
                                          (kTrailNodes[i].status == TrailNodeStatus.current ? 38 : 30),
                                      width: 90,
                                      child: TrailNodeCircle(
                                        node: kTrailNodes[i],
                                        onTap: notifier.toggleLessonSheet,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (trail.lessonSheetOpen)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: LessonSheet(
                title: 'Juros compostos',
                progressLabel: 'Lição 2 de 5 · 4 min',
                xpLabel: '+ 20 XP',
                onStart: () {
                  notifier.closeLessonSheet();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
