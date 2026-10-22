import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Biometria local (Face ID/digital) + a preferência "biometria habilitada"
/// — nunca a senha do usuário, que fica inteiramente a cargo do Firebase
/// Authentication (ver `.claude/rules/security.md`).
class BiometriaLocalDataSource {
  BiometriaLocalDataSource(this._localAuth, this._secureStorage);

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const _kBiometriaHabilitadaKey = 'biometria_habilitada';

  Future<bool> disponivel() async {
    final suportado = await _localAuth.isDeviceSupported();
    final podeChecar = await _localAuth.canCheckBiometrics;
    if (!suportado || !podeChecar) return false;
    // `canCheckBiometrics` pode ser true só pelo hardware; exige ao menos uma
    // biometria realmente cadastrada.
    return (await _localAuth.getAvailableBiometrics()).isNotEmpty;
  }

  Future<bool> habilitada() async {
    final valor = await _secureStorage.read(key: _kBiometriaHabilitadaKey);
    return valor == 'true';
  }

  Future<void> definirHabilitada(bool habilitada) {
    return _secureStorage.write(key: _kBiometriaHabilitadaKey, value: habilitada.toString());
  }

  Future<bool> autenticar() {
    return _localAuth.authenticate(
      localizedReason: 'Confirme sua identidade para abrir o TeoFinance',
      persistAcrossBackgrounding: true,
    );
  }
}
