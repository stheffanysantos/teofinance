import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Linha de configuração com ícone, título, descrição e um switch estilo
/// pílula (igual ao mock: trilho colorido + bolinha branca animada).
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showTopBorder = false,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showTopBorder
            ? Border(top: BorderSide(color: t.line))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.track,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: t.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: t.sub),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? t.on : t.off,
                borderRadius: BorderRadius.circular(99),
              ),
              alignment: value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de configuração de navegação simples (sem switch), com chevron.
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
    this.showTopBorder = true,
  });

  final Widget icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showTopBorder
              ? Border(top: BorderSide(color: t.line))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.track,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: t.ink,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.sub,
                ),
              ),
            const SizedBox(width: 6),
            Text('›', style: TextStyle(color: t.sub, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

/// Segmented control Claro/Escuro usado na linha "Tema".
class ThemeSegmentedControl extends StatelessWidget {
  const ThemeSegmentedControl({
    super.key,
    required this.isDark,
    required this.onLight,
    required this.onDark,
  });

  final bool isDark;
  final VoidCallback onLight;
  final VoidCallback onDark;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.track,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(context, 'Claro', !isDark, onLight),
          _segment(context, 'Escuro', isDark, onDark),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? t.card : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? t.ink : t.sub,
          ),
        ),
      ),
    );
  }
}
