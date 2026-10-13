import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/usuario.dart';
import 'auth_providers.dart';

/// Sessão atual do Firebase Authentication, já traduzida para a entidade de
/// domínio `Usuario`. `null` = deslogado.
final usuarioAtualProvider = StreamProvider<Usuario?>((ref) {
  return ref.watch(authRepositoryProvider).watchUsuarioAtual();
});

/// Preferência salva do usuário (não o sensor do aparelho) — exibida/alterada
/// na tela de Perfil.
final biometriaHabilitadaProvider = FutureProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).biometriaHabilitada();
});

/// Se a tela de desbloqueio biométrico deve ser exigida para a sessão atual
/// (sensor disponível no aparelho + preferência habilitada pelo usuário).
final precisaBiometriaProvider = FutureProvider<bool>((ref) {
  ref.watch(usuarioAtualProvider);
  return ref.watch(verificarBiometriaUseCaseProvider).precisaDesbloquear();
});

/// Flag de sessão (não persistida): já passou pela checagem biométrica
/// desde que o app foi aberto. Reseta ao reiniciar o app ou ao deslogar.
final biometriaDesbloqueadaProvider = NotifierProvider<BiometriaDesbloqueadaNotifier, bool>(
  BiometriaDesbloqueadaNotifier.new,
);

class BiometriaDesbloqueadaNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void marcarDesbloqueada() => state = true;

  void resetar() => state = false;
}
