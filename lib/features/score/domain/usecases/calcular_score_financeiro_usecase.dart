import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/budget/domain/services/calcular_envelopes.dart';
import 'package:teofinance/features/meta/domain/repositories/meta_repository.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';
import 'package:teofinance/features/score/domain/services/calcular_score.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Reúne os dados do mês corrente (já no aparelho) e calcula o score.
class CalcularScoreFinanceiroUseCase {
  CalcularScoreFinanceiroUseCase({
    required TransacaoRepository transacoes,
    required OrcamentoRepository orcamentos,
    required MetaRepository metas,
    required ReconciliationRepository reconciliacao,
    DateTime Function() agora = DateTime.now,
  })  : _transacoes = transacoes,
        _orcamentos = orcamentos,
        _metas = metas,
        _reconciliacao = reconciliacao,
        _agora = agora;

  final TransacaoRepository _transacoes;
  final OrcamentoRepository _orcamentos;
  final MetaRepository _metas;
  final ReconciliationRepository _reconciliacao;
  final DateTime Function() _agora;

  Future<Either<Failure, ScoreFinanceiro>> call() async {
    final hoje = _agora();
    final inicio = DateTime(hoje.year, hoje.month);
    final fim = DateTime(hoje.year, hoje.month + 1).subtract(const Duration(milliseconds: 1));

    try {
      final transacoes = await _transacoes.observarTodas().first;
      final limites = await _orcamentos.observarTodos().first;
      final metas = await _metas.observarTodas().first;

      var receitas = 0.0;
      var despesas = 0.0;
      for (final t in transacoes) {
        if (t.data.year != hoje.year || t.data.month != hoje.month) continue;
        final valor = t.valorContabilizado;
        if (valor > 0) {
          receitas += valor;
        } else {
          despesas -= valor;
        }
      }

      // Sem leitura da reconciliação, o componente apenas fica sem dado.
      final status = await _reconciliacao.obterStatusPeriodo(userId: '', dataInicio: inicio, dataFim: fim);
      final (linhas, conferidas) = status.fold((_) => (null, null), (s) => (s.totalLinhasExtrato, s.matched));

      return Right(calcularScore(
        receitas: receitas,
        despesas: despesas,
        orcamento: calcularEnvelopes(limites: limites, transacoes: transacoes, mes: hoje),
        metas: metas,
        linhasExtrato: linhas,
        linhasConferidas: conferidas,
      ));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível calcular o score agora.'));
    }
  }
}
