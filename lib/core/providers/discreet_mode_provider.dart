import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

const kMascaraValor = '•••••';

/// Modo Discreto: quando ligado, todo valor monetário exibido via
/// `AppAmountText` vira [kMascaraValor]. Persistido no aparelho para continuar
/// oculto depois que o app é fechado e reaberto.
final modoDiscretoProvider = NotifierProvider<ModoDiscretoNotifier, bool>(
  ModoDiscretoNotifier.new,
);

class ModoDiscretoNotifier extends Notifier<bool> {
  static const _chave = 'modo_discreto';

  @override
  bool build() {
    _carregar();
    return false;
  }

  Future<void> _carregar() async {
    try {
      final salvo = await ref.read(secureStorageProvider).read(key: _chave);
      if (salvo == '1') state = true;
    } catch (_) {
      // sem armazenamento seguro disponível (ex.: testes) — segue desligado.
    }
  }

  Future<void> alternar() async {
    state = !state;
    try {
      await ref.read(secureStorageProvider).write(key: _chave, value: state ? '1' : '0');
    } catch (_) {
      // a preferência vale na sessão mesmo que não consiga persistir.
    }
  }
}
