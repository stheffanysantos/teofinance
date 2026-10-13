import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Cartão de opção em "Traga seus dados", com radio próprio (círculo com
/// borda/preenchimento) em vez do Radio padrão do Material, para casar com
/// o traço do design system.
class ConnectOptionCard extends StatelessWidget {
  const ConnectOptionCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    this.footer,
    this.extra,
  });

  final bool selected;
  final VoidCallback onTap;
  final Color iconBg;
  final Widget icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget? footer;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final accentColor = Theme.of(context).brightness == Brightness.dark ? t.accent : t.hero;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: selected ? accentColor : t.line, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Row(
              spacing: 14,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: icon,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: t.ink)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtitleColor)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? accentColor : t.line, width: 2),
                    color: selected ? accentColor : Colors.transparent,
                  ),
                ),
              ],
            ),
            ?extra,
            ?footer,
          ],
        ),
      ),
    );
  }
}
