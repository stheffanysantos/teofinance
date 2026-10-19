import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';

/// Contrato de quem gera a resposta do assistente. Toda implementação roda no
/// aparelho: nenhuma pode fazer chamada de rede (ver `.claude/rules/architecture.md`).
/// Hoje a implementação é por regras; o Gemma/MediaPipe entra atrás deste
/// mesmo contrato.
abstract class MotorResposta {
  Future<Either<Failure, String>> responder({
    required String pergunta,
    required ContextoFinanceiro contexto,
  });
}
