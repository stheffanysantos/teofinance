import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../sync/presentation/widgets/sync_gate.dart';
import '../providers/auth_session_providers.dart';
import 'biometria_gate_screen.dart';
import 'login_screen.dart';

/// Ponto de entrada do app: decide entre Login, desbloqueio biométrico e o
/// `AppShell`, conforme o fluxo descrito em `.claude/docs/AUTH_FLOW.md`.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final usuario = ref.watch(usuarioAtualProvider);

    return usuario.when(
      loading: () => _Loading(t: t),
      error: (_, _) => const LoginScreen(),
      data: (usuario) {
        if (usuario == null) return const LoginScreen();

        final precisaBiometria = ref.watch(precisaBiometriaProvider);
        final jaDesbloqueou = ref.watch(biometriaDesbloqueadaProvider);

        return precisaBiometria.when(
          loading: () => _Loading(t: t),
          error: (_, _) => const SyncGate(child: AppShell()),
          data: (precisa) {
            if (precisa && !jaDesbloqueou) return const BiometriaGateScreen();
            return const SyncGate(child: AppShell());
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.t});

  final AppSurfaceTokens t;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.bg,
      body: Center(child: CircularProgressIndicator(color: t.hero)),
    );
  }
}
