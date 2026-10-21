import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

Transacao _t(
  String id,
  double valor,
  DateTime data, {
  String categoria = 'Mercado',
  double? minhaParte,
}) => Transacao(
  id: id,
  descricao: id,
  categoria: categoria,
  valor: valor,
  data: data,
  minhaParte: minhaParte,
);

void main() {
  test('filtra o mês, soma receitas/despesas e ordena categorias', () {
    final r = RelatorioMensal.de(
      [
        _t('a', -100, DateTime(2026, 10, 5)),
        _t('b', -300, DateTime(2026, 10, 2), categoria: 'Moradia'),
        _t('c', 1000, DateTime(2026, 10, 1), categoria: 'Renda'),
        _t('d', -50, DateTime(2026, 9, 30)),
        _t('e', -20, DateTime(2026, 10, 7), categoria: ''),
      ],
      ano: 2026,
      mes: 10,
    );

    expect(r.transacoes.map((t) => t.id), ['c', 'b', 'a', 'e']);
    expect(r.receitas, 1000);
    expect(r.despesas, 420);
    expect(r.saldo, 580);
    expect(r.despesasPorCategoria.keys, [
      'Moradia',
      'Mercado',
      RelatorioMensal.semCategoria,
    ]);
  });

  test('compra dividida conta só a parte do usuário', () {
    final r = RelatorioMensal.de(
      [_t('a', -200, DateTime(2026, 10, 5), minhaParte: 80)],
      ano: 2026,
      mes: 10,
    );
    expect(r.despesas, 80);
  });

  test('mês sem lançamentos é vazio', () {
    expect(RelatorioMensal.de([], ano: 2026, mes: 1).vazio, isTrue);
  });
}
