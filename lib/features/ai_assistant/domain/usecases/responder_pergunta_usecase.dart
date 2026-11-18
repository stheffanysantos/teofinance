import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/services/construir_contexto.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/cartao/domain/repositories/cartao_repository.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/investimento/domain/repositories/investimento_repository.dart';
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
    CartaoRepository? cartoes,
    ContaRepository? contas,
    InvestimentoRepository? investimentos,
    DateTime Function() agora = DateTime.now,
  })  : _cartoes = cartoes,
        _contas = contas,
        _investimentos = investimentos,
        _transacoes = transacoes,
        _metas = metas,
        _orcamentos = orcamentos,
        _motor = motor,
        _agora = agora;

  final TransacaoRepository _transacoes;
  final MetaRepository _metas;
  final OrcamentoRepository _orcamentos;
  final MotorResposta _motor;
  final CartaoRepository? _cartoes;
  final ContaRepository? _contas;
  final InvestimentoRepository? _investimentos;
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
        cartoes: await _opcional(() async => (await _cartoes?.listarCartoes())?.getOrElse((_) => const []) ?? const []),
        pagamentos: await _opcional(() async => (await _cartoes?.listarPagamentos())?.getOrElse((_) => const []) ?? const []),
        contas: await _opcional(() async => await _contas?.observarTodas().first ?? const []),
        investimentos: await _opcional(() async => (await _investimentos?.listar())?.getOrElse((_) => const []) ?? const []),
      );
      return await _motor.responder(pergunta: texto, contexto: contexto);
    } catch (_) {
      return const Left(CacheFailure('Não consegui ler seus dados agora.'));
    }
  }

  /// Cartões, contas e investimentos só enriquecem a resposta: se uma dessas
  /// fontes falhar, o assistente segue sem esse assunto em vez de falhar tudo.
  Future<List<T>> _opcional<T>(Future<List<T>> Function() ler) async {
    try {
      return await ler();
    } catch (_) {
      return const [];
    }
  }
}
