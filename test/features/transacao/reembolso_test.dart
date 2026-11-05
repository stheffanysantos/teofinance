import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

Transacao _t({required double minhaParte, required List<String> com}) => Transacao(
  id: '1',
  descricao: 'Conta de luz',
  categoria: 'Moradia',
  valor: -300,
  data: DateTime(2026, 11, 5),
  minhaParte: minhaParte,
  divididoCom: com,
);

void main() {
  test('o saldo e o que falta receber contam só a parte do usuário', () {
    final t = _t(minhaParte: 150, com: const ['Mãe']);
    expect(t.valorNoSaldo, -150);
    expect(t.parteDeCadaPessoa, 150);
    expect(t.aReceber, 150);
  });

  test('marcar como pago zera o que falta e mantém o nome limpo', () {
    final base = _t(minhaParte: 150, com: const ['Mãe']);
    final paga = _t(minhaParte: 150, com: base.divisaoComReembolso('Mãe', pago: true));

    expect(paga.aReceber, 0);
    expect(paga.pessoasPendentes, isEmpty);
    expect(paga.pessoasDaDivisao, ['Mãe']);
    expect(paga.divisaoComReembolso('Mãe', pago: false), ['Mãe']);
  });

  test('duas pessoas: cada uma deve metade do que não é do usuário', () {
    final t = _t(minhaParte: 100, com: const ['Ana', 'Bia']);
    expect(t.parteDeCadaPessoa, 100);

    final t2 = _t(minhaParte: 100, com: t.divisaoComReembolso('Ana', pago: true));
    expect(t2.aReceber, 100);
    expect(t2.pessoasPendentes, ['Bia']);
    expect(t2.preservandoReembolsos(['Ana', 'Carla']), ['✓ Ana', 'Carla']);
  });
}
