import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

Transacao _t({double valor = -100, double? minhaParte, bool parcela = false, double? valorParcela}) => Transacao(
      id: 't',
      descricao: 'x',
      categoria: 'c',
      valor: valor,
      data: DateTime(2026, 10, 10),
      minhaParte: minhaParte,
      ehParcela: parcela,
      valorParcela: valorParcela,
    );

void main() {
  test('sem divisão, contabilizado e cobrado são o valor da transação', () {
    final t = _t();
    expect(t.ehDividida, isFalse);
    expect(t.valorCobrado, -100);
    expect(t.valorContabilizado, -100);
  });

  test('despesa dividida conta só a parte do usuário, com sinal negativo', () {
    final t = _t(minhaParte: 33.33);
    expect(t.ehDividida, isTrue);
    expect(t.valorCobrado, -100);
    expect(t.valorContabilizado, -33.33);
  });

  test('receita dividida mantém sinal positivo', () {
    expect(_t(valor: 100, minhaParte: 40).valorContabilizado, 40);
  });

  test('parcela usa o valor da parcela como cobrado', () {
    final t = _t(valor: -300, parcela: true, valorParcela: -100);
    expect(t.valorCobrado, -100);
    expect(t.valorContabilizado, -100);
  });

  test('parcela dividida conta a parte sobre a parcela', () {
    final t = _t(valor: -300, parcela: true, valorParcela: -100, minhaParte: 50);
    expect(t.valorCobrado, -100);
    expect(t.valorContabilizado, -50);
  });
}
