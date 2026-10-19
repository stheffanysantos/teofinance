import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../lgpd/presentation/screens/meus_dados_screen.dart';
import '../../../renda/presentation/screens/renda_screen.dart';
import '../../../score/presentation/providers/score_providers.dart';
import '../../../score/presentation/widgets/como_calculamos_score_sheet.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../../../core/providers/discreet_mode_provider.dart';
import '../providers/app_info_provider.dart';
import '../widgets/financial_score_gauge.dart';
import '../widgets/settings_toggle_tile.dart';
import 'sobre_screen.dart';

/// Tela de Perfil — implementação fiel a Profile.dc.html (design system
/// TeoFinance, direção 1: petróleo + lima). Ver `.claude/memory/design-system.md`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final modoDiscreto = ref.watch(modoDiscretoProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    final usuario = ref.watch(usuarioAtualProvider).valueOrNull;
    final email = usuario?.email ?? '';
    final iniciais = email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?';
    final biometriaHabilitada = ref.watch(biometriaHabilitadaProvider).valueOrNull ?? false;
    final syncState = ref.watch(syncUiStateProvider);
    final appInfo = ref.watch(appInfoProvider).valueOrNull;
    final score = ref.watch(scoreFinanceiroProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    _ProfileHeader(
                      initials: iniciais,
                      name: email.isNotEmpty ? email : 'Conta',
                      memberSince: 'TeoFinance',
                    ),
                    const SizedBox(height: 18),
                    FinancialScoreGauge(
                      score: score.valueOrNull,
                      carregando: score.isLoading,
                      onTap: () => ComoCalculamosScoreSheet.mostrar(context, score.valueOrNull),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'CONFIGURAÇÕES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.sub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: t.card,
                        border: Border.all(color: t.line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SettingsToggleTile(
                            icon: Icon(Icons.lock_outline, size: 18, color: t.ink),
                            title: 'Modo Discreto',
                            subtitle: 'Oculta os valores em todas as telas',
                            value: modoDiscreto,
                            onChanged: (_) => ref.read(modoDiscretoProvider.notifier).alternar(),
                          ),
                          SettingsToggleTile(
                            icon: Icon(Icons.fingerprint, size: 18, color: t.ink),
                            title: 'Biometria',
                            subtitle: 'Desbloquear com digital ou rosto',
                            value: biometriaHabilitada,
                            onChanged: (novoValor) async {
                              await ref
                                  .read(authRepositoryProvider)
                                  .definirBiometriaHabilitada(novoValor);
                              ref.invalidate(biometriaHabilitadaProvider);
                            },
                            showTopBorder: true,
                          ),
                          SettingsNavTile(
                            icon: Icon(Icons.payments_outlined, size: 18, color: t.ink),
                            title: 'Minhas rendas',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RendaScreen()),
                            ),
                          ),
                          SettingsNavTile(
                            icon: syncState.estado == SyncExecutionState.sincronizando
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: t.ink),
                                  )
                                : Icon(Icons.sync, size: 18, color: t.ink),
                            title: 'Sincronizar agora',
                            trailingText: switch (syncState.estado) {
                              SyncExecutionState.sincronizando => 'Enviando...',
                              SyncExecutionState.concluida => 'Atualizado',
                              SyncExecutionState.falhou => 'Falhou',
                              SyncExecutionState.ocioso => null,
                            },
                            onTap: () => ref.read(syncUiStateProvider.notifier).sincronizarAgora(),
                          ),
                          SettingsNavTile(
                            icon: Icon(Icons.notifications_none, size: 18, color: t.ink),
                            title: 'Notificações',
                            trailingText: '3 ativas',
                            onTap: () {},
                          ),
                          _ThemeRow(
                            isDark: isDark,
                            onLight: themeNotifier.setLight,
                            onDark: themeNotifier.setDark,
                          ),
                          SettingsNavTile(
                            icon: Icon(Icons.shield_outlined, size: 18, color: t.ink),
                            title: 'Privacidade e dados',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MeusDadosScreen()),
                            ),
                          ),
                          SettingsNavTile(
                            icon: Icon(Icons.info_outline, size: 18, color: t.ink),
                            title: 'Sobre o app',
                            trailingText: appInfo == null ? null : 'v${appInfo.version}',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SobreScreen()),
                            ),
                          ),
                          SettingsNavTile(
                            icon: Icon(Icons.logout, size: 18, color: t.neg),
                            title: 'Sair',
                            onTap: () async {
                              await ref.read(logoutUseCaseProvider).call();
                              ref.read(biometriaDesbloqueadaProvider.notifier).resetar();
                            },
                          ),
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
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
            child: Icon(Icons.brightness_6_outlined, size: 18, color: t.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tema',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: t.ink,
              ),
            ),
          ),
          ThemeSegmentedControl(
            isDark: isDark,
            onLight: onLight,
            onDark: onDark,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.memberSince,
  });

  final String initials;
  final String name;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: t.hero, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w800,
              fontSize: 21,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                  color: t.ink,
                ),
              ),
              Text(
                memberSince,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: t.sub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
