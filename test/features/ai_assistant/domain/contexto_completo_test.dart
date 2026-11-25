import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/construir_contexto.dart';
import 'package:teofinance/features/ai_assistant/domain/services/montar_prompt.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

final _hoje = DateTime(2026, 11, 12);

Transacao _t(String id, double valor, DateTime data,
        {String categoria = 'Mercado', String? cartao, double? minhaParte, List<String> com = const [], bool parcela = false}) =>
    Transacao(
      id: id,
      descricao: id,
      categoria: categoria,
      valor: valor,
      data: data,
      cartaoId: cartao,
      minhaParte: minhaParte,
      divididoCom: com,
      ehParcela: parcela,
      valorParcela: parcela ? valor : null,
    );

ContextoFinanceiro _contexto() {
  const nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 4500);
  return construirContexto(
    mes: _hoje,
    limites: const [],
    metas: const [],
    cartoes: const [nubank],
    pagamentos: const [],
    transacoes: [
      _t('salario', 5000, DateTime(2026, 11, 5), categoria: 'Renda'),
      _t('mercado', -400, DateTime(2026, 11, 6)),
      _t('mercado-out', -300, DateTime(2026, 10, 6)),
      _t('salario-out', 4800, DateTime(2026, 10, 5), categoria: 'Renda'),
      // Compra no cartão dividida com a mãe: o banco cobra 156, 78 são dela.
      _t('presente', -156, DateTime(2026, 11, 10), categoria: 'Lazer', cartao: 'nu', minhaParte: 78, com: const ['Mãe']),
      // Parcela futura.
      _t('parcela', -50, DateTime(2026, 12, 5), cartao: 'nu', parcela: true),
    ],
    contas: [
      ContaAPagar(id: 'a', descricao: 'Aluguel', valor: 1450, vencimento: DateTime(2026, 11, 20), diaBase: 20),
      ContaAPagar(id: 'b', descricao: 'Internet', valor: 99.9, vencimento: DateTime(2026, 11, 8), diaBase: 8),
      ContaAPagar(id: 'c', descricao: 'Luz', valor: 140, vencimento: DateTime(2026, 10, 10), diaBase: 10, paga: true),
    ],
    investimentos: [
      Investimento(
        id: 'i1',
        nome: 'Tesouro',
        tipo: TipoInvestimento.tesouroDireto,
        valorInvestido: 1000,
        valorAtual: 1100,
        dataAplicacao: DateTime(2026, 1, 1),
      ),
    ],
  );
}

