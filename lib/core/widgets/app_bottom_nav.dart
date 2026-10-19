import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';

enum AppTab { inicio, contas, ia, perfil }

/// Aba atualmente selecionada no `AppShell` — mora aqui (não em
/// `app_shell.dart`) para evitar um import circular com as features que
/// precisam trocar de aba programaticamente (ex.: Dashboard → "Ver todas").
final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.inicio);

/// Barra de navegação inferior nos 4 destinos principais do app (Início/Contas/IA/Perfil).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current, this.onTap});

  final AppTab current;
  final ValueChanged<AppTab>? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final items = <_NavItem>[
      _NavItem(AppTab.inicio, 'Início', Icons.home_outlined),
      _NavItem(AppTab.contas, 'Contas', Icons.credit_card_outlined),
      _NavItem(AppTab.ia, 'IA', Icons.chat_bubble_outline),
      _NavItem(AppTab.perfil, 'Perfil', Icons.person_outline),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(color: t.bg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((item) {
                final selected = item.tab == current;
                final color = selected ? t.ink : t.sub;
                return GestureDetector(
                  onTap: () => onTap?.call(item.tab),
                  child: SizedBox(
                    width: 52,
                    child: Column(
                      children: [
                        Icon(item.icon, size: 22, color: color),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: t.ink.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  _NavItem(this.tab, this.label, this.icon);

  final AppTab tab;
  final String label;
  final IconData icon;
}
