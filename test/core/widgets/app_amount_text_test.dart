import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

class _ArmazenamentoEmMemoria implements FlutterSecureStorage {
  final dados = <String, String>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final chave = invocation.namedArguments[#key] as String;
    if (invocation.memberName == #write) {
      dados[chave] = invocation.namedArguments[#value] as String;
      return Future<void>.value();
    }
    return Future<String?>.value(dados[chave]);
  }
}

class _ModoFixo extends ModoDiscretoNotifier {
  _ModoFixo(this._valor);

  final bool _valor;

  @override
  bool build() => _valor;
}

Widget _app({required bool discreto, required Widget child}) {
  return ProviderScope(
    overrides: [modoDiscretoProvider.overrideWith(() => _ModoFixo(discreto))],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('modo desligado mostra o valor', (tester) async {
    await tester.pumpWidget(_app(discreto: false, child: const AppAmountText('R\$ 1.234,56')));

    expect(find.text('R\$ 1.234,56'), findsOneWidget);
  });

  testWidgets('modo ligado troca o valor pela máscara', (tester) async {
    await tester.pumpWidget(_app(discreto: true, child: const AppAmountText('R\$ 1.234,56')));

    expect(find.text('R\$ 1.234,56'), findsNothing);
    expect(find.text(kMascaraValor), findsOneWidget);
  });

  testWidgets('prefixo e sufixo continuam visíveis com o modo ligado', (tester) async {
    await tester.pumpWidget(
      _app(discreto: true, child: const AppAmountText('R\$ 500', prefix: 'Limite ', suffix: ' / mês')),
    );

    expect(find.text('Limite $kMascaraValor / mês'), findsOneWidget);
  });

  test('alternar liga e desliga', () async {
    final container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(_ArmazenamentoEmMemoria())],
    );
    addTearDown(container.dispose);

    expect(container.read(modoDiscretoProvider), isFalse);
    await container.read(modoDiscretoProvider.notifier).alternar();
    expect(container.read(modoDiscretoProvider), isTrue);
    await container.read(modoDiscretoProvider.notifier).alternar();
    expect(container.read(modoDiscretoProvider), isFalse);
  });

  test('a escolha sobrevive ao fechar e reabrir o app', () async {
    final armazenamento = _ArmazenamentoEmMemoria();
    final primeiro = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(armazenamento)],
    );
    await primeiro.read(modoDiscretoProvider.notifier).alternar();
    primeiro.dispose();

    final reaberto = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(armazenamento)],
    );
    addTearDown(reaberto.dispose);
    reaberto.read(modoDiscretoProvider);
    await pumpEventQueue();

    expect(reaberto.read(modoDiscretoProvider), isTrue);
  });
}
