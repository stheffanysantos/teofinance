import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai_assistant/presentation/screens/chat_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/trail/presentation/screens/trail_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../theme/app_theme.dart';
import 'app_bottom_nav.dart';

/// Casca do app: um `Scaffold` com a barra inferior fixa e o conteúdo da
/// aba selecionada por cima. Cada feature só precisa expor seu widget de
/// conteúdo (sem Scaffold/SafeArea/bottom nav próprios).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final tab = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          Expanded(child: _contentFor(tab)),
          SafeArea(
            top: false,
            child: AppBottomNav(
              current: tab,
              onTap: (next) => ref.read(currentTabProvider.notifier).state = next,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentFor(AppTab tab) {
    switch (tab) {
      case AppTab.inicio:
        return const DashboardScreen();
      case AppTab.perfil:
        return const ProfileScreen();
      case AppTab.contas:
        return const TransactionsScreen();
      case AppTab.trilha:
        return const TrailScreen();
      case AppTab.ia:
        return const ChatScreen();
    }
  }
}
