import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de uma lição na trilha de educação financeira.
enum TrailNodeStatus { done, current, locked }

class TrailNodeData {
  const TrailNodeData({required this.name, required this.x, required this.status});

  final String name;

  /// Posição horizontal no "canvas" de 350px de largura do design original.
  final double x;
  final TrailNodeStatus status;
}

/// Unidade 2 · "Primeiros investimentos" — ver Trail.dc.html.
///
/// TODO(fase-3): mover para `features/trail/data/` quando o progresso do
/// usuário for persistido (ver `.claude/agents/gamification-engineer.md`).
const kTrailNodes = [
  TrailNodeData(name: 'Orçamento', x: 175, status: TrailNodeStatus.done),
  TrailNodeData(name: 'Reserva', x: 255, status: TrailNodeStatus.done),
  TrailNodeData(name: 'Inflação', x: 215, status: TrailNodeStatus.done),
  TrailNodeData(name: 'Juros compostos', x: 115, status: TrailNodeStatus.current),
  TrailNodeData(name: 'Renda fixa', x: 85, status: TrailNodeStatus.locked),
  TrailNodeData(name: 'Renda variável', x: 170, status: TrailNodeStatus.locked),
];

const kTrailNodeSpacingY = 120.0;
const kTrailNodeStartY = 40.0;
const kTrailCanvasWidth = 350.0;
const kTrailCanvasHeight = 760.0;

class TrailState {
  const TrailState({this.streakDays = 7, this.xp = 1240, this.lessonSheetOpen = true});

  final int streakDays;
  final int xp;
  final bool lessonSheetOpen;

  TrailState copyWith({bool? lessonSheetOpen}) {
    return TrailState(
      streakDays: streakDays,
      xp: xp,
      lessonSheetOpen: lessonSheetOpen ?? this.lessonSheetOpen,
    );
  }
}

final trailProvider = NotifierProvider<TrailNotifier, TrailState>(TrailNotifier.new);

class TrailNotifier extends Notifier<TrailState> {
  @override
  TrailState build() => const TrailState();

  void toggleLessonSheet() => state = state.copyWith(lessonSheetOpen: !state.lessonSheetOpen);

  void closeLessonSheet() => state = state.copyWith(lessonSheetOpen: false);

  void openLessonSheet() => state = state.copyWith(lessonSheetOpen: true);
}
