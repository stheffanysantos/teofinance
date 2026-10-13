import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de preferências exibido na tela de Perfil.
///
/// A preferência de biometria agora vive em `features/auth/` (ver
/// `biometriaHabilitadaProvider`), persistida via `flutter_secure_storage`.
///
/// TODO(fase-2): mover `privacyMode` para `core/services/secure_prefs_service.dart`
/// quando a persistência local de preferências gerais for implementada —
/// por ora vive só na sessão, em memória.
class ProfileSettingsState {
  const ProfileSettingsState({this.privacyMode = false});

  final bool privacyMode;

  ProfileSettingsState copyWith({bool? privacyMode}) {
    return ProfileSettingsState(privacyMode: privacyMode ?? this.privacyMode);
  }
}

final profileSettingsProvider =
    NotifierProvider<ProfileSettingsNotifier, ProfileSettingsState>(
      ProfileSettingsNotifier.new,
    );

class ProfileSettingsNotifier extends Notifier<ProfileSettingsState> {
  @override
  ProfileSettingsState build() => const ProfileSettingsState();

  void togglePrivacyMode() =>
      state = state.copyWith(privacyMode: !state.privacyMode);
}
