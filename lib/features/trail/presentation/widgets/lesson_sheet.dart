import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Cartão flutuante com a lição atual e o botão "Começar", exibido sobre a
/// trilha quando o nó em destaque é tocado.
class LessonSheet extends StatelessWidget {
  const LessonSheet({
    super.key,
    required this.title,
    required this.progressLabel,
    required this.xpLabel,
    required this.onStart,
  });

  final String title;
  final String progressLabel;
  final String xpLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: t.ink)),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: t.sub),
                    children: [
                      TextSpan(text: '$progressLabel · '),
                      TextSpan(
                        text: xpLabel,
                        style: TextStyle(color: t.pos, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Começar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
