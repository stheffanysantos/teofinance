import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/relatorio/domain/services/gastos_por_categoria.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

void main() {
  test('ranking do mês: soma por categoria, usa a parte dividida e ignora receita e outros meses', () {
    Transacao t(String cat, double v, DateTime d, {double? parte}) =>
        Transacao(id: '$cat$v$d', descricao: 'x', categoria: cat, valor: v, data: d, minhaParte: parte);
    final r = gastosPorCategoriaDoMes([
      t('Mercado', -100, DateTime(2026, 11, 2)),
      t('Mercado', -50, DateTime(2026, 11, 3)),
      t('Contas', -300, DateTime(2026, 11, 4), parte: 150),
      t('', -20, DateTime(2026, 11, 5)),
      t('Salário', 5000, DateTime(2026, 11, 5)),
      t('Mercado', -999, DateTime(2026, 10, 5)),
    ], DateTime(2026, 11, 10));

    expect(r.map((g) => g.categoria), ['Mercado', 'Contas', 'Sem categoria']);
    expect(r.first.valor, 150);
    expect(r[1].valor, 150);
    // Mercado: 150 neste mês contra 999 no anterior
    expect(r.first.valorAnterior, 999);
    expect(r.first.variacaoPercent!.round(), -85);
    expect(r[1].variacaoPercent, isNull);
  });
}
