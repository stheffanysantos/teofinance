import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/trail_provider.dart';

/// Nó circular de uma lição: concluída (✓), atual (★, pulsante) ou
/// bloqueada (cadeado).
class TrailNodeCircle extends StatelessWidget {
  const TrailNodeCircle({super.key, required this.node, required this.onTap});

  final TrailNodeData node;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isCurrent = node.status == TrailNodeStatus.current;
    final isDone = node.status == TrailNodeStatus.done;
    final size = isCurrent ? 76.0 : 60.0;

    final bg = isDone ? t.hero : (isCurrent ? t.accent : t.track);
    final fg = isDone ? t.accent : (isCurrent ? t.accentInk : t.sub);

    return GestureDetector(
      onTap: isCurrent ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border(bottom: BorderSide(color: Colors.black.withValues(alpha: .18), width: 5))
                  : null,
            ),
            alignment: Alignment.center,
            child: isDone
                ? Icon(Icons.check, color: fg, size: 26)
                : isCurrent
                    ? Icon(Icons.star, color: fg, size: 28)
                    : Icon(Icons.lock_outline, color: fg, size: 20),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 90,
            child: Text(
              node.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: node.status == TrailNodeStatus.locked ? t.sub : t.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
