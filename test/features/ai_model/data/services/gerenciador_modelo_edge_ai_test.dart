import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_model/data/services/gerenciador_modelo_edge_ai.dart';
import 'package:teofinance/features/ai_model/data/services/modelo_local_edge_ai.dart';

class _ModeloFalso implements ModeloLocalEdgeAi {
  _ModeloFalso({this.instalado = false, this.falhaAoInstalar = false});

  bool instalado;
  bool falhaAoInstalar;
  int instalacoes = 0;

  @override
  Future<bool> estaInstalado() async => instalado;

  @override
  Future<void> instalar(void Function(int percentual) aoProgredir) async {
    instalacoes++;
    if (falhaAoInstalar) throw Exception('sem rede');
    aoProgredir(40);
    aoProgredir(100);
    instalado = true;
  }

  @override
  Future<void> desinstalar() async => instalado = false;
}

Future<void> _deixarVerificar() => Future<void>.delayed(Duration.zero);

void main() {
  test('sem o modelo, começa como não instalado e informa o tamanho', () async {
    final gerenciador = GerenciadorModeloEdgeAi(_ModeloFalso());
    await _deixarVerificar();

    final estado = await gerenciador.observarEstado().first;
    expect(estado, isA<ModeloNaoInstalado>());
    expect((estado as ModeloNaoInstalado).tamanhoEmMb, kModeloLocalTamanhoEmMb);
  });

  test('com o modelo já instalado, começa como pronto', () async {
    final gerenciador = GerenciadorModeloEdgeAi(_ModeloFalso(instalado: true));
    await _deixarVerificar();

    expect(await gerenciador.observarEstado().first, isA<ModeloPronto>());
  });

  test('baixar emite o progresso e termina pronto', () async {
    final gerenciador = GerenciadorModeloEdgeAi(_ModeloFalso());
    await _deixarVerificar();
    final estados = <EstadoModelo>[];
    final sub = gerenciador.observarEstado().listen(estados.add);

    await gerenciador.baixar();
    await _deixarVerificar();
    await sub.cancel();

    final progressos = estados
        .whereType<ModeloBaixando>()
        .map((e) => e.progresso)
        .toList();
    expect(progressos, [0.0, 0.4, 1.0]);
    expect(estados.last, isA<ModeloPronto>());
  });

  test(
    'falha no download vira ModeloComErro e permite tentar de novo',
    () async {
      final modelo = _ModeloFalso(falhaAoInstalar: true);
      final gerenciador = GerenciadorModeloEdgeAi(modelo);
      await _deixarVerificar();
      final estados = <EstadoModelo>[];
      final sub = gerenciador.observarEstado().listen(estados.add);

      await gerenciador.baixar();
      await _deixarVerificar();
      expect(estados.last, isA<ModeloComErro>());

      modelo.falhaAoInstalar = false;
      await gerenciador.baixar();
      await _deixarVerificar();
      await sub.cancel();

      expect(estados.last, isA<ModeloPronto>());
      expect(modelo.instalacoes, 2);
    },
  );

  test('baixar com o modelo pronto não baixa de novo', () async {
    final modelo = _ModeloFalso(instalado: true);
    final gerenciador = GerenciadorModeloEdgeAi(modelo);
    await _deixarVerificar();

    await gerenciador.baixar();

    expect(modelo.instalacoes, 0);
  });

  test('remover desinstala e volta a oferecer o download', () async {
    final modelo = _ModeloFalso(instalado: true);
    final gerenciador = GerenciadorModeloEdgeAi(modelo);
    await _deixarVerificar();

    await gerenciador.remover();

    expect(modelo.instalado, isFalse);
    expect(await gerenciador.observarEstado().first, isA<ModeloNaoInstalado>());
  });
}
