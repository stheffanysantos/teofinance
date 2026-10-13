import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Chip de filtro (período ou categoria) em pílula, com estado selecionado
/// usando a cor de destaque do tema (petróleo no claro, lima no escuro).
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.outlinedWhenUnselected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Usado na fileira de períodos, que tem borda mesmo quando não selecionada.
  final bool outlinedWhenUnselected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? t.accent : t.hero;
    final selectedFg = isDark ? t.accentInk : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedBg : (outlinedWhenUnselected ? t.card : t.track),
          borderRadius: BorderRadius.circular(999),
          border: outlinedWhenUnselected
              ? Border.all(color: selected ? selectedBg : t.line)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? selectedFg : t.ink,
          ),
        ),
      ),
    );
  }
}
