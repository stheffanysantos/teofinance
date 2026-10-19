import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _chave = 'sync_pausado_ate';

/// Quanto tempo o sync fica pausado após uma exclusão de conta interrompida.
/// Passado esse prazo ele volta sozinho, para nunca ficar preso se o usuário
/// desistir de apagar a conta.
const kDuracaoPausaSync = Duration(hours: 24);

/// Pausa o sync. Usado quando os dados da nuvem já foram apagados mas a conta
/// ainda não: sem isso o próximo sync reenviaria os dados locais.
Future<void> pausarSync(FlutterSecureStorage storage, {DateTime? agora}) {
  final ate = (agora ?? DateTime.now()).add(kDuracaoPausaSync);
  return storage.write(key: _chave, value: ate.toIso8601String());
}

Future<void> retomarSync(FlutterSecureStorage storage) => storage.delete(key: _chave);

/// `true` enquanto a pausa vale. Qualquer erro de leitura conta como "não pausado".
Future<bool> syncPausado(FlutterSecureStorage storage, {DateTime? agora}) async {
  try {
    final texto = await storage.read(key: _chave);
    final ate = texto == null ? null : DateTime.tryParse(texto);
    return ate != null && (agora ?? DateTime.now()).isBefore(ate);
  } catch (_) {
    return false;
  }
}
