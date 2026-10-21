import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/data/services/inferencia_local_edge_ai.dart';

void main() {
  test('pronta quando o modelo está instalado', () async {
    final inferencia = InferenciaLocalEdgeAi(
      verificarInstalacao: () async => true,
      executar: (_, _) async => '',
    );

    expect(await inferencia.estaPronta(), isTrue);
  });

  test(
    'erro ao verificar a instalação conta como não pronta, nunca como exceção',
    () async {
      final inferencia = InferenciaLocalEdgeAi(
        verificarInstalacao: () async =>
            throw StateError('plugin indisponível'),
        executar: (_, _) async => '',
      );

      expect(await inferencia.estaPronta(), isFalse);
    },
  );

  test(
    'gerar devolve o texto do modelo e repassa instruções e mensagem',
    () async {
      String? instrucoesRecebidas;
      String? mensagemRecebida;
      final inferencia = InferenciaLocalEdgeAi(
        verificarInstalacao: () async => true,
        executar: (instrucoes, mensagem) async {
          instrucoesRecebidas = instrucoes;
          mensagemRecebida = mensagem;
          return 'Você gastou R\$ 120 em mercado.';
        },
      );

      final resultado = await inferencia.gerar(
        instrucoes: 'seja breve',
        mensagem: 'quanto gastei?',
      );

      expect(resultado.getOrElse((_) => ''), 'Você gastou R\$ 120 em mercado.');
      expect(instrucoesRecebidas, 'seja breve');
      expect(mensagemRecebida, 'quanto gastei?');
    },
  );

  test(
    'falha do motor vira Left(CacheFailure) para o assistente cair nas regras',
    () async {
      final inferencia = InferenciaLocalEdgeAi(
        verificarInstalacao: () async => true,
        executar: (_, _) async => throw StateError('sem memória'),
      );

      final resultado = await inferencia.gerar(instrucoes: 'x', mensagem: 'y');

      expect(resultado.isLeft(), isTrue);
      expect(
        resultado.swap().getOrElse((_) => const ValidationFailure('')),
        isA<CacheFailure>(),
      );
    },
  );
}
