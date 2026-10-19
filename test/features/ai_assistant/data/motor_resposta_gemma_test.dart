import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_gemma.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';

class _FakeInferencia implements InferenciaLocal {
  bool pronta = true;
  Future<Either<Failure, String>> Function() resposta = () async => const Right('Resposta do modelo.');
  int geracoes = 0;
  String? instrucoesRecebidas;
  String? mensagemRecebida;

  @override
  Future<bool> estaPronta() async => pronta;

  @override
  Future<Either<Failure, String>> gerar({required String instrucoes, required String mensagem}) {
    geracoes++;
    instrucoesRecebidas = instrucoes;
    mensagemRecebida = mensagem;
    return resposta();
  }
}

class _FakeRegras implements MotorResposta {
  int chamadas = 0;

  @override
  Future<Either<Failure, String>> responder({
    required String pergunta,
    required ContextoFinanceiro contexto,
  }) async {
    chamadas++;
    return const Right('Resposta por regras.');
  }
}

final _contexto = ContextoFinanceiro(
  mes: DateTime(2026, 10, 15),
  receitas: 5000,
  despesas: 1500,
  gastoPorCategoria: const {'Mercado': 800},
  envelopes: const [],
  metas: const [],
);

void main() {
  late _FakeInferencia inferencia;
  late _FakeRegras regras;

  MotorRespostaGemma criar({Duration limite = const Duration(seconds: 5)}) =>
      MotorRespostaGemma(inferencia: inferencia, fallback: regras, limiteDeTempo: limite);

  Future<String> responder(MotorRespostaGemma motor) async {
    final r = await motor.responder(pergunta: 'Resumo do mês', contexto: _contexto);
    return r.getOrElse((_) => throw StateError('esperava Right'));
  }

  setUp(() {
    inferencia = _FakeInferencia();
    regras = _FakeRegras();
  });

  test('com o modelo pronto responde com ele e não consulta as regras', () async {
    expect(await responder(criar()), 'Resposta do modelo.');
    expect(regras.chamadas, 0);
  });

  test('entrega ao modelo o prompt montado a partir do resumo', () async {
    await responder(criar());

    expect(inferencia.mensagemRecebida, contains('Receitas: R\$ 5.000,00'));
    expect(inferencia.mensagemRecebida, endsWith('Pergunta do usuário: Resumo do mês'));
    expect(inferencia.instrucoesRecebidas, contains('português do Brasil'));
  });

  test('modelo não instalado cai nas regras sem tentar gerar', () async {
    inferencia.pronta = false;

    expect(await responder(criar()), 'Resposta por regras.');
    expect(inferencia.geracoes, 0);
  });

  test('falha do modelo cai nas regras', () async {
    inferencia.resposta = () async => const Left(CacheFailure('falhou'));

    expect(await responder(criar()), 'Resposta por regras.');
    expect(inferencia.geracoes, 1);
  });

  test('exceção inesperada do modelo cai nas regras', () async {
    inferencia.resposta = () async => throw StateError('crash nativo');

    expect(await responder(criar()), 'Resposta por regras.');
  });

  test('resposta vazia ou só espaços cai nas regras', () async {
    inferencia.resposta = () async => const Right('   \n ');

    expect(await responder(criar()), 'Resposta por regras.');
  });

  test('modelo lento demais cai nas regras depois do limite de tempo', () async {
    inferencia.resposta = () => Completer<Either<Failure, String>>().future;

    final texto = await responder(criar(limite: const Duration(milliseconds: 50)));

    expect(texto, 'Resposta por regras.');
  });

  test('a resposta do modelo é aparada', () async {
    inferencia.resposta = () async => const Right('  Gastou R\$ 800.  \n');

    expect(await responder(criar()), 'Gastou R\$ 800.');
  });
}
