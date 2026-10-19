import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/reconciliation/domain/entities/extrato_linha.dart';
import 'package:teofinance/features/reconciliation/domain/entities/reconciliation_match.dart';
import 'package:teofinance/features/reconciliation/presentation/notifiers/reconciliation_notifier.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

Transacao _t(String id, double valor, {double? minhaParte}) => Transacao(
      id: id,
      descricao: id,
      categoria: 'c',
      valor: valor,
      data: DateTime(2026, 10, 10),
      minhaParte: minhaParte,
    );

ExtratoLinha _l(String id, double valor, {String tipo = 'D'}) => ExtratoLinha(
      id: id,
      importId: 'imp',
      descricao: id,
      valor: valor,
      data: DateTime(2026, 10, 10),
      tipo: tipo,
      nomeBancoOriginal: id,
    );

ReconciliationMatch _m(String linhaId, String? transacaoId, String status) => ReconciliationMatch(
      id: 'm-$linhaId',
      transacaoId: transacaoId,
      linhaExtratoId: linhaId,
      dataReconciliacao: DateTime(2026, 10, 10),
      status: status,
      confidence: 1,
    );

void main() {
  test('totais comparam o registrado com o extrato e apontam a diferença', () {
    final state = ReconciliationState(
      transacoes: {'t1': _t('t1', -50), 't2': _t('t2', -30)},
      linhas: {'l1': _l('l1', 50), 'l2': _l('l2', 45)},
    );

    expect(state.totalRegistrado, -80);
    expect(state.totalBanco, -95);
    expect(state.diferenca, -15);
  });

  test('gasto real conta só a parte do usuário e ignora receitas', () {
    final state = ReconciliationState(
      transacoes: {
        't1': _t('t1', -100, minhaParte: 40),
        't2': _t('t2', -20),
        't3': _t('t3', 500),
      },
    );

    expect(state.gastoReal, 60);
  });

  test('transação sem candidata no extrato aparece como fora do extrato', () {
    final state = ReconciliationState(
      transacoes: {'t1': _t('t1', -50), 't2': _t('t2', -30)},
      linhas: {'l1': _l('l1', 50)},
      matches: [_m('l1', 't1', 'auto_matched')],
    );

    expect(state.transacoesSemExtrato.map((t) => t.id), ['t2']);
  });

  test('candidata ainda não aprovada não conta como fora do extrato', () {
    final state = ReconciliationState(
      transacoes: {'t1': _t('t1', -50)},
      linhas: {'l1': _l('l1', 52)},
      matches: [_m('l1', 't1', 'unmatched')],
    );

    expect(state.transacoesSemExtrato, isEmpty);
  });
}
