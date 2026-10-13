import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/quiz_provider.dart';

/// Tela de questão da trilha — implementação fiel a Quiz.dc.html.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final quiz = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);
    final progress = quiz.checked && quiz.isCorrect ? 0.5 : 0.375;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                spacing: 14,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.close, size: 22, color: t.sub),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: t.track,
                        valueColor: AlwaysStoppedAnimation(t.accent),
                      ),
                    ),
                  ),
                  Text(
                    '${quiz.checked ? 4 : 3}/8',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: t.sub,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 22,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            'RENDA FIXA · LIÇÃO 2',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.sub),
                          ),
                        ),
                        Text(
                          kQuizQuestion,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.7,
                            height: 1.15,
                            color: t.ink,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 12,
                      children: [
                        for (var i = 0; i < kQuizOptions.length; i++)
                          _QuizOptionTile(
                            option: kQuizOptions[i],
                            index: i,
                            quiz: quiz,
                            onTap: () => notifier.select(i),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _FeedbackBar(quiz: quiz, onPrimary: notifier.primaryAction),
          ],
        ),
      ),
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.option,
    required this.index,
    required this.quiz,
    required this.onTap,
  });

  final QuizOption option;
  final int index;
  final QuizState quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isSelected = quiz.selectedIndex == index;
    final isRight = index == kQuizCorrectIndex;

    Color bg = t.card;
    Color border = t.line;
    Color badgeBg = t.track;
    Color badgeFg = t.ink;
    double opacity = 1;

    if (!quiz.checked && isSelected) {
      bg = t.hero.withValues(alpha: .08);
      border = t.hero;
      badgeBg = t.hero;
      badgeFg = Colors.white;
    }
    if (quiz.checked) {
      if (isRight) {
        bg = t.posBg;
        border = t.pos;
        badgeBg = t.pos;
        badgeFg = Colors.white;
      } else if (isSelected) {
        bg = t.negBg;
        border = t.neg;
        badgeBg = t.neg;
        badgeFg = Colors.white;
      } else {
        opacity = .5;
      }
    }

    return GestureDetector(
      onTap: quiz.checked ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 14,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(9)),
                alignment: Alignment.center,
                child: Text(
                  option.letter,
                  style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.3, color: t.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({required this.quiz, required this.onPrimary});

  final QuizState quiz;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ok = quiz.isCorrect;
    final feedbackBg = quiz.checked ? (ok ? t.posBg : t.negBg) : t.bg;
    final feedbackColor = ok ? t.pos : t.neg;

    final buttonBg = !quiz.checked
        ? (quiz.canCheck ? t.hero : t.track)
        : (ok ? t.pos : t.neg);
    final buttonFg = !quiz.checked && !quiz.canCheck ? t.sub : Colors.white;
    final buttonLabel = !quiz.checked ? 'Verificar' : (ok ? 'Continuar' : 'Entendi');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: feedbackBg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Column(
        spacing: 14,
        children: [
          if (quiz.checked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: feedbackColor, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(ok ? Icons.check : Icons.close, color: Colors.white, size: 16),
                    ),
                    Text(
                      ok ? 'Correto!' : 'Quase lá',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: feedbackColor),
                    ),
                    if (ok) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          '+ 10 XP',
                          style: TextStyle(color: t.accentInk, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  ok ? kQuizCorrectExplanation : kQuizWrongExplanation,
                  style: TextStyle(fontSize: 13.5, height: 1.5, color: t.ink),
                ),
              ],
            ),
          GestureDetector(
            onTap: onPrimary,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: buttonBg, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(
                buttonLabel,
                style: TextStyle(color: buttonFg, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