void main() {
  test('o contexto reúne histórico, cartões, reembolsos, contas, investimentos e parcelas', () {
    final c = _contexto();

    expect(c.historico.single.despesas, 300);
    expect(c.historico.single.receitas, 4800);
    expect(c.reembolsos, {'Mãe': 78});
    expect(c.cartoes.single.nome, 'Nubank');
    expect(c.cartoes.single.faturaAberta, greaterThan(150), reason: 'o banco cobra os 156, não só a parte do usuário');
    expect(c.contasAPagar.map((x) => x.descricao), ['Internet', 'Aluguel'], reason: 'só abertas, a mais próxima primeiro');
    expect(c.totalInvestimentosAtual, 1100);
    expect(c.faturasPorMes.map((m) => m.mes), [12, 1], reason: 'dezembro e janeiro, por mês de vencimento');
    expect(c.parcelasFuturas, 1);
    expect(c.valorParcelasFuturas, 50);
  });

  test('o prompt traz as seções novas e as instruções trazem exemplos', () {
    final p = montarPrompt(pergunta: 'Quanto minha mãe me deve?', contexto: _contexto());

    expect(p.mensagem, contains('Hoje é 12/11/2026'));
    expect(p.mensagem, contains('Meses anteriores'));
    expect(p.mensagem, contains('Cartões (fatura em aberto)'));
    expect(p.mensagem, contains('Nubank'));
    expect(p.mensagem, contains('Reembolsos a receber'));
    expect(p.mensagem, contains('Mãe: R\$ 78,00'));
    expect(p.mensagem, contains('Contas a pagar em aberto'));
    expect(p.mensagem, contains('Internet'));
    expect(p.mensagem, contains('Investimentos: aplicado'));
    expect(p.mensagem, contains('Faturas por mês de vencimento'));
    expect(p.mensagem, contains('dezembro de 2026'));
    expect(p.mensagem, contains('janeiro de 2027'));
    expect(p.mensagem, contains('Parcelas futuras'));
    expect(p.instrucoes, contains('Exemplos'));
    expect(p.instrucoes, contains('exatamente como estão'));
  });

  test('o prompt não vaza descrição de transação individual', () {
    final p = montarPrompt(pergunta: 'oi', contexto: _contexto());
    expect(p.mensagem, isNot(contains('presente')));
    expect(p.mensagem, isNot(contains('salario')));
  });

  test('sem dados extras o prompt fica como antes, sem seções vazias', () {
    final p = montarPrompt(
      pergunta: 'oi',
      contexto: ContextoFinanceiro(
        mes: _hoje,
        receitas: 1,
        despesas: 1,
        gastoPorCategoria: const {},
        envelopes: const [],
        metas: const [],
      ),
    );
    expect(p.mensagem, isNot(contains('Cartões')));
    expect(p.mensagem, isNot(contains('Reembolsos')));
    expect(p.mensagem, isNot(contains('Investimentos')));
  });

  group('respostas por regras', () {
    const motor = MotorRespostaPorRegras();
    Future<String> perguntar(String q) async =>
        (await motor.responder(pergunta: q, contexto: _contexto())).getOrElse((_) => throw StateError('Left'));

    test('reembolsos, por pessoa e no total', () async {
      expect(await perguntar('Quanto minha mãe me deve?'), contains('R\$ 78,00'));
      expect(await perguntar('tenho algo a receber?'), contains('Mãe'));
    });

    test('fatura do cartão', () async {
      final r = await perguntar('Quanto está a fatura do Nubank?');
      expect(r, contains('Nubank'));
      expect(r, contains('fatura em aberto'));
    });

    test('faturas por mês e de um mês específico', () async {
      final geral = await perguntar('Como ficam as faturas dos próximos meses?');
      expect(geral, contains('dezembro'));
      expect(geral, contains('janeiro'));
      expect(await perguntar('Quanto vence de fatura em janeiro?'), contains('janeiro de 2027'));
    });

    test('investimentos', () async {
      final r = await perguntar('Como estão meus investimentos?');
      expect(r, contains('R\$ 1.000,00'));
      expect(r, contains('R\$ 1.100,00'));
    });

    test('contas a pagar, com a mais próxima primeiro', () async {
      final r = await perguntar('Quais contas vencem?');
      expect(r, contains('2 contas'));
      expect(r.indexOf('Internet'), lessThan(r.indexOf('Aluguel')));
    });

    test('parcelas futuras', () async {
      expect(await perguntar('Quanto falta de parcelas?'), contains('R\$ 50,00'));
    });

    test('comparação com o mês anterior', () async {
      final r = await perguntar('Gastei mais que no mês passado?');
      expect(r, contains('outubro'));
      expect(r, contains('R\$ 300,00'));
    });

    test('fatura não cai numa categoria de mesmo nome', () async {
      final c = ContextoFinanceiro(
        mes: _hoje,
        receitas: 0,
        despesas: 100,
        gastoPorCategoria: const {'Cartão': 100},
        envelopes: const [],
        metas: const [],
        cartoes: const [CartaoResumoIa(nome: 'Nubank', faturaAberta: 200)],
      );
      final r = (await motor.responder(pergunta: 'e a fatura do cartão?', contexto: c)).getOrElse((_) => '');
      expect(r, contains('Nubank'));
    });
  });
}
