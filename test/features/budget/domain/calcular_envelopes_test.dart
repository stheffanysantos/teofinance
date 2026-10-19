import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/services/calcular_envelopes.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

final _mes = DateTime(2026, 10, 15);

Transacao _t(
  double valor, {
  String categoria = 'Mercado',
  DateTime? data,
  double? minhaParte,
}) =>
    Transacao(
      id: '${valor}_${categoria}_${data ?? _mes}',
      descricao: 'x',
      categoria: categoria,
      valor: valor,
      data: data ?? DateTime(2026, 10, 5),
      minhaParte: minhaParte,
    );

const _mercado = Orcamento(id: 'o1', categoria: 'Mercado', limite: 500);
const _lazer = Orcamento(id: 'o2', categoria: 'Lazer', limite: 200);

void main() {
  test('soma as despesas da categoria no mês', () {
    final r = calcularEnvelopes(
      limites: [_mercado],
      transacoes: [_t(-100), _t(-50.5)],
      mes: _mes,
    );

    expect(r.envelopes.single.gasto, 150.5);
    expect(r.envelopes.single.restante, 349.5);
  });

  test('ignora receitas, outros meses e categorias sem limite', () {
    final r = calcularEnvelopes(
      limites: [_mercado],
      transacoes: [
        _t(300),
        _t(-80, data: DateTime(2026, 9, 30)),
        _t(-80, data: DateTime(2026, 11, 1)),
        _t(-80, categoria: 'Lazer'),
      ],
      mes: _mes,
    );

    expect(r.envelopes.single.gasto, 0);
  });

  test('compra dividida conta só a parte do usuário', () {
    final r = calcularEnvelopes(
      limites: [_mercado],
      transacoes: [_t(-120, minhaParte: 40)],
      mes: _mes,
    );

    expect(r.envelopes.single.gasto, 40);
  });

  test('limite sem gasto aparece com gasto zero e a lista sai por categoria', () {
    final r = calcularEnvelopes(limites: [_mercado, _lazer], transacoes: const [], mes: _mes);

    expect(r.envelopes.map((e) => e.categoria), ['Lazer', 'Mercado']);
    expect(r.envelopes.every((e) => e.gasto == 0), isTrue);
  });

  test('totais somam os envelopes e detectam estouro', () {
    final r = calcularEnvelopes(
      limites: [_mercado, _lazer],
      transacoes: [_t(-600), _t(-50, categoria: 'Lazer')],
      mes: _mes,
    );

    expect(r.totalLimite, 700);
    expect(r.totalGasto, 650);
    expect(r.totalRestante, 50);
    expect(r.envelopes.firstWhere((e) => e.categoria == 'Mercado').estourado, isTrue);
    expect(r.envelopes.firstWhere((e) => e.categoria == 'Lazer').estourado, isFalse);
  });

  test('sem limites a proporção total é zero, sem dividir por zero', () {
    final r = calcularEnvelopes(limites: const [], transacoes: [_t(-10)], mes: _mes);

    expect(r.proporcao, 0);
  });
}
