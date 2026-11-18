import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/services/edge_ai_motor.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';

/// Inferência no aparelho com o plugin de IA local. Só gera texto com o modelo
/// já instalado: o download é de `features/ai_model/`, e aqui não há rede.
class InferenciaLocalEdgeAi implements InferenciaLocal {
  InferenciaLocalEdgeAi({
    required Future<bool> Function() verificarInstalacao,
    required Future<String> Function(String instrucoes, String mensagem)
    executar,
  }) : _verificarInstalacao = verificarInstalacao,
       _executar = executar;

  /// Usa o plugin real; [modeloId] é o arquivo instalado pelo gerenciador.
  factory InferenciaLocalEdgeAi.plugin({required String modeloId}) {
    return InferenciaLocalEdgeAi(
      verificarInstalacao: () async {
        await garantirMotorEdgeAi();
        return FlutterEdgeAi.isModelInstalled(modeloId);
      },
      executar: _gerarComPlugin,
    );
  }

  final Future<bool> Function() _verificarInstalacao;
  final Future<String> Function(String instrucoes, String mensagem) _executar;

  @override
  Future<bool> estaPronta() async {
    try {
      return await _verificarInstalacao();
    } catch (e) {
      debugPrint(
        'InferenciaLocalEdgeAi.estaPronta falhou: ${e.runtimeType}: $e',
      );
      return false;
    }
  }

  @override
  Future<Either<Failure, String>> gerar({
    required String instrucoes,
    required String mensagem,
  }) async {
    try {
      return Right(await _executar(instrucoes, mensagem));
    } catch (e) {
      // O assistente cai para o motor por regras; o log guarda o motivo real
      // (ex.: falta de memória para carregar o modelo neste aparelho).
      debugPrint('InferenciaLocalEdgeAi.gerar falhou: ${e.runtimeType}: $e');
      return const Left(
        CacheFailure('Não consegui gerar a resposta com o modelo local.'),
      );
    }
  }
}

/// Contexto de 4096 tokens (prompt + resposta) e resposta limitada a 256: cabe o
/// resumo financeiro completo (cartões, contas, reembolsos, investimentos) sem
/// estourar a memória do aparelho. Temperatura baixa para ele ler os números do
/// resumo em vez de inventar.
Future<String> _gerarComPlugin(String instrucoes, String mensagem) async {
  await garantirMotorEdgeAi();
  // CPU de propósito: no Galaxy S24 Ultra o delegado de GPU (OpenCL) derruba o app
  // com SIGSEGV ao carregar o modelo, e um crash nativo não dá para capturar.
  final modelo = await FlutterEdgeAi.getActiveModel(
    maxTokens: 4096,
    preferredBackend: PreferredBackend.cpu,
  );
  final chat = await modelo.createChat(
    systemInstruction: instrucoes,
    maxOutputTokens: 256,
    temperature: 0.2,
    topK: 20,
    topP: 0.9,
  );
  try {
    await chat.addQueryChunk(Message.text(text: mensagem, isUser: true));
    final resposta = StringBuffer();
    await for (final parcial in chat.generateChatResponseAsync()) {
      if (parcial is TextResponse) resposta.write(parcial.token);
    }
    return resposta.toString();
  } finally {
    await chat.close();
  }
}
