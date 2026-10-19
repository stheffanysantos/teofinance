import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/sync/sync_pausa.dart';

class _Armazenamento implements FlutterSecureStorage {
  final dados = <String, String>{};
  bool quebrado = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (quebrado) throw StateError('sem armazenamento');
    final chave = invocation.namedArguments[#key] as String;
    switch (invocation.memberName) {
      case #write:
        dados[chave] = invocation.namedArguments[#value] as String;
        return Future<void>.value();
      case #delete:
        dados.remove(chave);
        return Future<void>.value();
      default:
        return Future<String?>.value(dados[chave]);
    }
  }
}

void main() {
  final agora = DateTime(2026, 10, 19, 12);

  test('sem nada guardado o sync não está pausado', () async {
    expect(await syncPausado(_Armazenamento(), agora: agora), isFalse);
  });

  test('pausado vale por 24 horas e volta sozinho depois', () async {
    final s = _Armazenamento();
    await pausarSync(s, agora: agora);

    expect(await syncPausado(s, agora: agora.add(const Duration(hours: 23, minutes: 59))), isTrue);
    expect(await syncPausado(s, agora: agora.add(const Duration(hours: 24))), isFalse);
  });

  test('retomar libera na hora', () async {
    final s = _Armazenamento();
    await pausarSync(s, agora: agora);

    await retomarSync(s);

    expect(await syncPausado(s, agora: agora), isFalse);
  });

  test('valor corrompido ou erro de leitura contam como não pausado', () async {
    final s = _Armazenamento()..dados['sync_pausado_ate'] = 'lixo';
    expect(await syncPausado(s, agora: agora), isFalse);

    s.quebrado = true;
    expect(await syncPausado(s, agora: agora), isFalse);
  });
}
