import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/reconciliation/data/services/transacao_matcher_service.dart';
import 'package:teofinance/features/reconciliation/domain/entities/extrato_linha.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

Transacao _txn(String id, double valor, DateTime data) =>
    Transacao(id: id, descricao: 'x', categoria: '', valor: valor, data: data);

ExtratoLinha _linha(String id, double valor, String tipo, DateTime data) => ExtratoLinha(
      id: id,
      importId: 'imp',
      descricao: 'y',
      valor: valor,
      data: data,
      tipo: tipo,
      nomeBancoOriginal: 'y',
    );

void main() {
  final service = TransacaoMatcherService();
  final dia = DateTime(2026, 10, 10);

  test('valor exato no mesmo dia tem confiança 1.0', () {
    final r = service.encontrarMatches(
      transacoes: [_txn('t1', -50, dia)],
      linhasExtrato: [_linha('l1', 50, 'D', dia)],
    );
    expect(r, hasLength(1));
    expect(r.first.$3, 1.0);
  });

  test('valor exato com 2 dias de diferença ainda passa do corte', () {
    final r = service.encontrarMatches(
      transacoes: [_txn('t1', -50, dia)],
      linhasExtrato: [_linha('l1', 50, 'D', dia.add(const Duration(days: 2)))],
    );
    expect(r, hasLength(1));
    expect(r.first.$3, closeTo(0.9, 1e-9));
  });

  test('valor muito diferente não gera match', () {
    final r = service.encontrarMatches(
      transacoes: [_txn('t1', -50, dia)],
      linhasExtrato: [_linha('l1', 80, 'D', dia)],
    );
    expect(r, isEmpty);
  });

  test('sinal oposto (crédito x despesa) não gera match', () {
    final r = service.encontrarMatches(
      transacoes: [_txn('t1', -50, dia)],
      linhasExtrato: [_linha('l1', 50, 'C', dia)],
    );
    expect(r, isEmpty);
  });

  test('valor zero não quebra o cálculo', () {
    final r = service.encontrarMatches(
      transacoes: [_txn('t1', 0, dia)],
      linhasExtrato: [_linha('l1', 10, 'C', dia)],
    );
    expect(r, isEmpty);
  });

  test('compra dividida casa pelo total cobrado, não pela parte do usuário', () {
    final dividida = Transacao(
      id: 't1',
      descricao: 'Pizza',
      categoria: '',
      valor: -100,
      data: dia,
      minhaParte: 33.33,
    );

    final r = service.encontrarMatches(
      transacoes: [dividida],
      linhasExtrato: [_linha('l1', 100, 'D', dia)],
    );

    expect(r, hasLength(1));
    expect(r.first.$3, 1.0);
  });
}
