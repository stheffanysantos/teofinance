import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

// Fecha dia 25, vence dia 5: compra de 10/11 entra na fatura que vence 05/12.
const _nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 4500);
// Fecha dia 10, vence dia 17: compra de 12/11 entra na fatura que vence 17/12.
const _inter = Cartao(id: 'in', nome: 'Inter', diaFechamento: 10, diaVencimento: 17);

final _hoje = DateTime(2026, 11, 12);

Transacao _compra(
  String id,
  double valor,
  DateTime data,
  String cartao, {
  double? minhaParte,
  List<String> com = const [],
  bool parcela = false,
}) =>
    Transacao(
      id: id,
      descricao: id,
      categoria: '',
      valor: valor,
      data: data,
      cartaoId: cartao,
      minhaParte: minhaParte,
      divididoCom: com,
      ehParcela: parcela,
      valorParcela: parcela ? valor : null,
    );

void main() {
  test('sem cartão ou sem compras não há o que projetar', () {
    expect(projetarFaturasPorMes(cartoes: const [], transacoes: const [], pagamentos: const [], hoje: _hoje), isEmpty);
    expect(projetarFaturasPorMes(cartoes: const [_nubank], transacoes: const [], pagamentos: const [], hoje: _hoje), isEmpty);
  });

  test('agrupa por mês de vencimento, soma os cartões e ordena do mais próximo ao mais distante', () {
    final meses = projetarFaturasPorMes(
      cartoes: const [_nubank, _inter],
      pagamentos: const [],
      hoje: _hoje,
      transacoes: [
        _compra('mercado', -100, DateTime(2026, 11, 10), 'nu'), // vence 05/12
        _compra('cinema', -60, DateTime(2026, 11, 12), 'in'), // vence 17/12
        // Duas parcelas futuras do mesmo parcelamento.
        _compra('tv-1', -250, DateTime(2026, 12, 10), 'nu', parcela: true), // vence 05/01
        _compra('tv-2', -250, DateTime(2027, 1, 10), 'nu', parcela: true), // vence 05/02
      ],
    );

    expect(meses.map((m) => (m.ano, m.mes)), [(2026, 12), (2027, 1), (2027, 2)]);
    expect(meses[0].total, 160);
    expect(meses[0].faturas.map((f) => f.cartao.nome), ['Nubank', 'Inter'], reason: 'o que vence primeiro vem antes');
    expect(meses[1].total, 250);
    expect(meses[2].total, 250);
  });

  test('fatura já paga não entra', () {
    final meses = projetarFaturasPorMes(
      cartoes: const [_nubank],
      hoje: _hoje,
      transacoes: [
        _compra('velha', -300, DateTime(2026, 10, 10), 'nu'), // vence 05/11
        _compra('nova', -80, DateTime(2026, 11, 10), 'nu'), // vence 05/12
      ],
      pagamentos: [FaturaPaga(cartaoId: 'nu', ano: 2026, mes: 11, valor: 300, dataPagamento: DateTime(2026, 11, 5))],
    );

    expect(meses.single.mes, 12);
    expect(meses.single.total, 80);
  });

  test('compra dividida: o banco cobra tudo, e "sua parte" é só a do usuário', () {
    final meses = projetarFaturasPorMes(
      cartoes: const [_nubank],
      pagamentos: const [],
      hoje: _hoje,
      transacoes: [
        _compra('presente', -156, DateTime(2026, 11, 10), 'nu', minhaParte: 78, com: const ['Mãe']),
        _compra('mercado', -44, DateTime(2026, 11, 11), 'nu'),
      ],
    );

    final mes = meses.single;
    expect(mes.total, 200);
    expect(mes.minhaParte, 122); // 78 + 44
    expect(mes.temDivisao, isTrue);
    expect(mes.faturas.single.minhaParte, 122);
  });

  test('sem divisão, a parte do usuário é o total', () {
    final mes = projetarFaturasPorMes(
      cartoes: const [_nubank],
      pagamentos: const [],
      hoje: _hoje,
      transacoes: [_compra('a', -50, DateTime(2026, 11, 10), 'nu')],
    ).single;

    expect(mes.minhaParte, mes.total);
    expect(mes.temDivisao, isFalse);
  });

  test('fatura não paga com vencimento no passado é marcada como vencida', () {
    final meses = projetarFaturasPorMes(
      cartoes: const [_nubank],
      pagamentos: const [],
      hoje: _hoje,
      transacoes: [
        _compra('velha', -300, DateTime(2026, 10, 10), 'nu'), // vence 05/11, já passou
        _compra('nova', -80, DateTime(2026, 11, 10), 'nu'), // vence 05/12
      ],
    );

    expect(meses.first.mes, 11);
    expect(meses.first.vencida, isTrue);
    expect(meses.last.vencida, isFalse);
  });

  test('compras sem cartão ou de outro cartão não entram na fatura', () {
    final meses = projetarFaturasPorMes(
      cartoes: const [_nubank],
      pagamentos: const [],
      hoje: _hoje,
      transacoes: [
        _compra('no-nubank', -100, DateTime(2026, 11, 10), 'nu'),
        _compra('no-inter', -999, DateTime(2026, 11, 10), 'in'),
        Transacao(id: 'sem', descricao: 'sem', categoria: '', valor: -777, data: DateTime(2026, 11, 10)),
      ],
    );

    expect(meses.single.total, 100);
  });
}
