import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/planejamento/domain/services/a_pagar_no_proximo_mes.dart';

MesDeFaturas _mes(int ano, int mes, double total, double minhaParte) {
  const cartao = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 5000);
  return MesDeFaturas(
    ano: ano,
    mes: mes,
    faturas: [
      FaturaDoCartaoNoMes(
        cartao: cartao,
        total: total,
        minhaParte: minhaParte,
        vencimento: DateTime(ano, mes, 5),
        vencida: false,
      ),
    ],
  );
}

void main() {
  test('soma só a minha parte dos cartões do mês seguinte', () {
    final r = calcularAPagarNoProximoMes(
      hoje: DateTime(2026, 11, 25),
      faturas: [_mes(2026, 11, 900, 900), _mes(2026, 12, 1000, 600), _mes(2027, 1, 500, 500)],
      contas: const [],
    );
    expect(r.mes, 12);
    expect(r.cartoes, 600);
    expect(r.total, 600);
  });

  test('virada de ano: em dezembro o mês seguinte é janeiro', () {
    final r = calcularAPagarNoProximoMes(
      hoje: DateTime(2026, 12, 10),
      faturas: [_mes(2027, 1, 500, 500)],
      contas: const [],
    );
    expect((r.ano, r.mes), (2027, 1));
    expect(r.cartoes, 500);
  });

  test('soma contas em aberto do mês seguinte, inclusive as que se repetem', () {
    final r = calcularAPagarNoProximoMes(
      hoje: DateTime(2026, 11, 25),
      faturas: const [],
      contas: [
        ContaAPagar(id: 'a', descricao: 'Aluguel', valor: 1500, vencimento: DateTime(2026, 11, 10), diaBase: 10, recorrencia: RecorrenciaConta.mensal),
        ContaAPagar(id: 'b', descricao: 'Luz', valor: 200, vencimento: DateTime(2026, 12, 12), diaBase: 12),
        ContaAPagar(id: 'c', descricao: 'Paga', valor: 999, vencimento: DateTime(2026, 12, 3), diaBase: 3, paga: true),
        ContaAPagar(id: 'd', descricao: 'Outro mês', valor: 80, vencimento: DateTime(2027, 2, 3), diaBase: 3),
      ],
    );
    expect(r.contas, 1700);
    expect(r.total, 1700);
  });
}
