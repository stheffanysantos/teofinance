import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';
import 'package:teofinance/features/ai_assistant/domain/services/montar_prompt.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';

/// Responde com o modelo local e, se ele não estiver instalado, falhar, demorar
/// demais ou devolver texto vazio, cai no [fallback] por regras. O usuário
/// sempre recebe uma resposta — a IA melhora a conversa, nunca a condiciona.
class MotorRespostaGemma implements MotorResposta {
  const MotorRespostaGemma({
    required InferenciaLocal inferencia,
    required MotorResposta fallback,
    this.limiteDeTempo = const Duration(seconds: 60),
  })  : _inferencia = inferencia,
        _fallback = fallback;

  final InferenciaLocal _inferencia;
  final MotorResposta _fallback;
  final Duration limiteDeTempo;

  @override
  Future<Either<Failure, String>> responder({
    required String pergunta,
    required ContextoFinanceiro contexto,
  }) async {
    try {
      if (!await _inferencia.estaPronta()) return _porRegras(pergunta, contexto);

      final prompt = montarPrompt(pergunta: pergunta, contexto: contexto);
      final resultado = await _inferencia
          .gerar(instrucoes: prompt.instrucoes, mensagem: prompt.mensagem)
          .timeout(limiteDeTempo);

      final texto = resultado.fold((_) => null, (t) => t.trim());
      if (texto == null || texto.isEmpty) return _porRegras(pergunta, contexto);
      return Right(texto);
    } catch (_) {
      return _porRegras(pergunta, contexto);
    }
  }

  Future<Either<Failure, String>> _porRegras(String pergunta, ContextoFinanceiro contexto) {
    return _fallback.responder(pergunta: pergunta, contexto: contexto);
  }
}
