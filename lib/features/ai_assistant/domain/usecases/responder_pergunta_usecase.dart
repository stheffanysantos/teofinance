import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/services/construir_contexto.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/meta/domain/repositories/meta_repository.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Responde uma pergunta do usuário usando só dados que já passam pelos
/// repositories das outras features.
class ResponderPerguntaUseCase {
  ResponderPerguntaUseCase({
    required TransacaoRepository transacoes,
    required MetaRepository metas,
    required OrcamentoRepository orcamentos,
    required MotorResposta motor,
    DateTime Function() agora = DateTime.now,
  })  : _transacoes = transacoes,
        _metas = metas,
        _orcamentos = orcamentos,
        _motor = motor,
        _agora = agora;

  final TransacaoRepository _transacoes;
  final MetaRepository _metas;
  final OrcamentoRepository _orcamentos;
  final MotorResposta _motor;
  final DateTime Function() _agora;

  Future<Either<Failure, String>> call(String pergunta) async {
    final texto = pergunta.trim();
    if (texto.isEmpty) {
      return const Left(ValidationFailure('Escreva uma pergunta.'));
    }

    try {
      final contexto = construirContexto(
        transacoes: await _transacoes.observarTodas().first,
        limites: await _orcamentos.observarTodos().first,
        metas: await _metas.observarTodas().first,
        mes: _agora(),
      );
      return _motor.responder(pergunta: texto, contexto: contexto);
    } catch (_) {
      return const Left(CacheFailure('Não consegui ler seus dados agora.'));
    }
  }
}
